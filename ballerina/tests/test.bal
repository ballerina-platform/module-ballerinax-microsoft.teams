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


import ballerina/http;
import ballerina/test;

// Set to `true` in tests/Config.toml to run against the real Microsoft Graph API
// instead of the local mock server.
configurable boolean isLiveServer = false;

// Which OAuth2 grant to use when isLiveServer = true:
// - "client_credentials": app-only auth with clientId + clientSecret + tenantId (no user or refresh token needed)
// - "refresh_token": delegated auth with clientId + clientSecret + refreshToken
configurable string authMode = "client_credentials";

configurable string clientId = "";
configurable string clientSecret = "";
configurable string tenantId = "common";
configurable string refreshToken = "";

final string serviceUrl = isLiveServer ? "https://graph.microsoft.com/v1.0" : "http://localhost:9090/v1.0";

final Client teams = check initClient();

isolated function initClient() returns Client|error {
    if isLiveServer {
        string tokenUrl = string `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`;
        if authMode == "refresh_token" {
            // Request `.default` so the token carries every statically-consented delegated
            // permission (e.g. ChannelMessage.ReadWrite added later), not just the scopes present
            // when the refresh token was first minted.
            OAuth2RefreshTokenGrantConfig auth = {clientId, clientSecret, refreshToken, refreshUrl: tokenUrl, scopes: ["https://graph.microsoft.com/.default"]};
            return new ({auth}, serviceUrl);
        }
        OAuth2ClientCredentialsGrantConfig auth = {clientId, clientSecret, tokenUrl, scopes: ["https://graph.microsoft.com/.default"]};
        return new ({auth}, serviceUrl);
    }
    http:BearerTokenConfig auth = {token: "test-token"};
    return new ({auth}, serviceUrl);
}

// Reusable identifiers matched by the mock server.
final string teamId = "d7b53d1b-17a8-4679-973f-4a7312675584";
final string channelId = "19:xsp4sBBt2cIBsZrtsQZtN205M_A_dV3Mkr_p9qoHuSw1@thread.tacv2";
final string memberId = "MCMjMSMjMjk1M2ZjZTctMjI4NC00ZGY1LThlODUtZGQzNGVkNDk0NWVkIyNkN2I1M2QxYi0xN2E4LTQ2NzktOTczZi00YTczMTI2NzU1ODQjIzcxZjYxNzVkLTNlMzUtNDU1NC1hYzBkLTZlYmU1NGJkZTk2ZA==";
final string messageId = "1784139915495";
final string replyId = "1784140530431";

