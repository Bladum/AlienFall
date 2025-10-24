--[[
  Geoscape Hex Map Renderer

  Renders the strategic world map with hex grid visualization.
  Includes camera system for panning and zooming at 60 FPS.

  @module engine.geoscape.rendering.geoscape_renderer
  @author AI Assistant
  @license MIT
]]

local HexMath = require("engine.core.hex_math")

local GeoscapeRenderer = {}

--- Initialize the renderer with world reference and screen dimensions
-- @param world table World system reference with regions
-- @param screen_width number Screen width in pixels
-- @param screen_height number Screen height in pixels
-- @return table Initialized renderer
function GeoscapeRenderer:initialize(world, screen_width, screen_height)
  self.world = world
  self.screen_width = screen_width
  self.screen_height = screen_height

  -- Camera position (in hex coordinates)
  self.camera_x = 40
  self.camera_y = 20

  -- Zoom level (1.0 = normal, 2.0 = 2x zoom)
  self.zoom = 1.0

  -- Hex size in pixels (before zoom)
  self.hex_size = 24

  -- Display options
  self.show_grid = false

  return self
end

--- Update camera based on input
-- Handles arrow keys for panning, +/- for zoom, space for grid toggle
-- @param dt number Delta time
function GeoscapeRenderer:update(dt)
  -- Camera panning with arrow keys
  if love.keyboard.isDown("left") then
    self:pan(-20, 0)
  end
  if love.keyboard.isDown("right") then
    self:pan(20, 0)
  end
  if love.keyboard.isDown("up") then
    self:pan(0, -20)
  end
  if love.keyboard.isDown("down") then
    self:pan(0, 20)
  end

  -- Zoom with +/- keys
  if love.keyboard.isDown("=") or love.keyboard.isDown("+") then
    self:zoom(1.05)
  end
  if love.keyboard.isDown("-") then
    self:zoom(0.95)
  end
end

--- Draw the entire hex map
function GeoscapeRenderer:draw()
  -- Clear with dark blue background
  love.graphics.clear(0.1, 0.15, 0.2)

  -- Draw all hexes on the map
  for q = 0, 79 do
    for r = 0, 39 do
      self:drawHex(q, r)
    end
  end

  -- Draw grid lines if enabled
  if self.show_grid then
    self:drawGridLines()
  end

  -- Draw debug info
  self:drawDebugInfo()
end

--- Draw a single hex at given coordinates
-- @param q number Hex column coordinate
-- @param r number Hex row coordinate
function GeoscapeRenderer:drawHex(q, r)
  -- Convert hex coordinates to pixel position
  local pixel_x, pixel_y = self:hexToPixel(q, r)

  -- Cull hexes that are off-screen
  local render_size = self.hex_size * self.zoom + 5
  if pixel_x < -render_size or pixel_x > self.screen_width + render_size then
    return
  end
  if pixel_y < -render_size or pixel_y > self.screen_height + render_size then
    return
  end

  -- Get province data from world
  local province = nil
  if self.world and self.world.getProvinceAt then
    province = self.world:getProvinceAt(q, r)
  end

  -- Determine color based on biome
  if province then
    local biome = province.biome or "grassland"
    if biome == "forest" then
      love.graphics.setColor(0.2, 0.4, 0.2)  -- Dark green
    elseif biome == "mountain" then
      love.graphics.setColor(0.5, 0.5, 0.5)  -- Gray
    elseif biome == "ocean" then
      love.graphics.setColor(0.2, 0.4, 0.7)  -- Blue
    elseif biome == "desert" then
      love.graphics.setColor(0.8, 0.7, 0.3)  -- Yellow-brown
    else
      love.graphics.setColor(0.3, 0.4, 0.3)  -- Grassland green
    end
  else
    love.graphics.setColor(0.3, 0.3, 0.3)  -- Default gray
  end

  -- Draw hex shape
  self:drawHexShape(pixel_x, pixel_y)
end

--- Draw a hexagon at pixel coordinates
-- @param x number Center x in pixels
-- @param y number Center y in pixels
function GeoscapeRenderer:drawHexShape(x, y)
  local size = self.hex_size * self.zoom

  -- Regular hexagon with flat-top orientation (6 vertices at 60-degree angles)
  local angles = {0, 60, 120, 180, 240, 300}
  local vertices = {}

  for i, angle in ipairs(angles) do
    local rad = math.rad(angle)
    vertices[i * 2 - 1] = x + size * math.cos(rad)
    vertices[i * 2] = y + size * math.sin(rad)
  end

  -- Fill hex
  love.graphics.polygon("fill", vertices)

  -- Draw border
  love.graphics.setColor(0, 0, 0)
  love.graphics.polygon("line", vertices)
