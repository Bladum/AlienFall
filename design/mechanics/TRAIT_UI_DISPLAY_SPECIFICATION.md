# Trait UI Display Specification

> **Status**: Implementation Specification
> **Last Updated**: 2025-10-31
> **Related Systems**: TRAIT_SYSTEM_SPECIFICATION.md, Unit cards, Squad management
> **Purpose**: Define how traits are displayed and managed in the user interface

## Overview

The trait UI system provides visual representation of unit traits across different screens. Traits are displayed with appropriate icons, colors, and tooltips to communicate their effects clearly to players.

**Key UI Elements**:
- Unit trait badges on unit cards
- Detailed trait tooltips
- Trait management screens
- Achievement progress displays

---

## 1. Trait Visual Design

### Trait Icons

Each trait has a distinctive icon for quick recognition:

**Combat Traits**:
- Quick Reflexes: ⚡ (lightning bolt)
- Sharp Eyes: 👁️ (eye)
- Steady Hand: 🎯 (target)
- Marksman: 🏹 (bow and arrow)
- Close Combat Expert: ⚔️ (crossed swords)

**Physical Traits**:
- Strong Build: 💪 (flexed bicep)
- Marathon Runner: 🏃 (running person)
- Heavy Build: 🛡️ (shield)
- Superhuman Strength: 🦸 (superhero)

**Mental Traits**:
- Iron Will: 🧠 (brain)
- Calm Under Pressure: 😌 (calm face)
- Natural Leader: 👑 (crown)
- Battle Hardened: 🛡️ (shield)
- Commanding Officer: 🎖️ (medal)

**Support Traits**:
- Natural Medic: ⚕️ (medical cross)
- Healer: 🩹 (bandage)
- Field Engineer: 🔧 (wrench)
- Resourceful: 🎒 (backpack)

**Negative Traits**:
- Weak Lungs: 😷 (medical mask)
- Poor Vision: 👓 (glasses)
- Clumsy: 🤕 (head bandage)
- Hemophobic: 🩸 (blood drop)

### Trait Colors

Traits use color coding for quick identification:

```
Positive Traits:  🟢 Green (#00AA00)
Negative Traits:  🔴 Red (#AA0000)
Neutral Traits:   🔵 Blue (#0000AA)
Rare/Legendary:   🟣 Purple (#AA00AA)
```

### Trait Layout

**Trait Badge Structure**:
```
┌─────────────────┐
│ Icon │ Name     │
│  ⚡  │ Quick    │
│      │ Reflexes │
└─────────────────┘
     +2 Reaction
```

---

## 2. Unit Card Display

### Basic Unit Card

**Layout**:
```
┌─────────────────────────────────────┐
│ John Smith                 Rank: 3  │
│ ┌───┐ ┌───┐ ┌───┐                   │
│ │⚡ │ │🏹 │ │😷 │  Traits (3/3)     │
│ │+2│ │+1│ │-1│                   │
│ └───┘ └───┘ └───┘                   │
│ Health: 100/100   XP: 1250/1500    │
│ Aim: 68  Melee: 62  Reaction: 57   │
└─────────────────────────────────────┘
```

**Trait Badge Details**:
- 24×24 pixel icons
- Small +/- value indicators
- Hover for tooltips
- Click to open trait management

### Expanded Unit Card

**Full Details View**:
```
┌─────────────────────────────────────┐
│ John Smith - Veteran Sniper         │
│ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐       │
│ │⚡ │ │🏹 │ │😷 │ │🎯│ │🧠 │       │
│ │+2│ │+1│ │-1│ │+1│ │+2│       │
│ └───┘ └───┘ └───┘ └───┘ └───┘       │
│                                     │
│ Traits:                             │
│ ⬆️ Quick Reflexes (+2 Reaction)     │
│ ⬆️ Marksman (+1 Aim, +1 Acc)        │
│ ⬇️ Weak Lungs (-1 Sanity)           │
│ ⬆️ Steady Hand (+5% accuracy)       │
│ ⬆️ Iron Will (+2 Bravery)           │
│                                     │
│ Synergy Effects:                    │
│ • +3% accuracy (Marksman+Steady)    │
│                                     │
└─────────────────────────────────────┘
```

