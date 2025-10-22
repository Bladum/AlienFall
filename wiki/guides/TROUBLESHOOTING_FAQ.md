# API Troubleshooting & FAQ

**Version:** 1.0  
**Date:** October 21, 2025  
**Goal:** Solutions to common problems and answers to frequent questions

---

## Troubleshooting

### Problem: "Module not found" Error

**Symptom:** `ERROR: Module 'engine.path.name' not found`

**Solutions:**
1. Verify the require path matches actual file location
2. Check file exists in `engine/` folder
3. Ensure no typos in require statement
4. Use proper path separators (dots, not slashes)

**Example:**
```lua
-- ❌ WRONG
local Module = require("engine/path/name")

-- ✅ CORRECT
local Module = require("engine.path.name")
```

---

### Problem: "Function Does Not Exist"

**Symptom:** `ERROR: attempt to call a nil value`

**Solutions:**
1. Check API documentation for correct function name
2. Verify you're calling function on correct object
3. Ensure module is loaded before calling function
4. Check function doesn't require prerequisites

**Example:**
```lua
-- ❌ WRONG - DataLoader doesn't have this function
DataLoader.item.findByName("Medikit")

-- ✅ CORRECT - Use getByCategory or getAllIds
local items = DataLoader.item.getByCategory("consumables")
```

---

### Problem: "Table is Nil" Error

**Symptom:** `ERROR: attempt to index a nil value`

**Solutions:**
1. Load data before using it
2. Verify ID exists in system
3. Check prerequisites are met
4. Use defensive programming

**Example:**
```lua
-- ❌ WRONG - Assuming item exists
local item = DataLoader.item.get("nonexistent_item")
print(item.name)  -- ERROR: item is nil!

-- ✅ CORRECT - Check before using
local item = DataLoader.item.get("nonexistent_item")
if item then
    print(item.name)
else
    print("Item not found")
end
```

---

### Problem: Data Not Loading

**Symptom:** Items/weapons/techs don't appear in game

**Solutions:**
1. Check console for load errors
2. Verify TOML file syntax is correct
3. Check file is in correct directory
4. Verify mod metadata is set up
5. Look for parse errors in console

**Debug:**
```lua
-- Check if data loaded
local items = DataLoader.item.getAllIds()
print("[DEBUG] Total items: " .. #items)

-- Check for specific item
local item = DataLoader.item.get("item_id")
if item then
    print("[DEBUG] Item found: " .. item.name)
else
    print("[DEBUG] Item NOT found - check TOML")
end
```

---

### Problem: Mod Not Loading

**Symptom:** Mod doesn't appear in game

**Solutions:**
1. Check `metadata.toml` exists and is valid
2. Verify folder structure matches expected layout
3. Check for typos in mod ID
4. Verify TOML syntax (no missing brackets)
5. Check console for specific error

**Valid structure:**
```
mods/my_mod/
├── metadata.toml
├── README.md
└── content/
    ├── items/
    ├── weapons/
    └── technologies/
```

---

### Problem: Performance Issues

**Symptom:** Game runs slowly or freezes

**Solutions:**
1. Don't reload data every frame - load once
2. Cache calculation results
3. Batch updates instead of individual
4. Use indexed lookups (by ID)
5. Profile to find bottleneck

**Good practices:**
```lua
-- ❌ BAD - Reloading every frame
function love.update(dt)
    local item = DataLoader.item.get("item_medikit")
end

-- ✅ GOOD - Load once in love.load
function love.load()
    CACHED_ITEM = DataLoader.item.get("item_medikit")
end

function love.update(dt)
    useItem(CACHED_ITEM)
end
```

---

### Problem: Calculations Wrong

**Symptom:** Budget/rewards/damage don't match expected values

**Solutions:**
1. Check if modifiers are being applied
2. Verify all bonuses are calculated
3. Check for rounding errors
4. Review formula in API documentation
5. Add debug prints to trace calculation

**Debug:**
```lua
local budget = Budget.calculate(base)
print("[DEBUG] Income: " .. budget.income)
print("[DEBUG] Expenses: " .. budget.expenses)
print("[DEBUG] Balance: " .. budget.balance)
print("[DEBUG] Deficit: " .. tostring(budget.deficit))
```

---

## Frequently Asked Questions

### Q: Where do I find available functions?

**A:** Check the API file for your system:
1. Find "Core Entities" section
2. Look for function signatures
3. Check parameters and returns
4. See Integration Examples for usage

Example in `API_ECONOMY_AND_ITEMS.md`:
```lua
DataLoader.item.get(itemId) -> table
-- Get complete item definition by ID
-- Returns: Item table with all properties
```

---

### Q: How do I load game data?

**A:** Use the DataLoader module:

```lua
local DataLoader = require("engine.core.data_loader")

-- Get specific item
local item = DataLoader.item.get("item_medikit")

-- Get all items
local items = DataLoader.item.getAllIds()

-- Get items by category
local weapons = DataLoader.item.getByCategory("weapons")
```

---

### Q: How do I create a new game instance?

