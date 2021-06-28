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

    log:printInfo("List chat members");
    string chatId = "19:994846dd2e5340b49dd5a5e8fb90fa60@thread.v2";

    teams:MemberData[]|teams:Error chatMember = teamsClient->listChatMembers(chatId);
    if (chatMember is  teams:MemberData[]) {
        log:printInfo("Member List" + chatMember.toString());
        log:printInfo("Success!");
    } else {
        log:printError(chatMember.message());
    }
}
