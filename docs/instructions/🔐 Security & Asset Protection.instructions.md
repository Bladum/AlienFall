# 🔐 Security & Asset Protection Best Practices

**Domain:** Security & IP Protection  
**Focus:** Mod sandboxing, asset encryption, piracy prevention, secure configuration  
**Version:** 1.0  
**Date:** October 2025

## Overview

This guide covers protecting game assets, implementing secure mod systems, and preventing unauthorized modifications.

## Asset Protection

### ✅ DO: Encrypt Critical Game Data

```lua
-- Simple XOR encryption for casual protection
function xorEncrypt(data, key)
    local encrypted = {}
    for i = 1, #data do
        table.insert(encrypted, string.byte(data, i) ~ string.byte(key, ((i - 1) % #key) + 1))
    end
    return string.char(unpack(encrypted))
end

-- For critical data like DRM tokens
function encryptAssetManifest(manifest, secretKey)
    local json = jsonEncode(manifest)
    local encrypted = xorEncrypt(json, secretKey)
    love.filesystem.write("assets/manifest.enc", encrypted)
end
```

---

### ✅ DO: Sandbox Mod Execution

```lua
function executeModInSandbox(modCode, modName)
    local env = {
        -- Provide safe subset of functions
        print = print,
        table = table,
        string = string,
        math = math,
        
        -- API functions mod can call
        registerUnit = registerUnitSafely,
        registerWeapon = registerWeaponSafely,
        
        -- Block dangerous functions
        os = nil,  -- No filesystem access
        io = nil,  -- No file I/O
        load = nil,
        loadstring = nil,
        debug = nil
    }
    
    -- Execute mod code in sandboxed environment
    local modFunction = load(modCode, modName, "t", env)
    if modFunction then
        local success, result = pcall(modFunction)
        if not success then
            print("[MOD ERROR] " .. modName .. ": " .. result)
            return false
        end
        return true
    end
    
    return false
end
```

---

### ✅ DO: Implement Asset Manifest Checking

```lua
-- Generate manifest on build
function generateAssetManifest()
    local manifest = {}
    local assets = getFileList("assets/")
    
    for _, file in ipairs(assets) do
        local path = "assets/" .. file
        local content = love.filesystem.read(path)
        
        -- SHA256 hash for integrity checking
        manifest[file] = {
            size = #content,
            hash = sha256(content),
            modified = os.time()
        }
    end
    
    return manifest
end

-- Verify assets haven't been modified
function verifyAssets()
    local manifest = loadJSON("assets/manifest.json")
    
    for file, expected in pairs(manifest) do
        local path = "assets/" .. file
        local content = love.filesystem.read(path)
        
        if sha256(content) ~= expected.hash then
            print("[SECURITY] Asset modified: " .. file)
            return false
        end
    end
    
    return true
end
```

---

## Practical Implementation

### ✅ DO: Validate Configuration Files

```lua
function loadGameConfig(filePath)
    local config = loadJSON(filePath)
    
    -- Whitelist allowed settings
    local allowedKeys = {
        difficulty = true,
        language = true,
        graphics_quality = true,
        volume = true
    }
    
    -- Sanitize config
    for key in pairs(config) do
        if not allowedKeys[key] then
            print("[CONFIG] Removing unknown key: " .. key)
            config[key] = nil
        end
    end
    
    -- Validate ranges
    if config.difficulty then
        config.difficulty = math.max(1, math.min(3, config.difficulty))
    end
    
    return config
end
```

---

### ✅ DO: Log Security Events

```lua
function logSecurityEvent(eventType, details)
    local logEntry = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        event_type = eventType,
        details = details,
        checksum = generateChecksum(details)
    }
    
    -- Append to security log
    local logPath = love.filesystem.getSaveDirectory() .. "/security.log"
    local content = love.filesystem.read(logPath) or ""
    content = content .. jsonEncode(logEntry) .. "\n"
    love.filesystem.write(logPath, content)
end

logSecurityEvent("ASSET_VERIFY_FAILED", "mission_map_001.lua")
logSecurityEvent("MOD_SANDBOX_VIOLATION", "unsafe_mod.lua attempted os.execute()")
```

---

### ❌ DON'T: Trust Mods Without Verification

```lua
-- BAD: Direct execution of mod code
function loadModBad(modPath)
    local code = love.filesystem.read(modPath)
    local func = load(code)  -- No sandbox!
    func()  -- Could do anything
end

-- GOOD: Sandboxed with verification
function loadModGood(modPath)
    -- First check mod signature
    if not verifyModSignature(modPath) then
        print("Mod not signed")
        return false
    end
    
    -- Then execute in sandbox
    return executeModInSandbox(modPath, "trusted_mod")
end
```

---

### ❌ DON'T: Store Sensitive Keys in Plain Text

```lua
-- BAD: API key in config
local config = {
    api_key = "super_secret_key_123"  -- VISIBLE
}

-- GOOD: Load from environment or encrypted storage
local apiKey = os.getenv("GAME_API_KEY")  -- From system env
if not apiKey then
    -- Or load encrypted from secure storage
    apiKey = decryptApiKey()
end
```

---

## Common Patterns & Checklist

- [x] Encrypt critical game data (manifests, tokens)
- [x] Implement mod sandboxing
- [x] Generate and verify asset manifests
- [x] Whitelist allowed configuration keys
- [x] Validate all config value ranges
- [x] Log security events with timestamps
- [x] Verify mod signatures before execution
- [x] Never store secrets in plain text
- [x] Disable dangerous Lua functions in mods
- [x] Test security measures regularly

---

## References

- SHA256 Hashing: https://en.wikipedia.org/wiki/SHA-2
- Lua Sandboxing: https://www.lua.org/
- XOR Encryption: https://en.wikipedia.org/wiki/XOR_cipher

