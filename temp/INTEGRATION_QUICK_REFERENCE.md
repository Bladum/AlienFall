# API-Engine-Mods Integration Quick Reference
**Quick Implementation Guide**

**Date:** 2025-10-27  
**For:** Developers implementing improvements

---

## Critical Gaps Summary

### 🔥 High Priority (Do First)

| Gap | Current State | Impact | Solution |
|-----|---------------|--------|----------|
| **No Runtime Validation** | TOML loaded without checks | Silent data corruption | Integrate SchemaValidator |
| **No Structure Enforcement** | Any directory structure works | Inconsistent mods | Enforce canonical structure |
| **No Relationship Resolution** | Manual cross-references | Runtime crashes | Add ContentRegistry |
| **No Error Messages** | Generic Lua errors | Hard to debug | User-friendly errors |

### 🟡 Medium Priority (Do Soon)

| Gap | Current State | Impact | Solution |
|-----|---------------|--------|----------|
| **No API Versioning** | Single version for all | Breaking changes | Version per API section |
| **Manual Doc Sync** | Docs drift from schema | Outdated info | Auto-generate from schema |
| **No Dependency Management** | No mod dependencies | Load order issues | Add dependency system |

### 🟢 Low Priority (Nice to Have)

| Gap | Current State | Impact | Solution |
|-----|---------------|--------|----------|
| **No Hot Reloading** | Restart to reload mods | Slow iteration | Add file watchers |
| **No IDE Integration** | No autocomplete | Slow modding | VS Code extension |
| **No Content Diffing** | Manual comparison | Hard to update | Diff tool |

---

## Quick Wins (Immediate Impact)

### Quick Win 1: Add Metadata to TOML Files (15 minutes)

**Before:**
```toml
[[unit]]
id = "soldier_rookie"
name = "Rookie"
```

**After:**
```toml
[_metadata]
content_type = "units"
api_version = "1.0.0"

[[unit]]
id = "soldier_rookie"
name = "Rookie"
```

**Impact:** Enables validation, versioning, self-documentation

---

### Quick Win 2: Validate on Load (30 minutes)

**Add to DataLoader:**
```lua
function DataLoader.loadWeapons()
    local path = ModManager.getContentPath("rules", "items/weapons.toml")
    local data = TOML.load(path)
    
    -- ADD THIS:
    if not data or not data.weapon then
        error("[DataLoader] Invalid weapons.toml: missing [[weapon]] array")
    end
    
    for i, weapon in ipairs(data.weapon) do
        -- ADD THIS:
        if not weapon.id then
            error(string.format("[DataLoader] Weapon #%d missing required field 'id'", i))
        end
        if not weapon.name then
            error(string.format("[DataLoader] Weapon '%s' missing required field 'name'", weapon.id))
        end
        if type(weapon.damage) ~= "number" then
            error(string.format("[DataLoader] Weapon '%s' field 'damage' must be number, got %s", 
                weapon.id, type(weapon.damage)))
        end
    end
    
    -- Continue normal loading...
end
```

**Impact:** Catch 80% of content errors immediately

---

### Quick Win 3: Better Error Messages (15 minutes)

**Before:**
```lua
local weapon = DataLoader.weapons.get("riffle")  -- Typo!
-- Later: attempt to index nil value
```

**After:**
```lua
function weapons.get(weaponId)
    local weapon = weapons.weapons[weaponId]
    
    if not weapon then
        -- Suggest similar IDs
        local similar = findSimilarIds(weaponId, weapons.getAllIds())
        local suggestion = #similar > 0 and 
            string.format("\n  Did you mean: %s?", table.concat(similar, ", ")) or ""
        
        error(string.format(
            "[Weapons] Weapon '%s' not found%s\n" ..
            "Available weapons: %s",
            weaponId,
            suggestion,
            table.concat(weapons.getAllIds(), ", ")
        ))
    end
    
    return weapon
end
```

**Impact:** 10x faster debugging for mod creators

---

## Code Snippets for Common Tasks

### Snippet 1: Load and Validate Content

