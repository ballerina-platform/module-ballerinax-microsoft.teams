import ballerina/http;

isolated function createChatResource(http:Client httpClient, string url, Chat data) returns ChatData|Error {
    http:Request request = new;
    json payload = check createChatDataPayload(data);
    http:Response response = check httpClient->post(url, payload);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check handledResponse.cloneWithType(ChatData);        
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function getChatResource(http:Client httpClient, string url) returns ChatData|Error {
    http:Response response = check httpClient->get(url);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check handledResponse.cloneWithType(ChatData);        
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function updateChatResource(http:Client httpClient, string url, string topic) returns ChatData|Error {
    http:Response response = check httpClient->patch(url, {topic: topic});
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check handledResponse.cloneWithType(ChatData);        
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function lisChatResourceMembers(http:Client httpClient, string url) returns MemberData[]|Error {
    http:Response response = check httpClient->get(url);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check mapJsonToMemberDataArray(handledResponse);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
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

isolated function deleteMemberFromChatResource(http:Client httpClient, string url) returns Error? { ////////////Same as team delete
    http:Response response = check httpClient->delete(url);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is ()) {
        return handledResponse;
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    } 
}

isolated function sendMessageToChatResource(http:Client httpClient, string url, Message data) returns 
                                            MessageData|Error {
    http:Request request = new;
    json payload = check data.cloneWithType(json);

    http:Response response = check httpClient->post(url, payload);
    map<json>? handledResponse = check handleResponse(response);
    if (handledResponse is map<json>) {
        return check handledResponse.cloneWithType(MessageData);
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }
}

isolated function getMessagesFromChatResource(http:Client httpClient, string url) returns 
                                              MessageData|MessageData[]|Error {
    http:Response response = check httpClient->get(url);
    map<json>? handledResponse = check handleResponse(response);

    if (handledResponse is map<json>) {
        if (handledResponse.get("@odata.count") is int) {
            return check mapJsonToMessageDataArray(handledResponse);
        } else {
            return check handledResponse.cloneWithType(MessageData);
        }
    } else {
        return error PayloadValidationError(INVALID_RESPONSE);
    }  
}
