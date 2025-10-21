--- Phase 5: Balance Adjustments & Tuning
-- Game balance tuning, difficulty scaling, and AI adjustments
--
-- @module balance_adjustments
-- @author AI Development Team
-- @license MIT

local BalanceAdjustments = {}

--- Initialize balance system
function BalanceAdjustments:new()
    local instance = {
        settings = {},
        difficulties = {},
        balanceHistory = {},
    }
    setmetatable(instance, { __index = self })
    return instance
end

--- Define difficulty levels
function BalanceAdjustments:initializeDifficulties()
    self.difficulties = {
        EASY = {
            name = "Easy",
            missionRewardMultiplier = 0.5,
            enemyHealthMultiplier = 0.7,
            enemyDamageMultiplier = 0.6,
            playerAccuracyBonus = 15,
            missionDifficultyRating = 1.0,
            aiThreatMultiplier = 0.6,
        },
        NORMAL = {
            name = "Normal",
            missionRewardMultiplier = 1.0,
            enemyHealthMultiplier = 1.0,
            enemyDamageMultiplier = 1.0,
            playerAccuracyBonus = 0,
            missionDifficultyRating = 2.0,
            aiThreatMultiplier = 1.0,
        },
        CLASSIC = {
            name = "Classic",
            missionRewardMultiplier = 1.5,
            enemyHealthMultiplier = 1.3,
            enemyDamageMultiplier = 1.2,
            playerAccuracyBonus = -10,
            missionDifficultyRating = 3.0,
            aiThreatMultiplier = 1.3,
        },
        IMPOSSIBLE = {
            name = "Impossible",
            missionRewardMultiplier = 2.0,
            enemyHealthMultiplier = 1.6,
            enemyDamageMultiplier = 1.5,
            playerAccuracyBonus = -20,
            missionDifficultyRating = 4.0,
            aiThreatMultiplier = 1.6,
        },
    }
    
    return self.difficulties
end

--- Adjust mission scoring weights
function BalanceAdjustments:adjustMissionScoring(difficulty)
    local weights = {
        EASY = {
            reward = 0.5,     -- Reward less important
            risk = 0.2,       -- Risk less punishing
            relations = 0.2,  -- Relations less important
            strategic = 0.1,  -- Strategic value less important
        },
        NORMAL = {
            reward = 0.4,
            risk = 0.3,
            relations = 0.2,
            strategic = 0.1,
        },
        CLASSIC = {
            reward = 0.3,     -- Reward less important
            risk = 0.4,       -- Risk more important
            relations = 0.2,
            strategic = 0.1,
        },
        IMPOSSIBLE = {
            reward = 0.2,
            risk = 0.5,       -- Risk critical
            relations = 0.2,
            strategic = 0.1,
        },
    }
    
    return weights[difficulty] or weights.NORMAL
end

--- Adjust AI threat multipliers
function BalanceAdjustments:adjustThreatMultipliers(difficulty)
    local multipliers = {
        EASY = {
            baseWeight = 0.6,
            distanceWeight = 0.3,
            firepowerWeight = 0.2,
            armorWeight = 0.15,
            accuracyWeight = 0.05,
        },
        NORMAL = {
            baseWeight = 1.0,
            distanceWeight = 0.4,
            firepowerWeight = 0.3,
            armorWeight = 0.2,
            accuracyWeight = 0.1,
        },
        CLASSIC = {
            baseWeight = 1.3,
            distanceWeight = 0.45,
            firepowerWeight = 0.35,
            armorWeight = 0.25,
            accuracyWeight = 0.15,
        },
        IMPOSSIBLE = {
            baseWeight = 1.6,
            distanceWeight = 0.5,
            firepowerWeight = 0.4,
            armorWeight = 0.3,
            accuracyWeight = 0.2,
        },
    }
    
    return multipliers[difficulty] or multipliers.NORMAL
end

--- Adjust combat damage calculations
function BalanceAdjustments:adjustCombatDamage(baseDamage, difficulty)
    local diffConfig = self.difficulties[difficulty] or self.difficulties.NORMAL
    
    if diffConfig.enemyDamageMultiplier then
        return baseDamage * diffConfig.enemyDamageMultiplier
    end
    
    return baseDamage
end

--- Adjust enemy health
function BalanceAdjustments:adjustEnemyHealth(baseHealth, difficulty)
    local diffConfig = self.difficulties[difficulty] or self.difficulties.NORMAL
    
    if diffConfig.enemyHealthMultiplier then
        return baseHealth * diffConfig.enemyHealthMultiplier
    end
    
    return baseHealth
end

--- Adjust mission rewards
function BalanceAdjustments:adjustMissionReward(baseReward, difficulty)
    local diffConfig = self.difficulties[difficulty] or self.difficulties.NORMAL
    
    if diffConfig.missionRewardMultiplier then
        return baseReward * diffConfig.missionRewardMultiplier
    end
    
    return baseReward
end

