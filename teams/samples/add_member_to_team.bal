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

    log:printInfo("Add member to team");
    string teamId = "0377f416-f978-475d-831c-eba35f2c90f9";
    string userId = "73a77e1e-31c0-4a99-ac1d-733053b16cbe";
    teams:Member data = {
        roles: ["owner"],
        userId: userId
    };

    teams:MemberData|teams:Error memberInfo = teamsClient-> addMemberToTeam(teamId, data);
    if (memberInfo is teams:MemberData) {
        log:printInfo("Member Added to the team " + memberInfo.id.toString());
        log:printInfo("Success!");
    } else {
        log:printError(memberInfo.message());
    }
}