// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

import ballerina/constraint;
import ballerina/data.jsondata;
import ballerina/http;

# Represents the Queries record for the operation: countAllChannels
public type CountAllChannelsQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

# Represents the Queries record for the operation: listTagMembers
public type ListTagMembersQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type PendingOperations record {
    # A property that indicates that an operation that might update the binary content of a file is pending completion
    PendingContentUpdate|record {} pendingContentUpdate?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
};

# Represents the Queries record for the operation: listMembers
public type ListMembersQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: countPrimaryChannelEnabledApps
public type CountPrimaryChannelEnabledAppsQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

public type TeamworkConversationIdentityType "team"|"channel"|"chat"|"unknownFutureValue";

public type TeamworkTagCollectionResponse record {
    *BaseCollectionPaginationCountResponse;
    TeamworkTag[] value?;
};

public type Identity record {
    # The display name of the identity.For drive items, the display name might not always be available or up to date. For example, if a user changes their display name the API might show the new value in a future response, but the items associated with the user don't show up as changed when using delta
    string? displayName?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Unique identifier for the identity or actor. For example, in the access reviews decisions API, this property might record the id of the principal, that is, the group, user, or application that's subject to review
    string? id?;
};

# Represents the Queries record for the operation: countChannelMessageReplyHostedContents
public type CountChannelMessageReplyHostedContentsQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

public type PendingContentUpdate record {
    # Date and time the pending binary operation was queued in UTC time. Read-only
    string? queuedDateTime?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
};

public type ChatMessagePolicyViolationVerdictDetailsTypes "none"|"allowFalsePositiveOverride"|"allowOverrideWithoutJustification"|"allowOverrideWithJustification";

public type ChatMessageReactionIdentitySet record {
    *IdentitySet;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType = "#microsoft.graph.chatMessageReactionIdentitySet";
};

# Represents the Queries record for the operation: listPrimaryChannelAllMembers
public type ListPrimaryChannelAllMembersQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Provides a set of configurations for controlling the behaviours when communicating with a remote HTTP endpoint.
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    # Configurations related to client authentication
    OAuth2ClientCredentialsGrantConfig|http:BearerTokenConfig|OAuth2RefreshTokenGrantConfig auth;
    # The HTTP version understood by the client
    http:HttpVersion httpVersion = http:HTTP_2_0;
    # Configurations related to HTTP/1.x protocol
    http:ClientHttp1Settings http1Settings = {};
    # Configurations related to HTTP/2 protocol
    http:ClientHttp2Settings http2Settings = {};
    # The maximum time to wait (in seconds) for a response before closing the connection
    decimal timeout = 30;
    # The choice of setting `forwarded`/`x-forwarded` header
    string forwarded = "disable";
    # Configurations associated with Redirection
    http:FollowRedirects followRedirects?;
    # Configurations associated with request pooling
    http:PoolConfiguration poolConfig?;
    # HTTP caching related configurations
    http:CacheConfig cache = {};
    # Specifies the way of handling compression (`accept-encoding`) header
    http:Compression compression = http:COMPRESSION_AUTO;
    # Configurations associated with the behaviour of the Circuit Breaker
    http:CircuitBreakerConfig circuitBreaker?;
    # Configurations associated with retrying
    http:RetryConfig retryConfig?;
    # Configurations associated with cookies
    http:CookieConfig cookieConfig?;
    # Configurations associated with inbound response size limits
    http:ResponseLimitConfigs responseLimits = {};
    # SSL/TLS-related options
    http:ClientSecureSocket secureSocket?;
    # Proxy server related options
    http:ProxyConfig proxy?;
    # Provides settings related to client socket configuration
    http:ClientSocketConfig socketConfig = {};
    # Enables the inbound payload validation functionality which provided by the constraint package. Enabled by default
    boolean validation = true;
    # Enables relaxed data binding on the client side. When enabled, `nil` values are treated as optional, 
    # and absent fields are handled as `nilable` types. Enabled by default.
    boolean laxDataBinding = true;
|};

public type ChatMessageHostedContent record {
    *TeamworkHostedContent;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
};

# Represents the Queries record for the operation: listPrimaryChannelMessageReplyHostedContents
public type ListPrimaryChannelMessageReplyHostedContentsQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: listTags
public type ListTagsQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Headers record for the operation: deleteChannelAllMember
public type DeleteChannelAllMemberHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

public type Channel record {
    *Entity;
    # Contains summary information about the channel, including number of owners, members, guests, and an indicator for members from other tenants. The summary property will only be returned if it is specified in the $select clause of the Get channel method
    ChannelSummary|record {} summary?;
    # The type of the channel. Can be set during creation and can't be changed. The possible values are: standard, private, unknownFutureValue, shared. The default value is standard. Use the Prefer: include-unknown-enum-members request header to get the following members in this evolvable enum: shared
    ChannelMembershipType|record {} membershipType?;
    # Channel name as it will appear to the user in Microsoft Teams. The maximum length is 50 characters
    string displayName?;
    # Indicates whether the channel is archived. Read-only
    boolean? isArchived?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Read-only. Timestamp at which the channel was created
    string? createdDateTime?;
    # Optional textual description for the channel
    string? description?;
    # Timestamp of the original creation time for the channel. The value is null if the channel never entered migration mode
    string? originalCreatedDateTime?;
    # Indicates whether a channel is in migration mode. This value is null for channels that never entered migration mode. The possible values are: inProgress, completed, unknownFutureValue
    MigrationMode|record {} migrationMode?;
    # A hyperlink that will go to the channel in Microsoft Teams. This is the URL that you get when you right-click a channel in Microsoft Teams and select Get link to channel. This URL should be treated as an opaque blob, and not parsed. Read-only
    string? webUrl?;
    # The ID of the Microsoft Entra tenant
    string? tenantId?;
    # The layout type of the channel. It can be set during creation and updated later. The possible values are: post, chat, unknownFutureValue. The default value is post. Channels with the post layout use a traditional post‑reply conversation format, and channels with the chat layout provide a chat‑like threading experience similar to group chats
    ChannelLayoutType|record {} layoutType?;
    # Indicates whether the channel should be marked as recommended for all members of the team to show in their channel list. Note: All recommended channels automatically show in the channels list for education and frontline worker users. The property can only be set programmatically via the Create team method. The default value is false
    boolean? isFavoriteByDefault?;
    # The email address for sending messages to the channel. Read-only
    string? email?;
};

