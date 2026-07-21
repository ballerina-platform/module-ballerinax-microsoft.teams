// Copyright (c) 2026 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/lang.runtime;
import ballerina/test;
import ballerina/time;

// Scenario: membership management (mirrors examples/channel-member-management).
//
// Read path (always runs live): list the channel's members and fetch one by id.
//
// Chains: listChannelMembers -> getChannelMember
@test:Config {groups: ["scenarios"]}
function testScenarioChannelMembersRead() returns error? {
    if !isLiveServer {
        return;
    }

    // Step 1: List the current members of the channel.
    MicrosoftGraphConversationMemberCollectionResponse members = check teams->listChannelMembers(teamId, channelId);
    MicrosoftGraphConversationMember[] memberList = members.value ?: [];
    test:assertTrue(memberList.length() > 0, "channel has no members to read");
    logStep("Listed channel members: " + memberList.length().toString());

    // Step 2: Fetch the first member by its membership id.
    string membershipId = memberList[0].id ?: "";
    test:assertTrue(membershipId.length() > 0, "first channel member has no id");
    MicrosoftGraphConversationMember member = check teams->getChannelMember(teamId, channelId, membershipId);
    test:assertEquals(member.id, membershipId, "getChannelMember returned a different id");
    logStep("Fetched channel member: " + membershipId);
}

// Write path (runs only when `secondUserId` is configured): add a real user to the team, read the
// new membership back, confirm it appears in the roster, then remove it.
//
// Chains: createMember -> getMember -> listMembers -> updateMember -> deleteMember
//         -> addMembers -> deleteMember
//
// Requires a SECOND user in the tenant. Adding a user who is already a member fails, and a
// single-user tenant has no one else to add.
@test:Config {groups: ["scenarios"]}
function testScenarioTeamMemberAddRemove() returns error? {
    if !isLiveServer {
        return;
    }
    if secondUserId == "" {
        logStep("Skipped: set `secondUserId` in Config.toml to a second tenant user to run add/remove.");
        return;
    }

    // Step 1: Add the second user to the team as an owner.
    MicrosoftGraphConversationMember created = check teams->createMember(teamId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: ["owner"],
        "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${secondUserId}')`
    });
    string membershipId = created.id ?: "";
    test:assertTrue(membershipId.length() > 0, "createMember did not return a membership id");
    logStep("Added team member: " + membershipId);

    // Step 2: Read the new membership back.
    MicrosoftGraphConversationMember fetched = check teams->getMember(teamId, membershipId);
    test:assertEquals(fetched.id, membershipId, "getMember returned a different id");
    logStep("Fetched team member");

    // Step 3: Confirm the member appears in the roster.
    MicrosoftGraphConversationMemberCollectionResponse members = check teams->listMembers(teamId);
    boolean found = false;
    foreach MicrosoftGraphConversationMember m in members.value ?: [] {
        if m.id == membershipId {
            found = true;
            break;
        }
    }
    test:assertTrue(found, "added member not found in listMembers");
    logStep("Located member in listMembers");

    // Step 3b: Change the member's role (demote owner -> member). A membership write can briefly lag
    // the reads that just succeeded (Graph documents that "membership addition may take time to
    // reflect"), so retry a few times before giving up. Promoting/demoting an owner also needs the
    // `TeamMember.ReadWrite.All` scope, which is skipped over if not consented.
    boolean roleUpdated = false;
    int roleAttempts = 0;
    while roleAttempts < 5 {
        MicrosoftGraphConversationMember|error demoted = teams->updateMember(teamId, membershipId, {
            atOdataType: "#microsoft.graph.aadUserConversationMember",
            roles: []
        });
        if demoted is MicrosoftGraphConversationMember {
            roleUpdated = true;
            break;
        }
        if isForbidden(demoted) {
            logStep("Skipped updateMember (needs TeamMember.ReadWrite.All).");
            break;
        }
        if !isSkippable(demoted) {
            return demoted;
        }
        roleAttempts += 1;
        runtime:sleep(4);
    }
    if roleUpdated {
        logStep("Updated team member role (demoted to member)");
    } else if roleAttempts >= 5 {
        logStep("Skipped updateMember after retries (membership write still propagating).");
    }

    // Step 4: Clean up.
    check teams->deleteMember(teamId, membershipId);
    logStep("Removed team member: " + membershipId);

    // Step 5: Bulk-add the same user via the add action, confirm the multi-status result, then
    // remove the membership again. Exercises addMembers (POST /members/add).
    ActionResultPartCollectionResponse addResult = check teams->addMembers(teamId, {
        values: [
            {
                atOdataType: "#microsoft.graph.aadUserConversationMember",
                roles: [],
                "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${secondUserId}')`
            }
        ]
    });
    test:assertTrue((addResult.value ?: []).length() > 0, "addMembers returned no result parts");
    logStep("Bulk-added team member via addMembers");

    // Find the re-added membership and remove it to leave the roster clean.
    MicrosoftGraphConversationMemberCollectionResponse afterAdd = check teams->listMembers(teamId);
    foreach MicrosoftGraphConversationMember m in afterAdd.value ?: [] {
        // `userId` lives on the aadUserConversationMember subtype, which the generated model exposes
        // as an open-record rest field rather than a typed property — so access it by key.
        if m["userId"] == secondUserId {
            check teams->deleteMember(teamId, m.id ?: "");
            logStep("Removed the bulk-added team member");
            break;
        }
    }
}

