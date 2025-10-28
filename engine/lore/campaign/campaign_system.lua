---Campaign System - Dynamic Mission Generation Engine
---
---Manages campaign definitions and mission spawning logic. Campaigns spawn missions
---weekly or monthly based on faction activity. Escalation system increases from
---2 campaigns/month (Quarter 1) to 10 campaigns/month (Quarter 8) for difficulty progression.
---
---Campaign Structure:
---  - ID and name for identification
---  - Faction ownership
---  - Mission spawning script (types, frequency, locations)
---  - Spawn frequency (weekly or monthly)
---  - Active status (can be disabled)
---  - Mission counter for tracking
---
---Escalation System:
---  - Q1-Q2: 2 campaigns/month (early game)
---  - Q3-Q4: 4 campaigns/month (mid game)
---  - Q5-Q6: 6 campaigns/month (late mid game)
---  - Q7-Q8: 8-10 campaigns/month (end game)
---
---Key Exports:
---  - CampaignSystem.new(): Creates campaign system instance
---  - registerCampaign(campaign): Adds campaign definition
---  - getCampaign(campaignId): Returns campaign data
---  - getActiveCampaigns(): Returns currently active campaigns
---  - getCampaignsForQuarter(quarter): Returns campaigns for difficulty level
---  - spawnMissionFromCampaign(campaignId): Generates mission
---
---Dependencies:
---  - lore.missions.mission_system: Mission generation
---  - lore.factions: Faction definitions
---  - lore.calendar: Time tracking for spawning
---
---@module lore.campaign.campaign_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local CampaignSystem = require("lore.campaign.campaign_system")
---  local campaigns = CampaignSystem.new()
---  campaigns:registerCampaign({
---    id = "terror_campaign",
---    factionId = "aliens",
---    spawnFrequency = "weekly"
---  })
---
---@see lore.campaign.campaign_manager For campaign execution
---@see lore.missions For mission system

local CampaignSystem = {}
CampaignSystem.__index = CampaignSystem

---@class Campaign
---@field id string Campaign ID
---@field name string Campaign name
---@field factionId string Owner faction
---@field missionScript string Mission spawning script
---@field spawnFrequency string "weekly" or "monthly"
---@field active boolean Is campaign active
---@field missionsSpawned number Count of spawned missions
---@field disabledByResearch boolean Disabled by technology

--- Create new campaign system
function CampaignSystem.new()
    local self = setmetatable({}, CampaignSystem)
    
    -- All campaigns
    self.campaigns = {}
    
    -- Active campaigns (currently running)
    self.activeCampaigns = {}
    
    -- Campaign templates (for spawning new campaigns)
    self.templates = {}
    
    -- Escalation settings
    self.escalation = {
        baseCampaigns = 2,        -- Start with 2/month
        campaignsPerQuarter = 1,  -- +1 per quarter
        maxCampaigns = 10,        -- Cap at 10/month
    }
    
    -- Calendar tracking
    self.currentQuarter = 1
    self.currentMonth = 1
    
    print("[CampaignSystem] Initialized")
    return self
end

--- Add campaign template
---@param campaign Campaign Campaign template
function CampaignSystem:addTemplate(campaign)
    self.templates[campaign.id] = campaign
    print("[CampaignSystem] Added template: " .. campaign.name)
end

--- Calculate campaigns per month for current quarter
---@return number Campaigns to spawn
function CampaignSystem:getCampaignsPerMonth()
    local count = self.escalation.baseCampaigns + 
                 (self.currentQuarter - 1) * self.escalation.campaignsPerQuarter
    return math.min(count, self.escalation.maxCampaigns)
end

