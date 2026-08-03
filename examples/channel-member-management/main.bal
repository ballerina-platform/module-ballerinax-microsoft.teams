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

// Manage channel membership: create a private channel with an owner and list its members.
//
// Per-channel membership applies to private and shared channels; standard channels inherit the
// team's roster and don't support adding members directly. This example creates its own private
// channel so it is self-contained, then cleans it up at the end.

import ballerina/http;
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

    // Step 1: Create a private channel with an owner. Channel creation returns the raw `http:Response`:
    // a private channel is created asynchronously (202 Accepted, id in the `Location` header), while a
    // standard channel comes back synchronously as 201 Created with the channel in the body. Handle both.
    http:Response createResponse = check teamsClient->createChannel(teamId, {
        displayName: "Ballerina Working Group",
        description: "Private channel created by the channel-member-management example",
        membershipType: "private",
        "members": [
            {
                "@odata.type": "#microsoft.graph.aadUserConversationMember",
                "roles": ["owner"],
                "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${ownerId}')`
            }
        ]
    });
    string channelId = check channelIdFrom(createResponse);
    io:println("Created private channel with id: ", channelId);

    // Step 2: Wait for the channel to finish provisioning before reading its membership.
    int attempts = 0;
    while attempts < 15 {
        teams:ConversationMemberCollectionResponse|error probe = teamsClient->listChannelMembers(teamId, channelId);
        if probe is teams:ConversationMemberCollectionResponse {
            break;
        }
        attempts += 1;
        runtime:sleep(5);
    }

    // Step 3: List the channel's members.
    teams:ConversationMemberCollectionResponse members = check teamsClient->listChannelMembers(teamId, channelId);
    io:println("Channel members:");
    foreach teams:ConversationMember member in members.value ?: [] {
        io:println("  - ", member?.displayName ?: member.id ?: "unknown");
    }

    // Step 4: Clean up the private channel.
    check teamsClient->deleteChannel(teamId, channelId);
    io:println("Deleted channel: ", channelId);
}

// Resolves the created channel's id from a create-channel response. Because the connector returns the
// raw `http:Response`, HTTP error statuses are not raised as errors — check the status code explicitly.
isolated function channelIdFrom(http:Response response) returns string|error {
    if response.statusCode == http:STATUS_ACCEPTED {
        // Async (private/shared) creation: the new channel's URL is in the Location header.
        string location = check response.getHeader("Location");
        return idBetween(location, "channels('", "')");
    }
    if response.statusCode == http:STATUS_CREATED {
        // Synchronous (standard) creation: the channel is in the response body.
        teams:Channel channel = check (check response.getJsonPayload()).cloneWithType();
        return channel.id ?: "";
    }
    // Any other status is a failure — surface the response body.
    json body = check response.getJsonPayload();
    return error(string `Channel creation failed (HTTP ${response.statusCode}): ${body.toJsonString()}`);
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
