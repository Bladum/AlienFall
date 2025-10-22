# Politics API Reference

**System:** Strategic Layer (Diplomacy, Factions & International Relations)  
**Module:** `engine/politics/` and `engine/geoscape/politics/`  
**Latest Update:** October 22, 2025  
**Status:** ✅ Complete

---

## Overview

The Politics system manages international relations, factions, diplomatic reputation, trade agreements, country funding, and hidden moral alignment tracking. It tracks political influence through relationships, voting power, territorial control, and ideological alignment. Countries support or abandon the player based on funding, mission success, political alignment, and global events. Factions compete for global influence and player allegiance. Fame and Karma systems create emergent gameplay with visible (fame) and hidden (karma) mechanics affecting opportunities and endings.

**Layer Classification:** Strategic / Diplomacy  
**Primary Responsibility:** Country relationships, faction management, diplomatic agreements, voting influence, funding allocation, trade agreements, political consequences, territory control, marketplace supply, fame tracking, karma alignment  
**Integration Points:** Geoscape (country territory, UFO attacks), Missions (success/failure, casualties), Finance (funding requests/payments), Research (technology sharing), Recruitment (karma gates), Story (ending determination)

---

## Implementation Status

### IN DESIGN (Exists in engine/politics/)
- Country management system with relations, funding, and support levels
- Faction system with influence, reputation, and alliances
- Political events and consequences processing
- Relationship tracking with trust, resentment, and happiness
- Mission outcome effects on diplomacy
- Trade agreements and supplier partnerships
- Voting weight system for coalition decisions
- Fame system with public reputation tiers and bonuses
- Karma system with hidden moral alignment and story gating
- Monthly funding calculations and country withdrawal mechanics

### FUTURE IDEAS (Not in engine/politics/)
- Dynamic faction rivalries and power shifts
- Advanced diplomatic negotiations and treaties
- International conferences and voting mechanics
- Espionage and covert operations
- Cultural exchange programs and soft power
- Economic sanctions and trade embargoes
- Refugee crises and humanitarian missions
- Media campaigns and propaganda systems
- Political scandals and corruption mechanics

---

## Core Entities

### Entity: Country

Nation-state with political influence, funding capability, regional control, and diplomatic relationships.

**Properties:**
```lua
Country = {
  id = string,                    -- "usa", "russia", "china"
  name = string,
  description = string,
  
  -- Geopolitics
  regions = string[],             -- Controlled region IDs
  owner_faction = string | nil,   -- Controlling faction (if any)
  
  -- Political State
  alignment = string,             -- "military", "scientific", "economical", "neutral"
  government_type = string,       -- "democracy", "dictatorship", "theocracy"
  leader = string,                -- Current leader name
  
  -- Support & Satisfaction
  monthly_funding = number,       -- Credits per month
  support_level = number,         -- 0-100 (satisfaction)
  panic_level = number,           -- 0-100 (fear/anxiety)
  happiness = number,             -- -100 to +100 (contentment)
  
  -- Relations
  relations = number,             -- -100 to +100 with player org
  status = string,                -- "ally", "neutral", "hostile"
  trust = number,                 -- -100 to +100 (confidence)
  resentment = number,            -- -100 to +100 (anger/gratitude)
  
  -- Funding Dynamics
  funding_requested = number,     -- Amount demanded each month
  funding_level = number,         -- 0-10 scale
  accumulated_funding = number,   -- Total contributed this month
  will_leave = boolean,           -- About to withdraw support
  has_left = boolean,             -- No longer in coalition
  
  -- Political Influence
  faction_alignment = table,      -- {faction_id: influence_level}
  military_strength = number,     -- Defensive capability (0-100)
  research_level = number,        -- Tech advancement (0-100)
  
  -- Activity & Threat
  active_missions_count = number, -- UFO activity level
  threat_assessment = number,     -- 0-10 estimated danger
  
  -- Marketplace
  available_supplies = ItemType[], -- Items this country can provide
  supplier_id = string | nil,    -- Associated supplier
  has_trade_agreement = bool,    -- Active trade route?
  
  -- Mission History
  successful_missions = number,
  failed_missions = number,
  civilians_protected = number,
  civilians_lost = number,
  
  -- Voting Power
  voting_weight = number,         -- 0-100 (influence in coalition decisions)
  has_voting_power = bool,        -- Weight > 25?
  is_influential = bool,          -- Weight > 50?
  
  -- Status
  is_active = bool,              -- Currently involved in game?
  last_contact_turn = number,    -- When player last interacted
}
```

