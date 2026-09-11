# YourChoice — iOS app

> **Know before you go.** A real-time local discovery app that ranks nearby
> places by what you would actually experience *right now*: predicted wait,
> confidence, freshness, walking time and the things you care about.

This is the consumer iOS app described in *YourChoice A-to-Z Complete Product
Concept*. It is built with SwiftUI for iOS 17+, with no third-party
dependencies, and ships with a simulated signal feed for the Cannes pilot
market so every screen is fully interactive on day one.

## Run it

1. Open `ios/YourChoice/YourChoice.xcodeproj` in **Xcode 16 or newer**.
2. Pick an iPhone simulator (iPhone 15 Pro or newer looks best) and press Run.
3. On a device: select your team under *Signing & Capabilities* first.

The project uses Xcode's folder-synchronized groups, so any Swift file you add
under `YourChoice/` is picked up automatically. If you prefer a generated
project, `project.yml` works with [XcodeGen](https://github.com/yonaskolb/XcodeGen).

Location: the pilot market is Cannes. If the device is outside Cannes (or
location is denied), the app uses a demo origin on La Croisette so the venue
set still makes sense. Inside Cannes it uses your real position.

## What's in the app

| Screen | What it does | Brief section |
|---|---|---|
| **Onboarding** | Three-page intro, priority pick, location permission | C, U, T |
| **Now (Home)** | "Best choice right now" hero, ranked venue cards, category and priority filters, pull-to-refresh | C, D, O |
| **Human help card** | One-tap "How's the wait?" that appears only for a nearby venue with low confidence | E, H, 8 |
| **Map** | Live decision map: every pin is a current wait, colour-coded, with a quick card | C, J |
| **Venue detail** | Live prediction (wait, confidence, freshness, crowd, seats, trend), "Why this estimate" signal breakdown, best-time-to-go chart (Pro), attributes, hours, partner status | G, I, K, P, Q |
| **Report wait** | One-tap report sheet, earns points | H, W |
| **Journey** | On-the-way screen with route, live re-estimates, "better option" banner, arrival confirmation for ground truth | J |
| **Saved** | Favourites with live waits | Y |
| **Alerts** | Favourite-got-quiet, best-time and system alerts | R, Y |
| **You** | Points, reputation ring (accuracy-weighted), Pro upsell, ranking preferences, must-haves, alert toggles, leaderboard, privacy note | Q, R, U |

## Architecture

```
YourChoice/
├── App/            Entry point, root tabs, AppModel (user, prefs, favourites, alerts)
├── DesignSystem/   Tokens, typography, card treatment, shared components, haptics
├── Models/         Venue, Signal, Prediction, HistoricalPattern, User types (pure Foundation)
├── Engine/         PredictionEngine and RankingEngine (pure Foundation, testable anywhere)
├── Data/           Cannes dataset, VenueStore (live feed simulation), LocationService
└── Features/       One folder per screen
```

### The prediction engine

`PredictionEngine` implements the four-layer data strategy from the brief:

1. **Automatic signals** (`pos`, `camera`, `mobile`) and **business input** each
   carry a baseline trust and a half-life. Weight = trust × 2^(−age / half-life).
2. **Historical prediction**: a per-venue hourly curve supplies the baseline
   and fills gaps when live signals are sparse.
3. **Human fallback** (`userReport`): blended like any other signal, and
   requested only when confidence is low.

Output is a `Prediction`: wait, confidence tier (from evidence strength ×
agreement), freshness, crowd level, seating likelihood, trend, and whether the
estimate is *observed* (live evidence dominates) or *predicted*.

`RankingEngine` turns predictions into the cross-venue answer. Score = wait ×
w₁ + walk × w₂ + uncertainty penalty ± preference bonuses; the weights change
with the Fastest / Balanced / Comfort dial.

### Wiring up real data

Replace `MockVenues.cannes()` and `VenueStore.tick()` with your backend. The
store's public surface (`venues`, `submitReport`, `ranked(from:preferences:)`)
is the seam. Nothing in the UI knows where a number came from, which is the
point of the product.

## Not in this release

- Admin / moderation tools (backend scope).
- Push notifications (in-app alerts only; wire `AppAlert` to APNs).
- Venue photography (gradient artwork stands in).
- Camera-based signals (the brief explicitly keeps them out of the MVP).
