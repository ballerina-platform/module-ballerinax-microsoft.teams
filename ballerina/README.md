## Overview

[Microsoft Teams](https://www.microsoft.com/en-us/microsoft-teams/group-chat-software) is a proprietary business communication platform developed by Microsoft, offering workspace chat, video conferencing, file storage, and application integration.

The `ballerinax/microsoft.teams` connector allows you to programmatically access and manage Microsoft Teams resources through the [Microsoft Graph API v1.0](https://learn.microsoft.com/en-us/graph/use-the-api). It supports working with teams, channels (including the primary channel), channel members, messages and replies, hosted content, tabs, and teamwork tags.

## Setup guide

To use the Microsoft Teams connector, you need access to a Microsoft 365 account and an application registered in Microsoft Entra ID.

> **Note:** The screenshots in this guide are for illustration only. The Microsoft Entra admin center changes over time, so treat them as a visual reference rather than an exact match — follow the described actions and choose the values (application name, redirect URI, permissions, and so on) that fit your own scenario.

### Step 1: Register an application in Microsoft Entra ID

1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com).
2. Navigate to **Entra ID** > **App registrations** and click **New registration**.

   ![App registrations](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.teams/main/docs/resources/setup-guide-1.jpg)

3. Enter a name of your choice and select the account types appropriate for your organization. For delegated (`refresh_token`) access, add a **Redirect URI** under the **Web** platform — this is where the sign-in flow returns the authorization code (a Microsoft-hosted page such as `https://jwt.ms` is a convenient choice for Step 4). The **Web** platform is required here because the connector redeems the code using a client secret (a confidential-client flow); the public "Mobile and desktop applications" platform does not accept a client secret. Click **Register**.

   ![Register an application](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.teams/main/docs/resources/setup-guide-2.jpeg)

4. On the app's **Overview** page, note the **Application (client) ID** and **Directory (tenant) ID** — both are needed for `Config.toml`.

   ![Overview of application](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.teams/main/docs/resources/setup-guide-3.jpeg)

### Step 2: Add Microsoft Graph permissions

1. In the registered application, go to **API permissions** > **Add a permission** > **Microsoft Graph**.

   ![Select Microsoft Graph](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.teams/main/docs/resources/setup-guide-5.jpeg)

2. Choose **Delegated permissions** (for `refresh_token`) or **Application permissions** (for `client_credentials`), then add the permissions your use case requires — each operation's required scope is listed in its [Microsoft Graph API reference](https://learn.microsoft.com/en-us/graph/api/overview). For the delegated flow, also include `offline_access` so the token response includes a refresh token. Click **Add permissions**.

   ![Request API permissions](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.teams/main/docs/resources/setup-guide-4.jpeg)

3. Back on the **API permissions** page, click **Grant admin consent for \<your tenant\>** and confirm **Yes**.

   ![Grant admin consent](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.teams/main/docs/resources/setup-guide-6.jpeg)

4. Confirm every permission now shows **Granted for \<your tenant\>** in the **Status** column.

   ![Configured permissions](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.teams/main/docs/resources/setup-guide-9.jpeg)

### Step 3: Create a client secret

1. Go to **Certificates & secrets** > **New client secret**, add a description and an expiry, and click **Add**.

   ![Add a client secret](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.teams/main/docs/resources/setup-guide-8.jpeg)

2. Copy the secret **Value** immediately — it is shown only once. (The **Secret ID** shown next to it is just a label for the secret, not a credential.)

   ![Certificates & secrets](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-microsoft.teams/main/docs/resources/setup-guide-7.jpeg)

### Step 4: Obtain the credentials for `Config.toml`

Microsoft Entra's v2.0 endpoints for the app registered above:

- Authorize: `https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/authorize`
- Token: `https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/token`

Replace `<TENANT_ID>`, `<CLIENT_ID>`, and `<CLIENT_SECRET>` below with the values from Steps 1 and 3.

#### Option A — Delegated access (`refreshToken` + `authMode = "refresh_token"`)

Requires a one-time interactive sign-in.

**1. Get an authorization code.** This is an interactive sign-in + consent step, so it can't be curled — paste this URL into a browser instead:

```text
https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/authorize?client_id=<CLIENT_ID>&response_type=code&redirect_uri=https%3A%2F%2Fjwt.ms&response_mode=query&scope=https%3A%2F%2Fgraph.microsoft.com%2F.default%20offline_access&state=12345
```

Sign in and accept the consent prompt. You'll land on `https://jwt.ms/?code=<AUTH_CODE>&state=12345` — copy the `code` value from that URL. It's single-use and short-lived, so use it in the next step within a few minutes.

**2. Exchange the code for a refresh token.**

macOS / Linux (bash, zsh):

```bash
curl -X POST "https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/token" \
  --data-urlencode "client_id=<CLIENT_ID>" \
  --data-urlencode "client_secret=<CLIENT_SECRET>" \
  --data-urlencode "scope=https://graph.microsoft.com/.default offline_access" \
  --data-urlencode "code=<AUTH_CODE>" \
  --data-urlencode "redirect_uri=https://jwt.ms" \
  --data-urlencode "grant_type=authorization_code"
```

Windows (PowerShell — call `curl.exe` explicitly; plain `curl` is aliased to `Invoke-WebRequest` and takes different flags):

```powershell
curl.exe -X POST "https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/token" `
  --data-urlencode "client_id=<CLIENT_ID>" `
  --data-urlencode "client_secret=<CLIENT_SECRET>" `
  --data-urlencode "scope=https://graph.microsoft.com/.default offline_access" `
  --data-urlencode "code=<AUTH_CODE>" `
  --data-urlencode "redirect_uri=https://jwt.ms" `
  --data-urlencode "grant_type=authorization_code"
```

The JSON response includes a `refresh_token` field — copy that value into `Config.toml` as `refreshToken`, alongside `clientId`, `clientSecret`, `tenantId`, and `authMode = "refresh_token"`.

> The `access_token` in the same response is short-lived (~1 hour) and isn't used directly; the connector uses `refreshToken` to mint new access tokens automatically on each call.

#### Option B — App-only access (`authMode = "client_credentials"`)

No user, no redirect URI, and no `/authorize` step — the app authenticates as itself directly against `/token`. This requires **Application** permissions (not delegated), admin-consented, from Step 2.

macOS / Linux:

```bash
curl -X POST "https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/token" \
  --data-urlencode "client_id=<CLIENT_ID>" \
  --data-urlencode "client_secret=<CLIENT_SECRET>" \
  --data-urlencode "scope=https://graph.microsoft.com/.default" \
  --data-urlencode "grant_type=client_credentials"
```

Windows (PowerShell):

```powershell
curl.exe -X POST "https://login.microsoftonline.com/<TENANT_ID>/oauth2/v2.0/token" `
  --data-urlencode "client_id=<CLIENT_ID>" `
  --data-urlencode "client_secret=<CLIENT_SECRET>" `
  --data-urlencode "scope=https://graph.microsoft.com/.default" `
  --data-urlencode "grant_type=client_credentials"
```

There's no `refresh_token` in this response — app-only tokens aren't refreshed; the connector just calls this same endpoint again with `clientId`/`clientSecret`/`tenantId` whenever a token expires. Set `authMode = "client_credentials"` in `Config.toml` and leave `refreshToken` unset.

## Quickstart

To use the `Microsoft Teams` connector in your Ballerina application, modify the `.bal` file as follows:

### Step 1: Import the module

```ballerina
import ballerina/io;
import ballerinax/microsoft.teams;
```

### Step 2: Instantiate a new connector

Create a `Config.toml` file with your OAuth2 credentials:

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
refreshToken = "<refresh-token>"
tenantId = "<tenant-id>"
```

Initialize the client with these credentials:

```ballerina
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string tenantId = ?;

teams:OAuth2RefreshTokenGrantConfig auth = {
    clientId,
    clientSecret,
    refreshToken,
    refreshUrl: string `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`
};
teams:Client teamsClient = check new ({auth});
```

### Step 3: Invoke the connector operation

```ballerina
public function main() returns error? {
    teams:ChannelCollectionResponse channels = check teamsClient->listChannels("<team-id>");
    foreach teams:Channel channel in channels.value ?: [] {
        io:println(channel.displayName ?: "");
    }
}
```

## Examples

The `Microsoft Teams` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/tree/main/examples), covering the following use cases:

1. [Team and channel setup](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/tree/main/examples/team-and-channel-setup) — Provision a new team and create a channel within it.
2. [Channel message thread](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/tree/main/examples/channel-message-thread) — Post a message to a channel, reply to it, and add a reaction.
3. [Channel member management](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/tree/main/examples/channel-member-management) — Create a private channel with an owner and list its members.
4. [Team tag management](https://github.com/ballerina-platform/module-ballerinax-microsoft.teams/tree/main/examples/team-tag-management) — Create a teamwork tag on a team and list all its tags.

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
