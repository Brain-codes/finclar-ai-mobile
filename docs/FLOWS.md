# Finclar AI — Flow Guide

Every user-facing flow in the app, written for someone who has never opened it before. Each flow is a numbered walkthrough: what to tap, what you should see, and what "it worked" looks like.

Terminology used throughout:
- **Sheet** — a panel that slides up from the bottom. Closed with the ✕ in its header, or by swiping down.
- **Tab bar** — the five-item bar at the bottom: Home, Expense, **+** (centre, orange), Budget, Group.
- **Clara FAB** — the round floating button at the bottom-right of every tab screen. Opens the Clara AI chat.
- **Snackbar** — the short message that slides in at the top/bottom after an action. Green-ish = success, red = failure.

---

## 1. Getting in — first launch, sign up, login

### 1.1 First launch (onboarding splash)

1. Open the app for the first time. You land on a 3-page splash carousel.
2. Swipe left through the three pages, or tap **Skip** (top right) to jump to the end.
3. On the last page the primary button reads **Create account**; on pages 1–2 it reads **Continue**.
4. Tap **Create account** → you go to Sign up.
5. Or tap **Login** in the "Have an account? Login" line at the bottom → you go to Login.

You only see the splash once. On later launches the app goes straight to a brief loading screen and then either Home (if you're still logged in) or Login.

### 1.2 Create an account

1. From splash or from Login → **Sign up**.
2. The top bar shows a back arrow and **Step 1 of 3**.
3. Fill in **Email address** ("Enter email address") and **Username** ("Enter username").
4. Tap **Continue**. If the email is already taken or invalid, a red snackbar tells you — the field itself won't turn red for backend errors.
5. Alternatively tap **Google** below the "or" divider to sign up with a social account. On iPhone/iPad an **Apple** button sits beside it; on Android only **Google** is shown.
6. If a social sign-in fails, a **Sign-in failed** sheet opens: "[Google/Apple] sign-in didn't go through", the reason, and a **Technical details** row. Tap it to expand the exact provider error, **Copy details** to put it on the clipboard, **Done** to dismiss. Dismissing changes nothing — you stay on Sign up and can retry.
7. The small print at the bottom links to **Terms of Service** and **Privacy Policy** — both open as full screens with a back arrow.
8. After **Continue** you land on **Create passcode** (Step 2 of 3). Enter a 6-digit passcode.
9. The screen immediately becomes **Confirm passcode** — enter the same 6 digits again. A mismatch clears the boxes and shows the error inline.
10. You're taken to **Verification** (Step 3 of 3) — a 6-digit code has been emailed to you.
11. Enter the code and tap **Continue**. If it doesn't arrive, wait for the "Resend in mm:ss" countdown to finish, then tap **Resend code**.
12. On success you go to the Preference screens — see 1.4.

The same **Google** / **Apple** buttons appear on Login (1.3), so a social account can be used from either screen.

### 1.3 Log in

1. Open Login. Enter your **Email address**, tap **Continue**.
2. Or, below the "or" divider, tap **Google** (and **Apple** on iPhone/iPad) to sign in with a social account — the same buttons and the same **Sign-in failed** sheet as on Sign up (1.2). This skips the passcode step entirely and drops you on Home.
3. The screen slides to the passcode phase, headed **Welcome back** with your email underneath. The back arrow returns you to the email step.
4. Enter your 6-digit passcode. There is no Continue button — it submits as soon as the sixth digit lands, with a full-screen blur loader.
5. If you're a returning user on this device, the top right shows **Not my account** — tap it to wipe the remembered email and start from the email step.
6. If biometrics are enrolled and you've logged in before, the Face ID / fingerprint prompt fires automatically. You can also tap **Use biometrics** under the passcode boxes to trigger it manually.
7. Forgot it? Tap **Forgot passcode** — see 1.5.
8. If your email was never verified, a sheet appears: **Email not verified**, "Your email address hasn't been verified yet." with **Resend verification code**. Tapping it sends a fresh code and drops you on the verification screen.
9. On success you land on Home.

### 1.4 Set your preferences (one-time, after sign up)

1. Phase 1 asks your **preferred name** — what Clara calls you. Type it and tap **Continue**, or tap **Skip for now**.
2. Phase 2 asks **What do you want help with?** — tap one or more goal cards.
3. Tap **Continue** to save, or **Skip for now** to move on without picking anything.
4. There is no back arrow here — this is the last step of onboarding. You land on Home afterwards.

### 1.5 Reset a forgotten passcode

1. Login → passcode step → **Forgot passcode**.
2. Enter your **Email address**, tap **Continue**.
3. Step 1 of 3: enter the 6-digit code emailed to you.
4. Step 2 of 3: **Create new passcode** — enter 6 digits.
5. Step 3 of 3: **Confirm passcode** — enter them again.
6. You get "Passcode changed successfully" and are returned to Login. Log in with the new passcode.

---

## 2. Home

### 2.1 Read the Home screen

Top to bottom:
1. **Header** — greeting ("Good morning/afternoon/evening"), your name, your avatar on the left and a bell icon on the right.
2. Tap the **avatar** → Settings. Tap the **bell** → Notifications.
3. **Balance card** — "Available balance". Tap the ⓘ next to "Your money at a glance" for the explanation of what the number means. Tap **Add income** / **Edit income** on the card to set or change your income.
4. **Spending card** — this month's spending plus a one-line insight. Tap it → the Spending screen (see 5.1).
5. **Budget section** — your budget summary. Tap **See breakdown** → the Budget tab.
6. **Clara card** — the latest AI insight, with a "Based on X% verified · Y% self-reported" line. Tap **Chat with Clara** → Clara chat.
7. **Recent expenses** — the last few expenses. Tap **View all** → the Expense tab. Tap any row → that expense's detail screen.
8. **Get set up** card (new accounts only) — three shortcuts: **Set your income**, **Log your first expense**, **Create a budget**. **Log your first expense** opens the same **Add** sheet as the tab bar **+** (see §3), not straight to the camera — minus the **Add/Update income** row, since that's already this card's own shortcut.

Every one of these sections shows a shimmer placeholder while its data loads — not a spinner, not blank space.

### 2.2 Set or update your income

1. Home → **Add income** on the balance card. (Also reachable from tab bar **+** → **Add income**, or Settings-free shortcut **Set your income** on the Get set up card.)
2. First time only, a sheet offers two routes: **Talk to Clara AI** ("Let our AI help you set up your income") or **Add manually** ("Enter your income details yourself").
3. Choosing **Add manually** opens the income screen headed **Add income** / "How much do you earn?". Type the amount, tap **Continue**.
4. The **Add details** sheet opens with four rows:
   - **Source** → opens **Select source**. Pick from the list, or tap **Add source** to create one ("e.g. Side hustle, Pension…") and tap **Done**.
   - **Reoccurence** → **Monthly / Weekly / Daily / One time**, then **Done**.
   - **Note** → free text, then **Done**.
   - **Date** — read-only, today's date.
5. Tap **Done**. You're returned to Home and the balance card should now show the new figure — check the number actually changed, not just that the sheet closed.
6. Editing later: the same flow, but the screen is headed **Edit income** / "Update what you earn" and the sheet is **Edit details**. The backend keeps one income record per user, so the tab bar **+** row says **Update income** once income exists.

---

## 3. Expenses

There are four ways an expense gets into Finclar: you type it, you scan a receipt, your bank syncs it, or Clara logs it. The tab bar **+** button is the entry point for the first three.

### 3.1 Add an expense manually

1. Tap **+** in the tab bar → **Type expense** ("Manually type in expense").
2. The **Add expense** sheet opens. Fill in:
   - **Description** — "What was this expense for?"
   - **Amount** — "0.00"
   - **Category** — tap the row (shows "Select category") → the **Select category** sheet. Pick one, or tap **Add category** to create your own (pick an icon, type a **Category name**, tap **Create**).
   - **Date** — tap the row → date picker.
   - Optionally attach a receipt image: "Optional. Attaching one marks this expense verified."
3. Tap **Save**.
4. The sheet closes and the expense appears in the Expense tab and in Recent expenses on Home.
5. If this is your first log of the day you may get the streak card modal — tap **Okay, let's go!** to dismiss it.

### 3.2 Scan a receipt

1. Tap **+** → **Scan receipt** ("Snap and categorize your expense"). The camera opens immediately.
2. Take the photo. Backing out of the camera without taking one returns you to where you were, no harm done.
3. A **Scanning receipt** dialog appears with a progress bar. It climbs to ~90% and holds until the scan resolves.
4. On failure you get **Scanning failed** — "We could not complete the scanning. Please try again" — with **Cancel** and **Retry**. **Retry** relaunches the camera.
5. On success you land on the receipt review screen, titled with the merchant name.
6. Review the line items. Tap any item → **Edit expense** sheet with **Name**, **Amount**, **Quantity**, **Category**. Tap **Save changes**.
7. Tap **Edit** in the top-right pill to edit the expense as a whole (description, amount, category, date). There's a "Apply this category to all items in this expense" toggle in that sheet.
8. Tap the receipt thumbnail to view the full **Payment receipt** image.
9. Tap **Save** at the bottom. You get "Expenses saved successfully" and are returned to the list.
10. To bin it instead, tap the delete icon in the top-right pill → **Delete receipt?** → **Delete**. **Cancel** backs out.

### 3.3 Browse and filter expenses

1. Open the **Expense** tab.
2. The summary card shows the month's total. Tap the month name → **Select month** sheet, a 3-column grid of the twelve months. Pick one; the list and total both update.
3. Below it, a stacked colour bar and legend break the month down by category.
4. Expenses are grouped under date headers ("Mar 4, 2026").
5. Each row shows a category dot, the description, the amount and the date.
6. Tap a row → the expense detail screen. If the row came from a scanned receipt, it opens the receipt review screen instead.
7. Empty month → "No expenses yet". Failure → "Could not load expenses" with a **Retry** button.

### 3.4 View, edit or delete a single expense

1. Expense tab (or Home → Recent expenses) → tap a row.
2. The detail card lists **Item name**, **Amount**, **Category**, **Merchant**, **Note**, **Date** and **Source**. Source shows a pill: green shield **Verified** (scanned or bank-synced) or amber pencil **Self-reported** (typed by hand).
3. If Clara has an insight for it, it appears in a note below the card.
4. Tap **Edit** in the top-right pill → the **Edit expense** sheet, same fields as 3.1, button reads **Save changes**.
5. Tap the delete icon in the same pill → **Delete expense?** — "Your expense will be cleared. The data can not be recovered". Tap **Delete** to confirm, **Cancel** to back out.
6. Deleting gives "Expense deleted" and pops you back to the list. Check the month total actually dropped, not just that the row vanished.

### 3.5 Link a bank account

1. Tap **+** → **Account integration**, or Settings → **My accounts** → **Link an account**.
2. An intro modal explains the benefits (no more manual tracking, see where money goes, smarter insights, secure and protected). Tap **Get started**.
3. **Select bank** (Step 3 of 3) — search by name in the "Search for bank name" field, then tap your bank.
4. The linking sheet runs: "Bank linking in progress". Leave it alone until it resolves.
5. On success you land on a confirmation screen — tap **Go home**.
6. On failure the sheet shows "Bank linking failed" with **Retry**.
7. If your profile hasn't finished loading you'll get "Please wait for your profile to load" — wait a beat and try again.

### 3.6 Manage linked accounts

1. Settings → **My accounts**.
2. Linked accounts are listed; with none you see "No linked accounts" / "Tap below to add one, or as many as you need."
3. Tap an account → actions sheet with **Sync transactions** and **Disconnect account**.
4. **Sync transactions** pulls the latest and confirms with "Transactions synced from [bank]".
5. **Disconnect account** removes it and confirms with "[bank] disconnected".
6. Tap **Link an account** to add another (goes to 3.5 step 3).

---

## 4. Budget

### 4.1 Create a budget

1. Open the **Budget** tab. With none ever set you see "No budget yet" and a **Create budget** button.
2. If you've budgeted before but not for the month you're viewing, the empty state instead reads "No budget for August" / "You haven't set a budget for August yet. Tap the button below or chat with Clara AI to set your budget and allocation" — and a summary of your last budget sits above it (see 4.6).
3. Tap **Create budget** — either the button in the empty state or the orange **Create budget** pill at the top right. Both go to the same screen.
4. Type the **Budget amount**, tap **Continue**.
5. You're returned to the Budget tab, switched to the month the budget was created for, with the budget card populated.

### 4.2 Allocate your budget across categories

1. Budget tab → **Allocate**.
2. If there's nothing left to allocate you get the **No allocation** sheet instead, offering **Increase budget** — that takes you to 4.4.
3. The allocation sheet shows "Amount left to allocate" at the top.
4. Tap **Category** → **Select category** sheet → pick one.
5. Enter the **Amount** ("Enter amount"). Over-allocating shows "Amount exceeds allocation balance" and blocks the button.
6. Tap **Continue**. The allocation appears in the "Allocated category" list.
7. Repeat for each category. Empty state reads "No allocations yet" / "Tap Allocate to split your budget across categories".

### 4.3 Edit or remove an allocation

1. Budget tab → tap an existing allocation row.
2. The same sheet opens in edit mode — header reads "Editing allocation", button reads **Update**.
3. Change the amount or category, tap **Update**.
4. To remove it, tap **Remove allocation** at the bottom. You get "Allocation removed" and the amount returns to your unallocated balance — check that balance actually went up.

### 4.4 See budget details / increase / delete the budget

1. Budget tab → tap the budget summary card.
2. The **Budget details** sheet lists: Budget amount, Budget allocated, Budget unallocated, Allocated spent, Allocated remaining, Start date, End date.
3. Tap the edit icon on **Budget amount** → the **Increase budget** screen. It shows your **Current budget** and asks for an **Add amount**. Tap **Continue**.
4. Tap **Delete budget** at the bottom of the details sheet → **Delete budget?** — "Your budget will be cleared. You can always add a budget". **Delete** confirms, **Cancel** backs out.

### 4.5 Change the budget month

1. Budget tab → tap the filter pill at the top right (funnel icon + the short month, e.g. **Aug**) → the **Select month** grid → pick a month. This pill is always there, including when the month has no budget.
2. You can also tap the month chip on the budget summary card itself — same **Select month** sheet.
3. The card, the allocations and the chart all switch to that month. Check the "Available budget" figure actually changed, not just the month label.
4. Picking a month with no budget shows the empty state for that month, not the previous month's figures.
5. Tap outside the sheet to dismiss without changing month.

### 4.6 Previous-month summary when the current month has no budget

1. Roll into a new month without creating a budget. The Budget tab shows a **July budget** card at the top (named for your most recent budgeted month), then the "No budget for August" empty state below it.
2. The card collapsed shows: the amount left at the end of July, the spent/total progress bar, "₦x / ₦y spent" and "n% used". Its subtitle reads "Your last budget — tap to see the breakdown".
3. Tap the card to expand. It adds Budget amount, Allocated, Unallocated, Spent, Remaining, Start date, End date, and a **Categories** list of each allocation's spent/allocated.
4. Tap it again to collapse — the subtitle reads "Tap to collapse" while open.
5. This card is read-only. To act, use **Create budget** (top right or in the empty state below).

---

## 5. Spending & insights

### 5.1 Spending screen

1. Home → tap the spending card.
2. The screen shows **Total expense** for the month, a **Category** breakdown ("See the categories you spent on"), and a **Spending Insight** section.
3. The insight reads either "Your expenses are up/down by X% from last month" or "Tracking your monthly spending" when there isn't enough history.
4. With too little history the trend chart says "Not enough data to show a trend yet".
5. No spending this month → "No spending this month yet".

### 5.2 Chat with Clara AI

1. Tap the **Clara FAB** on any tab screen, or **Chat with Clara** on the Home Clara card.
2. First visit shows suggestion chips: "Run my income and expense for April", "How did I do this month?", "Where am I overspending?". Tap one to send it.
3. Otherwise type into "Ask me about your expense" and send.
4. Empty history reads "No Insights Yet". A load failure reads "Couldn't load your chat" with **Retry**.
5. Tap the back arrow to leave — your history stays.

---

## 6. Groups & friends

### 6.1 Create a savings group

1. Open the **Group** tab → tap the **+** icon in the header, or **Create group** on the empty state ("Save with your friends").
2. Fill in **Name of group** ("Enter group name"), **Amount** ("Enter amount") and **End date** (date picker).
3. Tap **Add friends** to pick members — you appear as **You**, each added friend gets a slot.
4. Tap **Create group**. You get "Group created successfully" and land directly in the new group's detail screen.
5. On a free plan past the limit you get the **Group creation exceeded** sheet with **Upgrade to Clara +**.

### 6.2 Group detail — what's on it

1. Group tab → tap a group card.
2. The header shows the group name, a chat icon (→ 6.6) and a back arrow.
3. **Raised** is the headline figure, with **Target**, **Balance** and **Days left** underneath.
4. **Friends** section lists members; tap it (or **Friends**) to open the full members list.
5. Two actions at the bottom: **Add savings** and **Invite**.
6. Load failure → "Couldn't load this group" with **Retry**.

### 6.3 Record savings into a group

1. Group detail → **Add savings**.
2. The **Record savings** sheet asks for **Amount** ("Enter amount") and an optional **Note** ("Add a note").
3. Tap **Save**. You get "Savings recorded" — check the **Raised** figure and your own member row both moved.

### 6.4 Invite people to a group

1. Group detail → **Invite**, or the **Share** sheet.
2. The share sheet shows the invite link with a **Copy** button ("Link copied to clipboard") and share targets: **Whatsapp**, **Telegram**, **Gmail**, **Message**, **Instagram**.
3. Adding an existing friend directly confirms with "[username] invited".

### 6.5 Edit a member's share, or remove them

1. Group detail (or the Friends members list) → tap a member → **Edit details**.
2. Change **Edit amount** and tap **Save changes** — you get "Target updated".
3. Or tap **Remove user**. The **Remove [name]?** sheet appears.
4. If they still owe something you must choose how to reassign it: **Split it between everyone else** ("Each remaining member takes an equal extra share.") or **I will cover it** ("The full amount is added to your own target.").
5. If they've already paid in full, no options appear — just "They have met their share, so nothing needs to be reassigned."
6. Tap **Remove** to confirm ("Member removed"), **Cancel** to back out. Check the remaining members' targets actually changed.

This flow is reachable from two places — the group detail members strip and the Friends members screen. Both do the same thing.

### 6.6 Group chat

1. Group detail → the chat icon in the header.
2. Type into **Message** and send.
3. Tap the attach icon → **Attach media** sheet → **Take a photo** or **Choose from library**. You can add a caption ("Add a caption...") before sending.
4. Tap a received image → full view, with **Download**.
5. Tap the members row in the header → the group's Friends screen.
6. Empty chat reads "No messages yet" / "Say hi to your savings group 👋". Failure reads "Couldn't load messages" with **Retry**.

### 6.7 Leave or delete a group

1. Group detail → the overflow/action for the group.
2. **Leave group?** → **Leave** confirms ("You left the group"), **Cancel** backs out. Members only.
3. **Delete group?** → **Delete** confirms ("Group deleted"), **Cancel** backs out. Owners only.
4. Either way you're popped back to the Group tab and the group should be gone from the list.

### 6.8 Accept or decline a group invitation

1. Group tab → the **Invitations (n)** section at the top.
2. Each card reads "[name] invited you · [target] target · [n] members" with **Accept** and **Decline**.
3. **Accept** → "Joined [group]" and the group moves into **Your groups**. **Decline** → "Invite declined" and the card disappears.

### 6.9 Add a friend

1. Group tab → the friends icon in the header → **Friends** screen. Or the **Add friends** step while creating a group.
2. Tap **Add friends** → the search sheet. Type a username into **Search** ("To search friends, enter Username").
3. Empty state: "Search a friend by their username" / "They need a finclar account to show up here."
4. No match: "No one on finclar with the username "x" matches" / "Check the spelling, or invite them to join." with **Invite to finclar**.
5. Tap a result to send a request — "Request sent to [username]". Their tile then reads **Pending**; existing friends read **Friends**.
6. Past the free-plan limit you get the **Friend limit exceeded** sheet with **Upgrade to Clara +**.

### 6.10 Accept or decline a friend request

1. Friends screen → **Friend requests (n)** section.
2. **Accept** → "You and [username] are now friends"; they move into **My friends**.
3. **Decline** → "Request declined".
4. No friends yet → "No friends yet" / "Add people you split and save with." with **Invite a friend to finclar**.

### 6.11 Invite someone who isn't on Finclar

1. Friends screen → **Invite a friend to finclar**.
2. The **Invite a friend** sheet offers **WhatsApp**, **SMS**, **Email**, **More**, plus **Copy** for the raw link ("Invite link copied").
3. If the link can't be built you get "Could not build your invite link. Try again."

---

## 7. Gamification — badges, challenges, Money Passport

### 7.1 Check your badges

1. Settings → **My badges**.
2. Badges are grouped by month ("March badges"). Unearned months read "No badges earned this month yet."
3. Tap a badge → its detail sheet: what it is and either "Not earned yet", "Earned once this month" or "Earned N times this month".
4. Pull down to refresh. Failure reads "Couldn't load your badges. Pull down to try again."

### 7.2 Start a challenge

1. Settings → **Challenges**, or the challenge prompt that appears in-app.
2. Empty state reads "Put your money where your mouth is" with **Start challenge**.
3. Tap **Start challenge** → the **Start a challenge** sheet listing the three types. One you're already running reads **Already running** and can't be picked.
   - **Friday Savings** — save an amount every Friday. "Miss a Friday and the streak resets." Window: *Every Friday*.
   - **Category budget** — stay under a spend cap in one category. Window: *Anytime*.
   - **No spend weekend** — spend nothing over the weekend. Window: *This weekend only* / *Opens Friday*.
4. Pick a type → its intro modal → **Start saving** (or "I'm in, let's go" for the weekend one).
5. In the setup sheet fill in:
   - **Category** (category-budget challenges only) — tap **Select**.
   - **Weekly target** ("Enter amount").
   - **Overall goal (optional)** ("What you want to save in total"), or for spend-based types **Spend cap** ("The most you can spend") — "Go over this and the challenge is lost."
6. Tap **Start challenge** → "Challenge started".

### 7.3 Log savings against a challenge

1. Settings → **Challenges** → tap a challenge under **Ongoing**.
2. Tap **Log this week's savings** (it reads **Log another entry** once you've already logged one this week).
3. Fill in **Amount saved**, an optional **Note (optional)** ("What are you saving towards?"), and optionally **Attach proof** — "Optional. Attaching proof marks this entry evidence-backed."
4. Tap **Log savings**.
5. The entry appears under **Entries**, tagged **Evidence backed** or **Self reported**. Your **Current streak** and **Longest streak** should both update — check the numbers, not just that the row appeared.
6. Spend-based challenges log automatically: "Expenses you record count automatically."

