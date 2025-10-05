# Marketplace

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Access and Scope Framework](#access-and-scope-framework)
  - [Purchase Flow and Transfer Integration](#purchase-flow-and-transfer-integration)
  - [Selling System Architecture](#selling-system-architecture)
  - [Pricing and Economic Systems](#pricing-and-economic-systems)
  - [Prerequisites and Access Control](#prerequisites-and-access-control)
  - [Stock and Restocking](#stock-and-restocking)
  - [Reputation and Consequence Systems](#reputation-and-consequence-systems)
- [Examples](#examples)
  - [Purchase Flow Scenarios](#purchase-flow-scenarios)
    - [Basic Equipment Acquisition](#basic-equipment-acquisition)
    - [Advanced Technology Purchase](#advanced-technology-purchase)
    - [Limited Stock Item](#limited-stock-item)
    - [Unit Recruitment](#unit-recruitment)
    - [Craft Acquisition](#craft-acquisition)
  - [Selling System Cases](#selling-system-cases)
    - [Equipment Recovery](#equipment-recovery)
    - [Surplus Resource Liquidation](#surplus-resource-liquidation)
    - [Sensitive Item Sale](#sensitive-item-sale)
    - [Craft Decommissioning](#craft-decommissioning)
  - [Pricing Structure Examples](#pricing-structure-examples)
    - [Standard Markup System](#standard-markup-system)
    - [High-Value Item Pricing](#high-value-item-pricing)
    - [Bulk Purchase Pricing](#bulk-purchase-pricing)
  - [Prerequisites and Access Cases](#prerequisites-and-access-cases)
    - [Research-Gated Advanced Equipment](#research-gated-advanced-equipment)
    - [Regional Restricted Item](#regional-restricted-item)
    - [Reputation-Gated Sensitive Equipment](#reputation-gated-sensitive-equipment)
  - [Reputation Consequence Scenarios](#reputation-consequence-scenarios)
    - [Neutral Standard Transaction](#neutral-standard-transaction)
    - [Positive Reputation Transaction](#positive-reputation-transaction)
    - [Negative Reputation Transaction](#negative-reputation-transaction)
    - [Major Reputation Decision](#major-reputation-decision)
  - [Transfer Integration Examples](#transfer-integration-examples)
    - [Standard Delivery Process](#standard-delivery-process)
    - [Bulk Order Consolidation](#bulk-order-consolidation)
    - [Capacity Management Scenario](#capacity-management-scenario)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The marketplace system establishes Alien Fall's primary commerce framework, providing a deterministic, low-risk acquisition method for equipment, recruits, and resources through predictable purchase and delivery mechanics. The system integrates with transfer logistics to create visible supply chains and strategic base placement decisions, with data-driven listings, stock management, and prerequisite systems controlling progression and regional availability.

Marketplace transactions create transfer orders with delivery delays, contrasting with instant alternatives while maintaining deterministic reputation impacts and comprehensive modding support. The marketplace functions as a stable economic anchor that contrasts with riskier alternatives like the black market.

## Mechanics

### Access and Scope Framework

Basescape-integrated commerce system with comprehensive item availability:

- Basescape Integration: Marketplace accessible through base management interface
- Listing Categories: Equipment, resources, units, and complete craft systems
- Delivery Integration: Purchase transactions spawn transfer orders with variable delivery times
- Scope Management: Global marketplace with regional and supplier-specific variations
- UI Accessibility: Clear interface showing prerequisites, stock, delivery time, and consequences

### Purchase Flow and Transfer Integration

Deterministic transaction processing with logistics visibility:

- Transaction Processing: Immediate purchase commitment with deferred delivery execution
- Transfer Order Creation: Void-to-base transfers with 1-5 day delivery windows based on item type
- Arrival Mechanics: Purchased items created in base inventory upon transfer completion
- Capacity Management: Delivery phase handles base storage and hangar limitations with overflow policies
- Logistics Visibility: Transfer system provides tracking and strategic planning tools
- No Pre-Validation: Purchases don't check destination capacity at buy time, handled on arrival

### Selling System Architecture

Direct inventory conversion with economic and reputation consequences:

- Inventory Access: Players sell any stored tradable items from base storage
- No Stock Constraints: Selling operates without restocking or availability limitations
- Transaction Simplicity: Direct inventory-to-credits conversion without transfer delays
- Price Determinism: Fixed sell prices (typically 50% of purchase price) with no market fluctuations
- Economic Balance: Selling provides resource recovery without marketplace complexity
- Reputation Integration: Sales transactions may impact fame and karma metrics

### Pricing and Economic Systems

Transparent pricing structure with consistent markup mechanics:

- Base Price Structure: Items defined with core sell_price values in configuration data
- Purchase Markup: Fixed 200% multiplier creating consistent pricing expectations
- Policy Integration: Organization policies may enhance market prices and access
- Supplier Independence: Pricing unaffected by supplier relationships or negotiations
- Economic Transparency: Clear price display with markup explanations shown to players
- Balance Controls: Pricing system supports strategic purchasing decisions and budget planning

### Prerequisites and Access Control

Research and regional gating controlling marketplace availability:

- Supplier Requirements: Research unlocks specific supplier access and item listings
- Technology Gates: Research prerequisites control item availability progression
- Regional Restrictions: Geographic requirements limit certain purchases to specific regions/provinces
- Facility Dependencies: Base infrastructure requirements for advanced item categories
- Service Prerequisites: Operational capabilities required for specialized equipment
- Reputation Thresholds: Karma and fame minimums for restricted or sensitive items

### Stock and Restocking

Strategic scarcity mechanics for high-value and limited items:

- Stock Limits: Certain listings have limited monthly availability (e.g., 2 units per month)
- Restocking Cycle: Stock refilled on monthly tick according to listing configuration
- Purchase Decrement: Available stock reduced with each purchase transaction
- Strategic Scarcity: Limited stock creates meaningful planning and prioritization decisions
- Availability Tracking: UI shows remaining stock and restock timing

### Reputation and Consequence Systems

Deterministic reputation impacts from marketplace transactions:

- Transaction Impacts: Purchases and sales modify player fame and karma scores
- Deterministic Effects: Reputation changes calculated and displayed before confirmation
- Strategic Trade-offs: Players balance immediate benefits against long-term consequences
- Supplier Relationships: Reputation affects future access and pricing negotiations
- Diplomatic Implications: Reputation changes influence faction interactions and diplomatic options
- Recovery Mechanics: Reputation modification systems with potential restoration through positive actions

## Examples

### Purchase Flow Scenarios

#### Basic Equipment Acquisition
- Item: Assault Rifle (base sell price 500 credits)
- Purchase Price: 1,000 credits (200% markup)
- Delivery Time: 3 days
- Transfer Type: Void-to-base
- Strategic Consideration: Immediate commitment with delayed availability

#### Advanced Technology Purchase
- Item: Plasma Rifle
- Prerequisites: Hyperion supplier unlock + plasma research completion
- Purchase Price: 2,500 credits
- Delivery Time: 4 days
- Regional Restriction: None
- Strategic Consideration: Research investment required for access

#### Limited Stock Item
- Item: Rare prototype weapon
- Stock Limit: 2 units per month
- Purchase Price: 5,000 credits each
- Delivery Time: 5 days
- Restock: Monthly cycle
- Strategic Consideration: Timing purchases for availability

#### Unit Recruitment
- Item: Soldier recruit
- Purchase Price: 2,000 credits
- Delivery Time: 2 days
- Prerequisites: Basic training facilities
- Strategic Consideration: Faster than training but more expensive

#### Craft Acquisition
- Item: Interceptor craft
- Purchase Price: 20,000 credits
- Delivery Time: 5 days
- Prerequisites: Advanced aerospace research
- Strategic Consideration: Immediate availability vs. manufacturing time

### Selling System Cases

#### Equipment Recovery
- Item: Captured alien weapon
- Sell Price: 800 credits (base value)
- Transaction: Immediate credit conversion
- Reputation Impact: Neutral (no karma/fame change)
- Strategic Consideration: Resource recovery from missions

#### Surplus Resource Liquidation
- Item: Excess alloy units (50 units)
- Sell Price: 25 credits each = 1,250 credits total
- Transaction: Instant bulk sale
- Storage Impact: Frees up base capacity
- Strategic Consideration: Budget balancing through resource sales

#### Sensitive Item Sale
- Item: Live alien captive
- Sell Price: 3,000 credits (high value)
- Reputation Impact: -25 Karma, -10 Fame
- Transaction: Immediate with consequence warning
- Strategic Consideration: Short-term gain vs. long-term reputation cost

#### Craft Decommissioning
- Item: Obsolete fighter craft
- Sell Price: 3,000 credits
- Transaction: Direct removal from hangar
- Strategic Consideration: Fleet modernization funding

### Pricing Structure Examples

#### Standard Markup System
- Base Sell Price: 500 credits
- Purchase Price: 1,000 credits (2.0× markup)
- Sell-Back Value: 500 credits (50% of purchase)
- Economic Balance: Consistent profit margin for marketplace

#### High-Value Item Pricing
- Base Sell Price: 50,000 credits (advanced craft)
- Purchase Price: 100,000 credits
- Sell-Back Value: 50,000 credits
- Strategic Impact: Significant budget commitment required

#### Bulk Purchase Pricing
- Individual Item: 100 credits each
- Bulk Order: 50 units × 100 = 5,000 credits total
- No Volume Discount: Consistent per-unit pricing
- Transfer Impact: Single delivery for bulk order

### Prerequisites and Access Cases

#### Research-Gated Advanced Equipment
- Item: Laser weapons
- Prerequisite: "Laser Technology" research completion
- Supplier: Standard marketplace
- Unlock Timing: Mid-game technology progression
- Strategic Impact: Research priority affects equipment availability

#### Regional Restricted Item
- Item: Tropical climate equipment
- Regional Restriction: Equatorial base locations only
- Prerequisite: Geographic positioning
- Strategic Impact: Base placement affects purchasing options

#### Reputation-Gated Sensitive Equipment
- Item: Covert operations gear
- Reputation Threshold: Minimum -20 Karma
- Prerequisite: Established reputation track record
- Strategic Impact: Gameplay choices affect marketplace access

### Reputation Consequence Scenarios

#### Neutral Standard Transaction
- Purchase: Basic equipment
- Reputation Impact: 0 Karma, 0 Fame
- Strategic Consideration: No long-term consequences

#### Positive Reputation Transaction
- Purchase: Humanitarian aid supplies
- Reputation Impact: +5 Fame
- Strategic Consideration: Diplomatic benefit for future interactions

#### Negative Reputation Transaction
- Sale: Alien biological specimens
- Reputation Impact: -10 Fame, -15 Karma
- Strategic Consideration: Short-term profit vs. diplomatic penalties

#### Major Reputation Decision
- Purchase: Faction-specific advanced weaponry
- Reputation Impact: +10 faction relationship, -5 general fame
- Strategic Consideration: Alignment choice with diplomatic consequences

### Transfer Integration Examples

#### Standard Delivery Process
- Purchase: Equipment package
- Transfer Creation: 3-day void-to-base transfer
- Tracking: Visible in transfer management interface
- Arrival: Automatic inventory addition
- Capacity Handling: Overflow policies applied if storage full

#### Bulk Order Consolidation
- Multiple Purchases: Several items bought simultaneously
- Transfer Optimization: Consolidated into single transfer order
- Delivery Coordination: Single arrival event for all items
- Logistics Efficiency: Reduced transfer management overhead

#### Capacity Management Scenario
- Purchase: Large equipment shipment
- Storage Check: Transfer arrival handles capacity limitations
- Overflow Options: Auto-transfer to another base or sale if configured
- Strategic Planning: Purchase timing considers base capacity

## Related Wiki Pages

- [Suppliers.md](../economy/Suppliers.md) - Marketplace vendor relationships and stock management.
- [Manufacturing.md](../economy/Manufacturing.md) - Alternative equipment production methods.
- [Finance.md](../finance/Finance.md) - Market prices and transaction costs.
- [Research.md](../basescape/Research.md) - Technology requirements for market access.
- [Geoscape.md](../geoscape/Geoscape.md) - Regional market availability and logistics.
- [Country.md](../geoscape/Country.md) - National market relationships and trade.
- [Craft Items.md](../crafts/Craft%20item.md) - Equipment market availability.
- [Units.md](../units/Units.md) - Personnel recruitment markets.
- [Technical Architecture.md](../architecture.md) - Marketplace system data structures.
- [Lore.md](../lore/Lore.md) - Market background and economic context.

## References to Existing Games and Mechanics

- **XCOM Series**: Marketplace and equipment procurement systems
- **Civilization**: Trade systems and marketplace mechanics
- **Master of Orion**: Trade and commerce systems
- **Elite**: Trading networks and marketplace interactions
- **X3: Reunion**: Trade networks and market systems
- **Star Control**: Equipment markets and procurement systems
- **Wing Commander**: Equipment markets and supply chains
- **Freespace**: Equipment procurement and marketplace systems
- **Homeworld**: Trade systems and resource markets
- **Starfleet Command**: Equipment markets and procurement mechanics

