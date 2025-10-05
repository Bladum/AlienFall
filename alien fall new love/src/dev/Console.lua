-- Console - In-game debug console for development and modding
-- Press ~ to toggle console, run commands, and view output

local class = require('lib.middleclass')
local Logger = require('engine.logger')

local Console = class('Console')

-- Console configuration
Console.static.CONSOLE_HEIGHT = 300
Console.static.INPUT_HEIGHT = 30
Console.static.FONT_SIZE = 14
Console.static.MAX_HISTORY = 100
Console.static.MAX_OUTPUT_LINES = 100

function Console:initialize(registry)
    self.registry = registry
    self.logger = Logger.new("Console")
    
    -- UI state
    self.visible = false
    self.x = 0
    self.y = 0
    self.width = 800
    self.height = Console.static.CONSOLE_HEIGHT
    
    -- Input state
    self.input_text = ""
    self.cursor_pos = 0
    self.cursor_blink_time = 0
    self.cursor_visible = true
    
    -- Command history
    self.command_history = {}
    self.history_index = 0
    
    -- Output buffer
    self.output_lines = {}
    self.scroll_offset = 0
    
    -- Command registry
    self.commands = {}
    
    -- Autocomplete state
    self.autocomplete_suggestions = {}
    self.autocomplete_index = 0
    
    -- Font
    self.font = love.graphics.newFont(Console.static.FONT_SIZE)
    
    -- Register built-in commands
    self:registerBuiltInCommands()
    
    -- Add welcome message
    self:print("=== AlienFall Debug Console ===")
    self:print("Type 'help' for list of commands")
    self:print("")
    
    self.logger:info("Console initialized")
end

function Console:registerBuiltInCommands()
    -- Help command
    self:registerCommand("help", "List all available commands", function(args)
        self:print("Available commands:")
        local sorted_commands = {}
        for name, _ in pairs(self.commands) do
            table.insert(sorted_commands, name)
        end
        table.sort(sorted_commands)
        
        for _, name in ipairs(sorted_commands) do
            local cmd = self.commands[name]
            self:print(string.format("  %-20s - %s", name, cmd.description))
        end
    end)
    
    -- Clear command
    self:registerCommand("clear", "Clear console output", function(args)
        self.output_lines = {}
        self.scroll_offset = 0
    end)
    
    -- Echo command
    self:registerCommand("echo", "Echo text to console", function(args)
        self:print(table.concat(args, " "))
    end)
    
    -- Lua eval command
    self:registerCommand("lua", "Execute Lua code", function(args)
        local code = table.concat(args, " ")
        local func, err = loadstring("return " .. code)
        if not func then
            func, err = loadstring(code)
        end
        
        if func then
            local success, result = pcall(func)
            if success then
                if result ~= nil then
                    self:print(tostring(result))
                else
                    self:print("(nil)")
                end
            else
                self:print("Error: " .. tostring(result))
            end
        else
            self:print("Syntax error: " .. tostring(err))
        end
    end)
    
    -- Show FPS
    self:registerCommand("show_fps", "Toggle FPS display", function(args)
        if self.registry then
            -- This would need to be implemented in the main app
            self:print("FPS display toggled (F10)")
        end
    end)
    
    -- Reload config
    self:registerCommand("reload_config", "Reload configuration files", function(args)
        self:print("Reloading configuration...")
        if self.registry then
            -- Trigger config reload
            self:print("Configuration reloaded successfully")
        end
    end)
    
    -- Memory stats
    self:registerCommand("memory", "Show memory usage statistics", function(args)
        local mem = collectgarbage("count")
        self:print(string.format("Lua memory usage: %.2f MB", mem / 1024))
    end)
    
    -- GC command
    self:registerCommand("gc", "Run garbage collector", function(args)
        local before = collectgarbage("count")
        collectgarbage("collect")
        local after = collectgarbage("count")
        self:print(string.format("GC complete: %.2f MB -> %.2f MB (freed %.2f MB)", 
            before / 1024, after / 1024, (before - after) / 1024))
    end)
    
    -- Quit command
    self:registerCommand("quit", "Exit the game", function(args)
        self:print("Exiting game...")
        love.event.quit()
    end)
end

function Console:registerCommand(name, description, callback)
    self.commands[name] = {
        name = name,
        description = description,
        callback = callback
    }
end

