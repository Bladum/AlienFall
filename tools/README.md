# Development Tools

External utilities for XCOM Simple development. Each tool is a standalone Love2D application that references the main engine code.

## Tools Overview

### 1. Map Editor (`map_editor/`)

Visual editor for creating and modifying tactical maps.

**Purpose:**
- Create new maps for missions
- Edit existing mapblocks
- Design landing zones and spawn points
- Test tileset configurations
- Generate map variants

**Quick Start:**
```bash
# From project root
tools\map_editor\run_map_editor.bat

# Or with Love2D
lovec tools/map_editor
```

**Features:**
- Tileset browser with preview
- Multiple editing tools (paint, fill, erase, select)
- Real-time statistics
- Save/load map files
- Grid overlay and zoom
- Keyboard shortcuts

**See:** `map_editor/README.md` for detailed usage guide

---

### 2. Asset Verification (`asset_verification/`)

Utility for verifying game assets and creating placeholders.

**Purpose:**
- Verify all TOML references have corresponding assets
- Report missing images/sounds
- Auto-generate placeholder images
- Prevent runtime errors from missing files
- CI/CD integration

**Quick Start:**
```bash
# From project root
tools\asset_verification\run_asset_verification.bat

# Or with Love2D
lovec tools/asset_verification
```

**Features:**
- Scans all TOML files (terrains, units, items, tilesets)
- Reports missing assets with file paths
- Creates placeholder images (optional)
- Console output for CI/CD
- Comprehensive verification report

**See:** `asset_verification/README.md` for detailed usage guide

---

### 3. Documentation Cross-Reference Validator

Standalone utility for validating documentation-to-code links.

**Purpose:**
- Verify all documentation implementation links point to existing files
- Detect broken documentation references
- Identify incomplete implementations referenced in docs
- Generate cross-reference audit report
- Maintain design-code synchronization

**Quick Start:**
```bash
# Windows (PowerShell version - recommended)
tools\validate_docs_links.ps1

# Cross-platform (Lua version)
lovec tools/validate_docs_links.lua
```

**Features:**
- Scans all markdown files in `docs/` directory recursively
- Extracts implementation links: `> **Implementation**: \`path/to/file\``
- Categorizes results: valid links, broken links, vague links (with wildcards)
- Generates detailed report: `validate_docs_links_report.txt`
- Console output with color-coded results (green/red/yellow)
- No dependencies on Love2D (pure Lua/PowerShell script)

**Output Report Includes:**
```
Total links found: 47
Valid links: 43 ✓
Broken links: 3 ✗
Vague links: 1 ⚠

Broken Links:
  Line 45: engine/core/old_module.lua (file not found)
  Line 67: engine/ui/missing_widget.lua (file not found)

Vague Links (wildcards):
  Line 12: engine/**/*.lua (multiple matches)
```

**Best Used:**
- After major documentation updates
- During code review to verify docs are up-to-date
- As part of CI/CD validation pipeline
- Weekly validation during active development

**See:** `docs/mods/CROSS_REFERENCE_AUDIT_GUIDE.md` for comprehensive validation standards and audit process

---

## Architecture

Each tool is a **standalone Love2D application** that:
1. Has its own `main.lua` and `conf.lua`
2. References engine code via `package.path`
3. Can be run independently with `lovec tools/[tool_name]`
4. Includes batch file for quick launch

### Directory Structure

```
tools/
├── README.md                    -- This file
├── validate_docs_links.ps1      -- PowerShell cross-reference validator
├── validate_docs_links.lua      -- Lua cross-reference validator (cross-platform)
├── map_editor/
│   ├── main.lua                 -- Map editor entry point
│   ├── conf.lua                 -- Love2D configuration
│   ├── run_map_editor.bat       -- Quick launch
│   └── README.md                -- Map editor guide
└── asset_verification/
    ├── main.lua                 -- Verification entry point
    ├── conf.lua                 -- Love2D configuration
    ├── run_asset_verification.bat -- Quick launch
    └── README.md                -- Verification guide
```

### How Tools Access Engine Code

**Package Path Setup:**
Each tool's `main.lua` adds the engine directory to Lua's search path:

```lua
-- Add engine directory to Lua path for require() to work
package.path = package.path .. ";../../engine/?.lua;../../engine/?/init.lua"

-- Now can require engine modules
local MapEditor = require("battlescape.ui.map_editor")
local ModManager = require("core.mod_manager")
```

This allows tools to:
- Use engine widgets and UI components
- Access game data structures
- Load tilesets and assets
- Use utility functions
- Share code with main game

**Benefits:**
- No code duplication
- Tools stay in sync with engine changes
- Centralized widget system
- Consistent UI/UX across tools

---

## Running Tools

### Method 1: Batch Files (Easiest)

Each Love2D tool has a `.bat` file for quick launch:
```bash
tools\map_editor\run_map_editor.bat
tools\asset_verification\run_asset_verification.bat
```

Script tools run directly:
```bash
# PowerShell (Windows - recommended)
tools\validate_docs_links.ps1

# Or from PowerShell terminal:
powershell -ExecutionPolicy Bypass -File tools\validate_docs_links.ps1
```

