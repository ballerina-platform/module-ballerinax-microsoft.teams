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

    log:printInfo("Create team");
    teams:Team info = {
        displayName: "New team name",
        description: "This is the description for new team"
    };

    string|teams:Error newTeamId = teamsClient->createTeam(info);
    if (newTeamId is string) {
        log:printInfo("Team succesfully created " + newTeamId);
        log:printInfo("Success!");
    } else {
        log:printError(newTeamId.message());
    }
}
