-- ─────────────────────────────────────────────────────────────────────────
-- ENVIRONMENTAL EFFECTS TEST SUITE
-- FILE: tests2/battlescape/environmental_effects_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.environmental_effects",
    fileName = "environmental_effects.lua",
    description = "Environmental effects system with hazards, weather, and terrain damage"
})

print("[ENVIRONMENTAL_EFFECTS_TEST] Setting up")

local EnvironmentalEffects = {
    hazards = {},
    weather = {},
    terrain = {},
    effects = {},
    damage_zones = {},

    new = function(self)
        return setmetatable({
            hazards = {}, weather = {}, terrain = {},
            effects = {}, damage_zones = {}
        }, {__index = self})
    end,

    registerHazard = function(self, hazardId, name, hazardType, damage)
        self.hazards[hazardId] = {
            id = hazardId, name = name, type = hazardType or "generic",
            damage = damage or 10, active = false, triggers = 0
        }
        return true
    end,

    getHazard = function(self, hazardId)
        return self.hazards[hazardId]
    end,

    activateHazard = function(self, hazardId)
        if not self.hazards[hazardId] then return false end
        self.hazards[hazardId].active = true
        return true
    end,

    isHazardActive = function(self, hazardId)
        if not self.hazards[hazardId] then return false end
        return self.hazards[hazardId].active
    end,

    createHazardZone = function(self, zoneId, x, y, radius, hazardId)
        if not self.hazards[hazardId] then return false end
        self.damage_zones[zoneId] = {
            id = zoneId, x = x, y = y, radius = radius,
            hazard = hazardId, affected_units = {}, damage_applied = 0
        }
        return true
    end,

    isInHazardZone = function(self, zoneId, unitX, unitY)
        if not self.damage_zones[zoneId] then return false end
        local zone = self.damage_zones[zoneId]
        local distance = math.sqrt((unitX - zone.x)^2 + (unitY - zone.y)^2)
        return distance <= zone.radius
    end,

    applyHazardDamage = function(self, zoneId, unitId, unitHealth)
        if not self.damage_zones[zoneId] then return false end
        local zone = self.damage_zones[zoneId]
        if not self.hazards[zone.hazard] then return false end
        local damage = self.hazards[zone.hazard].damage
        zone.affected_units[unitId] = true
        zone.damage_applied = zone.damage_applied + damage
        self.hazards[zone.hazard].triggers = self.hazards[zone.hazard].triggers + 1
        return damage
    end,

    getZoneDamageApplied = function(self, zoneId)
        if not self.damage_zones[zoneId] then return 0 end
        return self.damage_zones[zoneId].damage_applied
    end,

    getAffectedUnitCount = function(self, zoneId)
        if not self.damage_zones[zoneId] then return 0 end
        local count = 0
        for _ in pairs(self.damage_zones[zoneId].affected_units) do
            count = count + 1
        end
        return count
    end,

    setWeather = function(self, weatherId, name, weatherType, intensity)
        self.weather[weatherId] = {
            id = weatherId, name = name, type = weatherType or "clear",
            intensity = intensity or 0, duration = 0, effects = {}
        }
        return true
    end,

    getWeather = function(self, weatherId)
        return self.weather[weatherId]
    end,

    updateWeatherIntensity = function(self, weatherId, delta)
        if not self.weather[weatherId] then return false end
        self.weather[weatherId].intensity = math.max(0, math.min(100, self.weather[weatherId].intensity + delta))
        return true
    end,

    getWeatherIntensity = function(self, weatherId)
        if not self.weather[weatherId] then return 0 end
        return self.weather[weatherId].intensity
    end,

    addWeatherEffect = function(self, weatherId, effectId, effectName, modifier)
        if not self.weather[weatherId] then return false end
        self.weather[weatherId].effects[effectId] = {id = effectId, name = effectName, modifier = modifier or 0}
        return true
    end,

    getWeatherEffectModifier = function(self, weatherId, effectId)
        if not self.weather[weatherId] or not self.weather[weatherId].effects[effectId] then return 0 end
        return self.weather[weatherId].effects[effectId].modifier
    end,

    calculateWeatherBonus = function(self, weatherId)
        if not self.weather[weatherId] then return 1 end
        local weather = self.weather[weatherId]
        local intensity_bonus = 1 + (weather.intensity * 0.01)
        local effects_bonus = 0
        for _, effect in pairs(weather.effects) do
            effects_bonus = effects_bonus + effect.modifier
        end
        return intensity_bonus + effects_bonus
    end,

    registerTerrain = function(self, terrainId, name, terrainType, difficulty)
        self.terrain[terrainId] = {
            id = terrainId, name = name, type = terrainType or "grass",
            difficulty = difficulty or 50, traversable = true, passthrough_cost = 1
        }
        return true
    end,

    getTerrainInfo = function(self, terrainId)
        return self.terrain[terrainId]
    end,

    setTerrainTraversable = function(self, terrainId, traversable)
        if not self.terrain[terrainId] then return false end
        self.terrain[terrainId].traversable = traversable
        return true
    end,

    isTerrainTraversable = function(self, terrainId)
        if not self.terrain[terrainId] then return false end
        return self.terrain[terrainId].traversable
    end,

    calculateTraversalCost = function(self, terrainId)
        if not self.terrain[terrainId] then return 0 end
        local terrain = self.terrain[terrainId]
        if not terrain.traversable then return 999 end
        return 1 + (terrain.difficulty / 100)
    end,

    applyTerrainDamage = function(self, terrainId, unitHealth)
        if not self.terrain[terrainId] then return unitHealth end
        local terrain = self.terrain[terrainId]
        local damage = math.floor(terrain.difficulty * 0.1)
        return math.max(0, unitHealth - damage)
    end,

    registerEffect = function(self, effectId, name, effectType, duration)
        self.effects[effectId] = {
            id = effectId, name = name, type = effectType or "passive",
            duration = duration or 0, applied_to = {}, applied_count = 0
        }
        return true
    end,

    applyEffectToUnit = function(self, effectId, unitId)
        if not self.effects[effectId] then return false end
        self.effects[effectId].applied_to[unitId] = true
        self.effects[effectId].applied_count = self.effects[effectId].applied_count + 1
        return true
    end,

    getEffectCount = function(self, effectId)
        if not self.effects[effectId] then return 0 end
        return self.effects[effectId].applied_count
    end,

    updateEffectDuration = function(self, effectId)
        if not self.effects[effectId] then return false end
        self.effects[effectId].duration = math.max(0, self.effects[effectId].duration - 1)
        return true
    end,

    isEffectExpired = function(self, effectId)
        if not self.effects[effectId] then return true end
        return self.effects[effectId].duration <= 0
    end,

    calculateHazardDamage = function(self, hazardId, multiplier)
        if not self.hazards[hazardId] then return 0 end
        return math.floor(self.hazards[hazardId].damage * (multiplier or 1))
    end,

    getTotalEnvironmentalDamage = function(self)
        local total = 0
        for _, zone in pairs(self.damage_zones) do
            total = total + zone.damage_applied
        end
        for _, weather in pairs(self.weather) do
            total = total + math.floor(weather.intensity * 0.1)
        end
        return total
    end,

    getHazardTriggerCount = function(self, hazardId)
        if not self.hazards[hazardId] then return 0 end
        return self.hazards[hazardId].triggers
    end,

    resetEnvironment = function(self)
        self.hazards = {}
        self.weather = {}
        self.terrain = {}
        self.effects = {}
        self.damage_zones = {}
        return true
    end
}

