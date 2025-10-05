# Relationship

## Overview
Relationships represent the player's standing with various entities in the game world, including suppliers, countries, and factions. These relationships dynamically affect marketplace pricing, funding levels, and mission availability, creating strategic trade-offs in diplomatic management.

## Mechanics
- **Relationship Levels**: Range from Very Bad to Very Good
- **Supplier Relations**: Affect marketplace prices (200% to 50% of base price)
- **Country Relations**: Impact monthly funding changes (-2 to +2 levels)
- **Faction Relations**: Control mission frequency (200% for bad relations, 0% for good)
- **Dynamic Changes**: Relationships shift based on player actions and events
- **Diplomatic Actions**: Players can invest resources to improve relationships

## Examples
| Entity | Level | Supplier Price | Country Funding | Faction Missions |
|--------|-------|---------------|----------------|------------------|
| Supplier | Very Good | 50% | N/A | N/A |
| Supplier | Neutral | 100% | N/A | N/A |
| Supplier | Very Bad | 200% | N/A | N/A |
| Country | Very Good | N/A | +2/month | N/A |
| Country | Neutral | N/A | 0/month | N/A |
| Country | Very Bad | N/A | -2/month | N/A |
| Faction | Very Good | N/A | N/A | 0% missions |
| Faction | Neutral | N/A | N/A | 100% missions |
| Faction | Very Bad | N/A | N/A | 200% missions |

## References
- XCOM: Council funding and panic systems
- Civilization: Diplomatic relations and trade bonuses
- See Diplomacy for relationship management
- See Marketplace Management for pricing impacts