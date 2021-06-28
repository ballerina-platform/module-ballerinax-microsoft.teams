import ballerina/log;
import ballerina/os;
import ballerinax/microsoft.teams;

configurable string & readonly refreshUrl = os:getEnv("TOKEN_ENDPOINT");
configurable string & readonly refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string & readonly clientId = os:getEnv("CLIENT_ID");
configurable string & readonly clientSecret = os:getEnv("CLIENT_SECRET");

public function main() returns error? {
    teams:Configuration configuration = {
        clientConfig: {
            refreshUrl: refreshUrl,
            refreshToken : refreshToken,
            clientId : clientId,
            clientSecret : clientSecret,
            scopes: ["openid", "offline_access","https://graph.microsoft.com/.default"]
        }
    };
    teams:Client teamsClient = check new(configuration);

    log:printInfo("Add member to chat");
    string owner = "4250c029-6f82-40b7-bad0-d1d336f86837";
    string chatId = "19:994846dd2e5340b49dd5a5e8fb90fa60@thread.v2";
    teams:Member data = {
        roles: ["owner"],
        userId: owner,
        visibleHistoryStartDateTime: "2019-04-18T23:51:43.255Z"
    };

    teams:MemberData|teams:Error chatMember = teamsClient->addMemberToChat(chatId, data);
    if (chatMember is teams:MemberData) {
        log:printInfo("Member Added to the chat " + chatMember.id.toString());
        log:printInfo("Success!");
    } else {
        log:printError(chatMember.message());
    }
}
