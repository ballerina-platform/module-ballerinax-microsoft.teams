# Channel message thread

This example starts a threaded conversation in a channel: it posts a root message, replies to it to form a thread, and then lists every reply in the thread.

## Prerequisites

1. **Microsoft Teams setup**
   > Refer to the [Microsoft Teams connector setup guide](https://central.ballerina.io/ballerinax/microsoft.teams/latest) to register an application in Microsoft Entra ID and obtain the required credentials.

2. **Configuration**

   Create a `Config.toml` file in the example directory and add your credentials and the target team and channel:

   ```toml
   clientId = "<client-id>"
   clientSecret = "<client-secret>"
   refreshToken = "<refresh-token>"
   tenantId = "<tenant-id>"
   teamId = "<team-id>"
   channelId = "<channel-id>"
   ```

## Run the example

Execute the following command to run the example. It prints its progress to the console.

```shell
bal run
```