**Functions:**
```lua
-- Retrieval
Country.getCountry(country_id: string) → Country | nil
Country.getCountries() → Country[]
Country.getCountriesByRegion(region: string) → Country[]
Country.getActiveCountries() → Country[]

-- Status queries
country:getName() → string
country:getRelations() → number
country:getStatus() → string  -- "ally", "neutral", "hostile"
country:getFunding() → number
country:getFundingLevel() → number
country:getSupportLevel() → number
country:getPanicLevel() → number
country:getHappiness() → number
country:isActive() → boolean

-- Relations
country:getTrust() → number
country:getRese ntment() → number
country:isAboutToLeave() → boolean
country:canTrade() → bool  -- Relations > -50?
country:canFund() → bool    -- Relations > -75?

-- Funding system
country:setFundingLevel(level: number) → bool
country:monthlyUpdate() → number  -- Returns funding received
country:getMonthlyRate() → number  -- Funding per level point
country:updateRelations(delta: number) → void
country:setRelations(value: number) → void

-- Faction alignment
country:getFactionAlignment(faction_id: string) → number
country:getPreferredFaction() → Faction
country:getAlignmentType() → string

-- Supply & Trade
country:getSupplies() → ItemType[]
country:canSupply(itemId: string) → bool
country:createTradeAgreement() → Agreement
country:hasTradeAgreement() → bool
country:getTradeCost(itemId: string) → number

-- Influence
country:getVotingWeight() → number  -- 0-100
country:hasVotingPower() → bool
country:isInfluential() → bool

-- Statistics
country:getMissionStats() → {successful, failed, civilians_protected, civilians_lost}
country:getActiveMissions() → number
country:getThreatLevel() → number  -- 0-10
country:getPopulation() → number
country:getRegions() → string[]
```

---

### Entity: Faction

Political, ideological, or military power bloc competing for global influence and player allegiance.

**Properties:**
```lua
Faction = {
  id = string,                    -- "xe_alliance", "corporate_bloc"
  name = string,                  -- Display name
  type = string,                  -- "military", "scientific", "economic", "alien"
  
  -- Ideology
  alignment = string,             -- "aggressive", "defensive", "diplomatic"
  goals = string[],               -- Strategic objectives
  
  -- Influence & Power
  global_influence = number,      -- 0-100
  influence_level = number,       -- 0-10
  allied_countries = Country[],   -- Supporters
  member_factions = Faction[],    -- Sub-factions
  supported_countries = string[], -- Aligned country IDs
  
  -- Relations with entities
  relationships = table,          -- {faction_id: relationship_level}
  player_reputation = number,     -- -100 to +100 with faction
  
  -- Military & Research
  military_power = number,        -- Combat effectiveness
  research_level = number,        -- Tech advancement
  
  -- Resources
  monthly_budget = number,
  current_funding = number,       -- Total resources
  
  -- Player Relations
  reputation = number,            -- -100 to +100 with player
  mission_count = number,         -- Missions done for faction
}
```

**Functions:**
```lua
-- Retrieval
Faction.getFaction(faction_id: string) → Faction | nil
Faction.getFactions() → Faction[]
Faction.getFactionsByType(type: string) → Faction[]

-- Status
faction:getName() → string
faction:getInfluence() → number
faction:getReputation() → number
faction:getPlayerReputation() → number
faction:isAlly(other_faction: Faction) → boolean
faction:isEnemy(other_faction: Faction) → boolean

-- Relations
faction:getRelationship(other_faction: Faction) → number
faction:getAlliedCountries() → Country[]
faction:getEnemyFactions() → Faction[]
faction:getSupportedCountries() → string[]
```

---

### Entity: PoliticalEvent

Event triggered by political changes, mission outcomes, or diplomatic decisions with widespread consequences.

**Properties:**
```lua
PoliticalEvent = {
  id = string,                    -- "event_country_leaves_001"
  type = string,                  -- "country_leaves", "faction_rivalry", "tension_rising", etc.
  
  -- Participants
  involving = string[],           -- Country/Faction IDs involved
  initiator = string,             -- Who triggered (player, country, faction)
  
  -- Impact
  consequences = table,           -- {entity_id: effect}
  severity = number,              -- 0-100 (importance)
  global_impact = boolean,        -- Affects all factions
  
  -- Timing
  turn_triggered = number,        -- When did it happen
  is_active = boolean,
  duration = number,              -- Turns until resolved
}
```

---

### Entity: Agreement

Formal arrangement between countries (trade, defense pacts, research sharing).