// Scenario: channel-scoped membership on a private channel.
//
// Channel member add/update/remove is supported only on private/shared channels (standard channels
// inherit the team roster). This creates a fresh private channel under the existing team, adds the
// second user, changes their role, reads it back, then removes both the member and the channel.
//
// Chains: createMember (team-roster prerequisite) -> createChannel(private, owner=userId)
//         -> (await provisioning) -> createChannelMember -> getChannelMember -> updateChannelMember
//         -> listChannelMembers -> deleteChannelMember -> deleteChannel -> deleteMember (cleanup)
//
// Requires `userId` (the private channel's owner) and `secondUserId` (the member to add). A user can
// only be added to a private channel if they are already in the parent team's roster, so the second
// user is added to the team first and that membership is removed again at the end. Private channel
// creation is asynchronous (HTTP 202); the connector returns the id from the response header.
@test:Config {groups: ["scenarios"]}
function testScenarioChannelMemberManagement() returns error? {
    if !isLiveServer {
        return;
    }
    if userId == "" || secondUserId == "" {
        logStep("Skipped: set both `userId` (channel owner) and `secondUserId` (member to add) in Config.toml.");
        return;
    }

    string suffix = time:utcNow()[0].toString();

    // Prerequisite: Graph only allows adding a user to a private channel if that user is already in
    // the parent team's roster (otherwise createChannelMember returns 404 "UserNotFoundInTeamRoster").
    // Ensure the second user is a team member first; remember whether we added them so we can remove
    // them again at the end. If they're already a member the add fails harmlessly and we leave them.
    string? addedTeamMembershipId = ();
    MicrosoftGraphConversationMember|error teamAdd = teams->createMember(teamId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: [],
        "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${secondUserId}')`
    });
    if teamAdd is MicrosoftGraphConversationMember {
        addedTeamMembershipId = teamAdd.id;
        logStep("Added second user to the team roster (prerequisite for private-channel membership)");
    } else {
        logStep("Second user already in the team roster (or add skipped): " + teamAdd.message());
    }

    // Step 1: Create a private channel owned by the signed-in user.
    MicrosoftGraphChannel channel = check teams->createChannel(teamId, {
        displayName: "Private Members " + suffix,
        description: "Private channel for the channel-member scenario test",
        membershipType: "private",
        "members": [
            {
                "@odata.type": "#microsoft.graph.aadUserConversationMember",
                "roles": ["owner"],
                "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${userId}')`
            }
        ]
    });
    string privateChannelId = channel.id ?: "";
    test:assertTrue(privateChannelId.length() > 0, "createChannel did not return a private channel id");
    logStep("Created private channel (async): " + privateChannelId);

    do {
        // Step 2: Wait until the private channel is ready to accept members.
        int attempts = 0;
        while attempts < 15 {
            MicrosoftGraphConversationMemberCollectionResponse|error probe = teams->listChannelMembers(teamId, privateChannelId);
            if probe is MicrosoftGraphConversationMemberCollectionResponse {
                break;
            }
            attempts += 1;
            runtime:sleep(5);
        }

        // Step 3: Add the second user to the private channel.
        MicrosoftGraphConversationMember added = check teams->createChannelMember(teamId, privateChannelId, {
            atOdataType: "#microsoft.graph.aadUserConversationMember",
            roles: [],
            "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${secondUserId}')`
        });
        test:assertTrue((added.id ?: "").length() > 0, "createChannelMember did not return a membership id");
        logStep("Added channel member");

        // Step 3b: Resolve the member's canonical membership id from the roster. The id returned by
        // createChannelMember embeds a per-channel ordinal that can differ from the stable id, so the
        // subsequent get/update/delete use the id looked up here (matched on the second user's id).
        MicrosoftGraphConversationMemberCollectionResponse chMembers = check teams->listChannelMembers(teamId, privateChannelId);
        test:assertTrue((chMembers.value ?: []).length() >= 1, "private channel unexpectedly has no members");
        string channelMembershipId = "";
        foreach MicrosoftGraphConversationMember cm in chMembers.value ?: [] {
            if cm["userId"] == secondUserId {
                channelMembershipId = cm.id ?: "";
                break;
            }
        }
        test:assertTrue(channelMembershipId.length() > 0, "added user not found in listChannelMembers");
        logStep("Listed private channel members and resolved membership id: " + (chMembers.value ?: []).length().toString() + " members");

        // Step 4: Read the membership back by its canonical id.
        MicrosoftGraphConversationMember fetched = check teams->getChannelMember(teamId, privateChannelId, channelMembershipId);
        test:assertEquals(fetched.id, channelMembershipId, "getChannelMember returned a different id");
        logStep("Fetched channel member");

        // Step 5: Promote the member to owner.
        _ = check teams->updateChannelMember(teamId, privateChannelId, channelMembershipId, {
            atOdataType: "#microsoft.graph.aadUserConversationMember",
            roles: ["owner"]
        });
        logStep("Promoted channel member to owner");

        // Step 6: Remove the member.
        check teams->deleteChannelMember(teamId, privateChannelId, channelMembershipId);
        logStep("Removed channel member");
    } on fail error e {
        // Best-effort cleanup of the private channel and the prerequisite team membership before
        // surfacing the failure.
        error? cleanup = teams->deleteChannel(teamId, privateChannelId);
        if cleanup is error {
            logStep("Cleanup note: could not delete private channel " + privateChannelId + " (" + cleanup.message() + ").");
        }
        if addedTeamMembershipId is string {
            error? teamCleanup = teams->deleteMember(teamId, addedTeamMembershipId);
            if teamCleanup is error {
                logStep("Cleanup note: could not remove team member " + addedTeamMembershipId + " (" + teamCleanup.message() + ").");
            }
        }
        return e;
    }

    // Step 7: Clean up the private channel, then the prerequisite team membership (if we added it).
    check teams->deleteChannel(teamId, privateChannelId);
    logStep("Deleted private channel: " + privateChannelId);
    if addedTeamMembershipId is string {
        check teams->deleteMember(teamId, addedTeamMembershipId);
        logStep("Removed the prerequisite team membership");
    }
}