public type File record {
    boolean? processingMetadata?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Hashes of the file's binary content, if available. Read-only
    Hashes|record {} hashes?;
    # The MIME type for the file. This is determined by logic on the server and might not be the value provided when the file was uploaded. Read-only
    string? mimeType?;
};

# Represents the Queries record for the operation: getPrimaryChannelTabTeamsApp
public type GetPrimaryChannelTabTeamsAppQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: getPrimaryChannelMessageHostedContent
public type GetPrimaryChannelMessageHostedContentQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: getPrimaryChannelMessagesDelta
public type GetPrimaryChannelMessagesDeltaQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type TeamsAppCollectionResponse record {
    *BaseCollectionPaginationCountResponse;
    TeamsApp[] value?;
};

# Represents the Headers record for the operation: deletePrimaryChannelTab
public type DeletePrimaryChannelTabHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

public type ChannelSummary record {
    # Count of members in a channel
    decimal? membersCount?;
    # Count of guests in a channel
    decimal? guestsCount?;
    # Indicates whether external members are included on the channel
    boolean? hasMembersFromOtherTenants?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Count of owners in a channel
    decimal? ownersCount?;
};

public type Video record {
    # Duration of the file in milliseconds
    decimal? duration?;
    # Frame rate of the video
    decimal|string|ReferenceNumeric? frameRate?;
    # Number of audio channels
    decimal? audioChannels?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Number of audio bits per sample
    decimal? audioBitsPerSample?;
    # 'Four character code' name of the video format
    string? fourCC?;
    # Width of the video, in pixels
    decimal? width?;
    # Name of the audio format (AAC, MP3, etc.)
    string? audioFormat?;
    # Bit rate of the video in bits per second
    decimal? bitrate?;
    # Number of audio samples per second
    decimal? audioSamplesPerSecond?;
    # Height of the video, in pixels
    decimal? height?;
};

# Represents the Headers record for the operation: deleteTag
public type DeleteTagHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

# Represents the Queries record for the operation: listChannelMessageReplies
public type ListChannelMessageRepliesQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type ChatMessageHostedContentCollectionResponse record {
    *BaseCollectionPaginationCountResponse;
    ChatMessageHostedContent[] value?;
};

# Represents the Queries record for the operation: getPrimaryChannelFilesFolderContent
public type GetPrimaryChannelFilesFolderContentQueries record {
    # Format of the content
    @http:Query {name: "$format"}
    string dollarFormat?;
};

# Represents the Queries record for the operation: getPrimaryChannelAllMember
public type GetPrimaryChannelAllMemberQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: getIncomingChannel
public type GetIncomingChannelQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: getChannelEnabledApp
public type GetChannelEnabledAppQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type SpecialFolder record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The unique identifier for this item in the /drive/special collection
    string? name?;
};

public type TeamworkTagType "standard"|"unknownFutureValue";

public type Image record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Optional. Width of the image, in pixels. Read-only
    decimal? width?;
    # Optional. Height of the image, in pixels. Read-only
    decimal? height?;
};

# Represents the Queries record for the operation: getAllChannel
public type GetAllChannelQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type Shared record {
    # The identity of the owner of the shared item. Read-only
    IdentitySet|record {} owner?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Indicates the scope of how the item is shared. The possible values are: anonymous, organization, or users. Read-only
    string? scope?;
    # The identity of the user who shared the item. Read-only
    IdentitySet|record {} sharedBy?;
    # The UTC date and time when the item was shared. Read-only
    string? sharedDateTime?;
};

public type Photo record {
    # The numerator for the exposure time fraction from the camera. Read-only
    decimal|string|ReferenceNumeric? exposureNumerator?;
    # The orientation value from the camera. Writable on OneDrive Personal
    decimal? orientation?;
    # The denominator for the exposure time fraction from the camera. Read-only
    decimal|string|ReferenceNumeric? exposureDenominator?;
    # The ISO value from the camera. Read-only
    decimal? iso?;
    # The F-stop value from the camera. Read-only
    decimal|string|ReferenceNumeric? fNumber?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Camera model. Read-only
    string? cameraModel?;
    # Camera manufacturer. Read-only
    string? cameraMake?;
    # Represents the date and time the photo was taken. Read-only
    string? takenDateTime?;
    # The focal length from the camera. Read-only
    decimal|string|ReferenceNumeric? focalLength?;
};

public type ChatMessageType "message"|"chatEvent"|"typing"|"unknownFutureValue"|"systemEventMessage";

# Represents the Queries record for the operation: countPrimaryChannelMessageReplies
public type CountPrimaryChannelMessageRepliesQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

# Represents the Headers record for the operation: deleteTagMember
public type DeleteTagMemberHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

# Represents the Queries record for the operation: listAllChannels
public type ListAllChannelsQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type Bundle record {
    # If the bundle is an album, then the album property is included
    Album|record {} album?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Number of children contained immediately within this container
    decimal? childCount?;
};

# Represents the Queries record for the operation: listIncomingChannels
public type ListIncomingChannelsQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type ChatMessageActions "reactionAdded"|"reactionRemoved"|"actionUndefined"|"unknownFutureValue";

# Represents the Queries record for the operation: getChannel
public type GetChannelQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: getAllRetainedChannelMessages
public type GetAllRetainedChannelMessagesQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type ChatMessageFromIdentitySet record {
    *IdentitySet;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType = "#microsoft.graph.chatMessageFromIdentitySet";
};

# OAuth2 Client Credentials Grant Configs
public type OAuth2ClientCredentialsGrantConfig record {|
    *http:OAuth2ClientCredentialsGrantConfig;
    # Token URL
    string tokenUrl;
|};

public type SearchResult record {
    # A callback URL that can be used to record telemetry information. The application should issue a GET on this URL if the user interacts with this item to improve the quality of results
    string? onClickTelemetryUrl?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
};

public type TeamsTabConfiguration record {
    # Url used for rendering tab contents in Teams. Required
    string? contentUrl?;
    # Url called by Teams client when a Tab is removed using the Teams Client
    string? removeUrl?;
    # Url for showing tab contents outside of Teams
    string? websiteUrl?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Identifier for the entity hosted by the tab provider
    string? entityId?;
};

# Represents the Headers record for the operation: deleteChannelMessageReplyHostedContent
public type DeleteChannelMessageReplyHostedContentHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

