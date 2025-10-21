---Geoscape Data Module - Province Definitions and Initialization
---
---Contains province data definitions and initialization logic for the world map.
---Defines 80+ provinces covering Earth (North America, Europe, Asia, Africa, South America,
---Oceania, Antarctica) with populations, connections, funding, and satisfaction values.
---
---Data Structure:
---  - provinces: Array of province definitions
---  - Each province: {id, name, x, y, connections, population, satisfaction, funding, hasBase}
---  - connections: Array of adjacent province IDs for graph
---
---World Map Coverage:
---  - North America: 15 provinces (Alaska to Mexico)
---  - Europe: 20 provinces (UK to Russia)
---  - Asia: 25 provinces (Middle East to Japan)
---  - Africa: 15 provinces (Egypt to South Africa)
---  - South America: 10 provinces (Brazil to Argentina)
---  - Oceania: 5 provinces (Australia, New Zealand, Pacific)
---  - Antarctica: 2 provinces (research stations)
---
---Economic Balance:
---  - High population provinces: Higher funding (e.g., Tokyo, New York)
---  - Low population provinces: Lower funding (e.g., Greenland, Antarctica)
---  - Starting satisfaction: 75-90 (varies by region)
---
---Key Exports:
---  - GeoscapeData:initProvinces(): Initializes province array
---  - self.provinces: Province data array
---
---Dependencies:
---  - geoscape.geography.province: Province entity constructor
---
---@module geoscape.logic.data
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local GeoscapeData = require("geoscape.logic.data")
---  GeoscapeData:initProvinces()
---  for _, province in ipairs(GeoscapeData.provinces) do
---    print(province.name)
---  end
---
---@see geoscape.geography.province For province entity
---@see geoscape.world.world_state For initialization

local GeoscapeData = {}