**A:** Most systems have create() functions:

```lua
-- Create research project
local Research = require("engine.basescape.research")
local project = Research.create("tech_id", base)

-- Create manufacturing project
local Manufacturing = require("engine.basescape.manufacturing")
local production = Manufacturing.createProduct("recipe_id", quantity, base)

-- Create mission
local Mission = require("engine.geoscape.mission")
local mission = Mission.create(template, difficulty)
```

---

### Q: How do I update game state?

**A:** Call update functions with new parameters:

```lua
-- Update progress
Research.updateProgress(project, scientist_count, facility_bonus)

-- Update position
Craft.updateFuel(craft, -50)  -- Consume 50 fuel

-- Update status
Base.updateStatus(base)  -- Recalculate all values
```

---

### Q: How do I get results/completion?

**A:** Call complete or get functions:

```lua
-- Complete and get reward
local reward = Mission.complete(missionInstance, results)

-- Get current outcome
local outcome = Interception.getOutcome(battle)

-- Get calculated value
local budget = Budget.calculate(base)
```

---

### Q: What are the performance metrics?

**A:** Most common operations take < 5ms:

| Operation | Time |
|-----------|------|
| Load data | 50-100ms (startup only) |
| Lookup by ID | < 1ms |
| Create instance | < 5ms |
| Update state | < 2ms |
| Calculate result | < 5ms |

See "Performance Considerations" in each API file.

---

### Q: How do I debug issues?

**A:** Use print statements and check console:

```lua
-- Enable Love2D console
print("[DEBUG] Variable value: " .. tostring(value))

-- Check conditions
if item == nil then
    print("[ERROR] Item is nil!")
end

-- Trace execution
print("[TRACE] Starting process...")
doSomething()
print("[TRACE] Process complete")
```

---

### Q: What's the best way to organize code?

**A:** Follow the pattern structure:

```lua
-- 1. Load dependencies
local DataLoader = require("engine.core.data_loader")
local Research = require("engine.basescape.research")

-- 2. Load/cache data
local base = Basescape.Base.get("base_main")

-- 3. Execute operations
local project = Research.create("tech_id", base)

-- 4. Process results
if project then
    print("[SUCCESS] Project created")
end
```

---

### Q: How do I handle errors?

**A:** Use return values and check results:

```lua
-- Check boolean return
local success, msg = Marketplace.buyItem(base, item, quantity)
if not success then
    print("[ERROR] " .. msg)
    return false
end

-- Check for nil
local item = DataLoader.item.get("item_id")
if not item then
    print("[ERROR] Item not found")
    return nil
end
```

---

### Q: Where's the complete documentation?

**A:** See these files:
- Quick-Start: `API_QUICK_START.md`
- All APIs: `wiki/api/API_*.md` (19 files)
- Schema: `API_SCHEMA_REFERENCE.md`
- Game Design: `wiki/FAQ.md`
- Development: `wiki/DEVELOPMENT.md`

---

### Q: How do I create a mod?

**A:** See `MOD_DEVELOPMENT_TUTORIAL.md` for complete guide:
1. Create directory structure
2. Write TOML files
3. Test in game
4. Package and share

---

### Q: What if I find a bug?

**A:** Report with details:
1. Describe what went wrong
2. Show console error message
3. Include code that caused issue
4. List steps to reproduce
5. Check if already reported

---

## Console Debug Output

### Understanding console messages

```
[MODULE_NAME] Message type
[DEBUG] - Debugging information
[WARNING] - Non-critical issue
[ERROR] - Critical problem
[SUCCESS] - Operation succeeded
[INFO] - General information
```

### Example output

```
[MOD LOADER] Loading mod: mod_test
[DEBUG] Processing items...
[DEBUG] Processing weapons...
[SUCCESS] Mod loaded: 5 items, 3 weapons
[ECONOMY] Marketplace updated
[DEBUG] Prices calculated
[INFO] Game ready
```

---

## Common Data Values

### Difficulty Levels
- Easy: 1
- Normal: 2
- Hard: 3
- Very Hard: 4
- Impossible: 5

### Rarity Levels
- Common: 0
- Uncommon: 1
- Rare: 2
- Very Rare: 3
- Unique: 4

### Item Categories
- weapons
- armor
- ammunition
- consumables
- components
- special

### Mission Types
- rescue
- assault
- defend
- research
- intercept

---

## Performance Optimization Tips

1. **Cache data** - Load once, reuse many times
2. **Batch updates** - Process multiple items together
3. **Avoid loops** - Use indexed lookups instead
4. **Minimize calculations** - Cache results
5. **Profile code** - Find real bottlenecks
6. **Use efficient structures** - Arrays vs maps
7. **Lazy load** - Load only what's needed
8. **Pool objects** - Reuse instances

---

## Getting Help

1. Check this FAQ
2. Read the API file for your system
3. Review Integration Patterns guide
4. Check console for error messages
5. Ask in community forums
6. Review existing code examples

---

**Still stuck?** Check the complete API documentation or integration examples. Happy coding! 🚀