# Represents the Queries record for the operation: getChannelMessage
public type GetChannelMessageQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type TeamGuestSettings record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # If set to true, guests can delete channels
    boolean? allowDeleteChannels?;
    # If set to true, guests can add and update channels
    boolean? allowCreateUpdateChannels?;
};

public type PublicErrorDetail record {
    # The error code
    string? code?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The error message
    string? message?;
    # The target of the error
    string? target?;
};

public type Deleted record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Represents the state of the deleted item
    string? state?;
};

# Represents the Queries record for the operation: countChannelTabs
public type CountChannelTabsQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

public type TeamworkActivityTopic record {
    # The link the user clicks when they select the notification. Optional when source is entityUrl; required when source is text
    string? webUrl?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Type of source. The possible values are: entityUrl, text. For supported Microsoft Graph URLs, use entityUrl. For custom text, use text
    TeamworkActivityTopicSource|record {} 'source?;
    # The topic value. If the value of the source property is entityUrl, this must be a Microsoft Graph URL. If the value is text, this must be a plain text value
    string value?;
};

public type PublicInnerError record {
    # The error code
    string? code?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # A collection of error details
    PublicErrorDetail[] details?;
    # The error message
    string? message?;
    # The target of the error
    string? target?;
};

# Represents the Queries record for the operation: getAllChannelMessages
public type GetAllChannelMessagesQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # The payment model for the API
    string model?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type ConversationMemberCollectionResponse record {
    *BaseCollectionPaginationCountResponse;
    ConversationMember[] value?;
};

# Represents the Queries record for the operation: listChannelMembers
public type ListChannelMembersQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type ItemReference record {
    # Percent-encoded path that can be used to navigate to the item. Read-only
    string? path?;
    # Unique identifier of the drive instance that contains the driveItem. Only returned if the item is located in a drive. Read-only
    string? driveId?;
    # Identifies the type of drive. Only returned if the item is located in a drive. See drive resource for values
    string? driveType?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The name of the item being referenced. Read-only
    string? name?;
    # For OneDrive for Business and SharePoint, this property represents the ID of the site that contains the parent document library of the driveItem resource or the parent list of the listItem resource. The value is the same as the id property of that site resource. It is an opaque string that consists of three identifiers of the site. For OneDrive, this property is not populated
    string? siteId?;
    # A unique identifier for a shared resource that can be accessed via the Shares API
    string? shareId?;
    # Unique identifier of the driveItem in the drive or a listItem in a list. Read-only
    string? id?;
    # Returns identifiers useful for SharePoint REST compatibility. Read-only
    SharepointIds|record {} sharepointIds?;
};

public type ItemBody record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The type of the content. Possible values are text and html
    BodyType|record {} contentType?;
    # The content of the item
    string? content?;
};

public type BaseCollectionPaginationCountResponse record {
    @jsondata:Name {value: "@odata.nextLink"}
    string? atOdataNextLink?;
    @jsondata:Name {value: "@odata.count"}
    int? atOdataCount?;
};

# Represents the Queries record for the operation: listPrimaryChannelTabs
public type ListPrimaryChannelTabsQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: getTag
public type GetTagQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type TeamMessagingSettings record {
    # If set to true, users can delete their messages
    boolean? allowUserDeleteMessages?;
    # If set to true, @team mentions are allowed
    boolean? allowTeamMentions?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # If set to true, @channel mentions are allowed
    boolean? allowChannelMentions?;
    # If set to true, owners can delete any message
    boolean? allowOwnerDeleteMessages?;
    # If set to true, users can edit their messages
    boolean? allowUserEditMessages?;
};

# Represents the Queries record for the operation: countChannelMessageHostedContents
public type CountChannelMessageHostedContentsQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

public type Root record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
};

public type BodyType "text"|"html";

# Represents the Headers record for the operation: deletePrimaryChannelMember
public type DeletePrimaryChannelMemberHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

public type SetReactionRequest record {
    string? reactionType?;
};

public type PublicationFacet record {
    # The unique identifier for the version that is visible to the current caller. Read-only
    string? versionId?;
    # The state of publication for this document. Either published or checkout. Read-only
    string? level?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The user who checked out the file
    IdentitySet|record {} checkedOutBy?;
};

# Represents the Headers record for the operation: deletePrimaryChannelMessageHostedContent
public type DeletePrimaryChannelMessageHostedContentHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

# Represents the Headers record for the operation: deletePrimaryChannelMessageReply
public type DeletePrimaryChannelMessageReplyHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

public type Package record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # A string indicating the type of package. While oneNote is the only currently defined value, you should expect other package types to be returned and handle them accordingly
    string? 'type?;
};

# Represents the Queries record for the operation: getPrimaryChannelMessageReply
public type GetPrimaryChannelMessageReplyQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: listChannelEnabledApps
public type ListChannelEnabledAppsQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Headers record for the operation: deleteChannelMessageHostedContentValue
public type DeleteChannelMessageHostedContentValueHeaders record {
    # ETag
    string If\-Match?;
};

# Represents the Headers record for the operation: deletePrimaryChannelFilesFolderContent
public type DeletePrimaryChannelFilesFolderContentHeaders record {
    # ETag
    string If\-Match?;
};

public type ChatMessageAttachment record {
    # The ID of the Teams app that is associated with the attachment. The property is used to attribute a Teams message card to the specified app
    string? teamsAppId?;
    # The URL for the content of the attachment
    string? contentUrl?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The name of the attachment
    string? name?;
    # Read-only. The unique ID of the attachment
    string? id?;
    # The media type of the content attachment. The possible values are: reference: The attachment is a link to another file. Populate the contentURL with the link to the object.forwardedMessageReference: The attachment is a reference to a forwarded message. Populate the content with the original message context.Any contentType that is supported by the Bot Framework's Attachment object.application/vnd.microsoft.card.codesnippet: A code snippet. application/vnd.microsoft.card.announcement: An announcement header
    string? contentType?;
    # The content of the attachment. If the attachment is a rich card, set the property to the rich card object. This property and contentUrl are mutually exclusive
    string? content?;
    # The URL to a thumbnail image that the channel can use if it supports using an alternative, smaller form of content or contentUrl. For example, if you set contentType to application/word and set contentUrl to the location of the Word document, you might include a thumbnail image that represents the document. The channel could display the thumbnail image instead of the document. When the user selects the image, the channel would open the document
    string? thumbnailUrl?;
};

