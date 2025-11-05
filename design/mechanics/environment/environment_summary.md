# Environment & Terrain Summary

## Terrain Categories

- **Floor** (cost 1) carries modifiers by material: dirt becomes mud in rain, ice causes slips, metal conducts electricity; never blocks sight.
- **Walls** are impassable LOS blockers with material HP tables (wood burns, glass shatters, stone/metal resist explosions); exceptions apply for flyers/ethereals.
- **Water** ranges from shallow (2 AP) to deep (3 AP/impassable), reduces incoming accuracy, extinguishes fire, and boosts electric conduction.
- **Difficult** terrain (forest, rubble, swamp, sand) inflates AP cost, raises sight cost, and often adds cover or morale penalties.
- **Cover** objects grant 40-80% protection, are destructible, and follow material HP rules (sandbags 30 HP, wrecks 50 HP, trees 15 HP).

## Hazards & Effects

- **Smoke** layers intensity (light/medium/heavy) impacting sight (+2/+3/+4), accuracy (−10/−20/−30), and stun; sources include grenades, fires, explosions.
- **Fire** inflicts 1-2 HP/turn, spreads 30% per adjacent tile if fuel exists, and causes morale loss; rain/water suppress, desert/sandstorm worsen.
- **Gas** variants (poison, nerve, acid, stun) bypass or corrode armor, alter morale/sanity, and stay 5-12 turns; perfect for area denial.
- **Electrical** arcs deal 2-4 HP, stun 50%, chain through metal/water; **Radiation** delivers long-term HP and sanity damage, persisting post-mission.

## Weather & Lighting

- Weather types (clear, rain, heavy rain, snow, blizzard, sandstorm, fog, thunderstorm) affect sight, accuracy, movement, and hazards: rain extinguishes fire, snow creates trails and cold damage, sandstorms jam weapons.
- Day/night toggles base visibility; night magnifies weather penalties and promotes stealth missions.

## Destruction & Special Environments

- Terrain uses material HP/resistance tables (wood 10-20 HP, stone 60+, metal 30-60); destruction updates cover, LOS, and hazard propagation.
- Special biomes (alien hive, orbital, underwater, arctic) tweak gravity, atmosphere, and available hazards (acid pools, zero-G drift, pressure damage).

## Integration & QA

- Environment feeds into Battlescape actions, Geoscape weather seeds, and asset selection; hazards interact with morale, status, and LOS.
- Testing focus: terrain cost tables, hazard spread, weather modifiers, material destruction, biome-specific rules, and mission scripting that manipulates environment states.
