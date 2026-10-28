# Status

Last updated: 2026-10-28

## Done

- Reproduced the stale subtitle on `central-staging`.
- Added a widget test that failed before the copy change and now passes.
- Full Flutter suite passes 32/32.
- Fatal analysis and format checks pass.
- Opened https://github.com/zeduchat/zedu-desktop/pull/338.
- Posted PR and test evidence to Ziki delivery comment `cmvsee3ih0jzut101zv1waq5h`.

## In progress

- PR review and Ziki issue confirmation.

## Blocked

- Ziki #248 is assigned to the user but unconfirmed, so the API refuses to create/accept a claim. Without an active claim, Ziki will not populate `pullRequestUrl`.

## Next

1. Review PR #338.
2. If the issue is confirmed and a claim becomes available, retry the PR-link callback.