### 7.4 Edit or cancel a challenge

1. Challenge detail → edit → the sheet reopens as **Edit challenge** with **Save changes** ("Challenge updated").
2. To stop it, cancel → **Cancel challenge?** — "Entries you already logged stay on your record." Tap **Cancel it** to confirm ("Challenge cancelled"), **Keep going** to back out.
3. Cancelled and completed challenges move into **Past challenges**.

### 7.5 Money Passport (Wrapped)

1. Settings → **Money passport**.
2. It's a swipeable story. Tap **Next** on each slide:
   1. Intro — "Your [Month] wrapped" / "See how you earned, saved and spent"
   2. **Your income vs Expense** — total income, total spent, net balance
   3. **Where your money went** — category breakdown
   4. Your biggest category
   5. **Savings rate** and **Amount saved**
   6. **Your money personality** — Goal-oriented / Consistent / Treat-friendly
   7. Clara's take
   8. "You're killing it!"
   9. The passport card itself
3. The button reads **See my passport** on the second-to-last slide and **View my passport** on the last.
4. Tap **Share passport** to share the card, then **Done**.
5. Failure reads "We couldn't build your wrapped" / "Check your connection and try again." with **Try again** and **Close**.

---

## 8. Profile & settings

### 8.1 Open Settings

Home → tap your avatar (top left of the header). Settings opens as a full screen with a circular back button.

