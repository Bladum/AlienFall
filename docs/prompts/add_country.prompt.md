# add_country

Create or update country/nation definitions in TOML format.

## Prefix
`country_`

## Task Type
Content Creation / Modification

## Description
Create or update country entries in `mods/core/geoscape/provinces.toml` or dedicated countries file. Countries represent geopolitical entities with funding, military capability, political alignment, and diplomatic relationships.

## Inputs

### Required
- **Country ID**: Unique identifier (e.g., `country_usa`, `country_china`)
- **Country Name**: Display name for UI
- **Government Type**: Category - `democracy`, `autocracy`, `military`, `coalition`, `corporate`
- **Description**: Country characteristics and role

### Optional
- **Funding**: Financial contribution to player organization
- **Military Capability**: Armed forces strength
- **Political Alignment**: Relationship tendencies
- **Territory**: Geographic regions controlled
- **Technology Level**: Current technology tier
- **Relationship Modifiers**: How easily relationships change

## Scope

### Affected Files
- `mods/core/geoscape/provinces.toml` (province-country mapping)
- `mods/core/geoscape/` (dedicated countries file if created)
- Related: `mods/core/factions/`
- Related: Diplomacy and politics systems

### Validation
- ✓ Country ID is unique
- ✓ All required TOML fields present
- ✓ Government type matches valid category
- ✓ Funding value is reasonable
- ✓ Territory regions exist
- ✓ Relationship references point to valid countries
- ✓ Technology level is valid
- ✓ No negative funding or stats

## TOML Structure Template

```toml
[[countries]]
id = "country_id"
name = "Country Display Name"
description = "Description of country characteristics and role"
government = "democracy|autocracy|military|coalition|corporate"
alignment = "pro_human|neutral|pro_alien|militant"
tags = ["tag1", "tag2"]

[military]
military_strength = 75
air_force_strength = 60
naval_strength = 70
technology_level = "modern|advanced|militaristic"
available_soldiers = 100
military_bases = 5

[economy]
funding_per_month = 10000
funding_consistency = "reliable|variable|unpredictable"
gdp_modifier = 1.0
trade_value = 100
industrial_capacity = "low|medium|high"

[government]
stability = 0.8
corruption_level = 0.2
military_spending = 0.25
research_spending = 0.10
public_morale = 0.7

[territory]
regions = ["region_id"]
population = 300000000
primary_language = "english"
primary_religion = "secular|religious|mixed"

[technology]
current_tech_level = "modern"
research_capability = "low|medium|high"
alien_contact_knowledge = false
artifact_possession = false

[relationships]
relationship_with = {country_id = "friendly|neutral|hostile"}
alliance_members = ["country_id"]
trade_partners = ["country_id"]
past_conflicts = ["country_id"]

[diplomacy]
diplomatic_reputation = 50
treaty_obligations = ["treaty_id"]
support_threshold = 0.7
change_rate = 0.05

[strategic]
strategic_value = "critical|important|moderate|minimal"
ufosightings_frequency = "rare|uncommon|common"
alien_activity_level = 1.0
```

## Outputs

### Created/Modified
- Country entry in TOML with complete definition
- Military and economic stats balanced
- Territory properly mapped
- Diplomatic relationships configured
- Technology level appropriate

### Validation Report
- ✓ TOML syntax verified
- ✓ Country ID uniqueness confirmed
- ✓ All territory regions exist
- ✓ Relationships with valid countries
- ✓ Military/economy stats balanced
- ✓ Technology levels consistent
- ✓ No impossible configurations

## Process

1. **Define Country Identity**: Establish government type and alignment
2. **Configure Military**: Set armed forces strength
3. **Set Economy**: Determine funding and resources
4. **Assign Territory**: Map regions the country controls
5. **Establish Relationships**: Set diplomatic stance with other countries
6. **Configure Technology**: Set current tech level and capabilities
7. **Validate**: Check TOML and cross-references
8. **Test**: Verify country appears in geoscape and diplomacy systems
9. **Document**: Update country documentation

## Testing Checklist

- [ ] Country loads without errors
- [ ] Country visible in geoscape
- [ ] Territory displays correctly
- [ ] Funding generates properly
- [ ] Military strength affects gameplay
- [ ] Diplomatic relationships work
- [ ] Technology level affects interactions
- [ ] All regions assigned exist
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Country balances with other countries

## References

- API: `docs/geoscape/` and `docs/politics/`
- Examples: `mods/core/geoscape/provinces.toml`
- Balance Guide: `docs/politics/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
