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

import ballerina/data.jsondata;
import ballerina/http;

# This OData service is located at https://graph.microsoft.com/v1.0
public isolated client class Client {
    final http:Client clientEp;
    # Gets invoked to initialize the `connector`.
    #
    # + config - The configurations to be used when initializing the `connector` 
    # + serviceUrl - URL of the target service 
    # + return - An error if connector initialization failed 
    public isolated function init(ConnectionConfig config, string serviceUrl = "https://graph.microsoft.com/v1.0") returns error? {
        http:ClientConfiguration httpClientConfig = {auth: config.auth, httpVersion: config.httpVersion, http1Settings: config.http1Settings, http2Settings: config.http2Settings, timeout: config.timeout, forwarded: config.forwarded, followRedirects: config.followRedirects, poolConfig: config.poolConfig, cache: config.cache, compression: config.compression, circuitBreaker: config.circuitBreaker, retryConfig: config.retryConfig, cookieConfig: config.cookieConfig, responseLimits: config.responseLimits, secureSocket: config.secureSocket, proxy: config.proxy, socketConfig: config.socketConfig, validation: config.validation, laxDataBinding: config.laxDataBinding};
        self.clientEp = check new (serviceUrl, httpClientConfig);
    }

    # Create team
    #
    # + headers - Headers to be sent with the request 
    # + payload - New entity 
    # + return - Created entity 
    remote isolated function createTeam(MicrosoftGraphTeam payload, map<string|string[]> headers = {}) returns MicrosoftGraphTeam|error {
        string resourcePath = string `/teams`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        // Team creation is asynchronous: Graph responds 202 Accepted with an empty body and the new
        // team's location in a header, so the raw response is inspected rather than bound directly.
        http:Response response = check self.clientEp->post(resourcePath, request, headers);
        check validateResponse(response);
        if response.statusCode == 202 || response.statusCode == 204 {
            string? teamId = asyncCreatedId(response, "teams");
            if teamId is string {
                return {id: teamId};
            }
            return error("Team was created asynchronously but its id was not returned in the response headers");
        }
        json responseBody = check response.getJsonPayload();
        return jsondata:parseAsType(responseBody);
    }

    # Get team
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved entity 
    remote isolated function getTeam(string teamId, map<string|string[]> headers = {}, *GetTeamQueries queries) returns MicrosoftGraphTeam|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete entity from teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteTeam(string teamId, DeleteTeamHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update team
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - New property values 
    # + return - Success 
    remote isolated function updateTeam(string teamId, MicrosoftGraphTeam payload, map<string|string[]> headers = {}) returns MicrosoftGraphTeam|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        // A team PATCH returns 204 No Content; re-fetch so the updated entity can still be returned.
        http:Response response = check self.clientEp->patch(resourcePath, request, headers);
        check validateResponse(response);
        if response.statusCode == 204 {
            return self.clientEp->get(resourcePath);
        }
        json responseBody = check response.getJsonPayload();
        return jsondata:parseAsType(responseBody);
    }

    # List allChannels
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listAllChannels(string teamId, map<string|string[]> headers = {}, *ListAllChannelsQueries queries) returns MicrosoftGraphChannelCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/allChannels`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get allChannels from teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getAllChannel(string teamId, string channelId, map<string|string[]> headers = {}, *GetAllChannelQueries queries) returns MicrosoftGraphChannel|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/allChannels/${getEncodedUri(channelId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countAllChannels(string teamId, map<string|string[]> headers = {}, *CountAllChannelsQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/allChannels/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # List channels
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listChannels(string teamId, map<string|string[]> headers = {}, *ListChannelsQueries queries) returns MicrosoftGraphChannelCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Create channel
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createChannel(string teamId, MicrosoftGraphChannel payload, map<string|string[]> headers = {}) returns MicrosoftGraphChannel|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        // Standard channels are created synchronously (201 with the channel body), but private and
        // shared channels are created asynchronously (202 Accepted, empty body, id in a header), so
        // both shapes are handled here.
        http:Response response = check self.clientEp->post(resourcePath, request, headers);
        check validateResponse(response);
        if response.statusCode == 202 || response.statusCode == 204 {
            string? channelId = asyncCreatedId(response, "channels");
            if channelId is string {
                return {id: channelId};
            }
            return error("Channel was created asynchronously but its id was not returned in the response headers");
        }
        json responseBody = check response.getJsonPayload();
        return jsondata:parseAsType(responseBody);
    }

    # Get channel
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getChannel(string teamId, string channelId, map<string|string[]> headers = {}, *GetChannelQueries queries) returns MicrosoftGraphChannel|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete channel
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteChannel(string teamId, string channelId, DeleteChannelHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Patch channel
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updateChannel(string teamId, string channelId, MicrosoftGraphChannel payload, map<string|string[]> headers = {}) returns MicrosoftGraphChannel|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        // A channel PATCH returns 204 No Content; re-fetch so the updated entity can still be returned.
        http:Response response = check self.clientEp->patch(resourcePath, request, headers);
        check validateResponse(response);
        if response.statusCode == 204 {
            return self.clientEp->get(resourcePath);
        }
        json responseBody = check response.getJsonPayload();
        return jsondata:parseAsType(responseBody);
    }

    # List allMembers
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listChannelAllMembers(string teamId, string channelId, map<string|string[]> headers = {}, *ListChannelAllMembersQueries queries) returns MicrosoftGraphConversationMemberCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/allMembers`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Create new navigation property to allMembers for teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createChannelAllMember(string teamId, string channelId, MicrosoftGraphConversationMember payload, map<string|string[]> headers = {}) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/allMembers`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get allMembers from teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getChannelAllMember(string teamId, string channelId, string conversationMemberId, map<string|string[]> headers = {}, *GetChannelAllMemberQueries queries) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/allMembers/${getEncodedUri(conversationMemberId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete navigation property allMembers for teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteChannelAllMember(string teamId, string channelId, string conversationMemberId, DeleteChannelAllMemberHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/allMembers/${getEncodedUri(conversationMemberId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update the navigation property allMembers in teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updateChannelAllMember(string teamId, string channelId, string conversationMemberId, MicrosoftGraphConversationMember payload, map<string|string[]> headers = {}) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/allMembers/${getEncodedUri(conversationMemberId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countChannelAllMembers(string teamId, string channelId, map<string|string[]> headers = {}, *CountChannelAllMembersQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/allMembers/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke action add
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function addChannelAllMembers(string teamId, string channelId, AddMembersRequest payload, map<string|string[]> headers = {}) returns ActionResultPartCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/allMembers/add`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action remove
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function removeChannelAllMembers(string teamId, string channelId, AddMembersRequest payload, map<string|string[]> headers = {}) returns ActionResultPartCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/allMembers/remove`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # List enabledApps
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listChannelEnabledApps(string teamId, string channelId, map<string|string[]> headers = {}, *ListChannelEnabledAppsQueries queries) returns MicrosoftGraphTeamsAppCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/enabledApps`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get teamsApp
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + teamsAppId - The unique identifier of teamsApp
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getChannelEnabledApp(string teamId, string channelId, string teamsAppId, map<string|string[]> headers = {}, *GetChannelEnabledAppQueries queries) returns MicrosoftGraphTeamsApp|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/enabledApps/${getEncodedUri(teamsAppId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countChannelEnabledApps(string teamId, string channelId, map<string|string[]> headers = {}, *CountChannelEnabledAppsQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/enabledApps/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get filesFolder
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getChannelFilesFolder(string teamId, string channelId, map<string|string[]> headers = {}, *GetChannelFilesFolderQueries queries) returns MicrosoftGraphDriveItem|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/filesFolder`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get content for the navigation property filesFolder from teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved media content 
    remote isolated function getChannelFilesFolderContent(string teamId, string channelId, map<string|string[]> headers = {}, *GetChannelFilesFolderContentQueries queries) returns byte[]|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/filesFolder/content`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Update content for the navigation property filesFolder in teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + payload - New media content 
    # + return - Success 
    remote isolated function updateChannelFilesFolderContent(string teamId, string channelId, byte[] payload, map<string|string[]> headers = {}) returns MicrosoftGraphDriveItem|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/filesFolder/content`;
        http:Request request = new;
        request.setPayload(payload, "application/octet-stream");
        return self.clientEp->put(resourcePath, request, headers);
    }

    # Delete content for the navigation property filesFolder in teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteChannelFilesFolderContent(string teamId, string channelId, DeleteChannelFilesFolderContentHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/filesFolder/content`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # List members of a channel
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listChannelMembers(string teamId, string channelId, map<string|string[]> headers = {}, *ListChannelMembersQueries queries) returns MicrosoftGraphConversationMemberCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/members`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Add member to channel
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createChannelMember(string teamId, string channelId, MicrosoftGraphConversationMember payload, map<string|string[]> headers = {}) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/members`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get member of channel
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getChannelMember(string teamId, string channelId, string conversationMemberId, map<string|string[]> headers = {}, *GetChannelMemberQueries queries) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/members/${getEncodedUri(conversationMemberId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Remove member from channel
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteChannelMember(string teamId, string channelId, string conversationMemberId, DeleteChannelMemberHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/members/${getEncodedUri(conversationMemberId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update member in channel
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updateChannelMember(string teamId, string channelId, string conversationMemberId, MicrosoftGraphConversationMember payload, map<string|string[]> headers = {}) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/members/${getEncodedUri(conversationMemberId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countChannelMembers(string teamId, string channelId, map<string|string[]> headers = {}, *CountChannelMembersQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/members/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke action add
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function addChannelMembers(string teamId, string channelId, AddMembersRequest payload, map<string|string[]> headers = {}) returns ActionResultPartCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/members/add`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action remove
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function removeChannelMembers(string teamId, string channelId, AddMembersRequest payload, map<string|string[]> headers = {}) returns ActionResultPartCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/members/remove`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # List channel messages
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listChannelMessages(string teamId, string channelId, map<string|string[]> headers = {}, *ListChannelMessagesQueries queries) returns MicrosoftGraphChatMessageCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Send chatMessage in channel
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createChannelMessage(string teamId, string channelId, MicrosoftGraphChatMessage payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessage|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get chatMessage in a channel or chat
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getChannelMessage(string teamId, string channelId, string chatMessageId, map<string|string[]> headers = {}, *GetChannelMessageQueries queries) returns MicrosoftGraphChatMessage|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete navigation property messages for teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteChannelMessage(string teamId, string channelId, string chatMessageId, DeleteChannelMessageHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update chatMessage
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updateChannelMessage(string teamId, string channelId, string chatMessageId, MicrosoftGraphChatMessage payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessage|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # List hostedContents
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listChannelMessageHostedContents(string teamId, string channelId, string chatMessageId, map<string|string[]> headers = {}, *ListChannelMessageHostedContentsQueries queries) returns MicrosoftGraphChatMessageHostedContentCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/hostedContents`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Create new navigation property to hostedContents for teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createChannelMessageHostedContent(string teamId, string channelId, string chatMessageId, MicrosoftGraphChatMessageHostedContent payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessageHostedContent|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/hostedContents`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get hostedContents from teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getChannelMessageHostedContent(string teamId, string channelId, string chatMessageId, string chatMessageHostedContentId, map<string|string[]> headers = {}, *GetChannelMessageHostedContentQueries queries) returns MicrosoftGraphChatMessageHostedContent|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete navigation property hostedContents for teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteChannelMessageHostedContent(string teamId, string channelId, string chatMessageId, string chatMessageHostedContentId, DeleteChannelMessageHostedContentHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update the navigation property hostedContents in teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updateChannelMessageHostedContent(string teamId, string channelId, string chatMessageId, string chatMessageHostedContentId, MicrosoftGraphChatMessageHostedContent payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessageHostedContent|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # List hostedContents
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + return - Retrieved media content 
    remote isolated function getChannelMessageHostedContentValue(string teamId, string channelId, string chatMessageId, string chatMessageHostedContentId, map<string|string[]> headers = {}) returns byte[]|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}/$value`;
        return self.clientEp->get(resourcePath, headers);
    }

    # Update media content for the navigation property hostedContents in teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + payload - New media content 
    # + return - Success 
    remote isolated function updateChannelMessageHostedContentValue(string teamId, string channelId, string chatMessageId, string chatMessageHostedContentId, byte[] payload, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}/$value`;
        http:Request request = new;
        request.setPayload(payload, "application/octet-stream");
        return self.clientEp->put(resourcePath, request, headers);
    }

    # Delete media content for the navigation property hostedContents in teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteChannelMessageHostedContentValue(string teamId, string channelId, string chatMessageId, string chatMessageHostedContentId, DeleteChannelMessageHostedContentValueHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}/$value`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countChannelMessageHostedContents(string teamId, string channelId, string chatMessageId, map<string|string[]> headers = {}, *CountChannelMessageHostedContentsQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/hostedContents/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke action setReaction
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function setReactionChannelMessage(string teamId, string channelId, string chatMessageId, SetReactionRequest payload, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/setReaction`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action softDelete
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function softDeleteChannelMessage(string teamId, string channelId, string chatMessageId, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/softDelete`;
        http:Request request = new;
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action undoSoftDelete
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function undoSoftDeleteChannelMessage(string teamId, string channelId, string chatMessageId, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/undoSoftDelete`;
        http:Request request = new;
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action unsetReaction
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function unsetReactionChannelMessage(string teamId, string channelId, string chatMessageId, SetReactionRequest payload, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/unsetReaction`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # List replies
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listChannelMessageReplies(string teamId, string channelId, string chatMessageId, map<string|string[]> headers = {}, *ListChannelMessageRepliesQueries queries) returns MicrosoftGraphChatMessageCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Reply to a message in a channel
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createChannelMessageReply(string teamId, string channelId, string chatMessageId, MicrosoftGraphChatMessage payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessage|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get chatMessage in a channel or chat
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getChannelMessageReply(string teamId, string channelId, string chatMessageId, string chatMessageId1, map<string|string[]> headers = {}, *GetChannelMessageReplyQueries queries) returns MicrosoftGraphChatMessage|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete navigation property replies for teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteChannelMessageReply(string teamId, string channelId, string chatMessageId, string chatMessageId1, DeleteChannelMessageReplyHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update the navigation property replies in teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updateChannelMessageReply(string teamId, string channelId, string chatMessageId, string chatMessageId1, MicrosoftGraphChatMessage payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessage|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # List hostedContents
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listChannelMessageReplyHostedContents(string teamId, string channelId, string chatMessageId, string chatMessageId1, map<string|string[]> headers = {}, *ListChannelMessageReplyHostedContentsQueries queries) returns MicrosoftGraphChatMessageHostedContentCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Create new navigation property to hostedContents for teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createChannelMessageReplyHostedContent(string teamId, string channelId, string chatMessageId, string chatMessageId1, MicrosoftGraphChatMessageHostedContent payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessageHostedContent|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get hostedContents from teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getChannelMessageReplyHostedContent(string teamId, string channelId, string chatMessageId, string chatMessageId1, string chatMessageHostedContentId, map<string|string[]> headers = {}, *GetChannelMessageReplyHostedContentQueries queries) returns MicrosoftGraphChatMessageHostedContent|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete navigation property hostedContents for teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteChannelMessageReplyHostedContent(string teamId, string channelId, string chatMessageId, string chatMessageId1, string chatMessageHostedContentId, DeleteChannelMessageReplyHostedContentHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update the navigation property hostedContents in teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updateChannelMessageReplyHostedContent(string teamId, string channelId, string chatMessageId, string chatMessageId1, string chatMessageHostedContentId, MicrosoftGraphChatMessageHostedContent payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessageHostedContent|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # List hostedContents
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + return - Retrieved media content 
    remote isolated function getChannelMessageReplyHostedContentValue(string teamId, string channelId, string chatMessageId, string chatMessageId1, string chatMessageHostedContentId, map<string|string[]> headers = {}) returns byte[]|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}/$value`;
        return self.clientEp->get(resourcePath, headers);
    }

    # Update media content for the navigation property hostedContents in teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + payload - New media content 
    # + return - Success 
    remote isolated function updateChannelMessageReplyHostedContentValue(string teamId, string channelId, string chatMessageId, string chatMessageId1, string chatMessageHostedContentId, byte[] payload, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}/$value`;
        http:Request request = new;
        request.setPayload(payload, "application/octet-stream");
        return self.clientEp->put(resourcePath, request, headers);
    }

    # Delete media content for the navigation property hostedContents in teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteChannelMessageReplyHostedContentValue(string teamId, string channelId, string chatMessageId, string chatMessageId1, string chatMessageHostedContentId, DeleteChannelMessageReplyHostedContentValueHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}/$value`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countChannelMessageReplyHostedContents(string teamId, string channelId, string chatMessageId, string chatMessageId1, map<string|string[]> headers = {}, *CountChannelMessageReplyHostedContentsQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke action setReaction
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function setReactionChannelMessageReply(string teamId, string channelId, string chatMessageId, string chatMessageId1, SetReactionRequest payload, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/setReaction`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action softDelete
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function softDeleteChannelMessageReply(string teamId, string channelId, string chatMessageId, string chatMessageId1, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/softDelete`;
        http:Request request = new;
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action undoSoftDelete
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function undoSoftDeleteChannelMessageReply(string teamId, string channelId, string chatMessageId, string chatMessageId1, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/undoSoftDelete`;
        http:Request request = new;
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action unsetReaction
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function unsetReactionChannelMessageReply(string teamId, string channelId, string chatMessageId, string chatMessageId1, SetReactionRequest payload, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/unsetReaction`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countChannelMessageReplies(string teamId, string channelId, string chatMessageId, map<string|string[]> headers = {}, *CountChannelMessageRepliesQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke function delta
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Success 
    remote isolated function getChannelMessageRepliesDelta(string teamId, string channelId, string chatMessageId, map<string|string[]> headers = {}, *GetChannelMessageRepliesDeltaQueries queries) returns ChatMessageDeltaCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/delta()`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$orderby": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke action replyWithQuote
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function replyWithQuoteChannelMessageReplies(string teamId, string channelId, string chatMessageId, ReplyWithQuoteRequest payload, map<string|string[]> headers = {}) returns ChatMessageResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/${getEncodedUri(chatMessageId)}/replies/replyWithQuote`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countChannelMessages(string teamId, string channelId, map<string|string[]> headers = {}, *CountChannelMessagesQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke function delta
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Success 
    remote isolated function getChannelMessagesDelta(string teamId, string channelId, map<string|string[]> headers = {}, *GetChannelMessagesDeltaQueries queries) returns ChatMessageDeltaCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/delta()`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$orderby": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke action replyWithQuote
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function replyWithQuoteChannelMessages(string teamId, string channelId, ReplyWithQuoteRequest payload, map<string|string[]> headers = {}) returns ChatMessageResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/messages/replyWithQuote`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # List tabs in channel
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listChannelTabs(string teamId, string channelId, map<string|string[]> headers = {}, *ListChannelTabsQueries queries) returns MicrosoftGraphTeamsTabCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/tabs`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Add tab to channel
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createChannelTab(string teamId, string channelId, MicrosoftGraphTeamsTab payload, map<string|string[]> headers = {}) returns MicrosoftGraphTeamsTab|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/tabs`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get tab
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + teamsTabId - The unique identifier of teamsTab
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getChannelTab(string teamId, string channelId, string teamsTabId, map<string|string[]> headers = {}, *GetChannelTabQueries queries) returns MicrosoftGraphTeamsTab|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/tabs/${getEncodedUri(teamsTabId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete tab from channel
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + teamsTabId - The unique identifier of teamsTab
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteChannelTab(string teamId, string channelId, string teamsTabId, DeleteChannelTabHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/tabs/${getEncodedUri(teamsTabId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update tab
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + teamsTabId - The unique identifier of teamsTab
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updateChannelTab(string teamId, string channelId, string teamsTabId, MicrosoftGraphTeamsTab payload, map<string|string[]> headers = {}) returns MicrosoftGraphTeamsTab|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/tabs/${getEncodedUri(teamsTabId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # Get teamsApp from teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + teamsTabId - The unique identifier of teamsTab
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getChannelTabTeamsApp(string teamId, string channelId, string teamsTabId, map<string|string[]> headers = {}, *GetChannelTabTeamsAppQueries queries) returns MicrosoftGraphTeamsApp|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/tabs/${getEncodedUri(teamsTabId)}/teamsApp`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countChannelTabs(string teamId, string channelId, map<string|string[]> headers = {}, *CountChannelTabsQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/${getEncodedUri(channelId)}/tabs/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countChannels(string teamId, map<string|string[]> headers = {}, *CountChannelsQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke function getAllMessages
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Success 
    remote isolated function getAllChannelMessages(string teamId, map<string|string[]> headers = {}, *GetAllChannelMessagesQueries queries) returns ChatMessageCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/getAllMessages()`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$orderby": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke function getAllRetainedMessages
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Success 
    remote isolated function getAllRetainedChannelMessages(string teamId, map<string|string[]> headers = {}, *GetAllRetainedChannelMessagesQueries queries) returns ChatMessageCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/channels/getAllRetainedMessages()`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$orderby": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # List incomingChannels
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listIncomingChannels(string teamId, map<string|string[]> headers = {}, *ListIncomingChannelsQueries queries) returns MicrosoftGraphChannelCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/incomingChannels`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get incomingChannels from teams
    #
    # + teamId - The unique identifier of team
    # + channelId - The unique identifier of channel
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getIncomingChannel(string teamId, string channelId, map<string|string[]> headers = {}, *GetIncomingChannelQueries queries) returns MicrosoftGraphChannel|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/incomingChannels/${getEncodedUri(channelId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countIncomingChannels(string teamId, map<string|string[]> headers = {}, *CountIncomingChannelsQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/incomingChannels/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # List members of team
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listMembers(string teamId, map<string|string[]> headers = {}, *ListMembersQueries queries) returns MicrosoftGraphConversationMemberCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/members`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Add member to team
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createMember(string teamId, MicrosoftGraphConversationMember payload, map<string|string[]> headers = {}) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/members`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get member of team
    #
    # + teamId - The unique identifier of team
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getMember(string teamId, string conversationMemberId, map<string|string[]> headers = {}, *GetMemberQueries queries) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/members/${getEncodedUri(conversationMemberId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Remove member from team
    #
    # + teamId - The unique identifier of team
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteMember(string teamId, string conversationMemberId, DeleteMemberHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/members/${getEncodedUri(conversationMemberId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update member in team
    #
    # + teamId - The unique identifier of team
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updateMember(string teamId, string conversationMemberId, MicrosoftGraphConversationMember payload, map<string|string[]> headers = {}) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/members/${getEncodedUri(conversationMemberId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countMembers(string teamId, map<string|string[]> headers = {}, *CountMembersQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/members/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke action add
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function addMembers(string teamId, AddMembersRequest payload, map<string|string[]> headers = {}) returns ActionResultPartCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/members/add`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action remove
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function removeMembers(string teamId, AddMembersRequest payload, map<string|string[]> headers = {}) returns ActionResultPartCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/members/remove`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action sendActivityNotification
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function sendActivityNotification(string teamId, SendActivityNotificationRequest payload, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/sendActivityNotification`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get primaryChannel
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getPrimaryChannel(string teamId, map<string|string[]> headers = {}, *GetPrimaryChannelQueries queries) returns MicrosoftGraphChannel|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete navigation property primaryChannel for teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deletePrimaryChannel(string teamId, DeletePrimaryChannelHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update the navigation property primaryChannel in teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updatePrimaryChannel(string teamId, MicrosoftGraphChannel payload, map<string|string[]> headers = {}) returns MicrosoftGraphChannel|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # Get allMembers from teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listPrimaryChannelAllMembers(string teamId, map<string|string[]> headers = {}, *ListPrimaryChannelAllMembersQueries queries) returns MicrosoftGraphConversationMemberCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/allMembers`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Create new navigation property to allMembers for teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createPrimaryChannelAllMember(string teamId, MicrosoftGraphConversationMember payload, map<string|string[]> headers = {}) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/allMembers`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get allMembers from teams
    #
    # + teamId - The unique identifier of team
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getPrimaryChannelAllMember(string teamId, string conversationMemberId, map<string|string[]> headers = {}, *GetPrimaryChannelAllMemberQueries queries) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/allMembers/${getEncodedUri(conversationMemberId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete navigation property allMembers for teams
    #
    # + teamId - The unique identifier of team
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deletePrimaryChannelAllMember(string teamId, string conversationMemberId, DeletePrimaryChannelAllMemberHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/allMembers/${getEncodedUri(conversationMemberId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update the navigation property allMembers in teams
    #
    # + teamId - The unique identifier of team
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updatePrimaryChannelAllMember(string teamId, string conversationMemberId, MicrosoftGraphConversationMember payload, map<string|string[]> headers = {}) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/allMembers/${getEncodedUri(conversationMemberId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countPrimaryChannelAllMembers(string teamId, map<string|string[]> headers = {}, *CountPrimaryChannelAllMembersQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/allMembers/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke action add
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function addPrimaryChannelAllMembers(string teamId, AddMembersRequest payload, map<string|string[]> headers = {}) returns ActionResultPartCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/allMembers/add`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action remove
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function removePrimaryChannelAllMembers(string teamId, AddMembersRequest payload, map<string|string[]> headers = {}) returns ActionResultPartCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/allMembers/remove`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get enabledApps from teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listPrimaryChannelEnabledApps(string teamId, map<string|string[]> headers = {}, *ListPrimaryChannelEnabledAppsQueries queries) returns MicrosoftGraphTeamsAppCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/enabledApps`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get enabledApps from teams
    #
    # + teamId - The unique identifier of team
    # + teamsAppId - The unique identifier of teamsApp
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getPrimaryChannelEnabledApp(string teamId, string teamsAppId, map<string|string[]> headers = {}, *GetPrimaryChannelEnabledAppQueries queries) returns MicrosoftGraphTeamsApp|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/enabledApps/${getEncodedUri(teamsAppId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countPrimaryChannelEnabledApps(string teamId, map<string|string[]> headers = {}, *CountPrimaryChannelEnabledAppsQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/enabledApps/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get filesFolder from teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getPrimaryChannelFilesFolder(string teamId, map<string|string[]> headers = {}, *GetPrimaryChannelFilesFolderQueries queries) returns MicrosoftGraphDriveItem|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/filesFolder`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get content for the navigation property filesFolder from teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved media content 
    remote isolated function getPrimaryChannelFilesFolderContent(string teamId, map<string|string[]> headers = {}, *GetPrimaryChannelFilesFolderContentQueries queries) returns byte[]|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/filesFolder/content`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Update content for the navigation property filesFolder in teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - New media content 
    # + return - Success 
    remote isolated function updatePrimaryChannelFilesFolderContent(string teamId, byte[] payload, map<string|string[]> headers = {}) returns MicrosoftGraphDriveItem|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/filesFolder/content`;
        http:Request request = new;
        request.setPayload(payload, "application/octet-stream");
        return self.clientEp->put(resourcePath, request, headers);
    }

    # Delete content for the navigation property filesFolder in teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deletePrimaryChannelFilesFolderContent(string teamId, DeletePrimaryChannelFilesFolderContentHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/filesFolder/content`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Get members from teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listPrimaryChannelMembers(string teamId, map<string|string[]> headers = {}, *ListPrimaryChannelMembersQueries queries) returns MicrosoftGraphConversationMemberCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/members`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Create new navigation property to members for teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createPrimaryChannelMember(string teamId, MicrosoftGraphConversationMember payload, map<string|string[]> headers = {}) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/members`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get members from teams
    #
    # + teamId - The unique identifier of team
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getPrimaryChannelMember(string teamId, string conversationMemberId, map<string|string[]> headers = {}, *GetPrimaryChannelMemberQueries queries) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/members/${getEncodedUri(conversationMemberId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete navigation property members for teams
    #
    # + teamId - The unique identifier of team
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deletePrimaryChannelMember(string teamId, string conversationMemberId, DeletePrimaryChannelMemberHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/members/${getEncodedUri(conversationMemberId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update the navigation property members in teams
    #
    # + teamId - The unique identifier of team
    # + conversationMemberId - The unique identifier of conversationMember
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updatePrimaryChannelMember(string teamId, string conversationMemberId, MicrosoftGraphConversationMember payload, map<string|string[]> headers = {}) returns MicrosoftGraphConversationMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/members/${getEncodedUri(conversationMemberId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countPrimaryChannelMembers(string teamId, map<string|string[]> headers = {}, *CountPrimaryChannelMembersQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/members/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke action add
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function addPrimaryChannelMembers(string teamId, AddMembersRequest payload, map<string|string[]> headers = {}) returns ActionResultPartCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/members/add`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action remove
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function removePrimaryChannelMembers(string teamId, AddMembersRequest payload, map<string|string[]> headers = {}) returns ActionResultPartCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/members/remove`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get messages from teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listPrimaryChannelMessages(string teamId, map<string|string[]> headers = {}, *ListPrimaryChannelMessagesQueries queries) returns MicrosoftGraphChatMessageCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Create new navigation property to messages for teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createPrimaryChannelMessage(string teamId, MicrosoftGraphChatMessage payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessage|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get messages from teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getPrimaryChannelMessage(string teamId, string chatMessageId, map<string|string[]> headers = {}, *GetPrimaryChannelMessageQueries queries) returns MicrosoftGraphChatMessage|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete navigation property messages for teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deletePrimaryChannelMessage(string teamId, string chatMessageId, DeletePrimaryChannelMessageHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update the navigation property messages in teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updatePrimaryChannelMessage(string teamId, string chatMessageId, MicrosoftGraphChatMessage payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessage|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # Get hostedContents from teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listPrimaryChannelMessageHostedContents(string teamId, string chatMessageId, map<string|string[]> headers = {}, *ListPrimaryChannelMessageHostedContentsQueries queries) returns MicrosoftGraphChatMessageHostedContentCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/hostedContents`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Create new navigation property to hostedContents for teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createPrimaryChannelMessageHostedContent(string teamId, string chatMessageId, MicrosoftGraphChatMessageHostedContent payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessageHostedContent|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/hostedContents`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get hostedContents from teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getPrimaryChannelMessageHostedContent(string teamId, string chatMessageId, string chatMessageHostedContentId, map<string|string[]> headers = {}, *GetPrimaryChannelMessageHostedContentQueries queries) returns MicrosoftGraphChatMessageHostedContent|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete navigation property hostedContents for teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deletePrimaryChannelMessageHostedContent(string teamId, string chatMessageId, string chatMessageHostedContentId, DeletePrimaryChannelMessageHostedContentHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update the navigation property hostedContents in teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updatePrimaryChannelMessageHostedContent(string teamId, string chatMessageId, string chatMessageHostedContentId, MicrosoftGraphChatMessageHostedContent payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessageHostedContent|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # Get media content for the navigation property hostedContents from teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + return - Retrieved media content 
    remote isolated function getPrimaryChannelMessageHostedContentValue(string teamId, string chatMessageId, string chatMessageHostedContentId, map<string|string[]> headers = {}) returns byte[]|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}/$value`;
        return self.clientEp->get(resourcePath, headers);
    }

    # Update media content for the navigation property hostedContents in teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + payload - New media content 
    # + return - Success 
    remote isolated function updatePrimaryChannelMessageHostedContentValue(string teamId, string chatMessageId, string chatMessageHostedContentId, byte[] payload, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}/$value`;
        http:Request request = new;
        request.setPayload(payload, "application/octet-stream");
        return self.clientEp->put(resourcePath, request, headers);
    }

    # Delete media content for the navigation property hostedContents in teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deletePrimaryChannelMessageHostedContentValue(string teamId, string chatMessageId, string chatMessageHostedContentId, DeletePrimaryChannelMessageHostedContentValueHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}/$value`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countPrimaryChannelMessageHostedContents(string teamId, string chatMessageId, map<string|string[]> headers = {}, *CountPrimaryChannelMessageHostedContentsQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/hostedContents/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke action setReaction
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function setReactionPrimaryChannelMessage(string teamId, string chatMessageId, SetReactionRequest payload, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/setReaction`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action softDelete
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function softDeletePrimaryChannelMessage(string teamId, string chatMessageId, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/softDelete`;
        http:Request request = new;
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action undoSoftDelete
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function undoSoftDeletePrimaryChannelMessage(string teamId, string chatMessageId, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/undoSoftDelete`;
        http:Request request = new;
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action unsetReaction
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function unsetReactionPrimaryChannelMessage(string teamId, string chatMessageId, SetReactionRequest payload, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/unsetReaction`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get replies from teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listPrimaryChannelMessageReplies(string teamId, string chatMessageId, map<string|string[]> headers = {}, *ListPrimaryChannelMessageRepliesQueries queries) returns MicrosoftGraphChatMessageCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Create new navigation property to replies for teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createPrimaryChannelMessageReply(string teamId, string chatMessageId, MicrosoftGraphChatMessage payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessage|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get replies from teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getPrimaryChannelMessageReply(string teamId, string chatMessageId, string chatMessageId1, map<string|string[]> headers = {}, *GetPrimaryChannelMessageReplyQueries queries) returns MicrosoftGraphChatMessage|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete navigation property replies for teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deletePrimaryChannelMessageReply(string teamId, string chatMessageId, string chatMessageId1, DeletePrimaryChannelMessageReplyHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update the navigation property replies in teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updatePrimaryChannelMessageReply(string teamId, string chatMessageId, string chatMessageId1, MicrosoftGraphChatMessage payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessage|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # Get hostedContents from teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listPrimaryChannelMessageReplyHostedContents(string teamId, string chatMessageId, string chatMessageId1, map<string|string[]> headers = {}, *ListPrimaryChannelMessageReplyHostedContentsQueries queries) returns MicrosoftGraphChatMessageHostedContentCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Create new navigation property to hostedContents for teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createPrimaryChannelMessageReplyHostedContent(string teamId, string chatMessageId, string chatMessageId1, MicrosoftGraphChatMessageHostedContent payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessageHostedContent|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get hostedContents from teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getPrimaryChannelMessageReplyHostedContent(string teamId, string chatMessageId, string chatMessageId1, string chatMessageHostedContentId, map<string|string[]> headers = {}, *GetPrimaryChannelMessageReplyHostedContentQueries queries) returns MicrosoftGraphChatMessageHostedContent|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete navigation property hostedContents for teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deletePrimaryChannelMessageReplyHostedContent(string teamId, string chatMessageId, string chatMessageId1, string chatMessageHostedContentId, DeletePrimaryChannelMessageReplyHostedContentHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update the navigation property hostedContents in teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updatePrimaryChannelMessageReplyHostedContent(string teamId, string chatMessageId, string chatMessageId1, string chatMessageHostedContentId, MicrosoftGraphChatMessageHostedContent payload, map<string|string[]> headers = {}) returns MicrosoftGraphChatMessageHostedContent|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # Get media content for the navigation property hostedContents from teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + return - Retrieved media content 
    remote isolated function getPrimaryChannelMessageReplyHostedContentValue(string teamId, string chatMessageId, string chatMessageId1, string chatMessageHostedContentId, map<string|string[]> headers = {}) returns byte[]|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}/$value`;
        return self.clientEp->get(resourcePath, headers);
    }

    # Update media content for the navigation property hostedContents in teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + payload - New media content 
    # + return - Success 
    remote isolated function updatePrimaryChannelMessageReplyHostedContentValue(string teamId, string chatMessageId, string chatMessageId1, string chatMessageHostedContentId, byte[] payload, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}/$value`;
        http:Request request = new;
        request.setPayload(payload, "application/octet-stream");
        return self.clientEp->put(resourcePath, request, headers);
    }

    # Delete media content for the navigation property hostedContents in teams
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + chatMessageHostedContentId - The unique identifier of chatMessageHostedContent
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deletePrimaryChannelMessageReplyHostedContentValue(string teamId, string chatMessageId, string chatMessageId1, string chatMessageHostedContentId, DeletePrimaryChannelMessageReplyHostedContentValueHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents/${getEncodedUri(chatMessageHostedContentId)}/$value`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countPrimaryChannelMessageReplyHostedContents(string teamId, string chatMessageId, string chatMessageId1, map<string|string[]> headers = {}, *CountPrimaryChannelMessageReplyHostedContentsQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/hostedContents/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke action setReaction
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function setReactionPrimaryChannelMessageReply(string teamId, string chatMessageId, string chatMessageId1, SetReactionRequest payload, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/setReaction`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action softDelete
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function softDeletePrimaryChannelMessageReply(string teamId, string chatMessageId, string chatMessageId1, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/softDelete`;
        http:Request request = new;
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action undoSoftDelete
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function undoSoftDeletePrimaryChannelMessageReply(string teamId, string chatMessageId, string chatMessageId1, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/undoSoftDelete`;
        http:Request request = new;
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Invoke action unsetReaction
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + chatMessageId1 - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function unsetReactionPrimaryChannelMessageReply(string teamId, string chatMessageId, string chatMessageId1, SetReactionRequest payload, map<string|string[]> headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/${getEncodedUri(chatMessageId1)}/unsetReaction`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countPrimaryChannelMessageReplies(string teamId, string chatMessageId, map<string|string[]> headers = {}, *CountPrimaryChannelMessageRepliesQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke function delta
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Success 
    remote isolated function getPrimaryChannelMessageRepliesDelta(string teamId, string chatMessageId, map<string|string[]> headers = {}, *GetPrimaryChannelMessageRepliesDeltaQueries queries) returns ChatMessageDeltaCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/delta()`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$orderby": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke action replyWithQuote
    #
    # + teamId - The unique identifier of team
    # + chatMessageId - The unique identifier of chatMessage
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function replyWithQuotePrimaryChannelMessageReplies(string teamId, string chatMessageId, ReplyWithQuoteRequest payload, map<string|string[]> headers = {}) returns ChatMessageResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/${getEncodedUri(chatMessageId)}/replies/replyWithQuote`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countPrimaryChannelMessages(string teamId, map<string|string[]> headers = {}, *CountPrimaryChannelMessagesQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke function delta
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Success 
    remote isolated function getPrimaryChannelMessagesDelta(string teamId, map<string|string[]> headers = {}, *GetPrimaryChannelMessagesDeltaQueries queries) returns ChatMessageDeltaCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/delta()`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$orderby": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Invoke action replyWithQuote
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - Action parameters 
    # + return - Success 
    remote isolated function replyWithQuotePrimaryChannelMessages(string teamId, ReplyWithQuoteRequest payload, map<string|string[]> headers = {}) returns ChatMessageResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/messages/replyWithQuote`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get tabs from teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listPrimaryChannelTabs(string teamId, map<string|string[]> headers = {}, *ListPrimaryChannelTabsQueries queries) returns MicrosoftGraphTeamsTabCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/tabs`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Create new navigation property to tabs for teams
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createPrimaryChannelTab(string teamId, MicrosoftGraphTeamsTab payload, map<string|string[]> headers = {}) returns MicrosoftGraphTeamsTab|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/tabs`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get tabs from teams
    #
    # + teamId - The unique identifier of team
    # + teamsTabId - The unique identifier of teamsTab
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getPrimaryChannelTab(string teamId, string teamsTabId, map<string|string[]> headers = {}, *GetPrimaryChannelTabQueries queries) returns MicrosoftGraphTeamsTab|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/tabs/${getEncodedUri(teamsTabId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete navigation property tabs for teams
    #
    # + teamId - The unique identifier of team
    # + teamsTabId - The unique identifier of teamsTab
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deletePrimaryChannelTab(string teamId, string teamsTabId, DeletePrimaryChannelTabHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/tabs/${getEncodedUri(teamsTabId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update the navigation property tabs in teams
    #
    # + teamId - The unique identifier of team
    # + teamsTabId - The unique identifier of teamsTab
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updatePrimaryChannelTab(string teamId, string teamsTabId, MicrosoftGraphTeamsTab payload, map<string|string[]> headers = {}) returns MicrosoftGraphTeamsTab|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/tabs/${getEncodedUri(teamsTabId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # Get teamsApp from teams
    #
    # + teamId - The unique identifier of team
    # + teamsTabId - The unique identifier of teamsTab
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getPrimaryChannelTabTeamsApp(string teamId, string teamsTabId, map<string|string[]> headers = {}, *GetPrimaryChannelTabTeamsAppQueries queries) returns MicrosoftGraphTeamsApp|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/tabs/${getEncodedUri(teamsTabId)}/teamsApp`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countPrimaryChannelTabs(string teamId, map<string|string[]> headers = {}, *CountPrimaryChannelTabsQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/primaryChannel/tabs/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # List teamworkTags
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listTags(string teamId, map<string|string[]> headers = {}, *ListTagsQueries queries) returns MicrosoftGraphTeamworkTagCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/tags`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Create teamworkTag
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createTag(string teamId, MicrosoftGraphTeamworkTag payload, map<string|string[]> headers = {}) returns MicrosoftGraphTeamworkTag|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/tags`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get teamworkTag
    #
    # + teamId - The unique identifier of team
    # + teamworkTagId - The unique identifier of teamworkTag
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getTag(string teamId, string teamworkTagId, map<string|string[]> headers = {}, *GetTagQueries queries) returns MicrosoftGraphTeamworkTag|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/tags/${getEncodedUri(teamworkTagId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete teamworkTag
    #
    # + teamId - The unique identifier of team
    # + teamworkTagId - The unique identifier of teamworkTag
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteTag(string teamId, string teamworkTagId, DeleteTagHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/tags/${getEncodedUri(teamworkTagId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update teamworkTag
    #
    # + teamId - The unique identifier of team
    # + teamworkTagId - The unique identifier of teamworkTag
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updateTag(string teamId, string teamworkTagId, MicrosoftGraphTeamworkTag payload, map<string|string[]> headers = {}) returns MicrosoftGraphTeamworkTag|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/tags/${getEncodedUri(teamworkTagId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # List members in a teamworkTag
    #
    # + teamId - The unique identifier of team
    # + teamworkTagId - The unique identifier of teamworkTag
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved collection 
    remote isolated function listTagMembers(string teamId, string teamworkTagId, map<string|string[]> headers = {}, *ListTagMembersQueries queries) returns MicrosoftGraphTeamworkTagMemberCollectionResponse|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/tags/${getEncodedUri(teamworkTagId)}/members`;
        map<Encoding> queryParamEncoding = {"$orderby": {style: FORM, explode: false}, "$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Create teamworkTagMember
    #
    # + teamId - The unique identifier of team
    # + teamworkTagId - The unique identifier of teamworkTag
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property 
    # + return - Created navigation property 
    remote isolated function createTagMember(string teamId, string teamworkTagId, MicrosoftGraphTeamworkTagMember payload, map<string|string[]> headers = {}) returns MicrosoftGraphTeamworkTagMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/tags/${getEncodedUri(teamworkTagId)}/members`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->post(resourcePath, request, headers);
    }

    # Get teamworkTagMember
    #
    # + teamId - The unique identifier of team
    # + teamworkTagId - The unique identifier of teamworkTag
    # + teamworkTagMemberId - The unique identifier of teamworkTagMember
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Retrieved navigation property 
    remote isolated function getTagMember(string teamId, string teamworkTagId, string teamworkTagMemberId, map<string|string[]> headers = {}, *GetTagMemberQueries queries) returns MicrosoftGraphTeamworkTagMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/tags/${getEncodedUri(teamworkTagId)}/members/${getEncodedUri(teamworkTagMemberId)}`;
        map<Encoding> queryParamEncoding = {"$select": {style: FORM, explode: false}, "$expand": {style: FORM, explode: false}};
        resourcePath = resourcePath + check getPathForQueryParam(queries, queryParamEncoding);
        return self.clientEp->get(resourcePath, headers);
    }

    # Delete teamworkTagMember
    #
    # + teamId - The unique identifier of team
    # + teamworkTagId - The unique identifier of teamworkTag
    # + teamworkTagMemberId - The unique identifier of teamworkTagMember
    # + headers - Headers to be sent with the request 
    # + return - Success 
    remote isolated function deleteTagMember(string teamId, string teamworkTagId, string teamworkTagMemberId, DeleteTagMemberHeaders headers = {}) returns error? {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/tags/${getEncodedUri(teamworkTagId)}/members/${getEncodedUri(teamworkTagMemberId)}`;
        map<string|string[]> httpHeaders = http:getHeaderMap(headers);
        return self.clientEp->delete(resourcePath, headers = httpHeaders);
    }

    # Update the navigation property members in teams
    #
    # + teamId - The unique identifier of team
    # + teamworkTagId - The unique identifier of teamworkTag
    # + teamworkTagMemberId - The unique identifier of teamworkTagMember
    # + headers - Headers to be sent with the request 
    # + payload - New navigation property values 
    # + return - Success 
    remote isolated function updateTagMember(string teamId, string teamworkTagId, string teamworkTagMemberId, MicrosoftGraphTeamworkTagMember payload, map<string|string[]> headers = {}) returns MicrosoftGraphTeamworkTagMember|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/tags/${getEncodedUri(teamworkTagId)}/members/${getEncodedUri(teamworkTagMemberId)}`;
        http:Request request = new;
        json jsonBody = jsondata:toJson(payload);
        request.setPayload(jsonBody, "application/json");
        return self.clientEp->patch(resourcePath, request, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + teamworkTagId - The unique identifier of teamworkTag
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countTagMembers(string teamId, string teamworkTagId, map<string|string[]> headers = {}, *CountTagMembersQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/tags/${getEncodedUri(teamworkTagId)}/members/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }

    # Get the number of the resource
    #
    # + teamId - The unique identifier of team
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - The count of the resource 
    remote isolated function countTags(string teamId, map<string|string[]> headers = {}, *CountTagsQueries queries) returns string|error {
        string resourcePath = string `/teams/${getEncodedUri(teamId)}/tags/$count`;
        resourcePath = resourcePath + check getPathForQueryParam(queries);
        return self.clientEp->get(resourcePath, headers);
    }
}
