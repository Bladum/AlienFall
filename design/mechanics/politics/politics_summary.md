# Politics System Summary

## Scope & Pillars

- Tracks external perception (Fame), hidden morality (Karma), formal relationships (countries, suppliers, factions), organizational power points, and advisor network.
- Interlocks with finance, missions, and marketplace: fame unlocks funding and suppliers; karma and relations gate black market, humanitarian ops, and story branches.
- Unified scales (fame 0–100, karma −100–+100, relations −100–+100) feed event triggers, pricing, mission availability, and endings.

## Fame vs Karma

- **Fame**: Public-facing metric (Unknown → Legendary) adjusting mission spawn (+30%), funding bonuses (+10–50%), supplier tiers, recruitment quality, and enemy attention (+30% campaign frequency at high fame). Gains from mission success, research, major victories; losses from failures, civilian casualties, black market exposure. Decays 1–2/month when idle.
- **Karma**: Hidden alignment (Evil ↔ Saint) driving contract availability, advisor reactions, recruitment pools, event variants, and narrative paths. Adjusted via humanitarian acts (+15), civilians rescued (+5), executions (−20), black market deals (−5 to −20), atrocities (−30). Alignment gates mission archetypes (assassinations vs liberation) and supplier willingness (saints lose black market, evil loses humanitarian suppliers).

## Relationship Web

- **Countries**: Influence mission frequency, funding tiers (level 1 = −50%, level 10 = +50%), base rights, and recruitment access. Actions (victories, casualties, treaties, incidents) shift relations; statuses range from embargo to strategic partner with effects on missions, bases, and trade permissions.
- **Suppliers**: Pricing multiplier `1.0 + 0.005 × (100 − relation)` and availability/delivery modifiers; relation changes through purchases, diplomacy, reliability, or betrayal. Unlock exclusives at +50, embargo at −100.
- **Factions**: Control enemy aggression, reinforcement strength, espionage pressure, and joint operations. Destroying bases or capturing leaders worsens relations; diplomacy, tech transfers, or withdrawals improve them. Multi-faction politics feature rival penalties and coalition escalations.

## Power Points

- Monthly strategic currency (`1 + bonuses − penalties`) representing organizational maturity. Earned from major victories (+3–5), treaties (+2), tech breakthroughs (+1), milestones (e.g., 10 missions = +2); lost via catastrophes (−3–5), betrayals (−5). Spent on advisors, organization level-ups, exclusive tech, and emergency measures. No decay; forecasted in monthly reports.

## Advisor Framework

- Advisors cost power points + monthly salaries (500–8,000 credits) with 1-month hiring delay; provide domain bonuses (finance, military, intel, diplomacy, R&D).
- Synergy sets (e.g., CFO + Quartermaster → +5% income, −20% transfer cost) stack multiplicatively; incompatibilities reduce overlapping bonuses by 5–10%.
- Hierarchy rules resolve overlapping effects: highest tier overrides, incompatible pairs flagged by reduced efficiency.

## System Interactions & Risks

- High fame + low karma can trigger public scandals (aid withdrawal, mission scrutiny). Very low funding (<50K) applies morale penalties (−5) and attrition, while fame-driven funding and supplier deals mitigate.
- Relationship thresholds govern base construction, mission types, and economic levers; black market exposure hits fame (−20) and relations (−15) globally.
- Multiple faction dynamics: supporting one penalizes rivals (−10 to −30), coalition retaliations increase mission difficulty, truces require +75 relation.

## QA & Monitoring

- Validate fame/karma deltas per event, decay timers, and bonus calculations (mission spawn %, funding multipliers, pricing modifiers).
- Stress-test relationship shifts under rapid event sequences (multi-country incidents, supplier betrayal, faction coalitions).
- Confirm power point accrual/spend flow, advisor hire delays, synergy activation/deactivation, and cost deductions.
- Scenario tests for campaign thresholds (morale penalties at <50K credits, bankruptcy at −500K three months, fame-driven enemy aggression).
