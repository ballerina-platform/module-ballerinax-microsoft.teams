_Author_: Ballerina \
_Created_: 2026-07-15 \
_Updated_: 2026-07-31 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from Microsoft Teams.
The OpenAPI specification is obtained from the [Microsoft Graph v1.0 OpenAPI metadata](https://github.com/microsoftgraph/msgraph-metadata), filtered to the Microsoft Teams (`/teams`) endpoints (`teams-endpoints.yaml`).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. **Flatten and align the specification** <!-- auto-generated -->
    - Original: The source contract inlines many schemas and does not follow Ballerina naming conventions.
    - Updated: Ran `bal openapi flatten` followed by `bal openapi align` to move inline schemas into `components`, normalise references, and align the contract with Ballerina best practices.
    - Reason: Produces a cleaner, reusable type model and predictable client generation.

2. **Retain the canonical Microsoft Graph base URL** <!-- auto-generated -->
    - Original: `servers[0].url = https://graph.microsoft.com/v1.0`; every path is prefixed with `/teams`.
    - Updated: Base URL left unchanged; the shared `/teams` prefix was **not** folded into the base URL.
    - Reason: `https://graph.microsoft.com/v1.0` is the well-known Microsoft Graph service root and matches the base URL used by the previous connector release. `/teams` is a resource collection (not a version/namespace segment), so moving it would turn `GET /teams` (list teams) into `GET /` and diverge from the standard Graph endpoint layout.

3. **Rewrite operation IDs into idiomatic remote-method names** <!-- auto-generated -->
    - Original: OData-style dotted identifiers, e.g. `teams.team.CreateTeam`, `teams.channels.ListMembers`, `teams.allChannels.GetCount-f86a`, `teams.team.channels.channel.members.add`.
    - Updated: Clean `camelCase` identifiers derived systematically from the HTTP method and resource path. All 186 operation IDs were rewritten; the resulting names are unique and valid Ballerina identifiers. The full mapping is listed at the end of this section.
    - Reason: The dotted IDs generate verbose, redundant method names (e.g. `teamsAllChannelsGetCountF86a`) with non-deterministic hash suffixes. Idiomatic names make the connector API discoverable and readable.

    Naming scheme:
    | Endpoint shape | Verb | Example |
    |---|---|---|
    | `GET` collection | `list<Resources>` | `GET /teams/{teamId}/channels` → `listChannels` |
    | `GET` item | `get<Resource>` | `GET /teams/{teamId}/channels/{channelId}` → `getChannel` |
    | `GET .../$count` | `count<Resources>` | `GET /teams/{teamId}/channels/$count` → `countChannels` |
    | `POST` collection | `create<Resource>` | `POST /teams/{teamId}/channels` → `createChannel` |
    | `PATCH`/`PUT` item | `update<Resource>` | `PATCH /teams/{teamId}` → `updateTeam` |
    | `DELETE` item | `delete<Resource>` | `DELETE /teams/{teamId}` → `deleteTeam` |
    | OData action | `<action><Context>` | `POST .../members/add` → `addChannelMembers`, `POST .../setReaction` → `setReactionChannelMessage` |
    | OData function | `<function><Context>` | `GET .../messages/delta()` → `getChannelMessagesDelta` |

    Nested resources carry their parent context for uniqueness (`listChannelMessageReplies`, `getChannelMessageHostedContentValue`); the `primaryChannel` singleton subtree is distinguished from `channels/{id}` by the `PrimaryChannel` segment (`listPrimaryChannelMembers`). Team-level resources carry no prefix (`listChannels`, `listMembers`, `listTags`).

4. **Rename generated wrapper schemas** <!-- auto-generated -->
    - Original: Anonymous / suffixed schema names produced by flatten + align: `AllMembersAddBody`, `ChatMessageIdSetReactionBody`, `RepliesReplyWithQuoteBody`, `TeamIdSendActivityNotificationBody`, `InlineResponse2XX`, `InlineResponse2XX1`, `InlineResponse2XX1AnyOf2`, `CollectionOfChatMessage`, `CollectionOfChatMessage1`.
    - Updated: Renamed to convention-following names — request bodies to `*Request`, response wrappers to `*Response` / `*CollectionResponse`:

      | Original | Updated |
      |---|---|
      | `AllMembersAddBody` | `AddMembersRequest` |
      | `ChatMessageIdSetReactionBody` | `SetReactionRequest` |
      | `RepliesReplyWithQuoteBody` | `ReplyWithQuoteRequest` |
      | `TeamIdSendActivityNotificationBody` | `SendActivityNotificationRequest` |
      | `InlineResponse2XX` | `ActionResultPartCollectionResponse` |
      | `InlineResponse2XX1` | `ChatMessageResponse` |
      | `InlineResponse2XX1AnyOf2` | `EmptyResponse` |
      | `CollectionOfChatMessage` | `ChatMessageDeltaCollectionResponse` |
      | `CollectionOfChatMessage1` | `ChatMessageCollectionResponse` |
    - Reason: These names surface directly in remote-method signatures (`addChannelMembers(..., AddMembersRequest payload) returns ActionResultPartCollectionResponse|error`); descriptive names improve usability. All `$ref` occurrences were updated accordingly.

<details>
<summary>Full operation ID mapping (186 operations)</summary>

| Method | Path | New operation ID |
|---|---|---|
| `POST` | `/teams` | `createTeam` |
| `DELETE` | `/teams/{teamId}` | `deleteTeam` |
| `GET` | `/teams/{teamId}` | `getTeam` |
| `PATCH` | `/teams/{teamId}` | `updateTeam` |
| `GET` | `/teams/{teamId}/allChannels` | `listAllChannels` |
| `GET` | `/teams/{teamId}/allChannels/$count` | `countAllChannels` |
| `GET` | `/teams/{teamId}/allChannels/{channelId}` | `getAllChannel` |
| `GET` | `/teams/{teamId}/channels` | `listChannels` |
| `POST` | `/teams/{teamId}/channels` | `createChannel` |
| `GET` | `/teams/{teamId}/channels/$count` | `countChannels` |
| `GET` | `/teams/{teamId}/channels/getAllMessages()` | `getAllChannelMessages` |
| `GET` | `/teams/{teamId}/channels/getAllRetainedMessages()` | `getAllRetainedChannelMessages` |
| `DELETE` | `/teams/{teamId}/channels/{channelId}` | `deleteChannel` |
| `GET` | `/teams/{teamId}/channels/{channelId}` | `getChannel` |
| `PATCH` | `/teams/{teamId}/channels/{channelId}` | `updateChannel` |
| `GET` | `/teams/{teamId}/channels/{channelId}/allMembers` | `listChannelAllMembers` |
| `POST` | `/teams/{teamId}/channels/{channelId}/allMembers` | `createChannelAllMember` |
| `GET` | `/teams/{teamId}/channels/{channelId}/allMembers/$count` | `countChannelAllMembers` |
| `POST` | `/teams/{teamId}/channels/{channelId}/allMembers/add` | `addChannelAllMembers` |
| `POST` | `/teams/{teamId}/channels/{channelId}/allMembers/remove` | `removeChannelAllMembers` |
| `DELETE` | `/teams/{teamId}/channels/{channelId}/allMembers/{conversationMemberId}` | `deleteChannelAllMember` |
| `GET` | `/teams/{teamId}/channels/{channelId}/allMembers/{conversationMemberId}` | `getChannelAllMember` |
| `PATCH` | `/teams/{teamId}/channels/{channelId}/allMembers/{conversationMemberId}` | `updateChannelAllMember` |
| `GET` | `/teams/{teamId}/channels/{channelId}/enabledApps` | `listChannelEnabledApps` |
| `GET` | `/teams/{teamId}/channels/{channelId}/enabledApps/$count` | `countChannelEnabledApps` |
| `GET` | `/teams/{teamId}/channels/{channelId}/enabledApps/{teamsAppId}` | `getChannelEnabledApp` |
| `GET` | `/teams/{teamId}/channels/{channelId}/filesFolder` | `getChannelFilesFolder` |
| `DELETE` | `/teams/{teamId}/channels/{channelId}/filesFolder/content` | `deleteChannelFilesFolderContent` |
| `GET` | `/teams/{teamId}/channels/{channelId}/filesFolder/content` | `getChannelFilesFolderContent` |
| `PUT` | `/teams/{teamId}/channels/{channelId}/filesFolder/content` | `updateChannelFilesFolderContent` |
| `GET` | `/teams/{teamId}/channels/{channelId}/members` | `listChannelMembers` |
| `POST` | `/teams/{teamId}/channels/{channelId}/members` | `createChannelMember` |
| `GET` | `/teams/{teamId}/channels/{channelId}/members/$count` | `countChannelMembers` |
| `POST` | `/teams/{teamId}/channels/{channelId}/members/add` | `addChannelMembers` |
| `POST` | `/teams/{teamId}/channels/{channelId}/members/remove` | `removeChannelMembers` |
| `DELETE` | `/teams/{teamId}/channels/{channelId}/members/{conversationMemberId}` | `deleteChannelMember` |
| `GET` | `/teams/{teamId}/channels/{channelId}/members/{conversationMemberId}` | `getChannelMember` |
| `PATCH` | `/teams/{teamId}/channels/{channelId}/members/{conversationMemberId}` | `updateChannelMember` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages` | `listChannelMessages` |
| `POST` | `/teams/{teamId}/channels/{channelId}/messages` | `createChannelMessage` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/$count` | `countChannelMessages` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/delta()` | `getChannelMessagesDelta` |
| `POST` | `/teams/{teamId}/channels/{channelId}/messages/replyWithQuote` | `replyWithQuoteChannelMessages` |
| `DELETE` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}` | `deleteChannelMessage` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}` | `getChannelMessage` |
| `PATCH` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}` | `updateChannelMessage` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/hostedContents` | `listChannelMessageHostedContents` |
| `POST` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/hostedContents` | `createChannelMessageHostedContent` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/hostedContents/$count` | `countChannelMessageHostedContents` |
| `DELETE` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/hostedContents/{chatMessageHostedContentId}` | `deleteChannelMessageHostedContent` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/hostedContents/{chatMessageHostedContentId}` | `getChannelMessageHostedContent` |
| `PATCH` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/hostedContents/{chatMessageHostedContentId}` | `updateChannelMessageHostedContent` |
| `DELETE` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/hostedContents/{chatMessageHostedContentId}/$value` | `deleteChannelMessageHostedContentValue` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/hostedContents/{chatMessageHostedContentId}/$value` | `getChannelMessageHostedContentValue` |
| `PUT` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/hostedContents/{chatMessageHostedContentId}/$value` | `updateChannelMessageHostedContentValue` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies` | `listChannelMessageReplies` |
| `POST` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies` | `createChannelMessageReply` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/$count` | `countChannelMessageReplies` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/delta()` | `getChannelMessageRepliesDelta` |
| `POST` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/replyWithQuote` | `replyWithQuoteChannelMessageReplies` |
| `DELETE` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}` | `deleteChannelMessageReply` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}` | `getChannelMessageReply` |
| `PATCH` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}` | `updateChannelMessageReply` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents` | `listChannelMessageReplyHostedContents` |
| `POST` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents` | `createChannelMessageReplyHostedContent` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents/$count` | `countChannelMessageReplyHostedContents` |
| `DELETE` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents/{chatMessageHostedContentId}` | `deleteChannelMessageReplyHostedContent` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents/{chatMessageHostedContentId}` | `getChannelMessageReplyHostedContent` |
| `PATCH` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents/{chatMessageHostedContentId}` | `updateChannelMessageReplyHostedContent` |
| `DELETE` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents/{chatMessageHostedContentId}/$value` | `deleteChannelMessageReplyHostedContentValue` |
| `GET` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents/{chatMessageHostedContentId}/$value` | `getChannelMessageReplyHostedContentValue` |
| `PUT` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents/{chatMessageHostedContentId}/$value` | `updateChannelMessageReplyHostedContentValue` |
| `POST` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}/setReaction` | `setReactionChannelMessageReply` |
| `POST` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}/softDelete` | `softDeleteChannelMessageReply` |
| `POST` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}/undoSoftDelete` | `undoSoftDeleteChannelMessageReply` |
| `POST` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/replies/{chatMessageId1}/unsetReaction` | `unsetReactionChannelMessageReply` |
| `POST` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/setReaction` | `setReactionChannelMessage` |
| `POST` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/softDelete` | `softDeleteChannelMessage` |
| `POST` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/undoSoftDelete` | `undoSoftDeleteChannelMessage` |
| `POST` | `/teams/{teamId}/channels/{channelId}/messages/{chatMessageId}/unsetReaction` | `unsetReactionChannelMessage` |
| `GET` | `/teams/{teamId}/channels/{channelId}/tabs` | `listChannelTabs` |
| `POST` | `/teams/{teamId}/channels/{channelId}/tabs` | `createChannelTab` |
| `GET` | `/teams/{teamId}/channels/{channelId}/tabs/$count` | `countChannelTabs` |
| `DELETE` | `/teams/{teamId}/channels/{channelId}/tabs/{teamsTabId}` | `deleteChannelTab` |
| `GET` | `/teams/{teamId}/channels/{channelId}/tabs/{teamsTabId}` | `getChannelTab` |
| `PATCH` | `/teams/{teamId}/channels/{channelId}/tabs/{teamsTabId}` | `updateChannelTab` |
| `GET` | `/teams/{teamId}/channels/{channelId}/tabs/{teamsTabId}/teamsApp` | `getChannelTabTeamsApp` |
| `GET` | `/teams/{teamId}/incomingChannels` | `listIncomingChannels` |
| `GET` | `/teams/{teamId}/incomingChannels/$count` | `countIncomingChannels` |
| `GET` | `/teams/{teamId}/incomingChannels/{channelId}` | `getIncomingChannel` |
| `GET` | `/teams/{teamId}/members` | `listMembers` |
| `POST` | `/teams/{teamId}/members` | `createMember` |
| `GET` | `/teams/{teamId}/members/$count` | `countMembers` |
| `POST` | `/teams/{teamId}/members/add` | `addMembers` |
| `POST` | `/teams/{teamId}/members/remove` | `removeMembers` |
| `DELETE` | `/teams/{teamId}/members/{conversationMemberId}` | `deleteMember` |
| `GET` | `/teams/{teamId}/members/{conversationMemberId}` | `getMember` |
| `PATCH` | `/teams/{teamId}/members/{conversationMemberId}` | `updateMember` |
| `DELETE` | `/teams/{teamId}/primaryChannel` | `deletePrimaryChannel` |
| `GET` | `/teams/{teamId}/primaryChannel` | `getPrimaryChannel` |
| `PATCH` | `/teams/{teamId}/primaryChannel` | `updatePrimaryChannel` |
| `GET` | `/teams/{teamId}/primaryChannel/allMembers` | `listPrimaryChannelAllMembers` |
| `POST` | `/teams/{teamId}/primaryChannel/allMembers` | `createPrimaryChannelAllMember` |
| `GET` | `/teams/{teamId}/primaryChannel/allMembers/$count` | `countPrimaryChannelAllMembers` |
| `POST` | `/teams/{teamId}/primaryChannel/allMembers/add` | `addPrimaryChannelAllMembers` |
| `POST` | `/teams/{teamId}/primaryChannel/allMembers/remove` | `removePrimaryChannelAllMembers` |
| `DELETE` | `/teams/{teamId}/primaryChannel/allMembers/{conversationMemberId}` | `deletePrimaryChannelAllMember` |
| `GET` | `/teams/{teamId}/primaryChannel/allMembers/{conversationMemberId}` | `getPrimaryChannelAllMember` |
| `PATCH` | `/teams/{teamId}/primaryChannel/allMembers/{conversationMemberId}` | `updatePrimaryChannelAllMember` |
| `GET` | `/teams/{teamId}/primaryChannel/enabledApps` | `listPrimaryChannelEnabledApps` |
| `GET` | `/teams/{teamId}/primaryChannel/enabledApps/$count` | `countPrimaryChannelEnabledApps` |
| `GET` | `/teams/{teamId}/primaryChannel/enabledApps/{teamsAppId}` | `getPrimaryChannelEnabledApp` |
| `GET` | `/teams/{teamId}/primaryChannel/filesFolder` | `getPrimaryChannelFilesFolder` |
| `DELETE` | `/teams/{teamId}/primaryChannel/filesFolder/content` | `deletePrimaryChannelFilesFolderContent` |
| `GET` | `/teams/{teamId}/primaryChannel/filesFolder/content` | `getPrimaryChannelFilesFolderContent` |
| `PUT` | `/teams/{teamId}/primaryChannel/filesFolder/content` | `updatePrimaryChannelFilesFolderContent` |
| `GET` | `/teams/{teamId}/primaryChannel/members` | `listPrimaryChannelMembers` |
| `POST` | `/teams/{teamId}/primaryChannel/members` | `createPrimaryChannelMember` |
| `GET` | `/teams/{teamId}/primaryChannel/members/$count` | `countPrimaryChannelMembers` |
| `POST` | `/teams/{teamId}/primaryChannel/members/add` | `addPrimaryChannelMembers` |
| `POST` | `/teams/{teamId}/primaryChannel/members/remove` | `removePrimaryChannelMembers` |
| `DELETE` | `/teams/{teamId}/primaryChannel/members/{conversationMemberId}` | `deletePrimaryChannelMember` |
| `GET` | `/teams/{teamId}/primaryChannel/members/{conversationMemberId}` | `getPrimaryChannelMember` |
| `PATCH` | `/teams/{teamId}/primaryChannel/members/{conversationMemberId}` | `updatePrimaryChannelMember` |
| `GET` | `/teams/{teamId}/primaryChannel/messages` | `listPrimaryChannelMessages` |
| `POST` | `/teams/{teamId}/primaryChannel/messages` | `createPrimaryChannelMessage` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/$count` | `countPrimaryChannelMessages` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/delta()` | `getPrimaryChannelMessagesDelta` |
| `POST` | `/teams/{teamId}/primaryChannel/messages/replyWithQuote` | `replyWithQuotePrimaryChannelMessages` |
| `DELETE` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}` | `deletePrimaryChannelMessage` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}` | `getPrimaryChannelMessage` |
| `PATCH` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}` | `updatePrimaryChannelMessage` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/hostedContents` | `listPrimaryChannelMessageHostedContents` |
| `POST` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/hostedContents` | `createPrimaryChannelMessageHostedContent` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/hostedContents/$count` | `countPrimaryChannelMessageHostedContents` |
| `DELETE` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/hostedContents/{chatMessageHostedContentId}` | `deletePrimaryChannelMessageHostedContent` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/hostedContents/{chatMessageHostedContentId}` | `getPrimaryChannelMessageHostedContent` |
| `PATCH` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/hostedContents/{chatMessageHostedContentId}` | `updatePrimaryChannelMessageHostedContent` |
| `DELETE` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/hostedContents/{chatMessageHostedContentId}/$value` | `deletePrimaryChannelMessageHostedContentValue` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/hostedContents/{chatMessageHostedContentId}/$value` | `getPrimaryChannelMessageHostedContentValue` |
| `PUT` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/hostedContents/{chatMessageHostedContentId}/$value` | `updatePrimaryChannelMessageHostedContentValue` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies` | `listPrimaryChannelMessageReplies` |
| `POST` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies` | `createPrimaryChannelMessageReply` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/$count` | `countPrimaryChannelMessageReplies` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/delta()` | `getPrimaryChannelMessageRepliesDelta` |
| `POST` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/replyWithQuote` | `replyWithQuotePrimaryChannelMessageReplies` |
| `DELETE` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}` | `deletePrimaryChannelMessageReply` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}` | `getPrimaryChannelMessageReply` |
| `PATCH` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}` | `updatePrimaryChannelMessageReply` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents` | `listPrimaryChannelMessageReplyHostedContents` |
| `POST` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents` | `createPrimaryChannelMessageReplyHostedContent` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents/$count` | `countPrimaryChannelMessageReplyHostedContents` |
| `DELETE` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents/{chatMessageHostedContentId}` | `deletePrimaryChannelMessageReplyHostedContent` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents/{chatMessageHostedContentId}` | `getPrimaryChannelMessageReplyHostedContent` |
| `PATCH` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents/{chatMessageHostedContentId}` | `updatePrimaryChannelMessageReplyHostedContent` |
| `DELETE` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents/{chatMessageHostedContentId}/$value` | `deletePrimaryChannelMessageReplyHostedContentValue` |
| `GET` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents/{chatMessageHostedContentId}/$value` | `getPrimaryChannelMessageReplyHostedContentValue` |
| `PUT` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}/hostedContents/{chatMessageHostedContentId}/$value` | `updatePrimaryChannelMessageReplyHostedContentValue` |
| `POST` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}/setReaction` | `setReactionPrimaryChannelMessageReply` |
| `POST` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}/softDelete` | `softDeletePrimaryChannelMessageReply` |
| `POST` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}/undoSoftDelete` | `undoSoftDeletePrimaryChannelMessageReply` |
| `POST` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/replies/{chatMessageId1}/unsetReaction` | `unsetReactionPrimaryChannelMessageReply` |
| `POST` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/setReaction` | `setReactionPrimaryChannelMessage` |
| `POST` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/softDelete` | `softDeletePrimaryChannelMessage` |
| `POST` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/undoSoftDelete` | `undoSoftDeletePrimaryChannelMessage` |
| `POST` | `/teams/{teamId}/primaryChannel/messages/{chatMessageId}/unsetReaction` | `unsetReactionPrimaryChannelMessage` |
| `GET` | `/teams/{teamId}/primaryChannel/tabs` | `listPrimaryChannelTabs` |
| `POST` | `/teams/{teamId}/primaryChannel/tabs` | `createPrimaryChannelTab` |
| `GET` | `/teams/{teamId}/primaryChannel/tabs/$count` | `countPrimaryChannelTabs` |
| `DELETE` | `/teams/{teamId}/primaryChannel/tabs/{teamsTabId}` | `deletePrimaryChannelTab` |
| `GET` | `/teams/{teamId}/primaryChannel/tabs/{teamsTabId}` | `getPrimaryChannelTab` |
| `PATCH` | `/teams/{teamId}/primaryChannel/tabs/{teamsTabId}` | `updatePrimaryChannelTab` |
| `GET` | `/teams/{teamId}/primaryChannel/tabs/{teamsTabId}/teamsApp` | `getPrimaryChannelTabTeamsApp` |
| `POST` | `/teams/{teamId}/sendActivityNotification` | `sendActivityNotification` |
| `GET` | `/teams/{teamId}/tags` | `listTags` |
| `POST` | `/teams/{teamId}/tags` | `createTag` |
| `GET` | `/teams/{teamId}/tags/$count` | `countTags` |
| `DELETE` | `/teams/{teamId}/tags/{teamworkTagId}` | `deleteTag` |
| `GET` | `/teams/{teamId}/tags/{teamworkTagId}` | `getTag` |
| `PATCH` | `/teams/{teamId}/tags/{teamworkTagId}` | `updateTag` |
| `GET` | `/teams/{teamId}/tags/{teamworkTagId}/members` | `listTagMembers` |
| `POST` | `/teams/{teamId}/tags/{teamworkTagId}/members` | `createTagMember` |
| `GET` | `/teams/{teamId}/tags/{teamworkTagId}/members/$count` | `countTagMembers` |
| `DELETE` | `/teams/{teamId}/tags/{teamworkTagId}/members/{teamworkTagMemberId}` | `deleteTagMember` |
| `GET` | `/teams/{teamId}/tags/{teamworkTagId}/members/{teamworkTagMemberId}` | `getTagMember` |
| `PATCH` | `/teams/{teamId}/tags/{teamworkTagId}/members/{teamworkTagMemberId}` | `updateTagMember` |

</details>

5. **Document required request-body fields and navigation-property bindings per operation**
    - Original: Every write operation binds its request body to a broad Microsoft Graph entity type (`MicrosoftGraphTeam`, `MicrosoftGraphChannel`, `MicrosoftGraphConversationMember`, `MicrosoftGraphChatMessage`, `MicrosoftGraphTeamsTab`, `MicrosoftGraphTeamworkTag`, ...) in which **every property is optional**. The generated method signatures therefore give no indication of which fields an operation actually requires (for example, `createChannel` needs a `displayName`), and they don't surface the `@odata.bind` navigation-property bindings some scenarios need (creating a team from a template, a private/shared channel, a channel/team member, or a channel tab).
    - Updated: Added Ballerina doc comments (a "Required payload fields" note in the description block) above **every remote method that accepts a request body** — all `create*`/`update*` operations, the `add*`/`remove*`/`setReaction*`/`unsetReaction*`/`replyWithQuote*` actions, `sendActivityNotification`, and the binary `application/octet-stream` content uploads. Each note states the minimally required fields, any conditionally-required fields (e.g. `membershipType` + a single-owner `members` array for a private/shared channel), and the exact navigation-property bindings for the relevant scenario — the four bindings used across the API are `template@odata.bind` (team), `user@odata.bind` (member), `teamsApp@odata.bind` (tab), and `group@odata.bind` (team from an existing group). The required-vs-optional distinction and the binding formats were verified against the [Microsoft Graph v1.0 reference](https://learn.microsoft.com/en-us/graph/api/resources/teams-api-overview?view=graph-rest-1.0). `@odata.type` is deliberately **not** listed in these notes: although Graph requires it on the two abstract types (`ConversationMember` and `TeamworkNotificationRecipient`), it is enforced as a **required field** on those records (see item 8), so restating it in the doc comment would be redundant. As a rule, a field that the type model already marks required is not repeated in the "Required payload fields" note.
    - Scope: This change is **documentation only** — it edits doc comments in the generated `ballerina/client.bal`. The OpenAPI specification and the generated types are left unchanged, so the payloads remain the open Graph entity records and any additional navigation-property keys (e.g. `"user@odata.bind"`) can still be supplied as extra fields on those open records.
    - Reason: Makes each operation self-documenting about what a caller must send for the request to succeed, compensating for the all-optional generated payload types without altering the spec or type model.

6. **Replace the OData "navigation property" doc-comment boilerplate with resource-specific wording**
    - Original: Microsoft Graph's OData metadata describes relationship (sub-resource) operations in generic OData terms, and `bal openapi` copied that phrasing verbatim into the generated method docs — for example `# Create new navigation property to allMembers for teams`, `# Update the navigation property members in teams`, `# Delete navigation property tabs for teams`, and the parameter/return descriptions `New navigation property`, `New navigation property values`, `Created navigation property`, `Retrieved navigation property`. This wording is opaque (a reader can't tell *which* resource is affected) and often says "for teams" even when the resource is a channel, message, or tab.
    - Updated: Rewrote every doc line that used the "navigation property" boilerplate (134 lines) into concise, resource-specific text derived from each operation's actual resource and payload/return type — method summaries such as `Add member to primary channel allMembers`, `Update primary channel message`, `Delete channel reply hosted content`, and parameter/return docs such as `The member to create`, `The channel properties to update`, `The created message`, `The retrieved tab`.
    - Scope: Documentation only — comment text in `ballerina/client.bal`. Operation IDs, method names, the OpenAPI specification, and the generated types are all unchanged.
    - Reason: The generic OData boilerplate carried no useful information and was frequently misleading about the target resource; resource-specific summaries make the generated API docs readable.

