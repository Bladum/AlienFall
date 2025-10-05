# Black Market

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Access and Unlocks](#access-and-unlocks)
  - [Transaction Flow](#transaction-flow)
  - [Deterministic Consequences](#deterministic-consequences)
  - [Pricing and Special Rules](#pricing-and-special-rules)
  - [Transparency and Moddability](#transparency-and-moddability)
- [Examples](#examples)
  - [Purchase Example](#purchase-example)
  - [Sale Example](#sale-example)
  - [Prototype Example](#prototype-example)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Black Market offers a high-risk, high-reward economic channel that supplements the official marketplace with restricted goods and services. It reuses existing transfer and logistics mechanics for consistency, but adds special costs such as reputation penalties, legal consequences, or unique restock rules. The Black Market creates deliberate player trade-offs: faster access to powerful items versus deterministic diplomatic or reputational costs. Because it is data-driven, designers and modders can craft bespoke supplier lists and conditional unlocks without engine changes.

The system serves as a strategic lever for advanced players willing to accept long-term consequences for short-term advantages, while maintaining full transparency and deterministic outcomes for reproducible gameplay and modding.

## Mechanics

### Access and Unlocks

Black Market access follows gated progression mechanics:
- Narrative Enabling: Black Market enabled by specific narrative events, reputation thresholds, or research unlocks
- Data-Driven Configuration: All access requirements defined in external configuration files
- Individual Prerequisites: Listings can require further research, supplier relationships, or contact-level prerequisites
- Progressive Unlocking: Access becomes explicit and visible once requirements are met
- Regional Restrictions: Some black market suppliers may be tied to specific geographic regions

### Transaction Flow

Black Market transactions maintain parity with official marketplace mechanics:
- Transfer Integration: Purchases and sales follow the same transfer and arrival process as the official market
- Void-to-Base Transfers: Black market purchases spawn void→base transfers with configurable delivery times
- Capacity Handling: Purchases do not pre-validate destination capacity; overflow rules apply on arrival
- Stock Management: Listings declare price, delivery time, regional restrictions, and monthly stock limits
- Hook Integration: Uses standard transfer hooks (on_transfer_arrival) for automation and modding

### Deterministic Consequences

All black market activities have explicit, predictable impacts:
- Reputation Penalties: Fixed impacts on Karma, Fame, and diplomatic scores applied immediately
- No Probabilistic Elements: All consequences are deterministic and displayed before transaction confirmation
- Transparent Display: UI shows all reputational deltas and side effects on confirmation screens
- Informed Decision Making: Players can evaluate risk-reward trade-offs before committing
- Campaign Persistence: Reputation changes persist across the entire campaign

### Pricing and Special Rules

Black market economics create premium and restricted access:
- Premium Pricing: Generally higher prices than official marketplace with configurable multipliers
- Additional Costs: May require up-front escrow payments, unique inputs, or special arrangements
- Restricted Items: Items unavailable on official market may be sold with explicit penalties and reduced prices
- Experimental Access: High-risk or prototype listings require special contacts or illicit procurement research
- Escrow Requirements: Some transactions require holding payments or resources during transfer

### Transparency and Moddability

The system prioritizes player awareness and developer flexibility:
- Data-Driven Configuration: All parameters (reputational impacts, price multipliers, stock limits) defined in YAML
- Deterministic Behavior: Seeded randomization ensures reproducible outcomes across playthroughs
- Modding Hooks: Exposed events for on_blackmarket_purchase, on_blackmarket_sale, on_blackmarket_transfer_arrival
- UI Requirements: All costs, delivery times, and consequences displayed before purchase confirmation
- Telemetry Integration: Transaction logging supports debugging, balancing, and mod development

## Examples

### Purchase Example
- Scenario: Buy a confiscated Plasma Rifle before researching Laser Weapons technology
- Requirements: Requires "SmugglerNetwork" research unlock and sufficient funds
- Consequences: Applies -5 Karma and -2 Fame penalties on purchase
- Transaction Flow: Spawns void→base transfer following standard transfer rules
- Strategic Trade-off: Immediate access to advanced weaponry versus long-term reputation costs

### Sale Example
- Scenario: Sell a live alien captive to a shadow broker for research purposes
- Economic Benefit: Large cash payout from the transaction
- Consequences: Applies fixed -25 Karma penalty and specified drop in country diplomatic score
- Transparency: All effects displayed and confirmed before sale completion
- Ethical Choice: Players must weigh research benefits against moral and diplomatic costs

### Prototype Example
- Scenario: Prototype craft hull becomes available after Illicit Procurement research unlock
- Access Requirements: Requires payment for research node and sufficient black market contacts
- Benefits: Grants immediate blueprint access and advanced craft capabilities
- Penalties: Applies fixed reputational penalty for circumventing normal research progression
- Risk-Reward Balance: Accelerated technological advancement with diplomatic consequences

## Related Wiki Pages

- [Economy.md](../economy/Economy.md) - Core economic system.
- [Transfers.md](../economy/Transfers.md) - Transfer mechanics used by black market.
- [Suppliers.md](../economy/Suppliers.md) - Supplier system integration.
- [Research.md](../economy/Research.md) - Research access through black market.
- [Base management.md](../basescape/Base%20management.md) - Base operations affected.
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic consequences.
- [Items.md](../items/Items.md) - Black market items.
- [Craft.md](../crafts/Craft.md) - Prototype crafts.
- [Lore.md](../lore/Lore.md) - Lore integration.
- [Modding.md](../technical/Modding.md) - Moddability of black market.

## References to Existing Games and Mechanics

- Deus Ex series: Black market and underground economy.
- Cyberpunk 2077: Black market vendors and illegal goods.
- Grand Theft Auto series: Black market activities.
- Fallout series: Underground trading.
- The Witcher series: Black market merchants.
- Borderlands: Black market vendors.
- Assassin's Creed: Underground economies.
- Mafia III: Black market operations.

