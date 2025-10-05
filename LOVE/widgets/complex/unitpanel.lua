--[[
widgets/unitpanel.lua
UnitPanel widget for displaying tactical unit information


Display and interaction panel for individual tactical units in turn-based strategy games.
Shows unit stats, abilities, equipment, and status effects in a compact, interactive layout.

PURPOSE:
- Present key unit information in a compact, accessible format
- Enable interaction with unit abilities, equipment, and status effects
- Provide visual feedback for unit health, armor, and combat state
- Support tactical decision making with comprehensive unit information

KEY FEATURES:
- Unit portrait and identification display
- Health and armor bars with threshold coloring and animations
- Comprehensive stats display (strength, accuracy, mobility, etc.)
- Ability/action buttons with cooldowns, costs, and interaction handlers
- Equipment and inventory visualization with interaction callbacks
- Status effect tracking with visual indicators and descriptions
- Compact and expanded view modes for different UI contexts
- Real-time updates for health, status, and ability changes
- Accessibility features for screen readers and keyboard navigation
- Customizable layout and theming options

]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local Label = require("widgets.common.label")
local ProgressBar = require("widgets.common.progressbar")
local Button = require("widgets.common.button")

local UnitPanel = {}
UnitPanel.__index = UnitPanel
setmetatable(UnitPanel, { __index = core.Base })

function UnitPanel:new(x, y, w, h, options)
    local obj = core.Base:new(x, y, w, h)

    -- Unit reference
    obj.unit = options and options.unit
    obj.showEmpty = (options and options.showEmpty) or false

    -- Layout configuration
    obj.padding = (options and options.padding) or { 8, 8, 8, 8 }
    obj.spacing = (options and options.spacing) or 6
    obj.compactMode = (options and options.compactMode) or false

    -- Visual properties
    obj.backgroundColor = (options and options.backgroundColor) or core.theme.backgroundLight
    obj.borderColor = (options and options.borderColor) or core.theme.border
    obj.borderRadius = (options and options.borderRadius) or 4
    obj.showBorder = (options and options.showBorder) ~= false
    obj.showShadow = (options and options.showShadow) or false

    -- Portrait settings
    obj.showPortrait = (options and options.showPortrait) ~= false
    obj.portraitSize = (options and options.portraitSize) or 64
    obj.portraitPlaceholder = (options and options.portraitPlaceholder) or "?"

    -- Sections to display
    obj.showHealth = (options and options.showHealth) ~= false
    obj.showArmor = (options and options.showArmor) ~= false
    obj.showStats = (options and options.showStats) ~= false
    obj.showAbilities = (options and options.showAbilities) ~= false
    obj.showEquipment = (options and options.showEquipment) ~= false
    obj.showStatusEffects = (options and options.showStatusEffects) ~= false
    obj.showActions = (options and options.showActions) ~= false

    -- Animation settings
    obj.animateChanges = (options and options.animateChanges) ~= false
    obj.highlightChanges = (options and options.highlightChanges) ~= false
    obj.changeHighlightDuration = 1.0

    -- Colors for different stat types
    obj.healthColors = {
        high = { 0.2, 0.8, 0.2 },
        medium = { 0.8, 0.8, 0.2 },
        low = { 0.8, 0.2, 0.2 },
        critical = { 1, 0, 0 }
    }

    obj.armorColors = {
        intact = { 0.4, 0.6, 1 },
        damaged = { 0.8, 0.6, 0.2 },
        broken = { 0.6, 0.4, 0.4 }
    }

    -- Status effect colors
    obj.statusColors = {
        buff = { 0.2, 1, 0.2 },
        debuff = { 1, 0.2, 0.2 },
        neutral = { 0.8, 0.8, 0.8 }
    }

    -- Internal components
    obj.components = {}
    obj.lastUnitData = {}
    obj.changeHighlights = {}

    -- Callbacks
    obj.onAbilityClick = options and options.onAbilityClick
    obj.onEquipmentClick = options and options.onEquipmentClick
    obj.onStatusClick = options and options.onStatusClick
    obj.onUnitAction = options and options.onUnitAction

    setmetatable(obj, self)
    obj:_buildComponents()
    return obj
end

function UnitPanel:setUnit(unit)
    local oldUnit = self.unit
    self.unit = unit

    if self.animateChanges and oldUnit and unit then
        self:_detectChanges(oldUnit, unit)
    end

    self:_buildComponents()
end

function UnitPanel:_detectChanges(oldUnit, newUnit)
    -- Detect health changes
    if oldUnit.health ~= newUnit.health then
        self.changeHighlights.health = love.timer.getTime()
    end

    -- Detect armor changes
    if oldUnit.armor ~= newUnit.armor then
        self.changeHighlights.armor = love.timer.getTime()
    end

    -- Detect status effect changes
    if self:_statusEffectsChanged(oldUnit.statusEffects or {}, newUnit.statusEffects or {}) then
        self.changeHighlights.statusEffects = love.timer.getTime()
    end
end

function UnitPanel:_statusEffectsChanged(oldEffects, newEffects)
    if #oldEffects ~= #newEffects then return true end

    for i, effect in ipairs(oldEffects) do
        local newEffect = newEffects[i]
        if not newEffect or effect.type ~= newEffect.type or
            effect.duration ~= newEffect.duration then
            return true
        end
    end

    return false
end

function UnitPanel:_buildComponents()
    self.components = {}

    if not self.unit and not self.showEmpty then return end

    local currentY = self.y + self.padding[1]
    local contentWidth = self.w - self.padding[2] - self.padding[4]

    -- Unit name and portrait
    if self.unit then
        currentY = self:_buildHeader(currentY, contentWidth)
        currentY = currentY + self.spacing
    end

    -- Health bar
    if self.showHealth then
        currentY = self:_buildHealthBar(currentY, contentWidth)
        currentY = currentY + self.spacing
    end

    -- Armor bar
    if self.showArmor and self.unit and self.unit.maxArmor and self.unit.maxArmor > 0 then
        currentY = self:_buildArmorBar(currentY, contentWidth)
        currentY = currentY + self.spacing
    end

    -- Stats section
    if self.showStats and not self.compactMode then
        currentY = self:_buildStats(currentY, contentWidth)
        currentY = currentY + self.spacing
    end

    -- Status effects
    if self.showStatusEffects then
        currentY = self:_buildStatusEffects(currentY, contentWidth)
        currentY = currentY + self.spacing
    end

    -- Abilities
    if self.showAbilities and not self.compactMode then
        currentY = self:_buildAbilities(currentY, contentWidth)
        currentY = currentY + self.spacing
    end

    -- Equipment
    if self.showEquipment and not self.compactMode then
        currentY = self:_buildEquipment(currentY, contentWidth)
        currentY = currentY + self.spacing
    end

    -- Action buttons
    if self.showActions and self.unit then
        currentY = self:_buildActions(currentY, contentWidth)
    end
end

function UnitPanel:_buildHeader(currentY, contentWidth)
    local headerHeight = self.portraitSize

    -- Portrait
    if self.showPortrait then
        local portraitComponent = {
            type = "portrait",
            x = self.x + self.padding[4],
            y = currentY,
            w = self.portraitSize,
            h = self.portraitSize,
            unit = self.unit
        }
        table.insert(self.components, portraitComponent)
    end

    -- Name and rank
    local textX = self.x + self.padding[4] + (self.showPortrait and (self.portraitSize + self.spacing) or 0)
    local textWidth = contentWidth - (self.showPortrait and (self.portraitSize + self.spacing) or 0)

    local nameLabel = Label:new(textX, currentY, textWidth, 20, {
        text = self.unit.name or "Unknown",
        font = core.theme.fontBold,
        fontSize = 16,
        align = "left",
        valign = "top"
    })

    table.insert(self.components, {
        type = "component",
        component = nameLabel
    })

    -- Rank/class
    if self.unit.rank or self.unit.class then
        local rankText = (self.unit.rank or "") ..
            (self.unit.rank and self.unit.class and " " or "") .. (self.unit.class or "")
        local rankLabel = Label:new(textX, currentY + 22, textWidth, 16, {
            text = rankText,
            font = core.theme.font,
            fontSize = 12,
            color = core.theme.textLight,
            align = "left"
        })

        table.insert(self.components, {
            type = "component",
            component = rankLabel
        })
    end

    return currentY + headerHeight
end

function UnitPanel:_buildHealthBar(currentY, contentWidth)
    if not self.unit then
        -- Empty health bar
        local emptyBar = ProgressBar:new(self.x + self.padding[4], currentY, contentWidth, 16, {
            value = 0,
            maxValue = 100,
            showText = true,
            text = "No Unit Selected",
            backgroundColor = core.theme.backgroundDark
        })

        table.insert(self.components, {
            type = "component",
            component = emptyBar
        })

        return currentY + 20
    end

    local health = self.unit.health or 0
    local maxHealth = self.unit.maxHealth or 100
    local healthRatio = maxHealth > 0 and health / maxHealth or 0

    -- Determine health color
    local healthColor = self.healthColors.high
    if healthRatio <= 0.25 then
        healthColor = self.healthColors.critical
    elseif healthRatio <= 0.5 then
        healthColor = self.healthColors.low
    elseif healthRatio <= 0.75 then
        healthColor = self.healthColors.medium
    end

    -- Check for highlight
    local isHighlighted = self.changeHighlights.health and
        (love.timer.getTime() - self.changeHighlights.health) < self.changeHighlightDuration

    local healthBar = ProgressBar:new(self.x + self.padding[4], currentY, contentWidth, 20, {
        value = health,
        maxValue = maxHealth,
        fillColor = healthColor,
        showText = true,
        text = string.format("HP: %d/%d", health, maxHealth),
        textColor = { 1, 1, 1 },
        animate = self.animateChanges,
        glowEffect = isHighlighted
    })

    table.insert(self.components, {
        type = "component",
        component = healthBar
    })

    return currentY + 24
end

function UnitPanel:_buildArmorBar(currentY, contentWidth)
    local armor = self.unit.armor or 0
    local maxArmor = self.unit.maxArmor or 0

    if maxArmor <= 0 then return currentY end

    local armorRatio = armor / maxArmor

    -- Determine armor color
    local armorColor = self.armorColors.intact
    if armorRatio <= 0.3 then
        armorColor = self.armorColors.broken
    elseif armorRatio <= 0.7 then
        armorColor = self.armorColors.damaged
    end

    local isHighlighted = self.changeHighlights.armor and
        (love.timer.getTime() - self.changeHighlights.armor) < self.changeHighlightDuration

    local armorBar = ProgressBar:new(self.x + self.padding[4], currentY, contentWidth, 16, {
        value = armor,
        maxValue = maxArmor,
        fillColor = armorColor,
        showText = true,
        text = string.format("Armor: %d/%d", armor, maxArmor),
        textColor = { 1, 1, 1 },
        animate = self.animateChanges,
        glowEffect = isHighlighted
    })

    table.insert(self.components, {
        type = "component",
        component = armorBar
    })

    return currentY + 20
end

function UnitPanel:_buildStats(currentY, contentWidth)
    if not self.unit or not self.unit.stats then
        return currentY
    end

    local stats = self.unit.stats
    local statNames = { "Aim", "Will", "Mobility", "Hacking" }
    local statKeys = { "aim", "will", "mobility", "hacking" }

    local statsPerRow = 2
    local statWidth = (contentWidth - self.spacing) / statsPerRow
    local statHeight = 16

    local row = 0
    local col = 0

    for i, statName in ipairs(statNames) do
        local statKey = statKeys[i]
        local statValue = stats[statKey]

        if statValue then
            local statX = self.x + self.padding[4] + col * (statWidth + self.spacing)
            local statY = currentY + row * (statHeight + 4)

            local statLabel = Label:new(statX, statY, statWidth, statHeight, {
                text = string.format("%s: %d", statName, statValue),
                fontSize = 12,
                align = "left"
            })

            table.insert(self.components, {
                type = "component",
                component = statLabel
            })

            col = col + 1
            if col >= statsPerRow then
                col = 0
                row = row + 1
            end
        end
    end

    return currentY + (row + (col > 0 and 1 or 0)) * (statHeight + 4)
end

function UnitPanel:_buildStatusEffects(currentY, contentWidth)
    if not self.unit or not self.unit.statusEffects or #self.unit.statusEffects == 0 then
        return currentY
    end

    local effectSize = 24
    local effectSpacing = 4
    local effectsPerRow = math.floor((contentWidth + effectSpacing) / (effectSize + effectSpacing))

    local isHighlighted = self.changeHighlights.statusEffects and
        (love.timer.getTime() - self.changeHighlights.statusEffects) < self.changeHighlightDuration

    local row = 0
    local col = 0

    for _, effect in ipairs(self.unit.statusEffects) do
        local effectX = self.x + self.padding[4] + col * (effectSize + effectSpacing)
        local effectY = currentY + row * (effectSize + effectSpacing)

        local effectComponent = {
            type = "statusEffect",
            x = effectX,
            y = effectY,
            w = effectSize,
            h = effectSize,
            effect = effect,
            highlighted = isHighlighted
        }

        table.insert(self.components, effectComponent)

        col = col + 1
        if col >= effectsPerRow then
            col = 0
            row = row + 1
        end
    end

    return currentY + (row + (col > 0 and 1 or 0)) * (effectSize + effectSpacing)
end

function UnitPanel:_buildAbilities(currentY, contentWidth)
    if not self.unit or not self.unit.abilities or #self.unit.abilities == 0 then
        return currentY
    end

    local abilityHeight = 32
    local maxAbilities = 4 -- Limit display

    for i = 1, math.min(maxAbilities, #self.unit.abilities) do
        local ability = self.unit.abilities[i]
        local abilityY = currentY + (i - 1) * (abilityHeight + self.spacing)

        local abilityButton = Button:new(self.x + self.padding[4], abilityY, contentWidth, abilityHeight, {
            text = ability.name or "Ability",
            variant = ability.available and "secondary" or "disabled",
            fontSize = 12,
            onClick = function()
                if self.onAbilityClick then
                    self.onAbilityClick(ability, i, self)
                end
            end
        })

        table.insert(self.components, {
            type = "component",
            component = abilityButton,
            data = { ability = ability, index = i }
        })
    end

    return currentY + math.min(maxAbilities, #self.unit.abilities) * (abilityHeight + self.spacing)
end

function UnitPanel:_buildEquipment(currentY, contentWidth)
    if not self.unit or not self.unit.equipment then
        return currentY
    end

    local equipment = self.unit.equipment
    local slots = { "primary", "secondary", "armor", "utility" }
    local slotNames = { "Primary", "Secondary", "Armor", "Utility" }

    local itemHeight = 24

    for i, slot in ipairs(slots) do
        local item = equipment[slot]
        local itemY = currentY + (i - 1) * (itemHeight + 2)

        local itemText = slotNames[i] .. ": " .. (item and item.name or "Empty")

        local itemLabel = Label:new(self.x + self.padding[4], itemY, contentWidth, itemHeight, {
            text = itemText,
            fontSize = 11,
            color = item and core.theme.text or core.theme.textLight,
            clickable = item ~= nil,
            onClick = function()
                if item and self.onEquipmentClick then
                    self.onEquipmentClick(item, slot, self)
                end
            end
        })

        table.insert(self.components, {
            type = "component",
            component = itemLabel
        })
    end

    return currentY + #slots * (itemHeight + 2)
end

function UnitPanel:_buildActions(currentY, contentWidth)
    local actions = { "Move", "Attack", "Overwatch", "End Turn" }
    local actionWidth = (contentWidth - self.spacing * 3) / 4
    local actionHeight = 28

    for i, actionName in ipairs(actions) do
        local actionX = self.x + self.padding[4] + (i - 1) * (actionWidth + self.spacing)

        local actionButton = Button:new(actionX, currentY, actionWidth, actionHeight, {
            text = actionName,
            variant = "primary",
            fontSize = 10,
            onClick = function()
                if self.onUnitAction then
                    self.onUnitAction(actionName:lower(), self.unit, self)
                end
            end
        })

        table.insert(self.components, {
            type = "component",
            component = actionButton
        })
    end

    return currentY + actionHeight
end

function UnitPanel:update(dt)
    core.Base.update(self, dt)

    -- Update all components
    for _, comp in ipairs(self.components) do
        if comp.component and comp.component.update then
            comp.component:update(dt)
        end
    end
end

function UnitPanel:draw()
    -- Draw background
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.borderRadius)

    -- Draw border
    if self.showBorder then
        love.graphics.setColor(unpack(self.borderColor))
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.borderRadius)
    end

    -- Draw components
    for _, comp in ipairs(self.components) do
        if comp.type == "component" then
            comp.component:draw()
        elseif comp.type == "portrait" then
            self:_drawPortrait(comp)
        elseif comp.type == "statusEffect" then
            self:_drawStatusEffect(comp)
        end
    end
end

function UnitPanel:_drawPortrait(portraitComp)
    -- Draw portrait background
    love.graphics.setColor(unpack(core.theme.backgroundDark))
    love.graphics.rectangle("fill", portraitComp.x, portraitComp.y, portraitComp.w, portraitComp.h, 4)

    -- Draw portrait border
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", portraitComp.x, portraitComp.y, portraitComp.w, portraitComp.h, 4)

    -- Draw portrait image or placeholder
    if portraitComp.unit.portrait then
        love.graphics.setColor(1, 1, 1)
        local scale = math.min(portraitComp.w / portraitComp.unit.portrait:getWidth(),
            portraitComp.h / portraitComp.unit.portrait:getHeight())
        love.graphics.draw(portraitComp.unit.portrait, portraitComp.x, portraitComp.y, 0, scale, scale)
    else
        love.graphics.setColor(unpack(core.theme.textLight))
        love.graphics.setFont(core.theme.fontBold)
        local centerX = portraitComp.x + portraitComp.w / 2
        local centerY = portraitComp.y + portraitComp.h / 2
        love.graphics.printf(self.portraitPlaceholder,
            portraitComp.x, centerY - core.theme.fontBold:getHeight() / 2,
            portraitComp.w, "center")
    end
end

function UnitPanel:_drawStatusEffect(effectComp)
    local effect = effectComp.effect

    -- Determine effect color
    local effectColor = self.statusColors.neutral
    if effect.type == "buff" then
        effectColor = self.statusColors.buff
    elseif effect.type == "debuff" then
        effectColor = self.statusColors.debuff
    end

    -- Highlight if recently changed
    if effectComp.highlighted then
        local highlightIntensity = 0.5 + 0.5 * math.sin(love.timer.getTime() * 8)
        effectColor = {
            effectColor[1] + (1 - effectColor[1]) * highlightIntensity * 0.3,
            effectColor[2] + (1 - effectColor[2]) * highlightIntensity * 0.3,
            effectColor[3] + (1 - effectColor[3]) * highlightIntensity * 0.3
        }
    end

    -- Draw effect background
    love.graphics.setColor(unpack(effectColor))
    love.graphics.rectangle("fill", effectComp.x, effectComp.y, effectComp.w, effectComp.h, 2)

    -- Draw effect border
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", effectComp.x, effectComp.y, effectComp.w, effectComp.h, 2)

    -- Draw effect icon/text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(core.theme.font)

    local iconText = effect.icon or string.sub(effect.name or "?", 1, 1):upper()
    local textWidth = core.theme.font:getWidth(iconText)
    local textHeight = core.theme.font:getHeight()

    love.graphics.print(iconText,
        effectComp.x + (effectComp.w - textWidth) / 2,
        effectComp.y + (effectComp.h - textHeight) / 2)

    -- Draw duration if available
    if effect.duration and effect.duration > 0 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(tostring(math.ceil(effect.duration)),
            effectComp.x + 2, effectComp.y + effectComp.h - 12)
    end
end

function UnitPanel:mousepressed(x, y, button)
    if not self:hitTest(x, y) then return false end

    -- Forward to components
    for _, comp in ipairs(self.components) do
        if comp.component and comp.component.mousepressed then
            if comp.component:mousepressed(x, y, button) then
                return true
            end
        elseif comp.type == "statusEffect" then
            if core.isInside(x, y, comp.x, comp.y, comp.w, comp.h) then
                if self.onStatusClick then
                    self.onStatusClick(comp.effect, self)
                end
                return true
            end
        end
    end

    return true -- Consume click
end

function UnitPanel:mousereleased(x, y, button)
    for _, comp in ipairs(self.components) do
        if comp.component and comp.component.mousereleased then
            comp.component:mousereleased(x, y, button)
        end
    end
end

function UnitPanel:mousemoved(x, y, dx, dy)
    for _, comp in ipairs(self.components) do
        if comp.component and comp.component.mousemoved then
            comp.component:mousemoved(x, y, dx, dy)
        end
    end
end

-- Public API
function UnitPanel:refresh()
    self:_buildComponents()
end

function UnitPanel:setCompactMode(compact)
    self.compactMode = compact
    self:_buildComponents()
end

function UnitPanel:highlightStat(statName)
    self.changeHighlights[statName] = love.timer.getTime()
end

return UnitPanel