```lua
-- Generic content loader with validation
function DataLoader.loadContentFile(contentType, relativePath)
    local path = ModManager.getContentPath("content", relativePath)
    if not path then
        error(string.format("[DataLoader] Could not resolve path: %s", relativePath))
    end
    
    print(string.format("[DataLoader] Loading %s from %s", contentType, path))
    
    -- Load TOML
    local data = TOML.load(path)
    if not data then
        error(string.format("[DataLoader] Failed to load: %s", path))
    end
    
    -- Check metadata
    if data._metadata then
        if data._metadata.content_type ~= contentType then
            print(string.format(
                "[WARNING] Content type mismatch: expected %s, got %s",
                contentType, data._metadata.content_type
            ))
        end
    else
        print(string.format("[WARNING] Missing [_metadata] in %s", path))
    end
    
    -- Validate against schema
    local schema = SchemaValidator.getSchema(contentType)
    if schema then
        local valid, errors = SchemaValidator.validate(data, schema)
        if not valid then
            local errorMsg = formatValidationErrors(errors)
            error(string.format(
                "[DataLoader] Validation failed for %s:\n%s",
                path, errorMsg
            ))
        end
    end
    
    return data
end
```

### Snippet 2: Check Mod Compatibility

```lua
function ModManager.checkCompatibility(modConfig)
    local errors = {}
    
    -- Check engine version
    if modConfig.compatibility and modConfig.compatibility.engine_version then
        local currentVersion = "1.5.0"  -- Get from engine
        local required = modConfig.compatibility.engine_version
        
        if not isVersionCompatible(currentVersion, required) then
            table.insert(errors, string.format(
                "Engine version mismatch: requires %s, have %s",
                required, currentVersion
            ))
        end
    end
    
    -- Check API version
    if modConfig.compatibility and modConfig.compatibility.api_version then
        local currentAPI = "1.0.0"  -- Get from GAME_API.toml
        local required = modConfig.compatibility.api_version
        
        if not isVersionCompatible(currentAPI, required) then
            table.insert(errors, string.format(
                "API version mismatch: requires %s, have %s",
                required, currentAPI
            ))
        end
    end
    
    if #errors > 0 then
        error(string.format(
            "[ModManager] Compatibility check failed for '%s':\n%s",
            modConfig.mod.name,
            table.concat(errors, "\n")
        ))
    end
end
```

### Snippet 3: Resolve Entity Relationships

```lua
-- Resolve weapon -> ammo reference
function ContentRegistry.resolveWeaponReferences(weapon)
    if weapon.ammo_type then
        weapon._ammo = ContentRegistry.get("items", weapon.ammo_type)
        
        if not weapon._ammo then
            print(string.format(
                "[WARNING] Weapon '%s' references unknown ammo '%s'",
                weapon.id, weapon.ammo_type
            ))
        end
    end
    
    return weapon
end

-- Usage in DataLoader
function DataLoader.loadWeapons()
    local data = DataLoader.loadContentFile("weapons", "items/weapons.toml")
    
    for _, weapon in ipairs(data.weapon or {}) do
        -- Register in ContentRegistry
        ContentRegistry.register("weapons", weapon.id, weapon)
        
        -- Resolve references
        ContentRegistry.resolveWeaponReferences(weapon)
    end
end
```

### Snippet 4: Validate Field Types

```lua
function SchemaValidator.validateField(value, fieldSchema, fieldName)
    local errors = {}
    
    -- Check required
    if fieldSchema.required and value == nil then
        table.insert(errors, {
            field = fieldName,
            error = "Required field missing"
        })
        return false, errors
    end
    
    if value == nil then
        return true, {}  -- Optional field, not provided
    end
    
    -- Check type
    local expectedType = fieldSchema.type
    local actualType = type(value)
    
    if expectedType == "integer" or expectedType == "float" then
        if actualType ~= "number" then
            table.insert(errors, {
                field = fieldName,
                error = string.format("Expected %s, got %s", expectedType, actualType)
            })
        end
    elseif expectedType ~= actualType then
        table.insert(errors, {
            field = fieldName,
            error = string.format("Expected %s, got %s", expectedType, actualType)
        })
    end
    
    -- Check constraints
    if actualType == "number" then
        if fieldSchema.min and value < fieldSchema.min then
            table.insert(errors, {
                field = fieldName,
                error = string.format("Value %s below minimum %s", value, fieldSchema.min)
            })
        end
        if fieldSchema.max and value > fieldSchema.max then
            table.insert(errors, {
                field = fieldName,
                error = string.format("Value %s above maximum %s", value, fieldSchema.max)
            })
        end
    end
    
    -- Check enum values
    if fieldSchema.values then
        local found = false
        for _, validValue in ipairs(fieldSchema.values) do
            if value == validValue then
                found = true
                break
            end
        end
        
        if not found then
            table.insert(errors, {
                field = fieldName,
                error = string.format(
                    "Invalid value '%s'. Valid values: %s",
                    value,
                    table.concat(fieldSchema.values, ", ")
                )
            })
        end
    end
    
    return #errors == 0, errors
end
```

