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

// Scenario: provision a team, add several channels, and add members to the team and a channel.
// This is a common onboarding flow ("stand up a new team") and extends examples/team-and-channel-setup.
//
// Chains: createTeam -> (wait for provisioning) -> getTeam -> updateTeam -> getPrimaryChannel
//         -> createChannel x3 -> listChannels -> createMember (team) -> createChannel (private)
//         -> createChannelMember -> listChannelMembers -> deleteTeam
//
// Team creation and private-channel creation are asynchronous in Graph (HTTP 202, empty body); the
// connector now returns the new id from the response `Location` header, and this test polls for
// provisioning to finish before operating on the resources. Because it creates a real team — a
// slow operation that can only be auto-deleted with `Group.ReadWrite.All` — it is gated behind the
// `runTeamProvisioning` flag and off by default.
@test:Config {groups: ["scenarios"]}
function testScenarioTeamProvisioning() returns error? {
    if !isLiveServer {
        return;
    }
    if !runTeamProvisioning {
        logStep("Skipped team-provisioning scenario: set `runTeamProvisioning = true` in Config.toml (creates a real team).");
        return;
    }
    if userId == "" {
        logStep("Skipped: set `userId` in Config.toml (needed as the private channel owner).");
        return;
    }

    string suffix = time:utcNow()[0].toString();

    // Step 1: Create a team. Asynchronous — the connector returns the id from the response header.
    MicrosoftGraphTeam team = check teams->createTeam({
        displayName: "Connector Scenario Team " + suffix,
        description: "Created by the team-provisioning scenario test",
        "template@odata.bind": "https://graph.microsoft.com/v1.0/teamsTemplates('standard')"
    });
    string newTeamId = team.id ?: "";
    test:assertTrue(newTeamId.length() > 0, "createTeam did not return a team id");
    logStep("Created team (async): " + newTeamId);

    do {
        // Step 2: Wait for the team to finish provisioning before operating on it.
        check waitUntilTeamReady(newTeamId);
        logStep("Team finished provisioning");

        // Step 2b: Read the team back, rename it, and resolve its primary (General) channel.
        MicrosoftGraphTeam fetchedTeam = check teams->getTeam(newTeamId);
        test:assertEquals(fetchedTeam.id, newTeamId, "getTeam returned a different id");
        logStep("Fetched team and verified id");

        string updatedTeamDescription = "Updated by the team-provisioning scenario test";
        MicrosoftGraphTeam updatedTeam = check teams->updateTeam(newTeamId, {description: updatedTeamDescription});
        test:assertEquals(updatedTeam?.description, updatedTeamDescription, "updateTeam did not return the updated description");
        logStep("Updated team description");

        MicrosoftGraphChannel general = check teams->getPrimaryChannel(newTeamId);
        test:assertTrue((general.id ?: "").length() > 0, "getPrimaryChannel did not return a channel id");
        logStep("Resolved primary channel: " + (general.displayName ?: general.id ?: ""));

        // Step 3: Create several standard channels.
        string[] channelIds = [];
        foreach string base in ["Design", "Engineering", "Marketing"] {
            MicrosoftGraphChannel channel = check createChannelWithRetry(newTeamId, {
                displayName: base + " " + suffix,
                description: base + " channel created by the scenario test"
            });
            channelIds.push(channel.id ?: "");
            logStep("Created channel: " + base);
        }
        test:assertEquals(channelIds.length(), 3, "expected three channels to be created");

        // Step 4: Confirm the channels are listed on the team.
        MicrosoftGraphChannelCollectionResponse channels = check teams->listChannels(newTeamId);
        int present = 0;
        foreach MicrosoftGraphChannel ch in channels.value ?: [] {
            if channelIds.indexOf(ch.id ?: "") is int {
                present += 1;
            }
        }
        test:assertEquals(present, 3, "not all created channels were listed");
        logStep("Verified channels in listChannels");

        // Step 5: Membership — add the second user to the team, then to a private channel.
        // (Standard channels inherit team membership; only private/shared channels have their own.)
        if secondUserId != "" {
            _ = check addTeamMemberWithRetry(newTeamId, secondUserId);
            logStep("Added member to team");

            MicrosoftGraphChannel privateChannel = check createChannelWithRetry(newTeamId, {
                displayName: "Private " + suffix,
                description: "Private channel created by the scenario test",
                membershipType: "private",
                "members": [
                    {
                        "@odata.type": "#microsoft.graph.aadUserConversationMember",
                        "roles": ["owner"],
                        "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${userId}')`
                    }
                ]
            });
            string privateChannelId = privateChannel.id ?: "";
            test:assertTrue(privateChannelId.length() > 0, "createChannel did not return a private channel id");
            logStep("Created private channel (async): " + privateChannelId);

            check addChannelMemberWithRetry(newTeamId, privateChannelId, secondUserId);
            logStep("Added member to private channel");

            MicrosoftGraphConversationMemberCollectionResponse chMembers = check teams->listChannelMembers(newTeamId, privateChannelId);
            test:assertTrue((chMembers.value ?: []).length() >= 1, "private channel has no members");
            logStep("Verified private channel members: " + (chMembers.value ?: []).length().toString());
        } else {
            logStep("Skipped member steps: set `secondUserId` in Config.toml to add members to the team/channel.");
        }
    } on fail error e {
        error? cleanup = teams->deleteTeam(newTeamId);
        if cleanup is error {
            logStep("Cleanup note: could not delete team " + newTeamId + " (" + cleanup.message() + "); delete it manually.");
        }
        return e;
    }

    // Step 6: Delete the team (best-effort; DELETE /teams needs `Group.ReadWrite.All`).
    error? deleteResult = teams->deleteTeam(newTeamId);
    if deleteResult is error {
        logStep("Team exercised OK but auto-delete failed (needs Group.ReadWrite.All): " + newTeamId + " — delete manually.");
    } else {
        logStep("Deleted team: " + newTeamId);
    }
}

