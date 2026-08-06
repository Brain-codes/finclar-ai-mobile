# Handoff

## 1. Goal

Bring the app in sync with backend API changes shipped since the last doc sync
(2026-08-02 live OpenAPI diff), working through a shared checklist one slice at a
time so the user can test each slice before the next starts. The broader
motivation: the founder wants Clara to be transparent about which figures are
AI-verified vs self-reported, and the backend now supports that plus a
"Wrapped" year-in-review feature and a user-chosen display name.

## 2. Current state

**Trusted baseline:** whole-project `flutter analyze` is clean right now — that
is the last verified-working checkpoint. Nothing has been run on a device in
this session; all verification has been static analysis only. The user has
manually tested and confirmed working: group-member removal + redistribution,
expense verification badges (after a redesign), and the home insight
transparency line/balance card. The user has NOT yet confirmed: the Wrapped
screen end-to-end, the preferred-name onboarding step, or the auto-fit text
sizing added in the last two exchanges.

**Known-good, tested by user:**
- Group member removal now asks who absorbs the departing member's unpaid
  share (`?redistribution=self|split`), which the backend made a *required*
  param — this was silently broken (422) before the fix.
- Expense tiles/detail show a "Verified"/"Self-reported" label (icon + text,
  not just color) — went through two redesign rounds per user feedback (see
  Failed attempts).
- Home Clara card shows a verified/self-reported % split bar + line; balance
  card uses backend `available_balance` instead of a client-derived number.

**Built but not yet user-tested:**
- Preferred name: onboarding step (skippable), Settings edit sheet, `Home`
  greeting and Settings header now read `displayName`.
- Wrapped: all 9 slides wired to `GET /wrapped`, loading/error states, a
  "Money passport" settings row that was previously a dead `onTap: () {}`,
  hold-to-pause on the story, and — just now — auto-fit shrinking text
  instead of overflow/ellipsis on every backend-driven headline/body.

