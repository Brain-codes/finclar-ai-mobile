# Finclar AI — User Testing Checklist

> How to use this: go through the app top to bottom and tick each box when it works the way it's described.
> If something doesn't match what's written, doesn't respond, looks broken, or shows a confusing message — leave the box unchecked and write a note next to it.
> Some parts of the app are **not connected yet** — those are marked ⏳ "not ready, just look". For those, only check that the screens look right, not that they save anything.

---

## 1. Opening the App for the First Time

- [ ] The app opens without crashing
- [ ] You see 3 introduction pages you can swipe through
- [ ] The intro pages have pictures and text that look properly laid out (nothing cut off)
- [ ] There's a button to get started / sign up
- [ ] There's a way to go to login if you already have an account
- [ ] If you close the app and reopen it, it doesn't make you watch the intro again (after you've signed up once)

---

## 2. Creating an Account

- [ ] You can type your email and a username
- [ ] If you pick a username someone already has, the app tells you it's taken
- [ ] If you type an invalid email (like "abc"), the app points it out under the field — it doesn't let you continue
- [ ] The Terms of Service page opens and is readable
- [ ] The Privacy Policy page opens and is readable
- [ ] After signing up, you get a 6-digit code in your email inbox (check spam too — note how long it took to arrive)
- [ ] Typing the correct code moves you forward
- [ ] Typing a wrong code shows a clear error message — it doesn't freeze or crash
- [ ] "Resend code" actually sends a new email
- [ ] While the app is checking your code, you can see it's busy (a loading effect) — it doesn't just sit there
- [ ] You're asked to create a 6-digit passcode
- [ ] You're asked to confirm the passcode, and if the two don't match it tells you
- [ ] You're asked what your money goal is (save more, track spending, etc.)
- [ ] ⚠️ Picking a goal and continuing — **known issue: this currently fails behind the scenes.** Note what you see when you tap continue.
- [ ] You can skip the goal question and still get into the app
- [ ] After all that, you land on the home screen

---

## 3. Logging In and Out

- [ ] You can log in with your email and passcode
- [ ] Wrong passcode shows a clear message (not a scary technical error)
- [ ] After logging in, you land on the home screen and see your own username
- [ ] Close the app completely and reopen it — you're still logged in
- [ ] Log out from Settings — it asks you to confirm before logging you out
- [ ] After logging out, you're back at the login screen
- [ ] After logging out, pressing back doesn't sneak you back into the app

**Forgot passcode:**
- [ ] On the login screen there's a "forgot passcode" option
- [ ] It sends a code to your email
- [ ] Entering the code lets you set a new passcode
- [ ] The new passcode works for your next login
- [ ] The old passcode no longer works

---

## 4. Home Screen

- [ ] Your username appears at the top
- [ ] The first time, the app asks you to set up your income
- [ ] You can enter how much you earn
- [ ] You can pick where the money comes from (salary, business, etc.)
- [ ] You can add your own custom income source (e.g. "Side hustle") and it appears in the list
- [ ] You can pick how often you get paid (daily / weekly / monthly / one-time)
- [ ] You can pick a start date
- [ ] You can add an optional note
- [ ] After saving, your income shows on the home screen with the right amount
- [ ] The currency symbol shown matches the currency you chose at sign up (e.g. ₦ for Naira)
- [ ] You can open your income again and edit it — the change sticks after closing and reopening the app
- [ ] ⏳ Recent expenses section — just check it displays without looking broken (real data not connected yet)
- [ ] ⏳ Budget section — same, just check the look
- [ ] ⏳ Clara AI card — visible and looks right, but tapping won't do much yet

---

## 5. Expenses

> ⏳ **Heads up: expenses don't actually save yet.** The list you see is sample data. Test the look and feel of every screen, but don't expect anything to stick.

