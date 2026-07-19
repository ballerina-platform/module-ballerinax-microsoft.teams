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
import ballerina/time;

// Scenario: channel tab lifecycle in the existing channel.
//
// Chains: listChannelTabs -> createChannelTab -> getChannelTab -> updateChannelTab
//         -> listChannelTabs -> deleteChannelTab
//
// createChannelTab binds a Teams app via the `teamsApp@odata.bind` key in the payload (from the
// `tabTeamsAppId` config, defaulting to the built-in Website app). The app must be installed in the
// team and the token must carry the `TeamsTab.*` scopes; if either is missing, Graph rejects the
// create and the whole scenario is logged and skipped rather than failed. The tab is deleted at the end.
@test:Config {groups: ["scenarios"]}
function testScenarioTabManagement() returns error? {
    if !isLiveServer {
        return;
    }

    string suffix = time:utcNow()[0].toString();
    string tabName = "Scenario Tab " + suffix;

    // Step 1: List the current tabs (always safe).
    MicrosoftGraphTeamsTabCollectionResponse before = check teams->listChannelTabs(teamId, channelId);
    logStep("Listed channel tabs: " + (before.value ?: []).length().toString());

    // Step 2: Create a tab backed by the configured Teams app. Best-effort — if the app isn't
    // installed or TeamsTab.Create isn't consented, skip the rest of the scenario.
    MicrosoftGraphTeamsTabConfiguration tabConfig = {
        entityId: "scenario-" + suffix,
        contentUrl: "https://learn.microsoft.com/graph/teams-concept-overview",
        websiteUrl: "https://learn.microsoft.com/graph/teams-concept-overview"
    };
    MicrosoftGraphTeamsTab tabPayload = {
        displayName: tabName,
        "teamsApp@odata.bind": string `https://graph.microsoft.com/v1.0/appCatalogs/teamsApps/${tabTeamsAppId}`,
        configuration: tabConfig
    };
    MicrosoftGraphTeamsTab|error created = teams->createChannelTab(teamId, channelId, tabPayload);
    if created is error {
        if isSkippable(created) {
            logStep("Skipped tab scenario: app '" + tabTeamsAppId + "' not installed in the team, or TeamsTab.Create not consented (" + created.message() + ").");
            return;
        }
        return created;
    }
    string tabId = created.id ?: "";
    test:assertTrue(tabId.length() > 0, "createChannelTab did not return a tab id");
    logStep("Created tab: " + tabId);

    do {
        // Step 3: Read the tab back.
        MicrosoftGraphTeamsTab fetched = check teams->getChannelTab(teamId, channelId, tabId);
        test:assertEquals(fetched.id, tabId, "getChannelTab returned a different id");
        logStep("Fetched tab and verified id");

        // Step 4: Rename the tab.
        string updatedName = "Scenario Tab U " + suffix;
        MicrosoftGraphTeamsTab updated = check teams->updateChannelTab(teamId, channelId, tabId, {displayName: updatedName});
        if updated?.displayName is string {
            test:assertEquals(updated?.displayName, updatedName, "updateChannelTab did not apply the new name");
        }
        logStep("Renamed tab");

        // Step 5: Confirm the tab is listed.
        MicrosoftGraphTeamsTabCollectionResponse after = check teams->listChannelTabs(teamId, channelId);
        boolean found = false;
        foreach MicrosoftGraphTeamsTab t in after.value ?: [] {
            if t.id == tabId {
                found = true;
                break;
            }
        }
        test:assertTrue(found, "created tab not found in listChannelTabs");
        logStep("Located tab in listChannelTabs");
    } on fail error e {
        error? cleanup = teams->deleteChannelTab(teamId, channelId, tabId);
        if cleanup is error {
            logStep("Cleanup note: could not delete tab " + tabId + " (" + cleanup.message() + ").");
        }
        return e;
    }

    // Step 6: Clean up.
    check teams->deleteChannelTab(teamId, channelId, tabId);
    logStep("Deleted tab: " + tabId);
}