**Not done at all (backend blockers — see `docs/API.md` "Planned / Not Yet
Live" + "Asked for, not yet built"):**
- No endpoint to attach proof to an *existing* expense, so `evidence_suggested`
  is display-only — do not build an "attach a receipt?" action.
- `POST /groups/{group_id}/members` still 404s.
- Clara conversation-context / "chat isn't saved" issues are backend/prompt
  work, out of scope for this app.

## 3. Active files

- `docs/API.md` — single source of truth for the backend contract; was
  rewritten this session against the live OpenAPI spec. Read this before
  touching any repository method.
- `MEMORY.md` — dated changelog with far more implementation detail than this
  file. Has a full entry for every change below under "2026-08-02". Read this
  next if you need the *why*, not just the *what*.
- `lib/core/api/api_client.dart` — `delete()` gained `queryParams` (needed for
  the redistribution fix); shared by every repository.
- `lib/features/gamification/presentation/widgets/wrapped/wrapped_shared.dart`
  — home of `WrappedAutoText` (the auto-fit widget), `WrappedHeadline`,
  `WrappedSubtitle`, `WrappedProgressBar`. Central to the last two exchanges.
- `lib/features/gamification/presentation/widgets/wrapped/wrapped_slide_*.dart`
  (all 9) — each now takes typed data instead of hardcoded mock strings.
- `lib/features/gamification/presentation/screens/wrapped_screen.dart` —
  fetches via Riverpod, splits into `WrappedScreen` (fetch/loading/error) and
  `WrappedStory` (the actual PageView), builds the slide list dynamically
  (skips slide 4 when `topCategory` is null).
- `lib/features/gamification/data/models/wrapped_model.dart` — `WrappedModel`
  + 9 section models mirroring the backend schema exactly.
- `lib/features/auth/data/models/user_model.dart` — gained `preferredName`,
  `profileIcon`, `displayName` (with local fallback logic).
- `lib/features/auth/presentation/widgets/preferred_name_step.dart` — new
  onboarding step, folded into `preference_screen.dart` as a two-phase screen.
- `lib/features/settings/presentation/widgets/edit_preferred_name_sheet.dart`
  — replaces the old `edit_username_sheet.dart` (deleted — it never saved
  anything, see Failed attempts).
- `lib/features/expenses/presentation/widgets/expense_verification_badge.dart`
  — the verification label widget, redesigned twice this session.
- `lib/shared/widgets/clara_note.dart` — renders inline `clara_insight` on
  expense detail; blank-safe (`SizedBox.shrink()` on empty).

## 4. Changes made

- **Fixed a live bug**: group member removal was silently failing (422) because
  the backend made `redistribution` required with no client change to match.
- **New**: verification badges on expenses (green "Verified" / amber
  "Self-reported", icon + text, WCAG-AA-checked colors).
- **New**: home screen shows a verified/self-reported percentage split under
  Clara's insight, and the balance card reads the backend's own balance figure
  instead of computing income-minus-expenses locally.
- **New**: `clara_insight` (a short AI note) surfaces on expense detail and
  the budget screen, replacing a fake hardcoded sentence on the budget card.
- **New**: users can set a preferred display name (onboarding + Settings),
  used everywhere the app used to show `username`.
- **New**: the "Wrapped" year-in-review feature is fully wired to the backend
  — was previously 9 slides of entirely hardcoded mock text/numbers. Two
  fabricated claims that had no backing API field were removed rather than
  kept as mock data (a made-up "24% faster than last month" badge, and a
  "Recommendation" card with an invented number).
- **New**: a "Money passport" row in Settings that used to do nothing now
  opens Wrapped.
- **New**: hold-to-pause on the Wrapped story (long-press pauses, release
  resumes from the same point, doesn't restart the slide).
- **Changed**: text on Wrapped slides that is backend-authored (headlines,
  descriptions, names) now auto-shrinks to fit instead of truncating with
  "…" — see section 5 for why this took three attempts.
- **Not mine — pre-existing in the diff, untouched by me**: `app_svg.dart`,
  `badge_widget.dart`, `gamification_preview_screen.dart`, and three new
  files under `assets/images/wrapped/` show as modified/untracked in git but
  were not edited in this session. Confirm with the user whether these are
  their own in-progress work before assuming they're safe to revert.

## 5. Failed attempts

- **DO NOT re-add a 6px colored dot for verification status.** First attempt
  used a bare color dot with a long-press tooltip. Rejected: fails WCAG
  color-only-conveys-meaning, and a tooltip needing long-press is
  undiscoverable on mobile. Also do not use dark-red/dark-amber text directly
  on the tinted background colors (`AppColors.success`/`warning` on
  `successLight`/`warningLight`) — that pairing is only ~3–4.4:1 contrast,
  under the 4.5:1 minimum. Use `context.successOn`/`warningOn` instead.
- **DO NOT let list-tile text wrap to a second line or overflow.** Expense
  name/merchant and category text must be `maxLines: 1` + ellipsis — first
  pass let them wrap, which made row heights inconsistent when text was long.
- **DO NOT use `Spacer()` inside a fixed-size detail row** (e.g.
  `ExpenseDetailCard._DetailRow`) — `Spacer` is `Expanded` and consumes all
  remaining width, leaving the value text totally unconstrained and prone to
  render overflow on a long name/note. Use a fixed gap + `Expanded` + right
  alignment instead.
- **DO NOT make Wrapped slides scrollable to fix overflow.** User explicitly
  rejected this after it was implemented (`WrappedBody` / `SingleChildScrollView`
  wrapper) — slides must stay fixed-height, full-bleed, no scroll indicator.
  It was built, then fully reverted in the same session. If you see any
  `SingleChildScrollView` in a wrapped_slide_*.dart file other than the
  pre-existing one in slide 9 (which uses `NeverScrollableScrollPhysics` and
  only clips, doesn't scroll), that's a regression — remove it.
- **DO NOT cap Wrapped text with a fixed `maxLines` + `TextOverflow.ellipsis`
  as the final solution.** This was the second attempt (after reverting
  scrolling) and got explicitly overridden by the user: "no need for
  truncating our text." The final approach is `WrappedAutoText` — it
  binary-searches the largest font size that fits the given `maxLines`/width,
  and ellipsis is now only a last-resort fallback if text still doesn't fit
  at the configured minimum font size. All backend-driven text in slides 2,
  4, 6, 7, 8, 9 was converted to this. Do not revert to fixed-size + ellipsis.
- **`WrappedAutoText` requires a bounded-width parent.** It measures via
  `LayoutBuilder` and no-ops (uses `maxFontSize`, can overflow) if the parent
  gives infinite width — e.g. inside a `Row` without `Expanded`/`Flexible`.
  This bit us once already on the passport slide (two `Column`s inside `Row`s
  had to be wrapped in `Expanded`). Any new usage inside a `Row` must be
  wrapped in `Expanded` or `Flexible`.
- **DO NOT edit `edit_username_sheet.dart`** — it's deleted. It looked
  functional (had a controller, a Done button) but the `Done` button just
  called `Navigator.pop(value)` and the caller only did `setState(() {})` —
  nothing was ever persisted to the backend. Replaced entirely by
  `edit_preferred_name_sheet.dart`, which calls `updateProfile()`.

## 6. Next steps

1. **Get user confirmation** on Wrapped (all 9 slides, especially slide 3's
   category truncation to top-5 and slide 4's conditional skip when there's
   no top category), the preferred-name onboarding flow, and the new
   auto-fit text sizing — none of these have been run on-device yet this
   session.
2. Ask the user directly what the untouched-by-me modified files are
   (`app_svg.dart`, `badge_widget.dart`, `gamification_preview_screen.dart`,
   plus the 3 new `assets/images/wrapped/*` files) before doing anything
   that could stage/revert them.
3. Once Wrapped + preferred name are confirmed, the remaining checklist items
   from `MEMORY.md`'s "Open threads" are backend-blocked, not client work:
   attach-proof-to-existing-expense endpoint, `POST /groups/{id}/members`,
   Clara context/persistence copy fixes. Flag these to the backend dev; do
   not attempt to build around them client-side.
4. Open question for the user: should Wrapped's auto-shrunk text have a
   visual floor lower than currently set (e.g. if a real backend headline is
   much longer than anything tested so far)? Font-size floors are in
   `wrapped_shared.dart` and per-slide call sites — worth a second pass once
   real (non-mock) long-form Wrapped copy is seen from the live API.
