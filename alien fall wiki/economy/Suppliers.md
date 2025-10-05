# Suppliers

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Supplier Identity and Configuration](#supplier-identity-and-configuration)
  - [Contact and Unlock Rules](#contact-and-unlock-rules)
  - [Purchase Item Framework](#purchase-item-framework)
  - [Stock Management System](#stock-management-system)
  - [Pricing and Transaction Framework](#pricing-and-transaction-framework)
  - [Reputation Effects System](#reputation-effects-system)
  - [Relationship and Access Control](#relationship-and-access-control)
  - [Delivery and Transfer Integration](#delivery-and-transfer-integration)
  - [Black Market Rules](#black-market-rules)
  - [UI, Hooks and Determinism](#ui,-hooks-and-determinism)
- [Examples](#examples)
  - [Supplier Configuration Cases](#supplier-configuration-cases)
  - [Purchase Item Scenarios](#purchase-item-scenarios)
  - [Stock Management Examples](#stock-management-examples)
  - [Pricing Transaction Cases](#pricing-transaction-cases)
  - [Reputation Effects Scenarios](#reputation-effects-scenarios)
  - [Relationship and Access Control Examples](#relationship-and-access-control-examples)
  - [Delivery Integration Examples](#delivery-integration-examples)
  - [Black Market Cases](#black-market-cases)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Suppliers system establishes a curated vendor layer controlling market availability, progression pacing, and commerce flavor through research-gated access to different item categories. Suppliers organize marketplace listings with monthly stock limits, reputation requirements, and regional restrictions while maintaining deterministic pricing and delivery mechanics. The system integrates with research unlocks, transfer logistics, and reputation systems to create strategic purchasing decisions with reproducible outcomes for testing and modding support.

Suppliers serve as the primary mechanism for acquiring equipment, personnel, and craft that cannot be manufactured locally. By gating powerful items behind research progression, regional access, or reputation thresholds, suppliers create meaningful pacing and strategic trade-offs. The data-driven architecture supports extensive modding while maintaining consistent marketplace behavior.

## Mechanics

### Supplier Identity and Configuration

Suppliers are data-driven records with comprehensive configuration fields:
- Core Identity: id, display_name, description, and category fields
- Access Control: contact_research_id, required_karma, required_fame thresholds
- Economic Parameters: base_price_multiplier, relationship_modifiers
- Stock Management: monthly_stock_reset mode, stock_table (item_id → quantity)
- Regional Binding: optional country_id for region-specific suppliers
- Market Classification: is_blackmarket flag for special handling

Supplier records function as first-class mod assets, enabling new vendors or tiered brands without code changes.

### Contact and Unlock Rules

Supplier access follows a progressive unlock system:
- Research Unlocks: Completing contact_research_id or associated quests makes supplier catalogs visible
- Visibility vs Availability: Unlocking reveals catalogs, but individual items still require their own prerequisites
- Default Availability: Suppliers with null contact_research_id available from campaign start
- Status Progression: Suppliers track progression from unknown → contacted → unlocked states

### Purchase Item Framework

Purchase items spawn specific entity types in base inventory:
- Entity Creation: Purchases generate ITEM, UNIT, or CRAFT entities upon delivery
- Supplier Requirements: All listed suppliers must be unlocked for item availability
- Stock Limitations: Monthly stock limits create scarcity and restocking cycles
- Additional Prerequisites: Technology, regional, facility, or service requirements beyond suppliers
- Fixed Pricing: All purchases use deterministic markup on base sell prices
- Transfer Integration: Purchases create void-to-base transfer orders with variable delivery times

### Stock Management System

Stock systems create predictable supply constraints:
- Monthly Replenishment: Stock refreshes at month start with configurable behavior (full, partial, random)
- Per-Item Tracking: Stock levels maintained individually for each supplier-item combination
- Restock Modes: Full refill to maximum, fixed amount additions, or seeded probabilistic refill
- Availability Control: Items become unavailable when stock depleted until next restock
- UI Transparency: Current stock levels and next restock dates visible in marketplace
- Scarcity Mechanics: Stock limits create strategic purchasing timing decisions

### Pricing and Transaction Framework

Pricing follows deterministic, transparent formulas:
- Base Price Definition: Items have defined sell prices for player-to-marketplace transactions
- Markup Calculation: Purchase price = sell_price × supplier.base_price_multiplier × relationship_discount
- Supplier Independence: Pricing unaffected by supplier relationships or negotiation
- Policy Integration: Organization policies may provide market price improvements
- Storage Sales: All inventory items sellable at defined sell prices without restrictions
- Economic Balance: Consistent pricing supports strategic resource management

### Reputation Effects System

Transactions create lasting reputation consequences:
- Transaction Impacts: Purchases and sales modify player fame and karma scores
- Karma/Fame Requirements: Minimum thresholds required for certain supplier access
- Deterministic Effects: Reputation changes calculated and displayed before transaction confirmation
- Strategic Trade-offs: Players balance immediate benefits against long-term reputation consequences
- Supplier Relationships: Reputation affects future supplier availability and access
- Diplomatic Implications: Reputation changes influence broader faction interactions

### Relationship and Access Control

Supplier relationships evolve through sustained interaction:
- Relationship Tiers: Neutral → Preferred → Allied progression through repeated purchases
- Tier Benefits: Higher tiers unlock discounts, exclusive items, or larger stock access
- Access Blocking: Purchases blocked if player fails required_karma or required_fame checks
- UI Feedback: Interface shows blocking reasons and relationship status
- Strategic Depth: Relationship building creates long-term investment decisions

### Delivery and Transfer Integration

Purchases integrate seamlessly with logistics systems:
- Transfer Order Creation: All purchases generate standard void-to-base transfer orders
- Delivery Timeframes: Configurable 1-5 day delivery periods per purchase item
- Arrival Mechanics: Transfer completion creates purchased entities in base inventory
- Capacity Management: Delivery respects base storage and hangar limitations
- Logistics Tracking: Transfer system provides visibility into delivery status and timing
- Overflow Handling: Transfer arrival manages base capacity constraints and overflow policies

### Black Market Rules

Black market suppliers follow specialized constraints:
- Explicit Penalties: Deterministic reputational costs (Karma -X, Fame -Y) displayed on confirmation
- Limited Stock: Smaller stock pools and irregular restock cadences
- Extra Prerequisites: Optional escrow payments or bribe requirements
- Legal Consequences: Clear display of reputational and legal risks
- Thematic Variety: Creates high-risk, high-reward purchasing options

### UI, Hooks and Determinism

The system provides comprehensive player and developer support:
- Market UI: Surfaces supplier information, stock levels, requirements, and consequences
- Automation Hooks: on_supplier_unlock, on_purchase, on_monthly_restock events
- Deterministic Behavior: All restock and transaction behavior seedable for reproducible testing
- Telemetry Integration: Purchase logs, restock summaries, and relationship events for debugging

## Examples

### Supplier Configuration Cases
- Ares Armaments: Unlocked by "ares_contact" research, monthly stock: Assault Rifles (20), Grenade Packs (50), base_price_multiplier = 1.0
- Hyperion Advanced: Requires "advanced_weapons" research and karma ≥ 10, provides plasma technology access
- Alien Traders: Unlocked through diplomatic relations, requires base in "Alien Territory" region
- Black Market Contacts: Requires minimum fame 50, maximum karma -10, provides restricted items with explicit penalties
- Regional Supplier: Country-specific vendor with localized equipment and pricing
- Research-Gated Vendor: Advanced supplier unlocked only after completing specific technology research

### Purchase Item Scenarios
- Assault Rifle: Requires "ares_armaments" supplier, sell price 500 credits, purchase price 1000 credits, 3-day delivery
- Plasma Rifle: Requires "hyperion_advanced" supplier and "plasma_tech" research, sell price 2500 credits, purchase price 5000 credits
- Alien Alloy: Requires "alien_traders" supplier and "Alien Region" base location, sell price 100 credits per unit
- Interceptor Craft: Requires multiple suppliers unlocked, sell price 10000 credits, 5-day delivery time
- Soldier Recruit: Requires "military_recruiters" supplier, sell price 1000 credits, 2-day delivery
- Special Equipment: Requires reputation thresholds, restricted availability, premium pricing

### Stock Management Examples
- Monthly Restock: Assault Rifle stock replenishes to 20 × (0.5-1.5) = 10-30 units (seeded variation)
- Stock Depletion: Player purchases 5 rifles, reducing stock from 25 to 20 remaining units
- Availability Control: Grenade packs deplete to 0, become unavailable until next monthly restock
- Stock Transparency: UI shows current stock levels and countdown to next restock date
- Scarcity Planning: Players time major purchases around monthly restock cycles
- Stock Variation: Seeded randomization ensures consistent but varied stock levels per campaign

### Pricing Transaction Cases
- Standard Markup: Base sell price 500 credits × 2.0 = 1000 credit purchase price
- High-Value Items: Advanced craft with 50000 credit base × 2.0 = 100000 credit purchase
- Bulk Consistency: Volume purchases maintain per-unit markup without discount scaling
- Policy Benefits: Economic policies provide 10% price reduction, 1800 credits for 1000 base item
- Supplier Neutrality: No negotiation or relationship modifiers affect fixed pricing
- Sell Mechanics: Captured alien weapon sold for 800 credits base value, immediate transaction

### Reputation Effects Scenarios
- Neutral Transactions: Standard equipment purchases with no reputation modification
- Positive Impacts: Humanitarian aid purchases granting +5 fame points
- Negative Consequences: Black market intel acquisition costing -5 karma points
- Access Requirements: Covert operations gear requires minimum -20 karma score
- Major Decisions: Alien specimen sales applying -10 fame and -15 karma penalties
- Diplomatic Effects: Faction-specific purchases modifying relationship scores

### Relationship and Access Control Examples
- Tier Progression: Starting with Neutral supplier, repeated purchases increase relationship to Preferred (+10% discount)
- Access Blocking: Player with karma -5 blocked from "Ethical Suppliers" requiring karma ≥ 0
- Exclusive Unlocks: Allied relationship with "Hyperion" unlocks prototype equipment listings
- UI Feedback: Purchase screen shows "Blocked: Insufficient Karma (current: -5, required: 0)"

### Delivery Integration Examples
- Standard Delivery: Equipment purchase creating 3-day transfer with automatic base arrival
- Bulk Operations: Multiple purchases consolidated into single transfer order
- Capacity Management: Transfer arrival respecting base storage limitations and overflow
- Priority Handling: Critical purchases flagged for expedited transfer processing
- Logistics Tracking: Transfer status visible in base management interface
- Delivery Coordination: Multiple transfers scheduled to avoid simultaneous arrivals

### Black Market Cases
- Shadow Brokers: is_blackmarket = true, purchases apply Karma -5 and Fame -3 penalties
- Penalty Display: Confirmation screen shows "Karma: -5, Fame: -3" with clear warnings
- Stock Irregularity: Random restock mode with smaller maximum quantities
- Extra Requirements: Some items require escrow payment or completed smuggling quest

## Related Wiki Pages

- [Marketplace.md](../economy/Marketplace.md) - Supplier listings and market interface.
- [Manufacturing.md](../economy/Manufacturing.md) - Alternative equipment production methods.
- [Finance.md](../finance/Finance.md) - Purchase costs and reputation effects.
- [Research.md](../basescape/Research.md) - Technology requirements for supplier access.
- [Geoscape.md](../geoscape/Geoscape.md) - Regional supplier locations and access.
- [Country.md](../geoscape/Country.md) - National supplier relationships.
- [Craft item.md](../crafts/Craft%20item.md) - Equipment procurement options.
- [Units.md](../units/Units.md) - Personnel recruitment through suppliers.
- [Technical Architecture.md](../architecture.md) - Supplier system data structures.
- [Lore.md](../lore/Lore.md) - Supplier background and relationships.

## References to Existing Games and Mechanics

- **XCOM Series**: Supplier networks and black market procurement
- **Civilization**: Trade routes and merchant relationships
- **Master of Orion**: Trade systems and diplomatic procurement
- **Elite**: Trading networks and merchant interactions
- **X3: Reunion**: Trade networks and supplier relationships
- **Star Control**: Equipment merchants and procurement systems
- **Wing Commander**: Equipment dealers and supply chains
- **Freespace**: Equipment procurement and supplier management
- **Homeworld**: Trade systems and resource acquisition
- **Starfleet Command**: Equipment suppliers and procurement mechanics

