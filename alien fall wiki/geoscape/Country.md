# Country

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Geography and Scope](#geography-and-scope)
  - [Economic Value Aggregation](#economic-value-aggregation)
  - [Public Score and Funding Conversion](#public-score-and-funding-conversion)
  - [Visibility Constraints](#visibility-constraints)
  - [Political Dynamics and State Changes](#political-dynamics-and-state-changes)
  - [Data-Driven Configuration](#data-driven-configuration)
- [Examples](#examples)
  - [High-Value Strategic Target](#high-value-strategic-target)
  - [Tactical Performance Impact](#tactical-performance-impact)
  - [Neglect Consequences](#neglect-consequences)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
A Country represents a campaign-level political and economic region that aggregates province population, score, and economic value to determine funding potential, mission opportunities, and diplomatic stance. Countries provide recurring monthly support, contracts, and localized strategic choices tied to visible performance in their provinces. They serve as configurable data objects enabling distinct geopolitical behaviors, restrictions, and withdrawal conditions without changing core systems.

Countries create incentives to protect high-value provinces and enable region-specific storylines and tailored mission content. They make clear what players can influence and how local actions map to national funding and global consequences, with all mechanics being data-driven for extensive modding support.

## Mechanics
### Geography and Scope
Countries consist of authored provinces on Earth-like worlds, with no single capital province. All member provinces contribute equally to funding and reporting. Countries do not exist on non-Earth worlds unless explicitly defined by mods or scripts.

### Economic Value Aggregation
Country economic value equals the sum of all member province economic values, directly scaling monthly payouts and funding potential. Similarly, country population equals the sum of all member province populations. This aggregation provides the economic base for funding calculations.

### Public Score and Funding Conversion
Public score derives from publicly visible actions affecting civilians and infrastructure, including interceptions, terror prevention, and mission outcomes within country provinces. Score is aggregated as the sum of all mission scores from all country provinces.

### Monthly Relation Changes
Country relation with player organization operates on a 0-10 scale:
- **Relation Range**: 0 (no funding) to 10 (maximum funding)
- **Monthly Adjustment**: Based on monthly score results, relation changes by +1 or -1
- **Funding Calculation**: Monthly income = Relation Level × Country Economic Value × 1000
- **Score Threshold**: Positive monthly score increases relation (+1), negative score decreases relation (-1)

### Visibility Constraints
Only observable actions by the public or government influence public score. Covert operations, hidden projects, or actions on other worlds do not affect country score unless they become public.

### Political Dynamics and State Changes
Borders and membership remain mutable through scripted events, allowing province reassignment, country creation/removal, or ownership changes. Sustained poor performance reduces funding levels, potentially triggering diplomatic penalties, treaty shifts, special restrictions, or withdrawal from funding.

### Data-Driven Configuration
All numeric thresholds, conversion rates, and political behaviors are authored in external data files, enabling designer and modder tuning of pacing, sensitivity, and edge behaviors without code changes.

## Examples
### High-Value Strategic Target
USA with very high economic value yields large monthly payouts when public score remains high, but high visibility makes it a frequent target for alien activity and political scrutiny.

### Tactical Performance Impact
Stopping a terror mission in Egypt yields significant public score increase, improving Egypt's funding level and monthly funding in the next cycle.

### Neglect Consequences
Ignoring a landed UFO in Brazil causes large public score penalty. Repeated neglect can drive funding level to zero and trigger diplomatic withdrawal or operational restrictions in Brazilian provinces.

## Related Wiki Pages

- [Province.md](../geoscape/Province.md) - Province country membership.
- [Region.md](../geoscape/Region.md) - Regional country grouping.
- [World.md](../geoscape/World.md) - World country composition.
- [Funding.md](../finance/Funding.md) - Country funding mechanics.
- [Score.md](../finance/Score.md) - Public score systems.
- [Monthly reports.md](../finance/Monthly%20reports.md) - Country reporting.
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic layer integration.
- [Mission.md](../lore/Mission.md) - Country-specific missions.

## References to Existing Games and Mechanics

- **Civilization Series**: Civilization diplomacy and relations
- **Europa Universalis**: Nation states and diplomatic relations
- **Crusader Kings**: Kingdom management and diplomacy
- **Hearts of Iron**: National governments and diplomacy
- **Victoria Series**: Nation states and international relations
- **Stellaris**: Empire diplomacy and relations
- **Endless Space**: Faction diplomacy and alliances
- **Galactic Civilizations**: Civilization diplomacy and trade
- **Total War Series**: Faction diplomacy and alliances
- **Warcraft III**: Faction alliances and diplomacy

