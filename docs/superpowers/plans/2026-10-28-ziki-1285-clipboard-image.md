# Ziki #1285 Clipboard Image Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give pasted screenshot attachments a valid disk path before DM message submission.

**Architecture:** Add a focused clipboard-file utility in the DM presentation layer. The composer converts clipboard bytes through it and continues using the existing attachment and repository flow.

**Tech Stack:** Flutter, Dart, cross_file, flutter_test.

**Spec:** `docs/superpowers/specs/2026-10-28-ziki-1285-clipboard-image-design.md`

## Global Constraints

- Keep the existing DM API payload and repository unchanged.
- Do not add dependencies or modify protected/native files.
- Use a unique system-temporary PNG path.

## Review Focus

- Empty bytes must be rejected without creating a file.
- The returned XFile path must exist and contain the exact bytes.
- Rapid pastes must not overwrite each other.
- The composer must await persistence before adding the attachment.
- File name and MIME type must remain correct for upload/display.

---

### Task 1: Disk-backed clipboard image utility

**Files:**
- Create: `lib/features/dms/presentation/components/composer/pasted_image_file.dart`
- Modify: `lib/features/dms/presentation/components/composer/composer.dart`
- Create: `test/unit/features/dms/presentation/pasted_image_file_test.dart`

- [ ] Write failing tests for valid bytes, empty bytes, metadata, and unique paths.
- [ ] Run the focused test and verify RED because the utility does not exist.
- [ ] Implement `persistClipboardPng(Uint8List bytes, {Directory? directory, int? uniqueId})` returning `Future<XFile>`.
- [ ] Run the focused test and verify GREEN.

### Task 2: Composer integration

**Files:**
- Modify: `lib/features/dms/presentation/components/dm_message_composer.dart`

- [ ] Replace `XFile.fromData` with awaited `persistClipboardPng(bytes)`.
- [ ] Await `addFiles` so attachment validation completes in order.
- [ ] Run focused tests, format, analyze, and full tests.

### Task 3: Delivery

**Files:**
- Create: `handoff/README.md`, `handoff/STATUS.md`, `handoff/DECISIONS.md`, `handoff/RUNBOOK.md`

- [ ] Review the target diff for scope and secrets.
- [ ] Commit and push without force.
- [ ] Open the PR and link it to Ziki #1285 with test evidence.
