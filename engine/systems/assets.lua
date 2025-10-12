-- Asset Loader
-- Loads all images from mod assets folder into a dictionary
-- Structure: assets[folder][filename] = image

local ModManager = require("systems.mod_manager")

local Assets = {}

-- Load all images
function Assets.load()
    Assets.images = {}
    
    -- Get assets path from active mod
    local imagesPath = ModManager.getContentPath("assets")
    if not imagesPath then
        print("[Assets] ERROR: Could not get assets path from mod")
        return
    end
    
    local items = love.filesystem.getDirectoryItems(imagesPath)
    
    for _, folder in ipairs(items) do
        local folderPath = imagesPath .. "/" .. folder
        local info = love.filesystem.getInfo(folderPath)
        if info and info.type == "directory" then
            Assets.images[folder] = {}
            
            -- Get all files in folder
            local files = love.filesystem.getDirectoryItems(folderPath)
            for _, file in ipairs(files) do
                -- Check if it's a png file
                if file:match("%.png$") then
                    local imageName = file:gsub("%.png$", "") -- Remove extension
                    local imagePath = folderPath .. "/" .. file
                    local success, image = pcall(love.graphics.newImage, imagePath)
                    if success then
                        -- Check if image is larger than 24x24 (tile variations)
                        local width, height = image:getDimensions()
                        if width > 24 or height > 24 then
                            -- Split into 24x24 tiles
                            local tiles = {}
                            local tilesX = math.floor(width / 24)
                            local tilesY = math.floor(height / 24)
                            
                            for y = 0, tilesY - 1 do
                                for x = 0, tilesX - 1 do
                                    local quad = love.graphics.newQuad(x * 24, y * 24, 24, 24, width, height)
                                    table.insert(tiles, quad)
                                end
                            end
                            
                            Assets.images[folder][imageName] = {
                                image = image,
                                quads = tiles,
                                isTileVariation = true
                            }
                            print("[Assets] Loaded tile variations: " .. folder .. "/" .. imageName .. " (" .. #tiles .. " tiles)")
                        else
                            -- Single tile
                            Assets.images[folder][imageName] = {
                                image = image,
                                quads = nil,
                                isTileVariation = false
                            }
                            print("[Assets] Loaded " .. folder .. "/" .. imageName)
                        end
                    else
                        print("[Assets] Failed to load " .. imagePath .. ": " .. image)
                    end
                end
            end
        end
    end
    
    print("[Assets] Loaded " .. Assets.count() .. " images")
end

-- Get image by folder and name
function Assets.get(folder, name)
    if Assets.images[folder] and Assets.images[folder][name] then
        local asset = Assets.images[folder][name]
        return asset.image, asset.quads and asset.quads[1] or nil, asset.isTileVariation
    end
    return nil
end

-- Get specific quad by index for tile variations
function Assets.getQuad(folder, name, quadIndex)
    if Assets.images[folder] and Assets.images[folder][name] then
        local asset = Assets.images[folder][name]
        if asset.isTileVariation and asset.quads and quadIndex and quadIndex <= #asset.quads then
            return asset.image, asset.quads[quadIndex]
        end
    end
    return nil
end

-- Count total images
function Assets.count()
    local count = 0
    for _, folder in pairs(Assets.images) do
        for _ in pairs(folder) do
            count = count + 1
        end
    end
    return count
end

return Assets