public type ChatMessagePolicyViolationPolicyTip record {
    # The URL a user can visit to read about the data loss prevention policies for the organization. (ie, policies about what users shouldn't say in chats)
    string? complianceUrl?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Explanatory text shown to the sender of the message
    string? generalText?;
    # The list of improper data in the message that was detected by the data loss prevention app. Each DLP app defines its own conditions, examples include 'Credit Card Number' and 'Social Security Number'
    string[] matchedConditionDescriptions?;
};

public type TeamsAppDistributionMethod "store"|"organization"|"sideloaded"|"unknownFutureValue";

# Represents the Queries record for the operation: countMembers
public type CountMembersQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

public type ChatMessageMentionedIdentitySet record {
    *IdentitySet;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType = "#microsoft.graph.chatMessageMentionedIdentitySet";
    # If present, represents a conversation (for example, team, channel, or chat) @mentioned in a message
    TeamworkConversationIdentity|record {} conversation?;
};

# OAuth2 Refresh Token Grant Configs
public type OAuth2RefreshTokenGrantConfig record {|
    *http:OAuth2RefreshTokenGrantConfig;
    # Refresh URL
    string refreshUrl;
|};

public type ConversationMember record {
    *Entity;
    # The display name of the user
    string? displayName?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType;
    # The roles for that user. This property contains more qualifiers only when relevant - for example, if the member has owner privileges, the roles property contains owner as one of the values. Similarly, if the member is an in-tenant guest, the roles property contains guest as one of the values. A basic member shouldn't have any values specified in the roles property. An Out-of-tenant external member is assigned the owner role
    string[] roles?;
    # The timestamp denoting how far back a conversation's history is shared with the conversation member. This property is settable only for members of a chat
    string? visibleHistoryStartDateTime?;
};

public type IdentitySet record {
    # Optional. The application associated with this action
    Identity|record {} application?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Optional. The device associated with this action
    Identity|record {} device?;
    # Optional. The user associated with this action
    Identity|record {} user?;
};

# Represents the Queries record for the operation: getMember
public type GetMemberQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: listChannelTabs
public type ListChannelTabsQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: listPrimaryChannelMessages
public type ListPrimaryChannelMessagesQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: getChannelFilesFolder
public type GetChannelFilesFolderQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type ReferenceNumeric "-INF"|"INF"|"NaN"?;

# Represents the Headers record for the operation: deleteChannelMessageReplyHostedContentValue
public type DeleteChannelMessageReplyHostedContentValueHeaders record {
    # ETag
    string If\-Match?;
};

public type GiphyRatingType "strict"|"moderate"|"unknownFutureValue";

public type PublicError record {
    # Represents the error code
    string? code?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Details of the error
    PublicErrorDetail[] details?;
    # Details of the inner error
    PublicInnerError|record {} innerError?;
    # A non-localized message for the developer
    string? message?;
    # The target of the error
    string? target?;
};

# Represents the Headers record for the operation: deleteChannelMessageHostedContent
public type DeleteChannelMessageHostedContentHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

public type Album record {
    # Unique identifier of the driveItem that is the cover of the album
    string? coverImageItemId?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
};

# Represents the Queries record for the operation: listChannelMessageHostedContents
public type ListChannelMessageHostedContentsQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: getChannelMessageReply
public type GetChannelMessageReplyQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Headers record for the operation: deletePrimaryChannel
public type DeletePrimaryChannelHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

public type TeamworkTagMemberCollectionResponse record {
    *BaseCollectionPaginationCountResponse;
    TeamworkTagMember[] value?;
};

# Represents the Queries record for the operation: getTeam
public type GetTeamQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Headers record for the operation: deleteChannelTab
public type DeleteChannelTabHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

# Represents the Queries record for the operation: getPrimaryChannelMessageReplyHostedContent
public type GetPrimaryChannelMessageReplyHostedContentQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type TeamFunSettings record {
    # If set to true, enables users to include custom memes
    boolean? allowCustomMemes?;
    # Giphy content rating. The possible values are: moderate, strict
    GiphyRatingType|record {} giphyContentRating?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # If set to true, enables Giphy use
    boolean? allowGiphy?;
    # If set to true, enables users to include stickers and memes
    boolean? allowStickersAndMemes?;
};

# Represents the Queries record for the operation: listPrimaryChannelMessageReplies
public type ListPrimaryChannelMessageRepliesQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type Malware record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Contains the virus details for the malware facet
    string? description?;
};

# Represents the Queries record for the operation: listChannels
public type ListChannelsQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type Team record {
    *Entity;
    # Contains summary information about the team, including number of owners, members, and guests
    TeamSummary|record {} summary?;
    # Settings to configure whether guests can create, update, or delete channels in the team
    TeamGuestSettings|record {} guestSettings?;
    # The visibility of the group and team. Defaults to Public
    TeamVisibilityType|record {} visibility?;
    # The name of the team
    string? displayName?;
    # Whether this team is in read-only mode
    boolean? isArchived?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The name of the first channel in the team. This is an optional property, only used during team creation and isn't returned in methods to get and list teams
    string? firstChannelName?;
    # Timestamp at which the team was created
    string? createdDateTime?;
    # An optional description for the team. Maximum length: 1,024 characters
    string? description?;
    # An optional label. Typically describes the data or business sensitivity of the team. Must match one of a preconfigured set in the tenant's directory
    string? classification?;
    # A unique ID for the team that was used in a few places such as the audit log/Office 365 Management Activity API
    string? internalId?;
    # Settings to configure messaging and mentions in the team
    TeamMessagingSettings|record {} messagingSettings?;
    # Settings to configure use of Giphy, memes, and stickers in the team
    TeamFunSettings|record {} funSettings?;
    # A hyperlink that goes to the team in the Microsoft Teams client. You get this URL when you right-click a team in the Microsoft Teams client and select Get link to team. This URL should be treated as an opaque blob, and not parsed
    string? webUrl?;
    # The ID of the Microsoft Entra tenant
    string? tenantId?;
    # Optional. Indicates whether the team is intended for a particular use case. Each team specialization has access to unique behaviors and experiences targeted to its use case
    TeamSpecialization|record {} specialization?;
    # Settings to configure whether members can perform certain actions, for example, create channels and add bots, in the team
    TeamMemberSettings|record {} memberSettings?;
};

