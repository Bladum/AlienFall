# Task: Relations System - Country, Supplier, and Faction Relations

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement a comprehensive relations system that tracks player relationships with countries, suppliers, and factions. Relations affect funding, prices, item availability, mission generation, and mission difficulty.

---

## Purpose

The relations system creates a dynamic strategic layer where player actions have consequences. Good relations unlock benefits (funding, discounts, fewer missions) while bad relations create challenges (higher prices, more/stronger missions). This adds depth to strategic decision-making.

---

## Requirements

### Functional Requirements
- [ ] Track relations value (-100 to +100) for each country, supplier, and faction
- [ ] Relations affect country funding levels
- [ ] Relations affect supplier prices and item availability
- [ ] Relations affect faction mission generation and difficulty
- [ ] Relations can change based on player actions (mission results, trade, diplomacy)
- [ ] Display relations status in UI (numeric + descriptive labels)
- [ ] Special events/rewards at extreme relation values
- [ ] Relations decay/growth over time (configurable per entity type)
- [ ] Save/load relations data

### Technical Requirements
- [ ] Relations manager system in `engine/geoscape/systems/relations_manager.lua`
- [ ] Relations data structure per entity (country/supplier/faction)
- [ ] Event-based relation changes (mission results, purchases, diplomatic actions)
- [ ] Configuration file for relation thresholds and effects
- [ ] Integration with funding system
- [ ] Integration with marketplace system
- [ ] Integration with mission generation system
- [ ] UI widgets for displaying relations

### Acceptance Criteria
- [ ] Relations values properly tracked for all entities
- [ ] Country funding changes based on relations
- [ ] Supplier prices adjust based on relations
- [ ] Faction mission frequency/strength affected by relations
- [ ] Relations UI shows current status and recent changes
- [ ] Relations persist across save/load
- [ ] Console shows debug info for relation changes
- [ ] Performance: O(1) lookups, minimal per-turn overhead

---

## Plan

### Step 1: Core Relations Manager (6 hours)
**Description:** Create the central relations management system  
**Files to create:**
- `engine/geoscape/systems/relations_manager.lua` - Main relations manager
- `engine/data/relations_config.lua` - Configuration for thresholds and effects

**Implementation:**
```lua
-- Relations Manager API
RelationsManager = {
    -- Core data
    countryRelations = {},    -- [countryId] = relationValue (-100 to +100)
    supplierRelations = {},   -- [supplierId] = relationValue
    factionRelations = {},    -- [factionId] = relationValue
    
    -- Relation thresholds (descriptive labels)
    thresholds = {
        { min = 75,  max = 100,  label = "Allied",    color = {0, 200, 0} },
        { min = 50,  max = 74,   label = "Friendly",  color = {0, 150, 0} },
        { min = 25,  max = 49,   label = "Positive",  color = {0, 100, 0} },
        { min = -24, max = 24,   label = "Neutral",   color = {150, 150, 150} },
        { min = -49, max = -25,  label = "Negative",  color = {200, 100, 0} },
        { min = -74, max = -50,  label = "Hostile",   color = {200, 50, 0} },
        { min = -100, max = -75, label = "War",       color = {255, 0, 0} }
    },
    
    -- Methods
    init = function(self) end,
    getRelation = function(self, entityType, entityId) end,
    setRelation = function(self, entityType, entityId, value) end,
    modifyRelation = function(self, entityType, entityId, delta, reason) end,
    getRelationLabel = function(self, value) end,
    getRelationColor = function(self, value) end,
    updateAllRelations = function(self, daysPassed) end,  -- Time-based decay/growth
}
```

**Estimated time:** 6 hours

### Step 2: Country Relations Integration (5 hours)
**Description:** Integrate relations with country funding system  
**Files to modify/create:**
- `engine/geoscape/systems/funding_manager.lua` - Add relation-based funding modifier
- `engine/geoscape/logic/country.lua` - Add relation tracking to country data

