# Team tag management

This example manages teamwork tags on a team: it creates a tag — seeded with one member, as Microsoft Graph requires a new tag to have at least one member — lists all tags on the team, reads the new tag back, and then deletes it.

## Prerequisites

1. **Microsoft Teams setup**
   > Refer to the [Microsoft Teams connector setup guide](https://central.ballerina.io/ballerinax/microsoft.teams/latest) to register an application in Microsoft Entra ID and obtain the required credentials.

2. **Configuration**

   Create a `Config.toml` file in the example directory and add your credentials, the target team, and the object id of a team member to seed the tag with:

   ```toml
   clientId = "<client-id>"
   clientSecret = "<client-secret>"
   refreshToken = "<refresh-token>"
   tenantId = "<tenant-id>"
   teamId = "<team-id>"
   # Object id of a team member to seed the new tag with
   userId = "<user-object-id>"
   ```

## Run the example

Execute the following command to run the example. It prints its progress to the console.

```shell
bal run
```
