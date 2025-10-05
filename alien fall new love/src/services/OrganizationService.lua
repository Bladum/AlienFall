--- OrganizationService.lua
-- Unified organization management service for Alien Fall
-- Manages fame, karma, policies, advisors, faction relations, and company structure

local class = require 'lib.Middleclass'
local FameSystem = require 'organization.FameSystem'
local KarmaSystem = require 'organization.KarmaSystem'
local ScoreSystem = require 'organization.ScoreSystem'

--- OrganizationService class
-- @type OrganizationService
OrganizationService = class('OrganizationService')

--- Company tiers enumeration
OrganizationService.COMPANY_TIERS = {
    FRONT = "front",
    COMMAND = "command",
    DIRECTORATE = "directorate"
}

--- Policy slots per tier
OrganizationService.POLICY_SLOTS = {
    front = 2,
    command = 4,
    directorate = 6
}

--- Create a new OrganizationService instance
-- @param registry Service registry for accessing other systems
-- @return OrganizationService instance
function OrganizationService:initialize(registry)
    self.registry = registry

    -- Subsystems
    self.fameSystem = FameSystem.new({})
    self.karmaSystem = KarmaSystem.new({})
    self.scoreSystem = ScoreSystem.new({})

    -- Company structure
    self.companyTier = OrganizationService.COMPANY_TIERS.FRONT
    self.companyLevel = 1

    -- Policies and advisors
    self.activePolicies = {} -- policy_id -> policy_data
    self.advisors = {} -- advisor_id -> advisor_data
    self.divisions = {} -- division_id -> division_data

    -- Faction relations
    self.factionRelations = {} -- faction_id -> standing_value

    -- Configuration
    self.config = {
        maxFame = 100,
        maxKarma = 100,
        baseFunding = 1000,
        policyCooldown = 24, -- hours
        advisorSlots = 3
    }

    -- Load organization data
    self:_loadOrganizationData()

    -- Note: Service registration is handled by ServiceRegistry
end

--- Load organization-related data from data files
function OrganizationService:_loadOrganizationData()
    if not self.registry then return end

    local dataRegistry = self.registry:resolve('data_registry')
    if not dataRegistry then return end

    -- Load policies
    self:_loadPolicies(dataRegistry)

    -- Load advisors
    self:_loadAdvisors(dataRegistry)

    -- Load divisions
    self:_loadDivisions(dataRegistry)

    -- Load factions
    self:_loadFactions(dataRegistry)

    -- Load reputation data
    self:_loadReputationData(dataRegistry)
end

--- Load policy definitions
function OrganizationService:_loadPolicies(dataRegistry)
    local policies = dataRegistry:get('organization', 'policies') or {}

    self.policyTemplates = {}
    for _, policyData in ipairs(policies) do
        self.policyTemplates[policyData.id] = policyData
    end
end

--- Load advisor definitions
function OrganizationService:_loadAdvisors(dataRegistry)
    local advisors = dataRegistry:get('organization', 'advisors') or {}

    self.advisorTemplates = {}
    for _, advisorData in ipairs(advisors) do
        self.advisorTemplates[advisorData.id] = advisorData
    end
end

--- Load division definitions
function OrganizationService:_loadDivisions(dataRegistry)
    local divisions = dataRegistry:get('organization', 'divisions') or {}

    self.divisionTemplates = {}
    for _, divisionData in ipairs(divisions) do
        self.divisionTemplates[divisionData.id] = divisionData
    end
end

--- Load faction definitions
function OrganizationService:_loadFactions(dataRegistry)
    local factions = dataRegistry:get('organization', 'factions') or {}

    for _, factionData in ipairs(factions) do
        self.factionRelations[factionData.id] = factionData.starting_standing or 0
    end
end