**Implementation:**
```lua
-- Country funding calculation
function FundingManager:calculateCountryFunding(country)
    local baseAmount = country.baseFunding
    local relationValue = RelationsManager:getRelation("country", country.id)
    local relationModifier = self:getRelationFundingModifier(relationValue)
    
    -- Relation effects on funding:
    -- Allied (75-100):   +50% to +100% funding
    -- Friendly (50-74):  +25% to +50% funding
    -- Positive (25-49):  +10% to +25% funding
    -- Neutral (-24-24):  0% modifier
    -- Negative (-49--25): -10% to -25% funding
    -- Hostile (-74--50):  -25% to -50% funding
    -- War (-100--75):     -50% to -75% funding (may cut funding entirely)
    
    local finalAmount = baseAmount * (1.0 + relationModifier)
    return math.max(0, finalAmount)
end

-- Relation changes from missions
function RelationsManager:onMissionComplete(mission, result)
    if mission.country then
        local delta = 0
        if result == "success" then
            delta = 5 + (mission.difficulty * 2)  -- Harder missions = more relation gain
        elseif result == "failure" then
            delta = -(3 + mission.difficulty)
        elseif result == "abort" then
            delta = -2
        end
        self:modifyRelation("country", mission.country.id, delta, "Mission " .. result)
    end
end
```

**Estimated time:** 5 hours

### Step 3: Supplier Relations Integration (6 hours)
**Description:** Integrate relations with marketplace pricing and availability  
**Files to modify/create:**
- `engine/geoscape/systems/marketplace_manager.lua` - Add relation-based pricing
- `engine/geoscape/logic/supplier.lua` - Add relation tracking to supplier data

**Implementation:**
```lua
-- Supplier price calculation
function MarketplaceManager:getItemPrice(supplier, item)
    local basePrice = item.basePrice
    local relationValue = RelationsManager:getRelation("supplier", supplier.id)
    local priceModifier = self:getRelationPriceModifier(relationValue)
    
    -- Relation effects on prices:
    -- Allied (75-100):   -30% to -50% discount
    -- Friendly (50-74):  -15% to -30% discount
    -- Positive (25-49):  -5% to -15% discount
    -- Neutral (-24-24):  0% modifier
    -- Negative (-49--25): +10% to +25% markup
    -- Hostile (-74--50):  +25% to +50% markup
    -- War (-100--75):     +50% to +100% markup (some items unavailable)
    
    local finalPrice = basePrice * (1.0 + priceModifier)
    return math.ceil(finalPrice)
end

-- Item availability based on relations
function MarketplaceManager:isItemAvailable(supplier, item)
    local relationValue = RelationsManager:getRelation("supplier", supplier.id)
    
    -- Items may require minimum relation to purchase
    if item.minRelationRequired and relationValue < item.minRelationRequired then
        return false, "Insufficient relations with supplier"
    end
    
    -- At war, only basic items available
    if relationValue < -75 then
        return item.category == "basic", "Supplier refuses to sell advanced items"
    end
    
    -- Special offers for allied suppliers
    if relationValue >= 75 and item.specialOffer then
        return true, "Special offer available!"
    end
    
    return true, ""
end

-- Relation changes from purchases
function RelationsManager:onPurchase(supplier, totalValue)
    -- Purchases improve relations slightly
    local delta = math.floor(totalValue / 10000)  -- 1 point per $10k spent
    delta = math.min(delta, 5)  -- Max +5 per purchase
    self:modifyRelation("supplier", supplier.id, delta, "Purchase")
end
```

**Estimated time:** 6 hours

### Step 4: Faction Relations & Mission Generation (8 hours)
**Description:** Integrate relations with faction mission spawning and difficulty  
**Files to modify/create:**
- `engine/geoscape/systems/mission_generator.lua` - Add relation-based mission logic
- `engine/geoscape/logic/faction.lua` - Add relation tracking to faction data