### Method 2: Love2D Command

Run Love2D tools directly with `lovec`:
```bash
lovec tools/map_editor
lovec tools/asset_verification
```

### Method 3: Lua Standalone

Run Lua validator on any platform:
```bash
# Requires Lua 5.1+ installed
lua tools/validate_docs_links.lua

# Or from Love2D:
lovec tools/validate_docs_links.lua
```

### Method 4: From Root

Tools expect to be run from project root:
```bash
cd c:\Users\tombl\Documents\Projects
lovec tools/map_editor
tools\validate_docs_links.ps1
```

---

## Development Workflow

### Adding a New Tool

1. **Create tool directory:**
   ```bash
   mkdir tools/new_tool
   ```

2. **Create conf.lua:**
   ```lua
   function love.conf(t)
       t.title = "XCOM Simple - New Tool"
       t.console = true
       -- ... other settings
   end
   ```

3. **Create main.lua:**
   ```lua
   -- Add engine path
   package.path = package.path .. ";../../engine/?.lua;../../engine/?/init.lua"
   
   -- Require dependencies
   local SomeModule = require("some.module")
   
   -- Tool logic
   function love.load()
       -- Initialize
   end
   
   function love.update(dt)
       -- Update
   end
   
   function love.draw()
       -- Draw
   end
   ```

4. **Create batch file:**
   ```bat
   @echo off
   echo Starting New Tool...
   "C:\Program Files\LOVE\lovec.exe" "tools\new_tool"
   ```

5. **Create README.md:**
   - Purpose and features
   - Running instructions
   - Usage guide
   - Troubleshooting

6. **Update this README:**
   - Add tool to overview section
   - Update directory structure
   - Add to table of contents

### Tool Development Tips

**Console Debugging:**
- All tools have `t.console = true` in conf.lua
- Use `print()` for debug output
- Console window shows errors and stack traces

**Widget System:**
- All tools can use engine widgets (`require("widgets")`)
- Use 24×24 grid system for UI layout
- Toggle grid overlay with F9
- Check `wiki/API.md` for widget API

**Asset Loading:**
- Tools can load game assets via Love2D
- Use `love.filesystem` for file I/O
- Check paths relative to tool directory
- Test with both windowed and fullscreen

**Testing:**
- Test tool launches from batch file
- Test require() paths work
- Test with various data files
- Verify console output
- Check for memory leaks with long running tools

---

## Requirements

- **Love2D 12.0+** with console support (`lovec.exe`)
- **Engine code** at `../../engine/` (relative to tool)
- **Mods folder** at `../../mods/` (for tools that need game data)
- **Windows** (batch files are Windows-specific, but tools run on all platforms with Love2D)

---

## Troubleshooting

### Tool Won't Start

**Problem:** Double-clicking batch file shows error

**Solutions:**
1. Verify Love2D 12.0+ installed at `C:\Program Files\LOVE\`
2. Check console window for error messages
3. Try running with `lovec tools/[tool_name]` from project root
4. Verify engine/ folder exists

### Require Errors

**Problem:** `module 'some.module' not found`

**Solutions:**
1. Check package.path setup in main.lua
2. Verify module exists in engine/ folder
3. Check for typos in require() statement
4. Test paths with print(package.path)

### Asset Not Loading

**Problem:** Tool can't find images/sounds

**Solutions:**
1. Verify asset exists in engine/assets/
2. Check file path case sensitivity
3. Use forward slashes (/) in paths
4. Test with asset verification tool first

### Console Not Showing

**Problem:** Console window doesn't appear

**Solutions:**
1. Verify using `lovec.exe` not `love.exe`
2. Check conf.lua has `t.console = true`
3. On non-Windows, console output goes to terminal
4. Use `print()` statements to verify code execution

---

## See Also

- **`wiki/API.md`** - Engine API documentation
- **`wiki/DEVELOPMENT.md`** - Development workflow guide
- **`wiki/MAP_EDITOR_GUIDE.md`** - Map editing guide
- **`wiki/TILESET_SYSTEM.md`** - Tileset format documentation
- **`tests/`** - Test runners and unit tests
- **`tests/mock/`** - Mock data for testing

---

## Future Tools

**Planned additions:**

- **Unit Editor** - Visual editor for unit stats, sprites, and animations
- **Mission Generator** - Procedural mission parameter generator
- **Save Game Editor** - Edit campaign saves for testing
- **Performance Profiler** - Analyze game performance and memory usage
- **Localization Tool** - Manage string translations
- **Mod Packager** - Package mods for distribution
- **TOML Schema Validator** - Validate TOML content files against schema
- **API Endpoint Tester** - Test mod API endpoints and hooks

**Contributing:**
If you create a new tool:
1. Follow the structure above
2. Include comprehensive README
3. Add batch file for easy launch (if Love2D-based)
4. Update this document
5. Document in wiki/DEVELOPMENT.md
6. For non-Love2D tools: Include PowerShell and/or cross-platform Lua version
7. Add cross-reference documentation links using `> **Implementation**: \`path/to/file\``
