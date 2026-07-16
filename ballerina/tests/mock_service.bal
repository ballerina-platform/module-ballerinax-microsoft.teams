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

listener http:Listener ep0 = new (9090);

type Route record {|
    string verb;
    string[] tokens;
    string shape;
|};

// Route table generated from the connector's 186 operations. Each entry maps an
// HTTP method + path pattern ("*" = path parameter) to the response shape the
// client expects, so the mock can answer every endpoint with a bindable payload.
// Built with incremental pushes rather than one large literal to keep codegen happy.
final Route[] routes = buildRoutes();

function buildRoutes() returns Route[] {
    Route[] routes = [];
    routes.push({verb: "post", tokens: ["teams"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "allChannels"], shape: "collection"});
    routes.push({verb: "get", tokens: ["teams", "*", "allChannels", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "allChannels", "$count"], shape: "count"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "channels", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "channels", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "allMembers"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "allMembers"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "allMembers", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "channels", "*", "allMembers", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "channels", "*", "allMembers", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "allMembers", "$count"], shape: "count"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "allMembers", "add"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "allMembers", "remove"], shape: "collection"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "enabledApps"], shape: "collection"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "enabledApps", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "enabledApps", "$count"], shape: "count"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "filesFolder"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "filesFolder", "content"], shape: "bytes"});
    routes.push({verb: "put", tokens: ["teams", "*", "channels", "*", "filesFolder", "content"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "channels", "*", "filesFolder", "content"], shape: "empty"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "members"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "members"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "members", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "channels", "*", "members", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "channels", "*", "members", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "members", "$count"], shape: "count"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "members", "add"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "members", "remove"], shape: "collection"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "messages"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "channels", "*", "messages", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "channels", "*", "messages", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "*", "hostedContents"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "messages", "*", "hostedContents"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "*", "hostedContents", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "channels", "*", "messages", "*", "hostedContents", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "channels", "*", "messages", "*", "hostedContents", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "*", "hostedContents", "*", "$value"], shape: "bytes"});
    routes.push({verb: "put", tokens: ["teams", "*", "channels", "*", "messages", "*", "hostedContents", "*", "$value"], shape: "empty"});
    routes.push({verb: "delete", tokens: ["teams", "*", "channels", "*", "messages", "*", "hostedContents", "*", "$value"], shape: "empty"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "*", "hostedContents", "$count"], shape: "count"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "messages", "*", "setReaction"], shape: "empty"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "messages", "*", "softDelete"], shape: "empty"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "messages", "*", "undoSoftDelete"], shape: "empty"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "messages", "*", "unsetReaction"], shape: "empty"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*", "hostedContents"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*", "hostedContents"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*", "hostedContents", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*", "hostedContents", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*", "hostedContents", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*", "hostedContents", "*", "$value"], shape: "bytes"});
    routes.push({verb: "put", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*", "hostedContents", "*", "$value"], shape: "empty"});
    routes.push({verb: "delete", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*", "hostedContents", "*", "$value"], shape: "empty"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*", "hostedContents", "$count"], shape: "count"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*", "setReaction"], shape: "empty"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*", "softDelete"], shape: "empty"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*", "undoSoftDelete"], shape: "empty"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "*", "unsetReaction"], shape: "empty"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "$count"], shape: "count"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "delta()"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "messages", "*", "replies", "replyWithQuote"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "$count"], shape: "count"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "messages", "delta()"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "messages", "replyWithQuote"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "tabs"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "channels", "*", "tabs"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "tabs", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "channels", "*", "tabs", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "channels", "*", "tabs", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "tabs", "*", "teamsApp"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "*", "tabs", "$count"], shape: "count"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "$count"], shape: "count"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "getAllMessages()"], shape: "collection"});
    routes.push({verb: "get", tokens: ["teams", "*", "channels", "getAllRetainedMessages()"], shape: "collection"});
    routes.push({verb: "get", tokens: ["teams", "*", "incomingChannels"], shape: "collection"});
    routes.push({verb: "get", tokens: ["teams", "*", "incomingChannels", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "incomingChannels", "$count"], shape: "count"});
    routes.push({verb: "get", tokens: ["teams", "*", "members"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "members"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "members", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "members", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "members", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "members", "$count"], shape: "count"});
    routes.push({verb: "post", tokens: ["teams", "*", "members", "add"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "members", "remove"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "sendActivityNotification"], shape: "empty"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "primaryChannel"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "primaryChannel"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "allMembers"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "allMembers"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "allMembers", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "primaryChannel", "allMembers", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "primaryChannel", "allMembers", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "allMembers", "$count"], shape: "count"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "allMembers", "add"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "allMembers", "remove"], shape: "collection"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "enabledApps"], shape: "collection"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "enabledApps", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "enabledApps", "$count"], shape: "count"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "filesFolder"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "filesFolder", "content"], shape: "bytes"});
    routes.push({verb: "put", tokens: ["teams", "*", "primaryChannel", "filesFolder", "content"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "primaryChannel", "filesFolder", "content"], shape: "empty"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "members"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "members"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "members", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "primaryChannel", "members", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "primaryChannel", "members", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "members", "$count"], shape: "count"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "members", "add"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "members", "remove"], shape: "collection"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "messages"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "primaryChannel", "messages", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "primaryChannel", "messages", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "*", "hostedContents"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "messages", "*", "hostedContents"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "*", "hostedContents", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "primaryChannel", "messages", "*", "hostedContents", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "primaryChannel", "messages", "*", "hostedContents", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "*", "hostedContents", "*", "$value"], shape: "bytes"});
    routes.push({verb: "put", tokens: ["teams", "*", "primaryChannel", "messages", "*", "hostedContents", "*", "$value"], shape: "empty"});
    routes.push({verb: "delete", tokens: ["teams", "*", "primaryChannel", "messages", "*", "hostedContents", "*", "$value"], shape: "empty"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "*", "hostedContents", "$count"], shape: "count"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "messages", "*", "setReaction"], shape: "empty"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "messages", "*", "softDelete"], shape: "empty"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "messages", "*", "undoSoftDelete"], shape: "empty"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "messages", "*", "unsetReaction"], shape: "empty"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*", "hostedContents"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*", "hostedContents"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*", "hostedContents", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*", "hostedContents", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*", "hostedContents", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*", "hostedContents", "*", "$value"], shape: "bytes"});
    routes.push({verb: "put", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*", "hostedContents", "*", "$value"], shape: "empty"});
    routes.push({verb: "delete", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*", "hostedContents", "*", "$value"], shape: "empty"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*", "hostedContents", "$count"], shape: "count"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*", "setReaction"], shape: "empty"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*", "softDelete"], shape: "empty"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*", "undoSoftDelete"], shape: "empty"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "*", "unsetReaction"], shape: "empty"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "$count"], shape: "count"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "delta()"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "messages", "*", "replies", "replyWithQuote"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "$count"], shape: "count"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "messages", "delta()"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "messages", "replyWithQuote"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "tabs"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "primaryChannel", "tabs"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "tabs", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "primaryChannel", "tabs", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "primaryChannel", "tabs", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "tabs", "*", "teamsApp"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "primaryChannel", "tabs", "$count"], shape: "count"});
    routes.push({verb: "get", tokens: ["teams", "*", "tags"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "tags"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "tags", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "tags", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "tags", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "tags", "*", "members"], shape: "collection"});
    routes.push({verb: "post", tokens: ["teams", "*", "tags", "*", "members"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "tags", "*", "members", "*"], shape: "entity"});
    routes.push({verb: "delete", tokens: ["teams", "*", "tags", "*", "members", "*"], shape: "empty"});
    routes.push({verb: "patch", tokens: ["teams", "*", "tags", "*", "members", "*"], shape: "entity"});
    routes.push({verb: "get", tokens: ["teams", "*", "tags", "*", "members", "$count"], shape: "count"});
    routes.push({verb: "get", tokens: ["teams", "*", "tags", "$count"], shape: "count"});
    return routes;
}

function shapeFor(string verb, string[] path) returns string {
    string best = "entity";
    int bestScore = -1;
    foreach Route route in routes {
        if route.verb != verb || route.tokens.length() != path.length() {
            continue;
        }
        int score = 0;
        boolean matched = true;
        foreach int i in 0 ..< path.length() {
            string t = route.tokens[i];
            if t == "*" {
                continue;
            }
            if t == path[i] {
                score += 1;
            } else {
                matched = false;
                break;
            }
        }
        if matched && score > bestScore {
            bestScore = score;
            best = route.shape;
        }
    }
    return best;
}

function mockResponse(string verb, string[] path) returns http:Response {
    http:Response response = new;
    match shapeFor(verb, path) {
        "empty" => {
            response.statusCode = 204;
        }
        "count" => {
            response.setTextPayload("5");
        }
        "bytes" => {
            response.setBinaryPayload("mock-content".toBytes());
        }
        "collection" => {
            response.setJsonPayload({"@odata.count": 0, "value": []});
        }
        _ => {
            response.setJsonPayload({"@odata.type": "#microsoft.graph.entity", "id": "test-id"});
        }
    }
    return response;
}

service /v1\.0 on ep0 {
    resource function get [string... path](http:Request request) returns http:Response {
        return mockResponse("get", path);
    }

    resource function post [string... path](http:Request request) returns http:Response {
        return mockResponse("post", path);
    }

    resource function put [string... path](http:Request request) returns http:Response {
        return mockResponse("put", path);
    }

    resource function patch [string... path](http:Request request) returns http:Response {
        return mockResponse("patch", path);
    }

    resource function delete [string... path](http:Request request) returns http:Response {
        return mockResponse("delete", path);
    }
}
