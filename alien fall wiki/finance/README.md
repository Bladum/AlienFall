# Finance Overview

Finance tracks the organisation’s solvency, reputation, and campaign victory conditions. This rewrite aligns the feature with Love2D implementation expectations and the broader 20×20 UI grid.

## Role in AlienFall
- Convert geoscape successes and failures into funding adjustments and diplomatic consequences.
- Regulate debt, interest, and emergency bailouts.
- Act as the arbiter of victory, defeat, and escalation thresholds.

## Player Experience Goals
- **Clarity:** Funding changes, debt interest, and monthly expenses are visible ahead of time.
- **Accountability:** Poor performance results in measurable penalties (reduced funding, panic, loss conditions).
- **Hope:** Even when struggling, players see achievable recovery paths.

## System Boundaries
- Covers international funding, debt, score tracking, monthly/quarterly reports, and win/loss rules.
- Interfaces with economy (cash flow), organization (reputation), geoscape (country satisfaction), and basescape (monthly reports).

## Core Mechanics
### Funding Model
- Each country contributes a base amount modified by satisfaction (0–200%), security status, and story events.
- Global funding is recalculated on the first of every month using deterministic formulas stored in `data/finance/funding.toml`.
- Panic spikes trigger instant funding reviews with potential emergency aid or cuts.

### Debt & Emergency Credit
- Loan offers come from three institutions with different interest rates and conditions. Debt compounds daily.
- Missed payments escalate to sanctions that cut access to suppliers and may trigger lose conditions.
- Debt seed: `finance:debt:<loanId>` for reproducible schedules.

### Score & Reputation
- Score tracks mission outcomes, civilian losses, and strategic objectives. Monthly score deltas feed funding.
- Reputation tiers unlock diplomacy options described in the organization spec.

### Reports & Alerts
- Monthly report summarises: income, expenses, debt, score, projections, and flagged risks.
- Quarterly review adds long-term trend graphs and determines if the council issues ultimatums.

### Win/Loss Conditions
- Victory: Achieve all narrative objectives or accumulate sufficient reputation + research completions.
- Defeat: Funding reaches zero, debt exceeds threshold, or time-sensitive story objectives fail.
- All win/loss checks are deterministic and logged for replays.

## Implementation Hooks
- **Data Tables:** `funding.toml`, `debt.toml`, `score.toml`, `victory.toml`.
- **Event Bus:** `finance:month_closed`, `finance:loan_taken`, `finance:loan_defaulted`, `finance:score_updated`, `finance:game_won`, `finance:game_lost`.
- **UI:** Financial dashboards sit on the 20×20 grid with charts rendered via Love2D canvases. Values use abbreviated formatting (e.g., 1.2M).
- **Save Data:** Persist outstanding loans, repayment schedules, score history, victory progress.

## Grid & Visual Standards
- Monthly report layout uses 20×20 tiles with two-column structure (metrics left, actions right).
- Icons for funding sources are 10×10 sprites scaled ×2.

## Data & Tags
- Funding tags: `council`, `faction`, `contract`, `market`, `black_market`.
- Debt tags: `short_term`, `long_term`, `emergency`.
- Score tags: `mission_success`, `civilian_loss`, `tech_breakthrough`, `panic_event`.

## Related Reading
- [Economy README](../economy/README.md)
- [Organization README](../organization/README.md)
- [Geoscape README](../geoscape/README.md)
- [Basescape README](../basescape/README.md)

## Tags
`#finance` `#funding` `#debt` `#victory` `#love2d`
