# Team and channel setup

This example provisions a new team and sets up a channel in it, handling Microsoft Graph's **asynchronous** operations. It creates a team (202 Accepted — the team id is read from the `Location` header), polls until the team is provisioned, creates a channel (synchronous 201 for a standard channel, or async 202 for a shared channel), and finally lists the team's channels.

## Prerequisites

1. **Microsoft Teams setup**
   > Refer to the [Microsoft Teams connector setup guide](https://central.ballerina.io/ballerinax/microsoft.teams/latest) to register an application in Microsoft Entra ID and obtain the required credentials.

2. **Configuration**

   Create a `Config.toml` file in the example directory and add your credentials. No resource ids are needed — the team and channel are created by the example:

   ```toml
   clientId = "<client-id>"
   clientSecret = "<client-secret>"
   refreshToken = "<refresh-token>"
   tenantId = "<tenant-id>"
   ```

## Run the example

Execute the following command to run the example. It prints its progress to the console.

```shell
bal run
```