### 8.2 Edit your username or preferred name

1. Settings → tap your profile row at the top → the **Edit details** sheet.
2. Change **Preferred name** and/or **Username** ("Your unique @handle").
3. The username is validated as you type: under 3 characters → "Username must be at least 3 characters"; anything other than letters, numbers and underscores → "Letters, numbers and underscores only"; already in use → "Username is already taken".
4. **Email** is shown but read-only.
5. Tap **Save changes** → "Details updated".

### 8.3 Change your profile avatar

1. Settings → profile row → **Edit details** → **Avatar** → **Build your own**. (Or Settings → tap the avatar directly.)
2. The **Profile avatar** screen has two tabs: **Ready-made** and **Customise**.
3. **Ready-made** offers "Recommended for you" ("Generated from your account") and "Presets" ("A ready-made set anyone can pick from"). Tap one.
4. **Customise** lets you build one: **Character**, **Skin tone**, **Hair**, **Hair colour**, **Hat**, **Hat colour**, **Eyes**, **Eyebrows**, **Glasses**, **Ears**, **Nose**, **Mouth**, **Top**, **Top colour**, **Background**.
5. Tap **Save changes** → "Avatar updated" and you're returned to Settings. Check the header avatar on Home actually changed.

### 8.4 Change your passcode

1. Settings → **Change passcode**.
2. Step 1 — **Verify it's you**: "We sent a 6-digit code to your email. Enter it below." Enter the code. Nothing arrived? Tap **Resend** in the "Didn't receive the code?" line.
3. Step 2 — **New passcode**: "Enter a passcode you'll remember".
4. Step 3 — **Confirm new passcode**: "Re-enter your new passcode to confirm".
5. The **Passcode changed** sheet appears: "Your passcode has been updated successfully. You'll need to log in again to continue." with a **Log out from all devices** option and a **Login again** button.