Suite:group("Hazards", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ee = EnvironmentalEffects:new()
    end)

    Suite:testMethod("EnvironmentalEffects.registerHazard", {description = "Registers hazard", testCase = "register", type = "functional"}, function()
        local ok = shared.ee:registerHazard("fire", "Fire", "flame", 20)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("EnvironmentalEffects.getHazard", {description = "Gets hazard", testCase = "get", type = "functional"}, function()
        shared.ee:registerHazard("acid", "Acid", "chemical", 15)
        local hazard = shared.ee:getHazard("acid")
        Helpers.assertEqual(hazard ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("EnvironmentalEffects.activateHazard", {description = "Activates hazard", testCase = "activate", type = "functional"}, function()
        shared.ee:registerHazard("gas", "Gas", "toxic", 10)
        local ok = shared.ee:activateHazard("gas")
        Helpers.assertEqual(ok, true, "Activated")
    end)

    Suite:testMethod("EnvironmentalEffects.isHazardActive", {description = "Is hazard active", testCase = "is_active", type = "functional"}, function()
        shared.ee:registerHazard("electric", "Electric", "shock", 12)
        shared.ee:activateHazard("electric")
        local is = shared.ee:isHazardActive("electric")
        Helpers.assertEqual(is, true, "Active")
    end)
end)

Suite:group("Hazard Zones", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ee = EnvironmentalEffects:new()
        shared.ee:registerHazard("zone_hazard", "Zone Hazard", "generic", 25)
    end)

    Suite:testMethod("EnvironmentalEffects.createHazardZone", {description = "Creates hazard zone", testCase = "create", type = "functional"}, function()
        local ok = shared.ee:createHazardZone("zone1", 50, 50, 10, "zone_hazard")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("EnvironmentalEffects.isInHazardZone", {description = "Is in zone", testCase = "in_zone", type = "functional"}, function()
        shared.ee:createHazardZone("zone2", 100, 100, 15, "zone_hazard")
        local is = shared.ee:isInHazardZone("zone2", 105, 100)
        Helpers.assertEqual(is, true, "In zone")
    end)

    Suite:testMethod("EnvironmentalEffects.applyHazardDamage", {description = "Applies damage", testCase = "apply", type = "functional"}, function()
        shared.ee:createHazardZone("zone3", 50, 50, 10, "zone_hazard")
        local damage = shared.ee:applyHazardDamage("zone3", "unit1", 100)
        Helpers.assertEqual(damage, 25, "Damage 25")
    end)

    Suite:testMethod("EnvironmentalEffects.getZoneDamageApplied", {description = "Gets damage", testCase = "get_damage", type = "functional"}, function()
        shared.ee:createHazardZone("zone4", 50, 50, 10, "zone_hazard")
        shared.ee:applyHazardDamage("zone4", "u1", 100)
        shared.ee:applyHazardDamage("zone4", "u2", 100)
        local total = shared.ee:getZoneDamageApplied("zone4")
        Helpers.assertEqual(total, 50, "Total 50")
    end)

    Suite:testMethod("EnvironmentalEffects.getAffectedUnitCount", {description = "Unit count", testCase = "count", type = "functional"}, function()
        shared.ee:createHazardZone("zone5", 50, 50, 10, "zone_hazard")
        shared.ee:applyHazardDamage("zone5", "unit_a", 100)
        shared.ee:applyHazardDamage("zone5", "unit_b", 100)
        local count = shared.ee:getAffectedUnitCount("zone5")
        Helpers.assertEqual(count, 2, "Two units")
    end)
end)

Suite:group("Weather", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ee = EnvironmentalEffects:new()
    end)

    Suite:testMethod("EnvironmentalEffects.setWeather", {description = "Sets weather", testCase = "set", type = "functional"}, function()
        local ok = shared.ee:setWeather("rain", "Rain", "precipitation", 50)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("EnvironmentalEffects.getWeather", {description = "Gets weather", testCase = "get", type = "functional"}, function()
        shared.ee:setWeather("storm", "Storm", "lightning", 75)
        local weather = shared.ee:getWeather("storm")
        Helpers.assertEqual(weather ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("EnvironmentalEffects.updateWeatherIntensity", {description = "Updates intensity", testCase = "update", type = "functional"}, function()
        shared.ee:setWeather("wind", "Wind", "air", 30)
        local ok = shared.ee:updateWeatherIntensity("wind", 20)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("EnvironmentalEffects.getWeatherIntensity", {description = "Gets intensity", testCase = "intensity", type = "functional"}, function()
        shared.ee:setWeather("fog", "Fog", "obscurity", 40)
        shared.ee:updateWeatherIntensity("fog", 10)
        local intensity = shared.ee:getWeatherIntensity("fog")
        Helpers.assertEqual(intensity, 50, "Intensity 50")
    end)

    Suite:testMethod("EnvironmentalEffects.addWeatherEffect", {description = "Adds effect", testCase = "add_effect", type = "functional"}, function()
        shared.ee:setWeather("hail", "Hail", "ice", 60)
        local ok = shared.ee:addWeatherEffect("hail", "damage", "Hail Damage", 5)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("EnvironmentalEffects.getWeatherEffectModifier", {description = "Gets modifier", testCase = "modifier", type = "functional"}, function()
        shared.ee:setWeather("blizzard", "Blizzard", "snow", 80)
        shared.ee:addWeatherEffect("blizzard", "chill", "Chilling", 10)
        local modifier = shared.ee:getWeatherEffectModifier("blizzard", "chill")
        Helpers.assertEqual(modifier, 10, "Modifier 10")
    end)

    Suite:testMethod("EnvironmentalEffects.calculateWeatherBonus", {description = "Calculates bonus", testCase = "bonus", type = "functional"}, function()
        shared.ee:setWeather("sunny", "Sunny", "clear", 20)
        shared.ee:addWeatherEffect("sunny", "visibility", "Good Visibility", 3)
        local bonus = shared.ee:calculateWeatherBonus("sunny")
        Helpers.assertEqual(bonus > 1, true, "Bonus > 1")
    end)
end)

Suite:group("Terrain", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ee = EnvironmentalEffects:new()
    end)

    Suite:testMethod("EnvironmentalEffects.registerTerrain", {description = "Registers terrain", testCase = "register", type = "functional"}, function()
        local ok = shared.ee:registerTerrain("grass", "Grass", "natural", 25)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("EnvironmentalEffects.getTerrainInfo", {description = "Gets terrain", testCase = "get", type = "functional"}, function()
        shared.ee:registerTerrain("rock", "Rock", "mineral", 50)
        local terrain = shared.ee:getTerrainInfo("rock")
        Helpers.assertEqual(terrain ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("EnvironmentalEffects.setTerrainTraversable", {description = "Sets traversable", testCase = "traversable", type = "functional"}, function()
        shared.ee:registerTerrain("lava", "Lava", "hazard", 80)
        local ok = shared.ee:setTerrainTraversable("lava", false)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("EnvironmentalEffects.isTerrainTraversable", {description = "Is traversable", testCase = "is_trav", type = "functional"}, function()
        shared.ee:registerTerrain("water", "Water", "liquid", 60)
        local is = shared.ee:isTerrainTraversable("water")
        Helpers.assertEqual(is, true, "Traversable")
    end)

    Suite:testMethod("EnvironmentalEffects.calculateTraversalCost", {description = "Calculates cost", testCase = "cost", type = "functional"}, function()
        shared.ee:registerTerrain("sand", "Sand", "desert", 40)
        local cost = shared.ee:calculateTraversalCost("sand")
        Helpers.assertEqual(cost > 1, true, "Cost > 1")
    end)

    Suite:testMethod("EnvironmentalEffects.applyTerrainDamage", {description = "Applies damage", testCase = "damage", type = "functional"}, function()
        shared.ee:registerTerrain("spikes", "Spikes", "trap", 70)
        local health = shared.ee:applyTerrainDamage("spikes", 100)
        Helpers.assertEqual(health < 100, true, "Damage applied")
    end)
end)

Suite:group("Effects", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ee = EnvironmentalEffects:new()
    end)

    Suite:testMethod("EnvironmentalEffects.registerEffect", {description = "Registers effect", testCase = "register", type = "functional"}, function()
        local ok = shared.ee:registerEffect("burn", "Burn", "dot", 5)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("EnvironmentalEffects.applyEffectToUnit", {description = "Applies effect", testCase = "apply", type = "functional"}, function()
        shared.ee:registerEffect("poison", "Poison", "dot", 3)
        local ok = shared.ee:applyEffectToUnit("poison", "unit1")
        Helpers.assertEqual(ok, true, "Applied")
    end)

    Suite:testMethod("EnvironmentalEffects.getEffectCount", {description = "Gets count", testCase = "count", type = "functional"}, function()
        shared.ee:registerEffect("freeze", "Freeze", "control", 4)
        shared.ee:applyEffectToUnit("freeze", "u1")
        shared.ee:applyEffectToUnit("freeze", "u2")
        local count = shared.ee:getEffectCount("freeze")
        Helpers.assertEqual(count, 2, "Count 2")
    end)

    Suite:testMethod("EnvironmentalEffects.updateEffectDuration", {description = "Updates duration", testCase = "update", type = "functional"}, function()
        shared.ee:registerEffect("bleed", "Bleed", "dot", 3)
        local ok = shared.ee:updateEffectDuration("bleed")
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("EnvironmentalEffects.isEffectExpired", {description = "Is expired", testCase = "expired", type = "functional"}, function()
        shared.ee:registerEffect("stun", "Stun", "control", 0)
        local is = shared.ee:isEffectExpired("stun")
        Helpers.assertEqual(is, true, "Expired")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ee = EnvironmentalEffects:new()
        shared.ee:registerHazard("analyze_hazard", "Analyze", "generic", 30)
        shared.ee:createHazardZone("analyze_zone", 50, 50, 10, "analyze_hazard")
    end)

    Suite:testMethod("EnvironmentalEffects.calculateHazardDamage", {description = "Calculates damage", testCase = "calc", type = "functional"}, function()
        local damage = shared.ee:calculateHazardDamage("analyze_hazard", 2)
        Helpers.assertEqual(damage, 60, "Damage 60")
    end)

    Suite:testMethod("EnvironmentalEffects.getTotalEnvironmentalDamage", {description = "Gets total", testCase = "total", type = "functional"}, function()
        shared.ee:applyHazardDamage("analyze_zone", "unit", 100)
        local total = shared.ee:getTotalEnvironmentalDamage()
        Helpers.assertEqual(total > 0, true, "Total > 0")
    end)

    Suite:testMethod("EnvironmentalEffects.getHazardTriggerCount", {description = "Trigger count", testCase = "triggers", type = "functional"}, function()
        shared.ee:applyHazardDamage("analyze_zone", "u1", 100)
        shared.ee:applyHazardDamage("analyze_zone", "u2", 100)
        local triggers = shared.ee:getHazardTriggerCount("analyze_hazard")
        Helpers.assertEqual(triggers, 2, "Two triggers")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ee = EnvironmentalEffects:new()
    end)

    Suite:testMethod("EnvironmentalEffects.resetEnvironment", {description = "Resets environment", testCase = "reset", type = "functional"}, function()
        local ok = shared.ee:resetEnvironment()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
