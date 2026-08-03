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


import ballerina/http;
import ballerina/os;
import ballerina/test;

// The following values are resolved from `tests/Config.toml` when present, otherwise from the
// corresponding environment variables. This lets local runs use a Config.toml while CI/live runs
// only need env vars/secrets set (no committed file).

// Set to `true` in tests/Config.toml (or via `-CisLiveServer=true`) to run against the real
// Microsoft Graph API. Defaults to `false` when unset, so `bal test` runs against the local mock.
configurable boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";

// Which OAuth2 grant to use when isLiveServer = true (env `AUTH_MODE`):
// - "client_credentials": app-only auth with clientId + clientSecret + tenantId (no user or refresh token needed)
// - "refresh_token": delegated auth with clientId + clientSecret + refreshToken
configurable string authMode = os:getEnv("AUTH_MODE") == "" ? "client_credentials" : os:getEnv("AUTH_MODE");

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string tenantId = os:getEnv("TENANT_ID") == "" ? "common" : os:getEnv("TENANT_ID");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");

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

@test:Config {groups: ["mock_tests"]}
isolated function testCreateTeam() returns error? {
    http:Response response = check teams->createTeam({
        displayName: "Ballerina Connector Test Team",
        description: "Team created by the Ballerina Microsoft Teams connector test suite",
        "template@odata.bind": "https://graph.microsoft.com/v1.0/teamsTemplates('standard')"
    });
    test:assertTrue(response.statusCode >= 200 && response.statusCode < 300);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetTeam() returns error? {
    Team response = check teams->getTeam(teamId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteTeam() returns error? {
    error? response = teams->deleteTeam(teamId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testUpdateTeam() returns error? {
    http:Response response = check teams->updateTeam(teamId, {
        description: "Updated by the Ballerina Microsoft Teams connector test suite"
    });
    test:assertTrue(response.statusCode >= 200 && response.statusCode < 300);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListAllChannels() returns error? {
    ChannelCollectionResponse response = check teams->listAllChannels(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetAllChannel() returns error? {
    Channel response = check teams->getAllChannel(teamId, channelId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountAllChannels() returns error? {
    string response = check teams->countAllChannels(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListChannels() returns error? {
    ChannelCollectionResponse response = check teams->listChannels(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateChannel() returns error? {
    http:Response response = check teams->createChannel(teamId, {
        displayName: "Connector Test Channel",
        description: "Channel created by the Ballerina Microsoft Teams connector test suite"
    });
    test:assertTrue(response.statusCode >= 200 && response.statusCode < 300);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetChannel() returns error? {
    Channel response = check teams->getChannel(teamId, channelId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteChannel() returns error? {
    error? response = teams->deleteChannel(teamId, channelId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testUpdateChannel() returns error? {
    http:Response response = check teams->updateChannel(teamId, channelId, {
        description: "Updated by the Ballerina Microsoft Teams connector test suite"
    });
    test:assertTrue(response.statusCode >= 200 && response.statusCode < 300);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListChannelAllMembers() returns error? {
    ConversationMemberCollectionResponse response = check teams->listChannelAllMembers(teamId, channelId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreateChannelAllMember() returns error? {
    ConversationMember response = check teams->createChannelAllMember(teamId, channelId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: [],
        "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetChannelAllMember() returns error? {
    ConversationMember response = check teams->getChannelAllMember(teamId, channelId, memberId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteChannelAllMember() returns error? {
    error? response = teams->deleteChannelAllMember(teamId, channelId, memberId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateChannelAllMember() returns error? {
    ConversationMember response = check teams->updateChannelAllMember(teamId, channelId, memberId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: ["owner"]
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountChannelAllMembers() returns error? {
    string response = check teams->countChannelAllMembers(teamId, channelId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testAddChannelAllMembers() returns error? {
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
isolated function testRemoveChannelAllMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->removeChannelAllMembers(teamId, channelId, {});
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListChannelEnabledApps() returns error? {
    TeamsAppCollectionResponse response = check teams->listChannelEnabledApps(teamId, channelId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetChannelEnabledApp() returns error? {
    TeamsApp response = check teams->getChannelEnabledApp(teamId, channelId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountChannelEnabledApps() returns error? {
    string response = check teams->countChannelEnabledApps(teamId, channelId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetChannelFilesFolder() returns error? {
    DriveItem response = check teams->getChannelFilesFolder(teamId, channelId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetChannelFilesFolderContent() returns error? {
    byte[] response = check teams->getChannelFilesFolderContent(teamId, channelId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateChannelFilesFolderContent() returns error? {
    DriveItem response = check teams->updateChannelFilesFolderContent(teamId, channelId, "mock-content".toBytes());
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteChannelFilesFolderContent() returns error? {
    error? response = teams->deleteChannelFilesFolderContent(teamId, channelId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListChannelMembers() returns error? {
    ConversationMemberCollectionResponse response = check teams->listChannelMembers(teamId, channelId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateChannelMember() returns error? {
    ConversationMember response = check teams->createChannelMember(teamId, channelId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: [],
        "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetChannelMember() returns error? {
    ConversationMember response = check teams->getChannelMember(teamId, channelId, memberId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testDeleteChannelMember() returns error? {
    error? response = teams->deleteChannelMember(teamId, channelId, memberId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateChannelMember() returns error? {
    ConversationMember response = check teams->updateChannelMember(teamId, channelId, memberId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: ["owner"]
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountChannelMembers() returns error? {
    string response = check teams->countChannelMembers(teamId, channelId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testAddChannelMembers() returns error? {
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
isolated function testRemoveChannelMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->removeChannelMembers(teamId, channelId, {});
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListChannelMessages() returns error? {
    ChatMessageCollectionResponse response = check teams->listChannelMessages(teamId, channelId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateChannelMessage() returns error? {
    ChatMessage response = check teams->createChannelMessage(teamId, channelId, {
        body: {
            contentType: "html",
            content: "<p>Hello from the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetChannelMessage() returns error? {
    ChatMessage response = check teams->getChannelMessage(teamId, channelId, messageId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testDeleteChannelMessage() returns error? {
    error? response = teams->deleteChannelMessage(teamId, channelId, messageId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testUpdateChannelMessage() returns error? {
    http:Response response = check teams->updateChannelMessage(teamId, channelId, messageId, {
        body: {
            contentType: "html",
            content: "<p>Updated by the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.statusCode >= 200 && response.statusCode < 300);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListChannelMessageHostedContents() returns error? {
    ChatMessageHostedContentCollectionResponse response = check teams->listChannelMessageHostedContents(teamId, channelId, messageId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreateChannelMessageHostedContent() returns error? {
    ChatMessageHostedContent response = check teams->createChannelMessageHostedContent(teamId, channelId, messageId, {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetChannelMessageHostedContent() returns error? {
    ChatMessageHostedContent response = check teams->getChannelMessageHostedContent(teamId, channelId, messageId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteChannelMessageHostedContent() returns error? {
    error? response = teams->deleteChannelMessageHostedContent(teamId, channelId, messageId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateChannelMessageHostedContent() returns error? {
    // NOTE: "test-id" is not a real hostedContent id (would require chaining from a prior
    // createChannelMessageHostedContent call); this call is expected to 404 against the live API.
    ChatMessageHostedContent response = check teams->updateChannelMessageHostedContent(teamId, channelId, messageId, "test-id", {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetChannelMessageHostedContentValue() returns error? {
    byte[] response = check teams->getChannelMessageHostedContentValue(teamId, channelId, messageId, "test-id");
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateChannelMessageHostedContentValue() returns error? {
    error? response = teams->updateChannelMessageHostedContentValue(teamId, channelId, messageId, "test-id", "mock-content".toBytes());
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteChannelMessageHostedContentValue() returns error? {
    error? response = teams->deleteChannelMessageHostedContentValue(teamId, channelId, messageId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountChannelMessageHostedContents() returns error? {
    string response = check teams->countChannelMessageHostedContents(teamId, channelId, messageId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testSetReactionChannelMessage() returns error? {
    error? response = teams->setReactionChannelMessage(teamId, channelId, messageId, {reactionType: "like"});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testSoftDeleteChannelMessage() returns error? {
    error? response = teams->softDeleteChannelMessage(teamId, channelId, messageId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUndoSoftDeleteChannelMessage() returns error? {
    error? response = teams->undoSoftDeleteChannelMessage(teamId, channelId, messageId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUnsetReactionChannelMessage() returns error? {
    error? response = teams->unsetReactionChannelMessage(teamId, channelId, messageId, {});
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListChannelMessageReplies() returns error? {
    ChatMessageCollectionResponse response = check teams->listChannelMessageReplies(teamId, channelId, messageId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateChannelMessageReply() returns error? {
    ChatMessage response = check teams->createChannelMessageReply(teamId, channelId, messageId, {
        body: {
            contentType: "html",
            content: "<p>Reply from the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetChannelMessageReply() returns error? {
    ChatMessage response = check teams->getChannelMessageReply(teamId, channelId, messageId, replyId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteChannelMessageReply() returns error? {
    error? response = teams->deleteChannelMessageReply(teamId, channelId, messageId, replyId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateChannelMessageReply() returns error? {
    http:Response response = check teams->updateChannelMessageReply(teamId, channelId, messageId, replyId, {
        body: {
            contentType: "html",
            content: "<p>Updated reply from the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.statusCode >= 200 && response.statusCode < 300);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListChannelMessageReplyHostedContents() returns error? {
    ChatMessageHostedContentCollectionResponse response = check teams->listChannelMessageReplyHostedContents(teamId, channelId, messageId, replyId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreateChannelMessageReplyHostedContent() returns error? {
    ChatMessageHostedContent response = check teams->createChannelMessageReplyHostedContent(teamId, channelId, messageId, replyId, {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetChannelMessageReplyHostedContent() returns error? {
    ChatMessageHostedContent response = check teams->getChannelMessageReplyHostedContent(teamId, channelId, messageId, replyId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteChannelMessageReplyHostedContent() returns error? {
    error? response = teams->deleteChannelMessageReplyHostedContent(teamId, channelId, messageId, replyId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateChannelMessageReplyHostedContent() returns error? {
    // NOTE: "test-id" is not a real hostedContent id (would require chaining from a prior
    // createChannelMessageReplyHostedContent call); this call is expected to 404 against the live API.
    ChatMessageHostedContent response = check teams->updateChannelMessageReplyHostedContent(teamId, channelId, messageId, replyId, "test-id", {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetChannelMessageReplyHostedContentValue() returns error? {
    byte[] response = check teams->getChannelMessageReplyHostedContentValue(teamId, channelId, messageId, replyId, "test-id");
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateChannelMessageReplyHostedContentValue() returns error? {
    error? response = teams->updateChannelMessageReplyHostedContentValue(teamId, channelId, messageId, replyId, "test-id", "mock-content".toBytes());
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteChannelMessageReplyHostedContentValue() returns error? {
    error? response = teams->deleteChannelMessageReplyHostedContentValue(teamId, channelId, messageId, replyId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountChannelMessageReplyHostedContents() returns error? {
    string response = check teams->countChannelMessageReplyHostedContents(teamId, channelId, messageId, replyId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testSetReactionChannelMessageReply() returns error? {
    error? response = teams->setReactionChannelMessageReply(teamId, channelId, messageId, replyId, {reactionType: "like"});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testSoftDeleteChannelMessageReply() returns error? {
    error? response = teams->softDeleteChannelMessageReply(teamId, channelId, messageId, replyId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUndoSoftDeleteChannelMessageReply() returns error? {
    error? response = teams->undoSoftDeleteChannelMessageReply(teamId, channelId, messageId, replyId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUnsetReactionChannelMessageReply() returns error? {
    error? response = teams->unsetReactionChannelMessageReply(teamId, channelId, messageId, replyId, {});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountChannelMessageReplies() returns error? {
    string response = check teams->countChannelMessageReplies(teamId, channelId, messageId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetChannelMessageRepliesDelta() returns error? {
    ChatMessageDeltaCollectionResponse response = check teams->getChannelMessageRepliesDelta(teamId, channelId, messageId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testReplyWithQuoteChannelMessageReplies() returns error? {
    ChatMessage quoteReply = {
        body: {
            contentType: "html",
            content: "<p>Replying with quote via the Ballerina connector test suite.</p>"
        }
    };
    ChatMessageResponse response = check teams->replyWithQuoteChannelMessageReplies(teamId, channelId, messageId, {
        replyMessage: quoteReply,
        messageIds: [replyId]
    });
    test:assertTrue(response is ChatMessage);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountChannelMessages() returns error? {
    string response = check teams->countChannelMessages(teamId, channelId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetChannelMessagesDelta() returns error? {
    ChatMessageDeltaCollectionResponse response = check teams->getChannelMessagesDelta(teamId, channelId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testReplyWithQuoteChannelMessages() returns error? {
    ChatMessage quoteReply = {
        body: {
            contentType: "html",
            content: "<p>Replying with quote via the Ballerina connector test suite.</p>"
        }
    };
    ChatMessageResponse response = check teams->replyWithQuoteChannelMessages(teamId, channelId, {
        replyMessage: quoteReply,
        messageIds: [messageId]
    });
    test:assertTrue(response is ChatMessage);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListChannelTabs() returns error? {
    TeamsTabCollectionResponse response = check teams->listChannelTabs(teamId, channelId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateChannelTab() returns error? {
    TeamsTab response = check teams->createChannelTab(teamId, channelId, {
        displayName: "Wiki",
        "teamsApp@odata.bind": "https://graph.microsoft.com/v1.0/appCatalogs/teamsApps/com.microsoft.teamspace.tab.wiki",
        configuration: <TeamsTabConfiguration>{}
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetChannelTab() returns error? {
    TeamsTab response = check teams->getChannelTab(teamId, channelId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteChannelTab() returns error? {
    error? response = teams->deleteChannelTab(teamId, channelId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateChannelTab() returns error? {
    // NOTE: "test-id" is not a real tab id (would require chaining from a prior createChannelTab
    // call); this call is expected to 404 against the live API.
    TeamsTab response = check teams->updateChannelTab(teamId, channelId, "test-id", {
        displayName: "Wiki (Updated)"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetChannelTabTeamsApp() returns error? {
    TeamsApp response = check teams->getChannelTabTeamsApp(teamId, channelId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountChannelTabs() returns error? {
    string response = check teams->countChannelTabs(teamId, channelId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCountChannels() returns error? {
    string response = check teams->countChannels(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetAllChannelMessages() returns error? {
    ChatMessageCollectionResponse response = check teams->getAllChannelMessages(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetAllRetainedChannelMessages() returns error? {
    ChatMessageCollectionResponse response = check teams->getAllRetainedChannelMessages(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListIncomingChannels() returns error? {
    ChannelCollectionResponse response = check teams->listIncomingChannels(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetIncomingChannel() returns error? {
    Channel response = check teams->getIncomingChannel(teamId, channelId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountIncomingChannels() returns error? {
    string response = check teams->countIncomingChannels(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListMembers() returns error? {
    ConversationMemberCollectionResponse response = check teams->listMembers(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreateMember() returns error? {
    ConversationMember response = check teams->createMember(teamId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: [],
        "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetMember() returns error? {
    ConversationMember response = check teams->getMember(teamId, memberId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteMember() returns error? {
    error? response = teams->deleteMember(teamId, memberId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateMember() returns error? {
    ConversationMember response = check teams->updateMember(teamId, memberId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: ["owner"]
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountMembers() returns error? {
    string response = check teams->countMembers(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testAddMembers() returns error? {
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
isolated function testRemoveMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->removeMembers(teamId, {});
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testSendActivityNotification() returns error? {
    // NOTE: requires a Teams app actually installed on this team whose manifest declares a
    // matching activity type; without one, Graph is expected to reject this even with valid shape.
    error? response = teams->sendActivityNotification(teamId, {
        topic: <TeamworkActivityTopic>{
            atOdataType: "#microsoft.graph.teamworkActivityTopic",
            'source: "entityUrl",
            value: string `https://graph.microsoft.com/v1.0/teams/${teamId}`
        },
        activityType: "taskCreated",
        previewText: <ItemBody>{
            content: "You have a new notification from the Ballerina connector test suite"
        },
        recipient: <TeamworkNotificationRecipient>{
            atOdataType: "#microsoft.graph.aadUserNotificationRecipient",
            "userId": myUserId
        }
    });
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannel() returns error? {
    Channel response = check teams->getPrimaryChannel(teamId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeletePrimaryChannel() returns error? {
    error? response = teams->deletePrimaryChannel(teamId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdatePrimaryChannel() returns error? {
    http:Response response = check teams->updatePrimaryChannel(teamId, {
        description: "Updated by the Ballerina Microsoft Teams connector test suite"
    });
    test:assertTrue(response.statusCode >= 200 && response.statusCode < 300);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListPrimaryChannelAllMembers() returns error? {
    ConversationMemberCollectionResponse response = check teams->listPrimaryChannelAllMembers(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreatePrimaryChannelAllMember() returns error? {
    ConversationMember response = check teams->createPrimaryChannelAllMember(teamId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: [],
        "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelAllMember() returns error? {
    ConversationMember response = check teams->getPrimaryChannelAllMember(teamId, memberId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeletePrimaryChannelAllMember() returns error? {
    error? response = teams->deletePrimaryChannelAllMember(teamId, memberId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdatePrimaryChannelAllMember() returns error? {
    ConversationMember response = check teams->updatePrimaryChannelAllMember(teamId, memberId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: ["owner"]
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountPrimaryChannelAllMembers() returns error? {
    string response = check teams->countPrimaryChannelAllMembers(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testAddPrimaryChannelAllMembers() returns error? {
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
isolated function testRemovePrimaryChannelAllMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->removePrimaryChannelAllMembers(teamId, {});
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListPrimaryChannelEnabledApps() returns error? {
    TeamsAppCollectionResponse response = check teams->listPrimaryChannelEnabledApps(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelEnabledApp() returns error? {
    TeamsApp response = check teams->getPrimaryChannelEnabledApp(teamId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountPrimaryChannelEnabledApps() returns error? {
    string response = check teams->countPrimaryChannelEnabledApps(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelFilesFolder() returns error? {
    DriveItem response = check teams->getPrimaryChannelFilesFolder(teamId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelFilesFolderContent() returns error? {
    byte[] response = check teams->getPrimaryChannelFilesFolderContent(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdatePrimaryChannelFilesFolderContent() returns error? {
    DriveItem response = check teams->updatePrimaryChannelFilesFolderContent(teamId, "mock-content".toBytes());
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeletePrimaryChannelFilesFolderContent() returns error? {
    error? response = teams->deletePrimaryChannelFilesFolderContent(teamId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testListPrimaryChannelMembers() returns error? {
    ConversationMemberCollectionResponse response = check teams->listPrimaryChannelMembers(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreatePrimaryChannelMember() returns error? {
    ConversationMember response = check teams->createPrimaryChannelMember(teamId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: [],
        "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${myUserId}')`
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelMember() returns error? {
    ConversationMember response = check teams->getPrimaryChannelMember(teamId, memberId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeletePrimaryChannelMember() returns error? {
    error? response = teams->deletePrimaryChannelMember(teamId, memberId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdatePrimaryChannelMember() returns error? {
    ConversationMember response = check teams->updatePrimaryChannelMember(teamId, memberId, {
        atOdataType: "#microsoft.graph.aadUserConversationMember",
        roles: ["owner"]
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountPrimaryChannelMembers() returns error? {
    string response = check teams->countPrimaryChannelMembers(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testAddPrimaryChannelMembers() returns error? {
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
isolated function testRemovePrimaryChannelMembers() returns error? {
    ActionResultPartCollectionResponse response = check teams->removePrimaryChannelMembers(teamId, {});
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListPrimaryChannelMessages() returns error? {
    ChatMessageCollectionResponse response = check teams->listPrimaryChannelMessages(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreatePrimaryChannelMessage() returns error? {
    ChatMessage response = check teams->createPrimaryChannelMessage(teamId, {
        body: {
            contentType: "html",
            content: "<p>Hello from the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelMessage() returns error? {
    ChatMessage response = check teams->getPrimaryChannelMessage(teamId, messageId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeletePrimaryChannelMessage() returns error? {
    error? response = teams->deletePrimaryChannelMessage(teamId, messageId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdatePrimaryChannelMessage() returns error? {
    http:Response response = check teams->updatePrimaryChannelMessage(teamId, messageId, {
        body: {
            contentType: "html",
            content: "<p>Updated by the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.statusCode >= 200 && response.statusCode < 300);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListPrimaryChannelMessageHostedContents() returns error? {
    ChatMessageHostedContentCollectionResponse response = check teams->listPrimaryChannelMessageHostedContents(teamId, messageId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreatePrimaryChannelMessageHostedContent() returns error? {
    ChatMessageHostedContent response = check teams->createPrimaryChannelMessageHostedContent(teamId, messageId, {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelMessageHostedContent() returns error? {
    ChatMessageHostedContent response = check teams->getPrimaryChannelMessageHostedContent(teamId, messageId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeletePrimaryChannelMessageHostedContent() returns error? {
    error? response = teams->deletePrimaryChannelMessageHostedContent(teamId, messageId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdatePrimaryChannelMessageHostedContent() returns error? {
    // NOTE: "test-id" is not a real hostedContent id (would require chaining from a prior
    // createPrimaryChannelMessageHostedContent call); this call is expected to 404 against the live API.
    ChatMessageHostedContent response = check teams->updatePrimaryChannelMessageHostedContent(teamId, messageId, "test-id", {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelMessageHostedContentValue() returns error? {
    byte[] response = check teams->getPrimaryChannelMessageHostedContentValue(teamId, messageId, "test-id");
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdatePrimaryChannelMessageHostedContentValue() returns error? {
    error? response = teams->updatePrimaryChannelMessageHostedContentValue(teamId, messageId, "test-id", "mock-content".toBytes());
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeletePrimaryChannelMessageHostedContentValue() returns error? {
    error? response = teams->deletePrimaryChannelMessageHostedContentValue(teamId, messageId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountPrimaryChannelMessageHostedContents() returns error? {
    string response = check teams->countPrimaryChannelMessageHostedContents(teamId, messageId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testSetReactionPrimaryChannelMessage() returns error? {
    error? response = teams->setReactionPrimaryChannelMessage(teamId, messageId, {reactionType: "like"});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testSoftDeletePrimaryChannelMessage() returns error? {
    error? response = teams->softDeletePrimaryChannelMessage(teamId, messageId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUndoSoftDeletePrimaryChannelMessage() returns error? {
    error? response = teams->undoSoftDeletePrimaryChannelMessage(teamId, messageId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUnsetReactionPrimaryChannelMessage() returns error? {
    error? response = teams->unsetReactionPrimaryChannelMessage(teamId, messageId, {});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testListPrimaryChannelMessageReplies() returns error? {
    ChatMessageCollectionResponse response = check teams->listPrimaryChannelMessageReplies(teamId, messageId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreatePrimaryChannelMessageReply() returns error? {
    ChatMessage response = check teams->createPrimaryChannelMessageReply(teamId, messageId, {
        body: {
            contentType: "html",
            content: "<p>Reply from the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelMessageReply() returns error? {
    ChatMessage response = check teams->getPrimaryChannelMessageReply(teamId, messageId, replyId);
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeletePrimaryChannelMessageReply() returns error? {
    error? response = teams->deletePrimaryChannelMessageReply(teamId, messageId, replyId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdatePrimaryChannelMessageReply() returns error? {
    http:Response response = check teams->updatePrimaryChannelMessageReply(teamId, messageId, replyId, {
        body: {
            contentType: "html",
            content: "<p>Updated reply from the Ballerina Microsoft Teams connector test suite.</p>"
        }
    });
    test:assertTrue(response.statusCode >= 200 && response.statusCode < 300);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListPrimaryChannelMessageReplyHostedContents() returns error? {
    ChatMessageHostedContentCollectionResponse response = check teams->listPrimaryChannelMessageReplyHostedContents(teamId, messageId, replyId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreatePrimaryChannelMessageReplyHostedContent() returns error? {
    ChatMessageHostedContent response = check teams->createPrimaryChannelMessageReplyHostedContent(teamId, messageId, replyId, {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelMessageReplyHostedContent() returns error? {
    ChatMessageHostedContent response = check teams->getPrimaryChannelMessageReplyHostedContent(teamId, messageId, replyId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeletePrimaryChannelMessageReplyHostedContent() returns error? {
    error? response = teams->deletePrimaryChannelMessageReplyHostedContent(teamId, messageId, replyId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdatePrimaryChannelMessageReplyHostedContent() returns error? {
    // NOTE: "test-id" is not a real hostedContent id (would require chaining from a prior
    // createPrimaryChannelMessageReplyHostedContent call); expected to 404 against the live API.
    ChatMessageHostedContent response = check teams->updatePrimaryChannelMessageReplyHostedContent(teamId, messageId, replyId, "test-id", {
        contentBytes: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=",
        contentType: "image/png"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelMessageReplyHostedContentValue() returns error? {
    byte[] response = check teams->getPrimaryChannelMessageReplyHostedContentValue(teamId, messageId, replyId, "test-id");
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdatePrimaryChannelMessageReplyHostedContentValue() returns error? {
    error? response = teams->updatePrimaryChannelMessageReplyHostedContentValue(teamId, messageId, replyId, "test-id", "mock-content".toBytes());
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeletePrimaryChannelMessageReplyHostedContentValue() returns error? {
    error? response = teams->deletePrimaryChannelMessageReplyHostedContentValue(teamId, messageId, replyId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountPrimaryChannelMessageReplyHostedContents() returns error? {
    string response = check teams->countPrimaryChannelMessageReplyHostedContents(teamId, messageId, replyId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testSetReactionPrimaryChannelMessageReply() returns error? {
    error? response = teams->setReactionPrimaryChannelMessageReply(teamId, messageId, replyId, {reactionType: "like"});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testSoftDeletePrimaryChannelMessageReply() returns error? {
    error? response = teams->softDeletePrimaryChannelMessageReply(teamId, messageId, replyId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUndoSoftDeletePrimaryChannelMessageReply() returns error? {
    error? response = teams->undoSoftDeletePrimaryChannelMessageReply(teamId, messageId, replyId);
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUnsetReactionPrimaryChannelMessageReply() returns error? {
    error? response = teams->unsetReactionPrimaryChannelMessageReply(teamId, messageId, replyId, {});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountPrimaryChannelMessageReplies() returns error? {
    string response = check teams->countPrimaryChannelMessageReplies(teamId, messageId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelMessageRepliesDelta() returns error? {
    ChatMessageDeltaCollectionResponse response = check teams->getPrimaryChannelMessageRepliesDelta(teamId, messageId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testReplyWithQuotePrimaryChannelMessageReplies() returns error? {
    ChatMessage quoteReply = {
        body: {
            contentType: "html",
            content: "<p>Replying with quote via the Ballerina connector test suite.</p>"
        }
    };
    ChatMessageResponse response = check teams->replyWithQuotePrimaryChannelMessageReplies(teamId, messageId, {
        replyMessage: quoteReply,
        messageIds: [replyId]
    });
    test:assertTrue(response is ChatMessage);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountPrimaryChannelMessages() returns error? {
    string response = check teams->countPrimaryChannelMessages(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelMessagesDelta() returns error? {
    ChatMessageDeltaCollectionResponse response = check teams->getPrimaryChannelMessagesDelta(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testReplyWithQuotePrimaryChannelMessages() returns error? {
    ChatMessage quoteReply = {
        body: {
            contentType: "html",
            content: "<p>Replying with quote via the Ballerina connector test suite.</p>"
        }
    };
    ChatMessageResponse response = check teams->replyWithQuotePrimaryChannelMessages(teamId, {
        replyMessage: quoteReply,
        messageIds: [messageId]
    });
    test:assertTrue(response is ChatMessage);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListPrimaryChannelTabs() returns error? {
    TeamsTabCollectionResponse response = check teams->listPrimaryChannelTabs(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreatePrimaryChannelTab() returns error? {
    TeamsTab response = check teams->createPrimaryChannelTab(teamId, {
        displayName: "Wiki",
        "teamsApp@odata.bind": "https://graph.microsoft.com/v1.0/appCatalogs/teamsApps/com.microsoft.teamspace.tab.wiki",
        configuration: <TeamsTabConfiguration>{}
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelTab() returns error? {
    TeamsTab response = check teams->getPrimaryChannelTab(teamId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeletePrimaryChannelTab() returns error? {
    error? response = teams->deletePrimaryChannelTab(teamId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdatePrimaryChannelTab() returns error? {
    // NOTE: "test-id" is not a real tab id (would require chaining from a prior
    // createPrimaryChannelTab call); this call is expected to 404 against the live API.
    TeamsTab response = check teams->updatePrimaryChannelTab(teamId, "test-id", {
        displayName: "Wiki (Updated)"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetPrimaryChannelTabTeamsApp() returns error? {
    TeamsApp response = check teams->getPrimaryChannelTabTeamsApp(teamId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountPrimaryChannelTabs() returns error? {
    string response = check teams->countPrimaryChannelTabs(teamId);
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListTags() returns error? {
    TeamworkTagCollectionResponse response = check teams->listTags(teamId);
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCreateTag() returns error? {
    TeamworkTag response = check teams->createTag(teamId, {
        displayName: "Connector Test Tag",
        "members": [
            {userId: myUserId}
        ]
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetTag() returns error? {
    TeamworkTag response = check teams->getTag(teamId, "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteTag() returns error? {
    error? response = teams->deleteTag(teamId, "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateTag() returns error? {
    // NOTE: "test-id" is not a real tag id (would require chaining from a prior createTag call);
    // this call is expected to 404 against the live API.
    TeamworkTag response = check teams->updateTag(teamId, "test-id", {
        displayName: "Connector Test Tag (Updated)"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListTagMembers() returns error? {
    TeamworkTagMemberCollectionResponse response = check teams->listTagMembers(teamId, "test-id");
    test:assertTrue(response.value is anydata[]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreateTagMember() returns error? {
    // NOTE: "test-id" is not a real tag id (would require chaining from a prior createTag call);
    // this call is expected to 404 against the live API.
    TeamworkTagMember response = check teams->createTagMember(teamId, "test-id", {
        userId: myUserId
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetTagMember() returns error? {
    TeamworkTagMember response = check teams->getTagMember(teamId, "test-id", "test-id");
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteTagMember() returns error? {
    error? response = teams->deleteTagMember(teamId, "test-id", "test-id");
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateTagMember() returns error? {
    // NOTE: "test-id" is not a real tag/member id (would require chaining from prior create
    // calls); this call is expected to 404 against the live API.
    TeamworkTagMember response = check teams->updateTagMember(teamId, "test-id", "test-id", {
        displayName: "Connector Test Tag Member (Updated)"
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountTagMembers() returns error? {
    string response = check teams->countTagMembers(teamId, "test-id");
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCountTags() returns error? {
    string response = check teams->countTags(teamId);
    test:assertTrue(response.length() > 0);
}