### 8.5 Turn on biometric login

1. Settings → **Biometric login** toggle.
2. Your device prompts: "Confirm your identity to enable biometric login".
3. Errors you may hit: "No biometrics enrolled on this device", "Biometrics locked. Use your passcode, then try again", "Could not verify biometrics".
4. Once on, the Face ID / fingerprint prompt fires automatically at the passcode step of Login.

### 8.6 Change theme / appearance

1. Settings → **Appearance** (the row shows the current mode: Light, Dark or System).
2. The **Appearance** sheet offers **Light**, **Dark** and **System default**. Pick one — it applies immediately, no confirm.

### 8.7 Change your default currency

Settings → the currency row → the **Default currency** sheet → pick one. Every amount in the app re-renders in the new symbol.

### 8.8 Notifications

1. Settings → **Notification** to manage which pushes you get.
2. To read them: Home → the bell icon. The bell carries a dot while anything is
   unread. Notifications are grouped into **Today** and **Earlier**.
3. Each unread row has a **Mark as read** link on its bottom-left. Tap it and the
   row's orange dot goes and the link disappears — check the dot actually
   clears, not just that the row looks dimmer. Read rows show no link.
4. Rows also carry a right-hand action that opens the screen the notification is
   about. The label depends on the type:

   | Notification | Action | Goes to |
   |---|---|---|
   | New friend request | **View request** | Friends |
   | Group invite / Group activity | **View group** | Group tab |
   | Approaching your budget limit | **View budget** | Budget tab |
   | Bank sync complete | **View transactions** | Expense tab |
   | Subscription activated | **View plan** | Subscription |

   Tapping the action marks the row read on the way out, so coming back the dot
   is already gone. An unrecognised notification type shows no action.