**Implementation:**
```lua
-- Faction mission generation
function MissionGenerator:generateWeeklyMissions(week)
    local missions = {}
    
    for _, faction in ipairs(self.activeFactions) do
        local relationValue = RelationsManager:getRelation("faction", faction.id)
        local missionCount = self:calculateMissionCount(faction, relationValue)
        local missionPower = self:calculateMissionPower(faction, relationValue)
        
        -- Relation effects on mission generation:
        -- Allied (75-100):   0 missions (cease-fire)
        -- Friendly (50-74):  1 mission, -50% power
        -- Positive (25-49):  1-2 missions, -25% power
        -- Neutral (-24-24):  2-3 missions, normal power
        -- Negative (-49--25): 3-4 missions, +25% power
        -- Hostile (-74--50):  4-5 missions, +50% power
        -- War (-100--75):     5-7 missions, +100% power
        
        for i = 1, missionCount do
            local mission = self:createMission(faction, missionPower)
            table.insert(missions, mission)
        end
    end
    
    return missions
end

function MissionGenerator:calculateMissionCount(faction, relationValue)
    if relationValue >= 75 then
        return 0  -- Allied: no missions
    elseif relationValue >= 50 then
        return 1
    elseif relationValue >= 25 then
        return math.random(1, 2)
    elseif relationValue >= -24 then
        return math.random(2, 3)
    elseif relationValue >= -49 then
        return math.random(3, 4)
    elseif relationValue >= -74 then
        return math.random(4, 5)
    else
        return math.random(5, 7)  -- War: maximum missions
    end
end

function MissionGenerator:calculateMissionPower(faction, relationValue)
    local basePower = faction.basePower
    local powerModifier = 1.0
    
    if relationValue >= 50 then
        powerModifier = 0.5  -- Friendly missions are weaker
    elseif relationValue >= 25 then
        powerModifier = 0.75
    elseif relationValue >= -49 then
        powerModifier = 1.25
    elseif relationValue >= -74 then
        powerModifier = 1.5
    else
        powerModifier = 2.0  -- War missions are much stronger
    end
    
    return basePower * powerModifier
end

-- Relation changes from mission results
function RelationsManager:onMissionCompleteForFaction(faction, mission, result)
    local delta = 0
    
    if result == "success" then
        -- Destroying faction missions decreases relations
        delta = -(5 + mission.difficulty)
    elseif result == "ignore" then
        -- Ignoring missions slightly improves relations
        delta = 1
    end
    
    self:modifyRelation("faction", faction.id, delta, "Mission outcome")
end
```

**Estimated time:** 8 hours

### Step 5: Relations UI Components (5 hours)
**Description:** Create UI widgets for displaying relations  
**Files to create:**
- `engine/geoscape/ui/relations_panel.lua` - Panel showing all relations
- `engine/widgets/relation_bar.lua` - Widget for displaying single relation value

**Implementation:**
```lua
-- RelationBar widget
local RelationBar = setmetatable({}, {__index = BaseWidget})

function RelationBar:new(x, y, width, entityType, entityId, entityName)
    local self = setmetatable(BaseWidget.new(x, y, width, 48), {__index = RelationBar})
    self.entityType = entityType
    self.entityId = entityId
    self.entityName = entityName
    return self
end

function RelationBar:draw()
    local value = RelationsManager:getRelation(self.entityType, self.entityId)
    local label = RelationsManager:getRelationLabel(value)
    local color = RelationsManager:getRelationColor(value)
    
    -- Draw entity name
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(self.entityName, self.x, self.y)
    
    -- Draw relation bar (-100 to +100 mapped to bar width)
    local barX = self.x
    local barY = self.y + 24
    local barWidth = self.width
    local barHeight = 12
    
    -- Background
    love.graphics.setColor(50, 50, 50)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
    
    -- Relation fill
    local fillWidth = (value + 100) / 200 * barWidth
    love.graphics.setColor(color[1], color[2], color[3])
    love.graphics.rectangle("fill", barX, barY, fillWidth, barHeight)
    
    -- Label and value
    local text = string.format("%s (%d)", label, value)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(text, barX + barWidth + 8, barY - 6)
end
```

**Estimated time:** 5 hours

### Step 6: Relations Events & Diplomacy Actions (4 hours)
**Description:** Add player actions and events that affect relations  
**Files to modify/create:**
- `engine/geoscape/systems/diplomacy_manager.lua` - Diplomatic actions
- `engine/geoscape/systems/event_manager.lua` - Random events affecting relations

