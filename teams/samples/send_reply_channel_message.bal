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
import ballerina/os;
import ballerinax/microsoft.teams;

configurable string & readonly refreshUrl = os:getEnv("REFRESH_URL");
configurable string & readonly refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string & readonly clientId = os:getEnv("CLIENT_ID");
configurable string & readonly clientSecret = os:getEnv("CLIENT_SECRET");

public function main() returns error? {
    teams:Configuration configuration = {
        clientConfig: {
            refreshUrl: refreshUrl,
            refreshToken : refreshToken,
            clientId : clientId,
            clientSecret : clientSecret,
            scopes: ["openid", "offline_access","https://graph.microsoft.com/.default"]
        }
    };
    teams:Client teamsClient = check new(configuration);

    log:printInfo("Send reply to channel message");
    string teamId = "0377f416-f978-475d-831c-eba35f2c90f9";
    string channelId = "19:797ca37b7bbe48fb84de02a4d9adbe86@thread.tacv2";
    string channelMessageId = "1624343525735";
    teams:Message body = {
        body: {
            content: "Hi this is the reply"
        }
    };

    teams:MessageData|teams:Error channelReply = teamsClient->sendReplyMessage(teamId, channelId, channelMessageId, body);
    if (channelReply is teams:MessageData) {
        log:printInfo("Message ID " + channelReply.id.toString());
        log:printInfo("Success!");
    } else {
        log:printError(channelReply.message());
    }
}
