# Basescape Core Mechanics

## Base Lifecycle

- One base per province; construction gated by tech, relations, biome penalties, and organisation level caps (1 base at org lvl 1 → 10 bases at lvl 10).
- Size tiers: Small 4×4 (150 K, 30 d), Medium 5×5 (250 K, 45 d), Large 6×6 (400 K, 60 d, relation >50), Huge 7×7 (600 K, 90 d, relation >75).
- Expansion follows sequential order; facility layout preserved during upgrades; bases unusable while expanding.

## Facility Grid

- Global base grid 40×60 orthogonal tiles; facilities must connect via cardinal adjacency to remain powered.
- Footprints: 1×1 (power, small barracks/storage), 2×2 (labs, workshops, radars, hospitals, hangars), 3×3 (large hangars, prisons, turrets).
- Corridors (1×1) maintain connectivity; diagonal contact never counts.

## Facility Services

- Binary service model: facilities either provide power, research, manufacturing, housing, defense, radar, psi, or medical output at full rated value.
- Core production values: Power Plant +50 power, Lab (S) 10 man-days, Lab (L) 30; Workshop (S/L) mirror these; Hospital +2 HP/+1 sanity per week; Academy +1 XP per unit per week; Garage +50 HP craft repair per week.
- Lifecycle states: Operational, Construction, Offline (player/power), Damaged, Destroyed; power shortages automatically disable lowest-priority facilities.

## Adjacency & Upgrade Rules

- Cardinal pairs confer bonuses (max 3–4 stacks per facility): Lab+Workshop +10 % output, Workshop+Storage −10 % material use, Hospital+Barracks +1 HP/+1 sanity, Garage+Hangar +15 % craft repair, Power Plant within two tiles of Lab/Workshop +10 % efficiency, Radar+Turret +10 % targeting, Academy+Barracks +1 XP.
- Upgrades cost roughly 20–30 % of build price, take 14–30 d, and improve production 30–50 % without relocation (e.g., Lab +50 % output then +2 queues; Power Plant +50 power; Storage tiers stepping 100→400→800 capacity).

## Power Management

- Total generation summed from active power facilities; consumers sorted by priority tiers (1 command life support → 10 luxury).
- Shortfalls shut down lowest tiers automatically; reactivation requires restored surplus.
- Maintenance: Power plants draw 10 power for upkeep and incur 10 K cr monthly.

## Personnel & Recruitment

- Barracks capacity: Small 8 units, Large 20; training via Academy adds +1 XP weekly (stacking with adjacency bonuses).
- Recruitment costs scale by rank: Rank 1 Agents 5 K, veterans up to 12.5 K monthly salary.
- Specialist unlocks gated by research plus facility availability.

## Prisoner Handling

- Prison (3×3) holds 10 captives; lifetime = 30 d + (max HP ×2).
- Actions: Execute (−5 karma), Interrogate (+30 man-days, 5 K, 1 w), Experiment (−3 karma, +60 man-days, kills target), Exchange (+3 relations, +3 karma, 1 w), Convert (60 % base success, 50 K, 4 w), Release (+5 karma, +1 relations with faction).
- Maintenance 1 unit per 2 prisoners per day; 1 % daily escape chance.

## Logistics & Storage

- Storage tiers: Small 100 items, Medium 400, Large 800; capacity determines salvage retention and manufacturing buffer.
- Craft hangars: Medium holds 4 craft, Large 8; garages speed repairs, hangars provide storage only.

## Defense Posture

- Turrets contribute defense rating (Medium 50 pts, Large 150 pts) and require power; adjacency to radar boosts accuracy 10 %.
- Damaged facilities drop to 50–90 % production until repaired; destroyed facilities must be rebuilt.

## Analytics & Reporting

- Base management screen aggregates power balance, upkeep, facility states, and production queues each strategic tick.
- Monthly upkeep debits: facilities 3–50 K cr, personnel salaries, craft maintenance (100–500 cr by class).