public type TeamMemberSettings record {
    # If set to true, members can add and update private channels
    boolean? allowCreatePrivateChannels?;
    # If set to true, members can add, update, and remove tabs
    boolean? allowCreateUpdateRemoveTabs?;
    # If set to true, members can add and remove apps
    boolean? allowAddRemoveApps?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # If set to true, members can add, update, and remove connectors
    boolean? allowCreateUpdateRemoveConnectors?;
    # If set to true, members can delete channels
    boolean? allowDeleteChannels?;
    # If set to true, members can add and update channels
    boolean? allowCreateUpdateChannels?;
};

# Represents the Queries record for the operation: countPrimaryChannelTabs
public type CountPrimaryChannelTabsQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

# Represents the Headers record for the operation: deleteChannelMessageReply
public type DeleteChannelMessageReplyHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

public type SharepointIds record {
    # The unique identifier (guid) for the item's list in SharePoint
    string? listId?;
    # The unique identifier (guid) for the item within OneDrive for Business or a SharePoint site
    string? listItemUniqueId?;
    # The SharePoint URL for the site that contains the item
    string? siteUrl?;
    # The unique identifier (guid) for the item's site (SPWeb)
    string? webId?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # An integer identifier for the item within the containing list
    string? listItemId?;
    # The unique identifier (guid) for the tenancy
    string? tenantId?;
    # The unique identifier (guid) for the item's site collection (SPSite)
    string? siteId?;
};

public type ChatMessageDeltaCollectionResponse record {
    *BaseDeltaFunctionResponse;
    ChatMessage[] value?;
};

# Represents the Headers record for the operation: deletePrimaryChannelMessageHostedContentValue
public type DeletePrimaryChannelMessageHostedContentValueHeaders record {
    # ETag
    string If\-Match?;
};

public type ChatMessageMention record {
    # String used to represent the mention. For example, a user's display name, a team name
    string? mentionText?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Index of an entity being mentioned in the specified chatMessage. Matches the {index} value in the corresponding <at id='{index}'> tag in the message body
    decimal? id?;
    # The entity (user, application, team, channel, or chat) that was @mentioned
    ChatMessageMentionedIdentitySet|record {} mentioned?;
};

# Represents the Headers record for the operation: deletePrimaryChannelMessageReplyHostedContent
public type DeletePrimaryChannelMessageReplyHostedContentHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

# Represents the Queries record for the operation: countIncomingChannels
public type CountIncomingChannelsQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

public type ChatMessage record {
    *Entity;
    # Summary text of the chat message that could be used for push notifications and summary views or fall back views. Only applies to channel chat messages, not chat messages in a chat
    string? summary?;
    # References to attached objects like files, tabs, meetings etc
    ChatMessageAttachment[] attachments?;
    # Read-only. Timestamp when edits to the chat message were made. Triggers an 'Edited' flag in the Teams UI. If no edits are made the value is null
    string? lastEditedDateTime?;
    # Read-only. Timestamp when the chat message is created (initial setting) or modified, including when a reaction is added or removed
    string? lastModifiedDateTime?;
    # If the message was sent in a chat, represents the identity of the chat
    string? chatId?;
    ChatMessageImportance importance?;
    # Read-only. ID of the parent chat message or root chat message of the thread. (Only applies to chat messages in channels, not chats.)
    string? replyToId?;
    # The subject of the chat message, in plaintext
    string? subject?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Timestamp of when the chat message was created
    string? createdDateTime?;
    # Read-only. Timestamp at which the chat message was deleted, or null if not deleted
    string? deletedDateTime?;
    # Defines the properties of a policy violation set by a data loss prevention (DLP) application
    ChatMessagePolicyViolation|record {} policyViolation?;
    ItemBody body?;
    # Locale of the chat message set by the client. Always set to en-us
    string locale?;
    # If the message was sent in a channel, represents identity of the channel
    ChannelIdentity|record {} channelIdentity?;
    ChatMessageType messageType?;
    # Read-only. Link to the message in Microsoft Teams
    string? webUrl?;
    # List of entities mentioned in the chat message. Supported entities are: user, bot, team, channel, chat, and tag
    ChatMessageMention[] mentions?;
    # List of activity history of a message item, including modification time and actions, such as reactionAdded, reactionRemoved, or reaction changes, on the message
    ChatMessageHistoryItem[] messageHistory?;
    # Read-only. Version number of the chat message
    string? etag?;
    # Details of the sender of the chat message. Can only be set during migration
    ChatMessageFromIdentitySet|record {} 'from?;
    # Reactions for this chat message (for example, Like)
    ChatMessageReaction[] reactions?;
    # Read-only. If present, represents details of an event that happened in a chat, a channel, or a team, for example, adding new members. For event messages, the messageType property will be set to systemEventMessage
    EventMessageDetail|record {} eventDetail?;
};

public type TeamsTabCollectionResponse record {
    *BaseCollectionPaginationCountResponse;
    TeamsTab[] value?;
};

# Represents the Headers record for the operation: deleteChannelMessage
public type DeleteChannelMessageHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

public type ReplyWithQuoteRequest record {
    ChatMessage|record {} replyMessage?;
    string[] messageIds?;
};

# Represents the Queries record for the operation: countPrimaryChannelAllMembers
public type CountPrimaryChannelAllMembersQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

# Represents the Queries record for the operation: getPrimaryChannelEnabledApp
public type GetPrimaryChannelEnabledAppQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Headers record for the operation: deletePrimaryChannelMessageReplyHostedContentValue
public type DeletePrimaryChannelMessageReplyHostedContentValueHeaders record {
    # ETag
    string If\-Match?;
};

# Represents the Headers record for the operation: deleteTeam
public type DeleteTeamHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

public type ChatMessagePolicyViolationUserActionTypes "none"|"override"|"reportFalsePositive";

public type TeamworkNotificationRecipient record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType;
};

public type TeamworkActivityTopicSource "entityUrl"|"text";

# Represents the Queries record for the operation: getChannelMessageReplyHostedContent
public type GetChannelMessageReplyHostedContentQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type ChannelIdentity record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The identity of the team in which the message was posted
    string? teamId?;
    # The identity of the channel in which the message was posted
    string? channelId?;
};

# Represents the Queries record for the operation: countTagMembers
public type CountTagMembersQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

public type FileSystemInfo record {
    # The UTC date and time the file was last accessed. Available for the recent file list only
    string? lastAccessedDateTime?;
    # The UTC date and time the file was last modified on a client
    string? lastModifiedDateTime?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The UTC date and time the file was created on a client
    string? createdDateTime?;
};

