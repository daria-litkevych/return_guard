# ReturnGuard (iOS)

A native SwiftUI app built from the ReturnGuard design: Home / Purchases /
Warranties / Settings tabs, purchase detail, an add-purchase flow with real
receipt scanning, and scheduled return-deadline reminders.

## What's implemented

- **Persistence** — purchases are stored with SwiftData and survive
  relaunch. Sample data seeds automatically exactly once per install (gated
  on a persisted flag, not just an in-memory check — see commit history for
  why that distinction mattered).
- **Real receipt scanning** — "Scan receipt" opens VisionKit's document
  camera (the same scanning UI as Notes/Files: auto edge detection,
  perspective correction), then runs on-device Vision text recognition
  (OCR) on the captured page and tries to pull out a store name, price,
  and date using a few regex/date-detector heuristics. Results land on an
  editable review screen — OCR on real-world receipts is imperfect, so
  every field can be corrected before saving, and "Enter manually" opens
  the same screen with blank fields.
- **Scheduled local notifications** — matches the design's fixed rule: one
  reminder 7 days before a purchase's return deadline, one more 1 day
  before, both at 9am local time, nothing on the day the window actually
  closes (that state only ever shows in-app). Reminders are (re)scheduled
  automatically whenever the purchase list changes — added, returned,
  deleted, all handled by the same sync path. The Settings toggle requests
  notification permission the first time it's turned on, and reverts
  itself with an alert if permission is denied.
- **Brand fonts** — Barlow and Barlow Condensed (OFL-licensed, from Google
  Fonts) are embedded and used throughout, replacing the earlier
  system-font stand-in.
- **App icon** — the shield + U-turn arrow mark (navy on lime), from the
  icon set in `design/app-icon/` (source SVG, iOS/Android exports, and
  color variants). The 1024×1024 used in `Assets.xcassets` is a flattened,
  full-bleed version (no alpha, no pre-rounded corners) — iOS applies its
  own corner mask, and an alpha channel would be rejected on App Store
  submission.
- **Settings** — "Export my data" shares a JSON file of your purchases,
  "Delete all data" clears the SwiftData store after confirmation.

## Not yet implemented

- Account/subscription/help/about rows in Settings are still inert.
- No backend or cross-device sync — SwiftData is local to the device.
- No batching of same-day reminders across multiple purchases (the
  design's "reminders for the same day are batched into one" — each
  purchase schedules its own two notifications independently; if several
  hit their 7-day or 1-day mark on the same date you'll get one
  notification per purchase, not a merged one).

## Verified

This has been built and run for real — Xcode is fully installed here now
(not just the Command Line Tools, which is what earlier notes in this
history referred to). In the iOS Simulator (iPhone 17):

- Clean build, no errors.
- Home, purchase detail (mark-as-returned persists correctly), Purchases
  search/filters, the Add Purchase sheet, and the manual-entry form all
  behave as designed.
- Fixed a real bug this way: sample data was seeding more than once across
  relaunches (tripled purchases), traced to gating seeding on an in-memory
  check instead of a persisted flag — see `AppModel.seedIfNeeded()`.

**Not verifiable in Simulator** (no camera hardware, and this environment's
simulator auto-resolves permission prompts without showing them
interactively):
- The actual VisionKit camera capture + Vision OCR pipeline — code review
  and cross-checking against Apple's documented API shapes is as far as
  this environment could verify.
- The real "Allow Notifications" system prompt and a genuinely granted
  authorization — the toggle's request/revert-on-denial logic was
  exercised, but every request in this environment resolved instantly
  without a visible dialog (denied), so a scheduled notification actually
  arriving has not been observed end-to-end.

Both are worth a real first-run check on your physical iPhone.

## Run it on your iPhone

1. Install **Xcode** from the Mac App Store (free) if you don't have it.
2. Open `ReturnGuard.xcodeproj` in Xcode.
3. Select the `ReturnGuard` target → **Signing & Capabilities** → choose
   your own name under **Team** (a free Apple ID works for local device
   installs; no paid developer account needed).
4. Plug in your iPhone, select it as the run destination in the toolbar,
   and press **Run** (⌘R).
5. On the phone: **Settings → General → VPN & Device Management** → trust
   your developer certificate the first time.
6. The first "Scan receipt" tap prompts for camera permission
   (`NSCameraUsageDescription` is set in `Info.plist`). Turning on
   Notifications in Settings prompts for notification permission the same
   way.

A free-account build expires after 7 days — reopen Xcode and hit Run again
to reinstall it.

## Notes / simplifications

- Icons are SF Symbols rather than the hand-drawn icons in the original
  mockups.
- OCR field extraction is heuristic (largest currency-shaped number on
  the receipt = price, first date-like text = purchase date, first
  text-heavy line = store name) — good enough to save typing on a clean
  receipt, not a guarantee. There's no line-item/product-name extraction,
  so "Product" is always left for you to type.
- "Default reminder timing" in Settings is informational (7 days before),
  matching the design — the 7-day/1-day rule isn't user-configurable yet.
