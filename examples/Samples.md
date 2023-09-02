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
