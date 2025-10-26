# Country System API

> **Module**: `geoscape.country.country_manager` | **Status**: Core implementation | **Integrated Relations**: ✅

## Table of Contents

- [Overview](#overview)
- [Country Entity](#country-entity)
- [Relations System](#relations-system)
- [Functions](#functions)
- [TOML Schema](#toml-schema)
- [Integration Points](#integration-points)
- [Examples](#examples)

---

## Overview

The Country System manages all country definitions, diplomatic relationships, and economic interactions within the geoscape. Countries are geographical entities that exist on the world map and serve as the primary diplomatic and economic stakeholders. The system integrates comprehensive country state management with advanced diplomatic relations tracking.

**Key Responsibilities:**
- Load and manage country definitions from TOML
- Track country state (panic, funding levels, stability, morale)
- Manage diplomatic relations with history, trends, and time-based decay
- Calculate monthly funding based on GDP, funding level, and relations
- Generate country-specific missions
- Handle panic accumulation and country collapse mechanics
- Provide unified country and relations management

**Integrated Relations System:**
- Range: -100 (war) to +100 (allied)
- Thresholds: Allied (75+), Friendly (50-74), Positive (25-49), Neutral (-24-24), Negative (-49--25), Hostile (-74--50), War (-100--75)
- History tracking with trends (improving/declining/stable)
- Time-based decay and growth
- UI-ready color coding and labels

---

## Country Entity

### Country Definition

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| id | string | ✓ | Unique country identifier (lowercase, no spaces) |
| name | string | ✓ | Display name (e.g., "United States") |
| nation_type | enum | ✓ | MAJOR, SECONDARY, MINOR, SUPRANATIONAL |
| gdp | number | ✓ | Economic power (1-1000 scale) |
| military_power | number | ✓ | Military capability (1-10) |
| region | string | ✓ | Region identifier (e.g., "north_america") |
| capital_province | string | ✓ | Primary territory province ID |
| starting_relation | number | ✗ | Initial relationship (-50 to +50, default 0) |
| base_funding_level | number | ✗ | Default funding allocation (1-10, default 5) |
| funding_volatility | number | ✗ | How much funding fluctuates (0.0-1.0, default 0.5) |
| panic_threshold | number | ✗ | Panic level for collapse (default 100) |
| territories | string[] | ✓ | Array of province IDs under control |

### Country State (Runtime)

```lua
{
  id = "usa",
  name = "United States",

  -- Current dynamic properties
  relation = 25,              -- Current relation with player (-100 to +100)
  panic = 35,                 -- Population fear level (0-100+)
  funding_level = 6,          -- Current budget allocation (1-10)
  stability = 75,             -- Political stability (0-100)
  military_readiness = 80,    -- Defense preparedness (0-100)
  morale = 65,                -- Public support (0-100)

  -- History and tracking
  last_mission_date = 1234,   -- Turn number of last mission
  missions_completed = 12,    -- Total missions completed
  missions_failed = 2,        -- Total mission failures
  ufos_defeated = 5,          -- UFOs destroyed in territory
  bases_raided = 1,           -- Enemy bases in territory

  -- Events and status
  is_collapsed = false,       -- Country surrendered to aliens
  is_at_war = false,          -- Active war declaration
  active_crises = {},         -- Array of active crisis IDs

  -- Definition reference
  definition = {...}          -- Reference to definition table
}
```

---

## Relations System

The Country System includes an integrated diplomatic relations system that tracks player relationships with each country. Relations affect funding levels, mission availability, and game difficulty.

### Relation Values & Thresholds

| Range | Label | Color (RGB) | Description |
|-------|-------|-------------|-------------|
| 75-100 | Allied | (0, 200, 0) | Strategic partnership, maximum funding |
| 50-74 | Friendly | (0, 150, 0) | Cooperative relationship, high funding |
| 25-49 | Positive | (0, 100, 0) | Good relations, standard funding |
| -24-24 | Neutral | (150, 150, 150) | Balanced relationship, base funding |
| -49--25 | Negative | (200, 100, 0) | Strained relations, reduced funding |
| -74--50 | Hostile | (200, 50, 0) | Adversarial, minimal funding |
| -100--75 | War | (255, 0, 0) | Active conflict, no funding |

### Relation Entry Structure

```lua
RelationEntry = {
  value = 25,                    -- Current relation (-100 to +100)
  history = {                    -- Recent changes (last 20)
    {delta = 5, reason = "Mission success", timestamp = 1234567890},
    {delta = -2, reason = "Civilian casualties", timestamp = 1234567880}
  },
  trend = "improving"            -- "improving", "declining", "stable"
}
```

### Time-Based Decay & Growth

Relations naturally decay or grow over time:
- **Positive relations** slowly decay towards neutral
- **Negative relations** gradually improve towards neutral
- Decay rate: ~1 point per 100 days for ±100 relations
- Growth rate: ~0.5 points per 100 days for negative relations

### Relation History & Trends

The system tracks recent changes to determine trends:
- **Improving**: Average delta > +0.5 over last 5 changes
- **Declining**: Average delta < -0.5 over last 5 changes
- **Stable**: Average delta between -0.5 and +0.5

---

## Functions

### CountryManager.new()
Create a new country manager instance.

```lua
local CountryManager = require("geoscape.country.country_manager")
local manager = CountryManager.new()
```

**Returns:**
- `table` - New manager instance

---

### CountryManager:init(countries_table)
Initialize manager with country definitions from TOML.

```lua
manager:init(countryDefinitions)
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| countries_table | table | Array of country definitions (from TOML load) |

**Returns:**
- `boolean` - True if successful
- `string` - Error message if failed

**Side Effects:**
- Initializes all countries in manager
- Creates runtime state for each country
- Integrates with RelationsManager
- Loads country-specific configuration

---

### CountryManager:getCountry(country_id)
Retrieve a country by ID.

```lua
local country = manager:getCountry("usa")
if country then
  print("Country: " .. country.name)
  print("Relation: " .. country.relation)
end
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| country_id | string | Country identifier |

**Returns:**
- `table` - Country state object
- `nil` - If country not found

---

### CountryManager:getAllCountries()
Get all loaded countries.

```lua
local countries = manager:getAllCountries()
for _, country in ipairs(countries) do
  print(country.name .. ": panic=" .. country.panic)
end
```

**Returns:**
- `table` - Array of all country state objects

---

### CountryManager:getCountriesByType(nation_type)
Get countries by classification.

```lua
local majors = manager:getCountriesByType("MAJOR")
local minors = manager:getCountriesByType("MINOR")
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| nation_type | string | MAJOR, SECONDARY, MINOR, SUPRANATIONAL |

**Returns:**
- `table` - Array of matching countries

---

### CountryManager:getCountriesByRegion(region_id)
Get countries in a region.

```lua
local asia = manager:getCountriesByRegion("asia_pacific")
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| region_id | string | Region identifier |

**Returns:**
- `table` - Array of countries in region

---

### CountryManager:updateCountryState(country_id, updates)
Update country runtime state.

```lua
manager:updateCountryState("usa", {
  panic = 45,
  funding_level = 7,
  morale = 80
})
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| country_id | string | Country identifier |
| updates | table | Properties to update |

**Returns:**
- `boolean` - True if successful

**Valid Properties:**
- `panic` - Panic level (0-100+)
- `funding_level` - Budget allocation (1-10)
- `stability` - Political stability (0-100)
- `military_readiness` - Defense readiness (0-100)
- `morale` - Public support (0-100)

---

### CountryManager:calculateFunding(country_id)
Calculate monthly funding for a country.

```lua
local funding = manager:calculateFunding("usa")
print("Monthly income: " .. funding .. " credits")
```

**Formula:**
```
funding = gdp × funding_level × (0.5 + relation/100 × 0.5)
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| country_id | string | Country identifier |

**Returns:**
- `number` - Monthly funding amount

---

### CountryManager:getTotalFunding()
Get total funding from all countries.

```lua
local total = manager:getTotalFunding()
print("Total monthly income: " .. total .. " credits")
```

**Returns:**
- `number` - Sum of all country funding

---

### CountryManager:modifyPanic(country_id, delta, reason)
Add or subtract panic for a country.

```lua
manager:modifyPanic("usa", 12, "Terror mission completed")
manager:modifyPanic("usa", -1, "Monthly decay (no alien activity)")
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| country_id | string | Country identifier |
|delta | number | Panic change (positive or negative) |
| reason | string | Reason for change (logging) |

**Returns:**
- `number` - New panic level
- `boolean` - True if country collapsed (panic > threshold)

**Effects:**
- Panic clamped to 0-100+ range
- Collapse triggered automatically if > threshold
- RelationsManager notified of major changes

---

### CountryManager:checkCountryCollapse(country_id)
Check and handle country collapse.

```lua
if manager:checkCountryCollapse("usa") then
  print("USA has fallen to alien forces!")
end
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| country_id | string | Country identifier |

**Returns:**
- `boolean` - True if country collapsed this check

**Side Effects:**
- Sets `is_collapsed` flag
- Stops all funding
- Switches missions to liberation/evacuation
- Notifies RelationsManager (-10 to all other countries)
- Generates alien base in territory

---

### CountryManager:updateDailyState(days_passed)
Update all countries based on time passage.

```lua
manager:updateDailyState(7)  -- Weekly update
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| days_passed | number | Days elapsed since last update |

**Updates:**
- Panic decay (-1 per day without alien activity)
- Stability changes based on events
- Morale shifts (funding, victories, defeats)
- Military readiness decay (inactivity)

---

### CountryManager:getCountriesByRelation(min_relation, max_relation)
Get countries within a relation range.

```lua
local allies = manager:getCountriesByRelation(50, 100)     -- Allied
local enemies = manager:getCountriesByRelation(-100, -50)  -- Hostile
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| min_relation | number | Minimum relation (-100 to +100) |
| max_relation | number | Maximum relation (-100 to +100) |

**Returns:**
- `table` - Array of countries in relation range

---

### CountryManager:getCountryStatus(country_id)
Get comprehensive status report for a country.

```lua
local status = manager:getCountryStatus("usa")
print(status.name .. ": " .. status.status_label)
```

**Returns:**
- `table` - Status object:
  ```lua
  {
    id = "usa",
    name = "United States",
    status_label = "Friendly",        -- Relation label
    relation = 65,
    relation_trend = "improving",     -- "improving", "declining", "stable"
    relation_color = {0, 150, 0},     -- RGB color for UI
    panic = 35,
    panic_label = "Moderate",
    funding = 375,                     -- Monthly amount
    funding_level = 6,
    stability = 75,
    morale = 80,
    military_readiness = 85,
    is_collapsed = false,
    is_at_war = false,
    crisis_count = 0
  }
  ```

---

### CountryManager:serialize()
Save all country state to table.

```lua
local saveData = manager:serialize()
-- Save to disk...
```

**Returns:**
- `table` - Serialized country data

---

### CountryManager:getRelation(country_id)
Get current diplomatic relation with a country.

```lua
local relation = manager:getRelation("usa")
print("USA relation: " .. relation)  -- e.g., 25
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| country_id | string | Country identifier |

**Returns:**
- `number` - Relation value (-100 to +100)
- `nil` - If country not found

---

### CountryManager:setRelation(country_id, value, reason)
Set diplomatic relation to an exact value.

```lua
manager:setRelation("usa", 50, "Diplomatic treaty signed")
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| country_id | string | Country identifier |
| value | number | Target relation (-100 to +100) |
| reason | string | Reason for change (for logging) |

**Returns:**
- `number` - New relation value

---

### CountryManager:modifyRelation(country_id, delta, reason)
Modify diplomatic relation by a delta amount.

```lua
manager:modifyRelation("usa", 5, "Successful mission")
manager:modifyRelation("usa", -10, "Civilian casualties")
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| country_id | string | Country identifier |
| delta | number | Change amount |
| reason | string | Reason for change (for logging) |

**Returns:**
- `number` - New relation value

---

### CountryManager:getRelationLabel(value)
Get descriptive label for a relation value.

```lua
local label = manager:getRelationLabel(75)
print(label)  -- "Allied"
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| value | number | Relation value |

**Returns:**
- `string` - Descriptive label

---

### CountryManager:getRelationColor(value)
Get UI color for a relation value.

```lua
local color = manager:getRelationColor(75)
-- color = {0, 200, 0} (green for allied)
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| value | number | Relation value |

**Returns:**
- `table` - RGB color {r, g, b}

---

### CountryManager:getRelationHistory(country_id, maxEntries)
Get recent relation change history.

```lua
local history = manager:getRelationHistory("usa", 5)
for _, entry in ipairs(history) do
  print(string.format("%+d: %s", entry.delta, entry.reason))
end
```

**Parameters:**
| Parameter | Type | Description |
|---|---|---|
| country_id | string | Country identifier |
| maxEntries | number | Maximum entries to return (default 10) |

**Returns:**
- `table` - Array of {delta, reason, timestamp}

---

## TOML Schema

### Countries File: `mods/core/rules/country/countries.toml`

```toml
# Country definitions for AlienFall

[countries.usa]
id = "usa"
name = "United States"
nation_type = "MAJOR"
gdp = 100
military_power = 10
region = "north_america"
capital_province = "usa_central"
starting_relation = 20
base_funding_level = 6
funding_volatility = 0.4
territories = [
  "usa_west",
  "usa_central",
  "usa_east",
  "mexico_north"
]

[countries.germany]
id = "germany"
name = "Germany"
nation_type = "SECONDARY"
gdp = 50
military_power = 7
region = "europe"
capital_province = "germany_central"
starting_relation = 10
base_funding_level = 5
territories = [
  "germany_north",
  "germany_central",
  "germany_south"
]

[countries.japan]
id = "japan"
name = "Japan"
nation_type = "SECONDARY"
gdp = 55
military_power = 8
region = "asia_pacific"
capital_province = "japan_main"
starting_relation = 15
base_funding_level = 6
territories = [
  "japan_honshu",
  "japan_hokkaido",
  "japan_kyushu"
]
```

### Schema Details

| Field | Type | Validation | Notes |
|-------|------|-----------|-------|
| id | string | Lowercase, no spaces | Unique identifier |
| name | string | 1-100 chars | Display name |
| nation_type | string | MAJOR\|SECONDARY\|MINOR\|SUPRANATIONAL | Classification |
| gdp | number | 1-1000 | Economic scale |
| military_power | number | 1-10 | Military strength |
| region | string | Valid region ID | Geographic area |
| capital_province | string | Valid province ID | Primary territory |
| starting_relation | number | -50 to +50 | Initial diplomacy |
| base_funding_level | number | 1-10 | Default budget |
| funding_volatility | number | 0.0-1.0 | Fluctuation amount |
| territories | string[] | Valid province IDs | Controlled areas |

---

## Integration Points

### RelationsManager Integration

Countries automatically register with RelationsManager:

```lua
-- Automatic registration
manager:initializeEntities(countryIds, supplierIds, factionIds)

-- Modify through relations
RelationsManager:modifyRelation("country", "usa", 5, "Mission success")
```

### Funding Manager Integration

Countries provide funding through economy system:

```lua
local totalFunding = manager:getTotalFunding()
-- Applied to monthly income
```

### Mission Manager Integration

Countries generate missions:

```lua
local missions = MissionManager:generateCountryMissions(country_id)
-- Frequency based on relation, panic, nation type
```

### Geoscape Integration

Countries are displayed on geoscape:

```lua
local countryInfo = manager:getCountriesByRegion("north_america")
-- Render panic level, funding status, relation indicator
```

---

## Examples

### Example 1: Check Country Status

```lua
local CountryManager = require("geoscape.country.country_manager")
local manager = CountryManager.new()
manager:init(countryDefs)

local usa = manager:getCountry("usa")
if usa.panic > 75 then
  print("[WARNING] USA panic critical: " .. usa.panic)
end

if usa.relation < -50 then
  print("[ALERT] USA is hostile!")
end

local funding = manager:calculateFunding("usa")
print("Monthly from USA: " .. funding .. " credits")
```

### Example 2: Handle Mission Outcome

```lua
-- Mission completed successfully in USA territory
manager:modifyPanic("usa", -2, "Successful defense mission")

-- Add relation bonus
RelationsManager:modifyRelation("country", "usa", 3, "Mission success")

-- Update funding if needed
local oldLevel = manager:getCountry("usa").funding_level
manager:updateCountryState("usa", {funding_level = 6})
local newFunding = manager:calculateFunding("usa")
print("USA funding increased by " .. (newFunding - oldFunding) .. " credits")
```

### Example 3: Monitor All Countries

```lua
local function printCountryReport()
  local countries = manager:getAllCountries()
  local total = 0

  for _, country in ipairs(countries) do
    if not country.is_collapsed then
      local funding = manager:calculateFunding(country.id)
      total = total + funding
      print(string.format("%s: relation=%d, panic=%d, funding=%d",
        country.name, country.relation, country.panic, funding))
    end
  end

  print("Total monthly funding: " .. total)
end
```

### Example 4: Regional Status

```lua
local function checkRegionalStability(region_id)
  local countries = manager:getCountriesByRegion(region_id)
  local avg_panic = 0
  local avg_relation = 0

  for _, country in ipairs(countries) do
    avg_panic = avg_panic + country.panic
    avg_relation = avg_relation + country.relation
  end

  avg_panic = avg_panic / #countries
  avg_relation = avg_relation / #countries

  return {
    region = region_id,
    avg_panic = avg_panic,
    avg_relation = avg_relation,
    stable = avg_panic < 50 and avg_relation > 0
  }
end
```

---

## See Also

- [design/mechanics/Countries.md](../../design/mechanics/Countries.md) - Game design documentation
- [api/GEOSCAPE.md](GEOSCAPE.md) - Geoscape system API
- [engine/geoscape/country/](../../engine/geoscape/country/) - Implementation
