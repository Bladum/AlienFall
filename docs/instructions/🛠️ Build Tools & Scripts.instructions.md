# 🛠️ Build Tools & Scripts Best Practices

**Domain:** Build Automation & Development Tools  
**Focus:** Build scripts, automation, CI/CD integration, task runners, development utilities  
**Version:** 1.0  
**Date:** October 2025

## Overview

This guide covers creating build automation, development tools, and CI/CD pipelines for efficient game development.

## Build Scripts

### ✅ DO: Create Cross-Platform Build Script

```batch
@echo off
REM build.bat - Cross-platform build automation

setlocal enabledelayedexpansion

set BUILD_DIR=build
set ENGINE_DIR=engine
set VERSION=1.2.3
set PLATFORM=%1

if "%PLATFORM%"=="" (
    echo Usage: build.bat [windows^|linux^|macos]
    exit /b 1
)

echo [BUILD] Starting build for %PLATFORM% v%VERSION%

REM Create build directory
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%BUILD_DIR%\%PLATFORM%" mkdir "%BUILD_DIR%\%PLATFORM%"

REM Run tests before build
echo [BUILD] Running tests...
call run_tests.bat
if errorlevel 1 (
    echo [ERROR] Tests failed, aborting build
    exit /b 1
)

REM Validate assets
echo [BUILD] Validating assets...
lua.exe tools\validate_assets.lua
if errorlevel 1 (
    echo [ERROR] Asset validation failed
    exit /b 1
)

REM Copy engine files
echo [BUILD] Copying engine files...
xcopy "%ENGINE_DIR%" "%BUILD_DIR%\%PLATFORM%\engine" /E /I /Y

REM Package for platform
call:package_%PLATFORM% "%BUILD_DIR%\%PLATFORM%"

echo [BUILD] Build complete: %BUILD_DIR%\%PLATFORM%

goto:eof

:package_windows
echo [BUILD] Packaging for Windows...
cd %1
"C:\Program Files\LOVE\lovec.exe" --fused . alienfall.exe
exit /b 0

:package_linux
echo [BUILD] Packaging for Linux...
exit /b 0

:package_macos
echo [BUILD] Packaging for macOS...
exit /b 0
```

---

### ✅ DO: Create Lua Build Runner

```lua
-- build.lua
local Build = {}

function Build:new()
    return setmetatable({
        startTime = os.time(),
        tasks = {},
        failed = false
    }, {__index = Build})
end

function Build:addTask(name, fn)
    table.insert(self.tasks, {name = name, fn = fn})
end

function Build:run()
    print("[BUILD] Starting build with " .. #self.tasks .. " tasks")
    
    for i, task in ipairs(self.tasks) do
        print("[BUILD] Task " .. i .. "/" .. #self.tasks .. ": " .. task.name)
        
        local success, err = pcall(task.fn)
        if not success then
            print("[ERROR] " .. task.name .. " failed: " .. err)
            self.failed = true
            break
        end
    end
    
    local elapsed = os.time() - self.startTime
    if self.failed then
        print("[BUILD] Build failed after " .. elapsed .. "s")
        return false
    else
        print("[BUILD] Build succeeded in " .. elapsed .. "s")
        return true
    end
end

-- Usage
local build = Build:new()

build:addTask("Validate syntax", function()
    print("  Checking Lua syntax...")
    -- Validate all .lua files
end)

build:addTask("Run tests", function()
    print("  Running unit tests...")
    -- Execute test suite
end)

build:addTask("Build package", function()
    print("  Creating distribution package...")
    -- Package game
end)

return build:run()
```

---

## Development Tools

### ✅ DO: Create Asset Verification Tool

```lua
-- tools/validate_assets.lua
local Validator = {}

function Validator:new()
    return setmetatable({
        errors = {},
        warnings = {}
    }, {__index = Validator})
end

function Validator:checkAssetExists(path)
    if not love.filesystem.getInfo(path) then
        table.insert(self.errors, "Missing asset: " .. path)
        return false
    end
    return true
end

function Validator:checkImageDimensions(path, expectedWidth, expectedHeight)
    local success, image = pcall(love.graphics.newImage, path)
    if not success then
        table.insert(self.errors, "Invalid image: " .. path)
        return false
    end
    
    local w, h = image:getDimensions()
    if w ~= expectedWidth or h ~= expectedHeight then
        table.insert(self.warnings, string.format(
            "Image dimensions mismatch: %s (expected %dx%d, got %dx%d)",
            path, expectedWidth, expectedHeight, w, h
        ))
    end
    
    return true
end

function Validator:run()
    -- Validate critical assets
    self:checkAssetExists("assets/sprites/units/soldier.png")
    self:checkAssetExists("engine/conf.lua")
    self:checkAssetExists("engine/main.lua")
    
    if #self.errors > 0 then
        print("[VALIDATOR] Errors found:")
        for _, err in ipairs(self.errors) do
            print("  ERROR: " .. err)
        end
        return false
    end
    
    if #self.warnings > 0 then
        print("[VALIDATOR] Warnings:")
        for _, warn in ipairs(self.warnings) do
            print("  WARNING: " .. warn)
        end
    end
    
    print("[VALIDATOR] All critical assets validated")
    return true
end

return Validator:new():run()
```