**Properties:**
```lua
Agreement = {
  id = string,
  type = string,                  -- "trade", "defense_pact", "research_sharing"
  country_a = Country,
  country_b = Country,
  signed_date = number,           -- Turn number
  expiration_date = number | nil, -- Eternal if nil
  benefits_a = table,             -- Bonuses for country A
  benefits_b = table,             -- Bonuses for country B
  is_active = bool,
}
```

---

### Entity: RelationsEntry

Historical record of relation changes tracking what actions impact diplomacy.

**Properties:**
```lua
RelationsEntry = {
  country = Country,
  date = number,                  -- Turn number
  change = number,                -- -10 to +10
  reason = string,                -- "mission_success", "enemy_attack", "supply_deal"
  value_before = number,
  value_after = number,
}
```

---

### Entity: VotingWeight

Represents a country's influence in global voting for coalition policies.

**Properties:**
```lua
VotingWeight = {
  country = Country,
  base_weight = number,           -- 10-50
  relation_modifier = number,     -- -30 to +30
  current_weight = number,        -- base + modifier
}
```

---

## Services & Functions

### Country Management Service

```lua
-- Creation and retrieval
CountryManager.createCountry(id: string, name: string, region: string) → Country
CountryManager.getCountry(country_id: string) → Country | nil
CountryManager.getCountries() → Country[]
CountryManager.getActiveCountries() → Country[]
CountryManager.getCountriesInRegion(region: string) → Country[]

-- Status and relationships
CountryManager.getCountriesByAlignment(alignment: string) → Country[]
CountryManager.getCountriesBySupport(min_level: number) → Country[]
CountryManager.getCountriesAboutToLeave() → Country[]
CountryManager.getTotalFunding() → number (all active countries)

-- Operations
CountryManager.processMonthlyFunding() → void
CountryManager.updateCountryStatus(country: Country) → void
CountryManager.checkCountryLoyalty(country: Country) → void

-- Country system (legacy interface)
CountrySystem.getCountry(id) → Country | nil
CountrySystem.getAllCountries() → Country[]
CountrySystem.getActiveCountries() → Country[]
PoliticsSystem.createAgreement(country_a, country_b, type) → Agreement
```

### Faction Management Service

```lua
-- Creation and retrieval
FactionManager.createFaction(id: string, name: string, type: string) → Faction
FactionManager.getFaction(faction_id: string) → Faction | nil
FactionManager.getFactions() → Faction[]
FactionManager.getFactionsByType(type: string) → Faction[]

-- Relations
FactionManager.getPlayerReputation(faction: Faction) → number
FactionManager.getAlliedFactions() → Faction[]
FactionManager.getEnemyFactions() → Faction[]

-- Influence
FactionManager.getGlobalInfluence(faction: Faction) → number
FactionManager.calculateInfluence(faction: Faction) → number (recalculate)

-- Faction system (legacy interface)
FactionSystem.getFaction(id) → Faction | nil
FactionSystem.getAllFactions() → Faction[]
```

### Political Events Service

```lua
-- Event management
PoliticalEventManager.createEvent(type: string, involving: string[]) → PoliticalEvent
PoliticalEventManager.getActiveEvents() → PoliticalEvent[]
PoliticalEventManager.getEventsBySeverity(min_severity: number) → PoliticalEvent[]

-- Event execution
PoliticalEventManager.triggerEvent(event: PoliticalEvent) → void
PoliticalEventManager.resolveEvent(event: PoliticalEvent) → void
PoliticalEventManager.updateEvents(delta_turns: number) → void

-- Consequences
PoliticalEventManager.applyConsequences(event: PoliticalEvent) → void
PoliticalEventManager.notifyPlayerOfEvent(event: PoliticalEvent) → void
```

### Relationship Service

```lua
-- Country relations
RelationshipManager.adjustCountryRelations(country: Country, delta: number, reason: string) → void
RelationshipManager.getCountryHappiness(country: Country) → number
RelationshipManager.modifyTrust(country: Country, delta: number) → void
RelationshipManager.modifyRese ntment(country: Country, delta: number) → void

-- Faction relations
RelationshipManager.adjustFactionReputation(faction: Faction, delta: number, reason: string) → void
RelationshipManager.modifyFactionRelations(faction1: Faction, faction2: Faction, delta: number) → void

-- Consequences
RelationshipManager.checkForCountryWithdrawal(country: Country) → boolean
RelationshipManager.checkForFactionTension(faction: Faction) → boolean
```

### Mission Consequences Service

