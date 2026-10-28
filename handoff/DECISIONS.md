# Decisions

## Persist before adding the attachment

- The staging repository sends `XFile.path` directly in the DM message payload.
- Writing clipboard bytes to a unique system-temp PNG is the smallest compatible fix.

## Do not port the later bundled upload rewrite

- `zedu-hng:dev` already uploads in-memory bytes, but that behavior arrived inside a large unrelated bundle with route and message-shape changes.
- This PR keeps staging's repository/API contract intact and changes only clipboard attachment creation.

## Use a clean staging-based branch

- The team and review branches contain many unrelated commits not present in `zeduchat:central-staging`.
- A target-based branch keeps the PR limited to #1285.
