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

    log:printInfo("Create chat");
    string owner1 = "b3bbe751-6c6c-4614-81b8-5e569130eb8b";
    string owner2 = "73a77e1e-31c0-4a99-ac1d-733053b16cbe";
    teams:Chat data = {
        chatType: "group",
        members: [
            {
                roles: ["owner"],
                userId: owner1
            },
            {
                roles: ["owner"],
                userId: owner2
            }
        ]
    };

    teams:ChatData|teams:Error chat = teamsClient->createChat(data);
    if (chat is teams:ChatData) {
        log:printInfo("Succesfully created the chat " + chat.id.toString());
        log:printInfo("Success!");
    } else {
        log:printError(chat.message());
    }
}
