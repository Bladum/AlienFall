---Mock Widget Data Generators
---
---Provides high-quality mock data for testing UI widgets. Includes
---realistic button configurations, text inputs, list items, dialog
---options, and complex widget hierarchies.
---
---Generators:
---  - getButton(): Button configurations
---  - getTextInput(): Text input field settings
---  - getListItems(): List box item sets
---  - getDropdownOptions(): Dropdown menu options
---  - getDialogConfig(): Dialog window configurations
---  - getWidgetHierarchy(): Parent-child widget trees
---  - getGridPositions(): Valid grid-aligned positions
---  - getThemeColors(): Theme color sets
---
---@module mock.widgets
---@author AlienFall Development Team
---@date 2025-10-15

local MockWidgets = {}

---Generate button configuration
---@param label string Button text label
---@param buttonType string Button type ("primary", "secondary", "danger", "success")
---@return table Button configuration
function MockWidgets.getButton(label, buttonType)
    buttonType = buttonType or "primary"
    
    local configs = {
        primary = {
            width = 96,
            height = 48,
            enabled = true,
            visible = true
        },
        secondary = {
            width = 96,
            height = 48,
            enabled = true,
            visible = true
        },
        danger = {
            width = 96,
            height = 48,
            enabled = true,
            visible = true
        },
        success = {
            width = 120,
            height = 48,
            enabled = true,
            visible = true
        },
        small = {
            width = 72,
            height = 24,
            enabled = true,
            visible = true
        },
        large = {
            width = 144,
            height = 72,
            enabled = true,
            visible = true
        }
    }
    
    local config = configs[buttonType] or configs.primary
    
    return {
        x = 0,
        y = 0,
        width = config.width,
        height = config.height,
        text = label or "Button",
        type = buttonType,
        enabled = config.enabled,
        visible = config.visible,
        callback = nil
    }
end

---Generate text input configuration
---@param placeholder string Placeholder text
---@param maxLength number Maximum character length
---@return table Text input configuration
function MockWidgets.getTextInput(placeholder, maxLength)
    return {
        x = 0,
        y = 0,
        width = 192,  -- 8 grid cells
        height = 24,  -- 1 grid cell
        placeholder = placeholder or "Enter text...",
        text = "",
        maxLength = maxLength or 50,
        enabled = true,
        visible = true,
        password = false,
        multiline = false
    }
end

---Generate checkbox configuration
---@param label string Checkbox label
---@param checked boolean Initial checked state
---@return table Checkbox configuration
function MockWidgets.getCheckbox(label, checked)
    return {
        x = 0,
        y = 0,
        width = 24,  -- 1 grid cell for checkbox
        height = 24,
        label = label or "Option",
        checked = checked or false,
        enabled = true,
        visible = true
    }
end

---Generate radio button group
---@param groupName string Radio group identifier
---@param options table Array of option labels
---@return table Radio button group configuration
function MockWidgets.getRadioButtonGroup(groupName, options)
    options = options or {"Option 1", "Option 2", "Option 3"}
    
    local buttons = {}
    for i, label in ipairs(options) do
        table.insert(buttons, {
            x = 0,
            y = (i - 1) * 24,  -- Stack vertically
            width = 24,
            height = 24,
            label = label,
            group = groupName,
            selected = i == 1,  -- First option selected
            enabled = true,
            visible = true
        })
    end
    
    return {
        groupName = groupName,
        buttons = buttons,
        selectedIndex = 1
    }
end

