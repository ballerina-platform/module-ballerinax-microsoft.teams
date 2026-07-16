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

// Scenario: teamwork tag management (mirrors examples/team-tag-management).
//
// Chains: createTag -> getTag -> updateTag -> getTag -> listTagMembers
//         -> [createTagMember -> getTagMember -> deleteTagMember] -> listTags -> deleteTag
//
// Graph requires a new tag to be created with at least one member, so this scenario needs
// `userId` (the signed-in user's object id) configured; it is skipped otherwise. The tag-member
// add/read/remove steps need a second user and run only when `secondUserId` is configured.
@test:Config {groups: ["scenarios"]}
function testScenarioTagManagement() returns error? {
    if !isLiveServer {
        return;
    }
    if userId == "" {
        logStep("Skipped: set `userId` in Config.toml to the signed-in user's object id (a tag needs a member).");
        return;
    }

    string suffix = time:utcNow()[0].toString();
    string tagName = "Scenario Tag " + suffix;

    // Step 1: Create a teamwork tag with the signed-in user as its first member.
    MicrosoftGraphTeamworkTag created = check teams->createTag(teamId, {
        displayName: tagName,
        description: "Created by the tag-management scenario test",
        "members": [{userId: userId}]
    });
    string tagId = created.id ?: "";
    test:assertTrue(tagId.length() > 0, "createTag did not return a tag id");
    test:assertEquals(created?.displayName, tagName, "created tag name mismatch");
    logStep("Created tag: " + tagId);

    // Step 2: Read it back.
    MicrosoftGraphTeamworkTag fetched = check teams->getTag(teamId, tagId);
    test:assertEquals(fetched.id, tagId, "getTag returned a different id");
    logStep("Fetched tag and verified id");

    // Step 3: Rename the tag.
    string updatedName = "Scenario Tag U " + suffix;
    MicrosoftGraphTeamworkTag updated = check teams->updateTag(teamId, tagId, {displayName: updatedName});
    if updated?.displayName is string {
        test:assertEquals(updated?.displayName, updatedName, "updateTag name not applied");
    }
    MicrosoftGraphTeamworkTag refetched = check teams->getTag(teamId, tagId);
    test:assertEquals(refetched?.displayName, updatedName, "tag rename not persisted");
    logStep("Renamed tag and verified");

    // Step 4: List the tag's members (the signed-in user added at creation should be present).
    MicrosoftGraphTeamworkTagMemberCollectionResponse tagMembers = check teams->listTagMembers(teamId, tagId);
    test:assertTrue((tagMembers.value ?: []).length() > 0, "tag has no members");
    logStep("Listed tag members: " + (tagMembers.value ?: []).length().toString());

    // Step 5 (optional): add a second user as a tag member, read it, and remove it.
    // A teamwork tag member must already be a member of the team, so the second user is added to
    // the team first and that temporary membership is cleaned up afterwards.
    if secondUserId != "" {
        MicrosoftGraphConversationMember teamMembership = check teams->createMember(teamId, {
            atOdataType: "#microsoft.graph.aadUserConversationMember",
            roles: [],
            "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${secondUserId}')`
        });
        string teamMembershipId = teamMembership.id ?: "";
        logStep("Added second user to team (prerequisite for tag membership)");

        MicrosoftGraphTeamworkTagMember addedMember = check teams->createTagMember(teamId, tagId, {userId: secondUserId});
        string tagMemberId = addedMember.id ?: "";
        test:assertTrue(tagMemberId.length() > 0, "createTagMember did not return a member id");
        logStep("Added tag member: " + tagMemberId);

        MicrosoftGraphTeamworkTagMember fetchedMember = check teams->getTagMember(teamId, tagId, tagMemberId);
        test:assertEquals(fetchedMember.id, tagMemberId, "getTagMember returned a different id");
        logStep("Fetched tag member");

        check teams->deleteTagMember(teamId, tagId, tagMemberId);
        logStep("Removed tag member: " + tagMemberId);

        check teams->deleteMember(teamId, teamMembershipId);
        logStep("Removed second user from team");
    } else {
        logStep("Skipped tag-member add/remove: set `secondUserId` in Config.toml to enable.");
    }

    // Step 6: Confirm the tag appears in the team's tag list.
    MicrosoftGraphTeamworkTagCollectionResponse tags = check teams->listTags(teamId);
    boolean found = false;
    foreach MicrosoftGraphTeamworkTag tag in tags.value ?: [] {
        if tag.id == tagId {
            found = true;
            break;
        }
    }
    test:assertTrue(found, "created tag not found in listTags");
    logStep("Located tag in listTags");

    // Step 7: Clean up.
    check teams->deleteTag(teamId, tagId);
    logStep("Deleted tag: " + tagId);
}