# Represents the Queries record for the operation: listChannelMessageReplyHostedContents
public type ListChannelMessageReplyHostedContentsQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: countChannelMembers
public type CountChannelMembersQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

public type Entity record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The unique identifier for an entity. Read-only
    string id?;
};

public type Audio record {
    # Indicates if the file is protected with digital rights management
    boolean? hasDrm?;
    # The name of the composer of the audio file
    string? composers?;
    # Copyright information for the audio file
    string? copyright?;
    # The performing artist for the audio file
    string? artist?;
    # Indicates if the file is encoded with a variable bitrate
    boolean? isVariableBitrate?;
    # The year the audio file was recorded
    decimal? year?;
    # The title of the album for this audio file
    string? album?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Bitrate expressed in kbps
    decimal? bitrate?;
    # The title of the audio file
    string? title?;
    # The total number of discs in this album
    decimal? discCount?;
    # Duration of the audio file, expressed in milliseconds
    decimal? duration?;
    # The total number of tracks on the original disc for this audio file
    decimal? trackCount?;
    # The artist named on the album for the audio file
    string? albumArtist?;
    # The genre of this audio file
    string? genre?;
    # The number of the disc this audio file came from
    decimal? disc?;
    # The number of the track on the original disc for this audio file
    decimal? track?;
};

public type ActionResultPartCollectionResponse record {
    *BaseCollectionPaginationCountResponse;
    ActionResultPart[] value?;
};

# Represents the Queries record for the operation: getChannelMessageRepliesDelta
public type GetChannelMessageRepliesDeltaQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type ChatMessagePolicyViolationDlpActionTypes "none"|"notifySender"|"blockAccess"|"blockAccessExternal";

# Represents the Headers record for the operation: deleteMember
public type DeleteMemberHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

# Represents the Queries record for the operation: getChannelMessagesDelta
public type GetChannelMessagesDeltaQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: countPrimaryChannelMembers
public type CountPrimaryChannelMembersQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

# Represents the Queries record for the operation: getPrimaryChannelFilesFolder
public type GetPrimaryChannelFilesFolderQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type ActionResultPart record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The error that occurred, if any, during the bulk operation
    PublicError|record {} 'error?;
};

# Represents the Queries record for the operation: listChannelMessages
public type ListChannelMessagesQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: getChannelTab
public type GetChannelTabQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type TeamsApp record {
    *Entity;
    # The method of distribution for the app. Read-only
    TeamsAppDistributionMethod|record {} distributionMethod?;
    # The name of the catalog app provided by the app developer in the Microsoft Teams zip app package
    string? displayName?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The ID of the catalog provided by the app developer in the Microsoft Teams zip app package
    string? externalId?;
};

public type TeamworkHostedContent record {
    *Entity;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Write only. Bytes for the hosted content (such as images)
    string? contentBytes?;
    # Write only. Content type. such as image/png, image/jpg
    string? contentType?;
};

public type KeyValuePair record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Name for this key-value pair
    string name?;
    # Value for this key-value pair
    string? value?;
};

public type ChannelCollectionResponse record {
    *BaseCollectionPaginationCountResponse;
    Channel[] value?;
};

# Represents the Queries record for the operation: getChannelMember
public type GetChannelMemberQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: countChannels
public type CountChannelsQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

# Represents the Queries record for the operation: getPrimaryChannelMessageRepliesDelta
public type GetPrimaryChannelMessageRepliesDeltaQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Headers record for the operation: deletePrimaryChannelMessage
public type DeletePrimaryChannelMessageHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

public type Folder record {
    # A collection of properties defining the recommended view for the folder
    FolderView|record {} view?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Number of children contained immediately within this container
    decimal? childCount?;
};

public type SendActivityNotificationRequest record {
    string? teamsAppId?;
    string? iconId?;
    decimal? chainId?;
    KeyValuePair[] templateParameters?;
    TeamworkNotificationRecipient|record {} recipient?;
    TeamworkActivityTopic|record {} topic?;
    string? activityType?;
    ItemBody|record {} previewText?;
};

public type ChatMessageHistoryItem record {
    # The reaction in the modified message
    ChatMessageReaction|record {} reaction?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The date and time when the message was modified
    @constraint:String {pattern: re `^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?(Z|[+-][0-9][0-9]:[0-9][0-9])$`}
    string modifiedDateTime?;
    ChatMessageActions actions?;
};

public type BaseDeltaFunctionResponse record {
    @jsondata:Name {value: "@odata.deltaLink"}
    string? atOdataDeltaLink?;
    @jsondata:Name {value: "@odata.nextLink"}
    string? atOdataNextLink?;
};

public type ChannelLayoutType "post"|"chat"|"unknownFutureValue";

# Represents the Queries record for the operation: getChannelTabTeamsApp
public type GetChannelTabTeamsAppQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type GeoCoordinates record {
    # Optional. The altitude (height), in feet,  above sea level for the item. Read-only
    decimal|string|ReferenceNumeric? altitude?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Optional. The latitude, in decimal, for the item. Read-only
    decimal|string|ReferenceNumeric? latitude?;
    # Optional. The longitude, in decimal, for the item. Read-only
    decimal|string|ReferenceNumeric? longitude?;
};

# Represents the Queries record for the operation: countChannelAllMembers
public type CountChannelAllMembersQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

public type RemoteItem record {
    # Image metadata, if the item is an image. Read-only
    Image|record {} image?;
    # Indicates that the item has been shared with others and provides information about the shared state of the item. Read-only
    Shared|record {} shared?;
    # Date and time the item was last modified. Read-only
    string? lastModifiedDateTime?;
    # If present, indicates that this item is a package instead of a folder or file. Packages are treated like files in some contexts and folders in others. Read-only
    Package|record {} package?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Identity of the user, device, and application which last modified the item. Read-only
    IdentitySet|record {} lastModifiedBy?;
    # Date and time of item creation. Read-only
    string? createdDateTime?;
    # DAV compatible URL for the item
    string? webDavUrl?;
    # Video metadata, if the item is a video. Read-only
    Video|record {} video?;
    # Provides interop between items in OneDrive for Business and SharePoint with the full set of item identifiers. Read-only
    SharepointIds|record {} sharepointIds?;
    # Properties of the parent of the remote item. Read-only
    ItemReference|record {} parentReference?;
    # Indicates that the remote item is a file. Read-only
    File|record {} file?;
    # Indicates that the remote item is a folder. Read-only
    Folder|record {} folder?;
    # Size of the remote item. Read-only
    decimal? size?;
    # Identity of the user, device, and application which created the item. Read-only
    IdentitySet|record {} createdBy?;
    # URL that displays the resource in the browser. Read-only
    string? webUrl?;
    # Optional. Filename of the remote item. Read-only
    string? name?;
    # Unique identifier for the remote item in its drive. Read-only
    string? id?;
    # If the current item is also available as a special folder, this facet is returned. Read-only
    SpecialFolder|record {} specialFolder?;
    # Information about the remote item from the local file system. Read-only
    FileSystemInfo|record {} fileSystemInfo?;
};