end

--- Convert hex coordinates to pixel coordinates
-- Uses axial coordinate system (q, r) to pixel (x, y)
-- @param q number Hex column
-- @param r number Hex row
-- @return number, number Pixel x and y coordinates
function GeoscapeRenderer:hexToPixel(q, r)
  local size = self.hex_size * self.zoom

  -- Axial to pixel (flat-top orientation)
  -- x = size * (1.5 * q)
  -- y = size * (sqrt(3)/2 * q + sqrt(3) * r)
  local x = size * (1.5 * q)
  local y = size * (math.sqrt(3) / 2 * q + math.sqrt(3) * r)

  -- Apply camera offset (center on screen)
  x = x - self.camera_x * size * 1.5 + self.screen_width / 2
  y = y - self.camera_y * size * math.sqrt(3) + self.screen_height / 2

  return x, y
end

--- Draw grid lines for debugging
function GeoscapeRenderer:drawGridLines()
  love.graphics.setColor(0.5, 0.5, 0.5, 0.3)

  -- Draw center point of hexes every 5 units
  for q = 0, 79, 5 do
    for r = 0, 39, 5 do
      local x, y = self:hexToPixel(q, r)
      love.graphics.circle("fill", x, y, 3)
    end
  end
end

--- Draw debug information on screen
function GeoscapeRenderer:drawDebugInfo()
  love.graphics.setColor(1, 1, 1)

  local fps = love.timer.getFPS()
  local info = string.format("Cam: (%.0f, %.0f) Zoom: %.2f FPS: %d",
    self.camera_x, self.camera_y, self.zoom, fps)

  love.graphics.printf(info, 10, 10, self.screen_width - 20, "left")

  -- Help text
  love.graphics.setColor(0.7, 0.7, 0.7)
  love.graphics.printf("Arrows: pan | +/-: zoom | SPACE: grid toggle",
    10, 30, self.screen_width - 20, "left")
end

--- Pan the camera
-- @param dx number Pixels to move in x direction
-- @param dy number Pixels to move in y direction
function GeoscapeRenderer:pan(dx, dy)
  local size = self.hex_size * self.zoom

  -- Convert pixel movement to hex coordinate movement
  self.camera_x = self.camera_x + dx / (size * 1.5)
  self.camera_y = self.camera_y + dy / (size * math.sqrt(3))

  -- Clamp camera to world bounds
  self.camera_x = math.max(0, math.min(79, self.camera_x))
  self.camera_y = math.max(0, math.min(39, self.camera_y))
end

--- Zoom the camera
-- @param factor number Multiplication factor (>1 zooms in, <1 zooms out)
function GeoscapeRenderer:zoom(factor)
  self.zoom = self.zoom * factor

  -- Clamp zoom level (0.5x to 4.0x)
  self.zoom = math.max(0.5, math.min(4.0, self.zoom))
end

--- Toggle grid display
function GeoscapeRenderer:toggleGrid()
  self.show_grid = not self.show_grid
end

--- Get hex under mouse cursor (for input handling)
-- @param mouse_x number Mouse x in screen coordinates
-- @param mouse_y number Mouse y in screen coordinates
-- @return table Hex coordinate table {q, r} or nil
function GeoscapeRenderer:getHexUnderMouse(mouse_x, mouse_y)
  local size = self.hex_size * self.zoom

  -- Convert screen coordinates to world-space coordinates
  local world_x = (mouse_x - self.screen_width / 2) / size
  local world_y = (mouse_y - self.screen_height / 2) / size

  -- Apply camera offset
  world_x = world_x + self.camera_x * 1.5
  world_y = world_y + self.camera_y * math.sqrt(3)

  -- Approximate hex from world coordinates
  local q = math.floor(world_x / 1.5)
  local r = math.floor(world_y / math.sqrt(3))

  -- Validate hex bounds
  if q >= 0 and q < 80 and r >= 0 and r < 40 then
    return { q = q, r = r }
  end

  return nil
end

return GeoscapeRenderer
