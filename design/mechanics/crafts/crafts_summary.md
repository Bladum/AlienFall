# Craft Fleet Overview

## Roles & Classes

- Craft families: Scouts (recon, radar, high dodge), Interceptors (air combat), Bombers (strike payloads), Transports/Assault transports (troop lift), Stealth craft (low landing noise), plus naval/off-world variants (submarines, cruisers, mobile bases).
- Each hull uses one pilot and fixed hardpoint/addon slots (2 weapons, 2 addons). Crew cabins/cargo pods expand capacity; fuel tanks, afterburners, shields, armor, radar boosters, and teleport repairs compete for slots.

## Stats & Movement

- Speed (1–4 hexes/turn) and range (5K–80K km) consume fuel automatically; weights beyond capacity are refused. Landing noise burns mission stealth budgets (heavy hulls ~200 noise vs covert cap 250).
- Durability: Small craft 100–150 HP, medium 200–300, large 350–450, capital 500+ with armor value 0–4 and optional shields regenerating +10 HP/turn at energy cost.
- Energy pool fuels weapons/abilities; addons can extend max EP (+20) or regen (+2/turn).

## Weapon & Sensor Suite

- Hardpoints accept cannons, missiles, lasers, plasma; inherent bonuses by specialization: scouts +20% dodge, interceptors +15% accuracy, bombers +30% damage, battleships -10% dodge.
- Radar power/range set detection coverage; boosters add +2 power/+500 km. Stealth rating subtracts from enemy detection; cover mechanics drive patrol viability.

## Logistics & Maintenance

- Storage: garages hold 1 craft, hangars (2×2) hold 4; lack of slots grounds craft. Repair ticks from garages (+50 HP/week) with power draw; damaged craft lose speed (-1 hex below 50% HP).
- Fuel types (petrol, fusion, elerium) pull from base inventory per move (1–5 units/hex); afterburners raise speed but increase consumption 25%.
- Crash results spawn rescue missions; pilots & passengers risk injury/death, salvage handled separately.

## Design Hooks & Tests

- Fleet management balances slot economy vs mission needs—diversify to cover stealth, range, transport, and heavy engagement roles.
- Integration points: pilot bonuses (Piloting÷5 to accuracy/dodge), bases for hangar capacity, interception combat resolution.
- Testing: weight gating, fuel math on round trips, shield-before-armor damage order, landing noise vs stealth budgets, addon stacking caps, repair throughput, crash mission generation.