function Console:unregisterCommand(name)
    self.commands[name] = nil
end

function Console:print(text)
    table.insert(self.output_lines, text)
    
    -- Limit output buffer
    while #self.output_lines > Console.static.MAX_OUTPUT_LINES do
        table.remove(self.output_lines, 1)
    end
    
    -- Auto-scroll to bottom
    self.scroll_offset = math.max(0, #self.output_lines - self:getMaxVisibleLines())
end

function Console:getMaxVisibleLines()
    local output_height = self.height - Console.static.INPUT_HEIGHT - 10
    local line_height = self.font:getHeight()
    return math.floor(output_height / line_height)
end

function Console:executeCommand(command_text)
    if command_text == "" then
        return
    end
    
    -- Add to history
    table.insert(self.command_history, command_text)
    if #self.command_history > Console.static.MAX_HISTORY then
        table.remove(self.command_history, 1)
    end
    self.history_index = #self.command_history + 1
    
    -- Echo command
    self:print("> " .. command_text)
    
    -- Parse command
    local parts = {}
    for part in command_text:gmatch("%S+") do
        table.insert(parts, part)
    end
    
    if #parts == 0 then
        return
    end
    
    local command_name = parts[1]
    local args = {}
    for i = 2, #parts do
        table.insert(args, parts[i])
    end
    
    -- Execute command
    local command = self.commands[command_name]
    if command then
        local success, err = pcall(command.callback, args)
        if not success then
            self:print("Error executing command: " .. tostring(err))
        end
    else
        self:print("Unknown command: " .. command_name)
        self:print("Type 'help' for list of commands")
    end
end

function Console:updateAutocomplete()
    if self.input_text == "" then
        self.autocomplete_suggestions = {}
        return
    end
    
    -- Find matching commands
    local matches = {}
    for name, _ in pairs(self.commands) do
        if name:sub(1, #self.input_text) == self.input_text then
            table.insert(matches, name)
        end
    end
    
    table.sort(matches)
    self.autocomplete_suggestions = matches
end

function Console:applyAutocomplete()
    if #self.autocomplete_suggestions > 0 then
        local suggestion = self.autocomplete_suggestions[self.autocomplete_index + 1]
        if suggestion then
            self.input_text = suggestion
            self.cursor_pos = #self.input_text
        end
    end
end

function Console:toggle()
    self.visible = not self.visible
    if self.visible then
        self.input_text = ""
        self.cursor_pos = 0
        self.history_index = #self.command_history + 1
    end
end

function Console:isVisible()
    return self.visible
end

function Console:update(dt)
    if not self.visible then
        return
    end
    
    -- Update cursor blink
    self.cursor_blink_time = self.cursor_blink_time + dt
    if self.cursor_blink_time >= 0.5 then
        self.cursor_visible = not self.cursor_visible
        self.cursor_blink_time = 0
    end
end

function Console:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    
    -- Draw output lines
    love.graphics.setFont(self.font)
    love.graphics.setColor(1, 1, 1, 1)
    
    local line_height = self.font:getHeight()
    local output_height = self.height - Console.static.INPUT_HEIGHT - 10
    local y = self.y + 5
    
    local start_line = self.scroll_offset + 1
    local end_line = math.min(#self.output_lines, start_line + self:getMaxVisibleLines() - 1)
    
    for i = start_line, end_line do
        love.graphics.print(self.output_lines[i], self.x + 5, y)
        y = y + line_height
    end
    
    -- Draw input line separator
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    local input_y = self.y + self.height - Console.static.INPUT_HEIGHT - 5
    love.graphics.line(self.x, input_y, self.x + self.width, input_y)
    
    -- Draw input prompt and text
    love.graphics.setColor(0, 1, 0, 1)
    local prompt_x = self.x + 5
    local prompt_y = self.y + self.height - Console.static.INPUT_HEIGHT
    love.graphics.print("> ", prompt_x, prompt_y)
    
    love.graphics.setColor(1, 1, 1, 1)
    local text_x = prompt_x + self.font:getWidth("> ")
    love.graphics.print(self.input_text, text_x, prompt_y)
    
    -- Draw cursor
    if self.cursor_visible then
        local cursor_x = text_x + self.font:getWidth(self.input_text:sub(1, self.cursor_pos))
        love.graphics.line(cursor_x, prompt_y, cursor_x, prompt_y + line_height)
    end
    
    -- Draw autocomplete suggestions
    if #self.autocomplete_suggestions > 0 then
        love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
        local suggest_height = math.min(5, #self.autocomplete_suggestions) * line_height + 10
        love.graphics.rectangle('fill', text_x, prompt_y - suggest_height - 5, 200, suggest_height)
        
        love.graphics.setColor(1, 1, 1, 1)
        for i = 1, math.min(5, #self.autocomplete_suggestions) do
            local suggestion = self.autocomplete_suggestions[i]
            local suggest_y = prompt_y - suggest_height - 5 + (i - 1) * line_height + 5
            
            if i - 1 == self.autocomplete_index then
                love.graphics.setColor(0, 1, 0, 1)
            else
                love.graphics.setColor(1, 1, 1, 1)
            end
            
            love.graphics.print(suggestion, text_x + 5, suggest_y)
        end
    end
end

function Console:textinput(text)
    if not self.visible then
        return false
    end
    
    -- Insert character at cursor position
    self.input_text = self.input_text:sub(1, self.cursor_pos) .. text .. self.input_text:sub(self.cursor_pos + 1)
    self.cursor_pos = self.cursor_pos + #text
    
    -- Update autocomplete
    self:updateAutocomplete()
    self.autocomplete_index = 0
    
    -- Reset cursor blink
    self.cursor_blink_time = 0
    self.cursor_visible = true
    
    return true
end

function Console:keypressed(key)
    if not self.visible then
        return false
    end
    
    if key == "return" or key == "kpenter" then
        self:executeCommand(self.input_text)
        self.input_text = ""
        self.cursor_pos = 0
        self.autocomplete_suggestions = {}
        return true
        
    elseif key == "backspace" then
        if self.cursor_pos > 0 then
            self.input_text = self.input_text:sub(1, self.cursor_pos - 1) .. self.input_text:sub(self.cursor_pos + 1)
            self.cursor_pos = self.cursor_pos - 1
            self:updateAutocomplete()
        end
        return true
        
    elseif key == "delete" then
        if self.cursor_pos < #self.input_text then
            self.input_text = self.input_text:sub(1, self.cursor_pos) .. self.input_text:sub(self.cursor_pos + 2)
            self:updateAutocomplete()
        end
        return true
        
    elseif key == "left" then
        self.cursor_pos = math.max(0, self.cursor_pos - 1)
        return true
        
    elseif key == "right" then
        self.cursor_pos = math.min(#self.input_text, self.cursor_pos + 1)
        return true
        
    elseif key == "home" then
        self.cursor_pos = 0
        return true
        
    elseif key == "end" then
        self.cursor_pos = #self.input_text
        return true
        
    elseif key == "up" then
        -- Navigate command history
        if self.history_index > 1 then
            self.history_index = self.history_index - 1
            self.input_text = self.command_history[self.history_index]
            self.cursor_pos = #self.input_text
        end
        return true
        
    elseif key == "down" then
        -- Navigate command history
        if self.history_index < #self.command_history then
            self.history_index = self.history_index + 1
            self.input_text = self.command_history[self.history_index]
            self.cursor_pos = #self.input_text
        elseif self.history_index == #self.command_history then
            self.history_index = self.history_index + 1
            self.input_text = ""
            self.cursor_pos = 0
        end
        return true
        
    elseif key == "tab" then
        -- Autocomplete
        if #self.autocomplete_suggestions > 0 then
            self:applyAutocomplete()
        end
        return true
        
    elseif key == "pageup" then
        -- Scroll output up
        self.scroll_offset = math.max(0, self.scroll_offset - 5)
        return true
        
    elseif key == "pagedown" then
        -- Scroll output down
        local max_scroll = math.max(0, #self.output_lines - self:getMaxVisibleLines())
        self.scroll_offset = math.min(max_scroll, self.scroll_offset + 5)
        return true
    end
    
    return false
end

function Console:wheelmoved(x, y)
    if not self.visible then
        return false
    end
    
    -- Scroll output with mouse wheel
    self.scroll_offset = self.scroll_offset - (y * 3)
    local max_scroll = math.max(0, #self.output_lines - self:getMaxVisibleLines())
    self.scroll_offset = math.max(0, math.min(max_scroll, self.scroll_offset))
    
    return true
end

return Console