--- Spawn campaigns for month (called on 1st day)
---@param factionSystem table FactionSystem instance
function CampaignSystem:spawnMonthlyCampaigns(factionSystem)
    local count = self:getCampaignsPerMonth()
    
    print(string.format("[CampaignSystem] Spawning %d campaigns for month %d, quarter %d", 
          count, self.currentMonth, self.currentQuarter))
    
    -- Get available factions (not researched, active)
    local availableFactions = {}
    for _, faction in pairs(factionSystem:getActiveFactions()) do
        if not factionSystem:areCampaignsDisabled(faction.id) then
            table.insert(availableFactions, faction)
        end
    end
    
    if #availableFactions == 0 then
        print("[CampaignSystem] No available factions for campaigns")
        return
    end
    
    -- Spawn campaigns
    for i = 1, count do
        -- Pick random faction
        local faction = availableFactions[math.random(#availableFactions)]
        
        -- Pick random campaign template for faction
        local template = self:getRandomTemplateForFaction(faction.id)
        
        if template then
            self:startCampaign(template, faction)
        end
    end
end

--- Get random campaign template for faction
---@param factionId string Faction ID
---@return Campaign|nil Template
function CampaignSystem:getRandomTemplateForFaction(factionId)
    local factionTemplates = {}
    
    for _, template in pairs(self.templates) do
        if template.factionId == factionId then
            table.insert(factionTemplates, template)
        end
    end
    
    if #factionTemplates == 0 then return nil end
    
    return factionTemplates[math.random(#factionTemplates)]
end

--- Start new campaign
---@param template Campaign Campaign template
---@param faction table Faction data
function CampaignSystem:startCampaign(template, faction)
    local campaignId = template.id .. "_" .. os.time()
    
    local campaign = {
        id = campaignId,
        name = template.name,
        factionId = faction.id,
        missionScript = template.missionScript,
        spawnFrequency = template.spawnFrequency or "weekly",
        active = true,
        missionsSpawned = 0,
        disabledByResearch = false,
        startDay = self.currentDay or 1,
    }
    
    self.campaigns[campaignId] = campaign
    table.insert(self.activeCampaigns, campaignId)
    
    print(string.format("[CampaignSystem] Started campaign: %s (%s)", 
          campaign.name, faction.name))
end

--- Update campaigns (daily)
---@param day number Current day
function CampaignSystem:dailyUpdate(day)
    self.currentDay = day
    
    -- Check weekly campaign spawning
    if day % 7 == 0 then
        self:weeklyUpdate()
    end
end

--- Weekly update (spawn missions from weekly campaigns)
function CampaignSystem:weeklyUpdate()
    print("[CampaignSystem] Weekly update")
    
    for _, campaignId in ipairs(self.activeCampaigns) do
        local campaign = self.campaigns[campaignId]
        
        if campaign and campaign.active and campaign.spawnFrequency == "weekly" then
            self:spawnMissionFromCampaign(campaign)
        end
    end
end

--- Spawn mission from campaign
---@param campaign Campaign Campaign data
function CampaignSystem:spawnMissionFromCampaign(campaign)
    print(string.format("[CampaignSystem] Spawning mission from campaign: %s", campaign.name))
    
    -- This would integrate with MissionSystem to create actual mission
    campaign.missionsSpawned = campaign.missionsSpawned + 1
    
    -- Example: spawn UFO mission, site mission, or base mission
    -- MissionSystem:spawnMission(campaign.missionScript, campaign.factionId)
end

--- Disable campaign (via research or manual)
---@param campaignId string Campaign ID
function CampaignSystem:disableCampaign(campaignId)
    local campaign = self.campaigns[campaignId]
    if not campaign then return end
    
    campaign.active = false
    campaign.disabledByResearch = true
    
    -- Remove from active list
    for i, id in ipairs(self.activeCampaigns) do
        if id == campaignId then
            table.remove(self.activeCampaigns, i)
            break
        end
    end
    
    print("[CampaignSystem] Disabled campaign: " .. campaign.name)
end

--- Update quarter (called every 3 months)
---@param quarter number New quarter (1-8)
function CampaignSystem:setQuarter(quarter)
    self.currentQuarter = quarter
    print("[CampaignSystem] Quarter " .. quarter .. ": " .. 
          self:getCampaignsPerMonth() .. " campaigns/month")
end

--- Get active campaign count
---@return number Count
function CampaignSystem:getActiveCampaignCount()
    return #self.activeCampaigns
end

--- Save state
---@return table State
function CampaignSystem:saveState()
    return {
        campaigns = self.campaigns,
        activeCampaigns = self.activeCampaigns,
        currentQuarter = self.currentQuarter,
        currentMonth = self.currentMonth,
        currentDay = self.currentDay,
    }
end

--- Load state
---@param state table Saved state
function CampaignSystem:loadState(state)
    self.campaigns = state.campaigns or {}
    self.activeCampaigns = state.activeCampaigns or {}
    self.currentQuarter = state.currentQuarter or 1
    self.currentMonth = state.currentMonth or 1
    self.currentDay = state.currentDay or 1
    
    print("[CampaignSystem] State loaded: " .. #self.activeCampaigns .. " active campaigns")
end

return CampaignSystem


























