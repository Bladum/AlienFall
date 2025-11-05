# Battlescape Core Mechanics

## Battlefield Structure

- Vertical axial hex grid (q,r) shared across game; distance = (|x₁−x₂|+|y₁−y₂|+|z₁−z₂|)/2 after cube conversion.
- Tactical map assembled from 15‑hex map blocks into battlefields sized 4×4 to 7×7 blocks (each block rotated/mirrored for variety).
- Tiles hold one unit plus up to five ground objects and environmental effects; walls fully block movement and line of fire.

## Sides, Teams, and Deployment

- Fixed sides: Player, Ally, Enemy, Neutral; sides subdivide into teams sharing line‑of‑sight.
- Landing zones allocated per map size (1–4 zones); player deploys squads there after previewing minimap.
- Enemy deployment pipeline: mission script → squad composition → auto promotions → map block priority → tile placement; difficulty scales squad size (75–150 %), AI aggressiveness (50–300 %), reinforcement waves (0–3).

## Turn Economy

- Turn order driven by initiative = base speed ± encumbrance/status; ties resolved in player favour.
- Units start with 4 AP per turn; modifiers: health <25 % −2 AP, morale penalties −2 AP, suppression −3 AP (stacks), stim bonuses +1 AP (caps at 5).
- AP costs: move 1 hex = 1 AP plus terrain modifier; snap shot 1 AP; aimed 3 AP; burst 3 AP; auto 4 AP; reload 1 AP; item use 1 AP; overwatch 2 AP; melee 2 AP.

## Accuracy Resolution

- Final hit chance = Base Accuracy × Range Mod × Fire Mode Mod × Cover Mod × LOS Mod; clamped to 5–95 %.
- Representative modifiers: point blank +20 %, medium −10 %, long −20 %, extreme −40 %; snap −20 %, aimed +20 %, burst −10 %, auto −20 %; light cover −15 %, heavy −30 %, critical −50 %; obstructed LOS −10 to −40 %, smoke −50 %.
- Cover stores cost-of-sight/cost-of-fire values; destruction removes modifiers.

## Damage Model

- Damage = (Base ± variance) × location multiplier × (1 − armor resistance) then apply status riders.
- Location factors: head 1.5×, torso 1.0×, limb 0.8×; armor tiers: light +5, combat +15, heavy +25 (movement/AP penalties −0/−1/−2 hexes and −0/−2 AP).
- Eight damage types: Kinetic, Explosive, Energy, Psi, Stun, Acid, Fire, Frost; each interacts with armor/resistance tables (e.g., explosive halved by walls, psi ignores armor, acid degrades armor, fire adds DoT and spreads, frost slows).
- Explosions propagate orthogonally; damage falls by 5 per hex; walls block, units behind walls take 50 %.

## Reactions and Interrupts

- Overwatch caches AP for reaction fire; triggers on enemy movement within LOS unless target suppressed or concealed.
- Melee counterattacks occur if opponent enters adjacent hex with ≥2 AP remaining.

## Status Systems

- Suppression: each suppressing attack applies −3 AP (reset end of turn if no fire taken).
- Stun: separate 0–20 pool; >10 immobilises, >20 knocks unit prone; recovers −5 per idle turn, −2 while acting; stimulants remove 10.
- Fire: 1–2 HP DoT, +morale loss, spreads to adjacent flammables; extinguish with water or action.
- Smoke: +1 to +4 sight cost, −10 to −30 % accuracy, +1 stun/turn at high density.
- Gas variants: poison (2 HP ignore armor), nerve (−1 HP, −2 morale per turn), acid (armor decay), stun gas (builds stun).
- Frost: +1 movement cost per hex, −10 % accuracy.

## Morale & Sanity (see shared systems)

- Morale pool 0…Bravery; loss triggers panic test (d20 + bravery vs DC). Panic states reduce AP and accuracy; leaders restore morale via inspire.
- Sanity 0–100 tracks campaign trauma; low sanity prevents deployment.

## Unit Actions & Abilities

- Standard actions: move, shoot, reload, overwatch, grenade, use item, interact, melee, hack.
- Class abilities unlocked via rank: e.g., Leader Inspire (end panic, +2 morale), Medic Heal (25 HP), Specialist Deploy Drone (scouting), Heavy Suppress (AP drain), Ghost Cloak (temp invisibility).
- Reaction fire respects visibility, cone-of-cover angles, and ammunition checks.

## Concealment & Detection

- Stealth units gain concealment until performing loud action; detection tests compare observer awareness vs target stealth rating modified by lighting and distance.
- Stealth missions link to geoscape budget; once budget zero, all enemy squads enter combat state.

## Environment Integration

- Weather imports from Geoscape (rain −1 sight, −10 % accuracy; snow −2 sight, +2 movement; blizzard −3 sight, +3 movement, −20 % accuracy).
- Terrain tags control movement multipliers (water 2–3 AP, rubble 2 AP) and cover values.
- Destructible geometry stores HP per material: wood 10–20, metal 30–60, stone 50–100, concrete 60–120.

## Victory & Extraction

- Mission success triggered by objective completion (eliminate hostiles, secure asset, escort, sabotage) or by reaching extraction zone with required assets.
- Partial success allows orderly retreat with recovered items; failure if squad wiped or timer expires.

## Post-Battle Resolution

- Outcomes feed Basescape: casualties become wounded states, XP awarded per damage, kills, survival; captured enemies move to prison facility; salvage queued for storage limits.
