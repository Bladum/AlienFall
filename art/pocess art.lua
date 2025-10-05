-- main.lua
-- LÖVE 12 compatible
-- Converts an input PNG into a perfect 1-bit (black/white) pixel-art tileset
-- Each output tile is 12x12 pixels. User provides: input filename, tilesX, tilesY
-- Usage: love . input.png tilesX tilesY
-- Fallback: uses "input.png" or first PNG found in project directory.

local TILE_PIXEL_SIZE = 12

-- read args: love . input.png tilesX tilesY
local input_filename = "input.png"
local tilesX = 16
local tilesY = 16
if arg and #arg >= 2 then
    input_filename = arg[2] or input_filename
    tilesX = tonumber(arg[3]) or tilesX
    tilesY = tonumber(arg[4]) or tilesY
end

local sourceImage, sourceData, outputImageData, outputImage
local savedPath = "output_tileset_1bit.png"
local previewScale = 2

local function clamp(v,a,b) if v<a then return a end if v>b then return b end return v end

-- Compute luminance from r,g,b components (linear values 0..1)
local function luminance(r,g,b)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
end

-- Build grayscale histogram (256 bins) for a given ImageData region
local function grayscaleHistogram(imgdata, x0,y0,w,h)
    local sw, sh = imgdata:getWidth(), imgdata:getHeight()
    local sx = math.floor(x0); local sy = math.floor(y0)
    local ex = math.floor(x0 + w - 1); local ey = math.floor(y0 + h - 1)
    ex = clamp(ex, 0, sw-1); ey = clamp(ey, 0, sh-1)
    local hist = {}
    for i=1,256 do hist[i]=0 end
    local count = 0
    for y = sy, ey do
        for x = sx, ex do
            local r,g,b,a = imgdata:getPixel(x,y)
            if a > 0 then
                local L = math.floor(clamp(luminance(r,g,b),0,1) * 255 + 0.5)
                hist[L+1] = hist[L+1] + 1
                count = count + 1
            end
        end
    end
    return hist, count
end

-- Otsu threshold on histogram (returns value 0..255)
local function otsuThreshold(hist, total)
    if total == 0 then return 128 end
    local sum = 0
    for t=0,255 do sum = sum + t * hist[t+1] end
    local sumB = 0
    local wB = 0
    local wF = 0
    local varMax = 0
    local threshold = 0
    for t=0,255 do
        wB = wB + hist[t+1]
        if wB == 0 then goto cont end
        wF = total - wB
        if wF == 0 then break end
        sumB = sumB + t * hist[t+1]
        local mB = sumB / wB
        local mF = (sum - sumB) / wF
        local varBetween = wB * wF * (mB - mF) * (mB - mF)
        if varBetween > varMax then
            varMax = varBetween
            threshold = t
        end
        ::cont::
    end
    return threshold
end

-- Downsample region to an integer grid (nearest neighbor) of w x h and return grayscale values 0..255
local function downsampleGrayscaleGrid(imgdata, srcX, srcY, srcW, srcH, w, h)
    local sw, sh = imgdata:getWidth(), imgdata:getHeight()
    local grid = {}
    for yy = 1, h do
        grid[yy] = {}
        for xx = 1, w do
            local u = (xx - 0.5) / w
            local v = (yy - 0.5) / h
            local sx = clamp(math.floor(srcX + u * srcW + 0.5), 0, sw - 1)
            local sy = clamp(math.floor(srcY + v * srcH + 0.5), 0, sh - 1)
            local r,g,b,a = imgdata:getPixel(sx, sy)
            local L = math.floor(clamp(luminance(r,g,b),0,1) * 255 + 0.5)
            grid[yy][xx] = L
        end
    end
    return grid
end

