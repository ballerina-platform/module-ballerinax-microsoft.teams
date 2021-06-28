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

# Represents configuration parameters to create Microsoft Teams client.
#
# + clientConfig - OAuth client configuration
# + secureSocketConfig - SSH configuration
@display{label: "Connection config"}
public type Configuration record {|
    http:BearerTokenConfig|http:OAuth2RefreshTokenGrantConfig clientConfig;
    http:ClientSecureSocket secureSocketConfig?;
|};

# A collection of channel objects. A channel represents a topic, and therefore a logical isolation of discussion, 
# within a team.
#
# + displayName - The name of the team
# + description - An optional description for the team. Maximum length: 1024 characters.  
# + classification - Describes the data or business sensitivity of the team
# + specialization - Indicates whether the team is intended for a particular use case 
# + visibility - The visibility of the group and team 
# + funSettings - Settings to configure use of Giphy, memes, and stickers in the team 
# + guestSettings - Settings to configure whether guests can create, update, or delete channels in the team  
# + memberSettings - A unique ID for the team that has been used in a few places such as the audit log
# + messagingSettings - Settings to configure messaging and mentions in the team  
# + isArchived - Whether this team is in read-only mode  
public type Team record {|
    string displayName?;
    string description?; //validate
    string? classification?;
    TeamSpecialization specialization?;
    TeamVisibility visibility?;
    TeamFunSettings funSettings?;
    TeamGuestSettings guestSettings?;
    TeamMemberSettings memberSettings?;
    TeamMessagingSettings messagingSettings?;
    boolean isArchived?;
|};

# Settings to configure use of Giphy, memes, and stickers in the team
#
# + allowGiphy - If set to true, enables Giphy use
# + giphyContentRating - Giphy content rating. Possible values are: `moderate`, `strict`
# + allowStickersAndMemes - If set to true, enables users to include stickers and memes
# + allowCustomMemes - If set to true, enables users to include custom memes  
public type TeamFunSettings record {|
    boolean allowGiphy?;
    GiphyContentRating giphyContentRating?;
    boolean allowStickersAndMemes?;
    boolean allowCustomMemes?;
|};

# Settings to configure whether guests can create, update, or delete channels in the team.
#
# + allowCreateUpdateChannels - If set to true, guests can add and update channels
# + allowDeleteChannels - If set to true, guests can delete channels 
public type TeamGuestSettings record {|
    boolean allowCreateUpdateChannels?;
    boolean allowDeleteChannels?;
|};

# Settings to configure whether members can perform certain actions, for example, create channels and add bots, in the 
# team.
#
# + allowCreatePrivateChannels - If set to true, members can add and update private channels  
# + allowAddRemoveApps - f set to true, members can add and remove apps  
# + allowCreateUpdateRemoveTabs - If set to true, members can add, update, and remove tabs 
# + allowCreateUpdateRemoveConnectors - If set to true, members can add, update, and remove connectors
public type TeamMemberSettings record {|
    *TeamGuestSettings;
    boolean allowCreatePrivateChannels?;
    boolean allowAddRemoveApps?;
    boolean allowCreateUpdateRemoveTabs?;
    boolean allowCreateUpdateRemoveConnectors?;
|};

# Settings to configure messaging and mentions in the team.
#
# + allowUserEditMessages - If set to true, users can edit their messages 
# + allowUserDeleteMessages - If set to true, users can delete their messages
# + allowOwnerDeleteMessages - If set to true, owners can delete any message
# + allowTeamMentions - If set to true, @team mentions are allowed 
# + allowChannelMentions - If set to true, @channel mentions are allowed  
public type TeamMessagingSettings record {|
    boolean allowUserEditMessages?;
    boolean allowUserDeleteMessages?;
    boolean allowOwnerDeleteMessages?;
    boolean allowTeamMentions?;
    boolean allowChannelMentions?;
|};

# The readonly data for the team
#
# + id - ID of the team  
# + webUrl - A hyperlink that will go to the team in the Microsoft Teams client 
# + createdDateTime -  	Timestamp at which the team was created
# + internalId - The internal ID of the team
# + operations - The async operations that ran or are running on this team
public type TeamData record {
    *Team;
    string id;
    string webUrl;
    string createdDateTime;
    string internalId?;
    // Relationships
    TeamsAsyncOperation[] operations?;
    // Instance attributes
};

