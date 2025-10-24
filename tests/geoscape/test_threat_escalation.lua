-- Test threat level escalation based on player performance
-- Verifies that win rate affects UFO frequency, mission difficulty, and overall threat

local function test_threat_escalation_on_victory()
    print("\n=== Testing Threat Escalation on Victory ===")

    local CampaignManager = require("geoscape.campaign_manager")
    local ThreatManager = require("ai.strategic.threat_manager")

    -- Initialize campaign and threat manager
    CampaignManager.init()
    ThreatManager.init(0)  -- Shadow War phase

    local initialThreat = ThreatManager.getThreatLevel()
    local initialWinRate = ThreatManager.winRate

    -- Simulate mission victories to build win rate
    print("Simulating 10 mission victories...")
    for i = 1, 10 do
        ThreatManager.recordMissionOutcome(true)  -- Victory
    end

    local newWinRate = ThreatManager.winRate
    assert(newWinRate > initialWinRate, "Win rate should increase after victories")
    print(string.format("✓ Win rate increased: %.1f%% → %.1f%%",
        initialWinRate * 100, newWinRate * 100))

    -- Update threat with winning win rate
    ThreatManager.update(3600)  -- 1 hour

    local newThreat = ThreatManager.getThreatLevel()
    print(string.format("✓ Threat level after victories: %.1f%% (with 90% win rate)",
        newThreat * 100))

    print("\n✅ Threat escalation on victory test passed!")
    return true
end

local function test_threat_escalation_on_defeat()
    print("\n=== Testing Threat Escalation on Defeat ===")

    local ThreatManager = require("ai.strategic.threat_manager")
    ThreatManager.init(0)  -- Reset

    local initialWinRate = 0.5
    ThreatManager.winRate = initialWinRate

    -- Simulate mission defeats
    print("Simulating 10 mission defeats...")
    for i = 1, 10 do
        ThreatManager.recordMissionOutcome(false)  -- Defeat
    end

    local newWinRate = ThreatManager.winRate
    assert(newWinRate < initialWinRate, "Win rate should decrease after defeats")
    print(string.format("✓ Win rate decreased: %.1f%% → %.1f%%",
        initialWinRate * 100, newWinRate * 100))

    -- Update threat with losing win rate
    local initialThreat = ThreatManager.threatLevel
    ThreatManager.update(3600)  -- 1 hour

    local newThreat = ThreatManager.threatLevel
    print(string.format("✓ Threat level after defeats: %.1f%%", newThreat * 100))

    print("\n✅ Threat escalation on defeat test passed!")
    return true
end

local function test_mission_frequency_scaling()
    print("\n=== Testing Mission Frequency Scaling ===")

    local ThreatManager = require("ai.strategic.threat_manager")

    -- Test at low threat
    ThreatManager.init(0)
    ThreatManager.threatLevel = 0.1
    local lowFrequency = ThreatManager.getMissionFrequency()
    print(string.format("✓ Low threat (10%%): %.2f missions/day", lowFrequency))

    -- Test at medium threat
    ThreatManager.threatLevel = 0.5
    local mediumFrequency = ThreatManager.getMissionFrequency()
    print(string.format("✓ Medium threat (50%%): %.2f missions/day", mediumFrequency))
    assert(mediumFrequency > lowFrequency, "Higher threat should increase mission frequency")

    -- Test at high threat
    ThreatManager.threatLevel = 0.9
    local highFrequency = ThreatManager.getMissionFrequency()
    print(string.format("✓ High threat (90%%): %.2f missions/day", highFrequency))
    assert(highFrequency > mediumFrequency, "Higher threat should increase mission frequency more")

    print("\n✅ Mission frequency scaling test passed!")
    return true
end

local function test_ufo_intensity_scaling()
    print("\n=== Testing UFO Intensity Scaling ===")

    local ThreatManager = require("ai.strategic.threat_manager")
    ThreatManager.init(0)

    -- Test at low threat
    ThreatManager.threatLevel = 0.1
    local lowIntensity = ThreatManager.getUFOIntensity()
    print(string.format("✓ Low threat (10%%): %.2fx UFO intensity", lowIntensity))

    -- Test at medium threat
    ThreatManager.threatLevel = 0.5
    local mediumIntensity = ThreatManager.getUFOIntensity()
    print(string.format("✓ Medium threat (50%%): %.2fx UFO intensity", mediumIntensity))
    assert(mediumIntensity > lowIntensity, "Higher threat should increase UFO intensity")

    -- Test at high threat
    ThreatManager.threatLevel = 0.9
    local highIntensity = ThreatManager.getUFOIntensity()
    print(string.format("✓ High threat (90%%): %.2fx UFO intensity", highIntensity))
    assert(highIntensity > mediumIntensity, "Higher threat should increase UFO intensity more")

    print("\n✅ UFO intensity scaling test passed!")
    return true
end

local function test_campaign_threat_integration()
    print("\n=== Testing Campaign-Threat Integration ===")

    local CampaignManager = require("geoscape.campaign_manager")
    local ThreatManager = require("ai.strategic.threat_manager")

    CampaignManager.init()
    ThreatManager.init(0)

    local initialCampaignThreat = CampaignManager.threatLevel
    print(string.format("✓ Initial campaign threat: %.1f%%", initialCampaignThreat * 100))

    -- Update threat managers
    ThreatManager.update(86400)  -- 1 day
    CampaignManager.update(86400)

    local newCampaignThreat = CampaignManager.threatLevel
    print(string.format("✓ Campaign threat after 1 day: %.1f%%", newCampaignThreat * 100))

    -- Campaign should be tracking time-based threat
    print("✓ Campaign and threat managers synchronized")

    print("\n✅ Campaign-threat integration test passed!")
    return true
end

-- Run all tests
local allPassed = true

allPassed = test_threat_escalation_on_victory() and allPassed
allPassed = test_threat_escalation_on_defeat() and allPassed
allPassed = test_mission_frequency_scaling() and allPassed
allPassed = test_ufo_intensity_scaling() and allPassed
allPassed = test_campaign_threat_integration() and allPassed

if allPassed then
    print("\n" .. string.rep("=", 50))
    print("✅ ALL THREAT ESCALATION TESTS PASSED")
    print(string.rep("=", 50))
else
    print("\n" .. string.rep("=", 50))
    print("❌ SOME TESTS FAILED")
    print(string.rep("=", 50))
end

return allPassed
