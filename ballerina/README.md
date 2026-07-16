# Ballerina Microsoft Teams connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/actions/workflows/ci.yml)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/actions/workflows/build-with-bal-test-native.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/actions/workflows/build-with-bal-test-native.yml)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-microsoft.teams/branch/main/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-microsoft.teams)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-microsoft.teams.svg)](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/commits/main)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Overview

[Microsoft Teams](https://www.microsoft.com/en-us/microsoft-teams/group-chat-software) is a proprietary business communication platform developed by Microsoft, offering workspace chat, video conferencing, file storage, and application integration.

The `ballerinax/microsoft.teams` connector allows you to programmatically access and manage Microsoft Teams resources through the [Microsoft Graph API v1.0](https://learn.microsoft.com/en-us/graph/use-the-api). It supports working with teams, channels (including the primary channel), channel members, messages and replies, hosted content, tabs, and teamwork tags.

## Setup guide

To use the Microsoft Teams connector, you must have access to a Microsoft 365 account and register an application in Microsoft Entra ID.

### Step 1: Register an application in Microsoft Entra ID

1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com).
2. Navigate to **Identity** > **Applications** > **App registrations** and click **New registration**.
3. Enter a name, select the supported account types, and (for delegated access) add a redirect URI. Click **Register**.

### Step 2: Add Microsoft Graph permissions

1. In the registered application, go to **API permissions** > **Add a permission** > **Microsoft Graph**.
2. Add the delegated or application permissions your scenario requires — for example, `Team.ReadBasic.All`, `Channel.ReadBasic.All`, `ChannelMessage.Send`, and `TeamMember.ReadWrite.All`.
3. Grant admin consent for the added permissions.

### Step 3: Create a client secret

1. Go to **Certificates & secrets** > **New client secret**, add a description and an expiry, and click **Add**.
2. Copy the secret **Value** immediately — it is shown only once.

### Step 4: Obtain a refresh token

Complete the OAuth2 authorization-code flow to obtain a refresh token for delegated access, or use the client-credentials flow for application-only access. See the [Microsoft identity platform documentation](https://learn.microsoft.com/en-us/graph/auth-v2-user) for details.

## Quickstart

To use the `Microsoft Teams` connector in your Ballerina application, modify the `.bal` file as follows:

### Step 1: Import the module

```ballerina
import ballerinax/microsoft.teams;
```

### Step 2: Instantiate a new connector

Create a `Config.toml` file with your OAuth2 credentials:

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
refreshToken = "<refresh-token>"
```

Initialize the client with these credentials:

```ballerina
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

teams:OAuth2RefreshTokenGrantConfig auth = {clientId, clientSecret, refreshToken};
teams:Client teamsClient = check new ({auth});
```

### Step 3: Invoke the connector operation

```ballerina
public function main() returns error? {
    teams:MicrosoftGraphChannelCollectionResponse channels = check teamsClient->listChannels("<team-id>");
    foreach teams:MicrosoftGraphChannel channel in channels.value ?: [] {
        io:println(channel.displayName ?: "");
    }
}
```

## Examples

The `Microsoft Teams` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/tree/main/examples/), covering the following use cases:

- [Team and channel setup](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/tree/main/examples/team-and-channel-setup) — Provision a new team and create a channel within it.
- [Channel message thread](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/tree/main/examples/channel-message-thread) — Post a message to a channel, reply to it, and add a reaction.
- [Channel member management](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/tree/main/examples/channel-member-management) — Add owners to a channel and list its current members.
- [Team tag management](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/tree/main/examples/team-tag-management) — Create a teamwork tag on a team and list all its tags.

## Build from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

### Building the source

Execute the following commands to build from the source:

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`microsoft.teams` package](https://central.ballerina.io/ballerinax/microsoft.teams/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