**Implementation:**
```lua
-- Diplomacy actions
DiplomacyManager = {
    -- Send gift to improve relations
    sendGift = function(self, entityType, entityId, giftValue)
        local cost = giftValue
        if player:spendFunds(cost) then
            local relationDelta = math.floor(giftValue / 5000)  -- $5k = +1 relation
            RelationsManager:modifyRelation(entityType, entityId, relationDelta, "Gift sent")
            return true
        end
        return false
    end,
    
    -- Formal alliance proposal (requires high relations)
    proposeAlliance = function(self, entityType, entityId)
        local currentRelation = RelationsManager:getRelation(entityType, entityId)
        if currentRelation >= 50 then
            -- Success chance based on relations
            local chance = (currentRelation - 50) / 50  -- 0% at 50, 100% at 100
            if math.random() < chance then
                RelationsManager:setRelation(entityType, entityId, 85)
                return true, "Alliance accepted!"
            else
                return false, "Alliance proposal rejected. Relations unchanged."
            end
        else
            return false, "Relations too low for alliance (need 50+)"
        end
    end,
    
    -- Declare war
    declareWar = function(self, entityType, entityId)
        RelationsManager:setRelation(entityType, entityId, -90)
        -- Trigger immediate consequences
        if entityType == "faction" then
            -- Spawn retaliatory missions
            MissionGenerator:spawnRetaliationMissions(entityId, 3)
        end
    end
}

-- Random events
function EventManager:processRandomRelationEvents()
    -- 10% chance per month for random event
    if math.random() < 0.1 then
        local eventType = math.random(1, 3)
        
        if eventType == 1 then
            -- Country political change
            local country = self:selectRandomCountry()
            local delta = math.random(-15, 15)
            RelationsManager:modifyRelation("country", country.id, delta, "Political change")
            
        elseif eventType == 2 then
            -- Supplier market shift
            local supplier = self:selectRandomSupplier()
            local delta = math.random(-10, 10)
            RelationsManager:modifyRelation("supplier", supplier.id, delta, "Market conditions")
            
        elseif eventType == 3 then
            -- Faction leadership change
            local faction = self:selectRandomFaction()
            local delta = math.random(-20, 20)
            RelationsManager:modifyRelation("faction", faction.id, delta, "Leadership change")
        end
    end
end
```

**Estimated time:** 4 hours

### Step 7: Time-Based Relations Decay (3 hours)
**Description:** Implement gradual relation changes over time  
**Files to modify:**
- `engine/geoscape/systems/relations_manager.lua` - Add decay logic

**Implementation:**
```lua
-- Relations decay/growth over time
function RelationsManager:updateAllRelations(daysPassed)
    -- Process all relations
    for countryId, value in pairs(self.countryRelations) do
        local newValue = self:applyDecay(value, daysPassed, "country")
        self.countryRelations[countryId] = newValue
    end
    
    for supplierId, value in pairs(self.supplierRelations) do
        local newValue = self:applyDecay(value, daysPassed, "supplier")
        self.supplierRelations[supplierId] = newValue
    end
    
    for factionId, value in pairs(self.factionRelations) do
        local newValue = self:applyDecay(value, daysPassed, "faction")
        self.factionRelations[factionId] = newValue
    end
end

function RelationsManager:applyDecay(currentValue, days, entityType)
    local config = self.config[entityType]
    
    -- Relations naturally trend toward neutral over time
    local targetValue = 0
    local decayRate = config.decayRate or 0.1  -- Points per day toward neutral
    
    local difference = targetValue - currentValue
    local decay = decayRate * days
    
    if math.abs(difference) < decay then
        return targetValue
    elseif difference > 0 then
        return currentValue + decay
    else
        return currentValue - decay
    end
end

-- Configuration
RelationsManager.config = {
    country = {
        decayRate = 0.05,  -- Slow decay (0.05/day = 1.5/month)
        initialRelation = 0
    },
    supplier = {
        decayRate = 0.1,   -- Medium decay (0.1/day = 3/month)
        initialRelation = 0
    },
    faction = {
        decayRate = 0.15,  -- Fast decay (0.15/day = 4.5/month)
        initialRelation = -25  -- Start slightly hostile
    }
}
```

**Estimated time:** 3 hours

### Step 8: Testing & Integration (5 hours)
**Description:** Test all relation systems and integrate with existing code  
**Files to create:**
- `engine/geoscape/tests/test_relations.lua` - Unit tests for relations system

**Test cases:**
- Relation values stay within bounds (-100 to +100)
- Country funding changes with relations
- Supplier prices adjust correctly
- Faction missions respond to relation changes
- Relations persist across save/load
- UI displays correct values and colors
- Decay system works over time
- Diplomatic actions have correct effects

**Estimated time:** 5 hours

---

## Implementation Details

### Architecture
Relations system follows observer pattern: entities (countries, suppliers, factions) are observed by the RelationsManager, which notifies dependent systems (funding, marketplace, missions) when relations change.

