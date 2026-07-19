# Tests

This package contains tests for the Microsoft Teams connector. The suite covers all 186 operations exposed by the client — spanning team, channel, channel-member, message, reply, hosted-content, tab, and tag resources across the standard `channels` and `primaryChannel` navigation paths — including create/read/update/delete, `$count`, `$value` media content, `delta`, member add/remove, and message actions such as `setReaction`, `softDelete`, and `replyWithQuote`.

The tests can run in two modes.

## Mock server tests (default)

By default the tests run against a mock server (`tests/mock_service.bal`) that emulates the Microsoft Graph endpoints on `http://localhost:9090`, so no real credentials are required:

```bash
bal test
```

The mock server routes every request through a generated route table (HTTP method + path pattern → response shape) and replies with a payload the client can bind for that operation, so all 186 operations are exercised without hand-writing a resource per endpoint.

## Live server tests

The `live_tests` group runs a representative scenario subset (team, channel, member, message, reply, tab, and tag CRUD plus key actions) against the real Microsoft Graph API — full live coverage of all 186 operations is impractical because most depend on interrelated, pre-existing resources.

Configuration is provided via `tests/Config.toml` (gitignored — never commit real secrets). Copy the placeholder values in that file and fill in your own, or create it fresh with the fields below.

Two OAuth2 grants are supported, selected by `authMode`:

### App-only (`client_credentials`) — no user or refresh token needed

Uses just the app registration's ID, secret, and tenant:

```toml
isLiveServer = true
authMode = "client_credentials"
clientId = "<app-id>"
clientSecret = "<client-secret-value>"
tenantId = "<tenant-id>"
```

This requires **application permissions** (not delegated) granted and admin-consented on the app registration. Note: the client secret's **Secret ID** (the GUID label in the Entra portal) is not a credential — only the secret **Value** is used as `clientSecret`.

### Delegated (`refresh_token`) — requires a signed-in user

Needs a refresh token obtained once via an interactive authorization-code sign-in:

```toml
isLiveServer = true
authMode = "refresh_token"
clientId = "<app-id>"
clientSecret = "<client-secret-value>"
tenantId = "<tenant-id>"
refreshToken = "<refresh-token>"
```

Then run:

```bash
bal test --groups live_tests
```

## Scenario tests

Alongside the per-endpoint tests, the `scenarios` group contains end-to-end flows that chain
dependent operations (create → read → update → … → delete) and assert on values returned by the
real service. They mirror the runnable samples under `examples/`:

| Scenario test | Mirrors example | Chained operations |
|---------------|-----------------|--------------------|
| `testScenarioChannelLifecycle` | `team-and-channel-setup` | getPrimaryChannel → createChannel → getChannel → updateChannel → getChannel → getChannelFilesFolder* → listChannels → deleteChannel |
| `testScenarioMessageThread` | `channel-message-thread` | createChannelMessage → getChannelMessage → createChannelMessageReply → listChannelMessageReplies → getChannelMessageReply → listChannelMessages → updateChannelMessage → (inline hostedContents: create → listHostedContents → getHostedContentValue)* → getChannelMessagesDelta* → setReaction → unsetReaction → softDelete → undoSoftDelete (last two best-effort) |
| `testScenarioChannelMembersRead` | `channel-member-management` | listChannelMembers → getChannelMember |
| `testScenarioChannelMemberManagement` | `channel-member-management` | createMember (team-roster prereq) → createChannel (private) → createChannelMember → getChannelMember → updateChannelMember → listChannelMembers → deleteChannelMember → deleteChannel → deleteMember |
| `testScenarioTeamMemberAddRemove` | `channel-member-management` | createMember → getMember → listMembers → updateMember → deleteMember → addMembers → deleteMember |
| `testScenarioTabManagement` | (new) | listChannelTabs → createChannelTab → getChannelTab → updateChannelTab → listChannelTabs → deleteChannelTab (whole scenario skips if the app isn't installed / `TeamsTab.*` not consented) |
| `testScenarioActivityNotification` | (new) | sendActivityNotification* (systemDefault, to the signed-in user) |
| `testScenarioTagManagement` | `team-tag-management` | createTag → getTag → updateTag → getTag → listTagMembers → (createTagMember → getTagMember → deleteTagMember) → listTags → deleteTag |
| `testScenarioTeamProvisioning` | `team-and-channel-setup` (extended) | createTeam → (await provisioning) → getTeam → updateTeam → getPrimaryChannel → createChannel ×3 → listChannels → createMember → createChannel (private) → createChannelMember → listChannelMembers → deleteTeam |

`*` = best-effort step: it runs but logs-and-skips if the tenant or permission set doesn't allow it,
rather than failing the scenario.

These do meaningful work only against the live server (each returns early when `isLiveServer` is
false), so configure live credentials as above, set `isLiveServer = true`, then run:

```bash
bal test --groups scenarios
```

### Additional scenario configuration

Beyond the OAuth2 + `teamId`/`channelId` fields, scenarios use:

```toml
# Object id of the signed-in user. Required by the tag scenario (a new tag must have a member).
userId = "<signed-in-user-object-id>"

# Optional. A second tenant user's object id. Enables the team-member and tag-member add/remove
# steps and the private-channel member scenario, which need a user who isn't already a member.
# Left empty, those steps/scenarios are skipped.
secondUserId = "<second-user-object-id>"

# Optional. A Teams app installed in the team, used by testScenarioTabManagement to create a tab.
# Defaults to the built-in Website app. If the app isn't installed or TeamsTab.* isn't consented,
# the tab scenario logs a note and skips.
tabTeamsAppId = "com.microsoft.teamspace.tab.web"

# Opt-in. Runs testScenarioTeamProvisioning, which creates a REAL team (slow) and can only
# auto-delete it with Group.ReadWrite.All. It is the only scenario that covers createTeam / getTeam /
# updateTeam / deleteTeam live. Off by default.
runTeamProvisioning = false
```

Manual prerequisites / known service constraints these scenarios account for:

- **Team and private-channel creation are asynchronous.** `POST /teams` (and creating a private or
  shared channel) returns `202 Accepted` with an empty body and the new resource's location in a
  header. `createTeam`/`createChannel` read that `Location`/`Content-Location` header and return the
  new id; the team-provisioning scenario then polls until the resource is ready before using it.
- **Deleting a created team needs `Group.ReadWrite.All`.** Without it `deleteTeam` returns 403, so
  the team-provisioning scenario logs the team id for manual cleanup rather than failing.
- **Team/channel PATCH returns `204 No Content`** while `updateTeam`/`updateChannel` declare the
  entity as their return type. The connector handles this by re-fetching the resource after a 204,
  so those methods still return the updated entity.
- **Message reactions require a Unicode emoji** (e.g. `👍`) as `reactionType` — reaction names such
  as `"like"` are rejected with HTTP 400.
- **Channel-scoped member add** works only on private/shared channels (standard channels inherit the
  team roster). The team-provisioning scenario creates a private channel to exercise it; the
  membership add/remove scenario otherwise operates at the team level.
- **A second tenant user** is needed for the add/remove member and tag-member steps; without one
  (`secondUserId` empty) those steps are skipped rather than failing.
- Soft-delete of channel messages needs the delegated `ChannelMessage.ReadWrite` scope — which is
  distinct from `ChannelMessage.Edit`/`.Send`/`.Read.All`. The message scenario attempts it and
  skips (logging a note) if that scope isn't consented, rather than failing.
