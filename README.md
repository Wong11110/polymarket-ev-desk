# Polymarket EV Desk

Mobile-first Polymarket market radar and EV analysis PWA. It is designed for quick iPhone demos through Safari "Add to Home Screen" and includes live public market data, CLOB depth previews, and a local paper portfolio.

Live demo: https://ev.aldacareer.online

## What It Does

- Market radar: near-real-time popular markets from the Polymarket Gamma API proxy.
- Search, category filter, sorting, and watchlist.
- YES / NO price display, volume, liquidity, spread, end date, and liquidity score.
- EV Gap analysis with fair probability estimate, confidence, risk label, and Fractional Kelly position sizing.
- Opportunity detail sheet with manual fair probability stress test.
- Live outcome price history and CLOB order-book panels for YES and NO tokens.
- Fill preview that walks the ask depth level by level, reporting estimated average price, market impact, levels consumed, and insufficient depth.
- Local paper portfolio with virtual cash, mark-to-market PnL, and order-book-aware entry estimates.
- Optional native opportunity alerts with an explicit Android/iOS permission request; disabled by default.
- Smart money module scaffold with mock wallet flow, ready to replace with Data API, subgraph, or indexer data.
- External market link to open the original Polymarket page.
- PWA manifest for iPhone home-screen usage.

## Research References

The current design borrows the useful parts from mature Polymarket tools while keeping this app mobile and analysis-only:

- Official Polymarket docs: Gamma/market data discovery, market/outcome/token model, and CLOB price/order-book concepts.
- PolyWorld-style dashboards: watchlist, market detail, smart trades, whale trades, order book, and price chart panels.
- Polymarket bot projects: order-book streaming, spread checks, position/risk limits, and fail-safe constraints.
- Terminal dashboards such as polyrec: compact indicators, local logging, and research/backtest orientation.

## Data Model

Polymarket groups one or more markets under an event. Each market has YES/NO outcomes and each outcome maps to a CLOB token ID. This app uses Gamma event/market data for discovery and public CLOB endpoints for price history and depth. The live order book is an execution estimate, not an order placement or a fill guarantee.

Current polling mode:

```text
Flutter PWA -> /api/polymarket/events -> deploy_server.py -> gamma-api.polymarket.com/events
Flutter PWA -> /api/polymarket/prices-history -> deploy_server.py -> clob.polymarket.com/prices-history
Flutter PWA -> /api/polymarket/book -> deploy_server.py -> clob.polymarket.com/book
```

The app polls every 60 seconds. If the API or network fails, it falls back to mock markets so the product does not show a blank screen during demos.

## Safety Boundary

This app does not:

- sign wallet messages
- store Polymarket private keys
- custody funds
- place real orders
- auto-execute trades

Real execution must live behind a wallet-signing/backend boundary with signer isolation, order-book depth checks, fees/slippage checks, manual confirmation, order-state reconciliation, and kill switches. Polymarket's official flow requires EIP-712 signing and authenticated CLOB requests; private keys must never be embedded in this PWA.

Official references: [Order book](https://docs.polymarket.com/api-reference/market-data/get-order-book), [trading overview](https://docs.polymarket.com/trading/overview), and [order creation](https://docs.polymarket.com/trading/orders/create).

## Project Structure

```text
lib/
  main.dart
  l10n/app_text.dart
  models/
  pages/
    home_page.dart
    analysis_page.dart
    smart_money_page.dart
    settings_page.dart
  repositories/polymarket_repository.dart
  services/
    ai_analysis_service.dart
    notification_service.dart
    risk_service.dart
  state/app_providers.dart
  widgets/
    market_card.dart
    opportunity_card.dart
    metric_tile.dart
deploy_server.py
web/manifest.json
```

## Local Run

```powershell
cd "C:\Users\18060\Documents\New project\polymarket_ev_mvp"
$env:Path = "C:\tools\flutter\bin;" + $env:Path
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Android / iOS Mobile Build

The Flutter app uses the same Riverpod state, repository, analysis, paper-portfolio,
watchlist, settings, and navigation flow on Android and iOS. When the app returns
to the foreground it refreshes market, opportunity, and smart-money data so a
long-lived mobile session does not keep stale radar results.

Run the local quality gates before packaging:

```powershell
flutter pub get
flutter analyze
flutter test
```

Build Android on a machine with Android SDK command-line tools and accepted
licenses:

```powershell
flutter doctor -v
flutter doctor --android-licenses
flutter build apk --debug
flutter build appbundle --release
```

The debug APK is emitted under `build/app/outputs/flutter-apk/`. Release Android
builds need a real signing key and should keep signing secrets outside Git.

iOS packaging requires macOS, Xcode, CocoaPods, and an Apple development or
distribution signing identity:

```bash
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter build ios --release
```

The Windows workstation can validate Flutter code and web builds, but it cannot
produce a signed iOS IPA. The iOS project is kept in the repository so the same
source can be opened and archived on a Mac or CI runner.

Mobile data remains analysis-only. Do not put Polymarket private keys, Cloudflare
tunnel tokens, VPS credentials, or API secrets into the Flutter bundle.

### Opportunity alerts

Opportunity alerts are disabled by default. In Settings, turn on **Opportunity
alerts** and accept the operating system permission prompt. Alerts are local to
the device and only surface markets that pass the saved EV and liquidity rules.
They do not execute an order, connect a wallet, or send a trading credential.

Build web/PWA:

```powershell
flutter build web --release --no-wasm-dry-run --pwa-strategy=none
```

Serve with Polymarket API proxy:

```powershell
python deploy_server.py --host 127.0.0.1 --port 8601 --directory build/web
```

## Roadmap

- Replace 60-second polling with CLOB WebSocket book updates and stale-data indicators.
- Add saved alert rules for price, EV, and liquidity changes.
- Replace mock smart money with wallet/Data API/indexer data.
- Add backend AI research service for explainable fair probability.
- Add a server-side, wallet-signed execution handoff with pre-trade risk checks and explicit user confirmation.
- Add Android APK build when Android SDK command-line tools and licenses are available.
- Add native alert delivery behind explicit notification permissions.
- Add optional short voice-input interview coaching; continuous listening is out of scope.
