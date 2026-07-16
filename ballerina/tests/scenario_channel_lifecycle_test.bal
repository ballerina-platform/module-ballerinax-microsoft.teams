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
import ballerina/time;

// Scenario: channel lifecycle within an existing team (mirrors examples/team-and-channel-setup).
//
// Chains: createChannel -> getChannel -> updateChannel -> getChannel -> listChannels -> deleteChannel.
//
// Note: creating a *team* is an asynchronous Graph operation (HTTP 202 with an empty body), so the
// connector's `createTeam` cannot return the new team's id. Scenarios therefore operate inside the
// pre-existing team identified by `teamId` rather than provisioning a fresh team. A standard channel
// is created and updated here — the General/primary channel cannot be renamed or updated.
@test:Config {groups: ["scenarios"]}
function testScenarioChannelLifecycle() returns error? {
    if !isLiveServer {
        return;
    }

    string suffix = time:utcNow()[0].toString();
    string channelName = "Connector Scenario " + suffix;

    // Step 1: Create a standard channel in the existing team.
    MicrosoftGraphChannel created = check teams->createChannel(teamId, {
        displayName: channelName,
        description: "Created by the channel-lifecycle scenario test"
    });
    string newChannelId = created.id ?: "";
    test:assertTrue(newChannelId.length() > 0, "createChannel did not return a channel id");
    test:assertEquals(created.displayName, channelName, "created channel name mismatch");
    logStep("Created channel: " + newChannelId);

    // Step 2: Read it back and confirm the name round-tripped.
    MicrosoftGraphChannel fetched = check teams->getChannel(teamId, newChannelId);
    test:assertEquals(fetched.id, newChannelId, "getChannel returned a different id");
    test:assertEquals(fetched.displayName, channelName, "getChannel name mismatch");
    logStep("Fetched channel and verified name");

    // Step 3: Update the channel's description. A channel PATCH returns 204 No Content, but the
    // connector re-fetches so `updateChannel` still returns the updated entity.
    string updatedDescription = "Updated by the channel-lifecycle scenario test";
    MicrosoftGraphChannel updated = check teams->updateChannel(teamId, newChannelId, {
        description: updatedDescription
    });
    test:assertEquals(updated?.description, updatedDescription, "updateChannel did not return the updated description");
    logStep("Updated channel description");

    // Step 4: Confirm the update by fetching again.
    MicrosoftGraphChannel refetched = check teams->getChannel(teamId, newChannelId);
    test:assertEquals(refetched?.description, updatedDescription, "description update not persisted");
    logStep("Re-fetched channel and verified updated description");

    // Step 5: List channels and confirm ours is present.
    MicrosoftGraphChannelCollectionResponse channels = check teams->listChannels(teamId);
    boolean found = false;
    foreach MicrosoftGraphChannel channel in channels.value ?: [] {
        if channel.id == newChannelId {
            found = true;
            break;
        }
    }
    test:assertTrue(found, "created channel not found in listChannels");
    logStep("Located channel in listChannels");

    // Step 6: Clean up.
    check teams->deleteChannel(teamId, newChannelId);
    logStep("Deleted channel: " + newChannelId);
}
