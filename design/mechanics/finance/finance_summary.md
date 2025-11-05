# Finance & Budget Summary

## Income Streams

- Monthly subsidies combine funding level (0-10) with relation multipliers (0.5x-2.0x) and threat pressure (1.0x-1.5x), keeping base payouts in the 10K-125K band before satellite, policy, or diplomatic bonuses.
- Mission rewards contribute 5-60K based on difficulty; salvage auctions and manufacturing exports swing 50-70% margins versus shop pricing and react immediately to market shocks.
- Supplemental inflows include supplier agreements, faction tributes, research licensing, and reserve interest (+2% when cash >500K), with conditional aid packages adding short-term liquidity at the cost of favors or 10-20% interest.

## Expense Structure

- Operational burn: personnel salaries 35-45%, facility upkeep 30-40%, craft logistics 10-15%, and research/manufacturing queues consume the remainder with difficulty modifiers (-20% Easy, +15% Hard, +30% Impossible).
- Strategic drains cover diplomacy, fame upkeep, black market premiums, and conditional funding penalties; corruption tax applies per excess base and inflation tax fires when credits exceed 20× monthly income.
- Power shortages still double facility costs until resolved, while outstanding loans accrue 5% monthly interest and morale penalties escalate below 50K reserves (attrition risk) or prolonged cash positions under -500K.

## Budget Cadence & Controls

- Monthly cadence: Week 1 aggregates revenue (+10% pacing), Weeks 2-3 settle operating costs (personnel, facilities, craft), Week 4 issues financial statements for course corrections.
- Strategic reroll (10K) refreshes funding offers once per month, while committee approvals gate >200K purchases and check loyalty drift.
- Conditional funding requests exchange short-term cash for mission promises; failure damages relations, funding tiers, and can trigger governance audits (-20 relation per violation).
- Financial suite auto-projects cash flow three months ahead, warning when reserves drop below one month (yellow) or one week (red) of expenses; monthly statements enumerate revenue/expense mixes plus corruption/inflation tax hits.
- Loan system allows 100K chunks up to a 500K ceiling at 5% monthly interest; exceeding annual income in debt trims funding 10% per month and drains relations by -1 globally.

## Score Coupling & Crisis Response

- Provincial score tracking aggregates monthly; every ±20 score shifts relations by ±1, feeding directly into funding multipliers and country escalation logic.
- Crisis ladder: Deficit phase leans on supplier credit (-1 relation), Debt phase layers interest and relation bleed, Withdrawal cuts country funding by 50%, and Bankruptcy fires when debt >500K or cash <-50K (liquidating 50% inventory, 25% personnel, -20 relations).
- Automated alerts flag Low (<300K) and Critical (<100K) reserves, escalating to bankruptcy risk when cash <0 or deficits linger past Month 6—campaign loss occurs after three months below -500K without recovery.
- Recovery levers: stack high-margin missions, liquidate salvage, pause research/manufacturing queues, consolidate bases to dodge corruption tax, and renegotiate conditional funding before trust collapses.

## QA Focus

- Validate funding calculations (country level tiers, relation/threat multipliers), mission payout brackets, and inflation/corruption tax triggers.
- Exercise loan workflows (interest accrual, repayment caps, funding penalty thresholds) and cash-flow forecasting warnings across reserve bands.
- Regression on crisis escalations: ensure each stage (deficit, debt, withdrawal, bankruptcy) applies penalties once, honors liquidation rules, and respects morale impacts below 50K cash.
