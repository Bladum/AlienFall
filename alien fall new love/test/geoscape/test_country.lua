--- Test Country.lua
-- Tests for Country class

local test_framework = require("test.framework.test_framework")
local Country = require("src.geoscape.Country")

local CountryTest = {}

function CountryTest.test_country_creation()
    local data = {
        id = "usa",
        name = "United States",
        province_ids = {"new_york", "california"},
        base_funding_level = 1,
        score_thresholds = {
            excellent = 100,
            good = 50,
            neutral = 0
        }
    }

    local country = Country:new(data)

    test_framework.assert_equal(country.id, "usa")
    test_framework.assert_equal(country.name, "United States")
    test_framework.assert_equal(#country.province_ids, 2)
    test_framework.assert_equal(country.base_funding_level, 1)
end

function CountryTest.test_economic_aggregation()
    local country = Country:new({
        id = "test_country",
        province_ids = {"prov1", "prov2", "prov3"}
    })

    -- Mock provinces with economy values
    local mock_provinces = {
        {getEconomyValue = function() return 50 end},
        {getEconomyValue = function() return 75 end},
        {getEconomyValue = function() return 25 end}
    }

    -- Mock getProvinces method
    country.getProvinces = function() return mock_provinces end

    local total_economy = country:getEconomicValue()
    test_framework.assert_equal(total_economy, 150)  -- 50 + 75 + 25
end

function CountryTest.test_public_score()
    local country = Country:new({
        id = "test_country",
        public_score = 10
    })

    -- Update score
    country:updatePublicScore(25, "successful interception")
    test_framework.assert_equal(country.public_score, 35)

    -- Update with negative score
    country:updatePublicScore(-10, "civilian casualties")
    test_framework.assert_equal(country.public_score, 25)
end

function CountryTest.test_funding_calculation()
    local country = Country:new({
        id = "test_country",
        base_funding_level = 1,
        funding_modifier = 1.0
    })

    -- Mock economic value
    country.getEconomicValue = function() return 100 end

    local funding = country:calculateFunding()
    test_framework.assert_equal(funding, 100000)  -- 1 * 100 * 1.0 * 1000
end

function CountryTest.test_funding_levels()
    local country = Country:new({
        id = "test_country",
        score_thresholds = {
            excellent = 100,
            good = 50,
            neutral = 0,
            poor = -50
        }
    })

    -- Mock economic value
    country.getEconomicValue = function() return 100 end

    -- Test different score levels
    country.public_score = 120  -- Excellent
    country:_updateFundingLevel()
    test_framework.assert_equal(country.current_funding_level, 3)

    country.public_score = 75  -- Good
    country:_updateFundingLevel()
    test_framework.assert_equal(country.current_funding_level, 2)

    country.public_score = 25  -- Neutral
    country:_updateFundingLevel()
    test_framework.assert_equal(country.current_funding_level, 1)

    country.public_score = -25  -- Poor
    country:_updateFundingLevel()
    test_framework.assert_equal(country.current_funding_level, 0.5)

    country.public_score = -75  -- Critical
    country:_updateFundingLevel()
    test_framework.assert_equal(country.current_funding_level, 0.25)

    country.public_score = -150  -- Withdrawn
    country:_updateFundingLevel()
    test_framework.assert_equal(country.current_funding_level, 0)
    test_framework.assert_true(country.isWithdrawn)
end

function CountryTest.test_diplomatic_state()
    local country = Country:new({id = "test_country"})

    test_framework.assert_equal(country:getDiplomaticState(), "neutral")

    country:setDiplomaticState("hostile")
    test_framework.assert_equal(country:getDiplomaticState(), "hostile")
end

function CountryTest.test_monthly_updates()
    local country = Country:new({
        id = "test_country",
        last_funding_update = 0
    })

    -- Mock methods
    country.getEconomicValue = function() return 100 end
    country.calculateFunding = function() return 50000 end

    -- Advance less than 30 days
    country:advanceTime(15)
    test_framework.assert_equal(country.last_funding_update, 15)

    -- Advance past 30 days
    country:advanceTime(20)  -- Total 35 days
    test_framework.assert_equal(country.last_funding_update, 5)  -- 35 - 30
end

function CountryTest.test_statistics()
    local country = Country:new({
        id = "test_country",
        province_ids = {"prov1", "prov2"},
        public_score = 75,
        current_funding_level = 2,
        monthly_funding = 150000
    })

    local stats = country:getStatistics()
    test_framework.assert_equal(stats.province_count, 2)
    test_framework.assert_equal(stats.public_score, 75)
    test_framework.assert_equal(stats.funding_level, 2)
    test_framework.assert_equal(stats.monthly_funding, 150000)
end

--- Run all Country tests
function CountryTest.run()
    test_framework.run_suite("Country", {
        test_country_creation = CountryTest.test_country_creation,
        test_economic_aggregation = CountryTest.test_economic_aggregation,
        test_public_score = CountryTest.test_public_score,
        test_funding_calculation = CountryTest.test_funding_calculation,
        test_funding_levels = CountryTest.test_funding_levels,
        test_diplomatic_state = CountryTest.test_diplomatic_state,
        test_monthly_updates = CountryTest.test_monthly_updates,
        test_statistics = CountryTest.test_statistics
    })
end

return CountryTest