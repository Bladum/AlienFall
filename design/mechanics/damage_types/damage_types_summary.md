# Damage Type Matrix

## Core Palette

- Eight canonical types: Kinetic, Explosive, Energy, Psi, Stun, Acid, Fire, Frost. All content must reference these IDs unless a mod adds new ones.
- Armor baseline resistances: Light (50% kinetic, 40% explosive, 20% energy, 0% psi, 70% stun, 30% acid, 40% fire, 50% frost), Medium, Heavy, Reinforced, Alien Tech with specified reductions; special armors override single columns (Psi Shield 80% psi, Insulated 95% stun, etc.).
- Shields absorb first then pass remainder to armor/health; standard/advanced/alien shield tables stack with armor but never double-count.

## Damage Behaviors

- Explosives use directional wave propagation: walls fully block waves, units reduce damage (50% base + armor resistance) but do not stop propagation, distance scaling (100/80/60/40%).
- Psi ignores all physical armor/shield values unless dedicated psi protection exists; treat as pure neurological attack.
- Status tie-ins: Stun accumulates non-lethal threshold with -1/turn decay, Acid applies corrosion (later hits reduce armor effectiveness), Fire inflicts burning DoT (−1 HP for 3 turns), Frost halves movement for 2 turns.

## Combat Integration

- Final damage = Base × (1 − Resistance%). Fire modes adjust base: single 1.0× (+20% accuracy), burst 0.8×, auto 0.6× (−15% acc), charged 1.5× (−10% acc).
- Accuracy pipeline is damage-agnostic; aim, cover, range, and visibility drive hit chance.
- Faction loadouts: Humans lean kinetic/explosive/stun/fire; aliens field energy/psi/acid with species variation. Ensure encounter design mixes types to pressure varied armor builds.

## Design & Mod Hooks

- Custom types and armor profiles are supported but must extend the canonical tables for consistency; modders should define new resistance rows/columns explicitly.
- Testing focus: explosion blocking logic, shield-first damage ordering, psi bypass, corrosion/burning/frost duration handling, and charged shot modifiers.
