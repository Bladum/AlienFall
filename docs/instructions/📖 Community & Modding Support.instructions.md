# 📖 Community & Modding Support Best Practices

**Domain:** Community & Extensibility  
**Focus:** Mod systems, modding documentation, API stability, community engagement, content creation tools  
**Version:** 1.0  
**Date:** October 2025

## Overview

This guide covers supporting mod creators, maintaining mod systems, and building engaged game communities.

## Modding Framework

### ✅ DO: Provide Clean Modding API

```lua
-- mods/api.lua - Public modding interface
ModAPI = {
    version = "1.0.0",
    registered_units = {},
    registered_weapons = {},
    registered_facilities = {}
}

function ModAPI:registerUnit(unitDef)
    -- Validate required fields
    assert(unitDef.name, "Unit must have name")
    assert(unitDef.health, "Unit must have health")
    assert(unitDef.icon, "Unit must have icon")
    
    self.registered_units[unitDef.name] = unitDef
    print("[MOD API] Registered unit: " .. unitDef.name)
    
    return unitDef
end

function ModAPI:registerWeapon(weaponDef)
    assert(weaponDef.name, "Weapon must have name")
    assert(weaponDef.damage, "Weapon must have damage")
    
    self.registered_weapons[weaponDef.name] = weaponDef
    print("[MOD API] Registered weapon: " .. weaponDef.name)
    
    return weaponDef
end

function ModAPI:getUnit(name)
    return self.registered_units[name]
end

function ModAPI:listUnits()
    local list = {}
    for name, _ in pairs(self.registered_units) do
        table.insert(list, name)
    end
    return list
end
```

---

### ✅ DO: Implement Mod Lifecycle Hooks

```lua
-- mods/hooks.lua
ModHooks = {
    handlers = {}
}

function ModHooks:register(eventName, handler)
    if not self.handlers[eventName] then
        self.handlers[eventName] = {}
    end
    
    table.insert(self.handlers[eventName], handler)
end

function ModHooks:fire(eventName, ...)
    if not self.handlers[eventName] then return end
    
    for _, handler in ipairs(self.handlers[eventName]) do
        local success, err = pcall(handler, ...)
        if not success then
            print("[MOD HOOK ERROR] " .. eventName .. ": " .. err)
        end
    end
end

-- Available hooks
-- - "game:load" - Game initializes
-- - "game:enter_battle" - Entering combat
-- - "game:exit_battle" - Leaving combat
-- - "unit:created" - Unit spawned
-- - "unit:destroyed" - Unit killed
-- - "mod:loaded" - Mod finishes loading

-- Usage in mod
ModHooks:register("game:enter_battle", function()
    print("[MY MOD] Battle started!")
end)

ModHooks:register("unit:created", function(unit)
    print("[MY MOD] Unit created: " .. unit.name)
end)
```

---

## Mod Content System

### ✅ DO: Load Mods from Directory

```lua
function loadMods(modsDirectory)
    local modsLoaded = 0
    
    -- List all mod directories
    for modName in love.filesystem.getDirectoryItems(modsDirectory) do
        local modPath = modsDirectory .. "/" .. modName
        
        if love.filesystem.getInfo(modPath).type == "directory" then
            if loadMod(modPath, modName) then
                modsLoaded = modsLoaded + 1
            end
        end
    end
    
    print("[MODS] Loaded " .. modsLoaded .. " mods")
    return modsLoaded > 0
end

function loadMod(modPath, modName)
    print("[MODS] Loading mod: " .. modName)
    
    -- Verify mod structure
    if not love.filesystem.getInfo(modPath .. "/mod.json") then
        print("[MOD ERROR] Missing mod.json in " .. modName)
        return false
    end
    
    -- Load mod metadata
    local metadata = loadJSON(modPath .. "/mod.json")
    
    -- Verify compatibility
    if not isModCompatible(metadata) then
        print("[MOD ERROR] Mod " .. modName .. " incompatible with this game version")
        return false
    end
    
    -- Load main mod script
    if love.filesystem.getInfo(modPath .. "/main.lua") then
        local modEnv = createModEnvironment(metadata)
        local modScript = love.filesystem.read(modPath .. "/main.lua")
        
        local fn = load(modScript, modName, "t", modEnv)
        if fn then
            local success, err = pcall(fn)
            if not success then
                print("[MOD ERROR] " .. modName .. ": " .. err)
                return false
            end
        end
    end
    
    ModHooks:fire("mod:loaded", modName, metadata)
    return true
end

function createModEnvironment(metadata)
    return {
        -- Provide safe API
        ModAPI = ModAPI,
        ModHooks = ModHooks,
        print = print,
        table = table,
        string = string,
        math = math,
        
        -- Block dangerous functions
        os = nil,
        io = nil,
        load = nil,
        debug = nil
    }
end
```

---

### ✅ DO: Define Mod Structure

```
mods/
├── my_awesome_mod/
│   ├── mod.json              -- Mod metadata
│   ├── main.lua              -- Mod entry point
│   ├── units.lua             -- Custom units
│   ├── weapons.lua           -- Custom weapons
│   ├── assets/
│   │   ├── sprites/
│   │   └── sounds/
│   └── README.md             -- Mod documentation

-- Example mod.json
{
    "name": "My Awesome Mod",
    "author": "ModCreator",
    "version": "1.0.0",
    "description": "Adds new units and weapons",
    "game_version": "1.2.3+",
    "dependencies": []
}

-- Example main.lua
local myMod = {
    name = "My Awesome Mod",
    version = "1.0.0"
}

function myMod:load()
    print("[MOD] Loading " .. self.name)
    
    -- Register custom content
    ModAPI:registerUnit({
        name = "MyCustomUnit",
        health = 100,
        armor = 20,
        icon = "assets/sprites/my_unit.png"
    })
end

myMod:load()
```

