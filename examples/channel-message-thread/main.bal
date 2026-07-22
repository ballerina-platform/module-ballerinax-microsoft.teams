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

// Start a threaded conversation in a channel: post a root message, reply to it,
// then list the replies to read the thread back.

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

    // Step 1: Post the root message to the channel.
    teams:ChatMessage rootMessage = check teamsClient->createChannelMessage(teamId, channelId, {
        body: {content: "Kicking off the release checklist for this sprint. Please reply with your status."}
    });
    string messageId = rootMessage.id ?: "";
    io:println("Posted root message: ", messageId);

    // Step 2: Reply to the root message, forming a thread.
    teams:ChatMessage reply = check teamsClient->createChannelMessageReply(teamId, channelId, messageId, {
        body: {content: "Backend tasks are done and deployed to staging."}
    });
    io:println("Posted reply: ", reply.id ?: "");

    // Step 3: List every reply in the thread.
    teams:ChatMessageCollectionResponse replies =
        check teamsClient->listChannelMessageReplies(teamId, channelId, messageId);
    io:println("Thread replies:");
    foreach teams:ChatMessage r in replies.value ?: [] {
        io:println("  - ", r.body?.content ?: "");
    }
}
