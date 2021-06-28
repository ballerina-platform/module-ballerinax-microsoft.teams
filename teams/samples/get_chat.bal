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

    log:printInfo("Get chat info");
    string chatId = "19:994846dd2e5340b49dd5a5e8fb90fa60@thread.v2";

    teams:ChatData|teams:Error chat = teamsClient->getChat(chatId);
    if (chat is teams:ChatData) {
        log:printInfo("Chat info " + chat.toString());
        log:printInfo("Success!");
    } else {
        log:printError(chat.message());
    }
}