-- Convert entire image into a 1-bit tileset: each tile TILE_PIXEL_SIZE x TILE_PIXEL_SIZE, black or white only
-- Per-tile adaptive thresholding using Otsu gives best 1-bit pixel-art result without gradients
local function convertTo1BitTileset(imgdata, tilesX, tilesY, tilePixelSize)
    local sw, sh = imgdata:getWidth(), imgdata:getHeight()
    local outW = tilesX * tilePixelSize
    local outH = tilesY * tilePixelSize
    local out = love.image.newImageData(outW, outH)

    local cellW = sw / tilesX
    local cellH = sh / tilesY

    for ty = 0, tilesY - 1 do
        for tx = 0, tilesX - 1 do
            local srcX = tx * cellW
            local srcY = ty * cellH
            -- build histogram for this logical tile region and compute threshold
            local hist, count = grayscaleHistogram(imgdata, srcX, srcY, cellW, cellH)
            local thresh = otsuThreshold(hist, count) -- 0..255
            -- Downsample to tile grid using nearest neighbor then threshold each pixel to 0 or 1
            local grid = downsampleGrayscaleGrid(imgdata, srcX, srcY, cellW, cellH, tilePixelSize, tilePixelSize)
            for yy = 1, tilePixelSize do
                for xx = 1, tilePixelSize do
                    local L = grid[yy][xx]
                    local isWhite = (L > thresh) and 1 or 0
                    if isWhite == 1 then
                        out:setPixel(tx * tilePixelSize + (xx-1), ty * tilePixelSize + (yy-1), 1,1,1,1)
                    else
                        out:setPixel(tx * tilePixelSize + (xx-1), ty * tilePixelSize + (yy-1), 0,0,0,1)
                    end
                end
            end
        end
    end

    return out
end

function love.load()
    -- load source image (try given filename, then first PNG in folder, else error)
    if love.filesystem.getInfo(input_filename) then
        sourceImage = love.graphics.newImage(input_filename)
        sourceData = sourceImage:getData()
    else
        -- try to find first PNG
        local files = love.filesystem.getDirectoryItems(".")
        local found = false
        for _,f in ipairs(files) do
            if f:lower():match("%.png$") then
                input_filename = f
                sourceImage = love.graphics.newImage(input_filename)
                sourceData = sourceImage:getData()
                found = true
                break
            end
        end
        if not found then
            error("No input PNG found. Place input.png or pass filename as argument.")
        end
    end

    -- perform conversion
    outputImageData = convertTo1BitTileset(sourceData, tilesX, tilesY, TILE_PIXEL_SIZE)
    local ok, err = outputImageData:encode("png", savedPath)
    if not ok then
        print("Failed to save:", err)
    else
        print("Saved:", savedPath)
    end
    outputImage = love.graphics.newImage(outputImageData)
end

function love.draw()
    love.graphics.clear(0.12,0.12,0.12)
    love.graphics.setColor(1,1,1,1)
    local margin = 8
    -- show original scaled (nearest) so blocks look like pixels
    local srcW, srcH = sourceImage:getWidth(), sourceImage:getHeight()
    local srcScale = math.min(200/srcW, 200/srcH)
    -- force nearest filtering for crisp preview
    sourceImage:setFilter("nearest", "nearest")
    love.graphics.draw(sourceImage, margin, margin, 0, srcScale, srcScale)
    love.graphics.rectangle("line", margin-1, margin-1, srcW*srcScale+2, srcH*srcScale+2)

    -- show output tileset
    local tx = margin + srcW*srcScale + 24
    local ty = margin
    outputImage:setFilter("nearest", "nearest")
    love.graphics.draw(outputImage, tx, ty, 0, previewScale, previewScale)
    love.graphics.rectangle("line", tx-1, ty-1, outputImage:getWidth()*previewScale+2, outputImage:getHeight()*previewScale+2)

    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Input: " .. input_filename, margin, margin + srcH*srcScale + 8)
    love.graphics.print(string.format("Tiles: %d x %d    Output: %dx%d (saved: %s)", tilesX, tilesY, outputImage:getWidth(), outputImage:getHeight(), savedPath), tx, ty + outputImage:getHeight()*previewScale + 8)
    love.graphics.print("Press +/- to change preview scale, Esc to quit", margin, ty + 260)
end

function love.keypressed(k)
    if k == "escape" then love.event.quit() end
    if k == "kp+" or k == "+" then previewScale = previewScale + 1 end
    if k == "kp-" or k == "-" then previewScale = math.max(1, previewScale - 1) end
end