# Information about an operation that transcends the lifetime of a single API request.
#
# + id - Unique operation ID  
# + operationType - Denotes which type of operation is being described  
# + createdDateTime - Time when the operation was created  
# + status - Operation status 
# + lastActionDateTime - Time when the async operation was last updated
# + attemptsCount - Number of times the operation was attempted before being marked successful or failed 
# + targetResourceId - The ID of the object that's created or modified as result of this async operation, typically a 
#                      team  
# + targetResourceLocation - The location of the object that's created or modified as result of this async operation
public type TeamsAsyncOperation record {
    string id;
    string operationType;
    string createdDateTime;
    string status;
    string lastActionDateTime;
    int attemptsCount;
    string targetResourceId;
    string targetResourceLocation;
};

# Represents a user in a team, a channel, or a chat.
#
# + roles - The roles for the user 
# + visibleHistoryStartDateTime - The timestamp denoting how far back a conversation's history is shared with the 
#                                 conversation member
# + email - The email address of the user
# + displayName - The display name of the user
# + userId - The guid of the user
public type Member record {|
    string[] roles; // make an enum
    string? visibleHistoryStartDateTime?;
    string? email?;
    string displayName?;
    string userId;
|};

# Represents readonly data for a user in a team, a channel, or a chat.
#
# + id - Unique ID of the user 
# + tenantId - TenantId which the Azure AD user belongs to 
public type MemberData record {
    *Member;
    string id;
    string tenantId?;
};

# Teams are made up of channels, which are the conversations you have with your teammates. Each channel is dedicated to 
# a specific topic, department, or project. 
#
# + description - Optional textual description for the channel
# + displayName - Channel name as it will appear to the user in Microsoft Teams
# + isFavoriteByDefault - Indicates whether the channel should automatically be marked 'favorite' for all members of the 
#                         team  
# + membershipType - The type of the channel Possible values are: 
#                    `standard` - Channel inherits the list of members of the parent team
#                    `private` - Channel can have members that are a subset of all the members on the parent team
public type Channel record {|
    string? description?;
    string displayName;
    boolean? isFavoriteByDefault?;
    ChannelMemberhipType membershipType?;
|};

# Description
#
# + id - The channel ID 
# + email - The email address for sending messages to the channel  
# + webUrl - A hyperlink that will go to the channel in Microsoft Teams
# + createdDateTime - Timestamp at which the channel was created 
public type ChannelData record {
    *Channel;
    string id;
    string email;
    string webUrl;
    string createdDateTime;
};

# Represents an individual chat message within a channel or chat.
#
# + body - Plaintext/HTML representation of the content of the chat message  
# + subject - The subject of the chat message, in plaintext  
# + importance - The importance of the chat message. The possible values are: `normal`, `high`, `urgent`  
# + mentions - List of entities mentioned in the chat message. Currently supports user, bot, team, channel.  

public type Message record {|
    ItemBody body;
    string? subject?;
    MessageImportance importance?;
    MessageMention[] mentions?;
|};

# Represents properties of the body of an item, such as a message, event or group post
#
# + content -  	The content of the item 
# + contentType - The type of the content. Possible values are `text` and `html`  
public type ItemBody record {|
    string content;
    MessageContentType contentType?;
|};

# Represents a mention in a chatMessage entity. The mention can be to a user, team, bot, or channel.
#
# + id - Index of an entity being mentioned in the specified Message
# + mentionText - String used to represent the mention. For example, a user's display name, a team name  
# + mentioned - The entity (user, application, team, or channel) that was mentioned  
public type MessageMention record {|
    int:Unsigned32 id?;
    string mentionText;
    IdentitySet mentioned;
|};

# Represents a reaction to a chatMessage entity
#
# + createdDateTime - The Timestamp type represents date and time information using ISO 8601 format and is always in UTC 
#                     time. eg: `midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z`
# + reactionType - Supported values are `like`, `angry`, `sad`, `laugh`, `heart`, `surprised` 
# + user - The user who reacted to the message 
public type MessageReaction record {|
    string createdDateTime;
    string reactionType;//enum
    IdentitySet user;
|};

# represent a set of identities associated with various events for an item.
#
# + application - The application associated with this action
# + device - The device associated with this action 
# + user - The user associated with this action 
public type IdentitySet record {
    //one more field conversation is there
    Identity? application?;
    Identity? device?;
    Identity user;
};

