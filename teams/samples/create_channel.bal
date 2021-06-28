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

    log:printInfo("Create channel");
    string teamId = "0377f416-f978-475d-831c-eba35f2c90f9";
    teams:Channel data = {
        displayName: "New Channel Name", //Channel should have unique names
        description: "This is our new channel",
        membershipType: "standard"
    };

    teams:ChannelData|teams:Error channelInfo = teamsClient->createChannel(teamId, data);
    if (channelInfo is teams:ChannelData) {
        log:printInfo("Channel succesfully created " + channelInfo.id.toString());
        log:printInfo("Success!");
    } else {
        log:printError(channelInfo.message());
    }
}