---

## Testing Checklist

### Before Committing Changes

- [ ] Game loads without errors
- [ ] Core mod loads successfully
- [ ] All content types load (units, items, facilities, etc.)
- [ ] Invalid content is rejected with clear errors
- [ ] Validation errors are user-friendly
- [ ] Performance is acceptable (< 2s load time)
- [ ] No regression in existing functionality

### Content Validation Tests

```lua
-- Test: Invalid field type
[[weapon]]
id = "test_weapon"
damage = "fifty"  -- Should error: expected number

-- Test: Missing required field
[[weapon]]
name = "Test"
-- Missing id - should error

-- Test: Out of range value
[[weapon]]
id = "test"
damage = -10  -- Should error: below minimum

-- Test: Unknown field
[[weapon]]
id = "test"
super_power = true  -- Should warn: unknown field

-- Test: Invalid enum value
[[weapon]]
id = "test"
type = "magical"  -- Should error: not in enum
```

---

## Common Pitfalls

### Pitfall 1: Silently Ignoring Errors

**Bad:**
```lua
local weapon = DataLoader.weapons.get("rifle")
if weapon then
    -- Use weapon
end
-- Continues silently if weapon not found
```

**Good:**
```lua
local weapon = DataLoader.weapons.get("rifle")
if not weapon then
    error("[Combat] Required weapon 'rifle' not found")
end
-- Use weapon
```

### Pitfall 2: Assuming Fields Exist

**Bad:**
```lua
local damage = weapon.damage  -- Might be nil
local totalDamage = damage * 2  -- Runtime error if nil
```

**Good:**
```lua
local damage = weapon.damage or 0  -- Default value
if damage <= 0 then
    print(string.format("[WARNING] Weapon '%s' has invalid damage: %s", 
        weapon.id, damage))
end
local totalDamage = damage * 2
```

### Pitfall 3: Not Validating References

**Bad:**
```lua
local ammoId = weapon.ammo_type
local ammo = DataLoader.items.get(ammoId)  -- Might be nil
local ammoCount = ammo.quantity  -- Crashes if ammo is nil
```

**Good:**
```lua
local ammoId = weapon.ammo_type
if not ammoId then
    print(string.format("[WARNING] Weapon '%s' has no ammo_type", weapon.id))
    return nil
end

local ammo = DataLoader.items.get(ammoId)
if not ammo then
    error(string.format(
        "[DataLoader] Weapon '%s' references unknown ammo '%s'",
        weapon.id, ammoId
    ))
end

local ammoCount = ammo.quantity or 0
```

---

## Performance Optimization

### Optimization 1: Cache Resolved References

```lua
-- Instead of resolving every time:
function Unit:getWeapon()
    local weaponId = self.equipment.primary
    return ContentRegistry.get("weapons", weaponId)  -- Lookup every time
end

-- Cache resolved reference:
function Unit:loadEquipment()
    if self.equipment.primary then
        self._primary_weapon = ContentRegistry.get("weapons", self.equipment.primary)
        
        if not self._primary_weapon then
            print(string.format("[WARNING] Unit '%s' has unknown weapon '%s'",
                self.id, self.equipment.primary))
        end
    end
end

function Unit:getWeapon()
    return self._primary_weapon  -- Cached, instant
end
```

### Optimization 2: Lazy Load Content