```lua
-- Mission outcome processing
MissionConsequences.processMissionOutcome(mission: Mission, result: string) → void
MissionConsequences.awardFactionMission(faction: Faction, mission: Mission) → void
MissionConsequences.penalizeMissionFailure(country: Country, mission: Mission) → void

-- Specific effects
MissionConsequences.recordCivilianCasualties(country: Country, count: number) → void
MissionConsequences.recordSuccessfulDefense(country: Country) → void
MissionConsequences.recordTerritorialLoss(country: Country) → void
```

---

## Configuration (TOML)

### Countries Configuration

```toml
# politics/countries.toml

[[countries]]
id = "usa"
name = "United States"
region = "north_america"
regions = ["north_america", "caribbean"]
alignment = "military"
government_type = "democracy"
leader = "Dr. Elizabeth Shaw"
monthly_funding = 30000
military_strength = 75
research_level = 60
starting_relations = 0
starting_funding = 5
available_supplies = ["plasma_rifle", "heavy_armor", "medkit", "ammo"]
voting_weight = 35

[[countries]]
id = "russia"
name = "Russian Federation"
region = "europe_asia"
regions = ["europe_east", "siberia"]
alignment = "military"
government_type = "dictatorship"
leader = "General Petrov"
monthly_funding = 20000
military_strength = 70
research_level = 65
starting_relations = 5
starting_funding = 4
available_supplies = ["heavy_armor", "ammo", "fuel"]
voting_weight = 25

[[countries]]
id = "china"
name = "People's Republic of China"
region = "asia"
regions = ["asia", "pacific"]
alignment = "economical"
government_type = "dictatorship"
leader = "Minister Zhou"
monthly_funding = 25000
military_strength = 72
research_level = 70
starting_relations = -10
starting_funding = 3
available_supplies = ["laser_weapon", "electronics", "components"]
voting_weight = 30

[[countries]]
id = "canada"
name = "Canada"
region = "north_america"
regions = ["north_america"]
alignment = "scientific"
government_type = "democracy"
leader = "Dr. Sarah Chen"
monthly_funding = 10000
military_strength = 40
research_level = 80
starting_relations = 0
starting_funding = 2
available_supplies = ["ammo", "medkit"]
voting_weight = 10
```

### Factions Configuration

```toml
# politics/factions.toml

[[factions]]
id = "xenonaut_defense"
name = "Xenonaut Defense"
type = "military"
alignment = "aggressive"
goals = ["defeat_aliens", "maintain_global_control"]
military_power = 85
research_level = 70
member_countries = ["usa", "russia", "canada"]

[[factions]]
id = "corporate_alliance"
name = "Corporate Research Alliance"
type = "economic"
alignment = "diplomatic"
goals = ["profit_from_technology", "minimize_military_risk"]
military_power = 30
research_level = 75
member_countries = ["china", "india", "brazil"]

[[factions]]
id = "resistance_cells"
name = "Underground Resistance"
type = "military"
alignment = "defensive"
goals = ["protect_civilians", "guerrilla_warfare"]
military_power = 40
research_level = 40
member_countries = ["mexico", "south_africa", "indonesia"]
```

### Political Consequences

```toml
# politics/consequences.toml

[country_happiness_modifiers]
successful_mission_defense = 15
failed_mission = -25
civilian_casualties_per_100 = -1
territory_lost = -30
research_shared = 10
funding_requested_met = 5
funding_requested_denied = -15

[faction_reputation_modifiers]
completed_faction_mission = 20
faction_conflict_resolved = 15
mission_against_faction_enemy = 10
mission_against_faction_ally = -20
generic_victory = 5

[country_withdrawal]
support_threshold = 20
panic_threshold = 80
unhappiness_threshold = -50

[political_events]
country_withdrawal_severity = 90
faction_rivalry_severity = 70
research_breakthrough_severity = 40
civilian_casualty_threshold = 100
```

### Relationship Thresholds

```toml
# politics/relationship_thresholds.toml

[trust_levels]
hostile = -75
distrusted = -25
neutral = 0
trusted = 50
allied = 85

[support_levels]
abandoned = 0
very_low = 25
low = 50
moderate = 75
high = 90
committed = 100

[resentment_levels]
none = 0
minor = 25
significant = 50
severe = 75
extreme = 100
```

---

## Usage Examples

### Example 1: Monitor Country Support

