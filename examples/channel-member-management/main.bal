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

// Manage channel membership: create a private channel with an owner and list its members.
//
// Per-channel membership applies to private and shared channels; standard channels inherit the
// team's roster and don't support adding members directly.

import ballerina/io;
import ballerina/lang.runtime;
import ballerinax/microsoft.teams;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string tenantId = ?;
configurable string teamId = ?;
// Object id of the user who will own the new private channel (typically the signed-in user).
configurable string ownerId = ?;

public function main() returns error? {
    teams:OAuth2RefreshTokenGrantConfig auth = {
        clientId,
        clientSecret,
        refreshToken,
        refreshUrl: string `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`
    };
    teams:Client teamsClient = check new ({auth});

    // Step 1: Create a private channel with an owner. Private-channel creation is asynchronous in
    // Microsoft Graph (HTTP 202); the connector returns the new channel's id from the response.
    teams:MicrosoftGraphChannel channel = check teamsClient->createChannel(teamId, {
        displayName: "Project X (Private)",
        description: "Private channel for the Project X working group",
        membershipType: "private",
        "members": [
            {
                "@odata.type": "#microsoft.graph.aadUserConversationMember",
                "roles": ["owner"],
                "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${ownerId}')`
            }
        ]
    });
    string channelId = channel.id ?: "";
    io:println("Created private channel with id: ", channelId);

    // Step 2: Wait for the channel to finish provisioning before reading its membership.
    int attempts = 0;
    while attempts < 15 {
        teams:MicrosoftGraphConversationMemberCollectionResponse|error probe = teamsClient->listChannelMembers(teamId, channelId);
        if probe is teams:MicrosoftGraphConversationMemberCollectionResponse {
            break;
        }
        attempts += 1;
        runtime:sleep(5);
    }

    // Step 3: List the channel's members.
    teams:MicrosoftGraphConversationMemberCollectionResponse members = check teamsClient->listChannelMembers(teamId, channelId);
    foreach teams:MicrosoftGraphConversationMember member in members.value ?: [] {
        io:println("Member: ", member?.displayName ?: member.id ?: "unknown");
    }

    // Step 4: Clean up the private channel.
    check teamsClient->deleteChannel(teamId, channelId);
    io:println("Deleted channel: ", channelId);
}
