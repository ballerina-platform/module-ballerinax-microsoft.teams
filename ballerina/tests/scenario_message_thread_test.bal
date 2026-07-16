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

// Scenario: a channel message thread (mirrors examples/channel-message-thread).
//
// Chains: createChannelMessage -> getChannelMessage -> createChannelMessageReply
//         -> listChannelMessageReplies -> setReaction -> unsetReaction
//         -> softDeleteChannelMessage -> undoSoftDeleteChannelMessage
//
// Operates in the pre-existing `teamId`/`channelId`. Channel messages cannot be permanently deleted
// through Graph, so the message is soft-deleted and then restored (leaving it visible, as in the
// sample) rather than removed. Soft-delete requires the delegated `ChannelMessage.ReadWrite` scope.
@test:Config {groups: ["scenarios"]}
function testScenarioMessageThread() returns error? {
    if !isLiveServer {
        return;
    }

    // Step 1: Post a message to the channel.
    string messageText = "Hello team! Kicking off from the message-thread scenario test.";
    MicrosoftGraphChatMessage message = check teams->createChannelMessage(teamId, channelId, {
        body: {contentType: "html", content: "<p>" + messageText + "</p>"}
    });
    string newMessageId = message.id ?: "";
    test:assertTrue(newMessageId.length() > 0, "createChannelMessage did not return a message id");
    logStep("Posted message: " + newMessageId);

    // Step 2: Read the message back.
    MicrosoftGraphChatMessage fetched = check teams->getChannelMessage(teamId, channelId, newMessageId);
    test:assertEquals(fetched.id, newMessageId, "getChannelMessage returned a different id");
    test:assertTrue((fetched.body?.content ?: "").includes("Kicking off"), "message body did not round-trip");
    logStep("Fetched message and verified body");

    // Step 3: Reply to the message.
    MicrosoftGraphChatMessage reply = check teams->createChannelMessageReply(teamId, channelId, newMessageId, {
        body: {contentType: "html", content: "<p>Sounds great, count me in!</p>"}
    });
    string newReplyId = reply.id ?: "";
    test:assertTrue(newReplyId.length() > 0, "createChannelMessageReply did not return a reply id");
    logStep("Posted reply: " + newReplyId);

    // Step 4: List replies and confirm ours is present.
    MicrosoftGraphChatMessageCollectionResponse replies = check teams->listChannelMessageReplies(teamId, channelId, newMessageId);
    boolean replyFound = false;
    foreach MicrosoftGraphChatMessage r in replies.value ?: [] {
        if r.id == newReplyId {
            replyFound = true;
            break;
        }
    }
    test:assertTrue(replyFound, "created reply not found in listChannelMessageReplies");
    logStep("Located reply in listChannelMessageReplies");

    // Step 5: React to the message, then remove the reaction.
    // Graph expects `reactionType` to be a Unicode emoji (e.g. "👍"); reaction names such as
    // "like" are rejected with HTTP 400 "Unicode 'like' in the payload is not supported".
    string reaction = "👍";
    check teams->setReactionChannelMessage(teamId, channelId, newMessageId, {reactionType: reaction});
    logStep("Added reaction");
    check teams->unsetReactionChannelMessage(teamId, channelId, newMessageId, {reactionType: reaction});
    logStep("Removed reaction");

    // Step 6: Soft-delete the message and restore it (channel messages can't be hard-deleted).
    // Needs the delegated `ChannelMessage.ReadWrite` scope, which is distinct from the
    // ChannelMessage.Edit/Send/Read.All scopes. If it isn't consented, Graph returns 403 and these
    // two steps are skipped rather than failing the scenario.
    error? softDeleteResult = teams->softDeleteChannelMessage(teamId, channelId, newMessageId);
    if softDeleteResult is error {
        if isForbidden(softDeleteResult) {
            logStep("Skipped soft-delete/restore: needs the delegated 'ChannelMessage.ReadWrite' scope.");
            return;
        }
        return softDeleteResult;
    }
    logStep("Soft-deleted message");
    check teams->undoSoftDeleteChannelMessage(teamId, channelId, newMessageId);
    logStep("Restored message");
}