```lua
-- Get all active countries
local countries = CountryManager.getCountries()

for _, country in ipairs(countries) do
  if country:isActive() then
    local support = country:getSupportLevel()
    local happiness = country:getHappiness()
    local panic = country:getPanicLevel()
    
    print(country:getName() .. ":")
    print("  Support: " .. support .. "/100")
    print("  Happiness: " .. happiness)
    print("  Panic: " .. panic)
    
    -- Check for critical status
    if country:isAboutToLeave() then
      print("  WARNING: About to leave coalition!")
    end
  end
end

-- Process monthly funding
CountryManager.processMonthlyFunding()
local total_funding = CountryManager.getTotalFunding()
print("Total Monthly Income: " .. total_funding .. " credits")
```

### Example 2: Handle Mission Outcome

```lua
-- Mission completed
if mission_result == "success" then
  -- Award reputation to funding faction
  local faction = mission:getReqFaction()
  MissionConsequences.awardFactionMission(faction, mission)
  
  -- Update country relations
  for _, country in ipairs(faction:getAlliedCountries()) do
    RelationshipManager.adjustCountryRelations(country, 15, "mission_success")
    print(country:getName() .. " satisfied with mission")
  end
  
else
  -- Mission failed
  local primary_country = mission:getCountry()
  MissionConsequences.penalizeMissionFailure(primary_country, mission)
  
  RelationshipManager.adjustCountryRelations(primary_country, -30, "mission_failure")
  print(primary_country:getName() .. " lost faith in Xenonauts")
end
```

### Example 3: Manage Civilian Casualties

```lua
-- Battle resulted in casualties
local civs_lost = 150
local civs_protected = 300
local affected_country = mission:getCountry()

MissionConsequences.recordCivilianCasualties(affected_country, civs_lost)
MissionConsequences.recordSuccessfulDefense(affected_country)

-- Adjust relations based on balance
if civs_protected > civs_lost then
  print("Net positive outcome - citizens safe")
  RelationshipManager.modifyTrust(affected_country, 5)
else
  print("High casualties - country upset")
  RelationshipManager.modifyRese ntment(affected_country, 20)
end

-- Political event may trigger
if civs_lost > 200 then
  local event = PoliticalEventManager.createEvent("civilian_massacre", {affected_country:getId()})
  PoliticalEventManager.triggerEvent(event)
end
```

### Example 4: Monitor Faction Influence

```lua
-- Get all factions
local factions = FactionManager.getFactions()

for _, faction in ipairs(factions) do
  local influence = faction:getInfluence()
  local reputation = FactionManager.getPlayerReputation(faction)
  
  print(faction:getName() .. ":")
  print("  Global Influence: " .. influence .. "/100")
  print("  Player Reputation: " .. reputation)
  
  if reputation > 50 then
    print("  Status: ALLY")
  elseif reputation < -50 then
    print("  Status: ENEMY")
  else
    print("  Status: NEUTRAL")
  end
  
  -- List member countries
  local members = faction:getAlliedCountries()
  print("  Members: " .. table.concat(array_map(members, function(c) return c:getName() end), ", "))
end
```

### Example 5: Trade Agreement

```lua
local usa = CountryManager.getCountry("usa")
local china = CountryManager.getCountry("china")

-- Check if can trade
if usa:canTrade() and china:canTrade() then
  -- Create agreement
  local agreement = PoliticsSystem.createAgreement(usa, china, "trade")
  
  print("Trade agreement established!")
  
  -- Can now buy supplies from both countries
  local supplies = usa:getSupplies()
  for _, item in ipairs(supplies) do
    local cost = usa:getTradeCost(item.id)
    print(item.name .. ": $" .. cost)
  end
else
  print("Cannot establish trade - relations too poor")
end
```

### Example 6: Voting Power Query

```lua
local countries = CountryManager.getAllCountries()
local totalVoting = 0
local influential = {}

for _, country in ipairs(countries) do
  local weight = country:getVotingWeight()
  totalVoting = totalVoting + weight
  
  if country:isInfluential() then
    table.insert(influential, country:getName())
  end
end

print("Total voting power: " .. totalVoting)
print("Influential countries: " .. table.concat(influential, ", "))
```

### Example 7: Trigger Political Event

```lua
-- Scenario: Major country loses region
local country = CountryManager.getCountry("usa")
local event = PoliticalEventManager.createEvent("territorial_loss", {country:getId()})
event.severity = 85

PoliticalEventManager.triggerEvent(event)

-- Apply consequences
PoliticalEventManager.applyConsequences(event)
RelationshipManager.adjustCountryRelations(country, -40, "territorial_loss")

-- Notify player
PoliticalEventManager.notifyPlayerOfEvent(event)
print("CRISIS: " .. country:getName() .. " has lost territory to alien forces!")
```

---

## Relation Impact System

