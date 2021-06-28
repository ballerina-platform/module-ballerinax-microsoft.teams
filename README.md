Ballerina Connector For Microsoft Teams
===================

[![Build Status](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-msgraph-teams/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-microsoft.teams.svg)](https://github.com/ballerina-platform/module-ballerinax-msgraph-teams/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Connects to Microsoft Teams using Ballerina.

- [Microsoft Teams Connector](#)
    - [Introduction](#introduction)
        - [What is Microsoft Teams](#what-is-microsoft-teams)
        - [Key features of Microsoft OneDrive](#key-features-of-microsoft-teams)
        - [Connector Overview](#connector-overview)
    - [Prerequisites](#prerequisites)
        - [Obtaining tokens](#obtaining-tokens)
        - [Add project configurations file](#add-project-configurations-file)
    - [Supported versions & limitations](#supported-versions-&-limitations)
    - [Quickstarts](#quickstarts)
    - [Samples](#samples)
    - [Building from the Source](#building-from-the-source)
    - [Contributing to Ballerina](#contributing-to-ballerina)
    - [Code of Conduct](#code-of-conduct)
    - [Useful Links](#useful-links)

# Introduction
## What is Microsoft Teams?
[Microsoft Teams](https://www.microsoft.com/en-ww/microsoft-teams/group-chat-software) is a chat-based collaboration 
platform complete with document sharing, online meetings, and many more extremely useful features for business 
communications. It’s included totally free with Microsoft 365 and Office 365. It has designed to be used by local, remote 
and distributed work groups—anyone in any company. 
The true power of MS Teams comes with its rich set of features for collaboration. MS Teams API supports actions such as 
`Chats`, `Channels`, `Meetings` and `Calling`.
- **Chats** are supported as both one-on-one and group chats. Teams chat includes a host of modern messaging features, including
  text formatting, emoji and priority flagging. Users can also share files directly through chat sessions.
- **Channels** can be either Standard—public and open to everyone who wants to join—or private and focused on specific 
  topics or activities. Channel owners must authorize new users to join their channel.
- **Meetings** offers videoconferencing for up to 250 users per session. Video meetings can be scheduled on a channel’s calendar, or 
  users can create them on the fly. MS Teams offers meeting broadcasts for up to 10,000 simultaneous viewers using the Microsoft Stream integration.
- **Calls** offer the ability of outbound calling right from the client. It is an excellent way for remote or mobile users to stay 
  connected through one single, reliable connection.

    <p align="center">
    <img src="./docs/images/MS_Teams.png?raw=true" alt="MS Teams" width="500"/>
    </p>

## Key features of Microsoft Teams
- Teams which are made up of channels, which are conversation boards between teammates.
- A chat function which can take place between teams, groups, and individuals.  
- Document storage in SharePoint, which will contain a default document library folder. 
- Online video calling and screen sharing.
- Audio conferencing where anyone can join an online meeting via phone.
- Full telephony. Microsoft  365 Business Voice can completely replace your business’ existing phone system.

## Connector Overview
Ballerina connector for Microsoft Teams is connecting to MS Teams platform API in Microsoft Graph v1.0 via Ballerina 
language easily. It provides capability to perform basic functionalities provided in MS Teams such as Sending messages, 
Viewing messages, Creating Teams, Channels and Chats, deleting and updating resources etc programmatically. 

The connector has developed on top of Microsoft Graph is a REST web API that empowers you to access Microsoft Cloud 
service resources. This version of the connector only supports the access to the resources and information of a specific 
account (currently logged-in user).

# Prerequisites
- Microsoft Account
- Access to Azure Portal
- Java 11 installed - Java Development Kit (JDK) with version 11 is required
- [Ballerina SL Beta 1](https://ballerina.io/learn/user-guide/getting-started/setting-up-ballerina/installation-options/) installed 

## Obtaining tokens
- Create an account in MS Teams
- Sign-in to Azure Portal - App Registrations. (You should use work or school account to register the app)

- Obtaining OAuth2 credentials <br/>
    To get an access token you need to register your app with microsoft identity platform via Azure Portal. <br/>
    **(The access token contains information about your app, and the permissions it has for the resources and APIs 
    available through Microsoft Graph. To get an access token, your app must be registered with the Microsoft 
    identity platform and be authorized by either a user or an administrator to access the Microsoft Graph 
    resources it needs.)**

    Before your app can get a token from the Microsoft identity platform, it must be registered in the Azure portal. 
    Registration integrates your app with the Microsoft identity platform and establishes the information that it 
    uses to get tokens
    1. App ID
    2. Redirect URL
    3. App Secret <br/>

    **Step 1:** Register a new application in your Azure AD tenant.<br/>
    - In the App registrations page, click **New registration** and enter a meaningful name in the name field.
    - In the **Supported account types** section, select **Accounts in this organizational directory only (Single-tenant)** 
    or **Accounts in any organizational directory (Any Azure AD directory - Multi-tenant)**. Click Register to create 
    the application.
    - Provide a **Redirect URI** if necessary.

        ![Obtaining Credentials Step 1](docs/images/s1.png)
    - Copy the Application (client) ID to fill `<MS_CLIENT_ID>`. This is the unique identifier for your app.

        ![Obtaining Credentials Step 1](docs/images/s2.png)

    **Step 2:** Create a new client secret.<br/>
    - Under **Certificates & Secrets**, create a new client secret to fill `<MS_CLIENT_SECRET>`. This requires providing 
    a description and a period of expiry. Next, click Add.

        ![Obtaining Credentials Step 2](docs/images/s3.png)

    **Step 3:** Add necessary scopes/permissions.<br/>
    - In an OpenID Connect or OAuth 2.0 authorization request, an app can request the permissions it needs by using the 
    scope query parameter.
    - Some high-privilege permissions in Microsoft resources can be set to admin-restricted. So, if we want to access 
    such kind of resources, an organization's administrator must consent to those scopes on behalf of the organization's 
    users.
    
        ![Obtaining Credentials Step 3](docs/images/s4.png)

    **Step 4:** Obtain the authorization endpoint and token endpoint by opening the `Endpoints` tab in the application 
    overview. <br/>
    - The **OAuth 2.0 token endpoint (v2)** can be used as the value for `<MS_REFRESH_URL>`

        ![Obtaining Credentials Step 4](docs/images/s5.png)

    - In a new browser, enter the below URL by replacing the <MS_CLIENT_ID> with the application ID.

        ```
        https://login.microsoftonline.com/<TENENT_ID>/oauth2/v2.0/authorize?client_id=<MS_CLIENT_ID>&response_type=code&redirect_uri=https://oauth.pstmn.io/v1/browser-callback&response_mode=query&scope=openid offline_access <SPACE_SEPERATED_LIST_OF_SCOPES>
        ```
    
    - This will prompt you to enter the username and password for sign in to the Azure Portal App.
    - Once the username and password pair has successfully entered, this will give a URL as follows on the browser address 
    bar.
        ```
        https://login.microsoftonline.com/<TENENT_ID>/oauth2/nativeclient?code=M95780001-0fb3-d138-6aa2-0be59d402f32
        ```
    - Copy the code parameter (M95780001-0fb3-d138-6aa2-0be59d402f32 in the above example). In a new terminal, enter 
    the following cURL command by replacing the <MS_CODE> with the code received from the above step. The <MS_CLIENT_ID> 
    and <MS_CLIENT_SECRET> parameters are the same as above.
        ```
        curl -X POST --header "Content-Type: application/x-www-form-urlencoded" --header "Host:login.microsoftonline.com" -d "client_id=<MS_CLIENT_ID>&client_secret=<MS_CLIENT_SECRET>&grant_type=authorization_code&redirect_uri=https://login.microsoftonline.com/<TENENT_ID>/oauth2/nativeclient&code=<MS_CODE>&scope=Files.ReadWrite openid User.Read Mail.Send Mail.ReadWrite offline_access" https://login.microsoftonline.com/<TENENT_ID>/oauth2/v2.0/token
        ```
        
    - The above cURL command should result in a response as follows.
        ```
        {
            "token_type": "Bearer",
            "scope": "openid <LIST_OF_PERMISSIONS>",
            "expires_in": 3600,
            "ext_expires_in": 3600,
            "access_token": "<MS_ACCESS_TOKEN>",
            "refresh_token": "<MS_REFRESH_TOKEN>",
            "id_token": "<ID_TOKEN>"
        }
        ```
    **More information about OAuth2 tokens can be found here:** <br/>
    https://docs.microsoft.com/en-us/graph/auth-register-app-v2 <br/>
    https://docs.microsoft.com/en-au/azure/active-directory/develop/active-directory-v2-protocols#endpoints <br/> 
## Add project configurations file
Add the project configuration file by creating a `Config.toml` file under the root path of the project structure.
This file should have following configurations. Add the tokens obtained in the previous steps to the `Config.toml` file.

#### Config.toml
```ballerina
[ballerinax.microsoft.teams]
refreshUrl = <MS_REFRESH_URL>
refreshToken = <MS_REFRESH_TOKEN>
clientId = <MS_CLIENT_ID>
clientSecret = <MS_CLIENT_SECRET>
scopes = [<MS_NECESSARY_SCOPES>]
```
# Supported versions & limitations
## Supported Versions
|                                                                                    | Version               |
|------------------------------------------------------------------------------------|-----------------------|
| Ballerina Language Version                                                         | **Swan Lake Beta 1** |
| [Microsoft Graph API](https://docs.microsoft.com/en-us/graph/overview) Version     | **v1.0**              |
| Java Development Kit (JDK)                                                         | 11                    |

## Limitations
- Only communication related functions are supported for this version

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

string|teams:Error newTeamId = teamsClient->createTeam(info);
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

teams:ChannelData|teams:Error channelInfo = teamsClient->createChannel(teamId, data);
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

teams:MessageData|teams:Error channelMessage = teamsClient->sendChannelMessage(teamId,  channelId, message);    
if (channelMessage is teams:MessageData) {
    log:printInfo("Message ID " + channelMessage.id.toString());
    log:printInfo("Success!");
} else {
    log:printError(channelMessage.message());
}

```
# Samples
## Create a team
Team is a collection of people, content, and tools surrounding different projects and outcomes within an organization. 
Teams do not exist out there in space by itself. It is part of a Microsoft 365 Group (formerly Office 365 Group). 
So when you create a new Team, it creates a Microsoft 365 Group and other assets that are part of the Group 
(SharePoint site, Plan in Planner, Outlook Calendar, etc.)

This sample contains how to create a new team using the connector.
</br> [Sample](/teams/samples/create_team.bal)

**Notes**    
- Teams can create to be private to only invited users.
- Teams can also create to be public and open and anyone within the organization can join (up to 10,000 members).

## Get team info
This operation gets the information about an already existing team. This information mainly contains the properties and 
relationships of the specified team.

This sample contains how to get the data of a team by using its team ID. 
</br> [Sample](/teams/samples/get_team.bal)

## Update team info
This operation will update the properties of the specified team. This sample contains how to update the `Display name` 
of the existing team.
</br> [Sample](/teams/samples/update_team.bal)

## Add team member
This operation will add a conversation member to an already existing team. The users ID and the role will be provided 
along with several other optional parameters. When adding members who are already a part of your team's organization we 
have to provide the role as owner. If the user is not a part of your organization, add them as guests to a team.

This sample shows how to add a user how is already in our organization to a team.
</br> [Sample](/teams/samples/add_member_to_team.bal)

## Delete team
This operation shows how to delete an existing team by its ID.
</br> [Sample](/teams/samples/delete_team.bal)

## Create channel
Every team starts with a General channel. Use this channel as the name implies—to discuss general topics related to the 
team’s purpose. For every other topic ie: Projects—create a new channel. It’s an efficient way to bundle all related 
content into one location. Currently, there’s a limit of 200 channels per team, including deleted channels.

This sample shows how to create a new channel in a team.
</br> [Sample](/teams/samples/create_channel.bal)

## Get channels in a team
Team can comprised of several channels up-to 200 channels. In situations where you want to obtain the channels which 
belong to a specific team this operation comes in handy.

This sample shows how to get a list of channels once the ID of the team is available.
</br> [Sample](/teams/samples/get_channels_in_team.bal)

## Get channel info
There are a bunch of information about a channel you want to obtain and for that this operation comes useful. 
Can be used to retrieve the properties and relationships of a channel.

This sample shows how to obtain information about a channel once the channel ID and the team ID is available.
</br> [Sample](/teams/samples/get_channel.bal)

## Update channel info
From this operation we can update the properties of the specified channel. 
This sample shows how to update the `Display name` and the `Description` of a channel.
</br> [Sample](/teams/samples/update_channel.bal)

**Note** You cannot update the `membershipType` value for an existing channel.

## Add channel member
You can use this operation to add a conversation member to a channel. This sample shows how to add a member as an 
`owner` to a channel.
</br> [Sample](/teams/samples/add_member_to_channel.bal)

**Note** 
- This operation allows only for channels with a `membershipType` value of private.

## List channel members
You can retrieve a list of conversation members from a channel.This sample shows how to get information about members 
in a specific channel.
</br> [Sample](/teams/samples/list_channel_members.bal)

**Note**
- The `membership ID` values in result of this operation should be treated as opaque strings. The client should not 
try to parse or make any assumptions about these resource IDs.
-  The members of channel can map to users of different tenants.

## Remove a channel member
This operation can be used to delete a conversation member from a channel. This sample shows how to delete a member 
from a channel.
</br> [Sample](/teams/samples/delete_channel_member.bal)

**Note**
- This operation allows only for channels with a `membershipType` value of `private`.
- The ID which is used to identify the user is the `membership ID` of the user in that specific channel. It is not the 
object ID of the user from Azure AD.

## Send channel message
Channels are dedicated sections within a team to keep conversations organized by specific topics, projects, disciplines 
etc.This opeartion can be use to send a new message in the specified channel. The user must provide the parameters of 
message body to send a message. 
</br> [Sample](/teams/samples/send_channel_message.bal)

## Send reply to channel message
There are cases where we need to send reply message for a specific message. This operation can be used to send a new 
reply to a message in a specified channel. You need to know the ID of the message wen intend to reply to.
</br> [Sample](/teams/samples/send_reply_channel_message.bal)

## Create chat
There are different ways to start a chat with users. The connector allows to create chats of two different types.
1. A one-on-one chat (so with one other person) 
2. A group chat (so with a few people at once, but outside of a channel)
</br> [Sample](/teams/samples/create_chat.bal)

**Note** 
- To create a new chat, atleast two members should be added to the member array.
- The members who are added to the chat should be provided with the role `owner`.
- Only 200 members at a time can be added to a group chat

## Get chat info
You can use this operation to retrieve information about a single chat (without its messages). The chat infromation will 
contain only the metadata related to the chat such as the `id`, `created date time`, `relationships` and other metadata.
</br> [Sample](/teams/samples/get_chat.bal)

## Update chat info
You can use the following operation to update the properties of a chat. 
</br> [Sample](/teams/samples/update_chat.bal)

**Note** 
- You can update only the topic of the chat with this operation.
## List chat members
There may be instances you wnat to list all conversation members in a chat. This operation can be used for that purpose. 
It will return an array of members in the specified chat. 
</br> [Sample](/teams/samples/list_chat_members.bal)

## Add chat member
This operation can be used to add a conversation member to a chat after the initial creation of the chat.
</br> [Sample](/teams/samples/add_member_to_chat.bal)
## Remove chat member
You can use the following operation to remove a conversation member from a chat.
</br> [Sample](/teams/samples/remove_member_from_chat.bal)

**Note**
- The ID which is used to identify the user is the `membership ID` of the user in that specific chat. It is not the 
object ID of the user from Azure AD.

## Send chat message
Send a new chatMessage in the specified chat. This operation cannot create a new chat; you must use the list chats 
method to retrieve the ID of an existing chat before creating a chat message.
</br> [Sample](/teams/samples/send_chat_message.bal)

**Note**
- The chat size (message size) should be approximately equal to 28KB including the message itself (text, image links, e
tc.), @-mentions, and reactions.

## Get chat/chat message
Retrieve a single message or a message reply in a channel or a chat.
</br> [Sample](#)

### Notes
**For all the above operations [this](https://docs.microsoft.com/en-us/microsoftteams/limits-specifications-teams) limits and specifications apply**

# Building from the Source
## Setting Up the Prerequisites

1. Download and install Java SE Development Kit (JDK) version 11 (from one of the following locations).

   * [Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html)

   * [OpenJDK](https://adoptopenjdk.net/)

        > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed 
        JDK.

2. Download and install [Ballerina SLBeta 1](https://ballerina.io/). 

## Building the Source
Execute the commands below to build from the source after installing Ballerina SL Beta 1 version.

1. To build the library:
```shell script
    bal build
```

2. To build the module without the tests:
```shell script
    ball build --skip-tests
```
# Contributing to Ballerina
As an open source project, Ballerina welcomes contributions from the community. 

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/main/CONTRIBUTING.md).

# Code of Conduct
All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

# Useful Links
* Discuss about code changes of the Ballerina project in [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Slack channel](https://ballerina.io/community/slack/).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