- [ ] The expenses tab opens and shows a list of expenses (sample ones)
- [ ] The summary at the top shows a total and a colored bar split by category
- [ ] Each expense row shows a name, category, amount, and date that line up nicely
- [ ] Tapping an expense opens its details
- [ ] You can open the "add expense" flow and fill in amount, category, date, and a note
- [ ] The category picker, date picker, and note sheet all open and close smoothly
- [ ] The month picker opens, shows 12 months, and highlights your selection
- [ ] The edit and delete options open their screens/confirmation pop-ups
- [ ] The delete confirmation clearly asks "are you sure" with Cancel and Delete

**Scanning a receipt:**
- [ ] You can open the receipt scanner
- [ ] You can take a photo or pick one from your gallery
- [ ] While it reads the receipt, you see a scanning animation
- [ ] With a clear receipt photo, it pulls out the shop name, items, and prices
- [ ] You can edit an item it got wrong
- [ ] You can delete an item it got wrong
- [ ] With a blurry photo or a photo of something that isn't a receipt, it tells you it couldn't read it — it doesn't crash
- [ ] ⏳ Saving the scanned expense — won't actually save yet, just note what happens

**Linking a bank:**
- [ ] ⏳ The bank connection screens open and look right (picking a bank, success screen) — actual linking isn't connected yet

---

## 6. Budget

> ⏳ **Not connected yet** — screens only.

- [ ] The budget tab opens without errors
- [ ] You can walk through creating a budget (amounts, categories) and every screen looks right
- [ ] The charts and summary cards display without anything overlapping or cut off

---

## 7. Groups

> ⏳ **Not connected yet** — screens only, with sample people.

- [ ] The groups tab opens
- [ ] You can walk through creating a group
- [ ] A group's detail page opens
- [ ] The group chat screen opens — you can type in the message box
- [ ] Adding / editing / removing a friend opens the right pop-ups
- [ ] Share and leave-group pop-ups open and close properly

---

## 8. Settings

- [ ] Settings opens and shows your name/profile at the top
- [ ] **Change passcode** works fully: it emails you a code, you enter it, set a new passcode, and the new one works on next login
- [ ] Contact us screen opens
- [ ] FAQ screen opens, questions expand and collapse
- [ ] ⏳ Edit username — screen opens, but the change won't actually save yet
- [ ] ⏳ Delete account — screens open, but it won't actually delete yet
- [ ] ⏳ My accounts (banks) — opens, but shows placeholder data
- [ ] Log out asks for confirmation and works (see section 3)

---

## 9. Subscription

> ⏳ **Not connected yet** — screens only.

- [ ] The plans screen opens and the plans are readable and well laid out
- [ ] The upgrade / cancel pop-ups open and close properly

---

## 10. Fun Stuff (Badges & Wrapped)

> ⏳ Visual only — the numbers in here are sample data.

- [ ] Badges screen opens and badges display nicely
- [ ] "Wrapped" (your money year in review) opens and you can swipe through all the slides
- [ ] Challenge pop-ups open and look right

---

## 11. General Feel (check while doing everything above)

- [ ] No screen ever shows raw technical text (things like "Exception", "null", "500", "DioError")
- [ ] Error messages are in plain English and tell you what to do
- [ ] Every button reacts when tapped — nothing feels dead
- [ ] Whenever the app is busy, you can tell (spinner on the button, blurred loading screen, or shimmering placeholders)
- [ ] Swiping from the left edge takes you back a screen (iPhone)
- [ ] Nothing is cut off at the top or bottom of the screen, including around the notch
- [ ] The keyboard never covers the box you're typing in
- [ ] Turn off Wi-Fi and mobile data, then try logging in or saving something — you get a friendly "no connection" style message, not a crash or endless spinner
- [ ] Turn your phone's dark mode on — go through the main screens and note anywhere that looks wrong (unreadable text, white boxes on dark background, etc.)
- [ ] Use the app for 10+ minutes straight — you don't suddenly get logged out or hit random errors

---

## Notes

Write anything odd you noticed here (screen, what you did, what happened):

-
-
-
