--[[
  Army Class - Object-oriented representation of an army spritesheet

  Responsibilities:
  - Load army config from YAML file
  - Load all graphics for units
  - Generate spritesheet based on config
  - Save output
]]--

local Army = {}
Army.__index = Army

-- Create new Army instance
function Army.new(army_name, base_path)
    local self = setmetatable({}, Army)

    self.name = army_name
    self.base_path = base_path or ("armies/" .. army_name)
    self.config = nil
    self.graphics = {}
    self.errors = {}

    return self
end

-- Load configuration from YAML file
function Army:loadConfig()
    local config_path = self.base_path .. "/config.yaml"
    local file, err = io.open(config_path, "r")

    if not file then
        table.insert(self.errors, "Cannot open config: " .. config_path .. " - " .. tostring(err))
        return false
    end

    local content = file:read("*a")
    file:close()

    -- Parse YAML manually (simple parser for this specific format)
    local YAMLParser = require("src.YAMLParser")
    self.config = YAMLParser.parseSimple(content)

    if not self.config then
        table.insert(self.errors, "Failed to parse config YAML")
        return false
    end

    -- Fix the units list structure from YAMLParser
    if self.config.units and self.config.units._items then
        self.config.units = self.config.units._items
    end

    if not self.config.units then
        self.config.units = {}
    end

    if not self.config.name then
        table.insert(self.errors, "Config missing 'name' field")
        return false
    end

    return true
end

-- Simple YAML parser for our config format
function Army:parseYAML(content)
    local result = {}
    local lines = {}

    -- Split content into lines
    for line in content:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    local current_section = result
    local stack = {}
    local list_stack = {}

    for _, line in ipairs(lines) do
        -- Skip empty lines and comments
        if line:match("^%s*$") or line:match("^%s*#") then
            goto continue
        end

        local indent = #line - #line:lstrip()
        local trimmed = line:match("^%s*(.*)$")

        -- Adjust stack for indentation
        while #stack > 0 and stack[#stack].indent >= indent do
            table.remove(stack)
            current_section = stack[#stack] and stack[#stack].parent or result
        end

        -- Parse key: value pairs
        local key, val = trimmed:match("^([%w_]+):%s*(.*)$")

        if key then
            if val == "" then
                -- Nested object
                local nested = {}
                current_section[key] = nested
                table.insert(stack, { indent = indent, parent = current_section, table = nested })
                current_section = nested
            else
                -- Direct value
                current_section[key] = self:parseValue(val)
            end
        elseif trimmed:match("^%-") then
            -- List item
            if not current_section._items then
                current_section._items = {}
            end

            local item_content = trimmed:match("^%-%s*(.*)$")

            if item_content:match("^[%w_]+:") then
                -- Complex list item (table)
                local item = {}
                local k, v = item_content:match("^([%w_]+):%s*(.*)$")
                item[k] = self:parseValue(v)
                table.insert(current_section._items, item)
            else
                -- Simple list item
                table.insert(current_section._items, item_content)
            end
        end

        ::continue::
    end

    -- Post-process: convert _items to array format
    result.units = result._items or {}
    result._items = nil

    if result.print and result.print._items then
        result.print._items = nil
    end

    return result
end

-- Parse YAML value to appropriate type
function Army:parseValue(value)
    value = value:trim()

    if value == "" then return nil end
    if value:lower() == "true" then return true end
    if value:lower() == "false" then return false end

    local num = tonumber(value)
    if num then return num end

    if value:match('^"') and value:match('"$') then
        return value:sub(2, -2)
    end

    return value
end

-- String trim function
function string:trim()
    return self:match("^%s*(.-)%s*$")
end

function string:lstrip()
    return self:match("^%s*(.*)")
end

function string:rstrip()
    return self:match("(.-)%s*$")
end

-- Load all graphics for units
function Army:loadGraphics()
    if not self.config then
        table.insert(self.errors, "Config not loaded")
        return false
    end

    local graphics_path = self.base_path .. "/graphics"
    local loaded_count = 0
    local missing_count = 0

    for i, unit in ipairs(self.config.units) do
        if not unit.file then
            goto continue_graphic_load
        end

        local file_path = graphics_path .. "/" .. unit.file

        local success, image = pcall(function()
            return love.graphics.newImage(file_path)
        end)

        if success then
            local width, height = image:getDimensions()
            self.graphics[unit.name] = {
                name = unit.name,
                file = unit.file,
                image = image,
                width = width,
                height = height,
                repetitions = unit.repetitions,
                config_width = unit.width,
                config_height = unit.height
            }
            loaded_count = loaded_count + 1
        else
            missing_count = missing_count + 1
        end

        ::continue_graphic_load::
    end

    -- Allow generation if at least some graphics are loaded
    -- Return true if we loaded at least one graphic, or false if none loaded
    return loaded_count > 0
end

-- Generate spritesheet canvas
function Army:generateSpritesheet()
    if not self.config then
        table.insert(self.errors, "Config not loaded")
        return nil
    end

    local config = self.config
    local cols = config.print.grid.columns
    local rows = config.print.grid.rows
    local cell_size = 70
    local spacing = 8
    local border = 4

    -- Calculate canvas size
    local canvas_width = cols * cell_size + (cols - 1) * spacing + (2 * border)
    local canvas_height = rows * cell_size + (rows - 1) * spacing + (2 * border)

    -- Create canvas
    local canvas = love.graphics.newCanvas(canvas_width, canvas_height)

    -- Draw on canvas
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 1)

    local current_col = 0
    local current_row = 0

    -- Draw each unit's graphics or placeholder
    for _, unit_config in ipairs(config.units) do
        local graphic = self.graphics[unit_config.name]

        -- Determine repetitions
        local reps = graphic and graphic.repetitions or 1

        -- Draw as many repetitions as configured
        for rep = 1, reps do
            local x = current_col * (cell_size + spacing) + border
            local y = current_row * (cell_size + spacing) + border

            if graphic then
                -- Draw actual graphic
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle("fill", x, y, cell_size, cell_size)

                -- Draw graphic centered
                local center_x = x + cell_size / 2
                local center_y = y + cell_size / 2

                local scale_x = cell_size / graphic.width
                local scale_y = cell_size / graphic.height
                local scale = math.min(scale_x, scale_y)

                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(
                    graphic.image,
                    center_x,
                    center_y,
                    0,
                    scale,
                    scale,
                    graphic.width / 2,
                    graphic.height / 2
                )
            else
                -- Draw placeholder (gray background with question mark)
                love.graphics.setColor(0.5, 0.5, 0.5, 1)
                love.graphics.rectangle("fill", x, y, cell_size, cell_size)

                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.print("?", x + cell_size / 2 - 4, y + cell_size / 2 - 6)
            end

            -- Move to next cell
            current_row = current_row + 1
            if current_row >= rows then
                current_row = 0
                current_col = current_col + 1
            end
        end
    end

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)

    return canvas