**Positive Events (+1 to +10):**
- Successful mission in country
- Completed country objective
- Trade agreement established
- Technology shared
- Protection provided
- Civilian lives saved

**Negative Events (-1 to -10):**
- Failed mission in country
- Civilian casualties
- Funding reduced
- Base destroyed in region
- Enemy alliance with competitor
- Territory lost

**Relation Effects:**
```
-100 to -75:  Hostile (stops funding, won't trade)
-74 to -25:   Unfriendly (reduced funding)
-24 to +24:   Neutral (baseline funding)
+25 to +74:   Friendly (bonus funding)
+75 to +100:  Allied (maximum benefits)
```

---

## Funding Formula

**Monthly Contribution:**
```
Contribution = (Base Rate × Funding Level) × Relation Modifier
Example: (30,000 × 5) × 1.0 = 150,000 credits
```

**Relation Modifier:**
```
Modifier = 0.5 + (Relations / 200)
-100 relations = 0.0x (no funding)
0 relations = 0.5x (half funding)
+100 relations = 1.0x (full funding)
```

---

## Country Status Table

| Relations | Status | Funding | Trading | Benefits |
|-----------|--------|---------|---------|----------|
| -100 to -75 | Hostile | 0% | ❌ | None |
| -74 to -25 | Unfriendly | 25-50% | Limited | Reduced |
| -24 to +24 | Neutral | 50% | Yes | Standard |
| +25 to +74 | Friendly | 75-100% | Yes | Trade bonus |
| +75 to +100 | Allied | 100%+ | Yes | Full benefits |

---

## Entity: OrganizationFame

Tracks public reputation, recognition level, and their gameplay effects.

**Properties:**
```lua
OrganizationFame = {
  current_fame = number,          -- 0-100 current fame level
  fame_tier = string,             -- "unknown", "known", "famous", "legendary"
  monthly_decay = number,         -- -1 to -2 typical decay per month
  last_update_turn = number,      -- When fame was last recalculated
  
  -- History
  fame_events = table,            -- Recent fame sources/sinks {turn, delta, reason}
  lifetime_peak = number,         -- Highest fame ever achieved
  lifetime_earned = number,       -- Total fame gained (before decay)
  
  -- Effects
  active_multipliers = table,     -- Current modifiers to mission generation, recruitment, etc.
}
```

**Functions:**
```lua
-- Retrieval
Fame.getOrganizationFame() → OrganizationFame
Fame.getFame() → number  -- Current fame value (0-100)
Fame.getFameTier() → string  -- "unknown", "known", "famous", "legendary"
Fame.getFamePercent() → number  -- 0-1.0 (normalized)

-- Adjustments
Fame.addFame(delta: number, reason: string) → void
  -- Example: Fame.addFame(+5, "mission_success")
Fame.adjustFame(delta: number) → number  -- Returns new fame value
Fame.setFame(value: number) → void

-- Query effects
Fame.getMissionGenerationBonus() → number  -- 0.0 to 0.30 multiplier
Fame.getRecruitmentQualityBonus() → number  -- 0.0 to 0.45 multiplier (+15% per tier)
Fame.getFundingMultiplier() → number  -- 1.0 to 1.50 multiplier (+10% per tier)
Fame.getSupplierTierAccess() → number  -- 1-4 (locked supplier tiers)
Fame.getMediaAttention() → number  -- 0.0-1.0 (scrutiny level)
Fame.canAccessPremiumSuppliers() → boolean  -- Requires famous+ tier
Fame.canAccessLegendaryEquipment() → boolean  -- Requires legendary tier

-- Monthly processing
Fame.processMonthlyDecay() → void  -- Called monthly, applies -1 to -2 decay
Fame.processYearlyReset() → void  -- Called yearly, adjusts decay rate

-- Statistics
Fame.getFameHistory() → table  -- Last 12 entries of fame changes
Fame.getEventsSince(turn_number: number) → table  -- Fame changes since turn X
```

**Fame Tier Effects:**

| Tier | Range | Mission Gen | Recruitment | Funding | Supplier Access | Media |
|------|-------|-------------|-------------|---------|-----------------|-------|
| Unknown | 0-24 | -0% | -0% | -0% | Tier 1 only | Low |
| Known | 25-59 | +10% | +15% | +10% | Tier 1-2 | Medium |
| Famous | 60-89 | +20% | +30% | +30% | Tier 1-3 | High |
| Legendary | 90-100 | +30% | +45% | +50% | Tier 1-4 (all) | Very High |

