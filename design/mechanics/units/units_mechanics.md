# Unit & Pilot Systems

## Classification & Acquisition

- Rank ladder (0 Recruit to 6 Hero) gates gear access and squad composition; higher ranks require multiples of the previous tier inside the roster (e.g., Rank 5 needs three Rank 4 veterans).
- Classes branch on promotion: Agent to first specialization split (Soldier/Support/Leader/Scout/Specialist/Pilot), with deeper tiers unlocking elite branches and equipment synergies (+50% bonus when role matches gear, -30% penalty when it does not).
- Biological vs mechanical archetypes dictate recovery methods (medbay vs repair bay) and morale susceptibility; faction identity is cosmetic while class and gear drive stats.
- Recruitment unlocked through markets, contracts, research, or fabrication: Rank 0 raw recruits are cheap but need training, higher ranks cost exponentially more credits and facility time, and black market hires trade karma for late-game specialists.

## Stats, XP & Career Flow

- Core stats operate on a 6-12 scale for humans (Accuracy, Speed, Strength, Bravery, etc.); aliens use an independent 50-110 scale multiplied by difficulty and campaign month.
- XP sources mix combat (kills, damage dealt, survival), mission success (objectives, difficulty multiplier), training, and medals; Smart trait accelerates gains 20%, Stupid slows equivalently.
- Promotions are processed post-mission in base facilities, instantly applying stat baselines and new branch choices; demotion retains proportional progress and enforces a 1-week retraining lockout.
- Respecialization keeps rank and stats intact, resets perks, costs 15k credits, and is capped at two lifetime uses per unit with one-week downtime between missions.

## Traits & Perks

- Trait pool uses a 4-point budget per unit, combining positive and negative effects; conflicts (e.g., Smart vs Stupid) are prevented, and rarity bands control generation odds.
- Traits are immutable and stack with equipment, transformations, and perks; they influence combat (Fast, Brave), economy (Loyal salary cuts), or logistics (Fragile blocks heavy armor).
- Perks sit atop class templates, unlocked via promotions, achievements, research, or events; categories (combat, movement, defense, resistance, skill, leadership) stack additively but disallow duplicates or contradictory pairs.
- Synergistic perk packages (Sharpshooter, Assault Tank, Squad Leader) shape squad roles, while negative traits or perks open budget builds with clear penalties.

## Equipment & Loadouts

- Inventory capacity ties directly to Strength; exceeding limits forbids deployment, encouraging deliberate trade-offs between heavy armor, sidearms, and utilities.
- Three-slot baseline (primary, secondary, armor) plus consumable reserves covers ranged, melee, thrown, and support gear; class requirements enforce competency thresholds (e.g., heavy cannon specialists).
- Armor tiers trade mobility and AP for protection and resistances; specialty suits (Hazmat, Stealth, Medic) overlay situational bonuses without breaking grid balance.

## Transformations & Long-Term Modifiers

- Every unit may undergo exactly one irreversible transformation (bio or mechanical) that injects major stat shifts, new abilities, or slot changes; prerequisites include research, facilities, and substantial credit outlays.
- Transformations coexist with traits and perks, enabling hybrid builds (Strong trait plus Berserker protocol) but can restrict equipment flexibility (full mechanization locks armor swaps).

## Health, Recovery & Attrition

- In-mission healing is limited to consumables and specialist actions; incapacitated units must be extracted within a short turn window or become casualties or captives.
- Between missions, recovery is facility-gated: barracks grant +1 HP per week, clinics +3 with three slots, hospitals +5 with five slots, and assignments prioritize rank and severity.
- Wounds permanently reduce max HP until surgically repaired (300 credits each), forcing investment in medical infrastructure; stasis pods pause recovery cycles for reserve units.

## Morale & Sanity Separation

- Morale resets each mission, acting as an AP buffer: thresholds at 3 and 1 progressively strip actions, with panic at 0 locking turns until stabilized by rest, leadership auras, or cover.
- Sanity tracks campaign fatigue only; drops from horrors, near-death, or atrocities and blocks deployment at 0. Recovery relies on hospitals, counseling (100-150 credits), leave, or promotions.
- System emphasizes squad rotation and psychological management without touching accuracy, keeping penalties focused on tempo and availability.

## Pilots & Craft Ops

- Pilot is a standard class path; Piloting stat mirrors other attributes (6-12) and scales with rank. Non-pilots remain at 0 and cannot fly craft.
- Craft access demands minimum Piloting values by hull type (Scout 6, Fighter or Bomber 8, Capital 12); performance bonuses apply per point above threshold across accuracy, speed, and dodge.
- Assignment locks units to craft for mission duration with a one-day reassignment lag and 100-credit admin fee; pilots cannot fly and fight ground combat simultaneously.
- Specializations (Fighter, Bomber, Transport, Scout to Ace or Squadron Commander) inject craft-specific perks like dogfights, payload boosts, or formation buffs.

## Economics & Maintenance Hooks

- Salaries scale from a 200 credits per month baseline, rising with rank and specialty; Loyal halves pay, mechanical units cost 50% less upkeep, and financial crises can ground squads.
- Demotion and respecialization interface with payroll (temporary relief versus long-term flexibility), while late-game elite recruits may demand five figures and rare resources.

## Testing Priorities

- Validate XP curves, demotion math, and respecialization limits across difficulties.
- Stress-test trait and perk generation to ensure valid combinations and desired rarity distribution.
- Simulate recovery queues under high casualty rates to confirm facility throughput and prioritization rules.
- Run pilot performance benchmarks per craft tier and confirm alien stat scaling produces intended threat envelopes on Impossible difficulty.
