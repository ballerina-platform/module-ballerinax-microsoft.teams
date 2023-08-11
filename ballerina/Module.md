## Overview
Ballerina connector for Microsoft Teams is connecting to MS Teams platform API in Microsoft Graph via Ballerina language. 
It provides capability to perform basic functionalities provided in MS Teams such as Sending messages, 
Viewing messages, Creating Teams, Channels and Chats, deleting and updating resources etc programmatically. 

This module supports [Microsoft Graph API](https://docs.microsoft.com/en-us/graph/overview) `v1.0`.

## Prerequisites
Before using this connector in your Ballerina application, complete the following:

* Create a [Microsoft 365 Work and School account](https://www.office.com/)
* Create an [Azure account](https://azure.microsoft.com/en-us/) to register an application in the Azure portal
* Obtain tokens
    - Use [this](https://docs.microsoft.com/en-us/graph/auth-register-app-v2) guide to register an application with the Microsoft identity platform
    - The necessary scopes for this connector are shown below.

    | Permissions name              | Type      | Description                                                      |
    |:-----------------------------:|:---------:|:----------------------------------------------------------------:|
    | Channel.Create                | Delegated | Create channels                                                  |
    | Channel.Delete.All            | Delegated | Delete channels                                                  |
    | Channel.ReadBasic.All         | Delegated | Read the names and descriptions of channels                      |
    | ChannelMember.Read.All        | Delegated | Read the members of channels                                     |
    | ChannelMember.ReadWrite.All   | Delegated | Add and remove members from channels                             |
    | ChannelMessage.Send           | Delegated | Send channel messages                                            |
    | ChannelSettings.ReadWrite.All | Delegated | Read and write the names, descriptions, and settings of channels |
    | Chat.Create                   | Delegated | Create chats                                                     |
    | Chat.ReadWrite                | Delegated | Read and write user chat messages                                |
    | ChatMember.ReadWrite          | Delegated | Add and remove members from chats                                |
    | ChatMessage.Send              | Delegated | Send user chat messages                                          |
    | Group.ReadWrite.All           | Delegated | Read and write all groups                                        |
    | Team.Create                   | Delegated | Create teams                                                     |
    | Team.ReadBasic.All            | Delegated | Read the names and descriptions of teams                         |
    | TeamMember.ReadWrite.All      | Delegated | Add and remove members from teams                                |
    | TeamSettings.ReadWrite.All    | Delegated | Read and change teams' settings                                  |
    
## Quickstart
To use the MS Teams connector in your Ballerina application, update the .bal file as follows:
### Step 1 - Import connector
Import the ballerinax/microsoft.teams module into the Ballerina project.
```ballerina
import ballerinax/microsoft.teams;
```
### Step 2 - Create a new connector instance
You can now make the connection configuration using the OAuth2 refresh token grant config.
```ballerina
teams:ConnectionConfig configuration = {
    auth: {
        refreshUrl: <REFRESH_URL>,
        refreshToken : <REFRESH_TOKEN>,
        clientId : <CLIENT_ID>,
        clientSecret : <CLIENT_SECRET>
    }
};

teams:Client teamsClient = check new (configuration);
```
### Step 3 - Invoke connector operation

1. Create a team
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

2. Use `bal run` command to compile and run the Ballerina program

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/tree/main/examples)**
