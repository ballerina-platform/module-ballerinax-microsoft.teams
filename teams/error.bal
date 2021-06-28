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
public type Error PayloadValidationError|QueryParameterValidationError|InputValidationError|RequestFailedError|AsyncRequestFailedError|error;

# Error messages
const INVALID_RESPONSE = "Invalid response";
const INVALID_PAYLOAD = "Invalid payload";
const INVALID_MESSAGE = "Message cannot exceed 2000 characters";
const ASYNC_REQUEST_FAILED = "Asynchronous Job failed";
const INVALID_QUERY_PARAMETER = "Invalid query parameter";
const MAX_FRAGMENT_SIZE_EXCEEDED = "The content exceeds the maximum fragment size";