**Fame Sources:**
```lua
Fame Sources = {
  mission_success = 5,         -- Per completed mission
  mission_failure = -3,        -- Per failed mission
  ufo_destroyed = 2,           -- Per UFO kill in territory
  base_raided = -10,           -- Per base attacked/lost
  research_breakthrough = 3,   -- Per completed research
  black_market_discovery = -20, -- Major penalty if caught
  major_victory = 15,          -- Defeating significant threats
  civilian_casualties = -5,    -- Per major casualty incident
}
```

**Manager Service:**
```lua
FameManager = {
  -- Called when mission completes/fails
  recordMissionOutcome(success: boolean, region: string) → void,
  
  -- Called when UFO destroyed
  recordUFODestruction(ufo_id: string, region: string) → void,
  
  -- Called when base attacked
  recordBaseAttack(base_id: string, base_lost: boolean) → void,
  
  -- Called when research completes
  recordResearchComplete(tech_id: string, public_tier: number) → void,
  
  -- Called when black market activity discovered
  recordBlackMarketDiscovery() → void,
  
  -- Called on significant events
  recordMajorVictory(event_description: string) → void,
  recordCivilianCasualties(count: number) → void,
  
  -- Monthly/yearly processing
  processMonthlyDecay() → void,
  
  -- Query effects
  getMissionGenerationBonus() → number,
  getRecruitmentBonus() → number,
  getFundingBonus() → number,
}
```

---

## Entity: OrganizationKarma

Tracks moral alignment and ethical choices affecting available contracts, missions, and endings.

**Properties:**
```lua
OrganizationKarma = {
  current_karma = number,         -- -100 (evil) to +100 (benevolent)
  alignment = string,             -- "evil", "ruthless", "pragmatic", "neutral", "principled", "saint"
  
  -- Hidden from player
  karma_hidden = boolean,         -- Always true - player doesn't see value
  
  -- History (for development/debugging)
  karma_history = table,          -- Recent karma changes {turn, delta, reason, new_total}
  lifetime_actions = number,      -- Total actions affecting karma
  
  -- Effects (calculated)
  black_market_accessible = boolean,
  humanitarian_accessible = boolean,
  faction_alignment_bonus = table, -- Per-faction modifiers
}
```

**Functions:**
```lua
-- Retrieval (mostly hidden from player UI)
Karma.getKarma() → number  -- -100 to +100 (can be exposed for debugging)
Karma.getAlignment() → string  -- "evil", "ruthless", "pragmatic", "neutral", "principled", "saint"
Karma.getKarmaPercent() → number  -- Normalized -1.0 to +1.0

-- Adjustments
Karma.addKarma(delta: number, reason: string) → void
  -- Example: Karma.addKarma(-20, "prisoner_executed")
Karma.recordAction(action_type: string, context: table) → number  -- Returns karma delta
Karma.setKarma(value: number) → void  -- Direct setting (debug)

-- Access checks (gated mission/contract availability)
Karma.canAccessBlackMarket() → boolean  -- Requires karma < -40
Karma.canAccessHumanitarianMissions() → boolean  -- Requires karma > +10
Karma.canAccessShadowOps() → boolean  -- Requires karma < -20
Karma.canAccessAssassinations() → boolean  -- Requires karma < -50
Karma.canAccessMercyMissions() → boolean  -- Requires karma > +20

-- Faction effects
Karma.getFactionPreference(faction_id: string) → number  -- -1 (hates), 0 (neutral), +1 (favors)
Karma.getRecruitmentRestrictions() → string[]  -- Unit types unavailable
Karma.canHireUnit(unit_type: string) → boolean  -- Checks karma gate

-- Ending & story
Karma.getStoryBranchPath() → string  -- Determines narrative outcomes
Karma.getAvailableEndings() → string[]  -- Which endings are reachable
Karma.getMultipleOutcomes(event_id: string) → table  -- Variant outcomes for event

-- Statistics
Karma.getKarmaHistory() → table  -- Last 12 karma entries
Karma.getTotalActionsCount() → number
Karma.getMostCommonAlignment() → string  -- What alignment player leans toward
```

**Karma Alignment Levels:**

| Alignment | Range | Access | Suppliers | Story Impact | Unit Types |
|-----------|-------|--------|-----------|--------------|-----------|
| Evil | -100 to -75 | Black Market ✓ | War-profiteers | Dark/Ruthless | Mercenaries, Outlaws |
| Ruthless | -74 to -40 | Black Market ✓ | Amoral suppliers | Pragmatic/Cold | All (penalties vary) |
| Pragmatic | -39 to -10 | Limited access | Neutral access | Balanced outcomes | Standard + some restricted |
| Neutral | -9 to +9 | All available | All suppliers | Random/flexible | Standard options |
| Principled | +10 to +40 | Humanitarian ✓ | Ethical suppliers | Heroic/Justice | Standard + idealistic |
| Saint | +41 to +100 | Humanitarian ✓ | Idealistic only | Redemption/Victory | Idealistic, restricted evil |

