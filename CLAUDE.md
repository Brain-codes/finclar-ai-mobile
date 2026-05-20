# Finclar AI — Development Instructions

This file is the single source of truth for how this project is built. Every code change must follow these rules. No exceptions.

---

## 1. Architecture

### Pattern
Feature-first + lightweight layered architecture. Riverpod for state management. go_router for navigation.

### Folder structure
```
lib/
├── app/
│   ├── routes/         # Router and route name constants only
│   └── app.dart        # Root MaterialApp.router
├── core/
│   ├── api/            # ApiClient, endpoints, interceptors, response models
│   ├── constants/      # AppStrings, AppConstants
│   ├── errors/         # AppException and subclasses
│   ├── services/       # LoggerService, StorageService, etc.
│   ├── theme/          # AppColors, AppTypography, AppSpacing, AppRadius, AppTheme
│   └── utils/          # Extensions and helpers
├── shared/
│   ├── widgets/        # Global reusable components (AppButton, AppTextField, etc.)
│   ├── components/     # Composite reusable UI blocks
│   └── icons/          # AppIcons wrapper (single source of truth for icons)
├── features/
│   └── <feature>/
│       ├── data/
│       │   ├── models/         # JSON-serializable data models
│       │   └── repositories/   # Repository implementations
│       ├── domain/             # Use cases — ONLY when business logic is non-trivial
│       ├── presentation/
│       │   ├── screens/        # Full screens (one file per screen)
│       │   └── widgets/        # Feature-scoped widgets
│       └── providers/          # Riverpod providers for this feature
└── main.dart
```

### Feature list
- `splash` — 3 onboarding splash screens
- `auth` — sign_up, verify (email & phone), login, forgot_passcode
- `home` — dashboard, income_setup (AI or manual), ai_setup (one-time)
- `expenses` — list, add_manual, add_ocr, bank_integration
- `budget` — list, create_manual
- `group` — list, create, detail, add_friend
- `settings` — main settings screen
- `subscription` — plans and upgrade flow

---

## 2. Design System Rules

**Never hardcode colors, font sizes, spacing, or border radii anywhere in the app.**

| Concern | Use |
|---|---|
| Colors | `AppColors.*` |
| Text styles | `AppTypography.*` |
| Font families | `AppFonts.display` (Bricolage Grotesque) or `AppFonts.body` (Geist) |
| Spacing values | `AppSpacing.*` |
| Border radii | `AppRadius.*` |
| Icons | `AppIcons.*` |
| String literals | `AppStrings.*` |
| Constants (keys, timeouts, etc.) | `AppConstants.*` |

### Theme
- Light mode is the primary design target.
- Dark mode must be supported. Use `Theme.of(context).colorScheme` in widgets where values differ between modes. Use `AppColors` constants only for values that are the same in both modes.
- `ThemeMode` is currently set to `ThemeMode.light` in `app.dart`. Dark mode will be enabled later — do not remove dark theme wiring.

---

## 3. Icons Rule

**Never import or use `remixicon` (or any icon package) directly in feature code.**

Always go through `AppIcons`:
```dart
// CORRECT
Icon(AppIcons.home)

// WRONG — do not do this
Icon(Remix.home_4_line)
```

To add a new icon:
1. Add it to `lib/shared/icons/app_icons.dart` with a semantic name.
2. Use `AppIcons.yourName` everywhere else.

This means if the icon package is ever swapped, only `app_icons.dart` changes.

---

## 4. SVG Rule

**Never import `flutter_svg` or reference SVG path strings directly in feature code.**

All SVGs go through two wrappers:

| Wrapper | Purpose |
|---|---|
| `AppSvg` (`lib/shared/svg/app_svg.dart`) | Holds every SVG asset path as a named constant. Single source of truth for paths. |
| `AppSvgImage` (`lib/shared/widgets/app_svg_image.dart`) | The only widget that renders SVGs. Wraps `SvgPicture` so the package can be swapped without touching feature code. |

```dart
// CORRECT
AppSvgImage(AppSvg.google, width: 24, height: 24)
AppSvgImage(AppSvg.logo, color: context.textPrimary, width: 120)

// WRONG — never do this
SvgPicture.asset('assets/svg/google.svg')
import 'package:flutter_svg/flutter_svg.dart'; // in a feature file
```

Adding a new SVG:
1. Drop the `.svg` file into `assets/svg/`
2. Add a `static const String` to `AppSvg` with a semantic name
3. Use `AppSvgImage(AppSvg.yourName, ...)` everywhere it's rendered

---

## 4. Logging Rule

**Never use `print`, `debugPrint`, or `Logger` directly in feature code.**

Always go through `Log`:
```dart
// CORRECT
Log.d('Fetching transactions...');
Log.e('Failed to load', error: e, stackTrace: st);
Log.api('POST', '/auth/login', body: body);

// WRONG — do not do this
print('something');
Logger().d('something');
```

`Log` is defined in `lib/core/services/logger_service.dart`. If the logger package needs to change, only that file changes.

---

## 5. API Rule

**Never instantiate `Dio` or make HTTP calls directly in feature code.**

