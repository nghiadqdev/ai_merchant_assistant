# Architecture — AI Merchant Assistant

## 1. Principles

1. **Offline-first**: the local database is the source of truth. Every write is
   synchronous from the user's perspective; cloud sync is a side effect.
2. **Feature-first + clean boundaries**: `features/*` owns UI/domain, `data/*`
   owns persistence/network, `core/*` owns cross-cutting utilities.
3. **Progressive disclosure**: the dashboard shows outcomes and alerts; sliders
   expose only the inputs that matter; advanced packaging cost is collapsed.
4. **Reactive math**: no manual "calculate" button. Riverpod recomputes the
   derived result on every slider change.

## 2. Layers

```text
┌─────────────────────────────────────────────────────────────┐
│ Presentation                                                │
│  Onboarding · Dashboard · Simulator · Quick Expense · Shell │
│  Riverpod providers/notifiers                               │
└──────────────────────────┬──────────────────────────────────┘
                           │ reads/writes
┌──────────────────────────▼──────────────────────────────────┐
│ Domain                                                      │
│  FinancialCalculator · SimulationState · DashboardRepository│
└──────────────────────────┬──────────────────────────────────┘
                           │ repository calls
┌──────────────────────────▼──────────────────────────────────┐
│ Data                                                        │
│  Repositories · LocalStore (Hive CE) · SyncService/Supabase │
│  Models (toMap/fromMap)                                     │
└─────────────────────────────────────────────────────────────┘
```

## 3. Data models

| Model | Storage | Fields |
| --- | --- | --- |
| `SystemBenchmark` | Hive + Supabase | `id`, `category_name`, `default_platform_fee`, `default_ads_cost`, `dynamic_risk_type`, `default_risk_rate` |
| `UserBusinessProfile` | Hive + Supabase | `id`, `user_id`, `selected_category_id`, `initial_capital` |
| `ProductSimulation` | Hive + Supabase | `id`, `name`, `cogs`, `selling_price`, `custom_ads_rate`, `custom_platform_fee`, `custom_risk_rate`, `packaging_fee`* |
| `DailyExpense` | Hive + Supabase | `id`, `date`, `type`, `amount`, `note` |
| `DailySale`* | Hive + Supabase | `id`, `date`, `revenue`, `units` |

\* Extensions required by the PRD’s own formula/dashboard but missing from its
schema: fixed packaging fee per unit, and revenue for the 7-day chart. Revenue
is recorded through the dashboard’s **QuickSaleSheet** (date, revenue, units).

Maps use snake_case keys so the same `toMap()` can be sent to Supabase.
`DailyExpense.type` is an enum (`ads`, `shipping`, `returns`, `surcharge`).

## 4. Hive CE boxes

| Box | Key | Value |
| --- | --- | --- |
| `user_business_profile` | `'current'` | profile map |
| `system_benchmarks` | benchmark id | benchmark map |
| `products_simulations` | product id | product map |
| `daily_expenses` | expense id | expense map |
| `daily_sales` | sale id | sale map |

`HiveLocalStore.getBenchmarks()` restores the curated onboarding order because
Hive does not guarantee insertion order.

`LocalStore` is an interface. Replacing Hive with Isar means implementing that
interface; no widget/provider changes are required.

## 5. Realtime simulator state

```text
selectedBenchmarkProvider ─┐
profileProvider ───────────┼─► SimulatorNotifier.build()
                           │      └─► SimulationState (immutable)
slider callbacks ──────────┘             │
                                         ▼
                              simulatorResultProvider
                                         │
                                         ▼
                              FinancialCalculator.calculate
                                         │
                     ┌───────────────────┼────────────────────┐
                     ▼                   ▼                    ▼
                profit card          margin card        break-even card
```

Clamping rules:

- `sellingPrice ∈ [cogs, cogs × 5]`
- changing `cogs` re-clamps `sellingPrice`
- Ads/platform/risk `∈ [0, 0.30]`
- packaging fee `≥ 0`
- `grossProfit ≤ 0` → `breakEvenUnits = null` → UI shows **“Lỗ vốn”**

## 6. Dashboard aggregation

`DashboardRepository.lastSevenDays()`:

1. Builds 7 date buckets ending today.
2. Sums `DailySale.revenue` per bucket.
3. Sums `DailyExpense.amount` per bucket.
4. Returns `DashboardData(points, totalRevenue, totalExpense)`.

`dashboardDataProvider` watches `expensesProvider` and `salesProvider`, so a
quick-expense write immediately rebuilds the chart. Demo rows are seeded only in
debug builds when the boxes are empty.

## 7. Sync semantics

```text
write → LocalStore (await) → UI updates → SyncService.syncX (unawaited)
                                          ├─ no Supabase config → no-op
                                          ├─ no session → anonymous sign-in
                                          └─ upsert(table, onConflict: id)
```

- `bootstrap()` on app start/resume: anonymous session → pull
  `system_benchmarks` → upsert all local rows.
- Sync failures never block or roll back local writes.
- Supabase RLS expects `auth.uid() = user_id`; `SyncService` overwrites the local
  `user_id` with the authenticated user id.
- WorkManager is the recommended next step for true background execution; the
  `SyncService` API is already isolated for that.

## 8. UI decisions

- **No tables**: cards, chips, sliders, and a bar chart.
- **Color semantics**: red = loss / margin < 15%; amber = 15–25%; green ≥ 25%.
- **Center FAB**: quick expense is the primary daily action, docked in the
  bottom app bar with a notch.
- **Revenue action**: a chart icon in the dashboard header opens a bottom sheet
  for daily revenue/units, keeping the main FAB focused on expenses.
- **AI alert**: one bubble with a concrete, actionable sentence; thresholds are
  in `AppConstants`.
- **Editor/advanced inputs**: packaging fee is hidden behind an expansion tile.

## 9. Testing

- `financial_calculator_test.dart`: exact formula, loss, zero price, break-even
  ceiling, percentage clamping.
- `models_test.dart`: map round-trips for every model.
- `simulator_state_test.dart`: benchmark defaults, cogs/slider clamping via a
  `ProviderContainer`.

Run:

```bash
flutter analyze
flutter test
```
