# Economy System Summary

## Role in Campaign Loop

- Coordinates research, manufacturing, market acquisitions, and logistics to feed tactical readiness and strategic escalation.
- Ties reputation systems to economics: fame unlocks premium suppliers while karma opens or closes black market pipelines.
- Translates tactical success (salvage, mission rewards) into long-term economic capacity and technology progression.

## Research & Development Pillar

- Projects cost 50-500 man-days with 50-150% campaign randomization; prerequisites must reach 100% completion before unlocks.
- Five primary branches (Weapons, Armor, Alien Tech, Facilities, Support) layer early → late tiers with alien captures granting partial credit.
- Scientists face diminishing returns after 5/10 assignments; facility upgrades and specialization stack multiplicatively to cut time.
- Cancelling refunds 50-75% credits and preserves partial progress; switching branches retains 20% efficiency if in-category.

## Manufacturing Pillar

- Engineers consume man-days per recipe; batching improves efficiency up to 10% per unit and export sales yield 20-40% markups.
- Facility tiers (Workshop → Hub) accelerate throughput 10-30%; specialization and tooling add 5-20% bonuses.
- Queues support priority overrides, pause/resume, and impose 1-2 day spin-up penalties when reordering.
- Production halts gracefully on resource shortages instead of wiping progress; per-base inventories and warehouse capacity gate output.

## Marketplace & Supplier Web

- Six supplier archetypes drive availability; pricing = base × supplier modifier × relationship modifier × bulk discount.
- Relations span -100 to +100, shifting monthly with purchases/decay and unlocking discounts (up to -50%) or embargoes.
- Fame and alignment gate premium catalogs, while research levels prevent buying alien tech early; regional wars reduce stock 10-40%.
- Orders support upfront, credit, or subscription payments; delivery windows range 1-14 days with interception/delay risks and partial refunds on failure.
- Analytics dashboards track price trends, supplier reliability, and predictive availability for planning.

## Black Market Hooks

- Entry requires fame ≥25 and karma ≤+40 plus 10K buy-in; higher tiers demand fame 50/75/95 with karma thresholds ≤0/≤−50/≤−75.
- Inventory covers experimental weapons, mercs, stolen craft, mission contracts, and corpse trade with 200-500% markups and −5 to −20 karma hits per deal.
- Detection risk scales 5-15% per transaction; exposure slashes fame (−20 to −50) and diplomatic relations (−30 to −70) while triggering fines or facility downtime.

## Logistics & Transfer Systems

- Standard transfer cost = (mass × distance × 0.25) + base fee, modified by transport (air 2.0×, ground 1.0×, maritime 0.5×) and urgency multipliers.
- Time = distance / speed + load/unload overhead; emergency runs cut time 75% at 3× cost, stealth routes halve interception chance at +50% cost.
- Supply lines require 500 + 50×distance to activate, auto-resupply when stock <1.2× threshold, and can be protected via escorts (+25% cost) or stealth.
- Transfers are interceptable: contested routes can reach 90% risk, leading to tactical battles that determine cargo fate and strategic repercussions.

## Salvage & Revenue Streams

- Post-mission salvage auto-collects within craft capacity; condition tiers modify resale 10-100% and rare alien tech adds significant bonuses.
- Workshop/Research pipelines convert UFO parts, artifacts, and corpses into credits or unlocks over multi-day processing windows.
- Mission tier economics range from 500 credits (early) to 50K+ (late); UFO crashes can yield 20-100K depending on intact components.

## Strategic Integration

- Military actions (e.g., striking supplier regions) cascade into marketplace price spikes (30-60%) and supply shortages lasting weeks.
- Enemy AI targets active supply lines; sabotage success destroys one month of deliveries unless mitigated by escorts/stealth (up to 95% prevention combined).
- Economic victory path exists: control ≥70% suppliers, generate ≥500 credits/month from occupied regions, maintain 50+ supply lines, monopolize key resources.

## Balance Levers & Difficulty Scaling

- Campaign sliders adjust research cost multipliers, supplier pricing floors/ceilings, interception aggressiveness, and cash flow pacing.
- Diminishing returns across scientists, engineers, and supplier relations prevent runaway snowballing; karma/fame systems pressure ethical trade-offs.
- Scarcity knobs include monthly stock caps, delivery loss percentages, and manufacturing throughput penalties for overproduction.

## QA & Test Focus

- Verify research dependency gating, cost randomization bounds, and partial credit logic when capturing alien tech.
- Regression suites for manufacturing queues (pause/resume, resource depletion), batch bonus math, and export revenue calculations.
- Marketplace tests covering relationship-driven pricing, fame/karma gating, delivery failure probabilities, and embargo transitions.
- Logistics simulations for transfer cost/time formulas, interception battle triggers, supply line sabotage recovery, and redundancy fallbacks.
- Economic integration scenarios validating price shock propagation after military strikes and ensuring economic victory conditions tally correctly.
