# Release Pipeline — Fastlane + Firebase App Distribution

Ships Finclar AI to testers on **Android (free)** and **iOS (needs a paid Apple
Developer account)** via Firebase App Distribution, with the version number driven
automatically by your commit messages.

---

## 1. Versioning — how the number is decided

The single source of truth is the `version:` line in `pubspec.yaml`:

```yaml
version: 1.2.4+37
#        ^^^^^ = version NAME (humans)   ^^ = build NUMBER (stores/Firebase)
```

### Version name `1.2.4` — bumped from your commits

Since the last `vX.Y.Z` git tag, the pipeline scans commit messages and applies the
**highest-precedence** bump it finds:

| Commit message                                   | Bump  | 1.2.4 → |
| ------------------------------------------------ | ----- | ------- |
| `feat!: …` or a body line `BREAKING CHANGE: …`   | major | 2.0.0   |
| `feat: add budget screen`                        | minor | 1.3.0   |
| `fix: correct balance rounding`                  | patch | 1.2.5   |
| `chore:` `docs:` `refactor:` `test:` `style:`    | none  | 1.2.4   |

This is why **commit messages matter** — they *are* the version. Write them as
[Conventional Commits](https://www.conventionalcommits.org): `type(scope): summary`.

You can always override: `bundle exec fastlane bump bump:major`.

### Build number `+37` — automatic, always increasing

It's `git rev-list --count HEAD` (your total commit count). It only ever goes up, so
it never repeats and you never edit it by hand.

---

## 2. One-time setup

### a. Install fastlane

```bash
cd /Users/Efe/Projects/Mobile/finclar_ai
bundle install          # installs fastlane + the Firebase plugin from the Gemfile
```

### b. Firebase service account (auth for uploads)

1. [Firebase Console](https://console.firebase.google.com/) → project **finclar-ai**
   → ⚙️ Project settings → **Service accounts** → **Generate new private key**.
2. Save the downloaded JSON as `fastlane/firebase-service-account.json`
   (already gitignored — never commit it).
3. Make sure **App Distribution** is enabled: Console → Release & Monitor → App Distribution.
4. Create tester groups in the Firebase console (App Distribution → Testers and
   Groups) and add tester emails. Groups are split per platform:
   `android-testers` and `ios-testers` (aliases set in `fastlane/.env.default` as
   `FIREBASE_ANDROID_TESTER_GROUPS` / `FIREBASE_IOS_TESTER_GROUPS`). The Android
   lane only notifies `android-testers` so iPhone-only testers aren't sent a link
   they can't install yet. "Both"-device testers live in both groups.

App IDs are already filled in `fastlane/.env.default`.

### c. Android release keystore (recommended)

Without this, release APKs are debug-signed — they still install via Firebase, but you
can't ship to Google Play later, and the signature changes if anyone else builds.

```bash
keytool -genkey -v -keystore ~/finclar-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
cp android/key.properties.example android/key.properties   # then edit with real values
```

`android/key.properties` is gitignored. The Gradle config auto-detects it and falls
back to debug signing when it's absent, so nothing breaks without it.

### d. iOS signing (needed only for the iOS lane)

iOS distribution requires a **paid Apple Developer Program** membership — a free
account cannot sign for Firebase/ad-hoc, and this app uses *Sign in with Apple*, which
is paid-only. Once you have your own account:

1. Xcode → Settings → Accounts → add your Apple ID (Admin/App Manager on the team).
2. Set the team in `ios/ExportOptions.plist` and the Runner target if it differs from
   `R5TMQ2Q9WM`.
3. iOS testers must have their **device UDID registered** (ad-hoc, 100 devices/yr).

---

## 3. Daily use

```bash
# Preview the next version without touching anything
bundle exec fastlane bump dry_run:true

# Android only — free, works today
bundle exec fastlane android beta

# iOS only — needs paid Apple account set up
bundle exec fastlane ios beta

# Both platforms, then commit the version bump + tag vX.Y.Z + push
bundle exec fastlane beta
bundle exec fastlane beta skip_ios:true      # skip iOS until Apple account is ready
bundle exec fastlane beta skip_git:true      # don't commit/tag/push
```

Each `beta` run: computes the version → writes `pubspec.yaml` → builds → uploads to
Firebase with the commit list as release notes. The full `beta` lane also tags the
release `vX.Y.Z` so the next run knows where to start counting commits from.

---

## 4. Notes

- **Firebase App Distribution is invite-only**, not a public store. Android testers get
  a download link; iOS testers must have their device UDID registered first.
- The `vX.Y.Z` tags are what the bump logic reads to know "commits since last release."
  The first `beta` run with no tags yet analyses your whole history.
- CI: set `FIREBASE_SERVICE_ACCOUNT` and the Android keystore as CI secrets and run the
  same lanes; nothing else changes.
