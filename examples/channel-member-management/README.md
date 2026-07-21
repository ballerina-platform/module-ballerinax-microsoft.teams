# Channel member management

This example manages channel membership: it creates a private channel owned by a given user, waits for the channel to finish provisioning, lists its members, and finally deletes it. Per-channel membership applies only to private and shared channels — standard channels inherit the team's roster and don't support adding members directly.

## Prerequisites

1. **Microsoft Teams setup**
   > Refer to the [Microsoft Teams connector setup guide](https://central.ballerina.io/ballerinax/microsoft.teams/latest) to register an application in Microsoft Entra ID and obtain the required credentials.

2. **Configuration**

   Create a `Config.toml` file in the example directory and add your credentials, the target team, and the object id of the user who will own the new private channel:

   ```toml
   clientId = "<client-id>"
   clientSecret = "<client-secret>"
   refreshToken = "<refresh-token>"
   tenantId = "<tenant-id>"
   teamId = "<team-id>"
   # Object id of the user who will own the new private channel (typically the signed-in user)
   ownerId = "<user-object-id>"
   ```

## Run the example

Execute the following command to run the example. It prints its progress to the console.

```shell
bal run
```
