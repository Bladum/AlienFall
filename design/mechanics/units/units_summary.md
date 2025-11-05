# Units System Summary

## Core Philosophy

- Persistent squads form the campaign spine: units grow through ranks 0-6, unlock branching roles, and carry scars that fuel attachment.
- Class trees and equipment synergies ensure roster planning matters—wrong gear on wrong class yields −30% accuracy/−1 move penalties.
- Mechanics cover humans, aliens, and mechanical forces; biological and mechanical frames follow shared progression but diverge on upkeep and morale.

## Classification & Progression

- Rank ladder (0 Recruit → 6 Hero) gated by XP thresholds (0, 200, 500, 900, 1,500, 2,500, 4,500) with squad depth requirements (e.g., Rank 5 needs three Rank 4s).
- Promotion branches define role specialization (Soldier → Rifleman/Support/Specialist etc., pilots follow Fighter/Bomber/Transport/Scout paths with piloting stat 6-12).
- Demotion allows path correction: drop one rank, retain proportional XP, one-week retraining, reselect specialization, but stats revert to target rank baselines.
- Class mismatch rule: lower-tier gear always usable; high-tier gear on unspecialized units incurs penalties until re-promoted.

## Recruitment & Composition

- Marketplace supplies Rank 0-1 agents; advanced recruits unlocked via research, supplier relations, black market, or engineering (robots).
- Fame/karma and facility capacity gate availability; resurrection programs and mercenary contracts provide edge cases with steep costs.
- Recommended roster size scales 2-3× squad size to manage sanity and wound downtime; hospital/temple investments critical mid-game.

## Stats, Traits, & Perks

- Core stat ranges typically 6-12 with rank growth; traits consume a 4-point budget (positive costs, negative refunds) assigned at recruitment, immutable thereafter.
- Trait examples: Agile (+1 AP, 2 pts), Leader (aura +1 morale, 2 pts), Loyal (−50% salary, 1 pt); conflicts (Smart vs Stupid) enforced automatically.
- Perks layered atop traits deliver situational bonuses (accuracy, mobility, immunities, squad buffs) and stack unless explicitly contradictory.
- Transformations (one per unit) provide permanent biological/ mechanical augments (e.g., Berserker +3 STR/+3 HP, Full Mechanization +5 HP/+5 armor + morale immunity) at high research/cost.

## Inventory & Equipment

- Loadouts follow class-based unlocks; built-in checks prevent unauthorized use while allowing specialized bonuses (Medic using medikit heals +50%).
- Mechanical units rely on repair kits/facilities; biological units need medkits and medical bays.
- Pilots require craft-specific readiness: piloting stat gates craft tiers, XP earned from interceptions feeds same rank progression loop.

## Health, Wounds, & Recovery

- Damage converted to recovery weeks based on facility tier (Barracks 1 HP/week, Clinic 3, Hospital 5; priority: rank → damage → FIFO).
- Permanent wounds trigger when critically hit under 3 HP, reducing max HP until surgically removed (300 credits each).
- Death occurs at 0 HP if not evacuated in 3 turns; extraction requires ally rescue action, otherwise capture/killed with resurrection options (~60-80% success).

## Economics & Upkeep

- Recruitment ranges from 500 credits (Rank 0) to 10K+ (Rank 4); training times 1-4 weeks depending on rank/source.
- Salaries scale 200-500 credits/month, modified by traits (Loyal halves cost) and unit type (mechanical −50%).
- Facility upkeep (advanced barracks, medical, training) adds marginal per-unit fees, influencing squad size strategy.

## Psychological Systems Tie-In

- Bravery sets mission-start morale; morale losses from combat stress drive AP reductions and panic behavior (see morale summary).
- Sanity tracks cumulative trauma; at 0 the unit is Broken (deployment locked) until hospital/counseling/leave restores ≥1.
- Leader traits, perks, and equipment integrate tightly with morale recovery and squad stability loops.

## QA & Test Focus

- Validate rank prerequisite math (minimum counts per tier), demotion XP scaling, and class mismatch penalties activating/deactivating correctly.
- Trait generator must honor 4-point cap, conflict rules, and reroll costs; perks should stack only when allowed.
- Transformation pipeline tests: facility gating, stat application, slot adjustments, and permanence.
- Health recovery simulations for clinic/hospital scheduling, wound creation/removal, and extraction edge cases (carry vs abandonment).
- Economic regression for recruitment/salary modifiers, supplier availability gating, and mechanical vs biological maintenance costs.
