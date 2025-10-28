# add_purchase

Create or update marketplace purchase order definitions in TOML format.

## Prefix
`purchase_`

## Task Type
Content Creation / Modification

## Description
Create or update purchase entries in `mods/core/economy/purchase_entries.toml`. Purchases are items available to buy from suppliers with pricing, availability, and restrictions.

## Inputs

### Required
- **Purchase ID**: Unique identifier (e.g., `purchase_rifle_ammo`, `purchase_medkit`)
- **Item ID**: What item is being purchased
- **Supplier**: Which supplier/faction sells this
- **Purchase Price**: Cost to player

### Optional
- **Availability**: How often item is available
- **Quantity Limit**: Max per order
- **Frequency**: How often restocked
- **Faction Restrictions**: Which factions can buy
- **Technology Requirements**: Tech needed to purchase
- **Relation Requirements**: Faction relationship needed

## Scope

### Affected Files
- `mods/core/economy/purchase_entries.toml`
- Related: `mods/core/economy/suppliers.toml`
- Related: Item definitions
- Related: Faction definitions

### Validation
- ✓ Purchase ID is unique
- ✓ Item referenced exists
- ✓ Supplier exists
- ✓ Price is positive number
- ✓ Availability is valid category
- ✓ Quantity limit is positive
- ✓ Technology requirements exist
- ✓ Faction restrictions valid

## TOML Structure Template

```toml
[[purchases]]
id = "purchase_id"
name = "Purchase Display Name"
description = "Description of purchase availability and pricing"
item_id = "item_id"
supplier_id = "supplier_id"
tags = ["tag1", "tag2"]

[pricing]
price_per_unit = 500
price_currency = "cash"
price_modifier = 1.0
bulk_discount_available = false
bulk_discount_percent = 0.1

[availability]
availability = "common|rare|limited|seasonal|unique"
restock_frequency = "daily|weekly|monthly"
restock_quantity = 10
max_quantity_per_order = 5
total_available = -1  # -1 = unlimited

[restrictions]
minimum_organization_level = 1
minimum_relation_threshold = 0.5
required_technology = []
faction_restricted = []
location_restricted = []

[conditions]
purchase_cooldown_days = 0
one_time_purchase = false
delivery_time_days = 1
delivery_location = "base|geoscape"

[military_value]
strategic_importance = "critical|important|useful|cosmetic"
legal_status = "legal|restricted|black_market"
```

## Outputs

### Created/Modified
- Purchase entry in TOML with complete specification
- Price set appropriately for item value
- Availability and restrictions configured
- Supplier linked properly

### Validation Report
- ✓ TOML syntax verified
- ✓ Purchase ID uniqueness confirmed
- ✓ Item exists
- ✓ Supplier exists
- ✓ Price reasonable
- ✓ Availability valid
- ✓ Quantity limits sensible
- ✓ Restrictions achievable

## Process

1. **Select Item**: Determine what's being purchased
2. **Choose Supplier**: Select supplier/faction
3. **Set Price**: Balance with item value and availability
4. **Configure Availability**: Determine frequency and limits
5. **Set Restrictions**: Establish requirements
6. **Validate**: Check TOML and economic balance
7. **Test**: Purchase item in-game and verify
8. **Document**: Update marketplace documentation

## Testing Checklist

- [ ] Purchase loads without errors
- [ ] Item appears in marketplace
- [ ] Price correct and deducted properly
- [ ] Availability restrictions work
- [ ] Quantity limits enforce
- [ ] Technology gates purchase
- [ ] Relation requirement enforces
- [ ] Item delivered to inventory
- [ ] Restock frequency works
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Price balances with economy

## References

- API: `docs/economy/marketplace.md`
- Examples: `mods/core/economy/purchase_entries.toml`
- Balance Guide: `docs/economy/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