**Karma Action Sources:**

```lua
KarmaEvents = {
  -- Military actions
  civilian_killed = -10,
  civilian_killed_collateral = -5,
  civilian_saved = 5,
  base_defended = 3,
  defensive_victory = 2,
  
  -- Prisoner handling
  prisoner_executed = -20,
  prisoner_tortured = -3,
  prisoner_interrogated = 0,
  prisoner_spared = 10,
  prisoner_released = 12,
  
  -- Operations
  black_market_purchase = -5,    -- To -20 by value
  humanitarian_mission = 15,
  illegal_operation = -10,       -- To -30 by severity
  peaceful_resolution = 15,
  war_crime = -30,
  
  -- Research
  defensive_research = 3,
  unethical_experiment = -15,
  alien_experimentation = -8,
  
  -- Diplomacy
  treaty_signing = 5,
  treaty_breaking = -10,
  alliance_betrayal = -25,
  peaceful_negotiation = 8,
}
```

**Manager Service:**
```lua
KarmaManager = {
  -- Record actions affecting karma
  recordCivilianDeath(context: table) → number,  -- Returns karma delta
  recordCivilianSaved(context: table) → number,
  recordPrisonerExecution(prisoner_race: string) → number,
  recordPrisonerTorture(prisoner_id: string) → number,
  recordPrisonerSpared(prisoner_id: string) → number,
  recordBlackMarketPurchase(value: number) → number,
  recordHumanitarianOperation(outcome: boolean) → number,
  recordWarCrime(severity: number) → number,
  recordPeaceNegotiation(outcome: boolean) → number,
  
  -- Check availability
  checkMissionType(mission_type: string) → boolean,
  checkContractAvailability(contract_id: string) → boolean,
  checkSupplierAccess(supplier_id: string) → number,  -- -1, 0, +1
  checkUnitRecruitment(unit_type: string) → boolean,
  
  -- Story integration
  getAvailableEventVariants(event_id: string) → table,  -- Multiple outcomes
  getStoryEndings() → string[],  -- Which endings accessible
  
  -- Hidden calculation
  getEffectiveKarma() → number,  -- Adjusted by recent actions
  processHiddenMechanics() → void,  -- Monthly updates
}
```

---

## Integration Points

**Inputs from:**
- Geoscape (country territory, UFO attacks, regional control)
- Missions (success/failure, civilian casualty counts, territory impacts)
- Finance (funding requests, payment tracking)
- Research (technology developments, sharing agreements)
- Crafts (interception results affecting regional safety)

**Outputs to:**
- Finance (monthly funding amounts, payment conditions)
- Geoscape (mission availability, UFO deployment)
- Research (tech sharing agreements, research access)
- UI (diplomacy screens, relation displays, event notifications)
- Economy (trade availability, supplier partnerships)

**Dependencies:**
- Country/Faction databases
- Relationship calculation engine
- Mission system (success/failure outcomes)
- Finance system (funding calculations)
- Territory system (region ownership)

---

## Error Handling

```lua
-- Country has already left
if not country:isActive() then
  print("Cannot interact with " .. country:getName() .. " - they have withdrawn")
  return false
end

-- Country about to leave
if country:isAboutToLeave() then
  print("WARNING: " .. country:getName() .. " will leave next month if satisfaction not improved")
end

-- No valid factions for mission
local factions = FactionManager.getFactionsByType("military")
if #factions == 0 then
  print("No military factions available for mission")
  return nil
end

-- Relationship threshold
if country:getTrust() < -75 then
  print(country:getName() .. " is hostile - diplomacy impossible")
end

-- Invalid country removal
if not CountryManager.removeCountry(country_id) then
  print("Cannot remove country - not found")
end

-- Voting weight conflict
if totalVotingWeight > 100 then
  print("WARNING: Voting weights exceed 100 - normalization needed")
end
```

---

**Last Updated:** October 22, 2025  
**API Status:** ✅ COMPLETE  
**Coverage:** 100% (All entities, functions, TOML, examples, voting system, relations, agreements documented)  
**Consolidation:** POLITICS_DETAILED + POLITICS_COMPLETE merged into single comprehensive module
