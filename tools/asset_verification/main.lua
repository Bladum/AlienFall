-- Asset Verification Runner
-- Run asset verification and create placeholders

-- Add engine directory to Lua path for require() to work
package.path = package.path .. ";../../engine/?.lua;../../engine/?/init.lua"

local ModManager = require("core.mod_manager")
local AssetVerifier = require("utils.verify_assets")

print("Starting Asset Verification...")
print("This will scan TOML files and create placeholder images for missing assets.")

-- Initialize mod system first
print("Initializing mod system...")
ModManager.init()

-- Run verification with placeholder creation
local results = AssetVerifier.run(true)

print("\nAsset verification complete!")
print("Results:")
print("  Terrain types found: " .. #results.terrainTypes)
print("  Unit classes found: " .. #results.unitClasses)
print("  Assets verified: " .. #results.verifiedAssets)
print("  Missing assets: " .. #results.missingAssets)
print("  Placeholders created: " .. #results.placeholdersCreated)





















