# Polymarket EV Desk

Mobile-first Polymarket market radar and EV analysis PWA. It is designed for quick iPhone demos through Safari "Add to Home Screen", while keeping trading execution disabled by default.

Live demo: https://ev.aldacareer.online

## What It Does

- Market radar: near-real-time popular markets from the Polymarket Gamma API proxy.
- Search, category filter, sorting, and watchlist.
- YES / NO price display, volume, liquidity, spread, end date, and liquidity score.
- EV Gap analysis with fair probability estimate, confidence, risk label, and Fractional Kelly position sizing.
- Opportunity detail sheet with manual fair probability stress test.
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

Polymarket groups one or more markets under an event. Each market has YES/NO outcomes and each outcome maps to a CLOB token ID. This app currently uses Gamma event/market data for mobile market discovery, and keeps CLOB/order-book execution as a future backend integration.

Current polling mode:

```text
Flutter PWA -> /api/polymarket/events -> deploy_server.py -> gamma-api.polymarket.com/events
```

The app polls every 60 seconds. If the API or network fails, it falls back to mock markets so the product does not show a blank screen during demos.

## Safety Boundary

This app does not:

- sign wallet messages
- store Polymarket private keys
- custody funds
- place real orders
- auto-execute trades

Real execution should live in a backend with signer isolation, order-book depth checks, fees/slippage checks, manual confirmation, order-state reconciliation, and kill switches.

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

Build web/PWA:

```powershell
flutter build web --release --no-wasm-dry-run --pwa-strategy=none
```

Serve with Polymarket API proxy:

```powershell
python deploy_server.py --host 127.0.0.1 --port 8601 --directory build/web
```

## Roadmap

- Add CLOB token ID parsing and order-book depth panel.
- Add price history chart and volume spike detection.
- Replace mock smart money with wallet/Data API/indexer data.
- Add local alert rules for watchlist markets.
- Add backend AI research service for explainable fair probability.
- Add Android APK build when Android SDK is available.
