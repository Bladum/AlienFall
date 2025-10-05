--[[
    AI Behavior Example - Advanced AI Decision Making
    
    This example demonstrates how to create custom AI behaviors for Alien Fall mods.
    AI behaviors control alien decision-making, movement, targeting, and tactics.
    
    File Location: /wiki/examples/lua/ai_behavior.lua
    Related Docs: /wiki/ai/README.md, /wiki/mods/API_Reference.md
    
    Usage:
    1. Copy this file to your mod's /scripts/ai/ directory
    2. Register AI behaviors in mod.toml
    3. Assign to alien units in mission scripts or data files
]]

-- AI Behavior System
local AIBehavior = {}

--[[
    Behavior: Aggressive
    Advances toward enemies, takes shots when available, minimal cover use
]]
AIBehavior.aggressive = {
    name = "Aggressive",
    description = "Advances steadily and engages enemies directly",
    
    -- Behavior weights (0-100)
    weights = {
        attack = 80,      -- Prioritize shooting
        advance = 70,     -- Move toward enemies
        cover = 30,       -- Low cover priority
        flank = 40,       -- Some flanking attempts
        retreat = 10,     -- Rarely retreats
        ability = 50,     -- Use abilities moderately
    },
    
    -- Decision function
    decide = function(self, unit, game_state)
        print("[AI] Aggressive behavior evaluating for " .. unit.id)
        
        -- Get visible enemies
        local enemies = game_state:getVisibleEnemies(unit)
        
        if #enemies == 0 then
            -- No enemies visible - advance to search
            return self:searchAndAdvance(unit, game_state)
        end
        
        -- Select highest priority target
        local target = self:selectTarget(unit, enemies)
        
        -- Check if can shoot
        if unit:hasAP(4) and unit:hasLOS(target) then
            -- Take shot if decent hit chance
            local hit_chance = game_state:calculateHitChance(unit, target)
            
            if hit_chance >= 40 then -- Low threshold, aggressive!
                return {
                    action = "shoot",
                    target = target,
                    priority = 90,
                }
            end
        end
        
        -- Can't shoot - advance toward target
        return self:advanceToward(unit, target, game_state)
    end,
    
    -- Target selection (closest enemy)
    selectTarget = function(self, unit, enemies)
        local closest = nil
        local min_distance = math.huge
        
        for _, enemy in ipairs(enemies) do
            local distance = game_state:getDistance(unit.position, enemy.position)
            if distance < min_distance then
                min_distance = distance
                closest = enemy
            end
        end
        
        return closest
    end,
    
    -- Advance toward position
    advanceToward = function(self, unit, target, game_state)
        local path = game_state:findPath(unit.position, target.position)
        
        -- Move as far as possible toward target
        local move_distance = math.min(unit:getAP() / 1, #path) -- 1 AP per tile
        local destination = path[move_distance] or unit.position
        
        return {
            action = "move",
            destination = destination,
            priority = 70,
        }
    end,
    
    -- Search for enemies
    searchAndAdvance = function(self, unit, game_state)
        -- Move toward last known enemy position
        local last_known = game_state:getLastKnownEnemyPosition(unit)
        
        if last_known then
            return self:advanceToward(unit, {position = last_known}, game_state)
        end
        
        -- No information - patrol randomly
        return {
            action = "patrol",
            priority = 30,
        }
    end,
}

--[[
    Behavior: Cautious
    Uses cover, calculates risks, retreats when wounded, defensive tactics
]]
AIBehavior.cautious = {
    name = "Cautious",
    description = "Uses cover and defensive tactics, calculates risks carefully",
    
    weights = {
        attack = 60,
        advance = 40,
        cover = 90,      -- High cover priority
        flank = 20,
        retreat = 70,    -- Retreats when hurt
        ability = 40,
    },
    
    decide = function(self, unit, game_state)
        print("[AI] Cautious behavior evaluating for " .. unit.id)
        
        -- Check health status
        local health_percent = unit.health / unit.max_health
        
        -- If badly wounded, retreat
        if health_percent < 0.4 then
            return self:retreat(unit, game_state)
        end
        
        local enemies = game_state:getVisibleEnemies(unit)
        
        if #enemies == 0 then
            -- No enemies - take defensive position
            return self:takeDefensivePosition(unit, game_state)
        end
        
        -- Evaluate threat level
        local threat_level = self:evaluateThreat(unit, enemies, game_state)
        
        if threat_level > 70 then
            -- High threat - seek better cover or retreat
            return self:seekBetterCover(unit, game_state)
        end
        
        -- Check if in cover
        local in_cover = game_state:isInCover(unit.position)
        
        if not in_cover then
            -- Not in cover - get to cover before shooting
            return self:moveToNearestCover(unit, game_state)
        end
        
        -- In cover and safe - take shot if available
        local target = self:selectSafestTarget(unit, enemies, game_state)
        
        if target and unit:hasAP(4) then
            local hit_chance = game_state:calculateHitChance(unit, target)
            
            if hit_chance >= 60 then -- Higher threshold than aggressive
                return {
                    action = "shoot",
                    target = target,
                    priority = 80,
                }
            end
        end
        
        -- No good shot - overwatch
        return {
            action = "overwatch",
            priority = 60,
        }
    end,
    
    -- Evaluate threat level (0-100)
    evaluateThreat = function(self, unit, enemies, game_state)
        local threat = 0
        
        for _, enemy in ipairs(enemies) do
            local distance = game_state:getDistance(unit.position, enemy.position)
            
            -- Closer enemies = higher threat
            if distance < 5 then
                threat = threat + 40
            elseif distance < 10 then
                threat = threat + 20
            else
                threat = threat + 10
            end
            
            -- Flanking enemies = extra threat
            if game_state:isFlanking(enemy, unit) then
                threat = threat + 30
            end
        end
        
        -- Wounded = more cautious
        local health_percent = unit.health / unit.max_health
        threat = threat * (1.5 - (health_percent * 0.5))
        
        return math.min(threat, 100)
    end,
    
    -- Select safest target (wounded, exposed, low threat)
    selectSafestTarget = function(self, unit, enemies, game_state)
        local best_target = nil
        local best_score = -1
        
        for _, enemy in ipairs(enemies) do
            local score = 0
            
            -- Wounded enemies = easier kills
            local health_percent = enemy.health / enemy.max_health
            score = score + (1 - health_percent) * 40
            
            -- Exposed enemies = easier to hit
            if not game_state:isInCover(enemy.position) then
                score = score + 30
            end
            
            -- Closer = easier shot
            local distance = game_state:getDistance(unit.position, enemy.position)
            score = score + (20 - distance)
            
            if score > best_score then
                best_score = score
                best_target = enemy
            end
        end
        
        return best_target
    end,
    
    -- Move to nearest cover
    moveToNearestCover = function(self, unit, game_state)
        local cover_positions = game_state:findNearbyCovers(unit.position, 10)
        
        if #cover_positions == 0 then
            -- No cover available - hunker down
            return {
                action = "hunker",
                priority = 70,
            }
        end
        
        -- Move to closest cover
        local nearest_cover = cover_positions[1]
        
        return {
            action = "move",
            destination = nearest_cover,
            priority = 85,
        }
    end,
    
    -- Retreat to safety
    retreat = function(self, unit, game_state)
        print("[AI] " .. unit.id .. " retreating (low health)")
        
        local retreat_direction = game_state:getRetreatDirection(unit)
        local retreat_position = game_state:findSafePosition(unit.position, retreat_direction, 8)
        
        return {
            action = "move",
            destination = retreat_position,
            priority = 95, -- High priority!
        }
    end,
    
    -- Seek better cover
    seekBetterCover = function(self, unit, game_state)
        local current_cover = game_state:getCoverValue(unit.position)
        local better_covers = game_state:findBetterCovers(unit.position, current_cover, 8)
        
        if #better_covers > 0 then
            return {
                action = "move",
                destination = better_covers[1],
                priority = 80,
            }
        end
        
        -- No better cover - stay put and hunker
        return {
            action = "hunker",
            priority = 75,
        }
    end,
    
    -- Take defensive position
    takeDefensivePosition = function(self, unit, game_state)
        local cover_positions = game_state:findDefensivePositions(unit.position, 6)
        
        if #cover_positions > 0 then
            return {
                action = "move",
                destination = cover_positions[1],
                priority = 50,
            }
        end
        
        -- Already in good position - overwatch
        return {
            action = "overwatch",
            priority = 60,
        }
    end,
}

--[[
    Behavior: Flanker
    Uses mobility to get flanking positions, hit-and-run tactics
]]
AIBehavior.flanker = {
    name = "Flanker",
    description = "Uses mobility to flank enemies and strike from advantageous positions",
    
    weights = {
        attack = 70,
        advance = 80,
        cover = 50,
        flank = 95,      -- Highest priority!
        retreat = 30,
        ability = 60,
    },
    
    decide = function(self, unit, game_state)
        print("[AI] Flanker behavior evaluating for " .. unit.id)
        
        local enemies = game_state:getVisibleEnemies(unit)
        
        if #enemies == 0 then
            -- Scout ahead to find enemies
            return self:scoutAhead(unit, game_state)
        end
        
        -- Find flankable targets
        local flank_opportunities = self:findFlankOpportunities(unit, enemies, game_state)
        
        if #flank_opportunities > 0 then
            -- Flank and shoot!
            local target = flank_opportunities[1].enemy
            local flank_position = flank_opportunities[1].position
            
            -- Check if already in flanking position
            if game_state:getDistance(unit.position, flank_position) <= 1 then
                -- Already flanking - shoot!
                return {
                    action = "shoot",
                    target = target,
                    priority = 90,
                }
            else
                -- Move to flanking position
                return {
                    action = "move",
                    destination = flank_position,
                    priority = 85,
                }
            end
        end
        
        -- No flank opportunities - use mobility to reposition
        return self:reposition(unit, enemies, game_state)
    end,
    
    -- Find flankable enemies
    findFlankOpportunities = function(self, unit, enemies, game_state)
        local opportunities = {}
        
        for _, enemy in ipairs(enemies) do
            -- Find positions that flank this enemy
            local flank_positions = game_state:findFlankingPositions(unit.position, enemy.position, 12)
            
            for _, pos in ipairs(flank_positions) do
                -- Check if position is reachable
                if game_state:isReachable(unit, pos) then
                    table.insert(opportunities, {
                        enemy = enemy,
                        position = pos,
                        score = self:scoreFlankPosition(unit, enemy, pos, game_state),
                    })
                end
            end
        end
        
        -- Sort by score (highest first)
        table.sort(opportunities, function(a, b) return a.score > b.score end)
        
        return opportunities
    end,
    
    -- Score flanking position
    scoreFlankPosition = function(self, unit, enemy, position, game_state)
        local score = 50 -- Base score
        
        -- Closer = better
        local distance = game_state:getDistance(position, enemy.position)
        score = score + (20 - distance) * 2
        
        -- Cover at flank position = better
        if game_state:isInCover(position) then
            score = score + 20
        end
        
        -- Flanking multiple enemies = much better
        local enemies_flanked = game_state:countEnemiesFlankedFrom(position)
        score = score + (enemies_flanked * 15)
        
        -- Avoid enemy overwatch lanes
        if game_state:isInOverwatchLane(position) then
            score = score - 30
        end
        
        return score
    end,
    
    -- Reposition for better angle
    reposition = function(self, unit, enemies, game_state)
        -- Find position with better tactical value
        local tactical_positions = game_state:findTacticalPositions(unit.position, 8)
        
        if #tactical_positions > 0 then
            return {
                action = "move",
                destination = tactical_positions[1],
                priority = 70,
            }
        end
        
        -- No good repositioning - shoot from current spot
        local target = enemies[1]
        
        return {
            action = "shoot",
            target = target,
            priority = 60,
        }
    end,
    
    -- Scout ahead
    scoutAhead = function(self, unit, game_state)
        local scout_direction = game_state:getObjectiveDirection(unit)
        local scout_position = game_state:findScoutPosition(unit.position, scout_direction, 10)
        
        return {
            action = "move",
            destination = scout_position,
            priority = 60,
        }
    end,
}

--[[
    Behavior: Rush Melee
    Closes distance ASAP, ignores cover, attacks in melee (Chrysalids)
]]
AIBehavior.rush_melee = {
    name = "Rush Melee",
    description = "Rushes toward enemies for melee attacks, ignores cover",
    
    weights = {
        attack = 100,    -- Maximum aggression
        advance = 100,
        cover = 0,       -- No cover usage
        flank = 10,
        retreat = 0,     -- Never retreats
        ability = 80,
    },
    
    decide = function(self, unit, game_state)
        print("[AI] Rush Melee behavior evaluating for " .. unit.id)
        
        local enemies = game_state:getVisibleEnemies(unit)
        
        if #enemies == 0 then
            -- No visible enemies - rush forward to find them
            return self:rushForward(unit, game_state)
        end
        
        -- Find closest enemy
        local closest_enemy = self:findClosestEnemy(unit, enemies, game_state)
        local distance = game_state:getDistance(unit.position, closest_enemy.position)
        
        -- Check if in melee range (adjacent)
        if distance <= 1 then
            -- ATTACK!
            return {
                action = "melee_attack",
                target = closest_enemy,
                priority = 100,
            }
        end
        
        -- Not in range - RUSH toward enemy
        return self:rushToward(unit, closest_enemy, game_state)
    end,
    
    -- Find closest enemy
    findClosestEnemy = function(self, unit, enemies, game_state)
        local closest = nil
        local min_distance = math.huge
        
        for _, enemy in ipairs(enemies) do
            local distance = game_state:getDistance(unit.position, enemy.position)
            if distance < min_distance then
                min_distance = distance
                closest = enemy
            end
        end
        
        return closest
    end,
    
    -- Rush toward target (use all AP for movement)
    rushToward = function(self, unit, target, game_state)
        -- Use ALL AP to close distance
        local max_move_distance = math.floor(unit:getAP() / 1) -- 1 AP per tile
        
        local path = game_state:findPath(unit.position, target.position)
        local move_distance = math.min(max_move_distance, #path)
        local destination = path[move_distance] or unit.position
        
        print("[AI] Rushing " .. move_distance .. " tiles toward target")
        
        return {
            action = "dash", -- Fast movement (uses 2 AP but moves 2 tiles)
            destination = destination,
            priority = 95,
        }
    end,
    
    -- Rush forward when no enemies visible
    rushForward = function(self, unit, game_state)
        local forward_direction = game_state:getForwardDirection(unit)
        local rush_position = game_state:findPositionInDirection(unit.position, forward_direction, 8)
        
        return {
            action = "dash",
            destination = rush_position,
            priority = 80,
        }
    end,
}

--[[
    Behavior: Support
    Stays back, heals allies, uses utility abilities, avoids combat
]]
AIBehavior.support = {
    name = "Support",
    description = "Provides healing and buffs to allies, avoids direct combat",
    
    weights = {
        attack = 30,     -- Low attack priority
        advance = 20,    -- Stays back
        cover = 95,      -- High cover priority
        flank = 0,
        retreat = 80,    -- Retreats when threatened
        ability = 100,   -- Prioritize abilities
    },
    
    decide = function(self, unit, game_state)
        print("[AI] Support behavior evaluating for " .. unit.id)
        
        -- Check if allies need healing
        local wounded_allies = game_state:getWoundedAllies(unit, 10) -- Within 10 tiles
        
        if #wounded_allies > 0 then
            -- Heal most wounded ally
            local most_wounded = self:findMostWounded(wounded_allies)
            
            if game_state:getDistance(unit.position, most_wounded.position) <= 1 then
                -- Adjacent - heal!
                return {
                    action = "heal",
                    target = most_wounded,
                    priority = 95,
                }
            else
                -- Move toward wounded ally
                return {
                    action = "move",
                    destination = most_wounded.position,
                    priority = 85,
                }
            end
        end
        
        -- No healing needed - check for buff opportunities
        local allies = game_state:getNearbyAllies(unit, 6)
        
        if #allies > 0 and unit:hasAbility("buff") then
            return {
                action = "use_ability",
                ability = "buff",
                target = allies[1],
                priority = 70,
            }
        end
        
        -- No support actions - stay in cover and overwatch
        local in_cover = game_state:isInCover(unit.position)
        
        if not in_cover then
            return self:moveToSafeCover(unit, game_state)
        end
        
        return {
            action = "overwatch",
            priority = 60,
        }
    end,
    
    -- Find most wounded ally
    findMostWounded = function(self, wounded_allies)
        local most_wounded = nil
        local lowest_health = 1.0
        
        for _, ally in ipairs(wounded_allies) do
            local health_percent = ally.health / ally.max_health
            if health_percent < lowest_health then
                lowest_health = health_percent
                most_wounded = ally
            end
        end
        
        return most_wounded
    end,
    
    -- Move to safe cover position
    moveToSafeCover = function(self, unit, game_state)
        -- Find cover positions away from enemies
        local safe_covers = game_state:findSafeCovers(unit.position, 8)
        
        if #safe_covers > 0 then
            return {
                action = "move",
                destination = safe_covers[1],
                priority = 80,
            }
        end
        
        -- No safe cover - hunker down
        return {
            action = "hunker",
            priority = 75,
        }
    end,
}

-- Return AI behavior table
return AIBehavior
