# Examples

The `ballerinax/microsoft.teams` connector provides practical examples illustrating usage in various scenarios.

| Example | Description |
|---------|-------------|
| [`team-and-channel-setup`](./team-and-channel-setup) | Provision a new team and set up a channel in it, handling Graph's asynchronous operations. |
| [`channel-message-thread`](./channel-message-thread) | Post a root message to a channel, reply to it, and list the thread. |
| [`channel-member-management`](./channel-member-management) | Add a member to a channel, list the members, read one back, and remove them. |
| [`team-tag-management`](./team-tag-management) | Create a teamwork tag on a team, list its tags, read one back, and delete it. |
| [`primary-channel-messaging`](./primary-channel-messaging) | Post to a team's primary channel, react to the message, and list recent messages. |

## Prerequisites

1. Build and push the connector to your local Ballerina repository:
   ```bash
   cd ballerina
   bal pack && bal push --repository=local
   ```

2. Obtain OAuth2 credentials for a Microsoft 365 account by [registering an application](https://learn.microsoft.com/en-us/graph/auth-register-app-v2) in Microsoft Entra ID and granting the required Microsoft Graph permissions.

3. For each example, create a `Config.toml` in the example directory with the required credentials. All examples require the OAuth2 credentials and the tenant id (this connector's app registration is single-tenant, so the token endpoint must be tenant-specific — the `/common` endpoint is rejected). Some examples also need resource identifiers:
   ```toml
   clientId = "<client-id>"
   clientSecret = "<client-secret>"
   refreshToken = "<refresh-token>"
   tenantId = "<tenant-id>"

   # Required by all examples EXCEPT team-and-channel-setup (which creates its own team)
   teamId = "<team-id>"
   # Required by channel-message-thread and channel-member-management
   channelId = "<channel-id>"
   # Required by channel-member-management (user to add) and team-tag-management (tag member)
   userId = "<user-object-id>"
   ```

## Running an example

```bash
cd examples/<example-name>
bal run
```
