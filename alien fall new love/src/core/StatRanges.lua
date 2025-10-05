-- StatRanges.lua
-- Defines standard stat ranges for units, items, and game balance
-- Based on XCOM/5 scaling where original XCOM values are divided by 5

local StatRanges = {}

-- =============================================================================
-- UNIT STAT RANGES
-- =============================================================================

-- Human stat range (recruit to master)
StatRanges.HUMAN_MIN = 6        -- Junior/recruit level
StatRanges.HUMAN_MAX = 12       -- Master/elite level

-- Other species stat range
StatRanges.OTHER_MIN = 4        -- Weak creatures (rats, etc.)
StatRanges.OTHER_MAX = 20       -- Superhuman/alien entities

-- Morale system
StatRanges.MORALE_START = 10    -- Battle morale starts at 10
StatRanges.MORALE_MIN = 0       -- Minimum morale (panic)
StatRanges.MORALE_MAX = 15      -- Maximum morale (inspired)

-- Bravery determines morale test success rate
-- Bravery 6 = 60% success, Bravery 12 = 120% (always pass)
StatRanges.BRAVERY_MIN = 6
StatRanges.BRAVERY_MAX = 12

-- Energy pool system
StatRanges.ENERGY_MIN = 6       -- Minimum base energy
StatRanges.ENERGY_MAX = 12      -- Maximum base energy
StatRanges.ENERGY_REGEN_MIN = 2 -- Minimum base regen (1/3 of min)
StatRanges.ENERGY_REGEN_MAX = 4 -- Maximum base regen (1/3 of max)

-- =============================================================================
-- WEAPON STAT RANGES (XCOM/5)
-- =============================================================================

-- Damage values
StatRanges.DAMAGE_PISTOL = 5
StatRanges.DAMAGE_RIFLE = 6
StatRanges.DAMAGE_SNIPER = 7
StatRanges.DAMAGE_GRENADE = 10
StatRanges.DAMAGE_HEAVY = 11

-- Range in tiles (15 tiles = 1 map block)
StatRanges.RANGE_SHORT = 15     -- 1 block
StatRanges.RANGE_MEDIUM = 30    -- 2 blocks
StatRanges.RANGE_LONG = 45      -- 3 blocks

-- Action Point costs
StatRanges.AP_PISTOL = 1
StatRanges.AP_RIFLE = 2
StatRanges.AP_HEAVY = 3

-- Energy Point costs
StatRanges.EP_PISTOL = 1
StatRanges.EP_RIFLE = 2
StatRanges.EP_GRENADE = 4
StatRanges.EP_HEAVY = 3

-- Weapon weight (mass units)
StatRanges.WEIGHT_PISTOL = 1
StatRanges.WEIGHT_RIFLE = 2
StatRanges.WEIGHT_GRENADE = 1
StatRanges.WEIGHT_HEAVY = 10

-- Energy pool contributions from weapons
StatRanges.EP_BONUS_SMALL = 5       -- Pistols
StatRanges.EP_BONUS_MEDIUM = 10     -- Rifles
StatRanges.EP_BONUS_LARGE = 15      -- Heavy weapons
StatRanges.EP_BONUS_HUGE = 25       -- Very heavy weapons

-- =============================================================================
-- ARMOR STAT RANGES (XCOM/5)
-- =============================================================================

StatRanges.ARMOR_COVERALLS = 1
StatRanges.ARMOR_SHIELD = 4
StatRanges.ARMOR_LIGHT = 4
StatRanges.ARMOR_MEDIUM = 8
StatRanges.ARMOR_HEAVY = 18
StatRanges.ARMOR_TANK = 24

-- Armor weight
StatRanges.ARMOR_WEIGHT_LIGHT = 4
StatRanges.ARMOR_WEIGHT_MEDIUM = 8
StatRanges.ARMOR_WEIGHT_HEAVY = 12

-- =============================================================================
-- MOVEMENT AND ACTION ECONOMY
-- =============================================================================

-- Action Points per turn = Speed × AP_MULTIPLIER
StatRanges.AP_MULTIPLIER = 4

-- Movement costs
StatRanges.MP_ROTATION_90 = 1   -- 90 degree rotation
StatRanges.MP_TILE_NORMAL = 2   -- Normal terrain
StatRanges.MP_TILE_DIAGONAL = 3 -- Diagonal movement (50% more)
StatRanges.MP_TILE_ROUGH = 4    -- Rough terrain (2x)
StatRanges.MP_TILE_VERY_ROUGH = 6 -- Very rough terrain (3x)
StatRanges.MP_CROUCH_TOGGLE = 4 -- Enable/disable crouch

-- =============================================================================
-- EXPLOSION AND PHYSICS
-- =============================================================================

-- Grenade explosion physics
StatRanges.EXPLOSION_DAMAGE = 10
StatRanges.EXPLOSION_DROPOFF = 2    -- Damage reduction per tile
StatRanges.EXPLOSION_RADIUS = 5     -- Tiles affected
StatRanges.EXPLOSION_BULLETS = 60   -- Radial bullets (every 6 degrees)

-- =============================================================================
-- UI AND RENDERING
-- =============================================================================

-- Grid system
StatRanges.GRID_SIZE = 20           -- Pixels per grid unit
StatRanges.RESOLUTION_WIDTH = 800   -- Internal width (40 grid units)
StatRanges.RESOLUTION_HEIGHT = 600  -- Internal height (30 grid units)

-- Battlefield
StatRanges.MAP_BLOCK_SIZE = 15      -- Tiles per map block

-- =============================================================================
-- VALIDATION FUNCTIONS
-- =============================================================================

--- Validate if a stat is within human range
-- @param value number The stat value to check
-- @return boolean True if within human range
function StatRanges.isHumanRange(value)
    return value >= StatRanges.HUMAN_MIN and value <= StatRanges.HUMAN_MAX
end

--- Validate if a stat is within valid other species range
-- @param value number The stat value to check
-- @return boolean True if within other species range
function StatRanges.isOtherRange(value)
    return value >= StatRanges.OTHER_MIN and value <= StatRanges.OTHER_MAX
end

--- Calculate expected energy regen from base energy
-- @param base_energy number Base energy value
-- @return number Expected regen (1/3 of base)
function StatRanges.calculateExpectedRegen(base_energy)
    return math.floor(base_energy / 3)
end

--- Calculate total AP from speed stat
-- @param speed number Speed stat value
-- @return number Total action points per turn
function StatRanges.calculateTotalAP(speed)
    return speed * StatRanges.AP_MULTIPLIER
end

return StatRanges
