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

import ballerina/io;

// End-to-end scenario tests.
//
// Unlike the per-endpoint tests in `test.bal`, these exercise complete, realistic flows by
// chaining dependent operations (create -> read -> update -> ... -> delete) and asserting on
// values echoed back by the real service. They mirror the runnable samples under `examples/`.
//
// They only do meaningful work against the live Microsoft Graph API, so each scenario returns
// early when `isLiveServer` is false. To run just the scenarios against the live server, set the
// live-server config in `tests/Config.toml` (see tests/README.md) and run:
//
//     bal test --groups scenarios
//
// `isLiveServer`, `teamId`, `channelId` and the OAuth2 config are declared in `test.bal`.

// Object ID of the signed-in user (delegated auth). Required by scenarios that must reference a
// real user — for example creating a teamwork tag, which Graph requires to have at least one
// member. Set this in `tests/Config.toml` to the signed-in user's object id.
configurable string userId = "";

// Optional. Object ID of a SECOND user in the tenant. Enables the add/remove member and
// add/remove tag-member steps, which need a user who isn't already a member. Leave empty in a
// single-user tenant — those steps are then skipped with a log line rather than failing.
configurable string secondUserId = "";

// Opt-in flag for the team-provisioning scenario. That scenario creates a REAL team (an async,
// slow operation) and cannot reliably auto-delete it unless the app has `Group.ReadWrite.All`, so
// it is off by default. Set to true in Config.toml to run it.
configurable boolean runTeamProvisioning = false;

// Emits an indented progress line so the flow of a scenario is visible in the test output.
function logStep(string message) {
    io:println("    - " + message);
}

// True when a Graph call failed because the delegated token lacks a required permission scope
// (HTTP 403 Forbidden). Used to skip permission-gated optional steps rather than fail a scenario.
isolated function isForbidden(error e) returns boolean {
    return e.message().includes("Forbidden");
}
