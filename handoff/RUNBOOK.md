# Runbook

## Setup

```bash
cp .env.example .env
flutter pub get
```

CI pins Flutter 3.41.5. The local Flutter is 3.47.7 and may rewrite protected/config/lock files; do not commit those generated changes.

## Verify

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test
flutter build macos --debug
```

The build requires a Mac App Development profile for `com.zedu.desktopApp`. If Flutter 3.47 rewrites `analysis_options.yaml`, `macos/Podfile`, `macos/Podfile.lock`, or `macos/Runner.xcodeproj/project.pbxproj`, restore those generated changes; CI uses Flutter 3.41.5.

## Deliver

```bash
git push -u fork fix/ziki-1285-clipboard-image-central
gh pr create \
  --repo zeduchat/zedu-desktop \
  --base central-staging \
  --head AbdKabeer1:fix/ziki-1285-clipboard-image-central
```
