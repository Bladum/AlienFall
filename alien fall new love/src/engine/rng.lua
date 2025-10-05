--- RNG Service for deterministic random number generation
-- Provides seeded random number generation with telemetry support
-- Ensures deterministic behavior for game replays and testing
--
-- @module engine.rng

local class = require 'lib.Middleclass'

local RngService = class('RngService')

local DEFAULT_SEED = 1337

--- Hash function for generating deterministic seeds from strings
-- Uses djb2 algorithm for consistent hashing
-- @param str string: Input string to hash
-- @return number: Hash value for seeding
local function djb2(str)
    local hash = 5381
    for i = 1, #str do
        hash = ((hash * 33) + string.byte(str, i)) % 2147483647
    end
    return hash
end

--- Create a random number handle for a specific scope
-- Handles provide isolated random number generation with telemetry
-- @param scope string: Scope identifier for this handle
-- @param generator table: Love2D random generator instance
-- @param telemetry table: Optional telemetry service for tracking
-- @return table: Handle with random number methods
local function buildHandle(scope, generator, telemetry)
    local handle = {}

    --- Generate random integer within range
    -- @param min number: Minimum value (inclusive)
    -- @param max number: Maximum value (inclusive)
    -- @return number: Random integer
    function handle:random(min, max)
        local value
        if min and max then
            value = generator:random(min, max)
        elseif min then
            value = generator:random(min)
        else
            value = generator:random()
        end

        if telemetry then
            telemetry:recordEvent({
                type = "rng",
                scope = scope,
                value = value
            })
        end

        return value
    end

    --- Generate random float between 0 and 1
    -- @return number: Random float in range [0, 1)
    function handle:randomFloat()
        local value = generator:random()
        if telemetry then
            telemetry:recordEvent({
                type = "rng",
                scope = scope,
                value = value
            })
        end
        return value
    end

    --- Generate random float within specified range
    -- @param min number: Minimum value
    -- @param max number: Maximum value
    -- @return number: Random float in range [min, max)
    function handle:randomRange(min, max)
        assert(type(min) == "number" and type(max) == "number" and max >= min,
            "randomRange expects numeric min/max")
        local value = min + (max - min) * generator:random()
        if telemetry then
            telemetry:recordEvent({
                type = "rng",
                scope = scope,
                value = value
            })
        end
        return value
    end

    --- Shuffle a table in-place using Fisher-Yates algorithm
    -- @param list table: Table to shuffle
    -- @return table: The same table, shuffled
    function handle:shuffle(list)
        assert(type(list) == "table", "shuffle expects a table list")
        for i = #list, 2, -1 do
            local j = generator:random(1, i)
            list[i], list[j] = list[j], list[i]
        end
        if telemetry then
            telemetry:recordEvent({
                type = "rng-shuffle",
                scope = scope,
                size = #list
            })
        end
        return list
    end

    --- Get the current seed of this handle's generator
    -- @return number: Current seed value
    function handle:getSeed()
        return generator:getSeed()
    end

    return handle
end

--- Create a new RNG service instance
-- @param opts table: Configuration options
-- @param opts.telemetry table: Optional telemetry service
-- @return RngService: New service instance
function RngService:initialize(opts)
    self.telemetry = opts and opts.telemetry or nil
    self.scopes = {}  -- Cache of created scopes
    self.baseSeed = DEFAULT_SEED
end

--- Set the base seed for all random number generation
-- Resets all existing scopes when changed
-- @param seed number: New base seed value
function RngService:seed(seed)
    assert(type(seed) == "number", "seed must be a number")
    self.baseSeed = math.floor(seed)
    self.scopes = {}  -- Clear existing scopes on seed change
    if self.telemetry then
        self.telemetry:recordEvent({
            type = "rng-root-seed",
            seed = self.baseSeed
        })
    end
end

--- Create composite key from scope and context
-- Used for deterministic seeding of related random sequences
-- @param scope string: Primary scope identifier
-- @param context string: Optional context for sub-scoping
-- @return string: Composite key for seeding
local function compositeKey(scope, context)
    if context and context ~= "" then
        return scope .. "::" .. context
    end
    return scope
end

--- Request a random number handle for a specific scope
-- Creates or returns cached handle for deterministic generation
-- @param scope string: Scope identifier (must be non-empty)
-- @param options table: Optional configuration
-- @param options.context string: Sub-scope context
-- @param options.reset boolean: Force recreation of handle
-- @param options.seed number: Override seed for this scope
-- @return table: Random number handle
function RngService:requestScope(scope, options)
    assert(type(scope) == "string" and scope ~= "", "scope name must be non-empty string")
    local context = options and options.context or nil
    local key = compositeKey(scope, context)
    local existing = self.scopes[key]
    local reset = options and options.reset or false

    if existing and not reset then
        return existing.handle
    end

    local seedOverride = options and options.seed or nil
    local seed
    if seedOverride then
        seed = seedOverride
    else
        -- Generate deterministic seed from base seed and scope key
        seed = self.baseSeed + djb2(key)
    end

    local generator
    if love and love.math and love.math.newRandomGenerator then
        -- Use Love2D's deterministic random generator
        generator = love.math.newRandomGenerator(seed)
    else
        -- Fallback for testing outside Love2D environment
        math.randomseed(seed)
        generator = {
            random = function(_, a, b)
                if a and b then
                    return math.random(a, b)
                elseif a then
                    return math.random(a)
                end
                return math.random()
            end,
            getSeed = function()
                return seed
            end
        }
    end

    local handle = buildHandle(key, generator, self.telemetry)
    self.scopes[key] = {
        generator = generator,
        handle = handle,
        seed = seed
    }

    if self.telemetry then
        self.telemetry:recordEvent({
            type = "rng-scope",
            scope = key,
            seed = seed
        })
    end

    return handle
end

--- Get the seed used for a specific scope
-- Returns nil if scope doesn't exist
-- @param scope string: Scope identifier
-- @param options table: Optional context
-- @param options.context string: Sub-scope context
-- @return number|nil: Seed value or nil if not found
function RngService:getSeed(scope, options)
    local context = options and options.context or nil
    local key = compositeKey(scope, context)
    local entry = self.scopes[key]
    return entry and entry.seed or nil
end

return RngService
