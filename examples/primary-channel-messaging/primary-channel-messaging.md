# Primary channel messaging

This example works with a team's primary ("General") channel: it reads the primary channel to get its id, posts a message, adds a reaction to it, and then lists the channel's recent messages. No channel id is needed in the configuration — the example derives it from the primary channel.

> **Note:** Microsoft Graph doesn't support sending a message through the `primaryChannel` navigation directly, so this example reads the primary channel first and posts through the standard channel messaging path.

## Prerequisites

1. **Microsoft Teams setup**
   > Refer to the [Microsoft Teams connector setup guide](https://central.ballerina.io/ballerinax/microsoft.teams/latest) to register an application in Microsoft Entra ID and obtain the required credentials.

2. **Configuration**

   Create a `Config.toml` file in the example directory and add your credentials and the target team:

   ```toml
   clientId = "<client-id>"
   clientSecret = "<client-secret>"
   refreshToken = "<refresh-token>"
   tenantId = "<tenant-id>"
   teamId = "<team-id>"
   ```

## Run the example

Execute the following command to run the example. It prints its progress to the console.

```shell
bal run
```
