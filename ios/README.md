# ReturnGuard (iOS)

A native SwiftUI app built from the ReturnGuard design: Home / Purchases /
Warranties / Settings tabs, purchase detail, the "Add purchase" sheet, and a
simulated scan → confirm receipt flow. Sample data is generated relative to
today's date so the countdowns always look right when you run it.

## Run it on your iPhone

This machine only has the Xcode **Command Line Tools** installed, not the
full Xcode app — the project's Swift code has been type-checked and is
believed to compile cleanly, but it has not been built or run in a real
iOS toolchain. You'll need to do that part:

1. Install **Xcode** from the Mac App Store (free) if you don't have it.
2. Open `ReturnGuard.xcodeproj` in Xcode.
3. Select the `ReturnGuard` target → **Signing & Capabilities** → choose
   your own name under **Team** (a free Apple ID works for local device
   installs; no paid developer account needed).
4. Plug in your iPhone, select it as the run destination in the toolbar,
   and press **Run** (⌘R).
5. On the phone: **Settings → General → VPN & Device Management** → trust
   your developer certificate the first time.

A free-account build expires after 7 days — reopen Xcode and hit Run again
to reinstall it.

## Notes / simplifications

- Uses system fonts (SF Pro, rounded design for headings) as a stand-in for
  the brand's Barlow / Barlow Condensed — say the word if you want the real
  fonts embedded.
- Icons are SF Symbols rather than the hand-drawn icons in the original
  mockups.
- "Scan receipt" is simulated: it shows the camera UI for ~2 seconds, then
  transitions to a review screen with a fixed sample result (a Sony
  WH-1000XM6 purchase), matching the design prototype's own behavior.
- No backend/persistence — purchases live in memory and reset on relaunch.
