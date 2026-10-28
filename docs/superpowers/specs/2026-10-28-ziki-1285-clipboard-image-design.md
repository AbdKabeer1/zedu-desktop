# Ziki #1285 Clipboard Image Design

## Goal

Ensure screenshots pasted into desktop direct messages always have a valid local path before the existing message payload is created.

## Approach

- Persist non-empty PNG clipboard bytes to a uniquely named file under `Directory.systemTemp`.
- Return a disk-backed `XFile` that keeps the display name `Pasted Image.png` and MIME type `image/png`.
- Make the DM composer await persistence before adding the attachment.
- Keep the repository payload contract unchanged; it now receives a valid path.

## Constraints

- No API, dependency, or native-project changes.
- Empty clipboard data must not create a file.
- File names must be unique across rapid consecutive pastes.
- Static analysis and the full Flutter test suite must pass.

## Delivery

- Clean branch based on `zeduchat/zedu-desktop:central-staging`, where the defect is still present.
- Push to the authenticated contributor fork and open the PR against `zeduchat/zedu-desktop:central-staging` so only #1285 changes are included.
- Link the PR to Ziki #1285 with test evidence before the active claim expires.
