--- Equipment System
--- Manages armor and skill definitions and validation.
---
--- This module provides functions for equipment management including
--- armor and skill validation, compatibility checking, and stat calculations.
--- It works with the DataLoader to access equipment definitions.
---
--- Example usage:
---   local EquipmentSystem = require("battlescape.combat.equipment_system")
---   if EquipmentSystem.canEquipSkill(unit, "marksman") then
---       EquipmentSystem.equipSkill(unit, "marksman")
---   end

local DataLoader = require("core.data.data_loader")

local EquipmentSystem = {}

--- Check if a unit can equip specific armor.
---
--- Validates armor exists and is compatible with unit class.
---
--- @param unit table Unit entity
--- @param armorId string Armor identifier
--- @return boolean True if armor can be equipped
--- @return string|nil Error message if cannot equip
function EquipmentSystem.canEquipArmor(unit, armorId)
    -- Check if armor exists
    local armor = DataLoader.armours.get(armorId)
    if not armor then
        return false, "Armor not found: " .. armorId
    end

    -- For now, all armor is compatible with all classes
    -- This can be extended with class-specific restrictions
    return true, nil
end

--- Equip armor on a unit.
---
--- @param unit table Unit entity
--- @param armorId string Armor identifier
--- @return boolean True if armor was equipped successfully
function EquipmentSystem.equipArmor(unit, armorId)
    local canEquip, errorMsg = EquipmentSystem.canEquipArmor(unit, armorId)
    if not canEquip then
        print("[EquipmentSystem] ERROR: Cannot equip armor: " .. errorMsg)
        return false
    end

    unit.armour = armorId
    unit:updateStats()  -- Recalculate stats with new armor

    print(string.format("[EquipmentSystem] Equipped armor %s on %s", armorId, unit.name))
    return true
end

--- Check if a unit can equip a specific skill.
---
--- Validates skill exists and unit doesn't already have a skill equipped.
---
--- @param unit table Unit entity
--- @param skillId string Skill identifier
--- @return boolean True if skill can be equipped
--- @return string|nil Error message if cannot equip
function EquipmentSystem.canEquipSkill(unit, skillId)
    -- Check if skill exists
    local skill = DataLoader.skills.get(skillId)
    if not skill then
        return false, "Skill not found: " .. skillId
    end

    -- Check if unit already has a skill
    if unit.skill then
        return false, "Unit already has skill equipped: " .. unit.skill
    end

    -- For now, all skills are compatible with all classes
    -- This can be extended with class-specific restrictions
    return true, nil
end

--- Equip skill on a unit.
---
--- @param unit table Unit entity
--- @param skillId string Skill identifier
--- @return boolean True if skill was equipped successfully
function EquipmentSystem.equipSkill(unit, skillId)
    local canEquip, errorMsg = EquipmentSystem.canEquipSkill(unit, skillId)
    if not canEquip then
        print("[EquipmentSystem] ERROR: Cannot equip skill: " .. errorMsg)
        return false
    end

    unit.skill = skillId
    unit:updateStats()  -- Recalculate stats with new skill

    print(string.format("[EquipmentSystem] Equipped skill %s on %s", skillId, unit.name))
    return true
end

--- Unequip skill from a unit.
---
--- @param unit table Unit entity
--- @return boolean True if skill was unequipped successfully
function EquipmentSystem.unequipSkill(unit)
    if not unit.skill then
        return false
    end

    local oldSkill = unit.skill
    unit.skill = nil
    unit:updateStats()  -- Recalculate stats without skill

    print(string.format("[EquipmentSystem] Unequipped skill %s from %s", oldSkill, unit.name))
    return true
end

--- Get all available armor for a unit class.
---
--- Returns armor that can be equipped by the given unit class.
---
--- @param classId string Unit class identifier
--- @return table Array of armor IDs
function EquipmentSystem.getAvailableArmor(classId)
    return DataLoader.armours.getAllIds()
end

--- Get all available skills for a unit class.
---
--- Returns skills that can be equipped by the given unit class.
---
--- @param classId string Unit class identifier
--- @return table Array of skill IDs
function EquipmentSystem.getAvailableSkills(classId)
    return DataLoader.skills.getAllIds()
end

--- Check if armor is compatible with a unit class.
---
--- Currently all armor is compatible with all classes.
--- This can be extended with class-specific restrictions.
---
--- @param armorId string Armor identifier
--- @param classId string Unit class identifier
--- @return boolean True if compatible
function EquipmentSystem.isArmorCompatible(armorId, classId)
    -- For now, all armor is compatible with all classes
    -- This can be extended with armor restrictions per class
    local armor = DataLoader.armours.get(armorId)
    return armor ~= nil
end

--- Check if skill is compatible with a unit class.
---
--- Currently all skills are compatible with all classes.
--- This can be extended with class-specific restrictions.
---
--- @param skillId string Skill identifier
--- @param classId string Unit class identifier
--- @return boolean True if compatible
function EquipmentSystem.isSkillCompatible(skillId, classId)
    -- For now, all skills are compatible with all classes
    -- This can be extended with skill restrictions per class
    local skill = DataLoader.skills.get(skillId)
    return skill ~= nil
end

--- Get skill effects for a unit.
---
--- Returns the effects table for the unit's equipped skill.
---
--- @param unit table Unit entity
--- @return table|nil Effects table or nil if no skill equipped
function EquipmentSystem.getSkillEffects(unit)
    if not unit.skill then
        return nil
    end

    local skill = DataLoader.skills.get(unit.skill)
    return skill and skill.effects or nil
end

--- Check if unit has a specific skill effect.
---
--- @param unit table Unit entity
--- @param effectName string Effect name to check
--- @return boolean True if unit has the effect
function EquipmentSystem.hasSkillEffect(unit, effectName)
    local effects = EquipmentSystem.getSkillEffects(unit)
    return effects and effects[effectName] ~= nil or false
end

--- Get skill effect value.
---
--- @param unit table Unit entity
--- @param effectName string Effect name
--- @return any Effect value or nil if not found
function EquipmentSystem.getSkillEffectValue(unit, effectName)
    local effects = EquipmentSystem.getSkillEffects(unit)
    return effects and effects[effectName] or nil
end

return EquipmentSystem


























