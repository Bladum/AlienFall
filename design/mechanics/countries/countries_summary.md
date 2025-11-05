# Countries & Funding Summary

## Strategic Role

- Nations underpin Geoscape economics: they own provinces, provide monthly credits, gate research partnerships, and react to territorial events.
- Four economic tiers (superpower, major, regional, minor) set GDP, province count, and base funding expectations; superpowers contribute 5-10M credits, minors 50-200K.
- Relations, threat level, performance, and political stability multiply base funding, so identical GDP can yield very different payouts.

## Funding Mechanics

- Monthly funding formula multiplies Base × Relations × Threat × Performance × Stability; base derives from GDP and tier multiplier.
- Event modifiers stack: successes in territory add +10% funding, base defense wins +20%, alien occupation -30%, crises like coups can zero contributions until resolved.
- Withdrawal at relations ≤ -40 or stability <3 halts funding; restoring requires missions, diplomacy, and sometimes cash indemnities.

## Diplomatic Interactions

- Relations states map directly to funding share and access (Allied 100% with full privileges, Hostile 0% with embargoes).
- Positive drivers: successful missions, alien base destruction, intel and research sharing, trade/military agreements. Negative drivers: mission failures, civilian losses, unauthorized ops, espionage scandals.
- Player actions range from credit gifts to full alliances; each has credit/PP costs, relation thresholds, and cooldowns. Diplomacy also influences supplier availability via Politics system.

## Territory Control

- Provinces cycle through controlled, contested, occupied, abandoned. Occupation halts funding until liberation missions succeed and reconstruction fees are paid.
- Alien pressure can flip provinces after repeated mission failures or long-term neglect; base construction without permission also strains relations.
- Province state flows feed Geoscape mission generation and panic metrics while updating economic multipliers automatically.

## AI & Events

- Country AI recalculates relations and funding every month, may boost self-defense, request aid, or withdraw based on threat and performance trends.
- Random events (economic booms/crises, coups, infiltration) apply funding/relationship swings; some demand player intervention to stabilize.
- Testing focus: funding formula correctness, relation threshold transitions, province ownership logic, event-driven modifiers, and difficulty scaling (Easy +30% funding vs Hard -20%).
