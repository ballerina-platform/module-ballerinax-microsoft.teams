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

// Post to a team's primary ("General") channel and react to the message, then list the
// channel's recent messages.
//
// Microsoft Graph doesn't support sending a message through the `primaryChannel` navigation
// directly, so this example first reads the primary channel to get its real channel id and then
// posts through the standard channel messaging path.

import ballerina/io;
import ballerinax/microsoft.teams;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string tenantId = ?;
configurable string teamId = ?;

public function main() returns error? {
    teams:OAuth2RefreshTokenGrantConfig auth = {
        clientId,
        clientSecret,
        refreshToken,
        refreshUrl: string `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`
    };
    teams:Client teamsClient = check new ({auth});

    // Step 1: Read the team's primary channel to obtain its id.
    teams:Channel primaryChannel = check teamsClient->getPrimaryChannel(teamId);
    string channelId = check requireId(primaryChannel.id, "primary channel id");
    io:println("Primary channel: ", primaryChannel?.displayName ?: channelId);

    // Step 2: Post a message to the primary channel.
    teams:ChatMessage message = check teamsClient->createChannelMessage(teamId, channelId, {
        body: {content: "Welcome to the team! React with a 👍 if you're onboard."}
    });
    string messageId = check requireId(message.id, "message id");
    io:println("Posted message: ", messageId);

    // Step 3: Add a 👍 reaction to the message. Graph expects the reaction type as a Unicode emoji.
    check teamsClient->setReactionChannelMessage(teamId, channelId, messageId, {reactionType: "👍"});
    io:println("Reacted to message: ", messageId);

    // Step 4: List the primary channel's recent messages.
    teams:ChatMessageCollectionResponse messages =
        check teamsClient->listChannelMessages(teamId, channelId);
    io:println("Recent messages in the primary channel:");
    foreach teams:ChatMessage m in messages.value ?: [] {
        io:println("  - ", m.body?.content ?: "");
    }
}

// Returns the id when present, or a clear error when the API response omits it.
isolated function requireId(string? id, string what) returns string|error {
    return id ?: error(string `Expected a ${what} in the response but none was returned`);
}
