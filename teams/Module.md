## Overview
Ballerina connector for Microsoft Teams is connecting to MS Teams platform API in Microsoft Graph v1.0 via Ballerina 
language easily. It provides capability to perform basic functionalities provided in MS Teams such as Sending messages, 
Viewing messages, Creating Teams, Channels and Chats, deleting and updating resources etc programmatically. 

This module supports Ballerina SL Beta 1 version.
 
## Obtaining tokens
* Steps to generate tokens *
 
## Quickstart
# Quickstart(s)
## Create a Channel and send messages
### Step 1: Import MS Teams Package
First, import the ballerinax/microsoft.teams module into the Ballerina project.
```ballerina
import ballerinax/microsoft.teams;
```
### Step 2: Configure the connection to an existing Azure AD app
You can now make the connection configuration using the OAuth2 refresh token grant config.
```ballerina
onedrive:Configuration configuration = {
    clientConfig: {
        refreshUrl: <REFRESH_URL>,
        refreshToken : <REFRESH_TOKEN>,
        clientId : <CLIENT_ID>,
        clientSecret : <CLIENT_SECRET>,
        scopes: [<NECESSARY_SCOPES>]
    }
};

teams:Client teamsClient = check new(configuration);

```
### Step 3: Create a team
```
teams:Team info = {
    displayName: "<TEAM_NAME>",
    description: "<TEAM_DESCRIPTION>"
};

string|error newTeamId = teamsClient->createTeam(info);
if (newTeamId is string) {
    log:printInfo("Team succesfully created " + newTeamId);
    log:printInfo("Success!");
} else {
    log:printError(newTeamId.message());
}

```
### Step 4: Create a channel
```
string teamId = "<TEAM_ID>";
teams:Channel data = {
    displayName: "<CHANNEL_NAME>",
    description: "<CHANNEL_DESCRIPTION>",
    membershipType: "standard"
};

teams:ChannelData|error channelInfo = teamsClient->createChannel(teamId, data);
if (channelInfo is teams:ChannelData) {
    log:printInfo("Channel succesfully created " + channelInfo.id.toString());
    log:printInfo("Success!");
} else {
    log:printError(channelInfo.message());
}

```
### Step 5: Send message to channel
```
string teamId = "<TEAM_ID>";
string channelId = "<CHANNEL_ID>";
teams:Message message = {
    body: {
        content: "<MESSAGE>"
    }
};

teams:MessageData|error channelMessage = teamsClient->sendChannelMessage(teamId,  channelId, message);    
if (channelMessage is teams:MessageData) {
    log:printInfo("Message ID " + channelMessage.id.toString());
    log:printInfo("Success!");
} else {
    log:printError(channelMessage.message());
}

```
 
## [You can find more samples here](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/tree/main/teams/samples)