public type TeamworkTagMember record {
    *Entity;
    # The member's display name
    string? displayName?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The ID of the tenant that the tag member is a part of
    string? tenantId?;
    # The user ID of the member
    string? userId?;
};

public type AddMembersRequest record {
    ConversationMember[] values?;
};

# Represents the Queries record for the operation: countChannelMessages
public type CountChannelMessagesQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

public type TeamsTab record {
    *Entity;
    # Container for custom settings applied to a tab. The tab is considered configured only once this property is set
    TeamsTabConfiguration|record {} configuration?;
    # Name of the tab
    string? displayName?;
    # Deep link URL of the tab instance. Read-only
    string? webUrl?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
};

# Represents the Queries record for the operation: countPrimaryChannelMessageHostedContents
public type CountPrimaryChannelMessageHostedContentsQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

public type MigrationMode "inProgress"|"completed"|"unknownFutureValue";

public type BaseItem record {
    *Entity;
    # Parent information, if the item has a parent. Read-write
    ItemReference|record {} parentReference?;
    # Date and time the item was last modified. Read-only
    string lastModifiedDateTime?;
    # Identity of the user, device, or application that created the item. Read-only
    IdentitySet|record {} createdBy?;
    # URL that either displays the resource in the browser (for Office file formats), or is a direct link to the file (for other formats). Read-only
    string? webUrl?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Identity of the user, device, and application that last modified the item. Read-only
    IdentitySet|record {} lastModifiedBy?;
    # The name of the item. Read-write
    string? name?;
    # Date and time of item creation. Read-only
    string createdDateTime?;
    # Provides a user-visible description of the item. Optional
    string? description?;
    # ETag for the item. Read-only
    string? eTag?;
};

public type TeamSummary record {
    # Count of members in a team
    decimal? membersCount?;
    # Count of guests in a team
    decimal? guestsCount?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Count of owners in a team
    decimal? ownersCount?;
};

public type Hashes record {
    # This property isn't supported. Don't use
    string? sha256Hash?;
    # A proprietary hash of the file that can be used to determine if the contents of the file change (if available). Read-only
    string? quickXorHash?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # SHA1 hash for the contents of the file (if available). Read-only
    string? sha1Hash?;
    # The CRC32 value of the file (if available). Read-only
    string? crc32Hash?;
};

# Represents the Queries record for the operation: getChannelAllMember
public type GetChannelAllMemberQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: countPrimaryChannelMessageReplyHostedContents
public type CountPrimaryChannelMessageReplyHostedContentsQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

# Represents the Headers record for the operation: deleteChannelFilesFolderContent
public type DeleteChannelFilesFolderContentHeaders record {
    # ETag
    string If\-Match?;
};

# Represents the Queries record for the operation: getPrimaryChannelMember
public type GetPrimaryChannelMemberQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: getChannelMessageHostedContent
public type GetChannelMessageHostedContentQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: countChannelEnabledApps
public type CountChannelEnabledAppsQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

# Represents the Queries record for the operation: getChannelFilesFolderContent
public type GetChannelFilesFolderContentQueries record {
    # Format of the content
    @http:Query {name: "$format"}
    string dollarFormat?;
};

# Represents the Queries record for the operation: getPrimaryChannelTab
public type GetPrimaryChannelTabQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type EmptyResponse record {
};

public type TeamVisibilityType "private"|"public"|"hiddenMembership"|"unknownFutureValue";

# Represents the Queries record for the operation: getTagMember
public type GetTagMemberQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Queries record for the operation: listPrimaryChannelMembers
public type ListPrimaryChannelMembersQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type ChatMessageCollectionResponse record {
    *BaseCollectionPaginationCountResponse;
    ChatMessage[] value?;
};

# Represents the Queries record for the operation: getPrimaryChannel
public type GetPrimaryChannelQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

# Represents the Headers record for the operation: deleteChannelMember
public type DeleteChannelMemberHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

# Represents the Queries record for the operation: countPrimaryChannelMessages
public type CountPrimaryChannelMessagesQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

# Represents the Queries record for the operation: listPrimaryChannelMessageHostedContents
public type ListPrimaryChannelMessageHostedContentsQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type EventMessageDetail record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
};

public type FolderView record {
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # If true, indicates that items should be sorted in descending order. Otherwise, items should be sorted ascending
    string? sortOrder?;
    # The type of view that should be used to represent the folder
    string? viewType?;
    # The method by which the folder should be sorted
    string? sortBy?;
};

# Represents the Queries record for the operation: countTags
public type CountTagsQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

public type ChannelMembershipType "standard"|"private"|"unknownFutureValue"|"shared";

# Represents the Headers record for the operation: deleteChannel
public type DeleteChannelHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