---

## 3. Trait Tooltips

### Basic Tooltip

**On Hover**:
```
Quick Reflexes
+2 Reaction stat

Faster turn order in combat
Better dodge chance
```

### Advanced Tooltip

**Detailed Information**:
```
Quick Reflexes
═══════════════════════════════════════════
Type: Positive Combat Trait
Source: Birth trait
Balance Cost: +2

Effects:
• +2 Reaction (faster initiative)
• +10% dodge chance
• +5% reaction fire accuracy

Conflicts: Slow Reflexes
Synergies: Steady Hand (+3% accuracy)
```

### Achievement Tooltip

**For Earnable Traits**:
```
Marksman
═══════════════════════════════════════════
Type: Positive Combat Trait
Source: Achievement
Progress: 15/20 rifle kills

Effects:
• +1 Aim stat
• +1 weapon accuracy
• Unlocks precision shooting perks

Requirements:
• Kill 20 enemies with rifle
• Rank 3 minimum
```

---

## 4. Trait Management Screen

### Respec Interface

**Layout**:
```
Trait Management - John Smith
═══════════════════════════════════════════

Current Traits:
┌───┐ Quick Reflexes (Birth) - Cannot remove
│⚡ │ +2 Reaction
└───┘

┌───┐ Marksman (Achievement) - 100,000 XP to remove
│🏹 │ +1 Aim, +1 Weapon Acc
└───┘ [Remove] [Info]

┌───┐ Weak Lungs (Birth) - Cannot remove
│😷 │ -1 Sanity
└───┘

Available Slots: 0/3 (Rank 5 allows 3 traits)

XP Available: 50,000
Respec Cost: 100,000 XP

[Cancel] [Confirm Respec]
```

### Perk Selection Screen

**Late Game Perks**:
```
Perk Selection - John Smith (Rank 8)
═══════════════════════════════════════════

Choose one legendary perk:

┌───┐ Superhuman Strength
│🦸 │ +3 STR permanently
│   │ Requires: STR 15
└───┘ [Select]

┌───┐ Commanding Officer
│🎖️ │ +2 nearby morale
│   │ Requires: 50 missions
└───┘ [Select]

┌───┐ Battle Hardened
│🛡️ │ Immune to suppression
│   │ Requires: 100 missions
└───┘ [Select]

Current XP: 750,000
[Cancel]
```

---

## 5. Achievement Progress Display

### Achievement Tracker

**In-Game Display**:
```
Recent Achievements
═══════════════════════════════════════════

🏆 Marksman Unlocked!
Kill 20 enemies with rifle
Reward: +1 Aim, +1 weapon accuracy

Progress Toward Next Achievement:
• Sharpshooter: 3/5 headshot kills ███░ 60%
• Close Combat Expert: 12/15 melee kills ████████░ 80%
```

### Achievement Screen

**Full Achievement List**:
```
Achievements - Combat
═══════════════════════════════════════════

✅ Rifleman (Completed)
   Kill 20 enemies with rifle
   Reward: Marksman trait

🔄 Sharpshooter (In Progress)
   Get 5 headshot kills
   Progress: 3/5 ███░ 60%
   Reward: Deadly Aim trait

❓ War Hero (Hidden)
   Achieve 1000 total kills
   Progress: 847/1000 ████████░ 85%
```

---

## 6. Squad Overview Display

### Squad Trait Summary

**Battle Prep Screen**:
```
Squad Composition - Alpha Team
═══════════════════════════════════════════

Active Trait Effects:
• Natural Leader: +1 squad morale (Sarah Chen)
• Battle Hardened: Immune to suppression (Mike Johnson, David Lee)
• Marksman: +1 accuracy for rifle units (John Smith, Emma Davis)
• Marathon Runner: +2 movement speed (Lisa Wong)

Synergy Bonuses:
• +3% accuracy (Marksman + Steady Hand)
• +1 healing per bandage (Natural Medic + Healer)
• +2 nearby morale (Leader + Commanding Officer)
```

