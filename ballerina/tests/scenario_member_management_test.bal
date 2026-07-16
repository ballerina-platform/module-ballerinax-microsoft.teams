// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/test;

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
// Chains: createMember -> getMember -> listMembers -> deleteMember
//
// Requires a SECOND user in the tenant. Adding a user who is already a member fails, and a
// single-user tenant has no one else to add. Channel-scoped member add (addChannelMembers) is
// intentionally not used here: Graph only supports it on private/shared channels, whose creation
// is asynchronous (HTTP 202, empty body) and so the connector cannot return the new channel's id.
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

    // Step 4: Clean up.
    check teams->deleteMember(teamId, membershipId);
    logStep("Removed team member: " + membershipId);
}
