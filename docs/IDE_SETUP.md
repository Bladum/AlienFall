# IDE Setup and TOML Support Guide

**Status:** ✅ Complete
**Version:** 1.0.0
**Purpose:** Setup VS Code with TOML validation and autocompletion for mod development

---

## Overview

This guide helps you set up VS Code for comfortable mod development with real-time TOML syntax checking, formatting, and basic validation support.

### What You'll Get

✅ **TOML Syntax Highlighting:** Color-coded TOML files
✅ **TOML Formatting:** Auto-format TOML on save
✅ **Error Detection:** Syntax errors highlighted in red
✅ **Code Navigation:** Jump to definitions, find references
✅ **Lua Support:** Full Lua scripting support for the engine
✅ **Git Integration:** VS Code's built-in Git support
✅ **Task Running:** Run validators and build tasks from VS Code

---

## Installation Steps

### Step 1: Install VS Code

Download and install Visual Studio Code from https://code.visualstudio.com/

### Step 2: Open the Project

```bash
# Navigate to project folder
cd C:\Users\tombl\Documents\Projects

# Open in VS Code
code .
```

### Step 3: Install Recommended Extensions

VS Code will suggest extensions when you open the project. Click "Install" when prompted:

**Automatically Installed:**
- **Even Better TOML** (tamasfe.even-better-toml) - TOML syntax highlighting and formatting
- **Lua** (sumneko.lua) - Lua language support for engine code
- **YAML** (redhat.vscode-yaml) - YAML validation and autocomplete

Or install manually:

1. Open VS Code Extension Marketplace: **Ctrl+Shift+X**
2. Search for each extension name
3. Click "Install"

**Key Extensions:**

| Extension | Publisher | Purpose |
|-----------|-----------|---------|
| Even Better TOML | tamasfe | TOML syntax, formatting, validation |
| Lua | sumneko | Lua language support |
| YAML | redhat | YAML syntax and validation |
| GitLens | eamodio | Git history visualization (optional) |
| REST Client | humao | HTTP request testing (optional) |

### Step 4: Verify Setup

1. Open any TOML file: `mods/core/rules/units/soldier.toml`
2. Check that syntax highlighting works (colored text)
3. Check that formatting works: **Shift+Alt+F** to format
4. Make a typo in a field name - you should see squiggles

---

## TOML File Support

### Syntax Highlighting

Even Better TOML provides:
- Syntax coloring for TOML structure
- Error highlighting for malformed TOML
- Bracket matching

### Auto-Formatting

TOML files are automatically formatted on save:

```toml
# Before save (messy)
id="soldier"
name  =  "Soldier"
health=65

# After save (formatted)
id = "soldier"
name = "Soldier"
health = 65
```

Disable auto-format: Remove or comment out `"editor.formatOnSave": true` in settings.json

### Manual Formatting

Format any file: **Shift+Alt+F** or **Cmd+Shift+P** → **Format Document**

---

## Lua Support

### Features

The Sumneko Lua extension provides:
- Syntax highlighting for Lua code
- Error detection and diagnostics
- Autocomplete suggestions
- Go to definition
- Find references
- Hover documentation

### Configuration

Basic Lua configuration already in `.vscode/settings.json`:

```json
"[lua]": {
  "editor.defaultFormatter": "sumneko.lua"
},
"Lua.diagnostics.globals": [
  "love",      // Love2D framework
  "print",     // Lua built-ins
  "tostring",
  "tonumber"
],
"Lua.runtime.version": "Lua 5.1"
```

### Usage

1. Open any `.lua` file in the `engine/` folder
2. Syntax is highlighted
3. Hover over functions to see documentation
4. **Ctrl+Space** for autocomplete
5. **Ctrl+Click** to jump to definition

---

## Validator Tasks

### Running Validators in VS Code

Validators have VS Code tasks configured. Run them:

1. **Ctrl+Shift+P** to open Command Palette
2. Type "Run Task"
3. Select the validator task

**Available Tasks:**

| Task | Purpose |
|------|---------|
| 🧪 TEST: All Tests | Run all game tests |
| 🧪 Submodule: Battlescape Tests | Run battlescape tests |
| 🧪 Submodule: Unit Tests | Run unit tests |
| 🎮 RUN: Game with Debug Console | Run the game with debugging |
| 🎮 RUN: Game (Release - No Debug) | Run optimized game |

**Or run from terminal:**

