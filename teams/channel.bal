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

isolated function getChannelResources(http:Client httpClient, string url) returns ChannelData[]|Error {
    http:Response response = check httpClient->get(url);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check mapJsonToChannelDataArray(handledResponse);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    } 
}

isolated function createChannelResource(http:Client httpClient, string url, Channel info) returns 
                                        ChannelData|Error {
    http:Request request = new;
    json payload = check info.cloneWithType(json);
    http:Response response = check httpClient->post(url, payload);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check handledResponse.cloneWithType(ChannelData);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function getChannelResource(http:Client httpClient, string url) returns ChannelData|Error {
    http:Response response = check httpClient->get(url);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check handledResponse.cloneWithType(ChannelData);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function updateChannelResource(http:Client httpClient, string url, Channel info) returns Error? {
    json payload = check info.cloneWithType(json);
    http:Response response = check httpClient->patch(url, payload);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is ()) {
        return handledResponse;
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function addChannelMember(http:Client httpClient, string url, string userId, string role) returns @tainted
                                   MemberData|Error {
    http:Request request = new;
    json payload = {
        "@odata.type": "#microsoft.graph.aadUserConversationMember",
        roles: [role],
        "user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${userId}')`
    };

    http:Response response = check httpClient->post(url, payload);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check handledResponse.cloneWithType(MemberData);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    } 
}

isolated function listChannelMembersResource(http:Client httpClient, string url) returns MemberData[]|Error {
    http:Response response = check httpClient->get(url);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check mapJsonToMemberDataArray(handledResponse);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function deleteChannelMemberResource(http:Client httpClient, string url) returns Error? {
    http:Response response = check httpClient->delete(url);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is ()) {
        return handledResponse;
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function sendMessageToChannel(http:Client httpClient, string url, Message message) returns 
                                       MessageData|Error {
    http:Request request = new;
    json payload = check message.cloneWithType(json);
    http:Response response = check httpClient->post(url, payload);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check handledResponse.cloneWithType(MessageData);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function sendReplyToChannel(http:Client httpClient, string url, Message reply) returns 
                                     MessageData|Error {
    http:Request request = new;
    json payload = check reply.cloneWithType(json);
    http:Response response = check httpClient->post(url, payload);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check handledResponse.cloneWithType(MessageData);        
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function deleteChannelResource(http:Client httpClient, string url) returns Error? {
    http:Response response = check httpClient->delete(url);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is ()) {
        return handledResponse;
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}
