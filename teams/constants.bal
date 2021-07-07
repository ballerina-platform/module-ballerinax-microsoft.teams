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

# Constant field `BASE_URL`. Holds the value of the Microsoft graph API's endpoint URL.
const string BASE_URL = "https://graph.microsoft.com/v1.0";

# Indicates whether the team is intended for a particular use case.
#
# + NONE - Default type for a team which gives the standard team experience
# + EDUCATION_STANDARED - Team created by an education user. All teams created by education user are of type Edu
# + EDUCATION_CLASS - Team experience optimized for a class. This enables segmentation of features across O365.
# + EDUCATION_PROFESSIONAL - Team experience optimized for a PLC(Professional Learning Community)
# + EDUCATION_STAFF - Team type for an optimized experience for staff in an organization, where a staff leader, like a
#                     principal, is the admin and teachers are members in a team that comes with a specialized notebook
# + UNKNOWN_FUTURE - Sentinel value reserved as a placeholder for future expansion of the enum
public enum TeamSpecialization {
    NONE = "none",
    EDUCATION_STANDARED = "educationStandard",
    EDUCATION_CLASS = "educationClass",
    EDUCATION_PROFESSIONAL = "educationProfessionalLearningCommunity",
    EDUCATION_STAFF = "educationStaff",
    UNKNOWN_FUTURE = "unknownFutureValue"
}

# Describes the visibility of a team.
#
# + PRIVATE - Anyone can see the team but only the owner can add a user to the team
# + PUBLIC - Anyone can join the team
public enum TeamVisibility {
    PRIVATE = "private",
    PUBLIC = "public"
}

# Giphy content rating.
#
# + MODERATE - Moderate content rating
# + STRICT - Strict content rating
public enum GiphyContentRating {
    MODERATE = "moderate",
    STRICT = "strict"
}

# The type of the channel.
#
# + STANDARD_CHANNEL - hannel inherits the list of members of the parent team
# + PRIVATE_CHANNEL - Channel can have members that are a subset of all the members on the parent team
public enum ChannelMemberhipType {
    STANDARD_CHANNEL = "standard",
    PRIVATE_CHANNEL ="private"
}

# The importance of the chat message.
#
# + NORMAL - Normal message
# + HIGH - Important message
# + URGENT - Urgent message
public enum MessageImportance {
    NORMAL = "normal",
    HIGH = "high",
    URGENT = "urgent"
}

# The type of the content.
#
# + TEXT - Text content
# + HTML - HTML content
public enum MessageContentType {
    TEXT = "text",
    HTML = "html"
}

# Specifies the type of chat.
#
# + ONETOONE - Indicates that the chat is a 1:1 chat. The roster size is fixed for this type of chat; members cannot
#              be removed/added.
# + GROUP - Indicates that the chat is a group chat. The roster size (of at least two people) can be updated for this
#           type of chat. Members can be removed/added later.
public enum ChatType {
    ONETOONE = "oneOnOne",
    GROUP = "group"
}

# The role of a user.
#
# + OWNER - Owner role
# + MEMBER - Member role
public enum Role {
    OWNER = "owner",
    MEMBER = "member"
}

# The reaction type
#
# + LIKE - Like
# + ANGRY - Angry
# + SAD - Sad
# + LAUGH - Laugh
# + HEART - Heart
# + SURPRISED - Surprised
public enum ReactionType {
    LIKE = "like",
    ANGRY = "angry",
    SAD = "sad",
    LAUGH = "laugh",
    HEART = "heart",
    SURPRISED = "surprised"
}

# Numbers
const ZERO = 0;

# Symbols
const EQUAL_SIGN = "=";
const URL_PREFIX = "u!";
const EMPTY_STRING = "";
const DOLLAR_SIGN = "$";
const UNDERSCORE = "_";
const MINUS_SIGN = "-";
const PLUS_REGEX = "\\+";
const FORWARD_SLASH = "/";
const AMPERSAND = "&";
const QUESTION_MARK = "?";

# Resources
const TEAMS_RESOURCE = "teams";
const TEAM_RESOURCE = "team";
const GROUPS_RESOURCE = "groups";
const MEMBERS_RESOURCE = "members";
const CHANNELS_RESOURCE = "channels";
const MESSAGES_RESOURCE = "messages";
const CHATS_RESOURCE = "chats";
const REPLIES_RESOURCE = "replies";

# Util file enums
enum SystemQueryOption {
    EXPAND = "expand",
    SELECT = "select",
    FILTER = "filter",
    COUNT = "count",
    ORDERBY = "orderby",
    SKIP = "skip",
    TOP = "top",
    SEARCH = "search",
    BATCH = "batch",
    FORMAT = "format"
}

enum OpeningCharacters {
    OPEN_BRACKET = "(",
    OPEN_SQURAE_BRACKET = "[",
    OPEN_CURLY_BRACKET = "{",
    SINGLE_QUOTE_O = "'",
    DOUBLE_QUOTE_O = "\""
}

enum ClosingCharacters {
    CLOSE_BRACKET = ")",
    CLOSE_SQURAE_BRACKET = "]",
    CLOSE_CURLY_BRACKET = "}",
    SINGLE_QUOTE_C = "'",
    DOUBLE_QUOTE_C = "\""
}

enum AsyncOperationType {
    INVALID = "invalid",
    CLONE_TEAM = "cloneTeam",
    ARCHIVE_TEAM = "archiveTeam",
    UNARCHIVE_TEAM = "unarchiveTeam",
    CREATE_TEAM = "createTeam"
}

enum AsyncOperationStatus {
    INVALID_STATUS = "invalid",
    NOT_STARTED = "notStarted",
    IN_PROGRESS = "inProgress",
    SUCCEEDED = "succeeded",
    FAILED = "failed"
}