```bash
# API validation (structure checking)
lovec tools/validators/validate_mod.lua mods/core --verbose

# Content validation (reference checking)
lovec tools/validators/validate_content.lua mods/core --verbose

# Run game tests
lovec tests/runners

# Run specific test category
lovec tests/runners battlescape
```

---

## Keyboard Shortcuts

### Editing

| Shortcut | Action |
|----------|--------|
| **Ctrl+Z** | Undo |
| **Ctrl+Y** | Redo |
| **Ctrl+X** | Cut line |
| **Ctrl+C** | Copy line |
| **Ctrl+V** | Paste |
| **Ctrl+Shift+K** | Delete line |
| **Ctrl+/** | Toggle comment |
| **Ctrl+Shift+/** | Block comment |
| **Shift+Alt+Up/Down** | Copy line up/down |

### Navigation

| Shortcut | Action |
|----------|--------|
| **Ctrl+P** | Quick file open |
| **Ctrl+Shift+P** | Command palette |
| **Ctrl+G** | Go to line |
| **Ctrl+F** | Find |
| **Ctrl+H** | Find and replace |
| **Ctrl+Shift+F** | Find in files |
| **Ctrl+K Ctrl+0** | Fold all |
| **Ctrl+K Ctrl+J** | Unfold all |

### Code

| Shortcut | Action |
|----------|--------|
| **Ctrl+Space** | Autocomplete |
| **Ctrl+Shift+Space** | Parameter hints |
| **F12** | Go to definition |
| **Shift+F12** | Go to references |
| **Ctrl+Shift+L** | Select all occurrences |
| **Shift+Alt+F** | Format document |

### Debugging

| Shortcut | Action |
|----------|--------|
| **F5** | Start debugging |
| **F6** | Pause |
| **Ctrl+Shift+D** | Debug view |
| **Shift+Ctrl+P** > "Run Task" | Run validator tasks |

---

## File Organization in VS Code

### Explorer View

The folder structure in Explorer (left panel):

```
📁 Projects
├── 📁 .vscode
│   ├── settings.json          ← Your IDE settings
│   ├── extensions.json        ← Recommended extensions
│   └── tasks.json             ← Validator tasks
├── 📁 api                      ← API documentation
├── 📁 architecture             ← Architecture docs
├── 📁 design                   ← Design docs
├── 📁 docs                     ← Code docs
├── 📁 engine                   ← Main game engine
│   ├── conf.lua
│   ├── main.lua
│   ├── battlescape/
│   ├── geoscape/
│   └── ...
├── 📁 lore                     ← Story content
├── 📁 mods                     ← Game mods
│   └── core/                   ← Main mod
│       ├── mod.toml
│       └── rules/
│           ├── units/         ← 👈 TOML files here
│           ├── items/
│           ├── research/
│           └── ...
├── 📁 tasks                    ← Task tracking
├── 📁 temp                     ← Temporary files
├── 📁 tests                    ← Test files
├── 📁 tools                    ← Developer tools
│   └── validators/            ← Validator scripts
└── README.md
```

### Useful Tips

**Filter files in Explorer:**
- Click filter icon in Explorer title bar
- Type filename pattern to hide files

**Collapse/Expand folders:**
- Click folder arrow or press arrow key

**Open file in side-by-side editor:**
- Hold Ctrl and click file (or Ctrl+click folder)

---

## Common Workflows

### Workflow 1: Edit Mod File and Validate

1. Open mod file: `mods/core/rules/units/soldier.toml`
2. Edit the file (syntax errors highlighted in real-time)
3. Save file (**Ctrl+S**)
4. File auto-formats
5. Run validator: **Ctrl+Shift+P** → "VALIDATE: Content - Core Mod"
6. Check output in terminal

### Workflow 2: Run Game and Debug

1. Press **F5** to open Run/Debug view
2. Select "Run Game with Debug Console"
3. Game starts in new terminal
4. Check console output for errors
5. Edit engine code and press **Ctrl+Shift+P** → "Run Task" → select task

### Workflow 3: Find References Across Files

1. Open a file that references something
2. **Ctrl+Click** on entity ID (or **F12**)
3. Jumps to definition file
4. **Shift+F12** to find all references
5. Click results to jump to each reference

### Workflow 4: Search Codebase

1. **Ctrl+Shift+F** to open Find in Files
2. Type search term (e.g., "laser_rifle")
3. Results show all files containing term
4. Click result to open that location
5. Use regex pattern for advanced searches

---

## Troubleshooting

### TOML Formatting Not Working

**Problem:** Files aren't auto-formatted on save.

**Fix:**
1. Check `evenBetterToml` extension is installed
2. Verify settings.json has `"editor.formatOnSave": true`
3. Check TOML syntax is valid (errors prevent formatting)
4. Try manual format: **Shift+Alt+F**

### Extension Errors

**Problem:** Extension shows error in VS Code.

**Fix:**
1. Open Extension Settings: **Ctrl+Shift+X** → click extension → Settings
2. Check for configuration errors
3. Try reloading: **Ctrl+Shift+P** → "Reload Window"
4. Reinstall if still broken: Uninstall → Reinstall

### Tasks Not Working

**Problem:** Tasks don't show in "Run Task" list.

**Fix:**
1. Check `.vscode/tasks.json` exists
2. Verify tasks.json syntax is valid (use validate_mod.lua to check)
3. Restart VS Code: **Ctrl+Shift+P** → "Reload Window"
4. Check Love2D path is correct in tasks

### Lua Diagnostics Too Strict

**Problem:** Lua extension shows false error on valid code.

**Fix:**
1. Add to settings.json under `Lua.diagnostics`:
   ```json
   "Lua.diagnostics.undefined": false,
   "Lua.diagnostics.unused-local": false
   ```
2. Or mark as global: `---@diagnostic disable`

### Terminal Issues

**Problem:** Terminal not showing output.

**Fix:**
1. Check terminal is visible: **Ctrl+Backtick** to toggle
2. Try new terminal: **Ctrl+Shift+Backtick**
3. Check correct working directory: type `pwd` to see path
4. Try running command directly in terminal

---

## Performance Tips

### Speed Up VS Code

1. **Disable unnecessary extensions:** Extensions → disable unused ones
2. **Clear search cache:** **Ctrl+Shift+P** → "Clear Find State"
3. **Reduce file watching:** Add to settings.json:
   ```json
   "files.watcherExclude": {
     "**/node_modules": true,
     "**/dist": true,
     "temp/**": true
   }
   ```

### Faster Testing

Run only relevant tests instead of all:

```bash
# Instead of all tests
lovec tests/runners