--- Load reputation configuration
function OrganizationService:_loadReputationData(dataRegistry)
    local reputation = dataRegistry:get('organization', 'reputation') or {}

    -- Apply reputation settings to subsystems
    if reputation.fame_levels then
        -- Would configure fame system levels
    end

    if reputation.karma_alignments then
        -- Would configure karma system alignments
    end
end

--- Get current fame level
-- @return fame_level, fame_value
function OrganizationService:getFame()
    return self.fameSystem.fame_level, self.fameSystem.fame
end

--- Get current karma alignment
-- @return karma_alignment, karma_value
function OrganizationService:getKarma()
    return self.karmaSystem.karma_alignment, self.karmaSystem.karma
end

--- Get current score and funding
-- @return country_score, monthly_funding
function OrganizationService:getScore()
    return self.scoreSystem.country_score, self.scoreSystem.monthly_funding_level
end

--- Modify fame
-- @param amount Amount to add/subtract
-- @param reason Reason for the change
-- @return new_fame_level, new_fame_value
function OrganizationService:modifyFame(amount, reason)
    self.fameSystem:modify_fame(amount, "organization", reason)
    return self:getFame()
end

--- Modify karma
-- @param amount Amount to add/subtract
-- @param reason Reason for the change
-- @return new_karma_alignment, new_karma_value
function OrganizationService:modifyKarma(amount, reason)
    self.karmaSystem:modify_karma(amount, "organization", reason)
    return self:getKarma()
end

--- Update score based on province performance
-- @param provinceId The province ID
-- @param scoreChange The score change amount
function OrganizationService:updateProvinceScore(provinceId, scoreChange)
    self.scoreSystem:modify_province_score(provinceId, scoreChange, "organization", "service_update")
end

--- Get company tier and level
-- @return tier, level
function OrganizationService:getCompanyTier()
    return self.companyTier, self.companyLevel
end

--- Upgrade company tier
-- @return success, new_tier, reason
function OrganizationService:upgradeCompanyTier()
    local tierOrder = {front = 1, command = 2, directorate = 3}
    local currentOrder = tierOrder[self.companyTier]

    if currentOrder >= 3 then
        return false, self.companyTier, "Already at maximum tier"
    end

    -- Check requirements (simplified)
    local requiredScore = currentOrder * 50
    local currentScore = self.scoreSystem.country_score

    if currentScore < requiredScore then
        return false, self.companyTier, string.format("Insufficient score: %d/%d required", currentScore, requiredScore)
    end

    -- Upgrade tier
    if self.companyTier == "front" then
        self.companyTier = "command"
    elseif self.companyTier == "command" then
        self.companyTier = "directorate"
    end

    -- Fire event
    self:_fireEvent('org:tier_upgraded', {
        old_tier = self.companyTier,
        new_tier = self.companyTier,
        new_level = self.companyLevel
    })

    return true, self.companyTier
end

--- Get available policy slots
-- @return used_slots, max_slots
function OrganizationService:getPolicySlots()
    local maxSlots = OrganizationService.POLICY_SLOTS[self.companyTier] or 2
    local usedSlots = 0

    for _ in pairs(self.activePolicies) do
        usedSlots = usedSlots + 1
    end

    return usedSlots, maxSlots
end

--- Adopt a policy
-- @param policyId The policy ID
-- @return success, reason
function OrganizationService:adoptPolicy(policyId)
    local template = self.policyTemplates[policyId]
    if not template then
        return false, "Policy not found"
    end

    -- Check if already active
    if self.activePolicies[policyId] then
        return false, "Policy already active"
    end

    -- Check slots
    local usedSlots, maxSlots = self:getPolicySlots()
    if usedSlots >= maxSlots then
        return false, "No policy slots available"
    end

    -- Check requirements
    if not self:_checkPolicyRequirements(template) then
        return false, "Policy requirements not met"
    end

    -- Activate policy
    self.activePolicies[policyId] = {
        adopted_at = os.time(),
        template = template
    }

    -- Apply policy effects
    self:_applyPolicyEffects(template, true)

    -- Fire event
    self:_fireEvent('org:policy_adopted', {
        policy_id = policyId,
        policy = template
    })

    return true
