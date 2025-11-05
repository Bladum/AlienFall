# Battlescape Mechanics Snapshot

## Battlefield & Deployment

- Hex-based vertical axial grid with cube-distance calculation; maps stitch 15-hex blocks into 4x4-7x7 battlefields, each block rotatable/mirrorable for replay variety.
- Sides (Player, Ally, Enemy, Neutral) subdivide into LOS-sharing teams; maps allocate 1-4 landing zones with squad preview prior to deployment.
- Enemy setup pipeline: mission script -> squad templates -> auto promotions -> block priority -> tile placement, with difficulty scaling squad count (75-150%), AI aggression (50-300%), and reinforcement waves (0-3).

## Turn Economy & Combat Resolution

- Initiative = base speed +/- encumbrance/status; player wins ties. Units operate on 4 AP baseline with modifiers for health, morale, suppression, stimulants (cap 5 AP).
- AP costs anchored to 1-hex movement at 1 AP plus terrain multipliers; fire modes differentiate cost/bonuses (snap 1 AP/-20% accuracy, aimed 3 AP/+20%, burst 3 AP/-10%, auto 4 AP/-20%).
- Final accuracy clamps 5-95% from Base x range x fire mode x cover x LOS; reference modifiers include point blank +20%, heavy cover -30%, smoke -50%.
- Damage = (Base +/- variance) x location multiplier x (1 - armor resistance) with eight damage types (Kinetic, Explosive, Energy, Psi, Stun, Acid, Fire, Frost) supplying bespoke riders (acid degrades armor, fire spreads DoT, frost slows, psi pierces armor).

## Reactive Play & Status Layers

- Overwatch banks AP for reaction fire triggered by enemy movement in LOS; suppressed or concealed targets can bypass.
- Melee counterstrikes trigger on adjacency if defender retains >=2 AP.
- Status packages: suppression (-3 AP, clears when no incoming fire), stun pools (0-20; >10 immobilise, >20 prone, recovery tied to idle turns, stimulants remove 10), fire/smoke/gas variants, frost slow, plus morale and sanity pools referencing shared systems.

## Environment & Extraction

- Weather imports from Geoscape (rain sight -1 / accuracy -10%, snow sight -2 / movement +2, blizzard sight -3 / movement +3 / accuracy -20%).
- Terrain tags govern movement (water 2-3 AP, rubble 2 AP) and cover strength; destructible materials carry HP bands (wood 10-20, metal 30-60, stone 50-100, concrete 60-120).
- Victory triggers on objective completion or evac; partial success allows retreat with loot, failure on squad wipe or timers.
- Post-battle pipeline feeds Basescape wounds, XP (damage dealt, kills, survival), prisoner capture, and salvage queues.

## Implementation & QA Notes

- Ensure initiative recalculation respects status updates mid-round and AP clamps at [0,5].
- Validate accuracy calculators for combined modifier stacking and 5-95% clamp; cross-check cover destruction toggles associated cost tables.
- Stress-test status recovery pacing (stun decay, suppression clear) and environmental propagation (fire spread, gas stacking) across map sizes.
- Integration checks: Geoscape weather ingestion, Basescape casualty handling, mission scripts providing squad templates and reinforcement cadence.
