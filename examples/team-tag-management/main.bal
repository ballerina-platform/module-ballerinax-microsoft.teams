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

// Create a teamwork tag for a team and then list all tags defined on that team.

import ballerina/io;
import ballerinax/microsoft.teams;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string tenantId = ?;
configurable string teamId = ?;
// Object id of a team member to seed the tag with. Microsoft Graph requires a new tag to be
// created with at least one member.
configurable string userId = ?;

public function main() returns error? {
    teams:OAuth2RefreshTokenGrantConfig auth = {
        clientId,
        clientSecret,
        refreshToken,
        refreshUrl: string `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`
    };
    teams:Client teamsClient = check new ({auth});

    // Step 1: Create a teamwork tag on the team, seeded with one member.
    teams:MicrosoftGraphTeamworkTag newTag = check teamsClient->createTag(teamId, {
        displayName: "On-call",
        description: "Members currently on call",
        "members": [{userId: userId}]
    });
    io:println("Created tag with id: ", newTag.id ?: "");

    // Step 2: List all teamwork tags defined on the team.
    teams:MicrosoftGraphTeamworkTagCollectionResponse tags = check teamsClient->listTags(teamId);
    foreach teams:MicrosoftGraphTeamworkTag tag in tags.value ?: [] {
        io:println("Tag: ", tag?.displayName ?: "");
    }
}
