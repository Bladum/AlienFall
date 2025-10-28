# add_world

Create or update world definition for geoscape in TOML format.

## Prefix
`world_`

## Task Type
Content Creation / Modification

## Description
Create or update world entry in `mods/core/geoscape/world.toml`. The world defines the strategic map including continents, regions, climate zones, and initial geopolitical state.

## Inputs

### Required
- **World Configuration**: Global map parameters and scale
- **Continents**: Continental layout and boundaries
- **Climate Zones**: Temperature and weather patterns
- **Initial State**: Starting geopolitical situation

### Optional
- **Resource Distribution**: Where key resources are located
- **Faction Territories**: Initial territorial control
- **Strategic Points**: Important locations
- **Anomalies**: Special world features

## Scope

### Affected Files
- `mods/core/geoscape/world.toml`
- Related: `mods/core/geoscape/provinces.toml`
- Related: `mods/core/geoscape/biomes.toml`
- Related: Faction and country definitions

### Validation
- ✓ World configuration complete
- ✓ Grid dimensions are valid positive integers
- ✓ All referenced continents/regions exist
- ✓ Climate zones are valid
- ✓ No overlapping territory definitions
- ✓ Faction territories are specified
- ✓ Strategic points are within bounds

## TOML Structure Template

```toml
[world]
name = "World Display Name"
description = "Description of world and setting"
size = "large"  # small|medium|large
map_width = 180  # degrees longitude
map_height = 90   # degrees latitude

[climate]
climate_zones = ["tropical", "temperate", "polar"]
weather_system = "dynamic|static|seasonal"
temperature_variance = 1.0

[continents]
north_america = {x = -100, y = 45, width = 40, height = 30}
south_america = {x = -65, y = -15, width = 35, height = 45}
europe = {x = 10, y = 50, width = 40, height = 25}
africa = {x = 20, y = 0, width = 50, height = 40}
asia = {x = 90, y = 30, width = 70, height = 50}
australia = {x = 135, y = -25, width = 25, height = 20}

[initial_state]
dominant_factions = ["faction_id"]
conflict_regions = ["region_name"]
technology_level = "modern|advanced|militaristic"
population_distribution = "concentrated|dispersed"

[resources]
rare_resources = {tech_alloys = "asia", ancient_artifacts = "africa"}
trade_routes = ["asia_to_europe", "europe_to_americas"]

[strategic_points]
key_cities = ["New York", "London", "Tokyo"]
military_bases = ["Fort Hood", "RAF Lakenheath"]
research_centers = ["CERN", "MIT"]

[playable_area]
playable = true
accessible_sea = true
underground_access = false
polar_regions = true
```

## Outputs

### Created/Modified
- World definition with proper geographic scale
- Continent placement validated
- Climate zones assigned
- Initial geopolitical state configured
- Strategic locations marked

### Validation Report
- ✓ TOML syntax verified
- ✓ World configuration complete
- ✓ Grid dimensions valid
- ✓ Continents don't overlap
- ✓ All regions within bounds
- ✓ Climate zones valid
- ✓ Strategic points accessible

## Process

1. **Define World Scale**: Establish map dimensions
2. **Place Continents**: Position major landmasses
3. **Assign Climate**: Determine climate zones per region
4. **Configure State**: Set initial faction control
5. **Mark Resources**: Identify rare resource locations
6. **Add Strategic Points**: Mark important locations
7. **Validate**: Check TOML and geographic consistency
8. **Test**: Load world in geoscape and verify geography
9. **Document**: Update world documentation

## Testing Checklist

- [ ] World loads without errors
- [ ] Map displays correctly in geoscape
- [ ] All continents visible and accessible
- [ ] Climate zones display properly
- [ ] Faction territories correct
- [ ] Strategic points visible and accessible
- [ ] No geographic conflicts
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Missions can be deployed to all regions

## References

- API: `docs/geoscape/`
- Examples: `mods/core/geoscape/world.toml`
- Balance Guide: `docs/geoscape/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