---

## Practical Implementation

### ✅ DO: Create Development Server Script

```batch
@echo off
REM dev_server.bat - Start development environment

setlocal enabledelayedexpansion

set LOVE_EXE="C:\Program Files\LOVE\lovec.exe"
set ENGINE_DIR=engine

echo [DEV] Starting development environment...
echo [DEV] Game will launch with console enabled

REM Watch for changes and auto-restart (optional)
:loop
echo [DEV] Launching game...
%LOVE_EXE% %ENGINE_DIR%

echo [DEV] Game exited

REM Auto-restart on exit? Uncomment to enable:
REM goto loop

echo [DEV] Development session ended
```

---

### ✅ DO: Create Documentation Generator

```lua
-- tools/generate_docs.lua
local DocGenerator = {}

function DocGenerator:new()
    return setmetatable({
        output = "",
        functions = {}
    }, {__index = DocGenerator})
end

function DocGenerator:extractDocstrings(filePath)
    local content = love.filesystem.read(filePath)
    
    -- Extract LuaDoc comments
    for docstring, funcName, params in content:gmatch("%-%-%-%-(.-)function%s+([%w_]+)%s*%(([^)]*)%)") do
        table.insert(self.functions, {
            name = funcName,
            params = params,
            doc = docstring
        })
    end
end

function DocGenerator:generate()
    self.output = "# API Documentation\n\n"
    
    for _, func in ipairs(self.functions) do
        self.output = self.output .. "## " .. func.name .. "\n"
        self.output = self.output .. func.doc .. "\n"
        self.output = self.output .. "**Parameters:** " .. func.params .. "\n\n"
    end
    
    return self.output
end

function DocGenerator:write(outputPath)
    love.filesystem.write(outputPath, self:generate())
    print("[DOCS] Generated documentation: " .. outputPath)
end

-- Usage
local gen = DocGenerator:new()
gen:extractDocstrings("engine/core/state_manager.lua")
gen:write("docs/API_GENERATED.md")
```

---

### ✅ DO: Create Performance Profiler

```lua
-- tools/profiler.lua
local Profiler = {}
Profiler.data = {}

function Profiler:start(name)
    if not self.data[name] then
        self.data[name] = {calls = 0, totalTime = 0, minTime = math.huge, maxTime = 0}
    end
    
    self.data[name].startTime = love.timer.getTime()
end

function Profiler:stop(name)
    if not self.data[name] or not self.data[name].startTime then return end
    
    local elapsed = love.timer.getTime() - self.data[name].startTime
    
    self.data[name].calls = self.data[name].calls + 1
    self.data[name].totalTime = self.data[name].totalTime + elapsed
    self.data[name].minTime = math.min(self.data[name].minTime, elapsed)
    self.data[name].maxTime = math.max(self.data[name].maxTime, elapsed)
end

function Profiler:report()
    print("\n[PROFILER] Performance Report")
    print("=" .. string.rep("=", 70))
    
    for name, data in pairs(self.data) do
        local avgTime = data.totalTime / data.calls
        print(string.format("%s: %d calls, avg %.3fms, min %.3fms, max %.3fms",
            name, data.calls, avgTime * 1000, data.minTime * 1000, data.maxTime * 1000))
    end
end

-- Usage
Profiler:start("update")
-- ... game logic ...
Profiler:stop("update")

Profiler:start("render")
-- ... rendering ...
Profiler:stop("render")

Profiler:report()
```

---

### ❌ DON'T: Hardcode Paths in Build Scripts

```batch
REM BAD: Hardcoded paths
set LOVE_EXE=C:\Users\Tom\LOVE\lovec.exe
set BUILD_DIR=C:\Games\AlienFall\build

REM GOOD: Use environment variables
set LOVE_EXE=%LOVE_HOME%\lovec.exe
set BUILD_DIR=%CD%\build
```

---

### ❌ DON'T: Create Build Artifacts in Source Directory

```batch
REM BAD: Creates clutter in source
copy engine\*.lua build\
REM Leaves temporary files in engine\

REM GOOD: Keep source clean
mkdir build_temp
copy engine\*.lua build_temp\
del engine\*.bak
```

---

## Common Patterns & Checklist

- [x] Create cross-platform build scripts
- [x] Automate testing before build
- [x] Validate assets during build
- [x] Create asset verification tools
- [x] Generate documentation automatically
- [x] Implement performance profiling
- [x] Create development server scripts
- [x] Use environment variables
- [x] Keep build artifacts separate
- [x] Document build process

---

## References

- GNU Make: https://www.gnu.org/software/make/
- Lua: https://www.lua.org/
- GitHub Actions: https://github.com/features/actions

