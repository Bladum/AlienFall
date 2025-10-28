-- asset_validator.lua
-- Validates that all referenced asset files actually exist
-- Checks: sprite files, audio files, maps, etc.

local AssetValidator = {}

-- Check if file exists
local function fileExists(filePath)
  local file = io.open(filePath, "r")
  if file then
    file:close()
    return true
  end
  return false
end

-- Build full asset path relative to mod directory
local function buildAssetPath(modPath, assetPath)
  if not assetPath then
    return nil
  end
  
  -- If asset path is absolute, try as-is
  if assetPath:match("^/") or assetPath:match("^[A-Z]:") then
    return assetPath
  end
  
  -- Otherwise, relative to mod path
  return modPath .. "/" .. assetPath
end

-- Add error
local function addError(errors, entityId, file, field, asset, message)
  table.insert(errors, {
    entity = entityId,
    file = file,
    field = field,
    asset = asset,
    message = message,
    severity = "error",
  })
end

-- Validate all assets in mod
function AssetValidator.validate(mod, modPath)
  local errors = {}
  
  -- Check all entity types for asset references
  for category, entities in pairs(mod) do
    for entityId, entity in pairs(entities) do
      local assetErrors = AssetValidator.checkEntityAssets(entity, modPath)
      for _, err in ipairs(assetErrors) do
        table.insert(errors, err)
      end
    end
  end
  
  return errors
end

-- Check assets for a single entity
function AssetValidator.checkEntityAssets(entity, modPath)
  local errors = {}
  local data = entity.data
  
  if not data then
    return errors
  end
  
  -- Common asset fields to check
  local assetFields = {
    "sprite",
    "sprite_sheet",
    "image",
    "icon",
    "texture",
    "sound",
    "sound_fire",
    "sound_hit",
    "sound_reload",
    "sound_ambient",
    "music",
    "portrait",
    "tileset_image",
    "map_image",
    "model",
    "animation",
  }
  
  -- Check single asset fields
  for _, fieldName in ipairs(assetFields) do
    if data[fieldName] then
      local assetPath = buildAssetPath(modPath, data[fieldName])
      
      if assetPath and not fileExists(assetPath) then
        addError(errors, data.id or entity.id, entity.file, fieldName, data[fieldName],
          "Referenced asset file does not exist: " .. tostring(data[fieldName]))
      end
    end
  end
  
  -- Check sprite array
  if data.sprites then
    local sprites = type(data.sprites) == "table" and data.sprites or {data.sprites}
    for i, spritePath in ipairs(sprites) do
      local assetPath = buildAssetPath(modPath, spritePath)
      
      if assetPath and not fileExists(assetPath) then
        addError(errors, data.id or entity.id, entity.file, "sprites[" .. i .. "]", spritePath,
          "Referenced sprite file does not exist: " .. tostring(spritePath))
      end
    end
  end
  
  -- Check sounds object/table
  if data.sounds then
    local sounds = data.sounds
    if type(sounds) == "table" then
      for soundType, soundPath in pairs(sounds) do
        if type(soundPath) == "string" then
          local assetPath = buildAssetPath(modPath, soundPath)
          
          if assetPath and not fileExists(assetPath) then
            addError(errors, data.id or entity.id, entity.file, "sounds." .. soundType, soundPath,
              "Referenced sound file does not exist: " .. tostring(soundPath))
          end
        end
      end
    end
  end
  
  -- Check animations array
  if data.animations then
    local animations = type(data.animations) == "table" and data.animations or {data.animations}
    for i, animPath in ipairs(animations) do
      local assetPath = buildAssetPath(modPath, animPath)
      
      if assetPath and not fileExists(assetPath) then
        addError(errors, data.id or entity.id, entity.file, "animations[" .. i .. "]", animPath,
          "Referenced animation file does not exist: " .. tostring(animPath))
      end
    end
  end
  
  -- Check mapblocks array (for tilesets)
  if data.mapblocks then
    local mapblocks = type(data.mapblocks) == "table" and data.mapblocks or {data.mapblocks}
    for i, mapblockPath in ipairs(mapblocks) do
      local assetPath = buildAssetPath(modPath, mapblockPath)
      
      if assetPath and not fileExists(assetPath) then
        addError(errors, data.id or entity.id, entity.file, "mapblocks[" .. i .. "]", mapblockPath,
          "Referenced mapblock file does not exist: " .. tostring(mapblockPath))
      end
    end
  end
  
  -- Check UI assets
  if data.ui then
    local ui = data.ui
    if type(ui) == "table" then
      for uiType, uiPath in pairs(ui) do
        if type(uiPath) == "string" then
          local assetPath = buildAssetPath(modPath, uiPath)
          
          if assetPath and not fileExists(assetPath) then
            addError(errors, data.id or entity.id, entity.file, "ui." .. uiType, uiPath,
              "Referenced UI asset file does not exist: " .. tostring(uiPath))
          end
        end
      end
    end
  end
  
  -- Check fonts
  if data.font then
    local assetPath = buildAssetPath(modPath, data.font)
    
    if assetPath and not fileExists(assetPath) then
      addError(errors, data.id or entity.id, entity.file, "font", data.font,
        "Referenced font file does not exist: " .. tostring(data.font))
    end
  end
  
  return errors
end

-- Get expected asset extensions for a field
local function getExpectedExtensions(fieldName)
  local extensions = {
    sprite = {"png", "jpg", "jpeg"},
    sprite_sheet = {"png", "jpg", "jpeg"},
    image = {"png", "jpg", "jpeg"},
    icon = {"png", "jpg", "jpeg"},
    texture = {"png", "jpg", "jpeg"},
    portrait = {"png", "jpg", "jpeg"},
    tileset_image = {"png", "jpg", "jpeg"},
    map_image = {"png", "jpg", "jpeg"},
    model = {"obj", "fbx", "gltf"},
    animation = {"anim", "lua"},
    sound = {"ogg", "wav", "mp3", "flac"},
    sound_fire = {"ogg", "wav", "mp3", "flac"},
    sound_hit = {"ogg", "wav", "mp3", "flac"},
    sound_reload = {"ogg", "wav", "mp3", "flac"},
    sound_ambient = {"ogg", "wav", "mp3", "flac"},
    music = {"ogg", "wav", "mp3", "flac"},
    font = {"ttf", "otf"},
  }
  return extensions[fieldName] or {}
end

-- Validate file extension matches expected type
function AssetValidator.validateExtension(filePath, fieldName)
  local expectedExts = getExpectedExtensions(fieldName)
  
  if #expectedExts == 0 then
    return true  -- Unknown field, can't validate
  end
  
  local ext = filePath:match("%.([^.]+)$"):lower()
  
  for _, expectedExt in ipairs(expectedExts) do
    if ext == expectedExt:lower() then
      return true
    end
  end
  
  return false
end

return AssetValidator
