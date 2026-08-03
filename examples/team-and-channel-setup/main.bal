// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

// Provision a new team and set up a channel in it, handling Microsoft Graph's asynchronous
// operations.
//
// Both `createTeam` and `createChannel` can complete asynchronously: Graph returns 202 Accepted
// with an empty body and the new resource's URL in the `Location` header (team creation is always
// async; shared-channel creation is async too). The connector surfaces these as the raw
// `http:Response`, so this example reads the id from the `Location` header (or the body when the
// resource is created synchronously) and polls until the resource is ready.

import ballerina/http;
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

    // Step 1: Create a new team. Graph answers 202 Accepted with the new team's resource URL in the
    // `Location` header (like `/teams('<team-id>')/operations('<op-id>')`); read the id from it.
    // Because the connector returns the raw `http:Response`, HTTP error statuses are not raised as
    // errors — check the status code explicitly before reading the header.
    http:Response createTeamResponse = check teamsClient->createTeam({
        displayName: "Engineering",
        description: "Team for the engineering department",
        "template@odata.bind": "https://graph.microsoft.com/v1.0/teamsTemplates('standard')"
    });
    if createTeamResponse.statusCode != http:STATUS_ACCEPTED {
        json errorBody = check createTeamResponse.getJsonPayload();
        return error(string `Team creation failed (HTTP ${createTeamResponse.statusCode}): ${errorBody.toJsonString()}`);
    }
    string teamLocation = check createTeamResponse.getHeader("Location");
    string teamId = idBetween(teamLocation, "teams('", "')");
    io:println("Created team with id: ", teamId);

    // Step 2: Team provisioning is asynchronous — poll until the team responds to a channels read
    // before operating on it.
    int attempts = 0;
    while attempts < 20 {
        teams:ChannelCollectionResponse|error channels = teamsClient->listChannels(teamId);
        if channels is teams:ChannelCollectionResponse {
            break;
        }
        attempts += 1;
        runtime:sleep(6);
    }

    // Step 3: Create a channel. A standard channel is created synchronously (201 Created with the
    // channel in the body); a shared channel is created asynchronously (202 Accepted, id in the
    // `Location` header). Handle both.
    http:Response createChannelResponse = check teamsClient->createChannel(teamId, {
        displayName: "Design Discussions",
        description: "Channel for design conversations"
    });
    string channelId;
    if createChannelResponse.statusCode == http:STATUS_ACCEPTED {
        string channelLocation = check createChannelResponse.getHeader("Location");
        channelId = idBetween(channelLocation, "channels('", "')");
    } else if createChannelResponse.statusCode == http:STATUS_CREATED {
        teams:Channel channel =
            check (check createChannelResponse.getJsonPayload()).cloneWithType();
        channelId = channel.id ?: "";
    } else {
        json errorBody = check createChannelResponse.getJsonPayload();
        return error(string `Channel creation failed (HTTP ${createChannelResponse.statusCode}): ${errorBody.toJsonString()}`);
    }
    io:println("Created channel with id: ", channelId);

    // Step 4: List the team's channels.
    teams:ChannelCollectionResponse channels = check teamsClient->listChannels(teamId);
    io:println("Channels in the team:");
    foreach teams:Channel channel in channels.value ?: [] {
        io:println("  - ", channel?.displayName ?: channel.id ?: "unknown");
    }
}

// Extracts the substring of `value` between `prefix` and the next `suffix` after it.
isolated function idBetween(string value, string prefix, string suffix) returns string {
    int? startIndex = value.indexOf(prefix);
    if startIndex is () {
        return "";
    }
    int 'from = startIndex + prefix.length();
    int? end = value.indexOf(suffix, 'from);
    return value.substring('from, end ?: value.length());
}
