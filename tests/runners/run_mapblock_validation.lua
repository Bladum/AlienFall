-- Mapblock Validation Runner
-- Run mapblock validation to check for tile reference issues

print("=== STARTING MAPBLOCK VALIDATION ===")

local ModManager = require("core.mod_manager")
local DataLoader = require("core.data_loader")
local MapblockValidator = require("core.mapblock_validator")

print("Starting Mapblock Validation...")
print("This will scan all mapblocks and verify tile references.")

-- Initialize mod system first
print("Initializing mod system...")
ModManager.init()

-- Load data (terrain types)
print("Loading terrain data...")
DataLoader.load()

-- Run validation
local results = MapblockValidator.run()

print("\nMapblock validation complete!")
print("Results:")
print("  Mapblocks scanned: " .. #results.mapblocks)
print("  Valid mapblocks: " .. #results.validMapblocks)
print("  Invalid mapblocks: " .. #results.invalidMapblocks)
print("  Total tiles checked: " .. results.totalTiles)
print("  Invalid tile references: " .. results.invalidTiles)
print("  Total issues: " .. #results.issues)
























