
isolated function mapJsonToChannelDataArray(map<json> reponsePayload) returns ChannelData[]|Error {
    ChannelData[] channelArray = [];
    json[] valueArrayResult = <json[]>reponsePayload.get("value");

    foreach var item in valueArrayResult {
        ChannelData channel = check item.cloneWithType(ChannelData);
        channelArray.push(channel);
    }
    return channelArray;
}

isolated function mapJsonToMemberDataArray(map<json> reponsePayload) returns MemberData[]|Error {
    MemberData[] memberArray = [];
    json[] valueArrayResult = <json[]>reponsePayload.get("value");

    foreach var item in valueArrayResult {
        MemberData member = check item.cloneWithType(MemberData);
        memberArray.push(member);
    }
    return memberArray;
}

isolated function mapJsonToMessageDataArray(map<json> reponsePayload) returns MessageData[]|Error {
    MessageData[] messageArray = [];
    json[] valueArrayResult = <json[]>reponsePayload.get("value");

    foreach var item in valueArrayResult {
        MessageData member = check item.cloneWithType(MessageData);
        messageArray.push(member);
    }
    return messageArray;
}

isolated function createMemberPayload(Member data) returns json|Error {
    json payload = {"@odata.type": "#microsoft.graph.aadUserConversationMember"};
    _ = check payload.mergeJson(check data.cloneWithType(json));
    _ = check payload.mergeJson({"user@odata.bind": string `https://graph.microsoft.com/v1.0/users('${data?.userId.toString()}')`});
    return payload;
}

isolated function createChatDataPayload(Chat data) returns json|Error {
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