5. Tapping anywhere else on the row just marks it read.
6. Tap the **Mark all read** pill in the header to clear every unread at once.
   The pill only appears while at least one is unread.
7. Pull down to refresh. Scroll to the bottom to load older notifications — a
   shimmer row shows while the next page loads.
8. Empty → the empty-state illustration and copy. Failure → "Something went
   wrong" with **Retry**. A failed *load-more* leaves the rows already on screen
   untouched rather than emptying the list.

### 8.9 Take the app tour again

Settings → **Start app tour**. You're dropped on Home and the coachmarks walk you through the Expense tab, the **+** button, the Budget tab and the Clara FAB.

### 8.10 Get help

1. Settings → **Contact us** → "Need help?" / "Our team is always available to assist you". Four routes:
   - **Chat with Clara** — "Get instant help from our AI assistant"
   - **Email** — "We'll respond within 24 hours"
   - **Whatsapp** — "Get help from our team on Whatsapp"
   - **Message** — "We'll respond within 24 hours"
2. **Message** opens a form: **Subject** ("Enter subject"), **Note** ("Enter your message"), and **Add image**. Tap **Submit** → "Message sent successfully".
3. Settings → **FAQ's** for the common questions. The bottom links "Got more questions? **Contact us**".
4. Settings → **Rate Finclar AI** opens the store review prompt.

