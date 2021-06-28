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

    log:printInfo("Send channel message");
    string teamId = "0377f416-f978-475d-831c-eba35f2c90f9";
    string channelId = "19:797ca37b7bbe48fb84de02a4d9adbe86@thread.tacv2";
    teams:Message message = {
        body: {
            content: "Hello World"
        }
    };

    teams:MessageData|teams:Error channelMessage = teamsClient->sendChannelMessage(teamId, channelId, message);    
    if (channelMessage is teams:MessageData) {
        log:printInfo("Message ID " + channelMessage.id.toString());
        log:printInfo("Success!");
    } else {
        log:printError(channelMessage.message());
    }
}
