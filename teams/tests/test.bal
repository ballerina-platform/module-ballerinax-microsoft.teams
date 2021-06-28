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

import ballerina/io;
import ballerina/jballerina.java;
import ballerina/lang.runtime;
import ballerina/log;
import ballerina/os;
import ballerina/regex;
import ballerina/test;

configurable string & readonly refreshUrl = os:getEnv("REFRESH_URL");
configurable string & readonly refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string & readonly clientId = os:getEnv("CLIENT_ID");
configurable string & readonly clientSecret = os:getEnv("CLIENT_SECRET");
configurable string & readonly chatOwner = os:getEnv("USER_ID_1");
configurable string & readonly chatUser2 = os:getEnv("USER_ID_2");
configurable string & readonly chatUser3 = os:getEnv("USER_ID_3");

Configuration configuration = {
    clientConfig: {
        refreshUrl: refreshUrl,
        refreshToken : refreshToken,
        clientId : clientId,
        clientSecret : clientSecret,
        scopes: ["openid", "offline_access","https://graph.microsoft.com/.default"]
    }
};

Client teamsClient = check new(configuration);

var randomString = createRandomUUIDWithoutHyphens();

string teamDisplayName = string `Alice's Secret Team ${randomString}`;
string teamDescription = "Adventures in Wonderland";
string teamId = "";

string channelName = string `Plot room ${randomString}`;
string channelDescription = "Dethrone The Queen of Hearts";
string channelId = "";
string privateChannelId = "";
string channelMessageId = "";
string channelmembershipId = "";

string chatId = "";
string chatMembershipId = "";
string chatMessageId = "";

