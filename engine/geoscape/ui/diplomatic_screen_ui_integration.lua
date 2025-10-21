--- Diplomatic Screen UI Integration
-- Integrates diplomacy screen with faction data and decisions
-- Connects: diplomatic_screen_ui.lua → diplomatic_ai.lua, faction systems
--
-- @module diplomatic_screen_ui_integration
-- @author AI Development Team
-- @license MIT

local DiplomaticScreenUIIntegration = {}

--- Initialize diplomatic screen with real faction data
-- @param factions Real factions table
-- @param diplomaticAI Diplomatic AI instance
-- @return Integrated diplomatic UI instance
function DiplomaticScreenUIIntegration:new(factions, diplomaticAI)
    local instance = {
        factions = factions or {},
        diplomaticAI = diplomaticAI,
        selectedFaction = 1,
        selectedMessage = 1,
        selectedDecision = 1,
        viewMode = "overview",
        messages = {},
        decisions = {},
    }
    setmetatable(instance, { __index = self })
    return instance
end

--- Generate diplomatic messages from AI
function DiplomaticScreenUIIntegration:generateMessages()
    self.messages = {}
    
    for i, faction in ipairs(self.factions) do
        local message = {
            factionId = faction.id or i,
            factionName = faction.name or ("Faction " .. i),
            timestamp = os.time(),
            unread = faction.unread or false,
        }
        
        if self.diplomaticAI then
            message.subject = self.diplomaticAI:generateMessageSubject(faction)
            message.content = self.diplomaticAI:generateMessageContent(faction)
        else
            message.subject = self:generateDefaultSubject(faction)
            message.content = self:generateDefaultContent(faction)
        end
        
        table.insert(self.messages, message)
    end
end