7. **Add the Microsoft Entra ID (Azure AD v2) OAuth2 security scheme**
    - Original: The Microsoft Graph source spec omits `securitySchemes` entirely — no authentication is described, even though every Graph request requires an `Authorization: Bearer <token>` header.
    - Updated: Manually added an OAuth2 security scheme (`azureaadv2`) under `components.securitySchemes`, together with a global `security` requirement. It declares both flows the connector supports: `authorizationCode` (delegated / on-behalf-of-user, including `offline_access` for refresh tokens) and `clientCredentials` (app-only, using the `https://graph.microsoft.com/.default` scope). The relevant Microsoft Graph permission scopes (for example `Team.ReadBasic.All`, `ChannelMessage.Send`, `TeamsTab.ReadWrite.All`, `TeamworkTag.ReadWrite`) are enumerated under each flow. Applied to both `teams-endpoints.yaml` and `aligned_ballerina_openapi.json`.
    - Reason: Documents how callers authenticate against Microsoft Graph and lets the tooling surface the supported OAuth2 flows and the scopes each operation needs, instead of leaving the API appearing unauthenticated.

8. **Make `@odata.type` required only on the two schemas that need it; optional everywhere else**
    - Original: The flatten + align step marked `@odata.type` as `required` on **every** schema where it appears (68 component schemas), so `bal openapi` generated `atOdataType` (the `@jsondata:Name`-mapped `@odata.type`) as a **required** field on all of them. Because Microsoft Graph returns `@odata.type` only for polymorphic/derived instances and omits it from most responses, response binding (`jsondata:parseAsType`) then failed whenever it was absent. 
    - Updated: Moved the fix into the **spec** (so regeneration reproduces it) and narrowed it. In both `docs/spec/aligned_ballerina_openapi.json` and `docs/spec/teams-endpoints.yaml`, `@odata.type` was removed from the `required` array of every schema (66 schemas) **except**:
      - **`ConversationMember`** — Graph requires `@odata.type` = `#microsoft.graph.aadUserConversationMember` on every create/add/update-member request (`createMember`, `createChannelMember`, `updateMember`, the `add*`/`remove*` actions via `AddMembersRequest.values`, and their `primaryChannel`/`allMembers` variants). Kept **required**.
      - **`TeamworkNotificationRecipient`** — the abstract `recipient` of `sendActivityNotification`; Graph requires `@odata.type` to select the concrete recipient subtype (`aadUserNotificationRecipient`, `channelMembersNotificationRecipient`, `teamMembersNotificationRecipient`). Kept **required**.

      Correspondingly, `atOdataType` is now a **required** field (`string atOdataType;`) on those two records in `ballerina/types.bal` and optional (`string atOdataType?;`) on the other 66. The `@odata.type` property definitions and the `#microsoft.graph.*` discriminator values are unchanged, so the wire format is unchanged.
    - Scope: `docs/spec/aligned_ballerina_openapi.json` (66 `required` arrays stripped), `docs/spec/teams-endpoints.yaml` (66 stripped), and the two now-required fields in `ballerina/types.bal`.
    - Reason: Keeping `@odata.type` required only where Graph actually requires it makes those two request payloads self-enforcing while letting every other type (including all response-bound records) bind responses that omit `@odata.type`. Marking `ConversationMember.@odata.type` required is safe for its response paths because Graph returns the discriminator on every member read — including under `$select` (verified against live Graph v1.0: `GET /teams/{id}/members?$select=id,displayName,roles` still returns `"@odata.type": "#microsoft.graph.aadUserConversationMember"` for each member). Because the change now lives in the spec, regenerating the client reproduces it — no post-generation re-application required.