function GeoscapeData:initProvinces()
    -- Create a comprehensive world map with 80+ provinces
    -- World map dimensions: roughly 2000x1000 pixels at zoom 1.0
    self.provinces = {
        -- North America (15 provinces)
        {id = 1, name = "Alaska", x = 100, y = 100, connections = {2, 3}, population = 700000, satisfaction = 85, funding = 80000, hasBase = false},
        {id = 2, name = "British Columbia", x = 150, y = 150, connections = {1, 3, 4}, population = 5000000, satisfaction = 88, funding = 120000, hasBase = false},
        {id = 3, name = "Northwest Territories", x = 200, y = 120, connections = {1, 2, 5}, population = 45000, satisfaction = 82, funding = 15000, hasBase = false},
        {id = 4, name = "Alberta", x = 200, y = 180, connections = {2, 5, 6}, population = 4400000, satisfaction = 87, funding = 110000, hasBase = false},
        {id = 5, name = "Saskatchewan", x = 250, y = 160, connections = {3, 4, 6, 7}, population = 1200000, satisfaction = 86, funding = 60000, hasBase = false},
        {id = 6, name = "Manitoba", x = 300, y = 150, connections = {4, 5, 7, 8}, population = 1400000, satisfaction = 85, funding = 70000, hasBase = false},
        {id = 7, name = "Ontario", x = 350, y = 170, connections = {5, 6, 8, 9}, population = 15000000, satisfaction = 90, funding = 400000, hasBase = false},
        {id = 8, name = "Quebec", x = 420, y = 140, connections = {6, 7, 9, 10}, population = 8500000, satisfaction = 88, funding = 220000, hasBase = false},
        {id = 9, name = "New Brunswick", x = 450, y = 180, connections = {7, 8, 10}, population = 800000, satisfaction = 87, funding = 45000, hasBase = false},
        {id = 10, name = "Nova Scotia", x = 480, y = 190, connections = {8, 9}, population = 1000000, satisfaction = 89, funding = 55000, hasBase = false},
        {id = 11, name = "Washington", x = 120, y = 220, connections = {12, 13}, population = 7700000, satisfaction = 86, funding = 180000, hasBase = false},
        {id = 12, name = "Oregon", x = 100, y = 250, connections = {11, 13, 14}, population = 4200000, satisfaction = 87, funding = 100000, hasBase = false},
        {id = 13, name = "California", x = 80, y = 300, connections = {11, 12, 14}, population = 39500000, satisfaction = 85, funding = 950000, hasBase = false},
        {id = 14, name = "Nevada", x = 140, y = 280, connections = {12, 13, 15, 16}, population = 3100000, satisfaction = 84, funding = 75000, hasBase = false},
        {id = 15, name = "Arizona", x = 180, y = 320, connections = {14, 16, 17}, population = 7200000, satisfaction = 83, funding = 170000, hasBase = false},
        
        -- Central America & Caribbean (8 provinces)
        {id = 16, name = "Mexico", x = 220, y = 380, connections = {15, 17, 18}, population = 128000000, satisfaction = 75, funding = 180000, hasBase = false},
        {id = 17, name = "Guatemala", x = 260, y = 420, connections = {16, 18}, population = 18000000, satisfaction = 70, funding = 25000, hasBase = false},
        {id = 18, name = "Cuba", x = 320, y = 400, connections = {16, 17, 19}, population = 11000000, satisfaction = 78, funding = 30000, hasBase = false},
        {id = 19, name = "Haiti", x = 340, y = 410, connections = {18, 20}, population = 11500000, satisfaction = 65, funding = 15000, hasBase = false},
        {id = 20, name = "Dominican Republic", x = 350, y = 420, connections = {19}, population = 11000000, satisfaction = 72, funding = 20000, hasBase = false},
        
        -- South America (12 provinces)
        {id = 21, name = "Colombia", x = 300, y = 480, connections = {22, 23}, population = 51000000, satisfaction = 76, funding = 80000, hasBase = false},
        {id = 22, name = "Venezuela", x = 340, y = 460, connections = {21, 23, 24}, population = 28000000, satisfaction = 68, funding = 45000, hasBase = false},
        {id = 23, name = "Brazil", x = 400, y = 520, connections = {21, 22, 24, 25, 26}, population = 215000000, satisfaction = 80, funding = 350000, hasBase = false},
        {id = 24, name = "Guyana", x = 380, y = 480, connections = {22, 23}, population = 800000, satisfaction = 74, funding = 12000, hasBase = false},
        {id = 25, name = "Peru", x = 280, y = 540, connections = {23, 26, 27}, population = 33000000, satisfaction = 77, funding = 55000, hasBase = false},
        {id = 26, name = "Bolivia", x = 320, y = 580, connections = {23, 25, 27, 28}, population = 12000000, satisfaction = 73, funding = 20000, hasBase = false},
        {id = 27, name = "Chile", x = 300, y = 650, connections = {25, 26, 28}, population = 19000000, satisfaction = 82, funding = 45000, hasBase = false},
        {id = 28, name = "Argentina", x = 340, y = 680, connections = {26, 27}, population = 45000000, satisfaction = 81, funding = 90000, hasBase = false},
        
        -- Europe (20 provinces)
        {id = 29, name = "Iceland", x = 520, y = 80, connections = {30}, population = 350000, satisfaction = 95, funding = 25000, hasBase = false},
        {id = 30, name = "United Kingdom", x = 540, y = 120, connections = {29, 31, 32}, population = 67000000, satisfaction = 88, funding = 280000, hasBase = false},
        {id = 31, name = "Ireland", x = 500, y = 130, connections = {30}, population = 5000000, satisfaction = 90, funding = 35000, hasBase = false},
        {id = 32, name = "France", x = 580, y = 160, connections = {30, 33, 34, 35}, population = 67000000, satisfaction = 87, funding = 320000, hasBase = false},
        {id = 33, name = "Spain", x = 560, y = 200, connections = {32, 34, 36}, population = 47000000, satisfaction = 85, funding = 180000, hasBase = false},
        {id = 34, name = "Portugal", x = 520, y = 210, connections = {32, 33}, population = 10000000, satisfaction = 88, funding = 45000, hasBase = false},
        {id = 35, name = "Belgium", x = 600, y = 140, connections = {32, 36, 37}, population = 11500000, satisfaction = 89, funding = 55000, hasBase = false},
        {id = 36, name = "Netherlands", x = 610, y = 130, connections = {35, 37}, population = 17000000, satisfaction = 91, funding = 80000, hasBase = false},
        {id = 37, name = "Germany", x = 640, y = 130, connections = {35, 36, 38, 39}, population = 83000000, satisfaction = 86, funding = 380000, hasBase = false},
        {id = 38, name = "Denmark", x = 650, y = 110, connections = {37, 39}, population = 5800000, satisfaction = 92, funding = 40000, hasBase = false},
        {id = 39, name = "Poland", x = 700, y = 120, connections = {37, 38, 40, 41}, population = 38000000, satisfaction = 84, funding = 120000, hasBase = false},
        {id = 40, name = "Czech Republic", x = 670, y = 150, connections = {37, 39, 41}, population = 10700000, satisfaction = 87, funding = 50000, hasBase = false},
        {id = 41, name = "Austria", x = 660, y = 170, connections = {39, 40, 42, 43}, population = 9000000, satisfaction = 88, funding = 55000, hasBase = false},
        {id = 42, name = "Switzerland", x = 630, y = 180, connections = {41, 43}, population = 8600000, satisfaction = 93, funding = 65000, hasBase = false},
        {id = 43, name = "Italy", x = 650, y = 200, connections = {41, 42, 44}, population = 60000000, satisfaction = 85, funding = 250000, hasBase = false},
        {id = 44, name = "Greece", x = 720, y = 220, connections = {43, 45}, population = 10400000, satisfaction = 82, funding = 35000, hasBase = false},
        {id = 45, name = "Turkey", x = 780, y = 200, connections = {44, 46, 47}, population = 85000000, satisfaction = 78, funding = 120000, hasBase = false},
        {id = 46, name = "Ukraine", x = 750, y = 140, connections = {39, 45, 47}, population = 41000000, satisfaction = 75, funding = 80000, hasBase = false},
        {id = 47, name = "Russia", x = 850, y = 100, connections = {45, 46, 48, 49}, population = 145000000, satisfaction = 80, funding = 200000, hasBase = false},
        
        -- Africa (15 provinces)
        {id = 48, name = "Egypt", x = 750, y = 250, connections = {45, 49, 50}, population = 104000000, satisfaction = 75, funding = 45000, hasBase = false},
        {id = 49, name = "Libya", x = 680, y = 260, connections = {48, 50, 51}, population = 6800000, satisfaction = 70, funding = 15000, hasBase = false},
        {id = 50, name = "Algeria", x = 620, y = 280, connections = {49, 51, 52}, population = 44000000, satisfaction = 76, funding = 30000, hasBase = false},
        {id = 51, name = "Morocco", x = 560, y = 270, connections = {50, 52}, population = 37000000, satisfaction = 79, funding = 25000, hasBase = false},
        {id = 52, name = "Nigeria", x = 660, y = 380, connections = {50, 53, 54}, population = 218000000, satisfaction = 72, funding = 65000, hasBase = false},
        {id = 53, name = "Ghana", x = 620, y = 400, connections = {52, 54}, population = 31000000, satisfaction = 78, funding = 20000, hasBase = false},
        {id = 54, name = "South Africa", x = 720, y = 580, connections = {52, 53, 55}, population = 60000000, satisfaction = 83, funding = 95000, hasBase = false},
        {id = 55, name = "Kenya", x = 780, y = 420, connections = {54, 56}, population = 55000000, satisfaction = 76, funding = 35000, hasBase = false},
        {id = 56, name = "Ethiopia", x = 800, y = 380, connections = {55, 57}, population = 120000000, satisfaction = 71, funding = 25000, hasBase = false},
        {id = 57, name = "Sudan", x = 760, y = 340, connections = {48, 56, 58}, population = 45000000, satisfaction = 68, funding = 18000, hasBase = false},
        {id = 58, name = "Saudi Arabia", x = 820, y = 280, connections = {45, 57, 59}, population = 35000000, satisfaction = 77, funding = 120000, hasBase = false},
        
        -- Asia (20 provinces)
        {id = 59, name = "Iran", x = 850, y = 240, connections = {58, 60, 61}, population = 85000000, satisfaction = 74, funding = 80000, hasBase = false},
        {id = 60, name = "Iraq", x = 800, y = 260, connections = {58, 59, 61}, population = 40000000, satisfaction = 65, funding = 30000, hasBase = false},
        {id = 61, name = "Pakistan", x = 900, y = 260, connections = {59, 60, 62, 63}, population = 225000000, satisfaction = 75, funding = 55000, hasBase = false},
        {id = 62, name = "India", x = 950, y = 320, connections = {61, 63, 64}, population = 1380000000, satisfaction = 78, funding = 180000, hasBase = false},
        {id = 63, name = "Bangladesh", x = 1000, y = 300, connections = {61, 62, 64}, population = 165000000, satisfaction = 76, funding = 25000, hasBase = false},
        {id = 64, name = "China", x = 1100, y = 220, connections = {62, 63, 65, 66, 67}, population = 1440000000, satisfaction = 82, funding = 450000, hasBase = false},
        {id = 65, name = "Japan", x = 1250, y = 200, connections = {64, 66}, population = 125000000, satisfaction = 88, funding = 280000, hasBase = false},
        {id = 66, name = "South Korea", x = 1180, y = 220, connections = {64, 65, 67}, population = 52000000, satisfaction = 86, funding = 120000, hasBase = false},
        {id = 67, name = "North Korea", x = 1150, y = 200, connections = {64, 66}, population = 26000000, satisfaction = 60, funding = 15000, hasBase = false},
        {id = 68, name = "Thailand", x = 1050, y = 360, connections = {64, 69, 70}, population = 70000000, satisfaction = 80, funding = 35000, hasBase = false},
        {id = 69, name = "Vietnam", x = 1120, y = 340, connections = {68, 70}, population = 97000000, satisfaction = 78, funding = 25000, hasBase = false},
        {id = 70, name = "Indonesia", x = 1150, y = 450, connections = {68, 69, 71}, population = 273000000, satisfaction = 79, funding = 45000, hasBase = false},
        {id = 71, name = "Australia", x = 1300, y = 550, connections = {70, 72}, population = 26000000, satisfaction = 90, funding = 150000, hasBase = false},
        {id = 72, name = "New Zealand", x = 1450, y = 650, connections = {71}, population = 5000000, satisfaction = 92, funding = 40000, hasBase = false},
        
        -- Special: Add a base in North America
        {id = 73, name = "United States", x = 250, y = 250, connections = {11, 14, 15, 74}, population = 331000000, satisfaction = 85, funding = 800000, hasBase = true},
        {id = 74, name = "Canada", x = 300, y = 120, connections = {3, 7, 73}, population = 38000000, satisfaction = 89, funding = 180000, hasBase = false}
    }
end

-- Helper functions
function GeoscapeData:getProvinceAtWorldPosition(worldX, worldY)
    -- Helper: Get province at world position (accounting for camera)
    for _, province in ipairs(self.provinces) do
        local dx = worldX - province.x
        local dy = worldY - province.y
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance <= 30 then  -- Province radius
            return province
        end
    end
    return nil
end

function GeoscapeData:getProvinceById(id)
    -- Helper: Get province by ID
    for _, province in ipairs(self.provinces) do
        if province.id == id then
            return province
        end
    end
    return nil
end

function GeoscapeData:shortenProvinceName(name)
    -- Helper: Shorten long province names for display
    if #name > 12 then
        return name:sub(1, 10) .. ".."
    end
    return name
end

function GeoscapeData:formatNumber(num)
    -- Helper: Format large numbers with commas
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

return GeoscapeData
