# Represents an identity of a user, device, or application. 
#
# + displayName - The identity's display name
# + id - Unique identifier for the identity
public type Identity record {
    string id;
    string? displayName?;
};

# Represents an individual chat message within a channel or chat.
#
# + id - Message ID
# + etag - Version number of the chat message 
# + replyToId -  Id of the parent chat message or root chat message of the thread  
# + lastModifiedDateTime - Timestamp when the chat message is created (initial setting) or modified, including when a 
#                          reaction is added or removed.
# + createdDateTime - Timestamp of when the chat message was created  
# + lastEditedDateTime - Timestamp when edits to the chat message were made. Triggers an "Edited" flag in the Teams UI. 
#                        If no edits are made the value is null.
# + deletedDateTime - Timestamp at which the chat message was deleted, or null if not deleted  
# + chatId - If the message was sent in a chat, represents the identity of the chat 
# + webUrl - Link to the message in Microsoft Teams
# + policyViolation - Defines the properties of a policy violation set by a data loss prevention (DLP) application
# + channelIdentity - If the message was sent in a channel, represents identity of the channel
# + messageType - The type of chat message  
# + summary - Summary text of the chat message that could be used for push notifications and summary views or fall back 
#             views  
# + locale - Locale of the chat message set by the client. Always set to en-us.  
# + 'from - Details of the sender of the chat message  
# + reactions - Collection 	Reactions for this chat message (for example, Like)  
public type MessageData record {
    string id;
    string etag;
    string? replyToId;
    string lastModifiedDateTime;
    string createdDateTime;
    string? lastEditedDateTime;
    string? deletedDateTime;
    *Message;
    string? chatId; //check this in channels
    string? webUrl;
    MessagePolicyViolation? policyViolation;
    ChannelIdentity? channelIdentity;
    string messageType;
    string? summary?;
    string locale;
    IdentitySet 'from?; 
    MessageReaction[] reactions?;
};

# Contains basic identification information about a channel in Microsoft Teams
#
# + teamId - The identity of the channel in which the message was posted  
# + channelId - The identity of the team in which the message was posted
public type ChannelIdentity record {
    string teamId;
    string channelId;
};

# Represents a policy violation on a chat message.
#
# + dlpAction - The action taken by the DLP provider on the message with sensitive content
# + justificationText -Justification text provided by the sender of the message when overriding a policy violation
# + policyTip - Information to display to the message sender about why the message was flagged as a violation
# + userAction - Indicates the action taken by the user on a message blocked by the DLP provider
# + verdictDetails - Indicates what actions the sender may take in response to the policy violation
public type MessagePolicyViolation record {
    string dlpAction; //enum
    string justificationText;
    PolicyTip? policyTip;
    string userAction; //enum
    string verdictDetails; //enum
};

# Represents the properties of a policy tip on a `MessagePolicyViolation` object.Policy tips provide the sender with 
# information about the policy violation.
#
# + complianceUrl - The URL a user can visit to read about the data loss prevention policies for the organization
# + generalText - Explanatory text shown to the sender of the message
# + matchedConditionDescriptions - The list of improper data in the message that was detected by the data loss 
#                                  prevention app
public type PolicyTip record {
    string? complianceUrl;
    string? generalText;    
    string[]? matchedConditionDescriptions;
};

# A chat is a collection of chatMessages between one or more participants. Participants can be users or apps.
#
# + chatType - Specifies the type of chat `oneOnOne` or `group`
# + members - List of conversation members that should be added. Every single user, including the user initiating the 
#             create request, who will participate in the chat must be specified in this list.
# + topic - Subject or topic for the chat. (Only available for group chats)
public type Chat record {|
    ChatType chatType;
    Member[] members;
    string? topic?;
|};

# The readonly data for a chat. 
#
# + id - Chat ID 
# + topic - Subject or topic for the chat. (Only available for group chats)
# + chatType - Specifies the type of chat
# + createdDateTime - Date and time at which the chat was created
# + lastUpdatedDateTime - Date and time at which the chat was renamed or list of members were last changed
# + members - The list of members in the conversation  
public type ChatData record {
    string id;
    string? topic;
    ChatType chatType;    
    string createdDateTime;
    string? lastUpdatedDateTime;
    Member[] members?;
};
