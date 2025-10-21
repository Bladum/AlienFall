--- Diplomatic Screen UI
-- Faction relations, diplomacy, and decision-making
-- Shows: faction status, relations tracking, messages, diplomatic options
-- Integrates with: diplomatic_ai.lua, economy/finance systems
--
-- @module diplomatic_screen_ui
-- @author AI Development Team
-- @license MIT

local DiplomaticScreenUI = {}

--- Create new diplomatic screen instance
-- @param gameState Game state containing factions and relations
-- @return Diplomatic screen UI instance
function DiplomaticScreenUI:new(gameState)
    local instance = {
        gameState = gameState,
        selectedFaction = 1, -- Currently selected faction
        selectedMessage = 1, -- Currently selected message
        viewMode = "overview", -- overview, relations, messages, decisions
        scroll = 0,
        showDecisionPanel = false,
        selectedDecision = 1,
    }
    setmetatable(instance, { __index = self })
    return instance
end

--- Get faction info with colors and status
function DiplomaticScreenUI:getFactionInfo(factionId)
    local factions = {
        {
            id = 1,
            name = "Council of Nations",
            color = {0, 1, 1},
            status = "ALLIED",
            relations = 85,
            funding = 12000,
            priority = "CRITICAL",
            trait = "Funding Source",
            recentMessage = "Increased funding approved - perform 2 missions for 250% rewards",
            messageTime = "Today",
        },
        {
            id = 2,
            name = "Phobos Corporation",
            color = {1, 1, 0},
            status = "NEUTRAL",
            relations = 50,
            funding = 0,
            priority = "IMPORTANT",
            trait = "Equipment Supplier",
            recentMessage = "New heavy weapons available - discount for loyal customers",
            messageTime = "2 days ago",
        },
        {
            id = 3,
            name = "Black Market",
            color = {1, 0.5, 0},
            status = "TENSE",
            relations = 35,
            funding = 0,
            priority = "MINOR",
            trait = "Black Market",
            recentMessage = "We have 'special' items if you need them... discretely",
            messageTime = "3 days ago",
        },
        {
            id = 4,
            name = "International Government",
            color = {0, 1, 0},
            status = "FAVORABLE",
            relations = 70,
            funding = 5000,
            priority = "IMPORTANT",
            trait = "Secondary Funding",
            recentMessage = "Trade agreement proposed - mutual benefits",
            messageTime = "1 week ago",
        },
        {
            id = 5,
            name = "Resistance Cells",
            color = {1, 0, 0},
            status = "UNFRIENDLY",
            relations = 20,
            funding = 0,
            priority = "CRITICAL",
            trait = "Intelligence",
            recentMessage = "You work for the government. We do not negotiate.",
            messageTime = "1 week ago",
        },
    }
    return factions[factionId] or factions[1]
end

--- Draw overview panel (all factions at a glance)
function DiplomaticScreenUI:drawOverview()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Diplomatic Relations", 20, 20)
    
    -- Left panel: Faction list
    self:drawFactionList(20, 70, 300, 600)
    
    -- Middle panel: Faction details
    self:drawFactionDetails(330, 70, 300, 600)
    
    -- Right panel: Relationship chart
    self:drawRelationshipChart(640, 70, 300, 600)
end