---

## Documentation & Community

### ✅ DO: Provide Modding Documentation

```markdown
# Modding Guide

## Getting Started

### Create a Mod Directory

Create a folder in `mods/my_first_mod/` with these files:
- `mod.json` - Mod metadata
- `main.lua` - Mod code
- `README.md` - Documentation

### mod.json Format

```json
{
    "name": "My First Mod",
    "author": "YourName",
    "version": "1.0.0",
    "description": "A great mod description",
    "game_version": "1.2.0+"
}
```

### Register a Custom Unit

```lua
ModAPI:registerUnit({
    name = "SuperSoldier",
    health = 150,
    armor = 30,
    damage = 50,
    icon = "assets/sprites/super_soldier.png"
})
```

## API Reference

### ModAPI

#### registerUnit(unitDef)
Register a custom unit type.

**Parameters:**
- `unitDef` (table): Unit definition with name, health, armor, icon

**Example:**
```lua
ModAPI:registerUnit({name = "Laser Trooper", health = 100})
```

#### registerWeapon(weaponDef)
Register a custom weapon.

**Parameters:**
- `weaponDef` (table): Weapon definition

### ModHooks

#### register(eventName, handler)
Register a handler for mod events.

**Available Events:**
- `"game:load"` - Game starts
- `"game:enter_battle"` - Battle starts
- `"unit:created"` - Unit spawned
- `"unit:destroyed"` - Unit killed

## Best Practices

1. Always check if ModAPI exists
2. Use unique prefixes for custom content
3. Document your mod thoroughly
4. Test with different game versions
5. Provide clear error messages
```

---

## Practical Implementation

### ✅ DO: Validate Mod Compatibility

```lua
function isModCompatible(metadata)
    local requiredVersion = metadata.game_version or "1.0.0"
    
    -- Parse version requirements
    local minVersion = requiredVersion:match("([%d.]+)")
    local gameVersion = getGameVersion()
    
    return compareVersions(gameVersion, minVersion) >= 0
end

function compareVersions(v1, v2)
    -- Parse versions
    local parts1 = {v1:match("(%d+)%.(%d+)%.(%d+)")}
    local parts2 = {v2:match("(%d+)%.(%d+)%.(%d+)")}
    
    for i = 1, 3 do
        if tonumber(parts1[i] or 0) > tonumber(parts2[i] or 0) then return 1 end
        if tonumber(parts1[i] or 0) < tonumber(parts2[i] or 0) then return -1 end
    end
    
    return 0
end
```

---

### ✅ DO: Create Mod Content Tool

```lua
-- tools/mod_template_generator.lua
function generateModTemplate(modName, author)
    local template = {
        ["mod.json"] = jsonEncode({
            name = modName,
            author = author,
            version = "1.0.0",
            description = "My awesome mod",
            game_version = "1.0.0+"
        }),
        
        ["main.lua"] = [[
-- ]] .. modName .. [[ - Main Mod File
print("[MOD] Loading ]] .. modName .. [[")

-- Register your custom content here
-- ModAPI:registerUnit({...})
-- ModAPI:registerWeapon({...})

print("[MOD] ]] .. modName .. [[ loaded successfully")
        ]],
        
        ["README.md"] = "# " .. modName .. "\n\nAuthor: " .. author .. "\n\nDescription of your awesome mod."
    }
    
    return template
end

-- Usage
local template = generateModTemplate("MyMod", "MyName")
for filename, content in pairs(template) do
    print("Create: " .. filename)
    print(content)
end
```

---

### ❌ DON'T: Expose Internal Systems to Mods

```lua
-- BAD: Gives mods access to everything
function createModEnvironment()
    return _G  -- Dangerous!
end

-- GOOD: Whitelist only safe APIs
function createModEnvironment()
    return {
        ModAPI = ModAPI,
        ModHooks = ModHooks,
        print = print,
        table = table,
        string = string,
        math = math
    }
end
```

---

### ❌ DON'T: Load Unsigned or Untrusted Mods

```lua
-- BAD: No verification
function loadModBad(modPath)
    local code = love.filesystem.read(modPath)
    load(code)()  -- Execute directly
end

-- GOOD: Verify and sandbox
function loadModGood(modPath)
    -- Verify mod signature
    if not verifyModSignature(modPath) then
        return false
    end
    
    -- Execute in sandbox
    return executeModInSandbox(modPath)
end
```

---

## Common Patterns & Checklist

- [x] Provide clean modding API
- [x] Implement mod lifecycle hooks
- [x] Define mod directory structure
- [x] Load mods from directory
- [x] Sandbox mod execution
- [x] Validate mod compatibility
- [x] Provide modding documentation
- [x] Create mod template generator
- [x] Verify mod signatures
- [x] Create mod content tools

---

## References

- Mod Community: https://www.nexusmods.com/
- Workshop Integration: https://steamcommunity.com/workshop/
- Modding Best Practices: https://www.themodindex.com/