end

--- Revoke a policy
-- @param policyId The policy ID
-- @return success, reason
function OrganizationService:revokePolicy(policyId)
    if not self.activePolicies[policyId] then
        return false, "Policy not active"
    end

    local policyData = self.activePolicies[policyId]
    local template = policyData.template

    -- Check cooldown
    local timeSinceAdoption = os.time() - policyData.adopted_at
    if timeSinceAdoption < (self.config.policyCooldown * 3600) then
        return false, "Policy cooldown not expired"
    end

    -- Remove policy effects
    self:_applyPolicyEffects(template, false)

    -- Remove policy
    self.activePolicies[policyId] = nil

    -- Fire event
    self:_fireEvent('org:policy_revoked', {
        policy_id = policyId,
        policy = template
    })

    return true
end

--- Check policy requirements
function OrganizationService:_checkPolicyRequirements(template)
    if not template.requirements then return true end

    local req = template.requirements

    -- Check fame requirements
    if req.min_fame and self.fameSystem.fame < req.min_fame then
        return false
    end

    if req.max_fame and self.fameSystem.fame > req.max_fame then
        return false
    end

    -- Check karma requirements
    if req.min_karma and self.karmaSystem.karma < req.min_karma then
        return false
    end

    if req.max_karma and self.karmaSystem.karma > req.max_karma then
        return false
    end

    -- Check tier requirements
    if req.min_tier then
        local tierOrder = {front = 1, command = 2, directorate = 3}
        if tierOrder[self.companyTier] < tierOrder[req.min_tier] then
            return false
        end
    end

    return true
end

--- Apply or remove policy effects
function OrganizationService:_applyPolicyEffects(template, apply)
    if not template.effects then return end

    local multiplier = apply and 1 or -1

    for effectType, effectValue in pairs(template.effects) do
        if effectType == "fame_modifier" then
            -- Would apply ongoing fame modifier
        elseif effectType == "karma_modifier" then
            -- Would apply ongoing karma modifier
        elseif effectType == "funding_modifier" then
            -- Would modify funding calculations
        elseif effectType == "recruitment_modifier" then
            -- Would modify recruitment quality
        end
    end
end

--- Get active policies
-- @return Table of active policies (id -> policy_data)
function OrganizationService:getActivePolicies()
    return self.activePolicies
end

--- Hire advisor
-- @param advisorId The advisor ID
-- @return success, reason
function OrganizationService:hireAdvisor(advisorId)
    local template = self.advisorTemplates[advisorId]
    if not template then
        return false, "Advisor not found"
    end

    -- Check if already hired
    if self.advisors[advisorId] then
        return false, "Advisor already hired"
    end

    -- Check slots
    local advisorCount = 0
    for _ in pairs(self.advisors) do
        advisorCount = advisorCount + 1
    end

    if advisorCount >= self.config.advisorSlots then
        return false, "No advisor slots available"
    end

    -- Check requirements
    if not self:_checkAdvisorRequirements(template) then
        return false, "Advisor requirements not met"
    end

    -- Hire advisor
    self.advisors[advisorId] = {
        hired_at = os.time(),
        template = template
    }

    -- Apply advisor bonuses
    self:_applyAdvisorBonuses(template, true)

    -- Fire event
    self:_fireEvent('org:advisor_hired', {
        advisor_id = advisorId,
        advisor = template
    })

    return true
end

--- Fire advisor
-- @param advisorId The advisor ID
-- @return success, reason
function OrganizationService:fireAdvisor(advisorId)
    if not self.advisors[advisorId] then
        return false, "Advisor not hired"
    end

    local advisorData = self.advisors[advisorId]
    local template = advisorData.template

    -- Remove advisor bonuses
    self:_applyAdvisorBonuses(template, false)

    -- Fire advisor
    self.advisors[advisorId] = nil

    -- Fire event
    self:_fireEvent('org:advisor_fired', {
        advisor_id = advisorId,
        advisor = template
    })

    return true
