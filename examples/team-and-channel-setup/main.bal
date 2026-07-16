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

// Provision a new Microsoft Teams team and add a channel to it.

import ballerina/io;
import ballerina/lang.runtime;
import ballerinax/microsoft.teams;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string tenantId = ?;

public function main() returns error? {
    teams:OAuth2RefreshTokenGrantConfig auth = {
        clientId,
        clientSecret,
        refreshToken,
        refreshUrl: string `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`
    };
    teams:Client teamsClient = check new ({auth});

    // Step 1: Create a new team. Team creation is asynchronous in Microsoft Graph (it responds with
    // HTTP 202 and an empty body); the connector returns the new team's id from the response header.
    teams:MicrosoftGraphTeam newTeam = check teamsClient->createTeam({
        displayName: "Engineering",
        description: "Team for the engineering department",
        "template@odata.bind": "https://graph.microsoft.com/v1.0/teamsTemplates('standard')"
    });
    string teamId = newTeam.id ?: "";
    io:println("Created team with id: ", teamId);

    // Step 2: Wait for provisioning to finish before using the team (poll until channels list).
    int attempts = 0;
    while attempts < 20 {
        teams:MicrosoftGraphChannelCollectionResponse|error channels = teamsClient->listChannels(teamId);
        if channels is teams:MicrosoftGraphChannelCollectionResponse {
            break;
        }
        attempts += 1;
        runtime:sleep(6);
    }

    // Step 3: Create a channel inside the newly created team.
    teams:MicrosoftGraphChannel channel = check teamsClient->createChannel(teamId, {
        displayName: "Design Discussions",
        description: "Channel for design conversations"
    });
    io:println("Created channel with id: ", channel.id ?: "");
}
