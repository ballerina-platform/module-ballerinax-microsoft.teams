# Channel member management

This example manages channel membership: it creates a **private** channel with an owner, waits for it to provision, lists the channel's members, and then deletes the channel to clean up.

> **Note:** Per-channel membership applies to private and shared channels. Standard channels inherit the team's roster and don't support adding members directly, so this example creates its own private channel to be self-contained.
>
> Microsoft Graph reserves a deleted channel's display name for ~30 days. If you re-run the example within that window, change the `displayName` in `main.bal`, otherwise creation fails with `ChannelNameAlreadyExist`.

## Prerequisites

1. **Microsoft Teams setup**
   > Refer to the [Microsoft Teams connector setup guide](https://central.ballerina.io/ballerinax/microsoft.teams/latest) to register an application in Microsoft Entra ID and obtain the required credentials.

2. **Configuration**

   Create a `Config.toml` file in the example directory and add your credentials, the target team, and the object id of the user to own the new private channel:

   ```toml
   clientId = "<client-id>"
   clientSecret = "<client-secret>"
   refreshToken = "<refresh-token>"
   tenantId = "<tenant-id>"
   teamId = "<team-id>"
   # Object id of the user to own the new private channel (typically the signed-in user)
   ownerId = "<user-object-id>"
   ```

## Run the example

Execute the following command to run the example. It prints its progress to the console.

```shell
bal run
```