// The signed-in user (owner of teamId/channelId above). Reused for member/tag/notification
// payloads since the live tenant has no second user to reference.
final string myUserId = "71f6175d-3e35-4554-ac0d-6ebe54bde96d";

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_createTeam() returns error? {
    MicrosoftGraphTeam response = check teams->createTeam({
        displayName: "Ballerina Connector Test Team",
        description: "Team created by the Ballerina Microsoft Teams connector test suite",
        "template@odata.bind": "https://graph.microsoft.com/v1.0/teamsTemplates('standard')"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_getTeam() returns error? {
    MicrosoftGraphTeam response = check teams->getTeam(teamId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_deleteTeam() returns error? {
    error? response = teams->deleteTeam(teamId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_updateTeam() returns error? {
    MicrosoftGraphTeam response = check teams->updateTeam(teamId, {
        description: "Updated by the Ballerina Microsoft Teams connector test suite"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listAllChannels() returns error? {
    MicrosoftGraphChannelCollectionResponse response = check teams->listAllChannels(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getAllChannel() returns error? {
    MicrosoftGraphChannel response = check teams->getAllChannel(teamId, channelId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countAllChannels() returns error? {
    string response = check teams->countAllChannels(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_listChannels() returns error? {
    MicrosoftGraphChannelCollectionResponse response = check teams->listChannels(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_createChannel() returns error? {
    MicrosoftGraphChannel response = check teams->createChannel(teamId, {
        displayName: "Connector Test Channel",
        description: "Channel created by the Ballerina Microsoft Teams connector test suite"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_getChannel() returns error? {
    MicrosoftGraphChannel response = check teams->getChannel(teamId, channelId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_deleteChannel() returns error? {
    error? response = teams->deleteChannel(teamId, channelId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_updateChannel() returns error? {
    MicrosoftGraphChannel response = check teams->updateChannel(teamId, channelId, {
        description: "Updated by the Ballerina Microsoft Teams connector test suite"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listChannelAllMembers() returns error? {
    MicrosoftGraphConversationMemberCollectionResponse response = check teams->listChannelAllMembers(teamId, channelId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_createChannelAllMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->createChannelAllMember(teamId, channelId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: [],
        "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getChannelAllMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->getChannelAllMember(teamId, channelId, memberId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deleteChannelAllMember() returns error? {
    error? response = teams->deleteChannelAllMember(teamId, channelId, memberId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updateChannelAllMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->updateChannelAllMember(teamId, channelId, memberId, {
        roles: ["owner"]
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countChannelAllMembers() returns error? {
    string response = check teams->countChannelAllMembers(teamId, channelId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_addChannelAllMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->addChannelAllMembers(teamId, channelId, {
        values: [
            {
                atOdataType: "#microsoft.graph.aadUserConversationMember",
                roles: [],
                "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
            }
        ]
    });
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_removeChannelAllMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->removeChannelAllMembers(teamId, channelId, {});
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listChannelEnabledApps() returns error? {
    MicrosoftGraphTeamsAppCollectionResponse response = check teams->listChannelEnabledApps(teamId, channelId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getChannelEnabledApp() returns error? {
    MicrosoftGraphTeamsApp response = check teams->getChannelEnabledApp(teamId, channelId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countChannelEnabledApps() returns error? {
    string response = check teams->countChannelEnabledApps(teamId, channelId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getChannelFilesFolder() returns error? {
    MicrosoftGraphDriveItem response = check teams->getChannelFilesFolder(teamId, channelId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getChannelFilesFolderContent() returns error? {
    byte[] response = check teams->getChannelFilesFolderContent(teamId, channelId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updateChannelFilesFolderContent() returns error? {
    MicrosoftGraphDriveItem response = check teams->updateChannelFilesFolderContent(teamId, channelId, "mock-content".toBytes());
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deleteChannelFilesFolderContent() returns error? {
    error? response = teams->deleteChannelFilesFolderContent(teamId, channelId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_listChannelMembers() returns error? {
    MicrosoftGraphConversationMemberCollectionResponse response = check teams->listChannelMembers(teamId, channelId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_createChannelMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->createChannelMember(teamId, channelId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: [],
        "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_getChannelMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->getChannelMember(teamId, channelId, memberId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_deleteChannelMember() returns error? {
    error? response = teams->deleteChannelMember(teamId, channelId, memberId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updateChannelMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->updateChannelMember(teamId, channelId, memberId, {
        roles: ["owner"]
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countChannelMembers() returns error? {
    string response = check teams->countChannelMembers(teamId, channelId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_addChannelMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->addChannelMembers(teamId, channelId, {
        values: [
            {
                atOdataType: "#microsoft.graph.aadUserConversationMember",
                roles: [],
                "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
            }
        ]
    });
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_removeChannelMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->removeChannelMembers(teamId, channelId, {});
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_listChannelMessages() returns error? {
    MicrosoftGraphChatMessageCollectionResponse response = check teams->listChannelMessages(teamId, channelId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_createChannelMessage() returns error? {
    MicrosoftGraphChatMessage response = check teams->createChannelMessage(teamId, channelId, {
        body: {
            contentType: "html",
            content: "<p>Hello from the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_getChannelMessage() returns error? {
    MicrosoftGraphChatMessage response = check teams->getChannelMessage(teamId, channelId, messageId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_deleteChannelMessage() returns error? {
    error? response = teams->deleteChannelMessage(teamId, channelId, messageId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_updateChannelMessage() returns error? {
    MicrosoftGraphChatMessage response = check teams->updateChannelMessage(teamId, channelId, messageId, {
        body: {
            contentType: "html",
            content: "<p>Updated by the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listChannelMessageHostedContents() returns error? {
    MicrosoftGraphChatMessageHostedContentCollectionResponse response = check teams->listChannelMessageHostedContents(teamId, channelId, messageId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_createChannelMessageHostedContent() returns error? {
    MicrosoftGraphChatMessageHostedContent response = check teams->createChannelMessageHostedContent(teamId, channelId, messageId, {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getChannelMessageHostedContent() returns error? {
    MicrosoftGraphChatMessageHostedContent response = check teams->getChannelMessageHostedContent(teamId, channelId, messageId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deleteChannelMessageHostedContent() returns error? {
    error? response = teams->deleteChannelMessageHostedContent(teamId, channelId, messageId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updateChannelMessageHostedContent() returns error? {
    // NOTE: "test-id" is not a real hostedContent id (would require chaining from a prior
    // createChannelMessageHostedContent call); this call is expected to 404 against the live API.
    MicrosoftGraphChatMessageHostedContent response = check teams->updateChannelMessageHostedContent(teamId, channelId, messageId, "test-id", {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getChannelMessageHostedContentValue() returns error? {
    byte[] response = check teams->getChannelMessageHostedContentValue(teamId, channelId, messageId, "test-id");
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updateChannelMessageHostedContentValue() returns error? {
    error? response = teams->updateChannelMessageHostedContentValue(teamId, channelId, messageId, "test-id", "mock-content".toBytes());
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deleteChannelMessageHostedContentValue() returns error? {
    error? response = teams->deleteChannelMessageHostedContentValue(teamId, channelId, messageId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countChannelMessageHostedContents() returns error? {
    string response = check teams->countChannelMessageHostedContents(teamId, channelId, messageId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_setReactionChannelMessage() returns error? {
    error? response = teams->setReactionChannelMessage(teamId, channelId, messageId, {reactionType: "like"});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_softDeleteChannelMessage() returns error? {
    error? response = teams->softDeleteChannelMessage(teamId, channelId, messageId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_undoSoftDeleteChannelMessage() returns error? {
    error? response = teams->undoSoftDeleteChannelMessage(teamId, channelId, messageId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_unsetReactionChannelMessage() returns error? {
    error? response = teams->unsetReactionChannelMessage(teamId, channelId, messageId, {});
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_listChannelMessageReplies() returns error? {
    MicrosoftGraphChatMessageCollectionResponse response = check teams->listChannelMessageReplies(teamId, channelId, messageId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_createChannelMessageReply() returns error? {
    MicrosoftGraphChatMessage response = check teams->createChannelMessageReply(teamId, channelId, messageId, {
        body: {
            contentType: "html",
            content: "<p>Reply from the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_getChannelMessageReply() returns error? {
    MicrosoftGraphChatMessage response = check teams->getChannelMessageReply(teamId, channelId, messageId, replyId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deleteChannelMessageReply() returns error? {
    error? response = teams->deleteChannelMessageReply(teamId, channelId, messageId, replyId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updateChannelMessageReply() returns error? {
    MicrosoftGraphChatMessage response = check teams->updateChannelMessageReply(teamId, channelId, messageId, replyId, {
        body: {
            contentType: "html",
            content: "<p>Updated reply from the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listChannelMessageReplyHostedContents() returns error? {
    MicrosoftGraphChatMessageHostedContentCollectionResponse response = check teams->listChannelMessageReplyHostedContents(teamId, channelId, messageId, replyId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_createChannelMessageReplyHostedContent() returns error? {
    MicrosoftGraphChatMessageHostedContent response = check teams->createChannelMessageReplyHostedContent(teamId, channelId, messageId, replyId, {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getChannelMessageReplyHostedContent() returns error? {
    MicrosoftGraphChatMessageHostedContent response = check teams->getChannelMessageReplyHostedContent(teamId, channelId, messageId, replyId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deleteChannelMessageReplyHostedContent() returns error? {
    error? response = teams->deleteChannelMessageReplyHostedContent(teamId, channelId, messageId, replyId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updateChannelMessageReplyHostedContent() returns error? {
    // NOTE: "test-id" is not a real hostedContent id (would require chaining from a prior
    // createChannelMessageReplyHostedContent call); this call is expected to 404 against the live API.
    MicrosoftGraphChatMessageHostedContent response = check teams->updateChannelMessageReplyHostedContent(teamId, channelId, messageId, replyId, "test-id", {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getChannelMessageReplyHostedContentValue() returns error? {
    byte[] response = check teams->getChannelMessageReplyHostedContentValue(teamId, channelId, messageId, replyId, "test-id");
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updateChannelMessageReplyHostedContentValue() returns error? {
    error? response = teams->updateChannelMessageReplyHostedContentValue(teamId, channelId, messageId, replyId, "test-id", "mock-content".toBytes());
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deleteChannelMessageReplyHostedContentValue() returns error? {
    error? response = teams->deleteChannelMessageReplyHostedContentValue(teamId, channelId, messageId, replyId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countChannelMessageReplyHostedContents() returns error? {
    string response = check teams->countChannelMessageReplyHostedContents(teamId, channelId, messageId, replyId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_setReactionChannelMessageReply() returns error? {
    error? response = teams->setReactionChannelMessageReply(teamId, channelId, messageId, replyId, {reactionType: "like"});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_softDeleteChannelMessageReply() returns error? {
    error? response = teams->softDeleteChannelMessageReply(teamId, channelId, messageId, replyId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_undoSoftDeleteChannelMessageReply() returns error? {
    error? response = teams->undoSoftDeleteChannelMessageReply(teamId, channelId, messageId, replyId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_unsetReactionChannelMessageReply() returns error? {
    error? response = teams->unsetReactionChannelMessageReply(teamId, channelId, messageId, replyId, {});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countChannelMessageReplies() returns error? {
    string response = check teams->countChannelMessageReplies(teamId, channelId, messageId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getChannelMessageRepliesDelta() returns error? {
    ChatMessageDeltaCollectionResponse response = check teams->getChannelMessageRepliesDelta(teamId, channelId, messageId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_replyWithQuoteChannelMessageReplies() returns error? {
    MicrosoftGraphChatMessage quoteReply = {
        body: {
            contentType: "html",
            content: "<p>Replying with quote via the Ballerina connector test suite.</p>"
        }
    };
    ChatMessageResponse response = check teams->replyWithQuoteChannelMessageReplies(teamId, channelId, messageId, {
        replyMessage: quoteReply,
        messageIds: [replyId]
    });
    test:assertTrue(response is MicrosoftGraphChatMessage);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countChannelMessages() returns error? {
    string response = check teams->countChannelMessages(teamId, channelId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getChannelMessagesDelta() returns error? {
    ChatMessageDeltaCollectionResponse response = check teams->getChannelMessagesDelta(teamId, channelId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_replyWithQuoteChannelMessages() returns error? {
    MicrosoftGraphChatMessage quoteReply = {
        body: {
            contentType: "html",
            content: "<p>Replying with quote via the Ballerina connector test suite.</p>"
        }
    };
    ChatMessageResponse response = check teams->replyWithQuoteChannelMessages(teamId, channelId, {
        replyMessage: quoteReply,
        messageIds: [messageId]
    });
    test:assertTrue(response is MicrosoftGraphChatMessage);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_listChannelTabs() returns error? {
    MicrosoftGraphTeamsTabCollectionResponse response = check teams->listChannelTabs(teamId, channelId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_createChannelTab() returns error? {
    MicrosoftGraphTeamsTab response = check teams->createChannelTab(teamId, channelId, {
        displayName: "Wiki",
        "teamsApp@odata.bind": "https://graph.microsoft.com/v1.0/appCatalogs/teamsApps/com.microsoft.teamspace.tab.wiki",
        configuration: <MicrosoftGraphTeamsTabConfiguration>{}
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getChannelTab() returns error? {
    MicrosoftGraphTeamsTab response = check teams->getChannelTab(teamId, channelId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deleteChannelTab() returns error? {
    error? response = teams->deleteChannelTab(teamId, channelId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updateChannelTab() returns error? {
    // NOTE: "test-id" is not a real tab id (would require chaining from a prior createChannelTab
    // call); this call is expected to 404 against the live API.
    MicrosoftGraphTeamsTab response = check teams->updateChannelTab(teamId, channelId, "test-id", {
        displayName: "Wiki (Updated)"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getChannelTabTeamsApp() returns error? {
    MicrosoftGraphTeamsApp response = check teams->getChannelTabTeamsApp(teamId, channelId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countChannelTabs() returns error? {
    string response = check teams->countChannelTabs(teamId, channelId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_countChannels() returns error? {
    string response = check teams->countChannels(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getAllChannelMessages() returns error? {
    ChatMessageCollectionResponse response = check teams->getAllChannelMessages(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getAllRetainedChannelMessages() returns error? {
    ChatMessageCollectionResponse response = check teams->getAllRetainedChannelMessages(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listIncomingChannels() returns error? {
    MicrosoftGraphChannelCollectionResponse response = check teams->listIncomingChannels(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getIncomingChannel() returns error? {
    MicrosoftGraphChannel response = check teams->getIncomingChannel(teamId, channelId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countIncomingChannels() returns error? {
    string response = check teams->countIncomingChannels(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listMembers() returns error? {
    MicrosoftGraphConversationMemberCollectionResponse response = check teams->listMembers(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_createMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->createMember(teamId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: [],
        "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->getMember(teamId, memberId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deleteMember() returns error? {
    error? response = teams->deleteMember(teamId, memberId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updateMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->updateMember(teamId, memberId, {
        roles: ["owner"]
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countMembers() returns error? {
    string response = check teams->countMembers(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_addMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->addMembers(teamId, {
        values: [
            {
                atOdataType: "#microsoft.graph.aadUserConversationMember",
                roles: [],
                "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
            }
        ]
    });
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_removeMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->removeMembers(teamId, {});
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_sendActivityNotification() returns error? {
    // NOTE: requires a Teams app actually installed on this team whose manifest declares a
    // matching activity type; without one, Graph is expected to reject this even with valid shape.
    error? response = teams->sendActivityNotification(teamId, {
        topic: <MicrosoftGraphTeamworkActivityTopic>{
            atOdataType: "#microsoft.graph.teamworkActivityTopic",
            'source: "entityUrl",
            value: string `https://graph.microsoft.com/v1.0/teams/${teamId}`
        },
        activityType: "taskCreated",
        previewText: <MicrosoftGraphItemBody>{
            content: "You have a new notification from the Ballerina connector test suite"
        },
        recipient: <MicrosoftGraphTeamworkNotificationRecipient>{
            atOdataType: "#microsoft.graph.aadUserNotificationRecipient",
            "userId": myUserId
        }
    });
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannel() returns error? {
    MicrosoftGraphChannel response = check teams->getPrimaryChannel(teamId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deletePrimaryChannel() returns error? {
    error? response = teams->deletePrimaryChannel(teamId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updatePrimaryChannel() returns error? {
    MicrosoftGraphChannel response = check teams->updatePrimaryChannel(teamId, {
        description: "Updated by the Ballerina Microsoft Teams connector test suite"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listPrimaryChannelAllMembers() returns error? {
    MicrosoftGraphConversationMemberCollectionResponse response = check teams->listPrimaryChannelAllMembers(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_createPrimaryChannelAllMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->createPrimaryChannelAllMember(teamId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: [],
        "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelAllMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->getPrimaryChannelAllMember(teamId, memberId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deletePrimaryChannelAllMember() returns error? {
    error? response = teams->deletePrimaryChannelAllMember(teamId, memberId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updatePrimaryChannelAllMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->updatePrimaryChannelAllMember(teamId, memberId, {
        roles: ["owner"]
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countPrimaryChannelAllMembers() returns error? {
    string response = check teams->countPrimaryChannelAllMembers(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_addPrimaryChannelAllMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->addPrimaryChannelAllMembers(teamId, {
        values: [
            {
                atOdataType: "#microsoft.graph.aadUserConversationMember",
                roles: [],
                "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
            }
        ]
    });
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_removePrimaryChannelAllMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->removePrimaryChannelAllMembers(teamId, {});
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listPrimaryChannelEnabledApps() returns error? {
    MicrosoftGraphTeamsAppCollectionResponse response = check teams->listPrimaryChannelEnabledApps(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelEnabledApp() returns error? {
    MicrosoftGraphTeamsApp response = check teams->getPrimaryChannelEnabledApp(teamId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countPrimaryChannelEnabledApps() returns error? {
    string response = check teams->countPrimaryChannelEnabledApps(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelFilesFolder() returns error? {
    MicrosoftGraphDriveItem response = check teams->getPrimaryChannelFilesFolder(teamId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelFilesFolderContent() returns error? {
    byte[] response = check teams->getPrimaryChannelFilesFolderContent(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updatePrimaryChannelFilesFolderContent() returns error? {
    MicrosoftGraphDriveItem response = check teams->updatePrimaryChannelFilesFolderContent(teamId, "mock-content".toBytes());
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deletePrimaryChannelFilesFolderContent() returns error? {
    error? response = teams->deletePrimaryChannelFilesFolderContent(teamId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listPrimaryChannelMembers() returns error? {
    MicrosoftGraphConversationMemberCollectionResponse response = check teams->listPrimaryChannelMembers(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_createPrimaryChannelMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->createPrimaryChannelMember(teamId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: [],
        "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->getPrimaryChannelMember(teamId, memberId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deletePrimaryChannelMember() returns error? {
    error? response = teams->deletePrimaryChannelMember(teamId, memberId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updatePrimaryChannelMember() returns error? {
    MicrosoftGraphConversationMember response = check teams->updatePrimaryChannelMember(teamId, memberId, {
        roles: ["owner"]
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countPrimaryChannelMembers() returns error? {
    string response = check teams->countPrimaryChannelMembers(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_addPrimaryChannelMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->addPrimaryChannelMembers(teamId, {
        values: [
            {
                atOdataType: "#microsoft.graph.aadUserConversationMember",
                roles: [],
                "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
            }
        ]
    });
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_removePrimaryChannelMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->removePrimaryChannelMembers(teamId, {});
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listPrimaryChannelMessages() returns error? {
    MicrosoftGraphChatMessageCollectionResponse response = check teams->listPrimaryChannelMessages(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_createPrimaryChannelMessage() returns error? {
    MicrosoftGraphChatMessage response = check teams->createPrimaryChannelMessage(teamId, {
        body: {
            contentType: "html",
            content: "<p>Hello from the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelMessage() returns error? {
    MicrosoftGraphChatMessage response = check teams->getPrimaryChannelMessage(teamId, messageId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deletePrimaryChannelMessage() returns error? {
    error? response = teams->deletePrimaryChannelMessage(teamId, messageId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updatePrimaryChannelMessage() returns error? {
    MicrosoftGraphChatMessage response = check teams->updatePrimaryChannelMessage(teamId, messageId, {
        body: {
            contentType: "html",
            content: "<p>Updated by the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listPrimaryChannelMessageHostedContents() returns error? {
    MicrosoftGraphChatMessageHostedContentCollectionResponse response = check teams->listPrimaryChannelMessageHostedContents(teamId, messageId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_createPrimaryChannelMessageHostedContent() returns error? {
    MicrosoftGraphChatMessageHostedContent response = check teams->createPrimaryChannelMessageHostedContent(teamId, messageId, {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelMessageHostedContent() returns error? {
    MicrosoftGraphChatMessageHostedContent response = check teams->getPrimaryChannelMessageHostedContent(teamId, messageId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deletePrimaryChannelMessageHostedContent() returns error? {
    error? response = teams->deletePrimaryChannelMessageHostedContent(teamId, messageId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updatePrimaryChannelMessageHostedContent() returns error? {
    // NOTE: "test-id" is not a real hostedContent id (would require chaining from a prior
    // createPrimaryChannelMessageHostedContent call); this call is expected to 404 against the live API.
    MicrosoftGraphChatMessageHostedContent response = check teams->updatePrimaryChannelMessageHostedContent(teamId, messageId, "test-id", {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelMessageHostedContentValue() returns error? {
    byte[] response = check teams->getPrimaryChannelMessageHostedContentValue(teamId, messageId, "test-id");
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updatePrimaryChannelMessageHostedContentValue() returns error? {
    error? response = teams->updatePrimaryChannelMessageHostedContentValue(teamId, messageId, "test-id", "mock-content".toBytes());
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deletePrimaryChannelMessageHostedContentValue() returns error? {
    error? response = teams->deletePrimaryChannelMessageHostedContentValue(teamId, messageId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countPrimaryChannelMessageHostedContents() returns error? {
    string response = check teams->countPrimaryChannelMessageHostedContents(teamId, messageId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_setReactionPrimaryChannelMessage() returns error? {
    error? response = teams->setReactionPrimaryChannelMessage(teamId, messageId, {reactionType: "like"});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_softDeletePrimaryChannelMessage() returns error? {
    error? response = teams->softDeletePrimaryChannelMessage(teamId, messageId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_undoSoftDeletePrimaryChannelMessage() returns error? {
    error? response = teams->undoSoftDeletePrimaryChannelMessage(teamId, messageId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_unsetReactionPrimaryChannelMessage() returns error? {
    error? response = teams->unsetReactionPrimaryChannelMessage(teamId, messageId, {});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listPrimaryChannelMessageReplies() returns error? {
    MicrosoftGraphChatMessageCollectionResponse response = check teams->listPrimaryChannelMessageReplies(teamId, messageId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_createPrimaryChannelMessageReply() returns error? {
    MicrosoftGraphChatMessage response = check teams->createPrimaryChannelMessageReply(teamId, messageId, {
        body: {
            contentType: "html",
            content: "<p>Reply from the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelMessageReply() returns error? {
    MicrosoftGraphChatMessage response = check teams->getPrimaryChannelMessageReply(teamId, messageId, replyId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deletePrimaryChannelMessageReply() returns error? {
    error? response = teams->deletePrimaryChannelMessageReply(teamId, messageId, replyId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updatePrimaryChannelMessageReply() returns error? {
    MicrosoftGraphChatMessage response = check teams->updatePrimaryChannelMessageReply(teamId, messageId, replyId, {
        body: {
            contentType: "html",
            content: "<p>Updated reply from the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listPrimaryChannelMessageReplyHostedContents() returns error? {
    MicrosoftGraphChatMessageHostedContentCollectionResponse response = check teams->listPrimaryChannelMessageReplyHostedContents(teamId, messageId, replyId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_createPrimaryChannelMessageReplyHostedContent() returns error? {
    MicrosoftGraphChatMessageHostedContent response = check teams->createPrimaryChannelMessageReplyHostedContent(teamId, messageId, replyId, {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelMessageReplyHostedContent() returns error? {
    MicrosoftGraphChatMessageHostedContent response = check teams->getPrimaryChannelMessageReplyHostedContent(teamId, messageId, replyId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deletePrimaryChannelMessageReplyHostedContent() returns error? {
    error? response = teams->deletePrimaryChannelMessageReplyHostedContent(teamId, messageId, replyId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updatePrimaryChannelMessageReplyHostedContent() returns error? {
    // NOTE: "test-id" is not a real hostedContent id (would require chaining from a prior
    // createPrimaryChannelMessageReplyHostedContent call); expected to 404 against the live API.
    MicrosoftGraphChatMessageHostedContent response = check teams->updatePrimaryChannelMessageReplyHostedContent(teamId, messageId, replyId, "test-id", {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelMessageReplyHostedContentValue() returns error? {
    byte[] response = check teams->getPrimaryChannelMessageReplyHostedContentValue(teamId, messageId, replyId, "test-id");
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updatePrimaryChannelMessageReplyHostedContentValue() returns error? {
    error? response = teams->updatePrimaryChannelMessageReplyHostedContentValue(teamId, messageId, replyId, "test-id", "mock-content".toBytes());
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deletePrimaryChannelMessageReplyHostedContentValue() returns error? {
    error? response = teams->deletePrimaryChannelMessageReplyHostedContentValue(teamId, messageId, replyId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countPrimaryChannelMessageReplyHostedContents() returns error? {
    string response = check teams->countPrimaryChannelMessageReplyHostedContents(teamId, messageId, replyId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_setReactionPrimaryChannelMessageReply() returns error? {
    error? response = teams->setReactionPrimaryChannelMessageReply(teamId, messageId, replyId, {reactionType: "like"});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_softDeletePrimaryChannelMessageReply() returns error? {
    error? response = teams->softDeletePrimaryChannelMessageReply(teamId, messageId, replyId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_undoSoftDeletePrimaryChannelMessageReply() returns error? {
    error? response = teams->undoSoftDeletePrimaryChannelMessageReply(teamId, messageId, replyId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_unsetReactionPrimaryChannelMessageReply() returns error? {
    error? response = teams->unsetReactionPrimaryChannelMessageReply(teamId, messageId, replyId, {});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countPrimaryChannelMessageReplies() returns error? {
    string response = check teams->countPrimaryChannelMessageReplies(teamId, messageId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelMessageRepliesDelta() returns error? {
    ChatMessageDeltaCollectionResponse response = check teams->getPrimaryChannelMessageRepliesDelta(teamId, messageId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_replyWithQuotePrimaryChannelMessageReplies() returns error? {
    MicrosoftGraphChatMessage quoteReply = {
        body: {
            contentType: "html",
            content: "<p>Replying with quote via the Ballerina connector test suite.</p>"
        }
    };
    ChatMessageResponse response = check teams->replyWithQuotePrimaryChannelMessageReplies(teamId, messageId, {
        replyMessage: quoteReply,
        messageIds: [replyId]
    });
    test:assertTrue(response is MicrosoftGraphChatMessage);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countPrimaryChannelMessages() returns error? {
    string response = check teams->countPrimaryChannelMessages(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelMessagesDelta() returns error? {
    ChatMessageDeltaCollectionResponse response = check teams->getPrimaryChannelMessagesDelta(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_replyWithQuotePrimaryChannelMessages() returns error? {
    MicrosoftGraphChatMessage quoteReply = {
        body: {
            contentType: "html",
            content: "<p>Replying with quote via the Ballerina connector test suite.</p>"
        }
    };
    ChatMessageResponse response = check teams->replyWithQuotePrimaryChannelMessages(teamId, {
        replyMessage: quoteReply,
        messageIds: [messageId]
    });
    test:assertTrue(response is MicrosoftGraphChatMessage);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listPrimaryChannelTabs() returns error? {
    MicrosoftGraphTeamsTabCollectionResponse response = check teams->listPrimaryChannelTabs(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_createPrimaryChannelTab() returns error? {
    MicrosoftGraphTeamsTab response = check teams->createPrimaryChannelTab(teamId, {
        displayName: "Wiki",
        "teamsApp@odata.bind": "https://graph.microsoft.com/v1.0/appCatalogs/teamsApps/com.microsoft.teamspace.tab.wiki",
        configuration: <MicrosoftGraphTeamsTabConfiguration>{}
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelTab() returns error? {
    MicrosoftGraphTeamsTab response = check teams->getPrimaryChannelTab(teamId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deletePrimaryChannelTab() returns error? {
    error? response = teams->deletePrimaryChannelTab(teamId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updatePrimaryChannelTab() returns error? {
    // NOTE: "test-id" is not a real tab id (would require chaining from a prior
    // createPrimaryChannelTab call); this call is expected to 404 against the live API.
    MicrosoftGraphTeamsTab response = check teams->updatePrimaryChannelTab(teamId, "test-id", {
        displayName: "Wiki (Updated)"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getPrimaryChannelTabTeamsApp() returns error? {
    MicrosoftGraphTeamsApp response = check teams->getPrimaryChannelTabTeamsApp(teamId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countPrimaryChannelTabs() returns error? {
    string response = check teams->countPrimaryChannelTabs(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_listTags() returns error? {
    MicrosoftGraphTeamworkTagCollectionResponse response = check teams->listTags(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function test_createTag() returns error? {
    MicrosoftGraphTeamworkTag response = check teams->createTag(teamId, {
        displayName: "Connector Test Tag",
        "members": [
            {userId: myUserId}
        ]
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getTag() returns error? {
    MicrosoftGraphTeamworkTag response = check teams->getTag(teamId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deleteTag() returns error? {
    error? response = teams->deleteTag(teamId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updateTag() returns error? {
    // NOTE: "test-id" is not a real tag id (would require chaining from a prior createTag call);
    // this call is expected to 404 against the live API.
    MicrosoftGraphTeamworkTag response = check teams->updateTag(teamId, "test-id", {
        displayName: "Connector Test Tag (Updated)"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_listTagMembers() returns error? {
    MicrosoftGraphTeamworkTagMemberCollectionResponse response = check teams->listTagMembers(teamId, "test-id");
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_createTagMember() returns error? {
    // NOTE: "test-id" is not a real tag id (would require chaining from a prior createTag call);
    // this call is expected to 404 against the live API.
    MicrosoftGraphTeamworkTagMember response = check teams->createTagMember(teamId, "test-id", {
        userId: myUserId
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_getTagMember() returns error? {
    MicrosoftGraphTeamworkTagMember response = check teams->getTagMember(teamId, "test-id", "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_deleteTagMember() returns error? {
    error? response = teams->deleteTagMember(teamId, "test-id", "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function test_updateTagMember() returns error? {
    // NOTE: "test-id" is not a real tag/member id (would require chaining from prior create
    // calls); this call is expected to 404 against the live API.
    MicrosoftGraphTeamworkTagMember response = check teams->updateTagMember(teamId, "test-id", "test-id", {
        displayName: "Connector Test Tag Member (Updated)"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countTagMembers() returns error? {
    string response = check teams->countTagMembers(teamId, "test-id");
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function test_countTags() returns error? {
    string response = check teams->countTags(teamId);
    test:assertTrue(response.length() > 0);
}