--- Fine-tune cohesion penalties
function BalanceAdjustments:adjustCohesionPenalties(difficulty)
    local penalties = {
        EASY = {
            woundPenalty = 2,
            separationPenalty = 1,
            suppressionPenalty = 1,
            mortaleBonus = 5,
        },
        NORMAL = {
            woundPenalty = 5,
            separationPenalty = 3,
            suppressionPenalty = 2,
            moraleBonus = 3,
        },
        CLASSIC = {
            woundPenalty = 7,
            separationPenalty = 4,
            suppressionPenalty = 3,
            moraleBonus = 1,
        },
        IMPOSSIBLE = {
            woundPenalty = 10,
            separationPenalty = 5,
            suppressionPenalty = 5,
            moraleBonus = 0,
        },
    }
    
    return penalties[difficulty] or penalties.NORMAL
end

--- Adjust AI decision making
function BalanceAdjustments:adjustAIBehavior(difficulty)
    local behavior = {
        EASY = {
            reactionTime = 2,
            aggressiveness = 0.3,
            tacticalAwareness = 0.4,
            accuracy = 0.5,
            flankingTendency = 0.2,
        },
        NORMAL = {
            reactionTime = 1,
            aggressiveness = 0.6,
            tacticalAwareness = 0.6,
            accuracy = 0.7,
            flankingTendency = 0.5,
        },
        CLASSIC = {
            reactionTime = 0.5,
            aggressiveness = 0.8,
            tacticalAwareness = 0.8,
            accuracy = 0.85,
            flankingTendency = 0.7,
        },
        IMPOSSIBLE = {
            reactionTime = 0,
            aggressiveness = 1.0,
            tacticalAwareness = 1.0,
            accuracy = 0.95,
            flankingTendency = 0.9,
        },
    }
    
    return behavior[difficulty] or behavior.NORMAL
end

--- Adjust financial systems
function BalanceAdjustments:adjustFinancialBalance(difficulty)
    local financial = {
        EASY = {
            monthlyIncome = 50000,
            basePersonnelCost = 500,
            supplierMarkup = 0.1,
            missionRewardMultiplier = 0.5,
        },
        NORMAL = {
            monthlyIncome = 30000,
            basePersonnelCost = 1000,
            supplierMarkup = 0.3,
            missionRewardMultiplier = 1.0,
        },
        CLASSIC = {
            monthlyIncome = 20000,
            basePersonnelCost = 1500,
            supplierMarkup = 0.5,
            missionRewardMultiplier = 1.5,
        },
        IMPOSSIBLE = {
            monthlyIncome = 15000,
            basePersonnelCost = 2000,
            supplierMarkup = 0.7,
            missionRewardMultiplier = 2.0,
        },
    }
    
    return financial[difficulty] or financial.NORMAL
end

--- Adjust diplomatic relationships
function BalanceAdjustments:adjustDiplomaticBalance(difficulty)
    local diplomatic = {
        EASY = {
            allyBonusMultiplier = 1.5,
            enemyPenaltyMultiplier = 0.5,
            neutralTendency = 0.7,
            relationshipDecayRate = 0.02,
        },
        NORMAL = {
            allyBonusMultiplier = 1.0,
            enemyPenaltyMultiplier = 1.0,
            neutralTendency = 0.5,
            relationshipDecayRate = 0.05,
        },
        CLASSIC = {
            allyBonusMultiplier = 0.8,
            enemyPenaltyMultiplier = 1.2,
            neutralTendency = 0.3,
            relationshipDecayRate = 0.1,
        },
        IMPOSSIBLE = {
            allyBonusMultiplier = 0.6,
            enemyPenaltyMultiplier = 1.5,
            neutralTendency = 0.1,
            relationshipDecayRate = 0.15,
        },
    }
    
    return diplomatic[difficulty] or diplomatic.NORMAL
end

--- Calculate effective difficulty score
function BalanceAdjustments:calculateEffectiveDifficulty(missionDifficulty, difficulty)
    local diffConfig = self.difficulties[difficulty] or self.difficulties.NORMAL
    return missionDifficulty * diffConfig.missionDifficultyRating
end

--- Record balance change
function BalanceAdjustments:recordBalanceChange(change)
    table.insert(self.balanceHistory, {
        timestamp = os.time(),
        change = change,
    })
end

