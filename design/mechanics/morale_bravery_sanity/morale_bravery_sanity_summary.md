# Morale, Bravery & Sanity Snapshot

## System Roles

- **Bravery** (core stat, 6-12) sets battle-start morale cap, influences panic resistance, leadership aura strength, and psi defense.
- **Morale** operates in-battle as expendable buffer; drains from hits, deaths, flanks, horror events, with thresholds imposing AP/accuracy penalties down to full panic at 0.
- **Sanity** tracks long-term trauma between missions, gating deployment and triggering psychological debuffs if neglected.

## Key Mechanics

- Bravery modifiers: traits (Brave +2, Coward -3), rank (+1 per 3 promotions, max +4), equipment (officer gear, medals), situational (leaders nearby, night penalties, outnumbered states).
- Morale recovery: Rest action (2 AP -> +1), Leader Rally (4 AP -> +2 within 5 hexes), leader aura (+1/turn within 8 hexes). No passive regen; full reset post-mission.
- Panic outcomes: no AP, -50% accuracy, flee/drop weapon/surrender chances; requires intervention to recover above zero.
- Sanity drains via battlefield trauma, horror missions, psionic attacks; restoration through hospital stays, counseling facilities, downtime events.

## Integration Points

- Battlescape: status hooks adjust initiative/AP, interacts with suppression, stun, psi attacks, and morale-based abilities (Inspire, Battle Hymn).
- Basescape: recovery timers, hospital/counseling throughput, assignment of chaplains/psych officers to accelerate sanity repair.
- Economy/Facilities: advanced therapy centers unlock faster sanity recovery, high-end gear adds bravery bonuses.

## Strategic Implications

- Squad composition must balance bravery baselines with support roles (leaders, medics) to prevent cascading panic.
- Sanity gating enforces rotation of elite operatives; ignoring trauma sidelines veterans despite physical health.
- Mechanical units circumvent morale/sanity but incur maintenance costs, offering tradeoff against human flexibility.

## Implementation & QA Notes

- Clamp bravery-derived morale to [0,12]; ensure modifiers apply in correct phase (permanent before mission, situational each turn).
- Validate morale loss triggers and stacking (ally death proximity, outnumbered checks) to avoid double-counting.
- Test panic resolution flows, including interaction with suppression/stun; confirm leader abilities respect AP costs and range limits.
- Monitor sanity recovery pacing across difficulties to prevent soft-locks where top squads are perpetually sidelined.
