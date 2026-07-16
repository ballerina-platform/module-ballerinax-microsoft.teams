# Examples

The `ballerinax/microsoft.teams` connector provides practical examples illustrating usage in various scenarios.

| Example | Description |
|---------|-------------|
| [`team-and-channel-setup`](./team-and-channel-setup) | Provision a new team and create a channel within it. |
| [`channel-message-thread`](./channel-message-thread) | Post a message to a channel, reply to it, and add a reaction. |
| [`channel-member-management`](./channel-member-management) | Create a private channel with an owner and list its members. |
| [`team-tag-management`](./team-tag-management) | Create a teamwork tag on a team and list all its tags. |

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

   # Required by channel-message-thread, channel-member-management and team-tag-management
   teamId = "<team-id>"
   # Required by channel-message-thread
   channelId = "<channel-id>"
   # Required by channel-member-management — object id of the user to own the new private channel
   ownerId = "<user-object-id>"
   # Required by team-tag-management — object id of a team member to seed the tag with
   userId = "<user-object-id>"
   ```

## Running an example

```bash
cd examples/<example-name>
bal run
```
