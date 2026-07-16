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

// Start a conversation in a channel: post a message, reply to it, and react to it.

import ballerina/io;
import ballerinax/microsoft.teams;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string tenantId = ?;
configurable string teamId = ?;
configurable string channelId = ?;

public function main() returns error? {
    teams:OAuth2RefreshTokenGrantConfig auth = {
        clientId,
        clientSecret,
        refreshToken,
        refreshUrl: string `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`
    };
    teams:Client teamsClient = check new ({auth});

    // Step 1: Post a message to the channel.
    teams:MicrosoftGraphChatMessage message = check teamsClient->createChannelMessage(teamId, channelId, {
        body: {contentType: "html", content: "Hello team! Let's kick off the project."}
    });
    string messageId = message.id ?: "";
    io:println("Posted message with id: ", messageId);

    // Step 2: Reply to the message.
    teams:MicrosoftGraphChatMessage reply = check teamsClient->createChannelMessageReply(teamId, channelId, messageId, {
        body: {contentType: "html", content: "Sounds great, count me in!"}
    });
    io:println("Posted reply with id: ", reply.id ?: "");

    // Step 3: Add a reaction to the original message. Graph expects a Unicode emoji here
    // (reaction names such as "like" are rejected with HTTP 400).
    check teamsClient->setReactionChannelMessage(teamId, channelId, messageId, {reactionType: "👍"});
    io:println("Reacted to message: ", messageId);
}
