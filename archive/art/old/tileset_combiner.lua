-- Path to the folder containing PNG tilesets
local path = "."

local start_time = love.timer.getTime()

-- Function to get list of PNG files
function get_png_files(dir)
    local files = {}
    local items = love.filesystem.getDirectoryItems(dir)
    for _, item in ipairs(items) do
        if item:match("%.png$") and item ~= "combined_tiles.png" then
            table.insert(files, item)
        end
    end
    return files
end

-- Function to check if a tile is all one color
function is_uniform_color(tile)
    local r0, g0, b0, a0 = tile:getPixel(0, 0)
    for y = 0, 11 do
        for x = 0, 11 do
            local r, g, b, a = tile:getPixel(x, y)
            if r ~= r0 or g ~= g0 or b ~= b0 or a ~= a0 then
                return false
            end
        end
    end
    return true
end

-- Function to check if a tile is all black
function is_black(tile)
    if not is_uniform_color(tile) then return false end
    local r, g, b = tile:getPixel(0, 0)
    return r == 0 and g == 0 and b == 0
end

-- Function to check if a tile is all pink (magenta)
function is_pink(tile)
    if not is_uniform_color(tile) then return false end
    local r, g, b = tile:getPixel(0, 0)
    return r == 255 and g == 0 and b == 255
end

-- Function to load ImageData from file
function load_image_data(file_path)
    return love.image.newImageData(file_path)
end
function detect_tileset_params(w, h)
    local s = 12
    local sp1 = 13
    if (w - 1) % sp1 == 0 and (h - 1) % sp1 == 0 then
        local nw = (w - 1) / sp1
        local nh = (h - 1) / sp1
        if nw == math.floor(nw) and nh == math.floor(nh) and nw > 0 and nh > 0 then
            return {s = s, nw = nw, nh = nh}
        end
    end
    return nil
end

-- Main code
local all_tiles = {}

local files = get_png_files(path)
if #files == 0 then
    -- Fallback to hardcoded list
    files = {"15ypnhue51j51.png", "5p2p2fubxnk61.png", "8s1ixmrmc7ff1.png", "bkh8dw8d4gab1.png", "lys1a3njx8t41.png", "urizen_onebit_tileset__v2d0.png"}
end
print("Found files: " .. #files)
for _, file in ipairs(files) do
    local file_start = love.timer.getTime()
    print("Processing " .. file)
    local full_path = file
    local img_data = load_image_data(full_path)
    if img_data then
        local w, h = img_data:getDimensions()
        print("Image size: " .. w .. "x" .. h)
        local params = detect_tileset_params(w, h)
        if params then
            local s = params.s
            local nw = params.nw
            local nh = params.nh
            print("Detected tile size: " .. s .. ", tiles: " .. nw .. "x" .. nh)
            for j = 0, nh - 1 do
                for i = 0, nw - 1 do
                    local tile = love.image.newImageData(s, s)
                    for ty = 0, s - 1 do
                        for tx = 0, s - 1 do
                            local r, g, b, a = img_data:getPixel(1 + i * (s + 1) + tx, 1 + j * (s + 1) + ty)
                            tile:setPixel(tx, ty, r, g, b, a)
                        end
                    end
                    -- Check if tile is not empty
                    local is_empty = true
                    for ty = 0, s - 1 do
                        for tx = 0, s - 1 do
                            local _, _, _, a = tile:getPixel(tx, ty)
                            if a > 0 then
                                is_empty = false
                                break
                            end
                        end
                        if not is_empty then break end
                    end
                    if not is_empty and not is_uniform_color(tile) and not is_black(tile) and not is_pink(tile) then
                        table.insert(all_tiles, tile)
                    end
                end
            end
        else
            print("Could not detect tileset parameters for " .. file)
        end
    else
        print("Failed to load " .. file)
    end
    local file_end = love.timer.getTime()
    print("Processed " .. file .. " in " .. math.floor((file_end - file_start) * 1000) .. " ms")
end

local total_tiles = #all_tiles
print("Total tiles: " .. total_tiles)

-- Sort tiles by pixel data to group identical ones
local function hash_pixels(tile)
    local h = 5381
    for y = 0, 11 do
        for x = 0, 11 do
            local r, g, b, a = tile:getPixel(x, y)
            local pixel = math.floor(r) + math.floor(g) * 256 + math.floor(b) * 65536 + math.floor(a) * 16777216
            h = (h * 33 + pixel) % 2^32
        end
    end
    return h
end

local entries = {}
for i, tile in ipairs(all_tiles) do
    local hash = hash_pixels(tile)
    table.insert(entries, {tile = tile, hash = hash, index = i})
end
table.sort(entries, function(a, b)
    if a.hash ~= b.hash then
        return a.hash < b.hash
    else
        return a.index < b.index
    end
end)
local sorted_tiles = {}
for _, entry in ipairs(entries) do
    table.insert(sorted_tiles, entry.tile)
end
all_tiles = sorted_tiles

local tile_size = 12
local spacing = 0
local offset = 0
local cell_size = tile_size + spacing

local cols = math.ceil(math.sqrt(total_tiles))
local rows = math.ceil(total_tiles / cols)
local big_w = cols * cell_size + offset
local big_h = rows * cell_size + offset

if big_w > 8192 then
    cols = math.floor((8192 - offset) / cell_size)
    rows = math.ceil(total_tiles / cols)
    big_w = cols * cell_size + offset
    big_h = rows * cell_size + offset
end

if big_h > 8192 then
    rows = math.floor((8192 - offset) / cell_size)
    big_w = cols * cell_size + offset
    big_h = rows * cell_size + offset
end

print("Combined image size: " .. big_w .. "x" .. big_h)

local big = love.image.newImageData(big_w, big_h)

for i = 1, total_tiles do
    local tile = all_tiles[i]
    local r = math.floor((i - 1) / cols)
    local c = (i - 1) % cols
    big:paste(tile, c * cell_size + offset, r * cell_size + offset, 0, 0, tile_size, tile_size)
end

local png_data = big:encode("png")
local f = io.open("combined_tiles.png", "wb")
if not f then
    print("Failed to open file for writing")
    return
end
f:write(png_data and png_data:getString() or "")
f:close()
print("Combined tiles saved to combined_tiles.png")
local end_time = love.timer.getTime()
print("Total time: " .. math.floor((end_time - start_time) * 1000) .. " ms")





















