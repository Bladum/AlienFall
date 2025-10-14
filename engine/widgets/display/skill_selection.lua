--[[
    Skill Selection Widget

    A popup widget that allows players to select which skill to use when a unit has multiple skills.
    Features:
    - Grid-aligned layout
    - Skill icons/descriptions
    - Keyboard navigation
    - Click to select
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")
local Widgets = require("widgets")

local SkillSelection = setmetatable({}, {__index = BaseWidget})
SkillSelection.__index = SkillSelection

-- Constants
local SKILL_BUTTON_WIDTH = 192  -- 8 grid cells
local SKILL_BUTTON_HEIGHT = 48  -- 2 grid cells
local SKILL_SPACING = 4
local MAX_SKILLS_PER_ROW = 2

--[[
    Create a new skill selection widget
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param unit table - The unit whose skills to display
    @param onSkillSelected function - Callback when skill is selected (skill, index)
    @param onCancel function - Callback when selection is cancelled
    @return table - New skill selection instance
]]
function SkillSelection.new(x, y, unit, onSkillSelected, onCancel)
    -- Validate input parameters
    if not unit or not unit.skills or #unit.skills == 0 then
        print("[SkillSelection] ERROR: Invalid unit or no skills available")
        return nil
    end

    -- Calculate size based on number of skills
    local numSkills = #unit.skills
    local numRows = math.ceil(numSkills / MAX_SKILLS_PER_ROW)
    local width = (SKILL_BUTTON_WIDTH * MAX_SKILLS_PER_ROW) + (SKILL_SPACING * (MAX_SKILLS_PER_ROW - 1))
    local height = (SKILL_BUTTON_HEIGHT * numRows) + (SKILL_SPACING * (numRows - 1)) + 60 -- Extra for title

    local self = BaseWidget.new(x, y, width, height, "skill_selection")
    setmetatable(self, SkillSelection)

    self.unit = unit
    self.onSkillSelected = onSkillSelected
    self.onCancel = onCancel
    self.skillButtons = {}
    self.selectedIndex = 1

    -- Create background panel
    self.background = Widgets.FrameBox.new(x, y, width, height, "Select Skill")

    -- Create skill buttons
    self:createSkillButtons()

    return self
end

--[[
    Create skill selection buttons
]]
function SkillSelection:createSkillButtons()
    if not self.unit or not self.unit.skills then return end

    local startY = self.y + 30 -- Below title

    for i, skill in ipairs(self.unit.skills) do
        local row = math.floor((i - 1) / MAX_SKILLS_PER_ROW)
        local col = (i - 1) % MAX_SKILLS_PER_ROW

        local buttonX = self.x + (col * (SKILL_BUTTON_WIDTH + SKILL_SPACING))
        local buttonY = startY + (row * (SKILL_BUTTON_HEIGHT + SKILL_SPACING))

        local button = Widgets.Button.new(buttonX, buttonY, SKILL_BUTTON_WIDTH, SKILL_BUTTON_HEIGHT,
            skill.name or ("Skill " .. i))

        -- Add skill description as tooltip
        if skill.description then
            button.tooltip = skill.description
        elseif skill.type then
            button.tooltip = string.format("Type: %s", skill.type)
        else
            button.tooltip = "Unknown skill"
        end

        -- Set up button callback
        button.onClick = function()
            self:selectSkill(i)
        end

        table.insert(self.skillButtons, button)
    end
end

--[[
    Select a skill by index
    @param index number - The skill index to select
]]
function SkillSelection:selectSkill(index)
    if not self.unit or not self.unit.skills or index < 1 or index > #self.unit.skills then
        return
    end

    local skill = self.unit.skills[index]
    print(string.format("[SkillSelection] Selected skill: %s", skill.name or "Unknown"))

    if self.onSkillSelected then
        self.onSkillSelected(skill, index)
    end

    -- Close the selection widget
    self:close()
end

--[[
    Cancel skill selection
]]
function SkillSelection:cancel()
    print("[SkillSelection] Skill selection cancelled")

    if self.onCancel then
        self.onCancel()
    end

    self:close()
end

--[[
    Close the skill selection widget
]]
function SkillSelection:close()
    -- Remove from parent or hide
    if self.parent then
        self.parent:removeChild(self)
    end
    self.visible = false
end

--[[
    Handle keyboard input
    @param key string - The key pressed
]]
function SkillSelection:keypressed(key)
    if key == "escape" then
        self:cancel()
        return true
    elseif key == "return" or key == "space" then
        self:selectSkill(self.selectedIndex)
        return true
    elseif key == "up" then
        self.selectedIndex = math.max(1, self.selectedIndex - MAX_SKILLS_PER_ROW)
        return true
    elseif key == "down" then
        local maxIndex = self.unit and self.unit.skills and #self.unit.skills or 1
        self.selectedIndex = math.min(maxIndex, self.selectedIndex + MAX_SKILLS_PER_ROW)
        return true
    elseif key == "left" then
        self.selectedIndex = math.max(1, self.selectedIndex - 1)
        return true
    elseif key == "right" then
        local maxIndex = self.unit and self.unit.skills and #self.unit.skills or 1
        self.selectedIndex = math.min(maxIndex, self.selectedIndex + 1)
        return true
    end

    return false
end

--[[
    Draw the skill selection widget
]]
function SkillSelection:draw()
    if not self.visible then return end

    -- Draw background
    self.background:draw()

    -- Draw skill buttons
    for i, button in ipairs(self.skillButtons) do
        -- Highlight selected skill
        if i == self.selectedIndex then
            love.graphics.setColor(1, 1, 0, 0.3) -- Yellow highlight
            love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
            love.graphics.setColor(1, 1, 1, 1)
        end

        button:draw()
    end

    -- Draw skill details for selected skill
    self:drawSkillDetails()
end

--[[
    Draw details of the currently selected skill
]]
function SkillSelection:drawSkillDetails()
    local selectedSkill = self.unit and self.unit.skills and self.unit.skills[self.selectedIndex]
    if not selectedSkill then return end

    local detailX = self.x + 10
    local detailY = self.y + self.height - 40

    -- Draw skill type and effects
    Theme.setFont("small")
    Theme.setColor("text")

    local typeText = selectedSkill.type and string.format("Type: %s", selectedSkill.type) or "Type: Unknown"
    love.graphics.print(typeText, detailX, detailY)

    if selectedSkill.description then
        love.graphics.print(selectedSkill.description, detailX, detailY + 15)
    elseif selectedSkill.id then
        love.graphics.print(string.format("ID: %s", selectedSkill.id), detailX, detailY + 15)
    else
        love.graphics.print("No description available", detailX, detailY + 15)
    end
end

--[[
    Handle mouse input
    @param x number - Mouse X position
    @param y number - Mouse Y position
    @param button number - Mouse button
]]
function SkillSelection:mousepressed(x, y, button)
    -- Check if click is outside the widget (cancel)
    if not self:containsPoint(x, y) then
        self:cancel()
        return true
    end

    -- Let buttons handle their own clicks
    for _, btn in ipairs(self.skillButtons) do
        if btn:mousepressed(x, y, button) then
            return true
        end
    end

    return false
end

return SkillSelection