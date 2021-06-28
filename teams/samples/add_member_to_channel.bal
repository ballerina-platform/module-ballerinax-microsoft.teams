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

    // This operation is allowed only for channels with a membershipType value of private
    log:printInfo("Add member to channel");
    string teamId = "0377f416-f978-475d-831c-eba35f2c90f9";
    string privateChannelId = "19:797ca37b7bbe48fb84de02a4d9adbe86@thread.tacv2";
    string userId = "73a77e1e-31c0-4a99-ac1d-733053b16cbe";
    string role = "owner"; //member should be owner

    teams:MemberData|teams:Error memberInfo = teamsClient->addMemberToChannel(teamId, privateChannelId, userId, role);
    if (memberInfo is teams:MemberData) {
        log:printInfo("Member added sucessfully " + memberInfo.id.toString());
        log:printInfo("Success!");
    } else {
        log:printError(memberInfo.message());
    }
}