### 8.11 Log out

1. Settings → **Log out** → the **Log out** sheet: "Are you sure you want to log out?"
2. Optionally tick **Log out from all devices**.
3. Tap **Log out** to confirm, **Cancel** to back out. You land on Login.

### 8.12 Delete your account

1. Settings → **Delete account** → the **Delete my account** screen, headed "Before you go".
2. It points you at **support@finclar.com** and **WhatsApp** first, in case the problem is fixable.
3. Tap **Delete my account** → the **Delete account?** confirmation sheet → **Delete**. **Cancel** backs out.
4. Confirming wipes the session and returns you to Login.

---

## 9. Subscription (Clara +)

### 9.1 Subscribe

1. Settings → **Subscription** (the row badge reads **Free** or **Clara +**). Also reachable from any "Upgrade to Clara +" sheet you hit at a plan limit.
2. The screen is headed **Go Unlimited** and lists what you get.
3. Pick monthly or yearly — the yearly card shows a "Save X%" tag.
4. The button reads **Start N-Days Free Trial** if a trial is available, otherwise **Subscribe**, with the "Then [price]" line underneath.
5. Complete the payment. You get "You are now on Clara +" and the sheet closes.
6. Load failure → "We couldn't load the plans" with **Try again**.

### 9.2 Cancel or resume your subscription

