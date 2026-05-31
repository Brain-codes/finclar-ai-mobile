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

## 7. Screen Decomposition Rule

**A screen file must be a thin composer. It owns state, navigation, and layout — not widget implementations.**

Any widget class inside a screen file that is longer than ~20 lines, or that could meaningfully stand alone, must be extracted to its own file inside `features/<feature>/presentation/widgets/`.

### When to extract
Extract a private class from a screen file into a widget file when:
- It has its own layout logic (Column, Row, Stack, ListView, etc.)
- It could be reused by another screen or widget in the same feature
- Moving it out would make the screen file noticeably easier to read

### Naming convention
Widget files are named after what they render, not the screen they came from:
- `expense_tile.dart` not `expenses_screen_tile.dart`
- `expense_empty_state.dart` not `empty_card.dart`
- `expense_summary_card.dart` not `filled_card.dart`

### What stays in the screen file
- The `StatefulWidget` / `StatelessWidget` screen class itself
- State variables and lifecycle methods
- Navigation callbacks (`_onEdit`, `_onDelete`, `_pickMonth`)
- The `build` method composing the extracted widgets
- Very small local widgets (under ~15 lines, used only once in that screen) — e.g. a FAB

### Shared helpers across a feature
If multiple widgets or screens in the same feature use the same helper function (e.g. color/icon mapping by category), extract it into a dedicated utility file:
- `features/<feature>/presentation/widgets/<feature>_<concern>_utils.dart`
- Example: `expense_category_utils.dart` exports `expenseCategoryColor()`, `expenseCategoryBgColor()`, `expenseCategoryIcon()`
- Never duplicate the same switch/map logic across multiple files — one source of truth.

### Reuse before creating
Before writing a new private widget, check if a similar public widget already exists in:
1. `lib/shared/widgets/` — global reusables (buttons, inputs, sheets, top bars)
2. `features/<feature>/presentation/widgets/` — feature-scoped reusables

If a widget already exists but needs a slight variation for a new screen, add a parameter to the existing widget rather than creating a copy. Only create a new widget if the variation is structural, not cosmetic.

### Example — before and after

**Wrong** — everything in one file:
```
expenses_screen.dart  (400+ lines)
  _Header, _EmptyCard, _FilledCard, _CategoryBar,
  _CategoryLegend, _ExpenseList, _ExpenseTile, _ExpenseIcon, _Fab
```

**Correct** — screen is a thin composer:
```
expenses_screen.dart          (~80 lines — state + build only)
widgets/
  expense_header.dart
  expense_empty_state.dart
  expense_summary_card.dart   (includes CategoryBar + CategoryLegend)
  expense_tile.dart           (includes ExpenseCategoryIcon)
  expense_list.dart
  expense_category_utils.dart (shared color/icon helpers)
```

---

## 8. Components Rule (Shared Widgets)

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

## 9. Navigation Rules

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

---

## 17. Building Screens from Figma (TalkToFigma MCP)

This section captures what to read, extract, and apply whenever a screen or flow is implemented from a Figma design using the TalkToFigma MCP.

### Node ID format
Figma node IDs use `:` as a separator (e.g. `29:50650`), not `-`. Always pass them in this format to `get_node_info` / `get_nodes_info`.

### Read strategy
- Fetch all nodes for a given task in a **single `get_nodes_info` call** to reduce round trips.
- The result can be very large. Read it in `python3` character-slice chunks, not with the `Read` tool (lines are too long). Extract only what matters: text content, colors, cornerRadius, size/layout, and component names.
- Extract these things from each node:
  - **Text nodes**: `characters` (label copy), `style.fontFamily`, `style.fontWeight`, `style.fontSize`, `style.textAlignHorizontal`, `fills[].color`
  - **Frame/Container nodes**: `fills[].color`, `cornerRadius`, `absoluteBoundingBox` (width/height for proportions)
  - **Named component instances**: use the `name` field to identify the design system component being used (e.g. `button state`, `input field state`, `tab bar`)

### What to extract before writing any code
For every screen or sheet, identify and note:
1. Background color → map to `context.scaffoldColor` or `context.surfaceColor`
2. Top bar pattern → back arrow only, back + title, or back + action pill (edit/delete)
3. Card shapes → `cornerRadius` maps to `AppRadius.*` (24 = `radiusSheet`, 16 = `radiusCard`, 100 = `radiusFull`)
4. Empty state → icon or illustration + heading + subtitle, centered inside a surface card
5. FAB presence → orange circle (`AppColors.primary`) with `AppIcons.add`, positioned bottom-right via `Stack + Positioned`
6. Bottom sheet vs full screen → frames that are 393×852 are full screens; partial-height frames (or frames labeled as sheets) are bottom sheets using `showAppSheet`
7. Button copy → extract exact label text (`Save changes`, `Done`, `Delete`, `Cancel`)
8. Input field types → text vs numeric vs multiline (maxLines > 1)
9. Tappable rows (select rows) → label on left, value + optional chevron on right — use the `_DetailRow` / `_SelectRow` pattern from `income_details_sheet.dart`
10. Category colors → always use `AppColors.category*` constants, never hardcode hex

### Reference files — always read these before building a new feature screen

