# Items System Summary

## Purpose & Scope

- Governs every transferable asset: strategic resources, lore artifacts, unit gear, craft modules, consumables, and prisoners.
- Enforces research-first progression—purchase, use, and manufacture flags gate content until prerequisites complete.
- Connects economy, unit loadouts, and mission rewards by forcing trade-offs between equipping, selling, synthesizing, or stockpiling assets.

## Category Highlights

- **Resources** drive manufacturing, facility power, and craft range; phases introduce tiered materials (Fuel/Metal → Elerium/Alloys → Quantum Processors) with synthesis and trade loops.
- **Lore items** are zero-weight narrative unlocks that trigger research branches and story beats; protected from accidental sale.
- **Unit equipment** spans weapons, armor, utilities, and consumables with class synergies, AP costs, damage types, and weight/storage constraints.
- **Craft equipment** uses hardpoint weapons and support systems (shields, plating, fuel pods) fixed before interception; damage types include kinetic, energy, explosive.
- **Prisoners/corpses** feed research, diplomacy, and karma decisions; living captives decay over 10-60 days and require containment capacity.

## Synergy & Loadout Rules

- Equipment classes (Light/Medium/Heavy/Specialized) determine mobility vs protection; matched weapon/armor combos award bonuses, mismatches incur accuracy and armor penalties (e.g., light armor + heavy weapon = −15% accuracy, ×0.85 armor multiplier).
- Unit strength gates armor requirements; being under threshold reduces movement (−1 hex per 2 STR below) and may enforce penalties.
- Medic class + medikit, specialist + heavy weapons, etc., receive baked-in potency bonuses; general mismatch yields −30% accuracy and −1 move where specified.
- Craft loadouts are immutable mid-mission; fuel is pre-consumed per sortie with no in-flight refuel, making hangar prep critical.

## Durability & Maintenance

- Items track 0-100 durability; thresholds (Pristine, Worn, Damaged −10% effectiveness, Critical −30%) drive repair urgency.
- Degradation rates: weapons −5 per mission, armor −3 per hit, environment modifiers (volcanic +2, underwater +1), class usage adjustments.
- Repairs cost 1% of base price per durability point and require workshop time (1 day per 10 durability); emergency supplier repairs at +50% cost.
- Destroyed gear (0 durability) is lost permanently along with installed mods.

## Modification System

- Weapons host two slots, armor one, utilities one; install requires research, workshop time, 10% mod fee, and −5 durability.
- Mods include scopes (+15% accuracy), extended mags (+50% ammo), armor plating (+5 armor), camouflage (+15% stealth), etc., with conflict rules (scope vs laser sight, plating vs lightweight alloy).
- Mods are reusable if removed before destruction; stacking is multiplicative and enables specialized builds (e.g., silenced covert kit, rapid suppression platform).

## Acquisition & Economy

- Supplier relations, fame, and karma adjust price multipliers (±150% to −50%) and stock access; marketplace sales fixed at 50% base price.
- Storage tracked separately from weight; facilities supply ~100 space units, forcing warehouse expansion for heavy stockpiles.
- Synthesis converts commodity resources into rare materials; players choose between manufacturing, selling, or conversion to support strategy.
- Black market offers alien tech at inflated prices with detection risk; contracts/auctions provide limited-time deals.

## Usage & Logistics

- Pre-mission checks validate class, capacity, and research before equipping; over-capacity incurs +5% monthly maintenance per excess weight.
- Tactical layer allows weapon swapping (AP cost), item throws (1 AP emergency), corpse pickup, but armor remains fixed.
- Craft equipment must be configured before launch; cargo limits and passenger cabins enable transfer missions and rescues.

## Balance Levers & Difficulty

- Adjustable knobs include durability decay rates, synergy multipliers, repair costs, resource yields, and supplier pricing floors.
- Difficulty scaling tweaks availability, maintenance overhead, and research gating speed; harder modes impose steeper penalties and slower repairs.

## QA & Testing Priorities

- Verify synergy UI states (matched/mismatched/specialized) and resulting accuracy/armor/movement modifiers.
- Regression tests for durability loss per item type/environment, destruction thresholds, and repair cost/time calculations.
- Modification pipeline: installation costs, conflict enforcement, removal reuse, and durability subtraction.
- Inventory validation for class requirements, strength checks, storage capacity, and over-capacity maintenance penalties.
- Economy simulations covering supplier relation pricing bands, black market karma hits, resource synthesis ratios, and sell-back consistency.
