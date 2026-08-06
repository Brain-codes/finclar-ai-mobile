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

---

## 5. CI — releasing automatically on push

`.github/workflows/release.yml` runs the **same fastlane lanes** on GitHub Actions. The
workflow is only the runner: it installs Flutter/Ruby/Java, restores the secret files
that are gitignored locally, and calls `bundle exec fastlane beta skip_ios:true`. All
version, build, upload, tag and push logic stays in `fastlane/Fastfile` — never
duplicate it into the YAML.

**Triggers:** every push to `main` (excluding markdown/docs-only pushes), plus a manual
**Run workflow** button with optional `bump` and `skip_git` inputs.

The lane's release commit is `chore(release): X.Y.Z+N [skip ci]`, and GitHub honours
`[skip ci]`, so the push fastlane makes back to `main` does not retrigger the workflow.

### Required repository secrets

Settings → Secrets and variables → Actions:

| Secret | Contents | Required? |
| --- | --- | --- |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Full contents of `fastlane/firebase-service-account.json` | **Yes** |
| `ENV_JSON` | Full contents of your local `env.json` (`OPENAI_API_KEY`, `MONO_PUBLIC_KEY`, …) | Strongly recommended — without it the release ships with empty API keys |
| `ANDROID_KEYSTORE_BASE64` | `base64 -i ~/finclar-upload.jks \| pbcopy` | Recommended — without it the APK is debug-signed |
| `ANDROID_KEYSTORE_PASSWORD` / `ANDROID_KEY_PASSWORD` / `ANDROID_KEY_ALIAS` | Values from `android/key.properties` | With the keystore |

App IDs and tester groups are **not** secrets — they already live in
`fastlane/.env.default`, which is committed.

### iOS on CI

The workflow passes `skip_ios:true`. iOS needs a `macos-latest` runner plus the
signing certificate and provisioning profile imported into a temporary keychain
(fastlane `match` or `import_certificate` + `install_provisioning_profile`). Because the
umbrella `beta` lane bumps the version once and then cruises both platforms, keep it as
a **single job** on macOS when you enable iOS — do not split Android and iOS into two
jobs, or each would compute its own version bump.

---

## 6. In-app tester feedback (App Distribution SDK)

Testers can submit feedback + a screenshot from inside the app via a persistent
notification (wired in `MainActivity.onCreate` → `showFeedbackNotification`). Two
Gradle deps in `android/app/build.gradle.kts`:

- `firebase-appdistribution-api` — in **all** variants; calls no-op without the full SDK.
- `firebase-appdistribution` (full) — **`releaseImplementation` only** (the Firebase
  beta build). Feedback appears in the Firebase console under each release's
  **Tester feedback** tab, and Owners/Editors get email alerts.

Requires the **Firebase App Testers API** enabled (Google Cloud console → APIs).

### ⚠️ MANDATORY before shipping to Google Play

The full SDK contains self-update functionality that **violates Google Play policy** —
submitting it can get the app removed. Right now the `release` build type serves both
Firebase beta and (future) Play, so before the first Play submission you MUST split them:

1. Add a product flavor (e.g. `beta` vs `prod`) or a dedicated build type.
2. Scope the full SDK to the testing-only variant
   (`betaImplementation("...firebase-appdistribution:...")`), leaving `prod` api-only.
3. Point `fastlane android beta` at the testing variant
   (`flutter build apk --release --flavor beta`) and update the artifact path in
   `fastlane/Fastfile` (becomes `build/app/outputs/flutter-apk/app-beta-release.apk`).

Until then, distribute **only via Firebase**, never Play.