| What you need | Reference file |
|---|---|
| Full screen with back button top bar | `lib/features/home/presentation/screens/income_setup_screen.dart` |
| Bottom sheet (title + close + content) | `lib/features/home/presentation/widgets/income_details_sheet.dart` |
| Detail/select rows inside a card | `lib/features/home/presentation/widgets/income_details_sheet.dart` |
| Add note bottom sheet pattern | `lib/features/home/presentation/widgets/add_note_sheet.dart` |
| Expense tile (icon + name + category color + amount + date) | `lib/features/home/presentation/widgets/recent_expenses_section.dart` |
| Auth screen top bar with back circle button | `lib/features/auth/presentation/screens/login_screen.dart` |
| AppSheet wrapper | `lib/shared/widgets/app_sheet.dart` |
| AppButton, AppTextField | `lib/shared/widgets/app_button.dart`, `lib/shared/widgets/app_text_field.dart` |
| AppTopBar | `lib/shared/widgets/app_top_bar.dart` |
| Theme tokens | `lib/core/utils/extensions/context_extensions.dart` |

### Top bar patterns used in this app

| Pattern | When to use | Implementation |
|---|---|---|
| Back circle only | Full screens where the only action is back | `GestureDetector` wrapping a 36×36 circle container with `context.surfaceVariant` bg + `AppIcons.back` |
| Back circle + action pill | Preview/detail screens with Edit + Delete | Left: back circle. Right: white pill (`context.surfaceColor` + border) containing "Edit" text + divider + delete icon, each tappable |
| No back (shell tabs) | Bottom nav screens (home, expenses, budget…) | Just a title row + optional action icon (filter, search) |

### Bottom sheet pattern
Always use `showAppSheet` from `lib/shared/widgets/app_sheet.dart`. Never build a raw `showModalBottomSheet`. Pass:
- `title` — sheet heading (Bricolage Grotesque via `AppSheet` header)
- `children` — list of content widgets
- `avoidKeyboard: true` — when the sheet contains text fields
- `heightFactor` — when the sheet needs a fixed height (e.g. calendar date picker)

For sheets that return a value (category picker, month picker, note, date), make the `showAppSheet<T>` call typed and `pop` with the result.

### Expense tile / transaction tile pattern
Icon container: circular (`BoxShape.circle`) or rounded card (`AppRadius.radiusCard`), 40×40, category bg color.
Icon inside: 16–20px, category fg color.
Category label text: uses the category **foreground** color (e.g. `AppColors.categoryFood` for Food), not the bg.
Amount: right-aligned, `context.textQuaternary`.
Date: right-aligned below amount, `context.textSecondary`, 12px.

### Category color mapping

| Category | Foreground | Background |
|---|---|---|
| Food | `AppColors.categoryFood` | `AppColors.categoryFoodBg` |
| Transport / Transportation | `AppColors.categoryTransport` | `AppColors.categoryTransportBg` |
| Health | `AppColors.categoryHealth` | `AppColors.categoryHealthBg` |
| Shopping | `AppColors.categoryShopping` | `AppColors.categoryShoppingBg` |
| Default / Other | `AppColors.primary` | `AppColors.primaryMuted` |

Always extract this mapping into a `_categoryColor()` / `_categoryBgColor()` helper in the screen file. Do not inline color logic.

### Stacked bar chart (category breakdown)
Use a `LayoutBuilder` → `Row` of `Container` widgets. Width of each segment = `totalWidth * (categoryAmount / totalAmount)`. Wrap in `ClipRRect` with `AppRadius.radiusXs` for rounded ends. Height: 14px. Segment colors use category foreground colors.

### Month selection sheet
3-column `GridView`, 12 months, `childAspectRatio: 2.6`. Selected month = `AppColors.primary` bg + white text. Unselected = `context.surfaceVariant` bg + `context.textQuaternary` text. Returns the selected month number (1–12).

### Delete confirmation sheet
Structure: centered red circle icon (bg `Color(0xFFF9EAEA)`, icon `AppColors.error`) → heading → subtitle → side-by-side Cancel + Delete buttons. Cancel = `context.surfaceVariant` bg + `context.textSecondary` text. Delete = `AppColors.error` bg + white text. Returns `bool?` (`true` = confirmed).

### SVG / illustration assets
Before using `AppSvgImage(AppSvg.something)`, verify the SVG file exists in `assets/svg/`. If no matching illustration exists, fall back to an `Icon` widget (e.g. `AppIcons.file`, `AppIcons.wallet`) for empty states. Never reference a non-existent `AppSvg` constant.

### Route wiring for new screens
1. Add the path constant to `RouteNames` in `lib/app/routes/route_names.dart`.
2. Add the `GoRoute` to `app_router.dart`. For detail screens that receive an object, pass it via `state.extra` and cast it in the `pageBuilder`.
3. Push with `context.push(RouteNames.yourRoute, extra: yourObject)` from the list tile.
4. Detail screens that live outside the shell (no bottom nav) go **outside** the `ShellRoute` in `app_router.dart`.

---

## 18. Backend API Reference

The full backend API is documented in [`docs/API.md`](docs/API.md).

- **Base URL:** `https://finclar-ai.onrender.com/api/v1`
- **Swagger UI:** `https://finclar-ai.onrender.com/docs`
- `docs/API.md` is the single source of truth for all endpoint paths, request bodies, and response schemas.
- `lib/core/api/api_endpoints.dart` must always mirror `docs/API.md`.

### Rules
- **Before implementing any repository method or API call**, check `docs/API.md` to confirm the endpoint exists and is live.
- Endpoints listed under "Planned — not yet live" in `docs/API.md` must not be called until confirmed.
- When a new endpoint is added to the backend: update `docs/API.md` first, then update `api_endpoints.dart`.
- `default_currency` arrives in `UserResponseDto` after login/register. Always pass it to `AppConfigNotifier.applyCurrency()` immediately after a successful auth response.
- Income sources from `GET /income/sources` serve as the selectable source list in the income setup screen.
