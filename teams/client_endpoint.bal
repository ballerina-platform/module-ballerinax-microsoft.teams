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

# Teams Client Object for executing drive operations.
#
# + httpClient - the HTTP Client
@display {
    label: "Microsoft Teams Client",
    iconPath: "MSTeamsLogo.svg"
}
public client class Client {
    http:Client httpClient;

    public isolated function init(Configuration config) returns error? {
        http:BearerTokenConfig|http:OAuth2RefreshTokenGrantConfig clientConfig = config.clientConfig;
        http:ClientSecureSocket? socketConfig = config?.secureSocketConfig;
        self.httpClient = check new (BASE_URL, {
            auth: clientConfig,
            secureSocket: socketConfig
        });
    }

    // *************************************** Operations on Team resource *********************************************
    // A team in Microsoft Teams is a collection of channel objects.

    # Create a new team.
    # 
    # + info - The information for creating team
    # + return - A `string` which contains the ID of the team
    @display {label: "Create a Team"}
    remote isolated function createTeam(@display {label: "Team Information"} Team info) returns string|Error {
        string path = check createUrl([TEAMS_RESOURCE]);
        return check createTeamResource(self.httpClient, path, info);
    }

    # Create a new from Azure AD group. **Note** In order to create a team, the group must have a least one owner.
    # 
    # + groupId - The Azure AD group ID
    # + info - The information for creating team
    # + return - A `string` which contains the ID of the team
    @display {label: "Create a Team from Azure AD group"}
    remote isolated function createTeamFromGroup(@display {label: "Azure AD Group ID"} string groupId, 
                                        @display {label: "Team Information"} Team? info = ()) returns string|Error {
        string path = check createUrl([GROUPS_RESOURCE, groupId, TEAM_RESOURCE]);
        return check createTeamResourceFromGroup(self.httpClient, path, info);
    }

    # Retrieve the properties and relationships of the specified team.
    # 
    # + teamId - The ID of the team
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A record of type `TeamData` if success. Else `Error`
    @display {label: "Get Team Info"}
    remote isolated function getTeam(@display {label: "Team ID"} string teamId, 
                                     @display {label: "Query Parameters"} string[] queryParams = []) 
                                     returns TeamData|Error {
        string path = check createUrl([TEAMS_RESOURCE,teamId], queryParams);
        return check getTeamResource(self.httpClient, path);
    }

    # Update the properties of the specified team.
    # 
    # + teamId - The ID of the team    
    # + info - The information to update the team
    # + return - `Error` if the operation fails
    @display {label: "Update Team Info"}
    remote isolated function updateTeam(@display {label: "Team ID"} string teamId, 
                                        @display {label: "Team Information"} Team info) 
                                        returns Error? {
        string path = check createUrl([TEAMS_RESOURCE,teamId]);
        return check updateTeamResource(self.httpClient, path, info);
    }

    # Add a new member to a team.
    # 
    # + teamId - The ID of the team
    # + info - The information of the new member
    # + return - A record of type `Member` if success. Else `Error`
    @display {label: "Add Member To a Team"}
    remote isolated function addMemberToTeam(@display {label: "Team ID"} string teamId, 
                                             @display {label: "Member Information"} Member info) 
                                             returns MemberData|Error {
        string path = check createUrl([TEAMS_RESOURCE,teamId, MEMBERS_RESOURCE]);
        return check addMemberToTeamResource(self.httpClient, path, info);
    }

    # Delete group.
    # 
    # + teamId - The ID of the team
    # + return - `Error` if the operation fails
    @display {label: "Delete Team"}
    remote isolated function deleteTeam(@display {label: "Team ID"} string teamId) returns Error? {
        string path = check createUrl([GROUPS_RESOURCE,teamId]);
        return check deleteTeamResource(self.httpClient, path);
    }
 
    // *************************************** Operations on Channels resource *****************************************
    // Teams are made up of channels, which are the conversations you have with your teammates

    # Retrieve the list of channels in a team.
    # 
    # + teamId - The ID of the team
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - An array of type `Channel` if success. Else `Error`
    @display {label: "Get Channels in Team"}
    remote isolated function getChannelsInTeam(@display {label: "Team ID"} string teamId, 
                                               @display {label: "Query Parameters"} string[] queryParams = []) 
                                               returns ChannelData[]|Error {
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE], queryParams);
        return check getChannelResources(self.httpClient, path);
    }

    # Create a new channel in a team.
    # 
    # + teamId - The ID of the team
    # + info - The information for the new channel
    # + return - A record of type `Channel` if success. Else `Error`
    @display {label: "Create Channel"}
    remote isolated function createChannel(@display {label: "Team ID"} string teamId, 
                                           @display {label: "Channel Information"} Channel info) 
                                           returns ChannelData|Error {
        string path = check createUrl([TEAMS_RESOURCE, teamId, CHANNELS_RESOURCE]);
        return check createChannelResource(self.httpClient, path, info);
    }

    # Create a new channel in a team.
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + queryParams - Optional query parameters. This method support OData query parameters to customize the response.
    #                 It should be an array of type `string` in the format `<QUERY_PARAMETER_NAME>=<PARAMETER_VALUE>`
    #                 **Note:** For more information about query parameters, refer here: 
    #                   https://docs.microsoft.com/en-us/graph/query-parameters
    # + return - A record of type `Channel` if success. Else `Error`
    @display {label: "Get Channel"}
    remote isolated function getChannel(@display {label: "Team ID"} string teamId, 
                                        @display {label: "Channel ID"} string channelId, 
                                        @display {label: "Query Parameters"} string[] queryParams = []) 
                                        returns ChannelData|Error {
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE, channelId], queryParams);
        return check getChannelResource(self.httpClient, path);
    }

    # Create a new channel in a team.
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + info - The information to update the channel
    # + return - `Error` if the operation fails
    @display {label: "Update Channel"}
    remote isolated function updateChannel(@display {label: "Team ID"} string teamId, 
                                           @display {label: "Channel ID"} string channelId,
                                           @display {label: "Channel Information"} Channel info) returns Error? {
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE, channelId]);
        return check updateChannelResource(self.httpClient, path, info);
    }

    # Create a new channel in a team.
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + userId - The ID of the user to add to the channel
    # + role - The role for the user. Must be `owner` or empty.
    # + return - A record of type `MemberData` if success. Else `Error`
    @display {label: "Add Member To a Channel"}
    remote isolated function addMemberToChannel(@display {label: "Team ID"} string teamId, 
                                                @display {label: "Channel ID"} string channelId, 
                                                @display {label: "User ID"} string userId, 
                                                @display {label: "Role of the user"} string role) 
                                                returns MemberData|Error {
        string path = check createUrl([TEAMS_RESOURCE, teamId, CHANNELS_RESOURCE, channelId, MEMBERS_RESOURCE]);
        return check addChannelMember(self.httpClient, path, userId, role);
    }


    # Retrieve a list of members from a channel.
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + return - An array of type `Member` if success. Else `Error`
    @display {label: "List Channel Members"}
    remote isolated function listChannelMembers(@display {label: "Team ID"} string teamId, 
                                                @display {label: "Channel ID"} string channelId) 
                                                returns MemberData[]|Error {
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE, channelId, MEMBERS_RESOURCE]);
        return check listChannelMembersResource(self.httpClient, path);
    }

    # Delete a member from a channel. 
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + membershipId - Membership ID of the member
    # + return - `Error` if the operation fails
    @display {label: "Delete Channel Member"}
    remote isolated function deleteChannelMember(@display {label: "Team ID"} string teamId, 
                                                 @display {label: "Channel ID"} string channelId, 
                                                 @display {label: "Membership ID"} string membershipId) returns Error? { 
        // This operation is allowed only for channels with a membershipType value of private.
        // Make delete operation common
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE, channelId, MEMBERS_RESOURCE, 
            membershipId]);
        return check deleteChannelMemberResource(self.httpClient, path);
    }

    # Send a new message in the specified channel.
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + body - The information to send in the message 
    # + return - A record of type `Message` if success. Else `Error`
    @display {label: "Send Channel Message"}
    remote isolated function sendChannelMessage(@display {label: "Team ID"} string teamId, 
                                                @display {label: "Channel ID"} string channelId, 
                                                @display {label: "Message Content"} Message body) returns 
                                                MessageData|Error {
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE, channelId, MESSAGES_RESOURCE]);
        return check sendMessageToChannel(self.httpClient, path, body);
    }

    # Send a new message in the specified channel.
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + messageId - The ID of the message
    # + reply - The information to send in the reply 
    # + return - A record of type `Message` if success. Else `Error`
    @display {label: "Send Reply to Channel Message"}
    remote isolated function sendReplyMessage(@display {label: "Team ID"} string teamId, 
                                              @display {label: "Channel ID"} string channelId, 
                                              @display {label: "Message ID"} string messageId, 
                                              @display {label: "Reply Meaage Content"} Message reply) 
                                              returns MessageData|Error {
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE, channelId, MESSAGES_RESOURCE, 
            messageId, REPLIES_RESOURCE]);
        return check sendReplyToChannel(self.httpClient, path, reply);
    }

    # Delete group.
    # 
    # + teamId - The ID of the team
    # + channelId - The ID of the channel
    # + return - `Error` if the operation fails
    @display {label: "Delete Channel"}
    remote isolated function deleteChannel(@display {label: "Team ID"} string teamId, 
                                           @display {label: "Channel ID"} string channelId) returns Error? {
        string path = check createUrl([TEAMS_RESOURCE,teamId, CHANNELS_RESOURCE, channelId]);
        return check deleteChannelResource(self.httpClient, path);
    }

    // *************************************** Operations on Chat resource *********************************************
    // A chat is a collection of chatMessages between one or more participants. Participants can be users or apps.}

    # Create a new chat object.
    # 
    # + info - The information for the new chat
    # + return - A record of type `Chat` if success. Else `Error`
    @display {label: "Create Chat"}
    remote isolated function createChat(@display {label: "Chat Information"} Chat info) returns 
                                        ChatData|Error {
        string path = check createUrl([CHATS_RESOURCE]);
        return check createChatResource(self.httpClient, path, info);
    }

    # Retrieve a single chat (without its messages).
    # 
    # + chatId - The ID of the chat
    # + return - A record of type `Chat` if success. Else `Error`
    @display {label: "Get Chat"}
    remote isolated function getChat(@display {label: "Chat ID"} string chatId) returns ChatData|Error {
        string path = check createUrl([CHATS_RESOURCE, chatId]);
        return check getChatResource(self.httpClient, path);
    }

    # Update the properties of a chat object.
    # 
    # + chatId - The ID of the chat
    # + topic - The new topic for the chat
    # + return - A record of type `Chat` if success. Else `Error`
    @display {label: "Update Chat"}
    remote isolated function updateChat(@display {label: "Chat ID"}  string chatId, 
                                        @display {label: "New Topic"}  string topic) returns ChatData|Error {
        string path = check createUrl([CHATS_RESOURCE, chatId]);
        return check updateChatResource(self.httpClient, path, topic);
    }

    # List all conversation members in a chat.
    # 
    # + chatId - The ID of the chat
    # + return - An array of type `MemberData` if success. Else `Error`
    @display {label: "List Chat Members"}
    remote isolated function listChatMembers(@display {label: "Chat ID"} string chatId) returns MemberData[]|Error {
        string path = check createUrl([CHATS_RESOURCE, chatId, MEMBERS_RESOURCE]);
        return check lisChatResourceMembers(self.httpClient, path);
    }

    # Add a new member to a chat.
    # 
    # + chatId - The ID of the chat
    # + data - The data of the new member
    # + return - A record of type `MemberData` if success. Else `Error`
    @display {label: "Add Member To a Chat"}
    remote isolated function addMemberToChat(@display {label: "Chat ID"} string chatId, 
                                             @display {label: "Member Data"} Member data) returns MemberData|Error {
        string path = check createUrl([CHATS_RESOURCE, chatId, MEMBERS_RESOURCE]);
        return check addMemberToChatResource(self.httpClient, path, data);
    }

    # Remove a member from a chat.
    # 
    # + chatId - The ID of the chat
    # + membershipId - Membership ID of the member
    # + return - `Error` if the operation fails
    @display {label: "Remove Member From a Chat"}
    remote isolated function removeMemberFromChat(@display {label: "Chat ID"} string chatId, 
                                                  @display {label: "Membership ID"} string membershipId) 
                                                  returns Error? {
        string path = check createUrl([CHATS_RESOURCE, chatId, MEMBERS_RESOURCE, membershipId]);
        return check deleteMemberFromChatResource(self.httpClient, path);
    }

    # Send a new message in the specified chat.
    # 
    # + chatId - The ID of the chat
    # + body - The information to send in the message 
    # + return - A record of type `Message` if success. Else `Error`
    @display {label: "Send Chat Message"}
    remote isolated function sendChatMessage(@display {label: "Chat ID"} string chatId, 
                                             @display {label: "Message Body"} Message body) returns MessageData|Error {
        string path = check createUrl([CHATS_RESOURCE, chatId, MESSAGES_RESOURCE]);
        return check sendMessageToChatResource(self.httpClient, path, body);
    }

    # Retrieve a single message or a message reply in a chat.
    # 
    # + chatId - The ID of the chat
    # + messageId - ID of the message
    # + return - A record of type `Message` if success. Else `Error`
    @display {label: "Get Chat Message"}
    remote isolated function getChatMessage(@display {label: "Chat ID"} string chatId, 
                                            @display {label: "Message ID"} string messageId) returns 
                                            MessageData|MessageData[]|Error {
        string path = check createUrl([CHATS_RESOURCE, chatId, MESSAGES_RESOURCE, messageId]);
        return check getMessagesFromChatResource(self.httpClient, path);
    }
}
