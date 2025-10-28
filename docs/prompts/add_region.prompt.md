# add_region

Create or update region definitions in TOML format.

## Prefix
`region_`

## Task Type
Content Creation / Modification

## Description
Create or update region entries in `mods/core/geoscape/provinces.toml` or dedicated regions file. Regions are subdivisions of the geoscape with control, UFO activity, and mission generation properties.

## Inputs

### Required
- **Region ID**: Unique identifier (e.g., `region_north_america`, `region_central_asia`)
- **Region Name**: Display name for UI
- **Region Type**: Category - `continental`, `subcontinental`, `country`, `province`
- **Description**: Geographic and geopolitical characteristics

### Optional
- **Geographic Data**: Coordinates, terrain type, climate
- **Control**: Which country/faction controls region
- **Strategic Value**: Importance for missions and resources
- **UFO Activity**: Frequency and intensity of alien presence
- **Population**: Civilian population size
- **Resources**: Available resources and materials

## Scope

### Affected Files
- `mods/core/geoscape/provinces.toml`
- Related: `mods/core/geoscape/biomes.toml`
- Related: Country and faction definitions
- Related: Mission generation systems

### Validation
- ✓ Region ID is unique
- ✓ All required TOML fields present
- ✓ Region type matches valid category
- ✓ Coordinates are within world bounds
- ✓ Controlling country/faction exists
- ✓ UFO activity is reasonable (0-2.0 scale)
- ✓ Population is non-negative integer
- ✓ No overlapping region boundaries

## TOML Structure Template

```toml
[[regions]]
id = "region_id"
name = "Region Display Name"
description = "Description of region characteristics and location"
type = "continental|subcontinental|country|province"
category = "geography_type"
tags = ["tag1", "tag2"]

[geography]
latitude_start = 30
latitude_end = 50
longitude_start = -100
longitude_end = -70
terrain_type = "urban|rural|mountainous|desert|forest|ocean"
climate_zone = "tropical|temperate|polar"
area_km2 = 5000000

[control]
controlling_country = "country_id"
controlling_faction = "faction_id"
faction_presence = 0.3
control_stability = 0.9

[population]
population_total = 150000000
population_density = "urban|suburban|rural|sparse"
major_cities = ["city1", "city2"]
civilian_presence = true

[strategic]
strategic_importance = "critical|high|moderate|low"
resource_value = "high|medium|low"
research_value = "high|medium|low"
mission_frequency = "high|medium|low"

[ufo_activity]
ufo_sighting_frequency = 1.2
ufo_crash_rate = 0.5
alien_base_probability = 0.2
UFO_activity_trend = "increasing|stable|decreasing"

[resources]
rare_resources = ["resource_id"]
common_resources = ["resource_id"]
ancient_artifacts = true
alien_technology_remnants = false

[security]
military_presence = 0.7
air_defense = 0.6
militia_capability = 0.4
panic_level = 0.3

[missions]
available_mission_types = ["terror_defense", "ufo_crash"]
mission_availability = "common|rare|never"
terror_site_frequency = 0.8
```

## Outputs

### Created/Modified
- Region entry in TOML with geographic definition
- Control and faction affiliation set
- Strategic importance established
- UFO activity configured
- Population and resources defined

### Validation Report
- ✓ TOML syntax verified
- ✓ Region ID uniqueness confirmed
- ✓ Coordinates within world bounds
- ✓ No overlapping boundaries
- ✓ Controlling country/faction exist
- ✓ UFO activity reasonable
- ✓ Resources and missions valid
- ✓ No conflicts with existing regions

## Process

1. **Define Region Boundaries**: Set geographic coordinates
2. **Assign Control**: Determine controlling country/faction
3. **Set Strategic Value**: Establish importance level
4. **Configure UFO Activity**: Set alien presence frequency
5. **Add Population**: Define civilian population
6. **Assign Resources**: Identify available materials
7. **Configure Missions**: Set available mission types
8. **Validate**: Check TOML and geographic consistency
9. **Test**: Verify region appears in geoscape correctly
10. **Document**: Update region documentation

## Testing Checklist

- [ ] Region loads without errors
- [ ] Region visible in geoscape map
- [ ] Boundaries display correctly
- [ ] Control indicator correct
- [ ] UFO activity generates properly
- [ ] Missions available in region
- [ ] Resources accessible
- [ ] Population displays correctly
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Region balances with adjacent regions
- [ ] Strategic value affects gameplay

## References

- API: `docs/geoscape/`
- Examples: `mods/core/geoscape/provinces.toml`
- Balance Guide: `docs/geoscape/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
