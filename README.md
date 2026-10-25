# NurseFlow Personal — Native iPhone App

> **Version 1.0 (SwiftUI source)** · 100% iPhone native UI · White / Minimal / Pastel · **Not a PWA**

NurseFlow Personal has been rebuilt as an **iPhone-only** app using Apple's **SwiftUI** framework. It does **not load a website** and does not depend on Safari, Cloudflare Pages, a browser, HTML/CSS/JS, or a web server.

## Requirements

- A **Mac** running Xcode with the iOS 17+ SDK (Xcode 15+; latest Xcode recommended).
- An **iPhone** running iOS 17 or later (designed for iPhone 16 Pro and smaller phones as well).
- A personal Apple ID or an Apple Developer team for device signing.

## Run on your iPhone

1. Download or clone this repository on your **Mac**.
2. Open `NurseFlowPersonal.xcodeproj` in **Xcode**.
3. Select the **NurseFlowPersonal** target → **Signing & Capabilities** → choose your Team and change Bundle Identifier if needed.
4. Connect and unlock your iPhone. Enable **Developer Mode** on the device when prompted.
5. Choose your iPhone as the run destination and press **Run (▶)**. The native app installs directly on the iPhone Home Screen; no Safari website is involved.

**This repository contains Xcode source, not a signed `.ipa`.** iOS compilation, codesigning, and installation require Xcode/macOS. We only ran Swift Package unit tests and source parsing in a Linux environment; **the app has not been compiled by Xcode or physically tested on an iPhone yet**.

## Native features

- **Home:** active or upcoming shift across midnight; seven-day schedule; work-day, night-shift, and OT dashboard.
- **Calendar:** native portrait layout; edit any day, select multiple days, copy previous week into the current week, copy previous month to the visible month.
- **Shift codes:** create D1/D2/N1/N2 or any custom code, time, duration and allowance. Soft pastel colors.
- **Overtime:** extra daily OT minutes are *separate* from scheduled shift hours; set OT rate and multiplier.
- **Reports:** breakdown of shift allowances, OT pay, total projected income; counts and rest warnings.
- **Notifications:** scheduled **local iOS notifications** for shifts, when authorized (no push server).
- **Backup:** JSON export/restore using the iOS Files app; local autosave and recovery snapshots before bulk copy/import.
- **Import:** CSV (Excel/Numbers **Export to CSV** first); import a screenshot/photo through Apple's on-device Vision OCR with explicit preview before applying. Photo extraction works best with `YYYY-MM-DD SHIFT` rows. `.xlsx` direct parsing is **not implemented**.
- **Export:** CSV and `.ics` calendar files via the native iOS share sheet.

## Data and privacy

All scheduling data stays in the device's **Application Support** directory. No accounts, tracking, web endpoints or cloud sync is used. Use **Export Backup** regularly, then save it to iCloud Drive / Files if you want an off-device backup. Reinstalling or deleting the app can remove local data.

Default shift times and pay rates are examples; configure them for your workplace. The rest-time warnings are convenience checks, **not a guarantee of compliance with hospital staffing policy**.

## Tests

The standalone business logic can be tested on Linux/macOS with Swift 6:

```sh
swift test
```

SwiftUI, PhotosPicker, Vision, local notifications and full iPhone layouts still require Xcode + iOS testing.

## Repository transition

The previous web/PWA source is retained in **Git history** before the native transition. `main` now contains only iPhone native application source, documentation, test logic, and assets.
