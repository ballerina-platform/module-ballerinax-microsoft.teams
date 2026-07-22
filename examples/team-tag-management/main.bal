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

// Manage teamwork tags on a team: create a tag with a member, list the team's tags,
// read one back, then delete it.
//
// A new tag must be created with at least one member, so a user object id is required.

import ballerina/io;
import ballerinax/microsoft.teams;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string tenantId = ?;
configurable string teamId = ?;
// Object id of a user to assign to the new tag (a tag needs at least one member).
configurable string userId = ?;

public function main() returns error? {
    teams:OAuth2RefreshTokenGrantConfig auth = {
        clientId,
        clientSecret,
        refreshToken,
        refreshUrl: string `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`
    };
    teams:Client teamsClient = check new ({auth});

    // Step 1: Create a tag with one member.
    teams:TeamworkTag newTag = check teamsClient->createTag(teamId, {
        displayName: "Release Managers",
        "members": [
            {"userId": userId}
        ]
    });
    string tagId = newTag.id ?: "";
    io:println("Created tag with id: ", tagId);

    // Step 2: List all tags defined on the team.
    teams:TeamworkTagCollectionResponse tags = check teamsClient->listTags(teamId);
    io:println("Team tags:");
    foreach teams:TeamworkTag tag in tags.value ?: [] {
        io:println("  - ", tag?.displayName ?: tag.id ?: "unknown");
    }

    // Step 3: Read the newly created tag back.
    teams:TeamworkTag fetched = check teamsClient->getTag(teamId, tagId);
    io:println("Fetched tag: ", fetched?.displayName ?: tagId, " (members: ", fetched?.memberCount ?: 0, ")");

    // Step 4: Delete the tag.
    check teamsClient->deleteTag(teamId, tagId);
    io:println("Deleted tag: ", tagId);
}
