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

public enum TeamSpecialization {
    NONE = "none",
    EDUCATION_STANDARED = "educationStandard",
    EDUCATION_CLASS = "educationClass",
    EDUCATION_PROFESSIONAL = "educationProfessionalLearningCommunity",
    EDUCATION_STAFF = "educationStaff",
    UNKNOWN_FUTURE = "unknownFutureValue"
}

public enum TeamVisibility {
    PRIVATE = "private",
    PUBLIC = "public"
}

public enum GiphyContentRating {
    MODERATE = "moderate",
    STRICT = "strict"
}

public enum AsyncOperationType {
    INVALID = "invalid",
    CLONE_TEAM = "cloneTeam",
    ARCHIVE_TEAM = "archiveTeam",
    UNARCHIVE_TEAM = "unarchiveTeam",
    CREATE_TEAM = "createTeam"
}

public enum AsyncOperationStatus {
    INVALID_STATUS = "invalid",
    NOT_STARTED = "notStarted",
    IN_PROGRESS = "inProgress",
    SUCCEEDED = "succeeded",
    FAILED = "failed"
}

public enum ChannelMemberhipType {
    STANDARD_CHANNEL = "standard",
    PRIVATE_CHANNEL ="private"
}

public enum MessageImportance {
    NORMAL = "normal",
    HIGH = "high",
    URGENT = "urgent"
}

public enum MessageContentType {
    TEXT = "text",
    HTML = "html"
}

public enum ChatType {
    ONETOONE = "oneOnOne",
    GROUP = "group"
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
