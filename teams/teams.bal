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

import ballerina/http;

isolated function createTeamResource(http:Client httpClient, string url, Team data) returns string|error {
    json payload = check data.cloneWithType(json);
    _ = check payload.mergeJson({"template@odata.bind": "https://graph.microsoft.com/v1.0/teamsTemplates('standard')"});
    http:Response response = check httpClient->post(url, payload);
    map<json>|string handledResponse = check handleAsyncResponse(httpClient, response);
    if (handledResponse is string) {
        return handledResponse;
    } else {
        return error(INVALID_RESPONSE);
    } 
}

isolated function createTeamResourceFromGroup(http:Client httpClient, string url, Team? data) returns string|error {
    json payload = check data.cloneWithType(json);
    http:Response response = check httpClient->put(url, payload);
    map<json>|string handledResponse = check handleResponse(response); //
    if (handledResponse is map<json>) {
        json teamId = check handledResponse.id;
        return teamId.toString();
    } else {
        return error(INVALID_RESPONSE);
    } 
}

isolated function updateTeamResource(http:Client httpClient, string url, Team data) returns error? {
    json payload = check data.cloneWithType(json);
    http:Response response = check httpClient->patch(url, payload);
    _ = check handleResponse(response);
}

isolated function addMemberToTeamResource(http:Client httpClient, string url, Member data) returns 
                                          MemberData|error {
    json payload = check createMemberPayload(data);
    return check httpClient->post(url, payload, targetType = MemberData);
}

isolated function deleteTeamResource(http:Client httpClient, string url) returns error? {
    http:Response response = check httpClient->delete(url);
    _ = check handleResponse(response);
}
