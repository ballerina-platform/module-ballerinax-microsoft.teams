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

# The map which contains extra details of an error.
#
# + code - The status code 
# + message - The error message
public type OperationError record {
    string code;
    string message?;
};

# An error which occur when providing an invalid value
public type InputValidationError distinct error;

# An errror occur due to an invalid payload received
public type PayloadValidationError distinct error;

# An error which occur when there is an invalid query parameter
public type QueryParameterValidationError distinct error;

# An error occur due to a failed failed request attempt
public type RequestFailedError distinct error;

# An error occur due to a failed failed request attempt
public type AsyncRequestFailedError error<OperationError>;

# Union of all types of errors
public type Error PayloadValidationError|QueryParameterValidationError|InputValidationError|RequestFailedError|
    AsyncRequestFailedError|error;

# Error messages
const INVALID_RESPONSE = "Invalid response";
const INVALID_PAYLOAD = "Invalid payload";
const INVALID_MESSAGE = "Message cannot exceed 2000 characters";
const ASYNC_REQUEST_FAILED = "Asynchronous Job failed";
const INVALID_QUERY_PARAMETER = "Invalid query parameter";
const MAX_FRAGMENT_SIZE_EXCEEDED = "The content exceeds the maximum fragment size";
