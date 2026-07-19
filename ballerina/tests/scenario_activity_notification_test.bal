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

// Scenario: send an activity-feed notification to the signed-in user.
//
// Single call: sendActivityNotification. Uses the reserved `systemDefault` activity type (the only
// type that doesn't have to be declared in a Teams app manifest) and targets the signed-in user.
//
// This is best-effort. Graph requires the calling app to be installed in the team and the token to
// carry `TeamsActivity.Send`; a generic connector app usually satisfies neither, so a 4xx here is
// logged and skipped rather than failing. It runs only when `userId` is configured.
@test:Config {groups: ["scenarios"]}
function testScenarioActivityNotification() returns error? {
    if !isLiveServer {
        return;
    }
    if userId == "" {
        logStep("Skipped: set `userId` in Config.toml (the notification recipient).");
        return;
    }

    MicrosoftGraphTeamworkActivityTopic topic = {
        'source: "entityUrl",
        value: string `https://graph.microsoft.com/v1.0/teams/${teamId}`
    };
    MicrosoftGraphItemBody previewText = {content: "Connector scenario notification"};
    MicrosoftGraphTeamworkNotificationRecipient recipient = {
        atOdataType: "microsoft.graph.aadUserNotificationRecipient",
        "userId": userId
    };
    MicrosoftGraphKeyValuePair[] templateParameters = [
        {name: "systemDefault", value: "A connector scenario test sent this notification."}
    ];

    error? result = teams->sendActivityNotification(teamId, {
        topic,
        activityType: "systemDefault",
        previewText,
        recipient,
        templateParameters
    });
    if result is () {
        logStep("Sent activity notification to the signed-in user");
    } else if isSkippable(result) {
        logStep("Skipped sendActivityNotification (app not installed in the team, or TeamsActivity.Send not consented): " + result.message());
    } else {
        return result;
    }
}
