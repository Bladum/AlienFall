# AlienFall Development Setup - Windows

**Audience**: Developers | **Status**: Active | **Last Updated**: October 2025

Complete step-by-step guide to set up AlienFall development environment on Windows 10/11.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Step 1: Install Love2D](#step-1-install-love2d)
- [Step 2: Install Git](#step-2-install-git)
- [Step 3: Install VS Code](#step-3-install-vs-code)
- [Step 4: Clone Repository](#step-4-clone-repository)
- [Step 5: Configure VS Code](#step-5-configure-vs-code)
- [Step 6: Verify Installation](#step-6-verify-installation)
- [Troubleshooting](#troubleshooting)
- [Next Steps](#next-steps)

---

## Prerequisites

**System Requirements:**
- Windows 10 or Windows 11
- 4GB RAM minimum (8GB recommended)
- 2GB disk space for engine + dependencies
- Administrator access for software installation

**Estimated Time**: 30-45 minutes

---

## Step 1: Install Love2D

Love2D is the game framework that powers AlienFall.

### 1.1: Download Love2D

1. Visit https://love2d.org
2. Click **Download** in the top navigation
3. Select **Windows** → **64-bit** (recommended for modern systems)
4. Save `love-12.0-win64.zip` (or latest version)

### 1.2: Install Love2D

1. Extract the ZIP file to `C:\Program Files\LOVE`
   - Create the LOVE directory if it doesn't exist
   - You should have these files:
     ```
     C:\Program Files\LOVE\
     ├── love.exe
     ├── lovec.exe
     ├── loverc.exe
     └── [other files]
     ```

### 1.3: Add Love2D to PATH

1. Press `Win + X` and select **System**
2. Click **Advanced system settings**
3. Click **Environment Variables** button
4. Under "User variables" click **New**
5. Variable name: `Path`
6. Variable value: `C:\Program Files\LOVE`
7. Click **OK** three times
8. **Close and reopen** any open terminals for changes to take effect

### 1.4: Verify Love2D Installation

Open PowerShell and run:

```powershell
lovec --version
```

You should see output like:
```
LÖVE 12.0 (Fantastic Fajita)
```

---

## Step 2: Install Git

Git is required for version control and cloning the repository.

### 2.1: Download Git

1. Visit https://git-scm.com/download/win
2. Click **64-bit Git for Windows Setup**
3. Run the installer once downloaded

### 2.2: Configure Git Installer

During installation, use these settings:
- **Destination Location**: Default (`C:\Program Files\Git`)
- **Select Components**: Keep defaults (check "Git Bash Here" and "Git GUI Here")
- **Default Editor**: Select "Use Visual Studio Code as Git's default editor"
- **Initial Branch Name**: Select "Let Git decide"
- **PATH Environment**: Select "Git from the command line and also from 3rd-party software"
- **SSH Executable**: Use bundled OpenSSH
- **HTTPS transport backend**: Use native Windows Secure Channel library
- **Line ending conversion**: Select "Checkout as-is, commit as-is"
- **Terminal emulator**: Select "Use Windows' default console window"
- **Git pull behavior**: Select "Fast-forward or merge"
- **Credential manager**: Select "Git Credential Manager"
- **Other options**: Enable file caching and symbolic links

### 2.3: Verify Git Installation

Open PowerShell and run:

```powershell
git --version
```

You should see output like:
```
git version 2.42.0.windows.1
```

---

## Step 3: Install VS Code

VS Code is the recommended editor with excellent Lua support.

### 3.1: Download VS Code

1. Visit https://code.visualstudio.com
2. Click **Download for Windows**
3. Run the installer once downloaded

### 3.2: Install VS Code

- Use defaults during installation
- **Important**: Check "Add to PATH" during installation
- Check "Add Explorer context menu" for convenience

### 3.3: Verify VS Code Installation

Open PowerShell and run:

```powershell
code --version
```

You should see version output.

---

## Step 4: Clone Repository

### 4.1: Choose Location

Create a development folder. **Recommended location**:

```powershell
cd ~
mkdir Projects\AlienFall -Force
cd Projects\AlienFall
```

Or use any location you prefer (examples below use `C:\Dev`):

```powershell
mkdir C:\Dev
cd C:\Dev
```

### 4.2: Clone the Repository

If you have access to the GitHub repository:

```powershell
git clone https://github.com/YourOrg/AlienFall.git
cd AlienFall
```

Or if you have a local copy, copy the folder to your development location.

### 4.3: Verify Repository Structure

After cloning, verify the essential files exist:

```powershell
# Check folder structure
ls -Recurse | Select-Object FullName | head -20

# Should show:
# - engine\main.lua
# - engine\conf.lua
# - README.md
```

---

## Step 5: Configure VS Code

### 5.1: Open Project in VS Code

```powershell
code .
```

VS Code should launch and open the current folder.

### 5.2: Install Recommended Extensions

VS Code should suggest extensions for Lua and other tools. Accept installations or manually install:

**Essential Extensions:**

1. **Lua** (sumneko) - `sumneko.lua`
   - Provides Lua intellisense and diagnostics
   - Press `Ctrl+Shift+X` to open Extensions
   - Search "Lua" → Install by "sumneko"

2. **Love2D Support** (pixelbyte-studios) - `pixelbyte-studios.pixelbyte-love2d`
   - Love2D API documentation and snippets

3. **Git Graph** (mhutchie) - `mhutchie.git-graph`
   - Visual git history browser

**Optional but Useful:**

- **Error Lens** (usernamehw) - Shows inline errors
- **Thunder Client** - API testing
- **Markdown Preview Enhanced** - Better markdown preview

### 5.3: Configure Lua Extension

1. Open VS Code **Settings** (`Ctrl+,`)
2. Search "lua.runtime.version"
3. Set to "Lua 5.1" (Love2D uses Lua 5.1)
4. Search "lua.diagnostics.enable"
5. Ensure enabled for error checking

### 5.4: Configure Workspace

VS Code should auto-detect the project. If needed:

1. Create `.vscode/settings.json` in project root:

```json
{
    "lua.runtime.version": "Lua 5.1",
    "lua.workspace.library": [
        "${3rd}/love2d/library"
    ],
    "lua.diagnostics.disable": [
        "lowercase-global"
    ],
    "[lua]": {
        "editor.defaultFormatter": "sumneko.lua",
        "editor.formatOnSave": true,
        "editor.tabSize": 4,
        "editor.insertSpaces": true
    }
}
```

---

## Step 6: Verify Installation

### 6.1: Run the Game

Navigate to project directory and run:

```powershell
lovec "engine"
```

You should see:
- A console window opens with debug output
- A game window launches showing AlienFall
- No errors in console output

**If this works, congratulations! Setup is complete.**

### 6.2: Test Debug Console

The console should show initialization messages like:

```
[Core] Engine initializing...
[AssetManager] Loading assets...
[StateManager] Initial state loaded...
[Game] Ready for play
```

### 6.3: Test Development Workflow

1. Open `engine/main.lua` in VS Code
2. Modify a print statement (just for testing)
3. Save the file
4. Restart the game with `lovec "engine"`
5. Verify your change appears in console

---

## Troubleshooting

### "lovec command not found"

**Problem**: PowerShell doesn't recognize `lovec` command

**Solutions**:
1. Verify Love2D is installed: Check `C:\Program Files\LOVE\lovec.exe` exists
2. Add to PATH: Follow Step 1.3 again
3. Restart terminals: Close all PowerShell windows and reopen
4. Use full path: `"C:\Program Files\LOVE\lovec.exe" "engine"`

### "Module not found" errors in console

**Problem**: Engine fails to load modules

**Solutions**:
1. Verify directory structure: `engine/`, `engine/core/`, etc. must exist
2. Check file paths are correct in module requires
3. Ensure no circular dependencies
4. Review console output for specific module names

### "LÖVE window won't open"

**Problem**: Love2D starts but no window appears

**Solutions**:
1. Check console output for errors
2. Verify `engine/conf.lua` exists and is valid Lua
3. Try a simpler test: Create `test_love.lua`:
   ```lua
   function love.draw()
       love.graphics.print("Hello!", 100, 100)
   end
   ```
   Then run: `lovec` in that folder
4. Check graphics drivers are up-to-date

### "Git clone fails"

**Problem**: GitHub access denied or network error

**Solutions**:
1. Check internet connection
2. Configure Git credentials:
   ```powershell
   git config --global user.name "Your Name"
   git config --global user.email "your@email.com"
   ```
3. Generate SSH keys (recommended for GitHub):
   ```powershell
   ssh-keygen -t ed25519 -C "your@email.com"
   ```
   Then add public key to GitHub settings
4. Try HTTPS first, switch to SSH later

### "VS Code intellisense not working"

**Problem**: Lua language server not providing suggestions

**Solutions**:
1. Verify sumneko Lua extension installed: `Ctrl+Shift+X` → search "Lua"
2. Reload window: `Ctrl+Shift+P` → "Developer: Reload Window"
3. Check workspace settings in `.vscode/settings.json`
4. Verify `lua.runtime.version` is "Lua 5.1"
5. Restart VS Code

### High CPU or memory usage

**Problem**: Game runs but console/editor is slow

**Solutions**:
1. Reduce console output in code (comment debug prints)
2. Check for infinite loops in game logic
3. Profile memory: See [Debugging Guide](DEBUGGING.md)
4. Close other applications
5. Update graphics drivers

### "Permission denied" errors

**Problem**: Cannot write to project directory or install software

**Solutions**:
1. Run PowerShell as Administrator
2. Verify anti-virus isn't blocking operations
3. Check folder permissions: Right-click folder → Properties → Security
4. Temporarily disable anti-virus (or add project to whitelist)

---

## Post-Setup: Next Steps

**You're now ready to develop!** Here's what to do next:

1. **Learn the Architecture**: Read [System Architecture](../architecture/SYSTEM_INTERACTION.md)
2. **Understand Code Organization**: Read [Project Structure](../../wiki/PROJECT_STRUCTURE.md)
3. **Review Code Standards**: Read [Code Standards](../CODE_STANDARDS.md)
4. **Debug Effectively**: Read [Debugging Guide](DEBUGGING.md)
5. **Start Contributing**: Pick a task or feature to work on

### First Development Task

Try this starter task to verify everything works:

1. Open `engine/main.lua` in VS Code
2. Find the `love.draw()` function
3. Add a debug line:
   ```lua
   love.graphics.print("Development Setup Complete!", 50, 50)
   ```
4. Save and run: `lovec "engine"`
5. Verify the text appears on screen

**If you see your text, your development environment is fully functional!**

---

## Getting Help

If you encounter issues:

1. **Check Troubleshooting** section above (this document)
2. **Read Debugging Guide**: [DEBUGGING.md](DEBUGGING.md)
3. **Search Documentation**: Use [Navigation Guide](../NAVIGATION.md)
4. **Check Project Issues**: GitHub Issues for known problems
5. **Ask in Community**: Join Discord or project discussions

---

## Related Documentation

- **[Workflow Guide](WORKFLOW.md)** - Git and development workflow
- **[Debugging Guide](DEBUGGING.md)** - Debugging techniques and Love2D console
- **[Troubleshooting](TROUBLESHOOTING.md)** - More detailed troubleshooting
- **[Setup Guides](../NAVIGATION.md#developer-documentation)** - Linux/Mac setup
- **[Code Standards](../CODE_STANDARDS.md)** - Coding conventions

---

**Last Updated**: October 2025 | **Status**: Active | **Difficulty**: Beginner

