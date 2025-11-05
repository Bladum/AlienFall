# Basescape Management Summary

## Expansion & Layout

- One base per province with organisation level gating total count (1 at level 1 → 10 at level 10); size upgrades follow Small → Medium → Large → Huge with preserved layouts and 30–90 day downtime.
- Global grid is 40×60 orthogonal; facilities require cardinal connectivity via corridors; footprints range 1×1 utilities, 2×2 core support, 3×3 heavy structures.
- Biome modifiers inflate construction time/cost (Ocean +250%, Mountain +40%, Arctic +35%, Urban +25%, Desert +20%); tech and advisors offset via percentage reductions.

## Services & Production

- Binary service flags deliver power, research, manufacturing, medical, radar, defense, psi, and housing; outages drop facilities to 0 output until power restored.
- Baseline outputs: Power Plant +50 power (costs 10 upkeep power, 10K/month), Labs/Workshops 10/30 man-days, Hospital +2 HP/+1 sanity per week, Academy +1 XP/week, Garage +50 craft HP/week; hangars store 4/8 craft without repair bonus.
- Lifecycle states (Operational, Construction, Offline player/power, Damaged, Destroyed) govern availability; damage halves-to-90% production until paid repairs.

## Adjacency & Upgrades

- Cardinal adjacency grants stacked bonuses (caps at 3–4): Lab↔Workshop +10% throughput, Workshop↔Storage −10% materials, Hospital↔Barracks +1 HP/+1 sanity, Garage↔Hangar +15% repair, Power within two tiles → +10% efficiency, Radar↔Turret +10% accuracy, Academy↔Barracks +1 XP.
- Upgrades cost ~20–30% of build price, take 14–30 days, and raise output 30–50% (e.g., labs gain +50% man-days then +2 queues, storage steps 100→400→800, power plant adds +50 power).

## Power Priority Stack

- Generation sums active plants; consumption sorted by priority tiers (1 command/life support → 10 luxuries). Shortfalls auto-disable lowest tiers until surplus returns; reactivation is manual once margin restored.
- Plants consume 10 power to sustain themselves and draw 10K monthly maintenance; power routing requires orthogonal chains, making corridor planning critical.

## Personnel & Logistics

- Barracks capacity: Small 8, Large 20; Academy training stacks with adjacency for +2 XP/week potential. Recruitment salary ranges 5K rank-1 agents up to 12.5K veterans, with specialist unlocks tied to research + facility presence.
- Storage tiers hold 100/400/800 items; overflow halts salvage intake and manufacturing queues until cleared.
- Hangars purely store craft, garages apply repair ticks; turrets add 50/150 defense rating and need power, with radar adjacency improving targeting 10%.

## Prisoner Management

- 3×3 prison stores 10 captives, lifetime = 30 days + 2× max HP, and actions include Interrogate (+30 man-days, 5K, 1w), Experiment (+60 man-days, −3 karma), Convert (60% success, 50K, 4w), Exchange (+3 relations/karma), Release (+5 karma), Execute (−5 karma).
- Prison upkeep requires 1 staff per 2 prisoners per day, with 1% daily escape risk; maintenance failure reduces security effectiveness.

## Reporting & Economics

- Monthly ledger aggregates facility upkeep (3–50K each), salaries, craft maintenance (100–500 per hull), and power expenses; dashboards show power balance, construction timers, production queues, and adjacency benefits.
- Strategic tests should validate power priority, adjacency stacking limits, upgrade downtime handling, biome cost multipliers, and prison action outcomes.
