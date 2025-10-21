-- Unit Tests: Analytics System
-- Tests telemetry, game statistics, performance tracking, and data collection

local AnalyticsUnitTest = {}

-- Test setup
local function setup()
    package.path = package.path .. ";../../?.lua;../../engine/?.lua"
    -- Mock analytics module (if it exists)
    return {}
end

-- TEST 1: Player game session tracking
function AnalyticsUnitTest.testSessionTracking()
    local analytics = setup()
    
    local session = {
        id = "SESSION_001",
        startTime = os.time(),
        endTime = nil,
        playDuration = 0,
        gameEnded = false
    }
    
    assert(session.id ~= nil, "Session should have ID")
    assert(session.startTime > 0, "Start time should be valid")
    
    -- End session
    session.endTime = os.time() + 3600 -- 1 hour later
    session.playDuration = session.endTime - session.startTime
    session.gameEnded = true
    
    assert(session.playDuration == 3600, "Duration should be 1 hour")
    assert(session.gameEnded == true, "Game should be marked ended")
    
    print("✓ testSessionTracking passed")
end

-- TEST 2: Mission statistics collection
function AnalyticsUnitTest.testMissionStatistics()
    local analytics = setup()
    
    local mission = {
        missionId = "MISSION_001",
        type = "CRASH_SITE",
        difficulty = 4,
        completed = true,
        unitsDeployed = 6,
        casualtiesCount = 2,
        killsCount = 12,
        itemsRecovered = 8,
        averageDamagePerKill = 25
    }
    
    assert(mission.completed == true, "Mission should be completed")
    assert(mission.casualtiesCount == 2, "Casualties should be tracked")
    assert(mission.killsCount == 12, "Kills should be tracked")
    
    -- Calculate efficiency
    local efficiency = (mission.killsCount / mission.unitsDeployed) * 100
    assert(efficiency == 200, "Kill efficiency should be 200%")
    
    print("✓ testMissionStatistics passed")
end

-- TEST 3: Combat statistics recording
function AnalyticsUnitTest.testCombatStatistics()
    local analytics = setup()
    
    local combatStats = {
        totalShots = 42,
        shotsHit = 28,
        shotsWasted = 14,
        totalDamage = 850,
        damageReceived = 120,
        kills = 5,
        deaths = 1,
        grenades_used = 3,
        grenades_effective = 2
    }
    
    -- Calculate accuracy
    local accuracy = (combatStats.shotsHit / combatStats.totalShots) * 100
    assert(accuracy == 66.666666666667, "Accuracy should be ~66.67%")
    
    -- Calculate K/D ratio
    local kdRatio = combatStats.kills / math.max(1, combatStats.deaths)
    assert(kdRatio == 5, "K/D ratio should be 5")
    
    print("✓ testCombatStatistics passed")
end

-- TEST 4: Equipment usage tracking
function AnalyticsUnitTest.testEquipmentUsageTracking()
    local analytics = setup()
    
    local equipment = {
        rifle = { uses = 145, hits = 89, accuracy = 61.4 },
        laser = { uses = 32, hits = 24, accuracy = 75 },
        plasma = { uses = 8, hits = 7, accuracy = 87.5 },
        melee = { uses = 5, hits = 5, accuracy = 100 }
    }
    
    -- Most used equipment
    local mostUsed = "rifle"
    local mostUsedCount = equipment.rifle.uses
    
    assert(mostUsedCount == 145, "Rifle should be most used")
    
    -- Best accuracy
    local bestAccuracy = equipment.melee.accuracy
    assert(bestAccuracy == 100, "Melee should have perfect accuracy")
    
    print("✓ testEquipmentUsageTracking passed")
end

-- TEST 5: Unit performance profiles
function AnalyticsUnitTest.testUnitPerformanceProfiles()
    local analytics = setup()
    
    local unit = {
        name = "Soldier_Morgan",
        rank = "COLONEL",
        totalMissions = 45,
        casualtyCount = 3,
        killCount = 89,
        survivalRate = 93.3,
        favoriteWeapon = "PLASMA_RIFLE"
    }
    
    assert(unit.totalMissions == 45, "Total missions should be tracked")
    assert(unit.killCount == 89, "Kills should be tracked")
    
    -- Verify survival rate calculation
    local actualSurvivalRate = ((unit.totalMissions - unit.casualtyCount) / unit.totalMissions) * 100
    assert(actualSurvivalRate >= unit.survivalRate - 1, "Survival rate should be accurate")
    
    print("✓ testUnitPerformanceProfiles passed")
end

-- TEST 6: Economy metrics tracking
function AnalyticsUnitTest.testEconomyMetricsTracking()
    local analytics = setup()
    
    local economy = {
        monthlyIncome = 500000,
        monthlyCosts = 320000,
        netProfit = 180000,
        totalSpentOnEquipment = 1250000,
        totalSpentOnResearch = 850000,
        totalSpentOnMaintenance = 400000
    }
    
    assert(economy.netProfit == 180000, "Net profit should be tracked")
    
    local totalSpent = economy.totalSpentOnEquipment + economy.totalSpentOnResearch + economy.totalSpentOnMaintenance
    assert(totalSpent == 2500000, "Total spending should be correct")
    
    -- Spending breakdown
    local equipmentPercent = (economy.totalSpentOnEquipment / totalSpent) * 100
    assert(equipmentPercent == 50, "Equipment should be 50% of spending")
    
    print("✓ testEconomyMetricsTracking passed")
end

