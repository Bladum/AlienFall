--[[
  Spritesheet Generator Engine

  Responsibilities:
  - Coordinate multiple armies
  - Manage print settings
  - Generate all spritesheets
  - Report results
]]--

local Generator = {}

-- Configuration constants
Generator.PRINT_SETTINGS = {
    A4 = {
        format = "A4",
        width_px = 2480,
        height_px = 3508,
        dpi = 300,
        width_mm = 210,
        height_mm = 297
    }
}

Generator.DEFAULT_GRID = {
    columns = 10,
    rows = 15,
    cell_size = 64,
    spacing = 8,
    border = 4
}

-- Create new generator instance
function Generator.new()
    local self = setmetatable({}, { __index = Generator })

    self.armies = {}
    self.results = {}
    self.config = {
        print = Generator.PRINT_SETTINGS.A4,
        grid = Generator.DEFAULT_GRID,
        output_dir = "output"
    }

    return self
end

-- Add army to generator
function Generator:addArmy(army)
    table.insert(self.armies, army)
    print("[Generator] Added army: " .. army.name)
end

-- Generate all armies
function Generator:generateAll()
    print("\n========================================")
    print("SPRITESHEET GENERATOR - BATCH MODE")
    print("========================================\n")

    print("[Generator] Processing " .. #self.armies .. " armies...\n")

    for i, army in ipairs(self.armies) do
        print("[Generator] [" .. i .. "/" .. #self.armies .. "]")

        local success = army:generate(self.config.output_dir)

        table.insert(self.results, {
            army_name = army.name,
            success = success,
            errors = army.errors
        })
    end

    return self:printSummary()
end

-- Print summary
function Generator:printSummary()
    print("\n========================================")
    print("GENERATION COMPLETE")
    print("========================================\n")

    local success_count = 0
    local failed_count = 0

    for _, result in ipairs(self.results) do
        if result.success then
            print("✓ " .. result.army_name)
            success_count = success_count + 1
        else
            print("✗ " .. result.army_name)
            for _, err in ipairs(result.errors) do
                print("  → " .. err)
            end
            failed_count = failed_count + 1
        end
    end

    print("\n[Generator] Summary: " .. success_count .. " generated, " .. failed_count .. " failed")
    print("[Generator] Output directory: " .. self.config.output_dir)
    print("[Generator] ========================================\n")

    return failed_count == 0
end

-- Get statistics
function Generator:getStats()
    return {
        total_armies = #self.armies,
        results = self.results,
        config = self.config
    }
end

return Generator