### Trait Filter Options

**Unit Selection Filters**:
```
Filter Units By Trait:
[ ] Has Natural Leader
[ ] Battle Hardened
[ ] Marksman
[ ] Healer
[ ] Field Engineer

Sort By: [Name] [Rank] [Trait Count] [Balance Cost]
```

---

## 7. UI Implementation Code

### Trait Badge Component

```lua
---@class TraitBadge
---@field trait table Trait definition
---@field x number X position
---@field y number Y position
---@field size number Badge size (24 default)
local TraitBadge = {}

function TraitBadge:new(trait, x, y, size)
    local self = setmetatable({}, {__index = TraitBadge})
    self.trait = trait
    self.x = x
    self.y = y
    self.size = size or 24
    return self
end

function TraitBadge:draw()
    -- Draw background circle
    local color = self:getTraitColor()
    love.graphics.setColor(color.r, color.g, color.b, 0.8)
    love.graphics.circle("fill", self.x + self.size/2, self.y + self.size/2, self.size/2)

    -- Draw icon
    love.graphics.setColor(1, 1, 1)
    local icon = self:getTraitIcon()
    love.graphics.print(icon, self.x + 4, self.y + 2)

    -- Draw balance indicator
    if self.trait.balance_cost > 0 then
        love.graphics.setColor(0, 0.8, 0)  -- Green for positive
        love.graphics.print("+" .. self.trait.balance_cost, self.x + 2, self.y + self.size - 12)
    elseif self.trait.balance_cost < 0 then
        love.graphics.setColor(0.8, 0, 0)  -- Red for negative
        love.graphics.print(self.trait.balance_cost, self.x + 2, self.y + self.size - 12)
    end
end

function TraitBadge:getTraitColor()
    if self.trait.type == "positive" then
        return {r = 0, g = 0.7, b = 0}  -- Green
    elseif self.trait.type == "negative" then
        return {r = 0.7, g = 0, b = 0}  -- Red
    else
        return {r = 0, g = 0, b = 0.7}  -- Blue
    end
end

function TraitBadge:getTraitIcon()
    local icons = {
        quick_reflexes = "⚡",
        sharp_eyes = "👁️",
        steady_hand = "🎯",
        marksman = "🏹",
        strong_build = "💪",
        marathon_runner = "🏃",
        iron_will = "🧠",
        natural_medic = "⚕️",
        weak_lungs = "😷",
        poor_vision = "👓",
        -- Add more icons...
    }
    return icons[self.trait.id] or "❓"
end

function TraitBadge:isHovered(mouseX, mouseY)
    local dx = mouseX - (self.x + self.size/2)
    local dy = mouseY - (self.y + self.size/2)
    return math.sqrt(dx*dx + dy*dy) <= self.size/2
end
```

### Trait Tooltip Component

```lua
---@class TraitTooltip
---@field trait table Trait definition
---@field x number X position
---@field y number Y position
---@field width number Tooltip width
---@field height number Tooltip height
local TraitTooltip = {}

function TraitTooltip:new(trait, x, y)
    local self = setmetatable({}, {__index = TraitTooltip})
    self.trait = trait
    self.x = x
    self.y = y
    self.width = 300
    self.height = 150
    return self
end

function TraitTooltip:draw()
    -- Draw background
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Draw title
    love.graphics.setColor(1, 1, 0)
    love.graphics.print(self.trait.name, self.x + 10, self.y + 10)

    -- Draw type and category
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print(self.trait.type .. " " .. self.trait.category .. " trait",
        self.x + 10, self.y + 30)

    -- Draw description
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.trait.description, self.x + 10, self.y + 50,
        self.width - 20, "left")

    -- Draw balance cost
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Balance Cost: " .. self.trait.balance_cost,
        self.x + 10, self.y + self.height - 30)

    -- Draw acquisition method
    love.graphics.print("Source: " .. self.trait.acquisition,
        self.x + 10, self.y + self.height - 15)
end
```