### Key Components
- **RelationsManager:** Central hub tracking all relations
- **FundingManager Integration:** Modifies country funding based on relations
- **MarketplaceManager Integration:** Adjusts prices and availability
- **MissionGenerator Integration:** Controls mission frequency and difficulty
- **DiplomacyManager:** Player actions affecting relations
- **EventManager:** Random events creating dynamic changes

### Dependencies
- Geoscape world data (countries, suppliers, factions)
- Funding system
- Marketplace system
- Mission generation system
- Save/load system
- UI widgets

---

## Testing Strategy

### Unit Tests
- Test relation value boundaries (-100 to +100)
- Test funding modifier calculation
- Test price modifier calculation
- Test mission count/power calculation
- Test decay logic over time
- Test save/load persistence

### Integration Tests
- Test mission completion affecting relations
- Test purchases affecting supplier relations
- Test diplomatic actions
- Test random events
- Test UI updates with relation changes

### Manual Testing Steps
1. Start new campaign, check initial relations
2. Complete missions, verify country relations change
3. Purchase items, verify supplier relations improve
4. Advance time, verify decay toward neutral
5. Use diplomacy actions, verify effects
6. Check funding changes with country relations
7. Check price changes with supplier relations
8. Check mission spawning with faction relations
9. Save and load game, verify relations persist
10. Check console for relation change messages

### Expected Results
- Relations affect all three systems correctly
- UI shows accurate relation status
- No relation values exceed boundaries
- Performance remains smooth (< 1ms per turn update)
- Console shows clear debug info

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game"

### Debugging
- Enable relation debug logging: `RelationsManager.debugMode = true`
- Console output format: `[Relations] Country USA: 45 -> 50 (+5) [Mission success]`
- Use F9 for grid overlay if testing UI alignment
- Check `engine/logs/relations.log` for detailed history

### Debug Commands (add to test menu)
```lua
-- Debug commands for testing relations
function DebugCommands:setRelation(entityType, entityId, value)
    RelationsManager:setRelation(entityType, entityId, value)
end

function DebugCommands:printAllRelations()
    print("[Relations Debug] All Current Relations:")
    for id, value in pairs(RelationsManager.countryRelations) do
        print(string.format("  Country %s: %d (%s)", id, value, RelationsManager:getRelationLabel(value)))
    end
    -- Similar for suppliers and factions
end
```

### Temporary Files
- Relations history log: `os.getenv("TEMP") .. "\\xcom_relations_log.txt"`
- No other temporary files needed

---

## Documentation Updates

### Files to Update
- [x] `wiki/API.md` - Add RelationsManager API documentation
- [x] `wiki/FAQ.md` - Add section on relations system and how it works
- [x] `wiki/DEVELOPMENT.md` - Add relations system architecture notes
- [ ] `engine/geoscape/README.md` - Document relations integration
- [ ] Code comments - Add detailed inline documentation

### API Documentation Example
```markdown
## RelationsManager

### Methods
- `getRelation(entityType, entityId)` - Get current relation value (-100 to +100)
- `setRelation(entityType, entityId, value)` - Set relation to specific value
- `modifyRelation(entityType, entityId, delta, reason)` - Change relation by delta
- `getRelationLabel(value)` - Get descriptive label ("Allied", "Hostile", etc.)
- `getRelationColor(value)` - Get RGB color for relation value
- `updateAllRelations(daysPassed)` - Apply time-based decay

### Entity Types
- `"country"` - Relations with funding countries
- `"supplier"` - Relations with marketplace suppliers
- `"faction"` - Relations with alien/enemy factions
```

---

## Notes

- Relations are a core strategic mechanic affecting three major systems
- Balance is critical: too strong effects = no challenge, too weak = ignored
- Consider adding "relation change notifications" to UI for player feedback
- Future expansion: treaties, trade agreements, faction diplomacy
- Relations could unlock special technologies or units at high values

---

## Blockers

None currently. System is self-contained but requires:
- Funding system to be functional (for country relations)
- Marketplace system to be functional (for supplier relations)
- Mission generation system to be functional (for faction relations)

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (O(1) lookups, minimal overhead)
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] No warnings in Love2D console
- [ ] UI components grid-aligned (24×24 pixels)
- [ ] Theme system used for all colors/fonts
- [ ] Save/load functionality tested

---

## Post-Completion

### What Worked Well
- (To be filled after completion)

### What Could Be Improved
- (To be filled after completion)

### Lessons Learned
- (To be filled after completion)