// Polls until the team is provisioned enough to operate on (listing its channels succeeds).
function waitUntilTeamReady(string teamId) returns error? {
    int attempts = 0;
    while attempts < 20 {
        MicrosoftGraphChannelCollectionResponse|error result = teams->listChannels(teamId);
        if result is MicrosoftGraphChannelCollectionResponse {
            return;
        }
        attempts += 1;
        runtime:sleep(6);
    }
    return error("team " + teamId + " did not become ready within the expected time");
}

// Creates a channel, retrying while the team is still settling after provisioning.
function createChannelWithRetry(string teamId, MicrosoftGraphChannel payload) returns MicrosoftGraphChannel|error {
    int attempts = 0;
    while true {
        MicrosoftGraphChannel|error result = teams->createChannel(teamId, payload);
        if result is MicrosoftGraphChannel {
            return result;
        }
        attempts += 1;
        if attempts >= 6 {
            return result;
        }
        runtime:sleep(5);
    }
}

// Adds a team member, retrying transient failures during provisioning.
function addTeamMemberWithRetry(string teamId, string memberUserId) returns MicrosoftGraphConversationMember|error {
    int attempts = 0;
    while true {
        MicrosoftGraphConversationMember|error result = teams->createMember(teamId, {
            atOdataType: "#microsoft.graph.aadUserConversationMember",
            roles: [],
            "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${memberUserId}')`
        });
        if result is MicrosoftGraphConversationMember {
            return result;
        }
        attempts += 1;
        if attempts >= 6 {
            return result;
        }
        runtime:sleep(5);
    }
}

// Adds a user to a (private) channel, retrying while the channel is still settling.
function addChannelMemberWithRetry(string teamId, string channelId, string memberUserId) returns error? {
    int attempts = 0;
    while true {
        MicrosoftGraphConversationMember|error result = teams->createChannelMember(teamId, channelId, {
            atOdataType: "#microsoft.graph.aadUserConversationMember",
            roles: [],
            "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${memberUserId}')`
        });
        if result is MicrosoftGraphConversationMember {
            return;
        }
        attempts += 1;
        if attempts >= 6 {
            return result;
        }
        runtime:sleep(5);
    }
}