9. **Make the OAuth2 token/refresh URL a required field**
    - Original: The generated grant-config records defaulted the endpoint URL to the multi-tenant `/common/` endpoint — `OAuth2ClientCredentialsGrantConfig.tokenUrl` and `OAuth2RefreshTokenGrantConfig.refreshUrl` were both `= "https://login.microsoftonline.com/common/oauth2/v2.0/token"`.
    - Updated: Manually edited `ballerina/types.bal` after generation to drop those defaults, so `tokenUrl` (client-credentials flow) and `refreshUrl` (refresh-token flow) are now **required** fields the caller must supply.
    - Reason: The `/common/` default only works for multi-tenant app registrations; single-tenant apps must authenticate against their tenant-specific endpoint (`https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`). Silently defaulting to `/common/` produced confusing auth failures for single-tenant apps. Requiring the URL forces callers to point at the correct tenant. Note: this is a post-generation edit — regenerating the client reintroduces the defaults, so it must be re-applied.

10. **Return `http:Response` for asynchronous (202) and no-content (204) create/update operations**
    - Original: The Microsoft Graph metadata models every write operation's success response as `2XX` with the full entity body (e.g. `application/json` → `microsoft.graph.channel`). In reality several create/update operations do **not** return that body:
      - `POST /teams` (`createTeam`) — always **202 Accepted**, empty body, new team URL in the `Location` header (async).
      - `POST /teams/{id}/channels` (`createChannel`) — **201** with body for standard/private channels, but **202 Accepted** (empty body, `Location` header) for shared channels (partially async).
      - `PATCH /teams/{id}` (`updateTeam`), `PATCH .../channels/{id}` (`updateChannel`, `updatePrimaryChannel`), `PATCH .../messages/{id}` (`updateChannelMessage`, `updatePrimaryChannelMessage`), and `PATCH .../replies/{id}` (`updateChannelMessageReply`, `updatePrimaryChannelMessageReply`) — **204 No Content**, empty body.

      Because the generated methods bound the (absent) body directly into the entity record, these calls failed at runtime with a payload-binding error against live Graph. The exact status codes were verified against the [Microsoft Graph v1.0 API reference](https://learn.microsoft.com/en-us/graph/api/overview) for each operation.
    - Updated: For these **9 operations** the `2XX` response in both `teams-endpoints.yaml` and `aligned_ballerina_openapi.json` was changed to a generic, untyped body:

      ```yaml
      responses:
        2XX:
          description: Any Response
          content:
            '*/*':
              schema:
                description: Any type of entity body
      ```

      and the corresponding remote methods in `ballerina/client.bal` now return **`http:Response`** (a straight pass-through of `self.clientEp->post/patch(...)`). The `4XX`/`5XX` error responses are unchanged. Callers inspect the raw response — status code, `Location` header (for the async id), and body when present. Two now-unused post-generation helpers that had previously worked around this (`validateResponse`, `asyncCreatedId`/`idAfterSegment` in `ballerina/utils.bal`) were removed.
    - Scope: `docs/spec/teams-endpoints.yaml`, `docs/spec/aligned_ballerina_openapi.json`, `ballerina/client.bal`, `ballerina/utils.bal`. Tests (`ballerina/tests/test.bal`) and the affected examples were updated to consume `http:Response`.
    - Reason: Modelling these responses as a typed body was incorrect and broke the calls at runtime. Returning `http:Response` is honest about the async/empty-body nature of these operations and lets callers read the `Location` header (created id) or handle the empty `204` without a binding failure. Note: this is a spec + post-generation edit — regenerating the client from the updated spec reproduces the `http:Response` return type, but if the spec is re-synced from upstream the `2XX` change and the client passthrough must be re-applied.

11. **Remove the `MicrosoftGraph` prefix from schema (type) names**
    - Original: The flatten + align step names every Microsoft Graph schema with a `MicrosoftGraph` prefix in `aligned_ballerina_openapi.json` (e.g. `MicrosoftGraphTeam`, `MicrosoftGraphChannel`, `MicrosoftGraphChatMessage`, `MicrosoftGraphConversationMemberCollectionResponse`), and `bal openapi` turns those into correspondingly-prefixed Ballerina types. The prefix is redundant in a package already scoped as `ballerinax/microsoft.teams` and makes every method signature and type reference verbose (`teams:MicrosoftGraphChatMessageCollectionResponse`).
    - Updated: Removed the prefix in **both** spec files:
      - `aligned_ballerina_openapi.json` (the client-generation input): renamed all 96 `MicrosoftGraph*` schema components by dropping the prefix (`MicrosoftGraphTeam` → `Team`, `MicrosoftGraphChatMessage` → `ChatMessage`, `MicrosoftGraphConversationMemberCollectionResponse` → `ConversationMemberCollectionResponse`, …) and rewrote every `$ref` (232 references).
      - `teams-endpoints.yaml` (the raw filtered source): there the names are the dotted `microsoft.graph.*` form (e.g. `microsoft.graph.team`, `microsoft.graph.channelCollectionResponse`), so the 104 component definitions (96 schemas + 8 responses) and 283 `$ref`s were renamed to the same prefix-free names.

      `bal openapi` now generates prefix-free types **directly from the spec** — the change lives in the spec, not as a post-generation edit.
      - **Collision handling:** in the aligned JSON, `MicrosoftGraphChatMessageCollectionResponse` was byte-for-byte identical to the already-existing `ChatMessageCollectionResponse` schema (`*BaseCollectionPaginationCountResponse` + a `ChatMessage[] value?` field). Stripping the prefix would have produced a duplicate key, so the prefixed schema was **removed** and its `$ref`s repointed to `ChatMessageCollectionResponse` (108 schemas remain). The raw YAML has no such duplicate, so no merge was needed there.
    - Scope: `docs/spec/aligned_ballerina_openapi.json` and `docs/spec/teams-endpoints.yaml`. In both, only the schema/response component names and their `$ref`s were changed; the `#microsoft.graph.*` `@odata.type` payload discriminator values and all descriptions were left untouched, so the wire format is unchanged. The corresponding types across `ballerina/types.bal`, `ballerina/client.bal`, `ballerina/tests/test.bal`, and `examples/*/main.bal` are the prefix-free names. The `MicrosoftGraph*` names referenced in items 5 and 8 above therefore now denote their unprefixed forms.
    - Reason: Shorter, cleaner type names in the public API. Because the rename is applied to the spec, regenerating the client reproduces the prefix-free types (verified by regeneration — the generated types are prefix-free and match the committed sources); no post-generation re-application is required.

12. **Describe the return value on operations labeled with the generic `Success` response description**
    - Original: Microsoft Graph's OData→OpenAPI metadata labels many success responses with the bare description `Success`. `bal openapi` copies each response `description` verbatim into the generated `# + return -` doc, so 35 operations that actually return a **typed body** carried the uninformative `Success` — which didn't match the return type. The item-6 doc rewrite only replaced the "navigation property" boilerplate, so operations already labeled `Success` were skipped, even when they return an entity/collection.
    - Updated: Rewrote the success-response `description` for those 35 operations in **both** `docs/spec/aligned_ballerina_openapi.json` and `docs/spec/teams-endpoints.yaml`, and the matching `# + return -` doc line in `ballerina/client.bal`:

      | Operations | Return type | New description |
      |---|---|---|
      | 5 `update*Member` | `ConversationMember` | The updated member |
      | 4 `update*HostedContent` | `ChatMessageHostedContent` | The updated hosted content |
      | 2 `update*Tab` | `TeamsTab` | The updated tab |
      | `updateTag` | `TeamworkTag` | The updated tag |
      | `updateTagMember` | `TeamworkTagMember` | The updated tag member |
      | `getAllChannelMessages`, `getAllRetainedChannelMessages`, 4 `*Delta` | chat message collections | Retrieved collection |
      | 4 `replyWithQuote*` | `ChatMessageResponse` | The created reply message |
      | 10 `add*`/`remove*` members | `ActionResultPartCollectionResponse` | The result for each member |
      | 2 `update*FilesFolderContent` | `DriveItem` | The uploaded file |

      Operations that return no body (`error?` — every `delete*`, `setReaction`/`unsetReaction`, `softDelete`/`undoSoftDelete`, and `sendActivityNotification`) **keep** `Success`, which correctly describes a no-content (HTTP 204) success.
    - Scope: `docs/spec/aligned_ballerina_openapi.json`, `docs/spec/teams-endpoints.yaml`, `ballerina/client.bal`. Only response `description` text and the corresponding `# + return -` doc lines changed (35 per file); schemas, types, and status codes are untouched. In `teams-endpoints.yaml` the operations were matched by path + method (that file keeps the original dotted operationIds and kebab-case path params).
    - Reason: The generic `Success` gave no indication of what a call returns and contradicted the typed return. Because the change lives in the spec `description` fields, regenerating the client reproduces the descriptive return docs — no post-generation re-application required.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/aligned_ballerina_openapi.json --mode client --client-methods remote -o ballerina --license docs/license.txt
```

Note: The license year is set to 2021 to match the existing connector sources; change if necessary.