All API calls go through `ApiClient`:
```dart
// CORRECT — in a repository
final response = await _api.post<UserModel>(
  ApiEndpoints.login,
  body: {'email': email, 'passcode': passcode},
  fromData: (data) => UserModel.fromJson(data),
);

// WRONG — do not do this
final dio = Dio();
final res = await dio.post('https://api.finclar.com/auth/login', ...);
```

### Response format
All responses are wrapped in `ApiResponse<T>`. The backend is expected to return:
```json
{
  "success": true,
  "message": "...",
  "data": { ... }
}
```

If the backend deviates, fix it in `ApiResponse.fromJson` — not at the call site.

### Endpoints
All URLs live in `ApiEndpoints`. Never write a URL string outside that file.

---

## 6. State Management Rules

- Use **Riverpod** exclusively. No `setState` for non-local state.
- Providers live in `features/<feature>/providers/`.
- Keep providers small and focused — one provider per concern.
- Use `AsyncNotifier` for async state, `Notifier` for sync state, `StreamProvider` for real-time data.

```dart
// Good — focused provider
final transactionListProvider = AsyncNotifierProvider<TransactionNotifier, List<Transaction>>(
  TransactionNotifier.new,
);

// Bad — catch-all provider with too many responsibilities
final appProvider = ...
```

---

## 7. Components Rule

**If a UI element is used in more than one place, it must be a component.**

- Global reusable widgets (buttons, inputs, cards, loaders) → `lib/shared/widgets/`
- Feature-specific reusable widgets → `features/<feature>/presentation/widgets/`
- Never copy-paste widget code. Extract it.

### Mandatory shared components — always use these, never inline them

| Component | File | Usage |
|---|---|---|
| `AppButton` | `shared/widgets/app_button.dart` | Every button in the app. Pass `label`, `onTap` (null = disabled), `isLoading`, `variant` (`primary`/`secondary`/`outline`/`ghost`), optional `icon`. Never use `ElevatedButton`, `TextButton`, or `GestureDetector`+`Container` for buttons directly. |
| `AppTextField` | `shared/widgets/app_text_field.dart` | Every text input. Pass `label`, `hint`, `controller`, `errorText`, `onChanged`, etc. Never write a raw `TextField` or `TextFormField` in screen code. |
| `AppTopBar` | `shared/widgets/app_top_bar.dart` | Every screen top bar that has a back arrow and/or a step label. Pass `onBack`, `stepLabel`, `showBack`. Never inline a Row with a back-arrow GestureDetector. |
| `AppTextLink` | `shared/widgets/app_text_link.dart` | Inline "prompt + tappable action" pairs (e.g. "Have an account? Login", "Didn't receive code? Resend"). Pass `prompt`, `actionLabel`, `onTap`. Never inline these as a Row of Text + GestureDetector. |
| `AppScreenHeader` | `shared/widgets/app_screen_header.dart` | Screen title + optional subtitle + optional highlighted text. Pass `title`, `subtitle`, `highlightedText`. Never inline heading + subtitle Text widgets directly. |
| `AppOtpField` | `shared/widgets/app_otp_field.dart` | OTP and passcode input boxes. |
| `AppSnackbar` | `shared/widgets/app_snackbar.dart` | Always call via `AppSnackbar.success/error/warning/info(context, message)`. Never use `ScaffoldMessenger` directly. |

Standard shared components to build as needed:
- `AppCard` — rounded container with shadow
- `AppLoader` — consistent loading indicator
- `AppBottomSheet` — base bottom sheet wrapper
- `AppChip` — tag/badge component
- `TransactionTile` — reusable transaction list item
- `AppSkeleton` — shimmer skeleton loader. Use `AppSkeleton`, `AppSkeleton.text`, `AppSkeleton.circle` for individual bones. Pre-built layouts: `SkeletonCard`, `SkeletonTransactionList`, `SkeletonBalanceCard`. Never use a spinner where a skeleton makes more sense.

---

## 8. Navigation Rules

- Use **go_router** exclusively. Never use `Navigator.push` directly.
- All route paths live in `RouteNames`. Never write a path string outside that file.

### Which method to use

| Method | When to use |
|---|---|
| `context.push()` | Going forward to a new screen the user should be able to swipe back from. Use between sibling screens (e.g. login ↔ signup) and any screen in a forward flow. |
| `context.pop()` | Explicitly going back when you know there is something below (e.g. a cancel button). Always guard with `context.canPop()` if there is any doubt. |
| `context.go()` | One-way exits only — splash → auth, successful auth → home, logout → login. These clear the stack intentionally so the user cannot swipe back. |

```dart
// CORRECT
context.push(RouteNames.signUp);       // login → signup, swipe-back works
context.push(RouteNames.login);        // signup → login, swipe-back works
context.go(RouteNames.home);           // after login — clears auth stack
if (context.canPop()) context.pop();   // safe explicit back

// WRONG
context.go(RouteNames.login);          // on a screen the user should swipe back from
Navigator.push(context, MaterialPageRoute(builder: (_) => SomeScreen()));
```

