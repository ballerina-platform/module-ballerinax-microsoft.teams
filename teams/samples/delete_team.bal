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

    log:printInfo("Delete team"); //////////test

    string teamId = "0377f416-f978-475d-831c-eba35f2c90f9";

    teams:Error? teamInfo = teamsClient->deleteTeam(teamId);
    if (teamInfo is ()) {
        log:printInfo("CSucessfully deleted");
        log:printInfo("Success!");
    } else {
        log:printError(teamInfo.message());
    }
}
