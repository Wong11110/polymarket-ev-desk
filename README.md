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
- Add Android APK build when Android SDK is available.