@test:Config {
    enable: true
}
function testCreateTeam() {
    log:printInfo("client->createTeam()");

    Team info = {
        displayName: teamDisplayName,
        description: teamDescription
    };

    string|Error newTeamId = teamsClient->createTeam(info);
    if (newTeamId is string) {
        teamId = newTeamId;
        log:printInfo("New team id" + teamId.toString());
    } else {
        test:assertFail(msg = newTeamId.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateTeam]
}
function testGetTeamById() {
    log:printInfo("client->getTeamById()");

    string tid = teamId;

    TeamData|Error teamInfo = teamsClient->getTeam(tid);
    if (teamInfo is TeamData) {
        log:printInfo("Team info " + teamInfo.toString());
    } else {
        test:assertFail(msg = teamInfo.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateTeam]
}
function updateTeam() {
    log:printInfo("client->updateTeam()");

    string tid = teamId;
    Team info = {
        displayName: "Alice in Wonderland"
    };

    Error? teamInfo = teamsClient->updateTeam(tid, info);
    if (teamInfo is ()) {
        log:printInfo("Team update successful");
    } else {
        test:assertFail(msg = teamInfo.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateTeam]
}
function testAddMemberToTeam() {
    log:printInfo("client->addMemberToTeam()");

    string tid = teamId;
    Member data = {
        roles: ["owner"], // test the other parameters in this record type
        userId: chatUser3
    };

    MemberData|Error teamMemberInfo = teamsClient-> addMemberToTeam(tid, data);
    if (teamMemberInfo is MemberData) {
        log:printInfo("New team member info ", info = teamMemberInfo.toString());
    } else {
        test:assertFail(msg = teamMemberInfo.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateTeam]
}
function testCreateChannel() {
    log:printInfo("client->createChannel()");

    string tid = teamId;
    Channel data = {
        displayName: channelName, //Channel should have unique names
        description: channelDescription,
        membershipType: "standard"
    };

    ChannelData|Error channelInfo = teamsClient->createChannel(tid, data);
    if (channelInfo is ChannelData) {
        log:printInfo("New channel info " + channelInfo.toString());
        channelId = channelInfo.id;
    } else {
        test:assertFail(msg = channelInfo.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateChannel]
}
function getChannelsInTeam() {
    log:printInfo("client->getChannelsInTeam()");

    string tid = teamId;

    ChannelData[]|Error channelArray = teamsClient->getChannelsInTeam(tid);
    if (channelArray is ChannelData[]) {
        log:printInfo("Channels " + channelArray.toString());
    } else {
        test:assertFail(msg = channelArray.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateChannel]
}
function getChannel() {
    log:printInfo("client->getChannel()");

    string tid = teamId;
    string cid = channelId;

    ChannelData|Error channelInfo = teamsClient->getChannel(tid, cid);
    if (channelInfo is ChannelData) {
        log:printInfo("Channel info " + channelInfo.toString());
    } else {
        test:assertFail(msg = channelInfo.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateChannel]
}
function testUpdateChannel() {
    log:printInfo("client->updateChannel()");

    string tid = teamId;
    string cid = channelId;
    Channel data = {
        displayName: "Plot room",
        description: "Alices' army"
    };

    Error? channelInfo = teamsClient->updateChannel(tid, cid, data);
    if (channelInfo is ()) {
        log:printInfo("Sucessfully updated the channel");
    } else {
        test:assertFail(msg = channelInfo.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateTeam, testAddMemberToTeam]
}
function testAddMemberToChannel() {
    // This operation is allowed only for channels with a membershipType value of private
    string userId = chatUser3;
    string role = "owner"; //member should be owner
    string tid = teamId;

    Channel data = {
        displayName: channelName+"_private", //Channel should have unique names
        description: channelDescription,
        membershipType: "private"
    };
    
    log:printInfo("Step 1 - Create private channel");
    ChannelData|Error channelInfo = teamsClient->createChannel(tid, data);
    if (channelInfo is ChannelData) {
        log:printInfo("Private channel info " + channelInfo.toString());
        privateChannelId = channelInfo.id;
    } else {
        test:assertFail(msg = channelInfo.message());
    }

    log:printInfo("client->addMemberToChannel()");
    MemberData|Error memberInfo = teamsClient->addMemberToChannel(tid, privateChannelId, userId, role);
    if (memberInfo is MemberData) {
        log:printInfo(memberInfo.toString());
        channelmembershipId = memberInfo.id;
    } else {
        test:assertFail(msg = memberInfo.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testUpdateChannel, testAddMemberToChannel]
}
function testListChannelMembers() {
    log:printInfo("client->listChannelMembers()");

    string tid = teamId;
    string cid = channelId;

    MemberData[]|Error memberInfo = teamsClient->listChannelMembers(tid, cid);
    if (memberInfo is MemberData[]) {
        log:printInfo("Members ", info = memberInfo.toString());
    } else {
        test:assertFail(msg = memberInfo.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testAddMemberToChannel]
}
function testSendChannelMessage() {
    log:printInfo("client->sendChannelMessage()");

    string tid = teamId;
    string cid = channelId;
    Message message = {
        body: {
            content: "Hi people"
        }
    };

    MessageData|Error channelMessage = teamsClient->sendChannelMessage(tid, cid, message);
    if (channelMessage is MessageData) {
        log:printInfo("New channel message " + channelMessage.toString());
        channelMessageId = channelMessage.id;
    } else {
        test:assertFail(msg = channelMessage.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testSendChannelMessage]
}
function sendReplyToChannelMessage() {
    log:printInfo("client->sendReplyToChannelMessage()");

    string tid = teamId;
    string cid = channelId;
    string mid = channelMessageId;
    Message body = {
        body: {
            content: "Hi All, Queen of hearts is rude"
        }
    };

    MessageData|Error channelReply = teamsClient->sendReplyMessage(tid, cid, mid, body);
    if (channelReply is MessageData) {
        log:printInfo("Reply message " + channelReply.toString());
    } else {
        test:assertFail(msg = channelReply.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testListChannelMembers, testAddMemberToChannel]
}
function deleteChannelMember() {
    log:printInfo("client->deleteChannelMember()");

    string tid = teamId;
    string cid = privateChannelId;
    string mid = channelmembershipId;

    Error? channelInfo = teamsClient->deleteChannelMember(tid, cid, mid);
    if (channelInfo is ()) {
        log:printInfo("Sucessfully deleted the member");
    } else {
        test:assertFail(msg = channelInfo.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateTeam]
}
function testCreateChat() {
    log:printInfo("client->createChat()");

    Chat data = {
        chatType: "group",
        members: [
            {
                roles: ["owner"],
                userId: chatOwner
            },
            {
                roles: ["owner"],
                userId: chatUser2
            }
        ]
    };

    ChatData|Error chatData = teamsClient->createChat(data);
    if (chatData is ChatData) {
        log:printInfo("Chat created" + chatData.toString());
        chatId = chatData.id;
    } else {
        test:assertFail(msg = chatData.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateChat]
}
function getChat() {
    log:printInfo("client->getChat()");

    string cid = chatId;

    ChatData|Error chatData = teamsClient->getChat(chatId);
    if (chatData is ChatData) {
        log:printInfo("Chat created" + chatData.toString());
    } else {
        test:assertFail(msg = chatData.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateChat]
}
function updateChat() {
    log:printInfo("client->updateChat()");

    string cid = chatId;
    string topic =  "Advices from a Caterpillar";

    ChatData|Error chatData = teamsClient->updateChat(chatId, topic);
    if (chatData is ChatData) {
        log:printInfo("Chat created" + chatData.toString());
    } else {
        test:assertFail(msg = chatData.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateChat]
}
function listChatMembers() {
    log:printInfo("client->listChatMembers()");

    string cid = chatId;

    MemberData[]|Error chatMembers = teamsClient->listChatMembers(chatId);
    if (chatMembers is MemberData[]) {
        log:printInfo("Chat member list" + chatMembers.toString());
    } else {
        test:assertFail(msg = chatMembers.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateChat]
}
function testAddMemberToChat() {
    log:printInfo("client->addMemberToChat()");

    string cid = chatId;
    Member data = {
        roles: ["owner"],
        userId: chatUser3,
        visibleHistoryStartDateTime: "2019-04-18T23:51:43.255Z"
    };

    MemberData|Error chatMember = teamsClient->addMemberToChat(chatId, data);
    if (chatMember is MemberData) {
        log:printInfo("Member added to chat" + chatMember.toString());
        chatMembershipId = chatMember.id;
    } else {
        test:assertFail(msg = chatMember.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testAddMemberToChat]
}
function removeMemberFromChat() {
    log:printInfo("client->removeMemberFromChat()");

    string cid = chatId;
    string membershipId = chatMembershipId;

    Error? chatMember = teamsClient->removeMemberFromChat(cid, membershipId);
    if (chatMember is Error) {
        test:assertFail(msg = chatMember.message());

    } else {
        log:printInfo("Member removed successfully");

    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testCreateChat]
}
function testSendChatMessage() {
    log:printInfo("client->sendChatMessage()");

    string cid = chatId;
    Message message = {
        body: {
            content: "Against Idleness and Mischief"
        }
    };

    MessageData|Error chatMessage = teamsClient->sendChatMessage(cid, message);
    if (chatMessage is MessageData) {
        log:printInfo("New message " + chatMessage.toString());
    } else {
        test:assertFail(msg = chatMessage.message());
    }
    io:println("\n\n");
}

@test:Config {
    enable: true,
    dependsOn: [testSendChatMessage]
}
function getChatMessage() {
    log:printInfo("client->getChatMessage()");

    string cid = chatId;
    string cmid = chatMessageId;

    MessageData|MessageData[]|Error chatMessages = teamsClient->getChatMessage(chatId, cmid);
    if (chatMessages is MessageData) {
        log:printInfo("New chat message " + chatMessages.toString());
    } else if (chatMessages is MessageData[]) {
        log:printInfo("Chat messages " + chatMessages.toString());
    } else {
        test:assertFail(msg = chatMessages.message());
    }
    io:println("\n\n");
}

@test:AfterSuite {}
function testDeleteTeamsChatsChannels() {
    runtime:sleep(2);

    string tid = teamId;
    string cid = channelId;

    Error? channelInfo = teamsClient->deleteChannel(tid, cid);
    if (channelInfo is ()) {
        log:printInfo("Sucessfully deleted the channel");
    } else {
        test:assertFail(msg = channelInfo.message());
    }

    Error? teamInfo = teamsClient->deleteTeam(tid);
    if (teamInfo is ()) {
        log:printInfo("Sucessfully deleted the team");
    } else {
        test:assertFail(msg = teamInfo.message());
    }
}

# Create a random UUID removing the unnecessary hyphens which will interrupt querying opearations.
# 
# + return - A string UUID without hyphens
function createRandomUUIDWithoutHyphens() returns string {
    string? stringUUID = java:toString(createRandomUUID());
    if (stringUUID is string) {
        stringUUID = 'string:substring(regex:replaceAll(stringUUID, "-", ""), 1, 4);
        return stringUUID;
    } else {
        return EMPTY_STRING;
    }
}

function createRandomUUID() returns handle = @java:Method {
    name: "randomUUID",
    'class: "java.util.UUID"
} external;
