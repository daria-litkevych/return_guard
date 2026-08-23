# ReturnGuard (iOS)

A native SwiftUI app built from the ReturnGuard design: Home / Purchases /
Warranties / Settings tabs, purchase detail, an add-purchase flow with real
receipt scanning, scheduled return-deadline reminders, and store logos next
to each purchase.

## What's implemented

- **Free plan limit + paywall, backed by real StoreKit 2** — the free plan
  tracks up to `AppModel.freePurchaseLimit` (3) *active* (not-yet-returned)
  purchases; returning one frees up a slot. Tapping "Add purchase" past
  that limit shows `PaywallView` (from the design's "Paywall" turn —
  feature list, Yearly/Monthly/Lifetime plans, "Best value" on Yearly)
  instead of the add-purchase sheet.

  `StoreManager.swift` is real `StoreKit 2` — `Product.products(for:)`,
  `product.purchase()`, listening to `Transaction.updates`, computing
  `isPremium` from `Transaction.currentEntitlements` — backed by
  `ReturnGuard.storekit`, a local StoreKit Testing configuration (3
  products: yearly/monthly subscriptions in one group, a lifetime
  non-consumable) wired into the checked-in Xcode scheme
  (`ReturnGuard.xcodeproj/xcshareddata/xcschemes/ReturnGuard.xcscheme`),
  so opening this in Xcode and pressing **Run** gets local StoreKit
  Testing for free — no setup, no App Store Connect account, no real
  money, real purchase UI (Apple's own sandbox sheet) end to end.

  An earlier version tried to bootstrap that same `.storekit` file from
  app code via `SKTestSession(configurationFileNamed:)`, specifically so
  it would work under this environment's `simctl launch` (which can't use
  Xcode's Run action). That's a real, documented API — but it turned out
  to hard-crash (`SIGABRT` inside `-[SKTestSession bundleID]`) unless
  launched from an actual XCTest hosting context, confirmed by reading
  the crash log this environment produced. It's a testing-target tool,
  not a general application-code one, regardless of what some examples
  imply. Removed in favor of the scheme-based route above, which is what
  Apple actually documents. Net effect: in this environment,
  `Product.products(for:)` has no StoreKit Configuration to resolve
  against and no real App Store Connect products exist under these IDs
  either, so it correctly returns empty rather than crashing or faking
  data — verified in Simulator: the paywall renders (with fallback
  hardcoded prices, since no real `Product` data loaded), and the
  purchase button is correctly *disabled* rather than silently no-oping
  or pretending to succeed. The full purchase flow — real prices, Apple's
  purchase sheet, entitlements actually unlocking premium — only runs
  where the environment can support it: **Xcode's Run button**, which
  this one doesn't have.
- Settings: Subscription row reflects real `isPremium`/`activePlan`
  state, and "Restore purchases" calls the real `AppStore.sync()` +
  entitlement refresh.
- **Onboarding** — the three intro slides from the design ("Never miss a
  return deadline again" → "Snap your receipt" → "We'll remind you before
  it's too late" / "Get started"), shown once on first launch and gated by
  a persisted flag. No account, sign-up, or sign-in anywhere — this is
  deliberate, matching the "No account needed" line on the last slide
  (echoed again in Settings and the add-purchase sheet). If you want real
  account creation instead, that's a different, larger feature — it would
  need a backend decision and contradicts the "no account needed" branding
  throughout the current app, so it wasn't assumed.
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
- **Store logos** — `StoreIcon` (`StoreIcon.swift`) shows the actual
  retailer's icon next to each purchase in Home/Purchases/Warranties and
  live in the add-purchase form as you type a recognized store name.
  Logos are **live-fetched from Google's public favicon service**, never
  bundled into the app — the standard lower-risk pattern for showing a
  third party's mark (same as Mint/YNAB and most finance apps): it's for
  merchant identification, not endorsement, and nothing gets redistributed
  in the app binary the way a bundled logo asset would be. `StoreDirectory`
  is a curated name→domain map (~25 common retailers); anything not in it
  — or any fetch failure — falls back to a colored initial-letter
  monogram, so the UI never shows a broken-image glyph. **Privacy note**:
  this does mean the app calls out to Google with the store name to fetch
  its icon, which is a small dent in the "no financial access, receipts
  stay private" promise in Settings — worth knowing if that matters to you.
  (Clearbit's `logo.clearbit.com`, the other well-known free logo option,
  no longer resolves at all as of this writing — verified dead, not used.)
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

- Account/help/about rows in Settings are still inert (Subscription and
  Restore purchases are real now, see above).
- No backend or cross-device sync — SwiftData is local to the device.
- No batching of same-day reminders across multiple purchases (the
  design's "reminders for the same day are batched into one" — each
  purchase schedules its own two notifications independently).
- `StoreDirectory`'s domain map is a fixed list — an unmapped store (or
  a typo) always gets the monogram, never a guessed domain (deliberate:
  guessing could fetch and display a stranger's unrelated site icon).

## Verified

Built and run for real in the iOS Simulator (iPhone 17) — full Xcode is
installed, not just the Command Line Tools:

- Clean build, no errors, across every feature above.
- Home, purchase detail (mark-as-returned persists correctly), Purchases
  search/filters, Warranties, the Add Purchase sheet, and the
  manual-entry form all behave as designed.
- Store logos confirmed actually loading over the network for Amazon,
  Zalando, IKEA, Uniqlo, Philips Hue, and Coolblue — real icons, not
  placeholders. Quality varies by site (whatever favicon each one
  actually has), which is an inherent limit of using a free favicon
  service rather than curated brand assets.
- Fixed a real bug this way: sample data was seeding more than once
  across relaunches (tripled purchases), traced to gating seeding on an
  in-memory check instead of a persisted flag — see
  `AppModel.seedIfNeeded()`.
- Confirmed a real crash this way, not just inferred it: `SKTestSession
  (configurationFileNamed:)` called from plain app code hard-crashes
  (`SIGABRT`) outside an XCTest hosting context — this environment
  produced an actual crash log pinpointing it to
  `-[SKTestSession bundleID]`. That's what settled StoreManager's design
  on the scheme-based StoreKit Configuration instead (see "What's
  implemented" above) rather than trusting an untested assumption either
  way.
- Onboarding originally used `TabView(selection:)` with `.page` style.
  While testing, swipe-driven paging worked but tapping "Continue" appeared
  not to (a pattern that matches a real, commonly-reported SwiftUI
  TabView/.page quirk) — but the repro turned out inconclusive: after
  switching to a plain `@State`-driven `ZStack` instead (simpler either
  way, so kept), the *same* tap coordinates still missed the button until
  recalibrated, meaning the original failure may just as well have been
  bad tap coordinates on my end rather than a real TabView bug. Flagging
  the uncertainty rather than the more confident story, since I couldn't
  actually isolate the variable. All three slides and the transition into
  the main app are verified working now either way.

**Not verifiable in this environment** (no Xcode GUI, no camera hardware,
and this environment's simulator auto-resolves permission prompts without
showing them interactively):
- The actual VisionKit camera capture + Vision OCR pipeline — code review
  and cross-checking against Apple's documented API shapes is as far as
  this environment could verify.
- The real "Allow Notifications" system prompt and a genuinely granted
  authorization — the toggle's request/revert-on-denial logic was
  exercised, but every request in this environment resolved instantly
  without a visible dialog (denied), so a scheduled notification actually
  arriving has not been observed end-to-end.
- The real purchase flow end to end (Apple's purchase confirmation sheet,
  a successful test purchase, `isPremium` actually flipping true from a
  real `Transaction`) — needs Xcode's Run action for the scheme's
  StoreKit Configuration to activate, which this environment doesn't
  have. What *is* verified here: the paywall renders correctly, and with
  no StoreKit Configuration active (as in this environment) the purchase
  button correctly disables itself rather than crashing or faking a sale.

All three are worth a real first-run check on your physical iPhone (or
just Xcode's Simulator, run the normal way, for the StoreKit one).

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
   way. Store logos need network access — they'll silently fall back to
   monograms if you're offline.
7. Hitting the free-plan limit and tapping a plan on the paywall gets you
   Apple's real (local, test-only) purchase sheet — the checked-in scheme
   already points Xcode at `ReturnGuard.storekit`, so this works with no
   setup. StoreKit Testing only activates through Xcode's own Run button
   (⌘R) — a plain reinstall from Finder/TestFlight-style sideloading
   won't have it wired up.

A free-account build expires after 7 days — reopen Xcode and hit Run again
to reinstall it.

## Notes / simplifications

- Icons elsewhere in the UI (nav bar, buttons) are SF Symbols rather than
  the hand-drawn icons in the original mockups.
- OCR field extraction is heuristic (largest currency-shaped number on
  the receipt = price, first date-like text = purchase date, first
  text-heavy line = store name) — good enough to save typing on a clean
  receipt, not a guarantee. There's no line-item/product-name extraction,
  so "Product" is always left for you to type.
- "Default reminder timing" in Settings is informational (7 days before),
  matching the design — the 7-day/1-day rule isn't user-configurable yet.