1. Settings → **Subscription** (while subscribed) → the **Subscription** sheet.
2. It shows **Clara + monthly** / **Clara + yearly**, the period, and either "Your free trial is active through", "Your Clara + subscription is active through" or "Your Clara + subscription ends on".
3. Tap **Cancel subscription** → the confirmation sheet ("Your subscription will end on [date]", "Clara will still be here if you changed your mind.") → **Confirm cancellation** → "Subscription cancelled successfully".
4. If already cancelled, the button reads **Resume subscription** → "Your subscription has been resumed".

---

## 10. iOS home screen widget

iPhone only. Nothing to turn on in the app — the widget reads whatever your
Home screen last showed.

### 10.1 Add the widget

1. Long-press an empty area of your iPhone Home screen until the icons wiggle.
2. Tap **Edit** → **Add Widget** (top-left on iOS 18+; the **+** on earlier versions).
3. Search **Finclar** → pick **Monthly spending**.
4. Swipe between the sizes:
   - **Small** — "Spent · [month]", the amount, a progress bar, and "[amount] left".
   - **Medium** — the same plus **Top category** and an **Add expense** button.
   - **Lock Screen (circular)** — a ring showing the percentage of income spent.
5. Tap **Add Widget** → **Done**.

### 10.2 What it shows