# Run specific category (faster)
lovec tests/runners battlescape

# Measure time
Measure-Command { lovec tests/runners battlescape }
```

---

## Advanced Configuration

### Custom Key Bindings

Edit `.vscode/keybindings.json`:

```json
[
  {
    "key": "ctrl+alt+v",
    "command": "workbench.action.tasks.runTask",
    "args": "🔍 VALIDATE: Content - Core Mod"
  }
]
```

Now **Ctrl+Alt+V** runs the validator.

### Custom Snippets

Create `.vscode/alienfall-toml.code-snippets`:

```json
{
  "New Unit": {
    "prefix": "unit",
    "body": [
      "id = \"${1:unit_id}\"",
      "name = \"${2:Unit Name}\"",
      "type = \"${3|soldier,alien,civilian|}\"",
      "health = ${4:65}",
      "$0"
    ]
  }
}
```

Type `unit` and press **Tab** to insert snippet.

---

## Resources

- **VS Code Docs:** https://code.visualstudio.com/docs/
- **Lua Extension Docs:** https://github.com/LuaLS/lua-language-server/wiki
- **TOML Spec:** https://toml.io/
- **Project Docs:** See `api/` and `docs/` folders

---

## Quick Reference

**File Management:**
- **Ctrl+P** - Quick open file
- **Ctrl+N** - New file
- **Ctrl+W** - Close file
- **Ctrl+Tab** - Switch between open files

**Editing:**
- **Shift+Alt+F** - Format document
- **Ctrl+/** - Toggle comment
- **Ctrl+D** - Select next occurrence
- **Ctrl+Shift+L** - Select all occurrences

**Search:**
- **Ctrl+F** - Find
- **Ctrl+H** - Find and replace
- **Ctrl+Shift+F** - Find in all files
- **Ctrl+G** - Go to line

**Running:**
- **Ctrl+Shift+P** - Command palette (run tasks, etc.)
- **F5** - Start debugging
- **Ctrl+Backtick** - Show/hide terminal

---

## Next Steps

1. ✅ Install VS Code and extensions
2. ✅ Open the project: `code .`
3. ✅ Open a TOML file: `mods/core/rules/units/soldier.toml`
4. ✅ Verify syntax highlighting works
5. ✅ Run a validator: **Ctrl+Shift+P** → "Run Task"
6. ✅ Try editing and saving (auto-format should work)
7. ✅ Explore code with **F12** (go to definition)

Happy mod developing! 🎮