### Unit Card with Traits

```lua
---@class UnitCard
---@field unit table Unit data
---@field x number X position
---@field y number Y position
---@field width number Card width
---@field height number Card height
---@field traitBadges table Array of TraitBadge objects
local UnitCard = {}

function UnitCard:new(unit, x, y, width, height)
    local self = setmetatable({}, {__index = UnitCard})
    self.unit = unit
    self.x = x
    self.y = y
    self.width = width or 400
    self.height = height or 200
    self.traitBadges = {}
    self:createTraitBadges()
    return self
end

function UnitCard:createTraitBadges()
    local badgeSize = 24
    local badgeSpacing = 4
    local startX = self.x + 10
    local startY = self.y + 40

    for i, trait in ipairs(self.unit.traits or {}) do
        local badgeX = startX + (i-1) * (badgeSize + badgeSpacing)
        local badgeY = startY
        table.insert(self.traitBadges, TraitBadge:new(trait, badgeX, badgeY, badgeSize))
    end
end

function UnitCard:draw()
    -- Draw card background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw card border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Draw unit name and rank
    love.graphics.setColor(1, 1, 0)
    love.graphics.print(self.unit.name, self.x + 10, self.y + 10)
    love.graphics.print("Rank: " .. (self.unit.rank or 0), self.x + self.width - 60, self.y + 10)

    -- Draw trait badges
    for _, badge in ipairs(self.traitBadges) do
        badge:draw()
    end

    -- Draw trait count
    local traitCount = #(self.unit.traits or {})
    local maxTraits = 5  -- Would be calculated based on rank
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print(string.format("Traits: %d/%d", traitCount, maxTraits),
        self.x + 10, self.y + 70)

    -- Draw stats
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("Health: %d/%d", self.unit.health, self.unit.maxHealth),
        self.x + 10, self.y + 90)
    love.graphics.print(string.format("Aim: %d, Reaction: %d", self.unit.stats.aim, self.unit.stats.reaction),
        self.x + 10, self.y + 110)
end

function UnitCard:getHoveredTrait(mouseX, mouseY)
    for _, badge in ipairs(self.traitBadges) do
        if badge:isHovered(mouseX, mouseY) then
            return badge.trait
        end
    end
    return nil
end
```

---

## 8. Mobile/Responsive Considerations

### Small Screen Layout

**Compact Unit Card**:
```
John Smith R3
⚡+2 🏹+1 😷-1
HP:100 Aim:68
```

### Touch Interface

**Touch Targets**:
- Trait badges: 32×32 pixels minimum
- Tooltip display on tap-and-hold
- Swipe gestures for trait management

---

## 9. Accessibility Features

### Screen Reader Support

**Trait Descriptions**:
- "Trait: Quick Reflexes, positive combat trait, plus two reaction, birth trait"
- "Trait: Marksman, positive combat trait, plus one aim plus one weapon accuracy, achievement trait"

### High Contrast Mode

**Enhanced Colors**:
- Positive: Bright green (#00FF00)
- Negative: Bright red (#FF0000)
- Neutral: Bright blue (#0000FF)

### Keyboard Navigation

**Trait Management**:
- Tab to cycle through traits
- Enter to view details
- Space to select/remove
- Arrow keys to navigate options

---

## 10. Implementation Checklist

- [ ] Create TraitBadge component
- [ ] Create TraitTooltip component
- [ ] Create UnitCard component with trait display
- [ ] Implement achievement progress UI
- [ ] Add trait management screens
- [ ] Integrate with existing unit selection UI
- [ ] Add accessibility features
- [ ] Test on different screen sizes
- [ ] Get UI/UX review

---

**Version**: 1.0
**Status**: Complete Specification
**Last Reviewed**: 2025-10-31</content>
<parameter name="filePath">c:\Users\tombl\Documents\Projects\design\mechanics\TRAIT_UI_DISPLAY_SPECIFICATION.md
