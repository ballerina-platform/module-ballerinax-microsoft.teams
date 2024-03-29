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

import ballerina/log;
import ballerinax/microsoft.teams;

configurable string & readonly refreshUrl = ?;
configurable string & readonly refreshToken = ?;
configurable string & readonly clientId = ?;
configurable string & readonly clientSecret = ?;

public function main() returns error? {
    teams:ConnectionConfig configuration = {
        auth: {
            refreshUrl: refreshUrl,
            refreshToken: refreshToken,
            clientId: clientId,
            clientSecret: clientSecret
        }
    };
    teams:Client teamsClient = check new (configuration);

    log:printInfo("Add member to chat");
    string owner = "<OWNER_ID>";
    string chatId = "<CHAT_ID>";
    teams:Member data = {
        roles: ["owner"],
        userId: owner,
        visibleHistoryStartDateTime: "2019-04-18T23:51:43.255Z"
    };

    teams:MemberData|error chatMember = teamsClient->addMemberToChat(chatId, data);
    if (chatMember is teams:MemberData) {
        log:printInfo("Member Added to the chat " + chatMember?.id.toString());
        log:printInfo("Success!");
    } else {
        log:printError(chatMember.message());
    }
}
