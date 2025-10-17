# add_supplier

Create or update supplier/vendor definitions in TOML format.

## Prefix
`supplier_`

## Task Type
Content Creation / Modification

## Description
Create or update supplier entries in `mods/core/economy/suppliers.toml`. Suppliers are factions or organizations that sell items with pricing policies, inventory, and relationship-based availability.

## Inputs

### Required
- **Supplier ID**: Unique identifier (e.g., `supplier_black_market`, `supplier_xcom_quartermaster`)
- **Supplier Name**: Display name for UI
- **Supplier Type**: Category - `faction`, `corporation`, `government`, `black_market`, `npc`
- **Description**: Supplier characteristics and inventory focus

### Optional
- **Inventory**: Items supplied
- **Price Modifiers**: Markup/discount rates
- **Reputation Requirements**: Relationship to access
- **Reliability**: Consistency of availability
- **Special Items**: Unique or exclusive inventory
- **Restrictions**: Who can buy from supplier

## Scope

### Affected Files
- `mods/core/economy/suppliers.toml`
- Related: `mods/core/economy/purchase_entries.toml` (items sold)
- Related: Faction definitions
- Related: Marketplace system

### Validation
- ✓ Supplier ID is unique
- ✓ All required TOML fields present
- ✓ Supplier type matches valid category
- ✓ Price modifier is positive number
- ✓ Reputation requirement is realistic (-1.0 to 1.0)
- ✓ Item references exist
- ✓ Faction references valid

## TOML Structure Template

```toml
[[suppliers]]
id = "supplier_id"
name = "Supplier Display Name"
description = "Description of supplier and their inventory"
supplier_type = "faction|corporation|government|black_market|npc"
faction_id = "faction_id"
tags = ["tag1", "tag2"]

[character]
representative_name = "Name of Supplier"
personality = "professional|shady|friendly|corporate"
reputation = 50
trustworthiness = 0.8

[inventory]
specialization = "weapons|armor|tech|supplies|mixed"
inventory_size = 100
item_categories = ["weapons", "ammunition"]
carries_illegal_items = false

[pricing]
price_markup_percent = 1.2
price_modifier = 1.0
bulk_discounts_available = true
loyalty_discount_percent = 0.1

[availability]
always_available = true
operational_hours = "24/7"
requires_travel = false
delivery_available = true
delivery_time_days = 1

[restrictions]
minimum_relation = 0.0
faction_restricted = []
technology_gated = []
one_time_access = false
access_restrictions = "none"

[reliability]
reliability_score = 0.9
restock_schedule = "weekly"
scarcity_events = false
quality_consistency = 0.95

[special_items]
exclusive_items = []
limited_availability_items = ["item_id"]
seasonal_items = []

[relationship]
affects_relation_on_purchase = false
relation_change_per_purchase = 0
reputation_change_per_purchase = 1
maximum_credit_available = 10000
```

## Outputs

### Created/Modified
- Supplier entry in TOML with complete specification
- Inventory focus and specialization defined
- Pricing and relationship mechanics configured
- Availability and reliability established
- Faction/organization connections made

### Validation Report
- ✓ TOML syntax verified
- ✓ Supplier ID uniqueness confirmed
- ✓ All items exist
- ✓ Faction exists (if applicable)
- ✓ Price modifier reasonable
- ✓ Relationship requirements realistic
- ✓ Inventory specialization coherent
- ✓ No conflicting availability rules

## Process

1. **Define Supplier Identity**: Establish type and character
2. **Determine Specialization**: Decide what items they sell
3. **Set Pricing**: Configure markup and discount rates
4. **Establish Relationships**: Set faction connections and reputation
5. **Configure Availability**: Determine access conditions
6. **Set Reliability**: Configure inventory consistency
7. **Validate**: Check TOML and economic balance
8. **Test**: Access supplier in-game and purchase items
9. **Document**: Update supplier documentation

## Testing Checklist

- [ ] Supplier loads without errors
- [ ] Supplier appears in marketplace
- [ ] Inventory displays correctly
- [ ] Prices apply with correct modifiers
- [ ] Relationship requirements enforce
- [ ] Availability conditions work
- [ ] Inventory restocks properly
- [ ] Discounts apply correctly
- [ ] Delivery works (if enabled)
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Supplier balances with economy
- [ ] Exclusive items work (if any)

## References

- API: `docs/economy/marketplace.md`
- Examples: `mods/core/economy/suppliers.toml`
- Balance Guide: `docs/economy/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