### Swipe-back requirements
- All routes use `pageBuilder` with `MaterialPage` so iOS gets the native `CupertinoPageRoute` swipe-back gesture automatically.
- Never use `CustomTransitionPage` for routes that need swipe-back — it breaks the iOS gesture recogniser.
- `PopScope(canPop: false)` kills the swipe gesture. Only use it when you need to intercept back (e.g. multi-phase screens). Make `canPop` dynamic where possible so the gesture still works in phases that allow it.

---

## 9. Code Style

- No comments explaining what code does. Only comment WHY if it's non-obvious.
- No multi-line comment blocks or docstrings.
- Prefer `const` constructors wherever possible.
- No magic numbers — use `AppSpacing`, `AppRadius`, or a named constant.
- Screen files: one screen per file, named `<feature>_screen.dart`.
- Widget files: one widget per file when the widget is non-trivial.
- Model files: one model per file. Follow the model rules in section 10.

---

## 10. Model Rules

**Every piece of data that enters or leaves the app must pass through a model. No manual mapping anywhere outside the model file.**

### Pattern — follow this exactly

```dart
import 'dart:convert';

// Top-level helpers for raw JSON string parsing
UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));
String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  final String name;
  final int age;
  final String email;
  final bool isActive;
  final Address? address;
  final List<String> hobbies;
  final String? metadata;

  UserModel({
    required this.name,
    required this.age,
    required this.email,
    required this.isActive,
    this.address,
    required this.hobbies,
    this.metadata,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json["name"],
        age: json["age"],
        email: json["email"],
        isActive: json["isActive"],
        address: json["address"] != null ? Address.fromJson(json["address"]) : null,
        hobbies: json["hobbies"] != null
            ? List<String>.from(json["hobbies"].map((x) => x))
            : [],
        metadata: json["metadata"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "age": age,
        "email": email,
        "isActive": isActive,
        "address": address?.toJson(),
        "hobbies": List<dynamic>.from(hobbies.map((x) => x)),
        "metadata": metadata,
      };
}
```

### Rules
- All fields are `final`. Models are immutable.
- Nullable fields use `?`. Never assume a backend field is always present.
- Nested objects get their own model class in the same file if small, or their own file if complex.
- Lists always default to `[]` on null, never to `null`.
- `freezed` and `json_serializable` are available but the default is the manual pattern above. Use them only when a model is genuinely complex (many fields, union types, deep nesting) and code generation provides clear value.
- No `Map<String, dynamic>` passing between layers — always deserialize into a model at the repository boundary and never let raw maps leak into providers or UI.
- Model files live at `features/<feature>/data/models/<name>_model.dart`.

---

## 11. Domain Layer (Use Cases)

Only create a `domain/` folder inside a feature when:
- Business logic is complex enough that it doesn't belong in a repository or provider.
- The same logic is called from multiple providers or screens.
- You need to unit test the logic in isolation.

For simple CRUD features, skip `domain/` entirely and call the repository from providers directly.

---

## 11. Packages

| Package | Purpose |
|---|---|
| `flutter_riverpod` + `riverpod_annotation` | State management |
| `go_router` | Navigation |
| `dio` | HTTP client |
| `drift` + `sqlite3_flutter_libs` | Local relational database |
| `flutter_secure_storage` | Secure token storage |
| `logger` | Logging (via `Log` wrapper only) |
| `remixicon` | Icons (via `AppIcons` wrapper only) |
| `flutter_svg` | SVG rendering (via `AppSvgImage` + `AppSvg` wrappers only) |
| `local_auth` | Biometric authentication |
| `firebase_messaging` | Push notifications |
| `flutter_form_builder` | Form handling |
| `fl_chart` | Charts and analytics |
| `image_picker` | OCR receipt scanning |
| `intl` | Currency and date formatting |

Do not add new packages without discussing first.

---

## 13. Dark Mode

Dark mode is a full requirement, not optional. There is no Figma design for it — use design initiative.

Rules:
- All dark mode colors are defined in `AppColors` (prefixed `dark*`) and applied via `AppTheme.dark`.
- Never hardcode dark mode colors in widgets. Use `Theme.of(context).colorScheme` for values that differ per mode, or define explicit dark constants in `AppColors`.
- Every screen and component built must look correct in both modes. Test both before marking anything done.
- `ThemeMode` will be toggled by the user via Settings. Wire it to a Riverpod provider when implementing settings.

---

## 14. Biometric Auth

Biometric authentication is a core requirement for login.

- Package: `local_auth`
- Scope: login screen only — used as an alternative to passcode entry after the user has already authenticated once.
- The biometric prompt is triggered via a `BiometricService` in `core/services/`. Never call `local_auth` directly from UI or providers.
- On first launch or after logout, passcode login is required. Biometric is offered on subsequent logins.

---

## 15. Push Notifications

Push notifications are a core requirement.

- Package: `firebase_messaging`
- A `NotificationService` in `core/services/` handles all FCM setup, token registration, foreground/background message handling.
- Never call `FirebaseMessaging` directly from features. Always go through `NotificationService`.
- Notification categories to support: transaction alerts, budget limit warnings, group activity, AI insights.

---

## 16. Out of Scope (for now)

- Offline-first / local caching — architecture supports it but do not implement yet.