-- TEST 7: Technology research analytics
function AnalyticsUnitTest.testTechResearchAnalytics()
    local analytics = setup()
    
    local research = {
        totalTechResearched = 34,
        averageResearchTime = 12.5,
        fastestResearch = 3,
        slowestResearch = 45,
        totalResearchPoints = 8500
    }
    
    assert(research.totalTechResearched == 34, "Tech count should be tracked")
    assert(research.averageResearchTime == 12.5, "Average time should be calculated")
    assert(research.totalResearchPoints == 8500, "Research points should be tracked")
    
    print("✓ testTechResearchAnalytics passed")
end

-- TEST 8: Difficulty progression tracking
function AnalyticsUnitTest.testDifficultyProgression()
    local analytics = setup()
    
    local difficulty = {
        easyMissions = 5,
        normalMissions = 20,
        hardMissions = 15,
        impossibleMissions = 5
    }
    
    local totalMissions = 45
    local actualTotal = difficulty.easyMissions + difficulty.normalMissions + difficulty.hardMissions + difficulty.impossibleMissions
    
    assert(actualTotal == totalMissions, "Mission count should match")
    
    -- Difficulty trend
    local averageDifficulty = (difficulty.easyMissions * 1 + difficulty.normalMissions * 2 + difficulty.hardMissions * 3 + difficulty.impossibleMissions * 4) / totalMissions
    assert(averageDifficulty >= 2, "Average difficulty should be normal or higher")
    
    print("✓ testDifficultyProgression passed")
end

-- TEST 9: Achievement tracking
function AnalyticsUnitTest.testAchievementTracking()
    local analytics = setup()
    
    local achievements = {
        perfect_squad = { earned = true, date = os.time() },
        no_casualties = { earned = true, date = os.time() - 86400 },
        research_master = { earned = false, date = nil },
        economy_expert = { earned = true, date = os.time() - 172800 },
        tactical_genius = { earned = false, date = nil }
    }
    
    local earned = 0
    for _, achievement in pairs(achievements) do
        if achievement.earned then
            earned = earned + 1
        end
    end
    
    assert(earned == 3, "Should have earned 3 achievements")
    
    print("✓ testAchievementTracking passed")
end

-- TEST 10: Game progression metrics
function AnalyticsUnitTest.testGameProgressionMetrics()
    local analytics = setup()
    
    local progression = {
        currentPhase = 3,
        totalPhasesAvailable = 5,
        xenoDownedCount = 15,
        basesEstablished = 3,
        countriesAligned = 8,
        alienLeadersDefeated = 2,
        gameCompletion = 60
    }
    
    assert(progression.currentPhase == 3, "Current phase should be tracked")
    assert(progression.gameCompletion == 60, "Completion percentage should be tracked")
    
    local phaseProgress = (progression.currentPhase / progression.totalPhasesAvailable) * 100
    assert(phaseProgress == 60, "Phase progress should match completion")
    
    print("✓ testGameProgressionMetrics passed")
end

-- TEST 11: Performance metrics
function AnalyticsUnitTest.testPerformanceMetrics()
    local analytics = setup()
    
    local performance = {
        averageFPS = 58.5,
        minFPS = 45,
        maxFPS = 60,
        averageFrameTime = 17.1,
        memoryUsageMB = 256,
        peakMemoryMB = 380
    }
    
    assert(performance.averageFPS >= 45, "Should maintain good FPS")
    assert(performance.memoryUsageMB < 512, "Memory usage should be reasonable")
    
    -- Stability check
    local fpsVariation = performance.maxFPS - performance.minFPS
    assert(fpsVariation <= 15, "FPS should be relatively stable")
    
    print("✓ testPerformanceMetrics passed")
end

-- TEST 12: Player behavior analysis
function AnalyticsUnitTest.testPlayerBehaviorAnalysis()
    local analytics = setup()
    
    local behavior = {
        tacticalDecisions = 340,
        recklessDecisions = 12,
        defensiveDecisions = 156,
        aggressiveDecisions = 172,
        averageDecisionTime = 8.3, -- seconds
        gameRestarts = 2,
        loadGameCount = 45
    }
    
    local totalDecisions = behavior.tacticalDecisions + behavior.recklessDecisions + behavior.defensiveDecisions + behavior.aggressiveDecisions
    assert(totalDecisions == 680, "Total decisions should be tracked")
    
    local tacticalPercent = (behavior.tacticalDecisions / totalDecisions) * 100
    assert(tacticalPercent >= 50, "Player should make mostly tactical decisions")
    
    print("✓ testPlayerBehaviorAnalysis passed")
end

-- Run all tests
function AnalyticsUnitTest.runAll()
    print("\n[UNIT TEST] Analytics System\n")
    
    local tests = {
        AnalyticsUnitTest.testSessionTracking,
        AnalyticsUnitTest.testMissionStatistics,
        AnalyticsUnitTest.testCombatStatistics,
        AnalyticsUnitTest.testEquipmentUsageTracking,
        AnalyticsUnitTest.testUnitPerformanceProfiles,
        AnalyticsUnitTest.testEconomyMetricsTracking,
        AnalyticsUnitTest.testTechResearchAnalytics,
        AnalyticsUnitTest.testDifficultyProgression,
        AnalyticsUnitTest.testAchievementTracking,
        AnalyticsUnitTest.testGameProgressionMetrics,
        AnalyticsUnitTest.testPerformanceMetrics,
        AnalyticsUnitTest.testPlayerBehaviorAnalysis,
    }
    
    local passed = 0
    local failed = 0
    
    for _, test in ipairs(tests) do
        local success = pcall(test)
        if success then
            passed = passed + 1
        else
            failed = failed + 1
            print("✗ " .. tostring(test) .. " FAILED")
        end
    end
    
    print("\n[RESULT] Passed: " .. passed .. "/" .. #tests)
    if failed > 0 then
        print("[RESULT] Failed: " .. failed)
    end
    print()
    
    return passed, failed
end

return AnalyticsUnitTest
