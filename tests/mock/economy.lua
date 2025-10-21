-- Mock Economy Data Generator
-- Provides test data for economic systems, research, manufacturing tests

local MockEconomy = {}

-- Generate finance data
function MockEconomy.getFinances(balance)
    balance = balance or 1000000
    
    return {
        balance = balance,
        
        -- Monthly income
        income = {
            funding = 800000,
            sales = 50000,
            missions = 20000
        },
        
        -- Monthly expenses
        expenses = {
            salaries = 200000,
            maintenance = 150000,
            research = 100000,
            manufacturing = 80000
        },
        
        -- Transaction history
        transactions = {},
        
        -- Monthly summary
        lastMonthIncome = 870000,
        lastMonthExpenses = 530000,
        lastMonthProfit = 340000
    }
end

-- Get a research project
function MockEconomy.getResearchProject(projectType)
    projectType = projectType or "LASER_WEAPONS"
    
    local projects = {
        LASER_WEAPONS = {
            id = "research_laser",
            name = "Laser Weapons",
            description = "Basic laser weapon technology",
            cost = 10000,
            labDays = 100,
            completed = false,
            progress = 0,
            prerequisites = {},
            unlocks = {"LASER_PISTOL", "LASER_RIFLE"}
        },
        ALIEN_BIOLOGY = {
            id = "research_biology",
            name = "Alien Biology",
            description = "Study of alien physiology",
            cost = 5000,
            labDays = 50,
            completed = false,
            progress = 0,
            prerequisites = {},
            unlocks = {"MEDIKIT_ADVANCED"}
        },
        PLASMA_WEAPONS = {
            id = "research_plasma",
            name = "Plasma Weapons",
            description = "Advanced plasma technology",
            cost = 20000,
            labDays = 200,
            completed = false,
            progress = 0,
            prerequisites = {"LASER_WEAPONS"},
            unlocks = {"PLASMA_RIFLE", "PLASMA_CANNON"}
        },
        ARMOR_TECH = {
            id = "research_armor",
            name = "Advanced Armor",
            description = "Improved protective gear",
            cost = 15000,
            labDays = 150,
            completed = false,
            progress = 0,
            prerequisites = {},
            unlocks = {"CARAPACE_ARMOR"}
        },
        UFO_POWER = {
            id = "research_ufo_power",
            name = "UFO Power Source",
            description = "Alien power generation",
            cost = 25000,
            labDays = 250,
            completed = false,
            progress = 0,
            prerequisites = {"ALIEN_BIOLOGY"},
            unlocks = {"POWER_GENERATOR_ADVANCED"}
        }
    }
    
    return projects[projectType] or projects.LASER_WEAPONS
end

-- Get research queue
function MockEconomy.getResearchQueue()
    return {
        current = MockEconomy.getResearchProject("LASER_WEAPONS"),
        queue = {
            MockEconomy.getResearchProject("ALIEN_BIOLOGY"),
            MockEconomy.getResearchProject("ARMOR_TECH")
        },
        scientists = 50,
        dailyProgress = 5
    }
end

-- Get a manufacturing project
function MockEconomy.getManufacturingProject(itemType)
    itemType = itemType or "LASER_RIFLE"
    
    local projects = {
        LASER_RIFLE = {
            id = "mfg_laser_rifle",
            name = "Laser Rifle",
            itemId = "weapon_laser_rifle",
            cost = 5000,
            engineerDays = 20,
            quantity = 1,
            completed = false,
            progress = 0,
            materials = {
                {id = "alloys", amount = 5},
                {id = "elerium", amount = 2}
            }
        },
        CARAPACE_ARMOR = {
            id = "mfg_carapace",
            name = "Carapace Armor",
            itemId = "armor_carapace",
            cost = 8000,
            engineerDays = 30,
            quantity = 1,
            completed = false,
            progress = 0,
            materials = {
                {id = "alloys", amount = 10},
                {id = "fragments", amount = 15}
            }
        },
        INTERCEPTOR = {
            id = "mfg_interceptor",
            name = "Interceptor",
            itemId = "craft_interceptor",
            cost = 50000,
            engineerDays = 200,
            quantity = 1,
            completed = false,
            progress = 0,
            materials = {
                {id = "alloys", amount = 50},
                {id = "elerium", amount = 20}
            }
        }
    }
    
    return projects[itemType] or projects.LASER_RIFLE
end

-- Get manufacturing queue
function MockEconomy.getManufacturingQueue()
    return {
        current = MockEconomy.getManufacturingProject("LASER_RIFLE"),
        queue = {
            MockEconomy.getManufacturingProject("CARAPACE_ARMOR")
        },
        engineers = 50,
        dailyProgress = 10
    }
end

-- Get material inventory
function MockEconomy.getMaterials()
    return {
        {id = "alloys", name = "Alien Alloys", amount = 100, weight = 1},
        {id = "elerium", name = "Elerium-115", amount = 50, weight = 1},
        {id = "fragments", name = "Alien Fragments", amount = 200, weight = 0.5},
        {id = "meld", name = "MELD", amount = 25, weight = 1},
        {id = "ufo_power", name = "UFO Power Source", amount = 5, weight = 5}
    }
end

-- Get marketplace item for sale
function MockEconomy.getMarketItem(itemType)
    itemType = itemType or "LASER_RIFLE"
    
    return {
        id = itemType,
        name = itemType:gsub("_", " "),
        sellPrice = 10000,
        buyPrice = 25000,
        available = true,
        stock = 10,
        category = "WEAPONS"
    }
end

-- Generate funding from countries
function MockEconomy.getFundingReport()
    return {
        month = "January",
        year = 2025,
        
        countries = {
            {name = "USA", funding = 200000, panic = 2, satisfaction = 8},
            {name = "UK", funding = 150000, panic = 1, satisfaction = 9},
            {name = "Germany", funding = 180000, panic = 3, satisfaction = 7},
            {name = "Japan", funding = 120000, panic = 2, satisfaction = 8},
            {name = "Russia", funding = 150000, panic = 4, satisfaction = 6}
        },
        
        totalFunding = 800000,
        bonusFunding = 50000,
        penalties = -20000
    }
end

-- Get salary information
function MockEconomy.getSalaries()
    return {
        soldiers = {
            ROOKIE = 1000,
            SQUADDIE = 1500,
            CORPORAL = 2000,
            SERGEANT = 2500,
            LIEUTENANT = 3500,
            CAPTAIN = 5000,
            MAJOR = 7000,
            COLONEL = 10000
        },
        scientists = 2000,
        engineers = 1500
    }
end

return MockEconomy



