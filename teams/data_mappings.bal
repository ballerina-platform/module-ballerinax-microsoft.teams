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

isolated function createMemberPayload(Member data) returns json|error {
    json payload = {"@odata.type": "#microsoft.graph.aadUserConversationMember"};
    _ = check payload.mergeJson(check data.cloneWithType(json));
    _ = check payload.mergeJson({"user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${data?.userId.toString()}')`});
    return payload;
}

isolated function createChatDataPayload(Chat data) returns json|error {
    json payload = {
        topic: let var topic = data?.topic in topic is string ? topic : null,
        chatType: data.chatType
    };
    json[] memberArray = [];
    foreach var member in data?.members {
        memberArray.push(check createMemberPayload(member));
    }

    return check payload.mergeJson({members: memberArray});
}