```lua
-- Don't load everything at startup
function DataLoader.load()
    -- Load only essential content
    DataLoader.terrainTypes = DataLoader.loadTerrainTypes()
    DataLoader.weapons = DataLoader.loadWeapons()
    
    -- Lazy load optional content
    DataLoader._lazyLoaders = {
        lore = function() return DataLoader.loadLore() end,
        narrative = function() return DataLoader.loadNarrative() end,
    }
end

function DataLoader.get(contentType)
    if DataLoader[contentType] then
        return DataLoader[contentType]
    end
    
    -- Lazy load if available
    local loader = DataLoader._lazyLoaders[contentType]
    if loader then
        print(string.format("[DataLoader] Lazy loading: %s", contentType))
        DataLoader[contentType] = loader()
        return DataLoader[contentType]
    end
    
    return nil
end
```

---

## Debug Commands

### Enable Debug Mode

```lua
-- Add to engine/conf.lua
function love.conf(t)
    t.debug_mode = true
    t.content_validation = true
    t.strict_validation = true
end
```

### Print Content Stats

```lua
function DataLoader.printStats()
    print("=== Content Statistics ===")
    print(string.format("Terrain Types: %d", #DataLoader.terrainTypes.getAllIds()))
    print(string.format("Weapons: %d", #DataLoader.weapons.getAllIds()))
    print(string.format("Armours: %d", #DataLoader.armours.getAllIds()))
    print(string.format("Unit Classes: %d", #DataLoader.unitClasses.getAllIds()))
    print(string.format("Facilities: %d", #DataLoader.facilities.getAllIds()))
    print("=========================")
end
```

### Validate All Content

```lua
function DataLoader.validateAll()
    print("[Validation] Validating all content...")
    
    local categories = {
        "terrainTypes",
        "weapons",
        "armours",
        "unitClasses",
        "facilities"
    }
    
    local totalErrors = 0
    
    for _, category in ipairs(categories) do
        local content = DataLoader[category]
        if content then
            local ids = content.getAllIds()
            print(string.format("[Validation] Checking %s (%d items)...", 
                category, #ids))
            
            for _, id in ipairs(ids) do
                local item = content.get(id)
                local valid, errors = SchemaValidator.validateEntity(item, category)
                
                if not valid then
                    print(string.format("  [ERROR] %s '%s':", category, id))
                    for _, error in ipairs(errors) do
                        print(string.format("    - %s: %s", error.field, error.error))
                        totalErrors = totalErrors + 1
                    end
                end
            end
        end
    end
    
    if totalErrors == 0 then
        print("[Validation] ✓ All content valid!")
    else
        print(string.format("[Validation] ✗ Found %d errors", totalErrors))
    end
end
```

---

## File Locations Reference

### Core Files to Modify

```
engine/
├── core/
│   ├── mod_manager.lua          # Add v2 format support
│   └── data/
│       ├── data_loader.lua      # Add validation
│       ├── schema_validator.lua # NEW - Create this
│       └── content_registry.lua # NEW - Create this
│
mods/
└── core/
    ├── mod.toml                 # Upgrade to v2
    └── content/                 # Rename from rules/
        ├── units/               # Add metadata
        ├── items/               # Add metadata
        └── facilities/          # Add metadata

tools/
└── migration/                   # NEW - Create these
    ├── migrate_mod_structure.lua
    ├── add_metadata_headers.lua
    ├── upgrade_mod_toml.lua
    └── generate_manifest.lua
```

---

## Next Actions (Priority Order)

1. ✅ **Create SchemaValidator module** (30 min)
2. ✅ **Add basic validation to DataLoader** (1 hour)
3. ✅ **Test with core mod** (30 min)
4. ✅ **Add metadata to core mod TOML files** (1 hour)
5. ✅ **Create migration tools** (2 hours)
6. ✅ **Update ModManager for v2 format** (2 hours)
7. ✅ **Create ContentRegistry** (3 hours)
8. ✅ **Full integration testing** (2 hours)

**Total Time:** ~12 hours for core functionality

---

## Support Resources

- **Main Analysis:** `temp/API_ENGINE_MODS_INTEGRATION_ANALYSIS.md`
- **Implementation Plan:** `temp/MOD_STRUCTURE_IMPROVEMENT_PLAN.md`
- **API Schema:** `api/GAME_API.toml`
- **API Guide:** `api/GAME_API_GUIDE.md`
- **Sync Guide:** `api/SYNCHRONIZATION_GUIDE.md`

---

**End of Quick Reference**