# Represents the Queries record for the operation: getPrimaryChannelMessage
public type GetPrimaryChannelMessageQueries record {
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type TeamworkTag record {
    *Entity;
    # The name of the tag as it appears to the user in Microsoft Teams
    string? displayName?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The number of users assigned to the tag
    decimal? memberCount?;
    # ID of the team in which the tag is defined
    string? teamId?;
    # The type of the tag. Default is standard
    TeamworkTagType|record {} tagType?;
    # The description of the tag as it appears to the user in Microsoft Teams. A teamworkTag can't have more than 200 teamworkTagMembers
    string? description?;
};

public type TeamSpecialization "none"|"educationStandard"|"educationClass"|"educationProfessionalLearningCommunity"|"educationStaff"|"healthcareStandard"|"healthcareCareCoordination"|"unknownFutureValue";

# Represents the Queries record for the operation: listPrimaryChannelEnabledApps
public type ListPrimaryChannelEnabledAppsQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type ChatMessagePolicyViolation record {
    # Justification text provided by the sender of the message when overriding a policy violation
    string? justificationText?;
    # Indicates the action taken by the user on a message blocked by the DLP provider. Supported values are: NoneOverrideReportFalsePositiveWhen the DLP provider is updating the message for blocking sensitive content, userAction isn't required
    ChatMessagePolicyViolationUserActionTypes|record {} userAction?;
    # Information to display to the message sender about why the message was flagged as a violation
    ChatMessagePolicyViolationPolicyTip|record {} policyTip?;
    # The action taken by the DLP provider on the message with sensitive content. Supported values are: NoneNotifySender -- Inform the sender of the violation but allow readers to read the message.BlockAccess -- Block readers from reading the message.BlockAccessExternal -- Block users outside the organization from reading the message, while allowing users within the organization to read the message
    ChatMessagePolicyViolationDlpActionTypes|record {} dlpAction?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # Indicates what actions the sender may take in response to the policy violation. Supported values are: NoneAllowFalsePositiveOverride -- Allows the sender to declare the policyViolation to be an error in the DLP app and its rules, and allow readers to see the message again if the dlpAction hides it.AllowOverrideWithoutJustification -- Allows the sender to override the DLP violation and allow readers to see the message again if the dlpAction hides it, without needing to provide an explanation for doing so. AllowOverrideWithJustification -- Allows the sender to override the DLP violation and allow readers to see the message again if the dlpAction hides it, after providing an explanation for doing so.AllowOverrideWithoutJustification and AllowOverrideWithJustification are mutually exclusive
    ChatMessagePolicyViolationVerdictDetailsTypes|record {} verdictDetails?;
};

public type TeamworkConversationIdentity record {
    *Identity;
    # Type of conversation. The possible values are: team, channel, chat, and unknownFutureValue
    TeamworkConversationIdentityType|record {} conversationIdentityType?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType = "#microsoft.graph.teamworkConversationIdentity";
};

# Represents the Queries record for the operation: countChannelMessageReplies
public type CountChannelMessageRepliesQueries record {
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
};

# Represents the Headers record for the operation: deletePrimaryChannelAllMember
public type DeletePrimaryChannelAllMemberHeaders record {
    # ETag
    @http:Header {name: "If-Match"}
    string ifMatch?;
};

public type ChatMessageReaction record {
    # The reaction type. Supported values include Unicode characters, custom, and some backward-compatible reaction types, such as like, angry, sad, laugh, heart, and surprised
    string reactionType?;
    # The name of the reaction
    string? displayName?;
    # The hosted content URL for the custom reaction type
    string? reactionContentUrl?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType?;
    # The timestamp type represents date and time information using ISO 8601 format and is always in UTC. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z
    @constraint:String {pattern: re `^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?(Z|[+-][0-9][0-9]:[0-9][0-9])$`}
    string createdDateTime?;
    ChatMessageReactionIdentitySet user?;
};

public type DriveItem record {
    *BaseItem;
    # Search metadata, if the item is from a search result. Read-only
    SearchResult|record {} searchResult?;
    # Indicates that the item was shared with others and provides information about the shared state of the item. Read-only
    Shared|record {} shared?;
    @jsondata:Name {value: "@odata.type"}
    string atOdataType = "#microsoft.graph.driveItem";
    # Video metadata, if the item is a video. Read-only
    Video|record {} video?;
    # Returns identifiers useful for SharePoint REST compatibility. Read-only
    SharepointIds|record {} sharepointIds?;
    # The content stream, if the item represents a file
    string? content?;
    # File metadata, if the item is a file. Read-only
    File|record {} file?;
    # If present, indicates that one or more operations that might affect the state of the driveItem are pending completion. Read-only
    PendingOperations|record {} pendingOperations?;
    # Provides information about the published or checked-out state of an item, in locations that support such actions. This property isn't returned by default. Read-only
    PublicationFacet|record {} publication?;
    # If this property is non-null, it indicates that the driveItem is the top-most driveItem in the drive
    Root|record {} root?;
    # An eTag for the content of the item. This eTag isn't changed if only the metadata is changed. Note This property isn't returned if the item is a folder. Read-only
    string? cTag?;
    # Audio metadata, if the item is an audio file. Read-only. Read-only. Only on OneDrive Personal
    Audio|record {} audio?;
    # Bundle metadata, if the item is a bundle. Read-only
    Bundle|record {} bundle?;
    # Image metadata, if the item is an image. Read-only
    Image|record {} image?;
    # Malware metadata, if the item was detected to contain malware. Read-only
    Malware|record {} malware?;
    # If present, indicates that this item is a package instead of a folder or file. Packages are treated like files in some contexts and folders in others. Read-only
    Package|record {} package?;
    # Photo metadata, if the item is a photo. Read-only
    Photo|record {} photo?;
    # WebDAV compatible URL for the item
    string? webDavUrl?;
    # Information about the deleted state of the item. Read-only
    Deleted|record {} deleted?;
    # Folder metadata, if the item is a folder. Read-only
    Folder|record {} folder?;
    # Size of the item in bytes. Read-only
    decimal? size?;
    # Remote item data, if the item is shared from a drive other than the one being accessed. Read-only
    RemoteItem|record {} remoteItem?;
    # Location metadata, if the item has location data. Read-only
    GeoCoordinates|record {} location?;
    # If the current item is also available as a special folder, this facet is returned. Read-only
    SpecialFolder|record {} specialFolder?;
    # File system information on client. Read-write
    FileSystemInfo|record {} fileSystemInfo?;
};

# Represents the Queries record for the operation: listChannelAllMembers
public type ListChannelAllMembersQueries record {
    # Skip the first n items
    @http:Query {name: "$skip"}
    int dollarSkip?;
    # Show only the first n items
    @http:Query {name: "$top"}
    int dollarTop?;
    # Filter items by property values
    @http:Query {name: "$filter"}
    string dollarFilter?;
    # Search items by search phrases
    @http:Query {name: "$search"}
    string dollarSearch?;
    # Order items by property values
    @http:Query {name: "$orderby"}
    string[] dollarOrderby?;
    # Expand related entities
    @http:Query {name: "$expand"}
    string[] dollarExpand?;
    # Include count of items
    @http:Query {name: "$count"}
    boolean dollarCount?;
    # Select properties to be returned
    @http:Query {name: "$select"}
    string[] dollarSelect?;
};

public type ChatMessageResponse ChatMessage|EmptyResponse?;

public type ChatMessageImportance "normal"|"high"|"urgent"|"unknownFutureValue";

