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

isolated function createChatResource(http:Client httpClient, string url, Chat data) returns ChatData|Error {
    http:Request request = new;
    json payload = check createChatDataPayload(data);
    return check httpClient->post(url, payload, targetType = ChatData);
}

isolated function lisChatResourceMembers(http:Client httpClient, string url) returns MemberData[]|Error {
    http:Response response = check httpClient->get(url);
    map<json> handledResponse = check handleResponse(response);
    return check mapJsonToMemberDataArray(handledResponse);
}

isolated function addMemberToChatResource(http:Client httpClient, string url, Member data) returns 
                                          MemberData|Error {
    http:Request request = new;
    json payload = check createMemberPayload(data);
    http:Response response = check httpClient->post(url, payload);
    if (response.statusCode is http:STATUS_CREATED) {
        string locationHeader = check response.getHeader(http:LOCATION);
        http:Response addResponse = check httpClient->get(<@untainted>locationHeader);
        map<json>? finalResponse = check handleResponse(addResponse); 
        if (finalResponse is map<json>) {
            return check finalResponse.cloneWithType(MemberData);        
        } else {
            return error PayloadValidationError(INVALID_RESPONSE);
        }
    }
    json errorPayload = check response.getJsonPayload();
    string message = errorPayload.toString(); // Error should be defined as a user defined object
    return error PayloadValidationError(message);
}

isolated function deleteMemberFromChatResource(http:Client httpClient, string url) returns Error? {
    http:Response response = check httpClient->delete(url);
    _ =  check handleResponse(response);
}

isolated function sendMessageToChatResource(http:Client httpClient, string url, Message data) returns 
                                            MessageData|Error {
    http:Request request = new;
    json payload = check data.cloneWithType(json);
    return check httpClient->post(url, payload, targetType = MessageData);
}

isolated function getMessagesFromChatResource(http:Client httpClient, string url) returns 
                                              MessageData|MessageData[]|Error {
    http:Response response = check httpClient->get(url);
    map<json> handledResponse = check handleResponse(response);

    if (handledResponse.get("@odata.count") is int) {
        return check mapJsonToMessageDataArray(handledResponse);
    } else {
        return check handledResponse.cloneWithType(MessageData);
    }
}