end

-- Save spritesheet to file
function Army:saveSpritesheetToFile(canvas, output_dir)
    if not canvas then
        table.insert(self.errors, "Canvas is nil")
        return false
    end

    output_dir = output_dir or "output"

    -- Create output directory if it doesn't exist (using raw Lua)
    if jit.os == "Windows" then
        os.execute("mkdir " .. output_dir .. " 2>nul")
    else
        os.execute("mkdir -p " .. output_dir)
    end

    local filename = self.name .. "_A4_150items.png"
    local filepath = output_dir .. "/" .. filename

    local save_success, err = pcall(function()
        local image_data = love.graphics.readbackTexture(canvas)
        -- Use image_data:encode with a file stream
        -- Create a ByteBuffer using a temporary file approach
        local temp_path = "temp_" .. filename

        -- Write to temp file in save directory first
        image_data:encode("png", temp_path)

        -- Read the temp file and write to actual location
        local temp_file = io.open(love.filesystem.getSaveDirectory() .. "/" .. temp_path, "rb")
        if not temp_file then
            error("Cannot read temporary PNG file")
        end
        local png_bytes = temp_file:read("*a")
        temp_file:close()

        -- Write to final location
        local final_file = io.open(filepath, "wb")
        if not final_file then
            error("Cannot open final file for writing: " .. filepath)
        end
        final_file:write(png_bytes)
        final_file:close()

        -- Clean up temp file
        os.remove(love.filesystem.getSaveDirectory() .. "/" .. temp_path)
    end)

    if save_success then
        return true
    else
        local msg = "Cannot save file: " .. filepath .. " - " .. tostring(err)
        table.insert(self.errors, msg)
        return false
    end
end

-- Complete workflow
function Army:generate(output_dir)
    output_dir = output_dir or "output"

    if not self:loadConfig() then
        return false
    end

    -- Load graphics - may be partial (some units missing graphics)
    -- This will return false only if NO graphics are loaded
    local graphics_loaded = self:loadGraphics()

    -- Generate spritesheet even with partial graphics (uses placeholders for missing)
    local canvas = self:generateSpritesheet()
    if not canvas then
        return false
    end

    if not self:saveSpritesheetToFile(canvas, output_dir) then
        return false
    end

    return true
end

-- Get summary info
function Army:getSummary()
    return {
        name = self.name,
        config_loaded = self.config ~= nil,
        graphics_loaded = #self.graphics,
        errors = self.errors
    }
end

return Army