--- Draw faction list
function DiplomaticScreenUI:drawFactionList(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Factions", x + 10, y + 10)
    
    local factions = {
        self:getFactionInfo(1),
        self:getFactionInfo(2),
        self:getFactionInfo(3),
        self:getFactionInfo(4),
        self:getFactionInfo(5),
    }
    
    local factionY = y + 40
    for i, faction in ipairs(factions) do
        -- Highlight selected
        if self.selectedFaction == i then
            love.graphics.setColor(0, 1, 0, 0.2)
            love.graphics.rectangle("fill", x + 5, factionY - 2, width - 10, 95)
        end
        
        -- Border
        love.graphics.setColor(faction.color[1], faction.color[2], faction.color[3])
        love.graphics.rectangle("line", x + 5, factionY - 2, width - 10, 95)
        
        -- Status indicator (left bar)
        love.graphics.rectangle("fill", x + 8, factionY, 4, 90)
        
        -- Faction name
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print(faction.name, x + 20, factionY)
        
        -- Status
        love.graphics.setColor(faction.color[1], faction.color[2], faction.color[3])
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.printf(faction.status, x + 20, factionY + 16, width - 40, "left")
        
        -- Relations bar
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", x + 20, factionY + 32, 140, 12)
        
        local relColor = faction.relations > 70 and {0, 1, 0} or (faction.relations > 50 and {1, 1, 0} or (faction.relations > 30 and {1, 0.5, 0} or {1, 0, 0}))
        love.graphics.setColor(relColor[1], relColor[2], relColor[3])
        love.graphics.rectangle("fill", x + 20, factionY + 32, 140 * (faction.relations / 100), 12)
        
        -- Relations text
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.printf(faction.relations, x + 20, factionY + 33, 140, "center")
        
        -- Funding
        if faction.funding > 0 then
            love.graphics.setColor(0, 1, 0)
            love.graphics.setFont(love.graphics.newFont(8))
            love.graphics.printf("+" .. faction.funding .. "/month", x + 20, factionY + 50, 140, "left")
        end
        
        -- Trait
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.printf(faction.trait, x + 20, factionY + 65, 140, "left")
        
        factionY = factionY + 100
    end
end

--- Draw faction details panel
function DiplomaticScreenUI:drawFactionDetails(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    local faction = self:getFactionInfo(self.selectedFaction)
    
    love.graphics.setColor(faction.color[1], faction.color[2], faction.color[3])
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print(faction.name, x + 10, y + 10)
    
    -- Status details
    local detailY = y + 50
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.setFont(love.graphics.newFont(10))
    
    local details = {
        {"Status:", faction.status},
        {"Relations:", faction.relations .. "/100"},
        {"", ""},
        {"Trait:", faction.trait},
        {"Funding:", faction.funding > 0 and ("$" .. faction.funding .. "/month") or "None"},
        {"", ""},
        {"Recent Message:", ""},
    }
    
    for i, detail in ipairs(details) do
        if detail[1] == "" then
            detailY = detailY + 10
        else
            love.graphics.setColor(0.7, 0.7, 0.8)
            love.graphics.print(detail[1], x + 10, detailY)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(tostring(detail[2]), x + 120, detailY)
            
            detailY = detailY + 20
        end
    end
    
    -- Recent message (multi-line)
    love.graphics.setColor(faction.color[1], faction.color[2], faction.color[3])
    love.graphics.setFont(love.graphics.newFont(8))
    love.graphics.printf(faction.messageTime, x + 10, detailY, width - 20, "left")
    
    detailY = detailY + 15
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setFont(love.graphics.newFont(9))
    love.graphics.printf("\"" .. faction.recentMessage .. "\"", x + 10, detailY, width - 20, "left")
    
    -- Action buttons
    local buttonY = y + height - 60
    self:drawButton(x + 10, buttonY, 130, 25, "Send Message")
    self:drawButton(x + 145, buttonY, 130, 25, "Negotiate")
end

--- Draw relationship chart
function DiplomaticScreenUI:drawRelationshipChart(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Relations Summary", x + 10, y + 10)
    
    -- Total funding
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("Total Monthly Funding:", x + 10, y + 45)
    
    love.graphics.setColor(0, 1, 0)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("$17,000", x + 10, y + 65)
    
    -- Relationship status
    local statusY = y + 110
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("Status Overview:", x + 10, statusY)
    
    local statuses = {
        {label = "Allied:", count = 1, color = {0, 1, 0}},
        {label = "Favorable:", count = 1, color = {0, 1, 1}},
        {label = "Neutral:", count = 1, color = {1, 1, 0}},
        {label = "Tense:", count = 1, color = {1, 0.5, 0}},
        {label = "Unfriendly:", count = 1, color = {1, 0, 0}},
    }
    
    local statusItemY = statusY + 30
    for i, status in ipairs(statuses) do
        love.graphics.setColor(status.color[1], status.color[2], status.color[3])
        love.graphics.rectangle("fill", x + 10, statusItemY - 4, 8, 8)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.print(status.label, x + 25, statusItemY - 5)
        love.graphics.print(status.count, x + 200, statusItemY - 5)
        
        statusItemY = statusItemY + 20
    end
    
    -- Stability rating
    statusItemY = statusItemY + 15
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("Overall Stability:", x + 10, statusItemY)
    
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", x + 10, statusItemY + 20, 150, 25)
    
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", x + 10, statusItemY + 20, 150 * 0.68, 25)
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.printf("68%", x + 10, statusItemY + 23, 150, "center")
    
    -- Warning/notice
    statusItemY = statusItemY + 65
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.print("Caution: Relations with", x + 10, statusItemY)
    love.graphics.print("Resistance Cells critical", x + 10, statusItemY + 15)
end

--- Draw messages/communications panel
function DiplomaticScreenUI:drawMessagesView()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Diplomatic Communications", 20, 20)
    
    -- Left panel: Message list
    local listX = 20
    local listY = 70
    local listWidth = 300
    local listHeight = 600
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", listX, listY, listWidth, listHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", listX, listY, listWidth, listHeight)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Messages", listX + 10, listY + 10)
    
    -- Mock messages
    local messages = {
        {faction = "Council of Nations", subject = "Funding Approval", unread = false, time = "Today"},
        {faction = "Phobos Corp", subject = "Equipment Available", unread = true, time = "Today"},
        {faction = "Int'l Government", subject = "Trade Proposal", unread = false, time = "2 days"},
        {faction = "Council of Nations", subject = "Mission Priority Updated", unread = false, time = "3 days"},
        {faction = "Black Market", subject = "Discrete Services", unread = false, time = "1 week"},
    }
    
    local messageY = listY + 40
    for i, msg in ipairs(messages) do
        if self.selectedMessage == i then
            love.graphics.setColor(0, 1, 0, 0.2)
            love.graphics.rectangle("fill", listX + 5, messageY - 2, listWidth - 10, 65)
        end
        
        love.graphics.setColor(msg.unread and {0, 1, 0} or {0.5, 0.5, 0.5})
        love.graphics.rectangle("line", listX + 5, messageY - 2, listWidth - 10, 65)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.print(msg.faction, listX + 15, messageY)
        
        love.graphics.setColor(msg.unread and {1, 1, 1} or {0.7, 0.7, 0.8})
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.print(msg.subject, listX + 15, messageY + 16)
        
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.printf(msg.time, listX + 15, messageY + 32, listWidth - 40, "left")
        
        messageY = messageY + 70
    end
    
    -- Right panel: Message content
    if self.selectedMessage <= #messages then
        local msg = messages[self.selectedMessage]
        local contentX = 330
        local contentY = 70
        
        love.graphics.setColor(0.15, 0.15, 0.2)
        love.graphics.rectangle("fill", contentX, contentY, 620, 600)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", contentX, contentY, 620, 600)
        
        love.graphics.setColor(0, 1, 0)
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.print(msg.faction, contentX + 10, contentY + 10)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.print(msg.subject, contentX + 10, contentY + 35)
        
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.print(msg.time, contentX + 10, contentY + 60)
        
        -- Message content
        local content = ""
        if msg.subject == "Funding Approval" then
            content = "Our council has reviewed your recent missions. The results are impressive. We've approved an increase to your base funding of $12,000 per month.\n\nAdditionally, we'd like to propose a new mission contract. Neutralize the alien activity in the Asian Pacific region. Successful completion will result in a 250% funding bonus.\n\nLet us know if you can accept this mission.\n\n- Council Director"
        elseif msg.subject == "Equipment Available" then
            content = "Excellent timing on that salvage haul. We've got fresh inventory in stock.\n\nNew arrivals:\n- Plasma Rifle (Medium/High damage)\n- Alien Grenades (Radius damage)\n- Combat Armor MkII (Improved protection)\n\nAs a valued customer, you get 15% discount on all items.\n\n- Phobos Corp Supply Officer"
        elseif msg.subject == "Trade Proposal" then
            content = "We propose mutual trade agreement. You supply salvage and research data, we provide preferred access to military equipment and supplies.\n\nThis would benefit both our nations significantly.\n\nProposed terms:\n- Reciprocal 10% discount on purchases\n- Monthly intelligence sharing\n- Diplomatic cooperation against UFO threat\n\nWhat do you think?\n\n- Int'l Relations Bureau"
        end
        
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.printf(content, contentX + 10, contentY + 90, 600, "left")
    end
end

--- Draw decisions/actions panel
function DiplomaticScreenUI:drawDecisionsView()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Pending Decisions", 20, 20)
    
    -- Mock decision data
    local decisions = {
        {
            faction = "Council of Nations",
            title = "Accept Mission: Asia Pacific",
            description = "Deploy to neutralize alien activity in Asia Pacific region",
            reward = "$30,000 + $12,000 bonus",
            risk = "3-4 missions required",
            deadline = "7 days",
            consequences = "Increase relations, gain funding",
            status = "PENDING",
        },
        {
            faction = "Phobos Corporation",
            title = "Supply Contract",
            description = "Provide 5 units of alien salvage for equipment discount",
            reward = "15% discount on all purchases",
            risk = "Requires alien salvage",
            deadline = "30 days",
            consequences = "Improve relations with Phobos",
            status = "PENDING",
        },
        {
            faction = "Int'l Government",
            title = "Trade Agreement",
            description = "Mutual trade and intelligence sharing agreement",
            reward = "Preferred equipment access",
            risk = "Share intelligence data",
            deadline = "Immediate",
            consequences = "Improve relations, gain trade benefits",
            status = "PENDING",
        },
    }
    
    local cardX = 20
    local cardY = 70
    local cardWidth = 450
    local cardHeight = 240
    
    for i, decision in ipairs(decisions) do
        if cardY + cardHeight + 20 > 720 then break end
        
        -- Card background
        if self.selectedDecision == i then
            love.graphics.setColor(0, 1, 0, 0.1)
        else
            love.graphics.setColor(0.15, 0.15, 0.2)
        end
        love.graphics.rectangle("fill", cardX, cardY, cardWidth, cardHeight)
        
        love.graphics.setColor(0.3, 0.3, 0.4)
        love.graphics.rectangle("line", cardX, cardY, cardWidth, cardHeight)
        
        -- Header
        love.graphics.setColor(0, 1, 1)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print(decision.faction, cardX + 10, cardY + 10)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.print(decision.title, cardX + 10, cardY + 30)
        
        -- Details
        local detailY = cardY + 55
        love.graphics.setFont(love.graphics.newFont(9))
        
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.print("Reward:", cardX + 10, detailY)
        love.graphics.setColor(0, 1, 0)
        love.graphics.print(decision.reward, cardX + 100, detailY)
        
        detailY = detailY + 20
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.print("Risk:", cardX + 10, detailY)
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.print(decision.risk, cardX + 100, detailY)
        
        detailY = detailY + 20
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.print("Deadline:", cardX + 10, detailY)
        love.graphics.setColor(1, 1, 0)
        love.graphics.print(decision.deadline, cardX + 100, detailY)
        
        detailY = detailY + 30
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.print("Consequence:", cardX + 10, detailY)
        love.graphics.setColor(0, 1, 1)
        love.graphics.printf(decision.consequences, cardX + 100, detailY, cardWidth - 120, "left")
        
        -- Action buttons
        local buttonY = cardY + cardHeight - 35
        self:drawButton(cardX + 10, buttonY, 100, 25, "Accept")
        self:drawButton(cardX + 120, buttonY, 100, 25, "Decline")
        self:drawButton(cardX + 230, buttonY, 200, 25, "View Details")
        
        cardY = cardY + cardHeight + 10
    end
    
    -- Right side: Impact calculator
    local impactX = 490
    local impactY = 70
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", impactX, impactY, 450, 600)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", impactX, impactY, 450, 600)
    
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Decision Impact", impactX + 10, impactY + 10)
    
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.print("Select a decision to see impact analysis", impactX + 10, impactY + 50)
    
    if self.selectedDecision <= #decisions then
        local dec = decisions[self.selectedDecision]
        
        local impactAnalysisY = impactY + 50
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.print(dec.title, impactX + 10, impactAnalysisY)
        
        impactAnalysisY = impactAnalysisY + 30
        
        local impacts = {
            {label = "Relations Impact:", value = "+15", color = {0, 1, 0}},
            {label = "Funding Impact:", value = "+$5k/month", color = {0, 1, 0}},
            {label = "Conflict Risk:", value = "Low", color = {0, 1, 0}},
            {label = "Time Investment:", value = "2-3 missions", color = {1, 1, 0}},
            {label = "Resource Cost:", value = "-$500", color = {1, 0, 0}},
        }
        
        for i, impact in ipairs(impacts) do
            love.graphics.setColor(0.7, 0.7, 0.8)
            love.graphics.setFont(love.graphics.newFont(10))
            love.graphics.print(impact.label, impactX + 10, impactAnalysisY)
            
            love.graphics.setColor(impact.color[1], impact.color[2], impact.color[3])
            love.graphics.print(impact.value, impactX + 300, impactAnalysisY)
            
            impactAnalysisY = impactAnalysisY + 25
        end
        
        impactAnalysisY = impactAnalysisY + 20
        love.graphics.setColor(1, 1, 0)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print("Recommendation:", impactX + 10, impactAnalysisY)
        
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.printf("Accepting this decision improves relations and provides a steady funding increase. Recommended for long-term stability.", impactX + 10, impactAnalysisY + 20, 430, "left")
    end
end

--- Draw button helper
function DiplomaticScreenUI:drawButton(x, y, width, height, label)
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(9))
    love.graphics.printf(label, x, y + height / 2 - 5, width, "center")
