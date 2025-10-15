---MockData Generator - Test Data Generator
---
---Generates mock data for testing widgets and UI components. Provides consistent
---test data including items, units, stats, and strings. Useful for development
---and testing without real data sources.
---
---Features:
---  - Random item generation
---  - Mock unit data with stats
---  - Lorem ipsum text generation
---  - Consistent random seed
---  - Configurable data counts
---  - Realistic test values
---
---Data Types:
---  - Items: Names for lists/tables
---  - Units: Mock soldiers with stats (HP, AP, etc.)
---  - Stats: Health, armor, accuracy values
---  - Text: Lorem ipsum paragraphs
---  - Numbers: Ranges of numeric values
---
---Key Exports:
---  - MockData.generateItems(count): Creates item name list
---  - MockData.generateUnits(count): Creates mock unit list
---  - MockData.generateStats(): Creates stat values
---  - MockData.generateText(paragraphs): Creates lorem ipsum text
---  - MockData.randomInt(min, max): Random integer
---  - MockData.randomFloat(min, max): Random float
---  - MockData.setSeed(seed): Sets random seed for consistency
---
---Dependencies:
---  - None (standalone module)
---
---@module widgets.core.mock_data
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MockData = require("widgets.core.mock_data")
---  local items = MockData.generateItems(10)
---  local units = MockData.generateUnits(5)
---  local stats = MockData.generateStats()
---  -- Use in widget testing
---  listbox:setItems(items)
---
---@see widgets.init For widget system

--[[
    Mock Data Generator
    
    Generates mock data for testing widgets and UI components.
    Useful for development and testing without real data sources.
]]

local MockData = {}

-- Random seed for consistent mock data
math.randomseed(os.time())

--[[
    Generate random items for lists/tables
    @param count number - Number of items to generate
    @return table - Array of item strings
]]
function MockData.generateItems(count)
    local items = {}
    local adjectives = {"Quick", "Lazy", "Happy", "Brave", "Clever", "Swift", "Strong", "Wise", "Silent", "Bold"}
    local nouns = {"Fox", "Dog", "Cat", "Bear", "Wolf", "Eagle", "Lion", "Tiger", "Dragon", "Phoenix"}
    
    for i = 1, count do
        local adj = adjectives[math.random(#adjectives)]
        local noun = nouns[math.random(#nouns)]
        table.insert(items, adj .. " " .. noun .. " " .. i)
    end
    
    return items
end

--[[
    Generate random table data
    @param rows number - Number of rows
    @param cols number - Number of columns
    @return table, table - Headers and rows
]]
function MockData.generateTableData(rows, cols)
    local headers = {}
    for i = 1, cols do
        table.insert(headers, "Column " .. i)
    end
    
    local data = {}
    for i = 1, rows do
        local row = {}
        for j = 1, cols do
            table.insert(row, "Cell " .. i .. "-" .. j)
        end
        table.insert(data, row)
    end
    
    return headers, data
end

--[[
    Generate random unit names
    @param count number - Number of names to generate
    @return table - Array of unit names
]]
function MockData.generateUnitNames(count)
    local ranks = {"Private", "Corporal", "Sergeant", "Lieutenant", "Captain", "Major"}
    local firstNames = {"John", "Jane", "Mike", "Sarah", "Tom", "Emma", "Chris", "Lisa", "Alex", "Kate"}
    local lastNames = {"Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez"}
    
    local names = {}
    for i = 1, count do
        local rank = ranks[math.random(#ranks)]
        local first = firstNames[math.random(#firstNames)]
        local last = lastNames[math.random(#lastNames)]
        table.insert(names, rank .. " " .. first .. " " .. last)
    end
    
    return names
end

--[[
    Generate random health values
    @param count number - Number of values to generate
    @return table - Array of {current, max} health tables
]]
function MockData.generateHealthValues(count)
    local values = {}
    for i = 1, count do
        local max = math.random(50, 150)
        local current = math.random(10, max)
        table.insert(values, {current = current, max = max})
    end
    
    return values
end

--[[
    Generate random percentage values
    @param count number - Number of values to generate
    @return table - Array of values between 0.0 and 1.0
]]
function MockData.generatePercentages(count)
    local values = {}
    for i = 1, count do
        table.insert(values, math.random() * 0.8 + 0.1)  -- 0.1 to 0.9
    end
    
    return values
end

--[[
    Generate random text blocks
    @param count number - Number of text blocks
    @param sentences number - Sentences per block (optional, default 3)
    @return table - Array of text strings
]]
function MockData.generateText(count, sentences)
    sentences = sentences or 3
    
    local words = {
        "Lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit",
        "sed", "do", "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore",
        "magna", "aliqua", "enim", "ad", "minim", "veniam", "quis", "nostrud"
    }
    
    local texts = {}
    for i = 1, count do
        local text = ""
        for s = 1, sentences do
            local sentenceLength = math.random(5, 12)
            for w = 1, sentenceLength do
                text = text .. words[math.random(#words)]
                if w < sentenceLength then
                    text = text .. " "
                end
            end
            if s < sentences then
                text = text .. ". "
            else
                text = text .. "."
            end
        end
        table.insert(texts, text)
    end
    
    return texts
end

--[[
    Generate random options for dropdowns/combos
    @param count number - Number of options
    @return table - Array of option strings
]]
function MockData.generateOptions(count)
    local options = {}
    for i = 1, count do
        table.insert(options, "Option " .. i)
    end
    return options
end

--[[
    Generate random tree data for hierarchy
    @param depth number - Tree depth
    @param childrenPerNode number - Children per node (default 3)
    @return table - Tree structure
]]
function MockData.generateTreeData(depth, childrenPerNode)
    childrenPerNode = childrenPerNode or 3
    
    local function createNode(level, index)
        local node = {
            id = "node_" .. level .. "_" .. index,
            label = "Item " .. level .. "-" .. index,
            children = {}
        }
        
        if level < depth then
            for i = 1, childrenPerNode do
                table.insert(node.children, createNode(level + 1, i))
            end
        end
        
        return node
    end
    
    return createNode(1, 1)
end

--[[
    Generate random color
    @return table - Color table {r, g, b, a}
]]
function MockData.generateColor()
    return {
        r = math.random(0, 255),
        g = math.random(0, 255),
        b = math.random(0, 255),
        a = 255
    }
end

--[[
    Generate random coordinates
    @param count number - Number of coordinates
    @param maxX number - Max X value
    @param maxY number - Max Y value
    @return table - Array of {x, y} coordinate tables
]]
function MockData.generateCoordinates(count, maxX, maxY)
    local coords = {}
    for i = 1, count do
        table.insert(coords, {
            x = math.random(0, maxX),
            y = math.random(0, maxY)
        })
    end
    return coords
end

print("[MockData] Mock data generator loaded")

return MockData






















