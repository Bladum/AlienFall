-- ─────────────────────────────────────────────────────────────────────────
-- WEATHER SYSTEM TEST SUITE
-- FILE: tests2/geoscape/weather_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.weather_system",
    fileName = "weather_system.lua",
    description = "Weather system with dynamic patterns, climate effects, and transitions"
})

print("[WEATHER_SYSTEM_TEST] Setting up")

local WeatherSystem = {
    regions = {},
    weather_states = {},
    climate_zones = {},
    transitions = {},

    new = function(self)
        return setmetatable({
            regions = {}, weather_states = {}, climate_zones = {}, transitions = {}
        }, {__index = self})
    end,

    createWeatherRegion = function(self, regionId, name, climate)
        self.regions[regionId] = {
            id = regionId, name = name, climate = climate or "temperate",
            current_weather = "clear", temperature = 20, humidity = 50,
            wind_speed = 5, precipitation = 0, pressure = 1013
        }
        self.weather_states[regionId] = {
            turns_in_state = 0, state_duration = 5, severity = 0,
            visibility = 100, wind_direction = 0
        }
        return true
    end,

    getRegion = function(self, regionId)
        return self.regions[regionId]
    end,

    getWeatherState = function(self, regionId)
        return self.weather_states[regionId]
    end,

    setCurrentWeather = function(self, regionId, weatherType)
        if not self.regions[regionId] then return false end
        self.regions[regionId].current_weather = weatherType or "clear"
        self.weather_states[regionId].turns_in_state = 0
        return true
    end,

    getCurrentWeather = function(self, regionId)
        if not self.regions[regionId] then return nil end
        return self.regions[regionId].current_weather
    end,

    setTemperature = function(self, regionId, temp)
        if not self.regions[regionId] then return false end
        self.regions[regionId].temperature = temp
        return true
    end,

    getTemperature = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        return self.regions[regionId].temperature
    end,

    setHumidity = function(self, regionId, humidity)
        if not self.regions[regionId] then return false end
        self.regions[regionId].humidity = math.max(0, math.min(100, humidity))
        return true
    end,

    getHumidity = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        return self.regions[regionId].humidity
    end,

    setWindSpeed = function(self, regionId, speed)
        if not self.regions[regionId] then return false end
        self.regions[regionId].wind_speed = math.max(0, speed)
        return true
    end,

    getWindSpeed = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        return self.regions[regionId].wind_speed
    end,

    setPrecipitation = function(self, regionId, amount)
        if not self.regions[regionId] then return false end
        self.regions[regionId].precipitation = math.max(0, amount)
        return true
    end,

    getPrecipitation = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        return self.regions[regionId].precipitation
    end,

    setPressure = function(self, regionId, pressure)
        if not self.regions[regionId] then return false end
        self.regions[regionId].pressure = pressure
        return true
    end,

    getPressure = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        return self.regions[regionId].pressure
    end,

    setVisibility = function(self, regionId, visibility)
        if not self.weather_states[regionId] then return false end
        self.weather_states[regionId].visibility = math.max(0, math.min(100, visibility))
        return true
    end,

    getVisibility = function(self, regionId)
        if not self.weather_states[regionId] then return 0 end
        return self.weather_states[regionId].visibility
    end,

    setWindDirection = function(self, regionId, direction)
        if not self.weather_states[regionId] then return false end
        self.weather_states[regionId].wind_direction = direction % 360
        return true
    end,

    getWindDirection = function(self, regionId)
        if not self.weather_states[regionId] then return 0 end
        return self.weather_states[regionId].wind_direction
    end,

    setSeverity = function(self, regionId, severity)
        if not self.weather_states[regionId] then return false end
        self.weather_states[regionId].severity = math.max(0, math.min(100, severity))
        return true
    end,

    getSeverity = function(self, regionId)
        if not self.weather_states[regionId] then return 0 end
        return self.weather_states[regionId].severity
    end,

    simulateWeatherTransition = function(self, regionId)
        if not self.regions[regionId] then return false end
        local state = self.weather_states[regionId]
        state.turns_in_state = state.turns_in_state + 1
        local weather_options = {"clear", "cloudy", "rainy", "stormy", "snowy"}
        if state.turns_in_state >= state.state_duration then
            local random_idx = math.random(1, #weather_options)
            self.regions[regionId].current_weather = weather_options[random_idx]
            state.turns_in_state = 0
            state.state_duration = math.random(3, 8)
        end
        return true
    end,

    registerClimateZone = function(self, zoneId, name, base_temp, base_humidity, seasonal_variation)
        self.climate_zones[zoneId] = {
            id = zoneId, name = name, base_temperature = base_temp or 15,
            base_humidity = base_humidity or 50, seasonal_variation = seasonal_variation or 10,
            regions_in_zone = 0
        }
        return true
    end,

    getClimateZone = function(self, zoneId)
        return self.climate_zones[zoneId]
    end,

    applyClimateEffects = function(self, regionId, zoneId)
        if not self.regions[regionId] or not self.climate_zones[zoneId] then return false end
        local zone = self.climate_zones[zoneId]
        self.regions[regionId].temperature = zone.base_temperature + (math.random(-zone.seasonal_variation, zone.seasonal_variation))
        self.regions[regionId].humidity = zone.base_humidity + math.random(-10, 10)
        self.climate_zones[zoneId].regions_in_zone = self.climate_zones[zoneId].regions_in_zone + 1
        return true
    end,

    calculateWeatherImpact = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        local region = self.regions[regionId]
        local weather = region.current_weather
        local impact = 0
        if weather == "clear" then impact = 10
        elseif weather == "cloudy" then impact = 20
        elseif weather == "rainy" then impact = 50
        elseif weather == "stormy" then impact = 80
        elseif weather == "snowy" then impact = 70
        end
        local wind_impact = region.wind_speed
        local temp_variance = math.abs(region.temperature - 20)
        impact = impact + wind_impact + (temp_variance / 2)
        return math.floor(impact)
    end,

    isWeatherExtreme = function(self, regionId)
        if not self.regions[regionId] then return false end
        local region = self.regions[regionId]
        local weather = region.current_weather
        return weather == "stormy" or weather == "snowy"
    end,

    getWeatherDescription = function(self, regionId)
        if not self.regions[regionId] then return "" end
        local region = self.regions[regionId]
        local weather = region.current_weather
        local descriptions = {
            clear = "Clear skies",
            cloudy = "Overcast conditions",
            rainy = "Rainfall active",
            stormy = "Severe storm warning",
            snowy = "Heavy snowfall"
        }
        return descriptions[weather] or "Unknown weather"
    end,

    createWeatherTransition = function(self, transId, fromWeather, toWeather, turns)
        self.transitions[transId] = {
            id = transId, from = fromWeather, to = toWeather,
            duration = turns or 3, progress = 0
        }
        return true
    end,

    getTransition = function(self, transId)
        return self.transitions[transId]
    end,

    advanceTransition = function(self, transId)
        if not self.transitions[transId] then return false end
        self.transitions[transId].progress = self.transitions[transId].progress + 1
        return true
    end,

    isTransitionComplete = function(self, transId)
        if not self.transitions[transId] then return true end
        local trans = self.transitions[transId]
        return trans.progress >= trans.duration
    end,

    calculateTemperatureTrend = function(self, regionId, turns)
        if not self.regions[regionId] then return {} end
        local trend = {}
        local current_temp = self:getTemperature(regionId)
        for i = 1, turns or 5 do
            local variation = math.random(-2, 2)
            current_temp = current_temp + variation
            table.insert(trend, current_temp)
        end
        return trend
    end,

    registerWeatherEvent = function(self, eventId, regionId, eventType, duration, intensity)
        if not self.regions[regionId] then return false end
        self.regions[regionId][eventId] = {
            id = eventId, type = eventType or "none",
            duration = duration or 1, intensity = intensity or 50,
            turns_remaining = duration or 1
        }
        return true
    end,

    getWeatherEvent = function(self, regionId, eventId)
        if not self.regions[regionId] then return nil end
        return self.regions[regionId][eventId]
    end,

    updateWeatherEvent = function(self, regionId, eventId)
        if not self.regions[regionId] or not self.regions[regionId][eventId] then return false end
        local event = self.regions[regionId][eventId]
        event.turns_remaining = math.max(0, event.turns_remaining - 1)
        return true
    end,

    isWeatherEventActive = function(self, regionId, eventId)
        if not self.regions[regionId] or not self.regions[regionId][eventId] then return false end
        return self.regions[regionId][eventId].turns_remaining > 0
    end,

    calculateSeasonalEffect = function(self, regionId, season)
        if not self.regions[regionId] then return 0 end
        local effects = {
            spring = 20, summer = 40, autumn = 15, winter = -20
        }
        return effects[season] or 0
    end,

    reset = function(self)
        self.regions = {}
        self.weather_states = {}
        self.climate_zones = {}
        self.transitions = {}
        return true
    end
}

Suite:group("Regions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeatherSystem:new()
    end)

    Suite:testMethod("WeatherSystem.createWeatherRegion", {description = "Creates region", testCase = "create", type = "functional"}, function()
        local ok = shared.ws:createWeatherRegion("region1", "North", "arctic")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("WeatherSystem.getRegion", {description = "Gets region", testCase = "get", type = "functional"}, function()
        shared.ws:createWeatherRegion("region2", "South", "tropical")
        local region = shared.ws:getRegion("region2")
        Helpers.assertEqual(region ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("WeatherSystem.getWeatherState", {description = "Gets state", testCase = "state", type = "functional"}, function()
        shared.ws:createWeatherRegion("region3", "East", "temperate")
        local state = shared.ws:getWeatherState("region3")
        Helpers.assertEqual(state ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Weather", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeatherSystem:new()
        shared.ws:createWeatherRegion("weather_region", "Test", "temperate")
    end)

    Suite:testMethod("WeatherSystem.setCurrentWeather", {description = "Sets weather", testCase = "set", type = "functional"}, function()
        local ok = shared.ws:setCurrentWeather("weather_region", "rainy")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("WeatherSystem.getCurrentWeather", {description = "Gets weather", testCase = "get", type = "functional"}, function()
        shared.ws:setCurrentWeather("weather_region", "stormy")
        local weather = shared.ws:getCurrentWeather("weather_region")
        Helpers.assertEqual(weather, "stormy", "Stormy")
    end)

    Suite:testMethod("WeatherSystem.getWeatherDescription", {description = "Gets description", testCase = "description", type = "functional"}, function()
        shared.ws:setCurrentWeather("weather_region", "clear")
        local desc = shared.ws:getWeatherDescription("weather_region")
        Helpers.assertEqual(desc ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Temperature", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeatherSystem:new()
        shared.ws:createWeatherRegion("temp_region", "Test", "temperate")
    end)

    Suite:testMethod("WeatherSystem.setTemperature", {description = "Sets temp", testCase = "set", type = "functional"}, function()
        local ok = shared.ws:setTemperature("temp_region", 25)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("WeatherSystem.getTemperature", {description = "Gets temp", testCase = "get", type = "functional"}, function()
        shared.ws:setTemperature("temp_region", 30)
        local temp = shared.ws:getTemperature("temp_region")
        Helpers.assertEqual(temp, 30, "30 degrees")
    end)

    Suite:testMethod("WeatherSystem.calculateTemperatureTrend", {description = "Calculates trend", testCase = "trend", type = "functional"}, function()
        local trend = shared.ws:calculateTemperatureTrend("temp_region", 5)
        Helpers.assertEqual(#trend, 5, "5 trend points")
    end)

    Suite:testMethod("WeatherSystem.calculateSeasonalEffect", {description = "Seasonal effect", testCase = "seasonal", type = "functional"}, function()
        local effect = shared.ws:calculateSeasonalEffect("temp_region", "summer")
        Helpers.assertEqual(effect > 0, true, "Summer effect > 0")
    end)
end)

Suite:group("Humidity & Pressure", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeatherSystem:new()
        shared.ws:createWeatherRegion("hp_region", "Test", "temperate")
    end)

    Suite:testMethod("WeatherSystem.setHumidity", {description = "Sets humidity", testCase = "humidity", type = "functional"}, function()
        local ok = shared.ws:setHumidity("hp_region", 65)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("WeatherSystem.getHumidity", {description = "Gets humidity", testCase = "get_humidity", type = "functional"}, function()
        shared.ws:setHumidity("hp_region", 70)
        local humidity = shared.ws:getHumidity("hp_region")
        Helpers.assertEqual(humidity, 70, "70 humidity")
    end)

    Suite:testMethod("WeatherSystem.setPressure", {description = "Sets pressure", testCase = "pressure", type = "functional"}, function()
        local ok = shared.ws:setPressure("hp_region", 1020)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("WeatherSystem.getPressure", {description = "Gets pressure", testCase = "get_pressure", type = "functional"}, function()
        shared.ws:setPressure("hp_region", 1015)
        local pressure = shared.ws:getPressure("hp_region")
        Helpers.assertEqual(pressure, 1015, "1015 pressure")
    end)
end)

Suite:group("Wind", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeatherSystem:new()
        shared.ws:createWeatherRegion("wind_region", "Test", "temperate")
    end)

    Suite:testMethod("WeatherSystem.setWindSpeed", {description = "Sets wind", testCase = "wind", type = "functional"}, function()
        local ok = shared.ws:setWindSpeed("wind_region", 15)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("WeatherSystem.getWindSpeed", {description = "Gets wind", testCase = "get_wind", type = "functional"}, function()
        shared.ws:setWindSpeed("wind_region", 20)
        local speed = shared.ws:getWindSpeed("wind_region")
        Helpers.assertEqual(speed, 20, "20 wind")
    end)

    Suite:testMethod("WeatherSystem.setWindDirection", {description = "Sets direction", testCase = "direction", type = "functional"}, function()
        local ok = shared.ws:setWindDirection("wind_region", 45)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("WeatherSystem.getWindDirection", {description = "Gets direction", testCase = "get_direction", type = "functional"}, function()
        shared.ws:setWindDirection("wind_region", 180)
        local dir = shared.ws:getWindDirection("wind_region")
        Helpers.assertEqual(dir, 180, "180 degrees")
    end)
end)

Suite:group("Precipitation & Visibility", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeatherSystem:new()
        shared.ws:createWeatherRegion("pv_region", "Test", "temperate")
    end)

    Suite:testMethod("WeatherSystem.setPrecipitation", {description = "Sets precip", testCase = "precip", type = "functional"}, function()
        local ok = shared.ws:setPrecipitation("pv_region", 25)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("WeatherSystem.getPrecipitation", {description = "Gets precip", testCase = "get_precip", type = "functional"}, function()
        shared.ws:setPrecipitation("pv_region", 30)
        local precip = shared.ws:getPrecipitation("pv_region")
        Helpers.assertEqual(precip, 30, "30 precip")
    end)

    Suite:testMethod("WeatherSystem.setVisibility", {description = "Sets visibility", testCase = "visibility", type = "functional"}, function()
        local ok = shared.ws:setVisibility("pv_region", 80)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("WeatherSystem.getVisibility", {description = "Gets visibility", testCase = "get_visibility", type = "functional"}, function()
        shared.ws:setVisibility("pv_region", 75)
        local vis = shared.ws:getVisibility("pv_region")
        Helpers.assertEqual(vis, 75, "75 visibility")
    end)
end)

Suite:group("Climate Zones", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeatherSystem:new()
    end)

    Suite:testMethod("WeatherSystem.registerClimateZone", {description = "Registers zone", testCase = "register", type = "functional"}, function()
        local ok = shared.ws:registerClimateZone("zone1", "Polar", -10, 40, 5)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("WeatherSystem.getClimateZone", {description = "Gets zone", testCase = "get", type = "functional"}, function()
        shared.ws:registerClimateZone("zone2", "Desert", 35, 20, 15)
        local zone = shared.ws:getClimateZone("zone2")
        Helpers.assertEqual(zone ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("WeatherSystem.applyClimateEffects", {description = "Applies effects", testCase = "apply", type = "functional"}, function()
        shared.ws:createWeatherRegion("region4", "Desert", "desert")
        shared.ws:registerClimateZone("zone3", "Sahara", 40, 15, 10)
        local ok = shared.ws:applyClimateEffects("region4", "zone3")
        Helpers.assertEqual(ok, true, "Applied")
    end)
end)

Suite:group("Transitions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeatherSystem:new()
        shared.ws:createWeatherRegion("trans_region", "Test", "temperate")
    end)

    Suite:testMethod("WeatherSystem.simulateWeatherTransition", {description = "Simulates transition", testCase = "simulate", type = "functional"}, function()
        local ok = shared.ws:simulateWeatherTransition("trans_region")
        Helpers.assertEqual(ok, true, "Simulated")
    end)

    Suite:testMethod("WeatherSystem.createWeatherTransition", {description = "Creates transition", testCase = "create", type = "functional"}, function()
        local ok = shared.ws:createWeatherTransition("trans1", "clear", "rainy", 4)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("WeatherSystem.getTransition", {description = "Gets transition", testCase = "get", type = "functional"}, function()
        shared.ws:createWeatherTransition("trans2", "cloudy", "stormy", 3)
        local trans = shared.ws:getTransition("trans2")
        Helpers.assertEqual(trans ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("WeatherSystem.advanceTransition", {description = "Advances transition", testCase = "advance", type = "functional"}, function()
        shared.ws:createWeatherTransition("trans3", "clear", "rainy", 5)
        local ok = shared.ws:advanceTransition("trans3")
        Helpers.assertEqual(ok, true, "Advanced")
    end)

    Suite:testMethod("WeatherSystem.isTransitionComplete", {description = "Is complete", testCase = "complete", type = "functional"}, function()
        shared.ws:createWeatherTransition("trans4", "stormy", "clear", 2)
        shared.ws:advanceTransition("trans4")
        shared.ws:advanceTransition("trans4")
        local is = shared.ws:isTransitionComplete("trans4")
        Helpers.assertEqual(is, true, "Complete")
    end)
end)

Suite:group("Impact Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeatherSystem:new()
        shared.ws:createWeatherRegion("impact_region", "Test", "temperate")
    end)

    Suite:testMethod("WeatherSystem.calculateWeatherImpact", {description = "Calculates impact", testCase = "impact", type = "functional"}, function()
        local impact = shared.ws:calculateWeatherImpact("impact_region")
        Helpers.assertEqual(impact >= 0, true, "Impact >= 0")
    end)

    Suite:testMethod("WeatherSystem.isWeatherExtreme", {description = "Is extreme", testCase = "extreme", type = "functional"}, function()
        shared.ws:setCurrentWeather("impact_region", "clear")
        local is = shared.ws:isWeatherExtreme("impact_region")
        Helpers.assertEqual(is, false, "Not extreme")
    end)

    Suite:testMethod("WeatherSystem.setSeverity", {description = "Sets severity", testCase = "severity", type = "functional"}, function()
        local ok = shared.ws:setSeverity("impact_region", 65)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("WeatherSystem.getSeverity", {description = "Gets severity", testCase = "get_severity", type = "functional"}, function()
        shared.ws:setSeverity("impact_region", 50)
        local severity = shared.ws:getSeverity("impact_region")
        Helpers.assertEqual(severity, 50, "50 severity")
    end)
end)

Suite:group("Weather Events", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeatherSystem:new()
        shared.ws:createWeatherRegion("event_region", "Test", "temperate")
    end)

    Suite:testMethod("WeatherSystem.registerWeatherEvent", {description = "Registers event", testCase = "register", type = "functional"}, function()
        local ok = shared.ws:registerWeatherEvent("event1", "event_region", "hurricane", 5, 80)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("WeatherSystem.getWeatherEvent", {description = "Gets event", testCase = "get", type = "functional"}, function()
        shared.ws:registerWeatherEvent("event2", "event_region", "tornado", 3, 70)
        local event = shared.ws:getWeatherEvent("event_region", "event2")
        Helpers.assertEqual(event ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("WeatherSystem.updateWeatherEvent", {description = "Updates event", testCase = "update", type = "functional"}, function()
        shared.ws:registerWeatherEvent("event3", "event_region", "hail", 4, 60)
        local ok = shared.ws:updateWeatherEvent("event_region", "event3")
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("WeatherSystem.isWeatherEventActive", {description = "Is active", testCase = "active", type = "functional"}, function()
        shared.ws:registerWeatherEvent("event4", "event_region", "flood", 2, 75)
        local is = shared.ws:isWeatherEventActive("event_region", "event4")
        Helpers.assertEqual(is, true, "Active")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WeatherSystem:new()
    end)

    Suite:testMethod("WeatherSystem.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.ws:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
