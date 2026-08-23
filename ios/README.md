# ReturnGuard (iOS)

A native SwiftUI app built from the ReturnGuard design: Home / Purchases /
Warranties / Settings tabs, purchase detail, and an add-purchase flow with
real receipt scanning.

## What's implemented

- **Persistence** — purchases are stored with SwiftData and survive
  relaunch. Sample data seeds automatically on first launch only.
- **Real receipt scanning** — "Scan receipt" opens VisionKit's document
  camera (the same scanning UI as Notes/Files: auto edge detection,
  perspective correction), then runs on-device Vision text recognition
  (OCR) on the captured page and tries to pull out a store name, price,
  and date using a few regex/date-detector heuristics. Results land on an
  editable review screen — OCR on real-world receipts is imperfect, so
  every field can be corrected before saving, and "Enter manually" opens
  the same screen with blank fields.
- **Brand fonts** — Barlow and Barlow Condensed (OFL-licensed, from Google
  Fonts) are embedded and used throughout, replacing the earlier
  system-font stand-in.
- **App icon** — the shield + U-turn arrow mark (navy on lime), from the
  icon set in `design/app-icon/` (source SVG, iOS/Android exports, and
  color variants). The 1024×1024 used in `Assets.xcassets` is a flattened,
  full-bleed version (no alpha, no pre-rounded corners) — iOS applies its
  own corner mask, and an alpha channel would be rejected on App Store
  submission.
- **Settings** — Notifications toggle persists (not yet wired to actually
  schedule reminders), "Export my data" shares a JSON file of your
  purchases, "Delete all data" clears the SwiftData store after
  confirmation.

## Not yet implemented

- **Scheduled local notifications** — the 7-day/1-day reminders shown in
  the original mockups aren't wired to `UserNotifications` yet.
- Account/subscription/help/about rows in Settings are still inert.
- No backend or cross-device sync — SwiftData is local to the device.

## Run it on your iPhone

This machine only has the Xcode **Command Line Tools** installed, not the
full Xcode app. Every file here has been typechecked (the SwiftData/
Foundation/SwiftUI code directly; the VisionKit/Vision camera-and-OCR
code by cross-checking its call shape against Apple's documented APIs,
since UIKit/VisionKit aren't available to typecheck outside a full iOS
toolchain) but it has not actually been built or run — that part is on
you:

1. Install **Xcode** from the Mac App Store (free) if you don't have it.
2. Open `ReturnGuard.xcodeproj` in Xcode.
3. Select the `ReturnGuard` target → **Signing & Capabilities** → choose
   your own name under **Team** (a free Apple ID works for local device
   installs; no paid developer account needed).
4. Plug in your iPhone, select it as the run destination in the toolbar,
   and press **Run** (⌘R).
5. On the phone: **Settings → General → VPN & Device Management** → trust
   your developer certificate the first time.
6. The first "Scan receipt" tap will prompt for camera permission
   (`NSCameraUsageDescription` is already set in `Info.plist`).

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
