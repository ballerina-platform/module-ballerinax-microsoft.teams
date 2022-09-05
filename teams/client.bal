// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;

# This is connecting to the Microsoft Graph RESTful web API that enables you to access Microsoft Cloud service resources.
#
# + httpClient - the HTTP Client
@display {
    label: "Microsoft Teams",
    iconPath: "icon.png"
}
public isolated client class Client {
    final http:Client httpClient;
    # Gets invoked to initialize the `connector`.
    # The connector initialization requires setting the API credentials. 
    # Create a [Microsoft 365 Work and School account](https://www.office.com/) 
    # and obtain tokens following [this guide](https://docs.microsoft.com/en-us/graph/auth-register-app-v2). Configure the Access token to 
    # have the [required permission](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-expose-web-apis#add-a-scope).
    #
    # + config - ConnectionConfig required to initialize the `Client` endpoint
    # + return -  Error at failure of client initialization
    public isolated function init(ConnectionConfig config) returns error? { 
        http:ClientConfiguration httpClientConfig = {
            auth: let var authConfig = config.auth in (authConfig is BearerTokenConfig ? authConfig : {...authConfig}),
            httpVersion: config.httpVersion,
            http1Settings: {...config.http1Settings},
            http2Settings: config.http2Settings,
            timeout: config.timeout,
            forwarded: config.forwarded,
            poolConfig: config.poolConfig,
            cache: config.cache,
            compression: config.compression,
            circuitBreaker: config.circuitBreaker,
            retryConfig: config.retryConfig,
            responseLimits: config.responseLimits,
            secureSocket: config.secureSocket,
            proxy: config.proxy,
            validation: config.validation
        };
        self.httpClient = check new (BASE_URL, httpClientConfig);
    }

    // *************************************** Operations on Team resource *********************************************
    // A team in Microsoft Teams is a collection of channel objects.

    # Creates a new team.
    # 
    # + info - The information for creating team
    # + return - A `string` which contains the ID of the team
    @display {label: "Create a Team"}
    remote isolated function createTeam(@display {label: "Team Information"} Team info) returns string|error {
        string path = check createUrl([TEAMS_RESOURCE]);
        return check createTeamResource(self.httpClient, path, info);
    }

    # Creates a new team from existing Azure AD group. 
    # - In order to create a team, the group must have a least one owner.
    # 
    # + groupId - The Azure AD group ID
    # + info - The information for creating team
    # + return - A `string` which contains the ID of the team
    @display {label: "Create a Team from Azure AD group"}
    remote isolated function createTeamFromGroup(@display {label: "Azure AD Group ID"} string groupId, 
                                                 @display {label: "Team Information"} Team? info = ()) 
                                                 returns string|error {
        string path = check createUrl([GROUPS_RESOURCE, groupId, TEAM_RESOURCE]);
        return check createTeamResourceFromGroup(self.httpClient, path, info);
    }

    # Retrieves the properties and relationships of the specified team.
    # 
    # + teamId - The ID of the team
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A record `teams:TeamData` if success. Else `error`
    @display {label: "Get Team Info"}
    remote isolated function getTeam(@display {label: "Team ID"} string teamId, 
                                     @display {label: "Query Parameters"} string? queryParams = ())
                                     returns TeamData|error {
        string path = check createUrl([TEAMS_RESOURCE,teamId], queryParams);
        return check self.httpClient->get(path, targetType = TeamData);
    }

    # Updates the properties of the specified team.
    # 
    # + teamId - The ID of the team    
    # + info - The information to update the team
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Update Team Info"}
    remote isolated function updateTeam(@display {label: "Team ID"} string teamId, 
                                        @display {label: "Team Information"} Team info) 
                                        returns error? {
        string path = check createUrl([TEAMS_RESOURCE,teamId]);
        return check updateTeamResource(self.httpClient, path, info);
    }

    # Adds a new member to a team.
    # 
    # + teamId - The ID of the team
    # + info - The information of the new member
    # + return - A record `teams:Member` if success. Else `error`
    @display {label: "Add Member To a Team"}
    remote isolated function addMemberToTeam(@display {label: "Team ID"} string teamId, 
                                             @display {label: "Member Information"} Member info) 
                                             returns MemberData|error {
        string path = check createUrl([TEAMS_RESOURCE,teamId, MEMBERS_RESOURCE]);
        return check addMemberToTeamResource(self.httpClient, path, info);
    }

    # Deletes a group.
    # 
    # + teamId - The ID of the team
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Delete Team"}
    remote isolated function deleteTeam(@display {label: "Team ID"} string teamId) returns error? {
        string path = check createUrl([GROUPS_RESOURCE,teamId]);
        return check deleteTeamResource(self.httpClient, path);
    }
 
    // *************************************** Operations on Channels resource *****************************************
    // Teams are made up of channels, which are the conversations you have with your teammates

    # Retrieves the list of channels in a team.
    # 
    # + teamId - The ID of the team
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - An array of `teams:Channel` if success. Else `error`
    @display {label: "Get Channels in Team"}
    remote isolated function getChannelsInTeam(@display {label: "Team ID"} string teamId, 
                                               @display {label: "Query Parameters"} string? queryParams = ()) 
                                               returns ChannelData[]|error {
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE], queryParams);
        return check getChannelResources(self.httpClient, path);
    }

    # Creates a new channel.
    # 
    # + teamId - The ID of the team
    # + info - The information for the new channel
    # + return - A record `teams:Channel` if success. Else `error`
    @display {label: "Create Channel"}
    remote isolated function createChannel(@display {label: "Team ID"} string teamId, 
                                           @display {label: "Channel Information"} Channel info) 
                                           returns ChannelData|error {
        string path = check createUrl([TEAMS_RESOURCE, teamId, CHANNELS_RESOURCE]);
        return check createChannelResource(self.httpClient, path, info);
    }

    # Gets a channel.
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + queryParams - Optional query parameters
    #               - This method support OData query parameters to customize the response. It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #               - For more information about query parameters, [visit](https://docs.microsoft.com/en-us/graph/query-parameters).
    # + return - A record `teams:Channel` if success. Else `error`
    @display {label: "Get Channel"}
    remote isolated function getChannel(@display {label: "Team ID"} string teamId, 
                                        @display {label: "Channel ID"} string channelId, 
                                        @display {label: "Query Parameters"} string? queryParams = ()) 
                                        returns ChannelData|error {
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE, channelId], queryParams);
        return check self.httpClient->get(path, targetType = ChannelData);
    }

    # Updates a channel.
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + info - The information to update the channel
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Update Channel"}
    remote isolated function updateChannel(@display {label: "Team ID"} string teamId, 
                                           @display {label: "Channel ID"} string channelId,
                                           @display {label: "Channel Information"} Channel info) returns error? {
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE, channelId]);
        return check updateChannelResource(self.httpClient, path, info);
    }

    # Adds a new member to channel.
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + userId - The ID of the user to add to the channel
    # + role - The role for the user. Must be `owner` or empty.
    # + return - A record `teams:MemberData` if success. Else `error`
    @display {label: "Add Member To a Channel"}
    remote isolated function addMemberToChannel(@display {label: "Team ID"} string teamId, 
                                                @display {label: "Channel ID"} string channelId, 
                                                @display {label: "User ID"} string userId, 
                                                @display {label: "Role of the user"} string role) 
                                                returns MemberData|error {
        string path = check createUrl([TEAMS_RESOURCE, teamId, CHANNELS_RESOURCE, channelId, MEMBERS_RESOURCE]);
        return check addChannelMember(self.httpClient, path, userId, role);
    }


    # Retrieves a list of members from a channel.
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + return - An array of `teams:Member` if success. Else `error`
    @display {label: "List Channel Members"}
    remote isolated function listChannelMembers(@display {label: "Team ID"} string teamId, 
                                                @display {label: "Channel ID"} string channelId) 
                                                returns MemberData[]|error {
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE, channelId, MEMBERS_RESOURCE]);
        return check listChannelMembersResource(self.httpClient, path);
    }

    # Deletes a member from a channel. 
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + membershipId - Membership ID of the member
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Delete Channel Member"}
    remote isolated function deleteChannelMember(@display {label: "Team ID"} string teamId, 
                                                 @display {label: "Channel ID"} string channelId, 
                                                 @display {label: "Membership ID"} string membershipId) returns error? { 
        // This operation is allowed only for channels with a membershipType value of private.
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE, channelId, MEMBERS_RESOURCE, 
            membershipId]);
        return check deleteChannelMemberResource(self.httpClient, path);
    }

    # Sends a new message in the specified channel.
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + body - The information to send in the message 
    # + return - A record `teams:Message` if success. Else `error`
    @display {label: "Send Channel Message"}
    remote isolated function sendChannelMessage(@display {label: "Team ID"} string teamId, 
                                                @display {label: "Channel ID"} string channelId, 
                                                @display {label: "Message Content"} Message body) returns 
                                                MessageData|error {
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE, channelId, MESSAGES_RESOURCE]);
        return check sendMessageToChannel(self.httpClient, path, body);
    }

    # Sends a reply message to a message in a specified channel.
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + messageId - The ID of the message
    # + reply - The information to send in the reply 
    # + return - A record `teams:Message` if success. Else `error`
    @display {label: "Send Reply to Channel Message"}
    remote isolated function sendReplyMessage(@display {label: "Team ID"} string teamId, 
                                              @display {label: "Channel ID"} string channelId, 
                                              @display {label: "Message ID"} string messageId, 
                                              @display {label: "Reply Meaage Content"} Message reply) 
                                              returns MessageData|error {
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE, channelId, MESSAGES_RESOURCE, 
            messageId, REPLIES_RESOURCE]);
        return check sendReplyToChannel(self.httpClient, path, reply);
    }

    # Deletes a group.
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Delete Channel"}
    remote isolated function deleteChannel(@display {label: "Team ID"} string teamId, 
                                           @display {label: "Channel ID"} string channelId) returns error? {
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE, channelId]);
        return check deleteChannelResource(self.httpClient, path);
    }

    // *************************************** Operations on Chat resource *********************************************
    // A chat is a collection of chatMessages between one or more participants. Participants can be users or apps.}

    # Creates a new chat.
    # 
    # + info - The information for the new chat
    # + return - A record `teams:Chat` if success. Else `error`
    @display {label: "Create Chat"}
    remote isolated function createChat(@display {label: "Chat Information"} Chat info) returns 
                                        ChatData|error {
        string path = check createUrl([CHATS_RESOURCE]);
        return check createChatResource(self.httpClient, path, info);
    }

    # Retrieves a single chat (without its messages).
    # 
    # + chatId - The ID of the chat
    # + return - A record `teams:Chat` if success. Else `error`
    @display {label: "Get Chat"}
    remote isolated function getChat(@display {label: "Chat ID"} string chatId) returns ChatData|error {
        string path = check createUrl([CHATS_RESOURCE, chatId]);
        return check self.httpClient->get(path, targetType = ChatData);
    }

    # Updates the properties of a chat object.
    # 
    # + chatId - The ID of the chat
    # + topic - The new topic for the chat
    # + return - A record `teams:Chat` if success. Else `error`
    @display {label: "Update Chat"}
    remote isolated function updateChat(@display {label: "Chat ID"}  string chatId, 
                                        @display {label: "New Topic"}  string topic) returns ChatData|error {
        string path = check createUrl([CHATS_RESOURCE, chatId]);
        return check self.httpClient->patch(path, {topic: topic}, targetType = ChatData);
    }

    # Lists all conversation members in a chat.
    # 
    # + chatId - The ID of the chat
    # + return - An array of `teams:MemberData` if success. Else `error`
    @display {label: "List Chat Members"}
    remote isolated function listChatMembers(@display {label: "Chat ID"} string chatId) returns MemberData[]|error {
        string path = check createUrl([CHATS_RESOURCE, chatId, MEMBERS_RESOURCE]);
        return check lisChatResourceMembers(self.httpClient, path);
    }

    # Adds a new member to a chat.
    # 
    # + chatId - The ID of the chat
    # + data - The data of the new member
    # + return - A record `teams:MemberData` if success. Else `error`
    @display {label: "Add Member To a Chat"}
    remote isolated function addMemberToChat(@display {label: "Chat ID"} string chatId, 
                                             @display {label: "Member Data"} Member data) returns MemberData|error {
        string path = check createUrl([CHATS_RESOURCE, chatId, MEMBERS_RESOURCE]);
        return check addMemberToChatResource(self.httpClient, path, data);
    }

    # Removes a member from a chat.
    # 
    # + chatId - The ID of the chat
    # + membershipId - Membership ID of the member
    # + return - `error` if the operation fails or `()` if nothing is to be returned
    @display {label: "Remove Member From a Chat"}
    remote isolated function removeMemberFromChat(@display {label: "Chat ID"} string chatId, 
                                                  @display {label: "Membership ID"} string membershipId) 
                                                  returns error? {
        string path = check createUrl([CHATS_RESOURCE, chatId, MEMBERS_RESOURCE, membershipId]);
        return check deleteMemberFromChatResource(self.httpClient, path);
    }

    # Sends a new message in the specified chat.
    # 
    # + chatId - The ID of the chat
    # + body - The information to send in the message 
    # + return - A record `teams:Message` if success. Else `error`
    @display {label: "Send Chat Message"}
    remote isolated function sendChatMessage(@display {label: "Chat ID"} string chatId, 
                                             @display {label: "Message Body"} Message body) returns MessageData|error {
        string path = check createUrl([CHATS_RESOURCE, chatId, MESSAGES_RESOURCE]);
        return check sendMessageToChatResource(self.httpClient, path, body);
    }

    # Retrieves a single message or a message reply in a chat.
    # 
    # + chatId - The ID of the chat
    # + messageId - ID of the message
    # + return - An array of `teams:Message` if success. Else `error`
    @display {label: "Get Chat Message"}
    remote isolated function getChatMessage(@display {label: "Chat ID"} string chatId, 
                                            @display {label: "Message ID"} string messageId) returns 
                                            MessageData[]|error {
        string path = check createUrl([CHATS_RESOURCE, chatId, MESSAGES_RESOURCE, messageId]);
        return check getMessagesFromChatResource(self.httpClient, path);
    }
}
