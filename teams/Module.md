## Overview
Ballerina connector for Microsoft Teams is connecting to MS Teams platform API in Microsoft Graph via Ballerina 
language easily. It provides capability to perform basic functionalities provided in MS Teams such as Sending messages, 
Viewing messages, Creating Teams, Channels and Chats, deleting and updating resources etc programmatically. 

This module supports [Microsoft Graph API](https://docs.microsoft.com/en-us/graph/overview) v1.0 version.
 ## Configuring connector
### Prerequisites
- Microsoft Office365 Work or School account
- Access to register an application in Azure portal

### Obtaining tokens
Follow the following steps below to obtain the configurations.

1. Before you run the following steps, create an account in [Microsoft Teams](https://www.microsoft.com/en-ww/microsoft-teams/group-chat-software). Next, sign into [Azure Portal - App Registrations](https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade). You should use your work or school account to register.

2. In the App registrations page, click **New registration** and enter a meaningful name in the name field.

3. In the **Supported account types** section, select **Accounts in this organizational directory only (Single-tenant)** or **Accounts in any organizational directory (Any Azure AD directory - Multi-tenant)**. Click **Register** to create the application.
    
4. Copy the Application (client) ID (`<CLIENT_ID>`). This is the unique identifier for your app.
    
5. In the application's list of pages (under the **Manage** tab in left hand side menu), select **Authentication**.
    Under **Platform configurations**, click **Add a platform**.

6. Under **Configure platforms**, click **Web** located under **Web applications**.

7. Under the **Redirect URIs text box**, register the https://login.microsoftonline.com/common/oauth2/nativeclient url.
   Under **Implicit grant**, select **Access tokens**.
   Click **Configure**.

8. Under **Certificates & Secrets**, create a new client secret (`<CLIENT_SECRET>`). This requires providing a description and a period of expiry. Next, click **Add**.

9. Next, you need to obtain an access token and a refresh token to invoke the Microsoft Graph API.
First, in a new browser, enter the below URL by replacing the `<CLIENT_ID>` with the application ID. 

- Here you need to provide a space seperated list of necessary scope names for `<SCOPES>`. The necessary scopes are shown below.

    | Permissions name              | Type      | Description                                                      |
    | ----------------------------- | --------- | ---------------------------------------------------------------- |
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



    ```
    https://login.microsoftonline.com/common/oauth2/v2.0/authorize?response_type=code&client_id=<CLIENT_ID>&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient&scope=<SCOPES> offline_access
    ```

10. This will prompt you to enter the username and password for signing into the Azure Portal App.

11. Once the username and password pair is successfully entered, this will give a URL as follows on the browser address bar.

    ```
    https://login.microsoftonline.com/common/oauth2/nativeclient?code=xxxxxxxxxxxxxxxxxxxxxxxxxxx
    ```

12. Copy the code parameter (`xxxxxxxxxxxxxxxxxxxxxxxxxxx` in the above example) and in a new terminal, enter the following cURL command by replacing the `<CODE>` with the code received from the above step. The `<CLIENT_ID>` and `<CLIENT_SECRET>` parameters are the same as above.

    ```
    curl -X POST --header "Content-Type: application/x-www-form-urlencoded" --header "Host:login.microsoftonline.com" -d "client_id=<CLIENT_ID>&client_secret=<CLIENT_SECRET>&grant_type=authorization_code&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient&code=<CODE>&scope=<SCOPES> offline_access" https://login.microsoftonline.com/common/oauth2/v2.0/token
    ```

    The above cURL command should result in a response as follows.
    ```
    {
      "token_type": "Bearer",
      "scope": openid <LIST_OF_SCOPES>",
      "expires_in": 3600,
      "ext_expires_in": 3600,
      "access_token": "<ACCESS_TOKEN>",
      "refresh_token": "<REFRESH_TOKEN>"
    }
    ```

13. Provide the following configuration information in the `Config.toml` file to use the Microsoft Teams connector.

    ```ballerina
    [ballerinax.microsoft.teams]
    refreshUrl = <MS_REFRESH_URL>
    refreshToken = <MS_REFRESH_TOKEN>
    clientId = <MS_CLIENT_ID>
    clientSecret = <MS_CLIENT_SECRET>
    ```
 
## Quickstart
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
        clientSecret : <CLIENT_SECRET>
    }
};

teams:Client teamsClient = check new (configuration);

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