--- Generate default message subject
function DiplomaticScreenUIIntegration:generateDefaultSubject(faction)
    local subjects = {
        {text = "Funding Approved", priority = "CRITICAL"},
        {text = "Equipment Available", priority = "NORMAL"},
        {text = "Trade Proposal", priority = "IMPORTANT"},
        {text = "Status Update", priority = "MINOR"},
        {text = "Mission Request", priority = "CRITICAL"},
    }
    return subjects[((faction.id or 1) % #subjects) + 1].text
end

--- Generate default message content
function DiplomaticScreenUIIntegration:generateDefaultContent(faction)
    if faction.relations > 70 then
        return "Relations with your organization are excellent. We're pleased with your performance and would like to increase our support."
    elseif faction.relations > 50 then
        return "We're satisfied with current arrangements. Let us know if you need anything from our end."
    elseif faction.relations > 30 then
        return "Our relationship has been cordial, though there's room for improvement. Perhaps we can find mutually beneficial opportunities."
    else
        return "Relations have been strained. We need to talk about improving our partnership."
    end
end

--- Generate decisions from AI
function DiplomaticScreenUIIntegration:generateDecisions()
    self.decisions = {}
    
    for i, faction in ipairs(self.factions) do
        if i > 3 then break end -- Limit to 3 decisions
        
        local decision = {
            factionId = faction.id or i,
            factionName = faction.name or ("Faction " .. i),
            deadline = os.time() + (7 * 24 * 3600), -- 7 days
        }
        
        if self.diplomaticAI then
            decision.title = self.diplomaticAI:generateDecisionTitle(faction)
            decision.description = self.diplomaticAI:generateDecisionDescription(faction)
            decision.reward = self.diplomaticAI:calculateDecisionReward(faction)
            decision.risk = self.diplomaticAI:calculateDecisionRisk(faction)
        else
            decision.title = self:generateDefaultDecisionTitle(faction)
            decision.description = self:generateDefaultDecisionDescription(faction)
            decision.reward = self:generateDefaultReward(faction)
            decision.risk = self:generateDefaultRisk(faction)
        end
        
        table.insert(self.decisions, decision)
    end
end

--- Generate default decision title
function DiplomaticScreenUIIntegration:generateDefaultDecisionTitle(faction)
    if faction.relations > 70 then
        return "Expand Partnership"
    elseif faction.relations > 50 then
        return "Negotiate Agreement"
    elseif faction.relations > 30 then
        return "Improve Relations"
    else
        return "Reconciliation Proposal"
    end
end

--- Generate default decision description
function DiplomaticScreenUIIntegration:generateDefaultDecisionDescription(faction)
    return "A new opportunity to strengthen our partnership and achieve mutual goals."
end

--- Generate default decision reward
function DiplomaticScreenUIIntegration:generateDefaultReward(faction)
    local base = (faction.relations or 50) * 10
    return {
        relations = math.floor(base / 100) * 10,
        funding = math.floor(base / 50),
        influence = math.floor((100 - (faction.relations or 50)) / 5),
    }
end

--- Generate default decision risk
function DiplomaticScreenUIIntegration:generateDefaultRisk(faction)
    local riskFactor = 100 - (faction.relations or 50)
    return {
        relationsDamage = math.floor(riskFactor / 10),
        conflicts = riskFactor > 40 and "High" or "Low",
        timeRequired = math.floor(riskFactor / 20) + 1,
    }
end

--- Calculate total monthly funding from all factions
function DiplomaticScreenUIIntegration:calculateTotalFunding()
    local total = 0
    for i, faction in ipairs(self.factions) do
        total = total + (faction.monthlyFunding or 0)
    end
    return total
end

--- Get faction summary statistics
function DiplomaticScreenUIIntegration:getFactionStats()
    local stats = {
        allied = 0,
        favorable = 0,
        neutral = 0,
        tense = 0,
        unfriendly = 0,
        totalRelations = 0,
    }
    
    for i, faction in ipairs(self.factions) do
        local relations = faction.relations or 50
        stats.totalRelations = stats.totalRelations + relations
        
        if relations >= 70 then
            stats.allied = stats.allied + 1
        elseif relations >= 50 then
            stats.favorable = stats.favorable + 1
        elseif relations >= 40 then
            stats.neutral = stats.neutral + 1
        elseif relations >= 20 then
            stats.tense = stats.tense + 1
        else
            stats.unfriendly = stats.unfriendly + 1
        end
    end
    
    stats.averageRelations = math.floor(stats.totalRelations / #self.factions)
    
    return stats
end

--- Draw faction overview
function DiplomaticScreenUIIntegration:drawFactionsOverview()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Diplomatic Relations", 20, 20)
    
    -- Left panel: Faction list
    local listX = 20
    local listY = 70
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", listX, listY, 300, 600)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", listX, listY, 300, 600)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Factions", listX + 10, listY + 10)
    
    local factionY = listY + 40
    for i, faction in ipairs(self.factions) do
        if i > 6 then break end
        
        local relations = faction.relations or 50
        local tierColor = relations >= 70 and {0, 1, 0} or (relations >= 50 and {0, 1, 1} or (relations >= 40 and {1, 1, 0} or (relations >= 20 and {1, 0.5, 0} or {1, 0, 0})))
        
        if self.selectedFaction == i then
            love.graphics.setColor(0, 1, 0, 0.2)
            love.graphics.rectangle("fill", listX + 5, factionY - 2, 290, 85)
        end
        
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.rectangle("line", listX + 5, factionY - 2, 290, 85)
        
        -- Name
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print(faction.name or ("Faction " .. i), listX + 15, factionY)
        
        -- Relations bar
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", listX + 15, factionY + 20, 160, 12)
        
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.rectangle("fill", listX + 15, factionY + 20, 160 * (relations / 100), 12)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.printf(relations, listX + 15, factionY + 21, 160, "center")
        
        -- Funding
        if faction.monthlyFunding and faction.monthlyFunding > 0 then
            love.graphics.setColor(0, 1, 0)
            love.graphics.setFont(love.graphics.newFont(8))
            love.graphics.print("+" .. faction.monthlyFunding .. "/mo", listX + 15, factionY + 40)
        end
        
        -- Trait
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.print(faction.trait or "General", listX + 15, factionY + 55)
        
        factionY = factionY + 90
    end
    
    -- Middle panel: Selected faction details
    local detailX = 330
    local detailY = 70
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", detailX, detailY, 300, 600)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", detailX, detailY, 300, 600)
    
    if self.selectedFaction <= #self.factions then
        local faction = self.factions[self.selectedFaction]
        
        love.graphics.setColor(1, 1, 0)
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.print(faction.name or "Faction", detailX + 10, detailY + 10)
        
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(10))
        local infoY = detailY + 45
        
        local details = {
            {"Status:", faction.status or "Neutral"},
            {"Relations:", (faction.relations or 50) .. "/100"},
            {"Funding:", faction.monthlyFunding and ("$" .. faction.monthlyFunding) or "None"},
            {"Trait:", faction.trait or "Unknown"},
            {"Recent:", faction.lastContact and "3 days ago" or "Never"},
        }
        
        for i, item in ipairs(details) do
            love.graphics.setColor(0.7, 0.7, 0.8)
            love.graphics.print(item[1], detailX + 10, infoY)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(item[2], detailX + 120, infoY)
            
            infoY = infoY + 30
        end
    end
    
    -- Right panel: Statistics
    local statsX = 640
    local statsY = 70
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", statsX, statsY, 300, 600)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", statsX, statsY, 300, 600)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Diplomatic Status", statsX + 10, statsY + 10)
    
    local stats = self:getFactionStats()
    local totalFunding = self:calculateTotalFunding()
    
    -- Total funding
    love.graphics.setColor(0, 1, 0)
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.print("Total Monthly Funding:", statsX + 10, statsY + 50)
    love.graphics.print("$" .. totalFunding, statsX + 10, statsY + 70)
    
    -- Status counts
    local statY = statsY + 110
    local statusCounts = {
        {label = "Allied:", count = stats.allied, color = {0, 1, 0}},
        {label = "Favorable:", count = stats.favorable, color = {0, 1, 1}},
        {label = "Neutral:", count = stats.neutral, color = {1, 1, 0}},
        {label = "Tense:", count = stats.tense, color = {1, 0.5, 0}},
        {label = "Unfriendly:", count = stats.unfriendly, color = {1, 0, 0}},
    }
    
    for i, status in ipairs(statusCounts) do
        love.graphics.setColor(status.color[1], status.color[2], status.color[3])
        love.graphics.rectangle("fill", statsX + 10, statY - 4, 8, 8)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.print(status.label, statsX + 25, statY - 5)
        love.graphics.print(status.count, statsX + 260, statY - 5)
        
        statY = statY + 25
    end
    
    -- Overall stability
    statY = statY + 20
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("Stability Rating:", statsX + 10, statY)
    
    local stability = stats.averageRelations / 100
    local stabColor = stability > 0.7 and {0, 1, 0} or (stability > 0.5 and {1, 1, 0} or {1, 0, 0})
    
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", statsX + 10, statY + 20, 280, 25)
    
    love.graphics.setColor(stabColor[1], stabColor[2], stabColor[3])
    love.graphics.rectangle("fill", statsX + 10, statY + 20, 280 * stability, 25)
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf(math.floor(stability * 100) .. "%", statsX + 10, statY + 23, 280, "center")
end

--- Handle input
function DiplomaticScreenUIIntegration:handleInput(key)
    if key == "up" then
        self.selectedFaction = math.max(1, self.selectedFaction - 1)
    elseif key == "down" then
        self.selectedFaction = math.min(#self.factions, self.selectedFaction + 1)
    elseif key == "tab" then
        self.viewMode = self.viewMode == "overview" and "messages" or "overview"
    end
end

--- Draw main interface
function DiplomaticScreenUIIntegration:draw()
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, 960, 720)
    
    self:generateMessages()
    self:generateDecisions()
    
    self:drawFactionsOverview()
    
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("[↑↓]Select Faction  [TAB]Messages  [ESC]Close", 10, 705)
end

return DiplomaticScreenUIIntegration