end

--- Handle keyboard input
function DiplomaticScreenUI:handleInput(key)
    if key == "tab" then
        local modes = {"overview", "messages", "decisions"}
        local currentIndex = 1
        for i, m in ipairs(modes) do
            if m == self.viewMode then
                currentIndex = i
                break
            end
        end
        self.viewMode = modes[(currentIndex % #modes) + 1]
    elseif key == "up" then
        if self.viewMode == "overview" then
            self.selectedFaction = math.max(1, self.selectedFaction - 1)
        elseif self.viewMode == "messages" then
            self.selectedMessage = math.max(1, self.selectedMessage - 1)
        end
    elseif key == "down" then
        if self.viewMode == "overview" then
            self.selectedFaction = math.min(5, self.selectedFaction + 1)
        elseif self.viewMode == "messages" then
            self.selectedMessage = math.min(5, self.selectedMessage + 1)
        end
    end
end

--- Main draw function
function DiplomaticScreenUI:draw()
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, 960, 720)
    
    if self.viewMode == "overview" then
        self:drawOverview()
    elseif self.viewMode == "messages" then
        self:drawMessagesView()
    elseif self.viewMode == "decisions" then
        self:drawDecisionsView()
    end
    
    -- Footer
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("[TAB]Change View  [↑↓]Select  [ENTER]Interact  [ESC]Close", 10, 705)
end

return DiplomaticScreenUI