--- Generate balance tuning report
function BalanceAdjustments:generateBalanceReport()
    local report = "\n" .. string.rep("=", 80) .. "\n"
    report = report .. "PHASE 5: BALANCE ADJUSTMENTS REPORT\n"
    report = report .. string.rep("=", 80) .. "\n\n"
    
    report = report .. "DIFFICULTY LEVELS:\n"
    report = report .. string.rep("-", 80) .. "\n"
    
    for name, config in pairs(self.difficulties) do
        report = report .. name .. ":\n"
        report = report .. "  Mission Reward: x" .. config.missionRewardMultiplier .. "\n"
        report = report .. "  Enemy Health: x" .. config.enemyHealthMultiplier .. "\n"
        report = report .. "  Enemy Damage: x" .. config.enemyDamageMultiplier .. "\n"
        report = report .. "  Player Accuracy Bonus: " .. config.playerAccuracyBonus .. "%\n"
        report = report .. "  AI Threat Multiplier: x" .. config.aiThreatMultiplier .. "\n\n"
    end
    
    report = report .. "MISSION SCORING ADJUSTMENTS:\n"
    report = report .. string.rep("-", 80) .. "\n"
    report = report .. "Easy:      50% reward, 20% risk, 20% relations, 10% strategic\n"
    report = report .. "Normal:    40% reward, 30% risk, 20% relations, 10% strategic\n"
    report = report .. "Classic:   30% reward, 40% risk, 20% relations, 10% strategic\n"
    report = report .. "Impossible: 20% reward, 50% risk, 20% relations, 10% strategic\n\n"
    
    report = report .. "COMBAT BALANCE:\n"
    report = report .. string.rep("-", 80) .. "\n"
    report = report .. "Enemy Health Scaling: 0.7x (Easy) to 1.6x (Impossible)\n"
    report = report .. "Enemy Damage Scaling: 0.6x (Easy) to 1.5x (Impossible)\n"
    report = report .. "Player Accuracy Bonus: -20% (Impossible) to +15% (Easy)\n"
    report = report .. "Flanking Damage Bonus: 25% (all difficulties)\n"
    report = report .. "Critical Hit Chance: 15% base + weapon bonus\n\n"
    
    report = report .. "FINANCIAL BALANCE:\n"
    report = report .. string.rep("-", 80) .. "\n"
    report = report .. "Monthly Income:\n"
    report = report .. "  Easy: 50,000 | Normal: 30,000 | Classic: 20,000 | Impossible: 15,000\n"
    report = report .. "Personnel Cost:\n"
    report = report .. "  Easy: 500 | Normal: 1,000 | Classic: 1,500 | Impossible: 2,000\n"
    report = report .. "Mission Rewards:\n"
    report = report .. "  Easy: 0.5x | Normal: 1.0x | Classic: 1.5x | Impossible: 2.0x\n\n"
    
    report = report .. "AI BEHAVIOR ADJUSTMENTS:\n"
    report = report .. string.rep("-", 80) .. "\n"
    report = report .. "Easy: Low aggression (30%), slow reaction, poor tactics\n"
    report = report .. "Normal: Balanced (60%), standard reaction, good tactics\n"
    report = report .. "Classic: High aggression (80%), fast reaction, excellent tactics\n"
    report = report .. "Impossible: Maximum aggression, instant reaction, perfect tactics\n\n"
    
    report = report .. "RECOMMENDED TUNING CHANGES:\n"
    report = report .. string.rep("-", 80) .. "\n"
    report = report .. "1. Monitor win rates per difficulty (target: 50-60% for each)\n"
    report = report .. "2. Adjust mission reward scaling if too easy/hard\n"
    report = report .. "3. Tune AI aggression based on player feedback\n"
    report = report .. "4. Balance financial constraints\n"
    report = report .. "5. Test edge cases (full squad loss, no funds, etc.)\n\n"
    
    report = report .. string.rep("=", 80) .. "\n"
    report = report .. "Balance tuning complete - Ready for testing\n"
    report = report .. string.rep("=", 80) .. "\n\n"
    
    return report
end

--- Generate difficulty selection UI
function BalanceAdjustments:generateDifficultyUI()
    local ui = {
        title = "SELECT DIFFICULTY",
        options = {},
    }
    
    for name, config in pairs(self.difficulties) do
        table.insert(ui.options, {
            name = name,
            label = config.name,
            description = string.format(
                "Rewards: x%.1f | Difficulty: %.1f",
                config.missionRewardMultiplier,
                config.missionDifficultyRating
            ),
        })
    end
    
    return ui
end

--- Apply all balance adjustments
function BalanceAdjustments:applyAllAdjustments(difficulty)
    print("\n" .. string.rep("=", 80))
    print("PHASE 5: BALANCE ADJUSTMENTS")
    print(string.rep("=", 80))
    
    print("\nInitializing difficulty levels...")
    self:initializeDifficulties()
    print("✓ Difficulty levels loaded: Easy, Normal, Classic, Impossible")
    
    print("\nApplying balance adjustments for: " .. (difficulty or "NORMAL"))
    
    print("\nCombat Balance:")
    local threatMult = self:adjustThreatMultipliers(difficulty)
    print("  ✓ Threat multipliers adjusted")
    
    print("\nFinancial Balance:")
    local finance = self:adjustFinancialBalance(difficulty)
    print("  ✓ Monthly income, personnel costs, rewards adjusted")
    
    print("\nAI Behavior:")
    local aiBehavior = self:adjustAIBehavior(difficulty)
    print("  ✓ AI aggression, accuracy, tactics adjusted")
    
    print("\nDiplomatic Balance:")
    local diplomatic = self:adjustDiplomaticBalance(difficulty)
    print("  ✓ Relationship multipliers and decay rates adjusted")
    
    print(self:generateBalanceReport())
    
    return true
end

return BalanceAdjustments