---Generate list box items
---@param count number Number of items to generate
---@param itemType string Type of items ("soldiers", "items", "missions", "generic")
---@return table Array of list items
function MockWidgets.getListItems(count, itemType)
    count = count or 10
    itemType = itemType or "generic"
    
    local items = {}
    
    if itemType == "soldiers" then
        local ranks = {"Rookie", "Squaddie", "Corporal", "Sergeant", "Captain"}
        for i = 1, count do
            table.insert(items, {
                id = "soldier_" .. i,
                text = string.format("Soldier %d (%s)", i, ranks[math.random(1, #ranks)]),
                icon = "soldier_icon",
                enabled = true,
                data = {
                    health = 100,
                    rank = ranks[math.random(1, #ranks)]
                }
            })
        end
    elseif itemType == "items" then
        local itemTypes = {"Rifle", "Pistol", "Grenade", "Medkit", "Armor"}
        for i = 1, count do
            table.insert(items, {
                id = "item_" .. i,
                text = itemTypes[((i - 1) % #itemTypes) + 1] .. " #" .. i,
                icon = "item_icon",
                enabled = true,
                data = {
                    quantity = math.random(1, 10)
                }
            })
        end
    elseif itemType == "missions" then
        local types = {"Terror", "UFO Recovery", "Base Defense", "Supply Raid"}
        for i = 1, count do
            table.insert(items, {
                id = "mission_" .. i,
                text = types[((i - 1) % #types) + 1] .. " - Location " .. i,
                icon = "mission_icon",
                enabled = true,
                data = {
                    difficulty = math.random(1, 5)
                }
            })
        end
    else
        for i = 1, count do
            table.insert(items, {
                id = "item_" .. i,
                text = "Item " .. i,
                icon = nil,
                enabled = true,
                data = {}
            })
        end
    end
    
    return items
end

---Generate dropdown options
---@param optionType string Type of options ("difficulty", "resolution", "quality", "generic")
---@return table Array of dropdown options
function MockWidgets.getDropdownOptions(optionType)
    optionType = optionType or "generic"
    
    local options = {}
    
    if optionType == "difficulty" then
        options = {
            {value = "easy", text = "Easy"},
            {value = "normal", text = "Normal"},
            {value = "hard", text = "Hard"},
            {value = "veteran", text = "Veteran"},
            {value = "impossible", text = "Impossible"}
        }
    elseif optionType == "resolution" then
        options = {
            {value = "960x720", text = "960×720 (4:3)"},
            {value = "1280x720", text = "1280×720 (16:9)"},
            {value = "1920x1080", text = "1920×1080 (16:9)"},
            {value = "2560x1440", text = "2560×1440 (16:9)"}
        }
    elseif optionType == "quality" then
        options = {
            {value = "low", text = "Low"},
            {value = "medium", text = "Medium"},
            {value = "high", text = "High"},
            {value = "ultra", text = "Ultra"}
        }
    else
        for i = 1, 5 do
            table.insert(options, {
                value = "option_" .. i,
                text = "Option " .. i
            })
        end
    end
    
    return options
end

---Generate dialog window configuration
---@param dialogType string Type of dialog ("confirm", "alert", "input", "custom")
---@return table Dialog configuration
function MockWidgets.getDialogConfig(dialogType)
    dialogType = dialogType or "confirm"
    
    local configs = {
        confirm = {
            title = "Confirm Action",
            message = "Are you sure you want to proceed?",
            width = 288,  -- 12 grid cells
            height = 168,  -- 7 grid cells
            buttons = {
                {text = "Yes", action = "confirm"},
                {text = "No", action = "cancel"}
            }
        },
        alert = {
            title = "Alert",
            message = "This is an important message!",
            width = 288,
            height = 144,  -- 6 grid cells
            buttons = {
                {text = "OK", action = "close"}
            }
        },
        input = {
            title = "Enter Name",
            message = "Please enter your name:",
            width = 312,  -- 13 grid cells
            height = 192,  -- 8 grid cells
            inputField = {
                placeholder = "Name",
                maxLength = 30
            },
            buttons = {
                {text = "Submit", action = "submit"},
                {text = "Cancel", action = "cancel"}
            }
        },
        custom = {
            title = "Custom Dialog",
            message = "Custom message content",
            width = 336,  -- 14 grid cells
            height = 216,  -- 9 grid cells
            buttons = {
                {text = "Option 1", action = "option1"},
                {text = "Option 2", action = "option2"},
                {text = "Cancel", action = "cancel"}
            }
        }
    }
    
    return configs[dialogType] or configs.alert
end

---Generate widget hierarchy (parent with children)
---@param depth number Tree depth (1-3)
---@return table Widget hierarchy tree
function MockWidgets.getWidgetHierarchy(depth)
    depth = depth or 2
    
    local function createWidget(level, index)
        local widget = {
            id = string.format("widget_L%d_%d", level, index),
            x = level * 24,
            y = index * 24,
            width = 96,
            height = 48,
            type = level == 1 and "panel" or "button",
            children = {}
        }
        
        if level < depth then
            local childCount = math.random(2, 3)
            for i = 1, childCount do
                table.insert(widget.children, createWidget(level + 1, i))
            end
        end
        
        return widget
    end
    
    return createWidget(1, 1)
end

---Generate grid-aligned positions
---@param count number Number of positions to generate
---@param maxX number Maximum X coordinate (default 960)
---@param maxY number Maximum Y coordinate (default 720)
---@return table Array of {x, y} positions
function MockWidgets.getGridPositions(count, maxX, maxY)
    count = count or 10
    maxX = maxX or 960
    maxY = maxY or 720
    
    local positions = {}
    local gridSize = 24
    
    for i = 1, count do
        local gridX = math.random(0, math.floor(maxX / gridSize) - 1)
        local gridY = math.random(0, math.floor(maxY / gridSize) - 1)
        
        table.insert(positions, {
            x = gridX * gridSize,
            y = gridY * gridSize,
            gridX = gridX,
            gridY = gridY
        })
    end
    
    return positions
end

---Generate theme color set
---@param themeName string Theme name ("default", "dark", "light", "military")
---@return table Theme colors
function MockWidgets.getThemeColors(themeName)
    themeName = themeName or "default"
    
    local themes = {
        default = {
            background = {r = 0.1, g = 0.1, b = 0.15},
            foreground = {r = 0.9, g = 0.9, b = 0.9},
            primary = {r = 0.2, g = 0.4, b = 0.8},
            secondary = {r = 0.3, g = 0.3, b = 0.4},
            success = {r = 0.2, g = 0.7, b = 0.3},
            warning = {r = 0.9, g = 0.7, b = 0.2},
            danger = {r = 0.8, g = 0.2, b = 0.2},
            text = {r = 1.0, g = 1.0, b = 1.0}
        },
        dark = {
            background = {r = 0.05, g = 0.05, b = 0.05},
            foreground = {r = 0.15, g = 0.15, b = 0.15},
            primary = {r = 0.3, g = 0.5, b = 0.9},
            secondary = {r = 0.2, g = 0.2, b = 0.3},
            success = {r = 0.1, g = 0.6, b = 0.2},
            warning = {r = 0.8, g = 0.6, b = 0.1},
            danger = {r = 0.7, g = 0.1, b = 0.1},
            text = {r = 0.95, g = 0.95, b = 0.95}
        },
        light = {
            background = {r = 0.95, g = 0.95, b = 0.95},
            foreground = {r = 0.85, g = 0.85, b = 0.85},
            primary = {r = 0.3, g = 0.5, b = 0.8},
            secondary = {r = 0.6, g = 0.6, b = 0.7},
            success = {r = 0.3, g = 0.7, b = 0.4},
            warning = {r = 0.9, g = 0.7, b = 0.2},
            danger = {r = 0.8, g = 0.3, b = 0.3},
            text = {r = 0.1, g = 0.1, b = 0.1}
        },
        military = {
            background = {r = 0.1, g = 0.15, b = 0.1},
            foreground = {r = 0.2, g = 0.25, b = 0.2},
            primary = {r = 0.3, g = 0.5, b = 0.2},
            secondary = {r = 0.4, g = 0.4, b = 0.3},
            success = {r = 0.2, g = 0.6, b = 0.2},
            warning = {r = 0.8, g = 0.6, b = 0.1},
            danger = {r = 0.7, g = 0.2, b = 0.1},
            text = {r = 0.8, g = 0.9, b = 0.8}
        }
    }
    
    return themes[themeName] or themes.default
end

---Generate progress bar configuration
---@param current number Current value
---@param maximum number Maximum value
---@param barType string Type ("health", "progress", "loading")
---@return table Progress bar configuration
function MockWidgets.getProgressBar(current, maximum, barType)
    current = current or 50
    maximum = maximum or 100
    barType = barType or "progress"
    
    return {
        x = 0,
        y = 0,
        width = 192,  -- 8 grid cells
        height = 24,  -- 1 grid cell
        current = current,
        maximum = maximum,
        percentage = (current / maximum) * 100,
        type = barType,
        showText = true,
        animated = barType == "loading"
    }
end

---Generate table widget data
---@param rows number Number of rows
---@param columns table Array of column definitions
---@return table Table widget configuration
function MockWidgets.getTableData(rows, columns)
    rows = rows or 10
    columns = columns or {
        {id = "name", header = "Name", width = 120},
        {id = "value", header = "Value", width = 72},
        {id = "status", header = "Status", width = 96}
    }
    
    local data = {}
    
    for i = 1, rows do
        local row = {
            id = "row_" .. i,
            cells = {}
        }
        
        for _, col in ipairs(columns) do
            if col.id == "name" then
                row.cells[col.id] = "Item " .. i
            elseif col.id == "value" then
                row.cells[col.id] = tostring(math.random(1, 100))
            elseif col.id == "status" then
                local statuses = {"Active", "Pending", "Complete", "Failed"}
                row.cells[col.id] = statuses[math.random(1, #statuses)]
            else
                row.cells[col.id] = "Data " .. i
            end
        end
        
        table.insert(data, row)
    end
    
    return {
        columns = columns,
        rows = data,
        totalRows = rows,
        x = 0,
        y = 0,
        width = 360,  -- 15 grid cells
        height = 288  -- 12 grid cells
    }
end

---Generate tooltip configuration
---@param text string Tooltip text
---@param position string Position ("top", "bottom", "left", "right")
---@return table Tooltip configuration
function MockWidgets.getTooltip(text, position)
    return {
        text = text or "This is a helpful tooltip",
        position = position or "top",
        maxWidth = 240,  -- 10 grid cells
        padding = 12,
        delay = 0.5,  -- seconds
        visible = false
    }
end

return MockWidgets