end

--- Check advisor requirements
function OrganizationService:_checkAdvisorRequirements(template)
    if not template.requirements then return true end

    local req = template.requirements

    -- Check tier requirements
    if req.min_tier then
        local tierOrder = {front = 1, command = 2, directorate = 3}
        if tierOrder[self.companyTier] < tierOrder[req.min_tier] then
            return false
        end
    end

    -- Check fame/karma requirements
    if req.min_fame and self.fameSystem.fame < req.min_fame then
        return false
    end

    if req.min_karma and self.karmaSystem.karma < req.min_karma then
        return false
    end

    return true
end

--- Apply or remove advisor bonuses
function OrganizationService:_applyAdvisorBonuses(template, apply)
    if not template.bonuses then return end

    local multiplier = apply and 1 or -1

    for bonusType, bonusValue in pairs(template.bonuses) do
        -- Apply bonuses to relevant systems
        -- This would integrate with other services
    end
end

--- Get hired advisors
-- @return Table of hired advisors (id -> advisor_data)
function OrganizationService:getHiredAdvisors()
    return self.advisors
end

--- Get faction standing
-- @param factionId The faction ID
-- @return standing_value
function OrganizationService:getFactionStanding(factionId)
    return self.factionRelations[factionId] or 0
end

--- Modify faction standing
-- @param factionId The faction ID
-- @param amount Amount to modify
-- @param reason Reason for the change
-- @return new_standing
function OrganizationService:modifyFactionStanding(factionId, amount, reason)
    local current = self:getFactionStanding(factionId)
    local newStanding = current + amount

    -- Clamp to reasonable range
    newStanding = math.max(-100, math.min(100, newStanding))

    self.factionRelations[factionId] = newStanding

    -- Fire event
    self:_fireEvent('org:faction_standing_changed', {
        faction_id = factionId,
        old_standing = current,
        new_standing = newStanding,
        change = amount,
        reason = reason
    })

    return newStanding
end

--- Get organization statistics
-- @return Statistics table
function OrganizationService:getStats()
    local _, fame = self:getFame()
    local _, karma = self:getKarma()
    local score, funding = self:getScore()

    return {
        fame = fame,
        karma = karma,
        score = score,
        funding = funding,
        company_tier = self.companyTier,
        company_level = self.companyLevel,
        active_policies = #self.activePolicies,
        hired_advisors = #self.advisors,
        faction_relations = self.factionRelations
    }
end

--- Fire an event through the event bus
function OrganizationService:_fireEvent(eventType, data)
    if self.registry then
        local eventBus = self.registry:getService('eventBus')
        if eventBus then
            eventBus:fire(eventType, data)
        end
    end
end

--- Save organization service state
-- @return Serializable state data
function OrganizationService:saveState()
    return {
        companyTier = self.companyTier,
        companyLevel = self.companyLevel,
        activePolicies = self.activePolicies,
        advisors = self.advisors,
        divisions = self.divisions,
        factionRelations = self.factionRelations
    }
end

--- Load organization service state
-- @param state Saved state data
function OrganizationService:loadState(state)
    self.companyTier = state.companyTier or OrganizationService.COMPANY_TIERS.FRONT
    self.companyLevel = state.companyLevel or 1
    self.activePolicies = state.activePolicies or {}
    self.advisors = state.advisors or {}
    self.divisions = state.divisions or {}
    self.factionRelations = state.factionRelations or {}
end

--- Convert to string representation
-- @return String representation
function OrganizationService:__tostring()
    local stats = self:getStats()
    return string.format("OrganizationService{tier=%s, fame=%d, karma=%d, score=%d, policies=%d}",
                        stats.company_tier, stats.fame, stats.karma, stats.score, stats.active_policies)
end

return OrganizationService