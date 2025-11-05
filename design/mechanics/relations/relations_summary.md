# Diplomatic Relations Summary

## Unified Scale

- Every relationship (country, supplier, faction) shares a -100 to +100 track with eight labeled tiers; threshold effects govern funding, trade, aggression, and UI cues.
- Momentum dampens extremes: change multiplier shrinks as |relation| grows, so flipping allies to enemies (or vice versa) demands sustained effort.
- Soft decay subtracts 1 point every three months of inactivity, encouraging regular diplomatic engagement.

## Change Sources

- Positive drivers include mission success, UFO interceptions, intel sharing, trade deals, and alliances; values typically +2 to +25 before momentum modifiers.
- Negative drivers range from mission failure and collateral losses to espionage exposure, treaty violations, and outright war, costing -3 to -60.
- Fame, panic, trade volume, karma alignment, and war state layer additional modifiers per entity type.

## Entity-Specific Effects

- Countries: relations map directly to funding multipliers (+50% at Allied, -50% at Hostile) and determine access to research, bases, and missions; fame boosts gains while panic suppresses them.
- Suppliers: relations shift prices (0.5x to 1.25x), stock levels (50%-150%), and delivery speed; rival purchases and unpaid invoices erode trust.
- Factions: relations control attack frequency (from -50% to +100%), unlock truces or joint ops, and react strongly to karma alignment mismatches.

## Events & Thresholds

- Crossing major thresholds fires scripted events (e.g., Diplomatic Breakdown at -50) that pose choices with lasting consequences, including permanent caps for betrayals.
- Random crises (economic shock, infiltration, coups) inject monthly relation swings and often trigger missions to stabilize standings.
- Betrayal actions (selling tech, breaking alliances) impose permanent caps (-50 to -100) to enforce narrative weight.

## UX & Testing

- UI presents colored bars, trend arrows, six-month graphs, and event logs; projections estimate next-month relation assuming trends persist.
- Testing focus: change formulas with momentum, threshold transitions, modifier stacking (fame, panic, trade, karma), betrayal caps, and difficulty multipliers (Easy forgiving, Impossible punitive).