- The numbers match the **Spent this month** figure on Home (2.1).
- The bar fills as you spend against your monthly income. Once you go over, the
  bar turns red and the caption becomes "Over budget by [amount]".
- If you have no income set, the bar and caption are hidden — only the spent
  amount shows.
- Before you have ever opened the app while signed in, the widget reads
  "Open the app to see this month's spending here."

### 10.3 Tapping it

1. Tap anywhere on the widget → the app opens on **Spending** (5.1).
2. On the medium widget, tap **Add expense** → the app opens straight on the
   **Add expense** screen (3.2).
3. If you are signed out, a tap just opens the app on the login screen — it does
   not jump to either screen.

### 10.4 When it refreshes

The widget updates whenever the Home screen loads or you pull-to-refresh it, and
iOS re-reads it about once an hour on its own. It does **not** update the instant
you add an expense from another screen — pull down on Home to push the new total.
After logging out the widget resets to its empty state.

To check it is really live: note the amount on the widget, add an expense, pull
down on Home, then background the app — the widget total should have gone up by
that amount, not just changed month label.

---

## 11. Plan limits you can hit

| Limit | What you see | Way out |
|---|---|---|
| Too many groups | **Group creation exceeded** sheet | **Upgrade to Clara +** |
| Too many friends | **Friend limit exceeded** sheet | **Upgrade to Clara +** |
| Any other quota | **Limit exceeded** sheet | **Upgrade to Clara +** |

All three drop you on the Subscription screen (9.1).

---

## 12. Error and empty states you'll run into

| Where | Copy | What to do |
|---|---|---|
| Expense list | "Could not load expenses" | **Retry** |
| Expense list, empty | "No expenses yet" | Add one via **+** |
| Budget, never budgeted | "No budget yet" | **Create budget** |
| Budget, no budget for this month | "No budget for &lt;Month&gt;" | **Create budget** (top right or in the card) |
| Budget allocations, empty | "No allocations yet" | **Allocate** |
| Budget load failure | "Couldn't load your budget" | **Retry** |
| Groups, empty | "You haven't joined any groups yet." | **Create group** |
| Groups load failure | "Couldn't load your groups" | **Retry** |
| Group chat, empty | "No messages yet" | Say something |
| Friends, empty | "No friends yet" | **Invite a friend to finclar** |
| Clara chat, empty | "No Insights Yet" | Ask something |
| Clara chat failure | "Couldn't load your chat" | **Retry** |
| Challenges failure | "Couldn't load your challenges" | **Retry** |
| Badges failure | "Couldn't load your badges. Pull down to try again." | Pull to refresh |
| Notifications failure | "Something went wrong" | **Retry** |
| Wrapped failure | "We couldn't build your wrapped" | **Try again** |
| Categories failure | "Failed to load categories. Tap to retry." | Tap the message |
| Banks failure | "Failed to load banks" | Back out and retry |
| Accounts failure | "Failed to load accounts" | Back out and retry |

Everywhere data is being fetched you should see a shimmer skeleton in the shape of the content, never a bare spinner and never blank space. If you see a blank gap while something loads, that's a bug.

---

## 13. Navigation rules that apply everywhere

- **Back arrow / swipe from the left edge** works on every screen pushed on top of a tab — expense detail, settings, group detail, challenges, and so on.
- **You cannot swipe back** out of Home into Login, or out of Login into the splash. Those transitions deliberately clear the stack.
- **Sheets** close with the ✕ in the header or a swipe down. Closing a sheet never saves — you must tap the button.
- **Destructive actions always confirm.** Delete expense, delete receipt, delete budget, delete group, leave group, remove member, cancel challenge, cancel subscription and delete account all show a sheet with an explicit **Cancel** first.
