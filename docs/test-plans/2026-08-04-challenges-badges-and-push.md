# 2026-08-04 — Friday challenge, badges, push routing

Single source of truth for this batch. An earlier draft of the Friday flow (one
full-width "Start saving" button, a separate "Start a challenge" sheet, and the
prompt going quiet once you'd saved that week) was **replaced** — none of that is
the shipped behaviour and it is not tested here.

Build with `--dart-define=SHOW_GAMIFY_GALLERY=true` for steps that need the
Gamify gallery or the dev tools; use a plain build for the gating steps.

**Push tap routing** — this was completely broken before (the tap handler was
declared and called but never assigned, so *every* push in the app silently did
nothing). Highest priority, and it isn't Friday-specific.

1. Get a challenge created first (steps 6–9 below if you have none), then open
   Challenge detail → gear icon → "Send reminder push now".
2. Background the app. When the push arrives, tap it. The app should open **and**
   the Friday Savings modal should appear — even if today isn't Friday, because a
   push-triggered prompt skips the local day check.
3. Force-quit the app entirely. Send another test reminder and tap it from cold
   start. Same result: app opens, modal appears. This is the `getInitialMessage`
   path and is separate code from step 2.
4. Tap a push while the app is already in the foreground. It should not crash or
   double-show the modal.
5. Deny notification permission (or use a simulator with no push) and open the
   app on a Friday. The modal must still appear — the client-side day check is
   the fallback so a broken push doesn't kill the feature.

**Friday challenge — first run** (no challenge exists yet)

6. On a fresh account with income set up, open Home on a Friday. The Friday
   Savings modal pops on its own after the screen settles. Confirm it does **not**
   stack on top of the income setup modal for a brand-new user — income comes
   first.
7. Confirm the modal has **two buttons side by side**, not one full-width button.
   That side-by-side layout is the design; a single button means a regression.
8. Tap the primary button. Because there's no challenge yet there's no "usual
   amount", so the "Enter amount" sheet opens first. Enter an amount, tap "Done".
   The challenge is created with that amount as the weekly target, then the
   "Attach your proof" sheet opens immediately — starting the challenge and
   logging the first savings are **one flow**, you should not have to go find the
   challenge afterwards to log against it.
9. In "Attach your proof": the amount is pre-filled with what you just entered,
   add an optional note, attach a receipt, tap "Log savings". The sheet closes and
   the success modal appears.
10. Check the success modal text. It must read the **real amount you entered** and
    the **current month name** — e.g. "You've saved ₦10,000 and kept your Friday
    streak alive. 2 more Fridays to close out August." Hardcoded "5k" or "April"
    is the exact bug this replaced.
11. Check the tail sentence is grammatical for the count: "1 more Friday" (singular),
    "3 more Fridays" (plural), and on the **last Friday of the month** it should
    read "That's every Friday covered for <month>." Worth setting the device date
    to the last Friday of a month to see that branch.

**Friday challenge — subsequent Fridays** (challenge already exists)

12. With a challenge already active, trigger the modal again (device date to next
    Friday, or a test push). It **must still pop.** Having saved last Friday does
    not silence it — popping every Friday is the whole point of the streak.
13. Tap the primary button this time. Because there's an existing weekly target,
    it should go **straight** to "Attach your proof" pre-filled with that amount —
    no amount sheet.
14. Tap the secondary/outline button instead. The "Enter amount" sheet opens
    pre-filled with the usual amount as a suggestion. Change it to a different
    number (e.g. last week 5,000 → this week 10,000), tap "Done", then log it.
    Amounts vary week to week; the sheet must not force last week's figure.
15. Confirm the "Enter amount" sheet's hint reads "Enter amount", not "Enter email
    address" (that was a real copy bug).
16. In "Enter amount", clear the field. "Done" must be disabled at 0 or empty.
17. Dismiss the modal without doing anything (tap outside / ✕). Then background and
    reopen the app **the same day**. It must not pop again — the once-a-week guard
    stops it repeating on every app open. Then move the device to the *next*
    Friday: it pops again.
18. Cancel out of the "Enter amount" sheet mid-flow. Nothing should be created —
    go to Challenges and confirm no stray challenge or entry was added.
19. Cancel out of "Attach your proof" **after** a challenge was created in step 8.
    The challenge should exist with no entry against it, and the next Friday prompt
    should behave as an existing-challenge one (step 13).

**Badges**

20. Settings → Challenges → open a challenge → gear → set the slider to e.g. 4
    weeks → "Simulate streak". This fires real backend badge and push logic, so
    expect an actual push as well.
21. Open the Badges screen. Badges are grouped into **month sections, current
    month at the top**, each section scrolling horizontally.
22. Confirm the current month section appears even when you've earned nothing in
    it — locked badges should read as goals for the month.
23. Earn the same badge more than once (simulate a longer streak). It should
    collapse into **one** badge tile with a `2x` / `3x` count marker. A badge earned
    only once must show **no** marker at all — not "1x".
24. Tap a badge. The detail sheet opens with the large badge, its name, its
    description, and the list of dates it was earned ("4 Aug 2026" style).
25. Tap a locked badge you haven't earned. Same sheet, but it reads "Not earned
    yet" with no date list.
26. Artwork: with `assets/images/gamification/` still empty, every badge should
    render as a tinted circle with an icon — a graceful fallback, not a broken
    image box or a crash. Colours should differ by category (savings orange,
    budget purple, no-spend blue, streak amber).
27. Kill the network and open Badges cold. You should get **skeleton shimmer**
    matching the badge layout while loading, then an error card — never a spinner
    and never blank space.

**Gamify gallery gating**

28. Build **without** `--dart-define=SHOW_GAMIFY_GALLERY=true`. Settings must have
    **no** "Gamify" row, and the challenge detail screen must have **no** gear
    icon. This is what ships to users.
29. Build **with** the flag. Both reappear. Confirm the real "Challenges" entry in
    Settings is present in **both** builds — only the design gallery and the dev
    tools are gated.

**Regression check** — I touched shared code: `NotificationService` (the tap
handler + a new `challenge` category), `ChallengeRepository` / `challengesProvider`,
and the shared `AppAttachReceiptField`.

30. Trigger any other push you can (transaction, budget, group). Tapping it must
    not crash — categories with no route wired just log and do nothing, which is
    the intended state for now.
31. Group → Record savings sheet. The receipt attach field there uses the same
    shared widget the challenge sheet does — attach a photo, remove it, save.
32. Challenges list, challenge detail, edit and delete a challenge, and record an
    entry from the challenge detail screen (not the Friday modal). All route
    through the same provider I extended.

**Also**

- Glance at every new sheet and modal in **dark mode** as well as light.
- The one I'd most expect to surface something is **step 12** — "it pops again the
  next Friday even though you already saved". That is precisely the behaviour that
  was wrong in the first cut, and it depends on the stored week label rolling over
  correctly, so it's the easiest thing to have got subtly wrong.
