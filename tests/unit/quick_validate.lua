-- Quick validation test
print("Testing module loading...")

-- Test Pathfinding
local success1, Pathfinding = pcall(require, "core.pathfinding")
if success1 then
    print("✓ Pathfinding loaded")
    if Pathfinding.findPath then
        print("✓ Pathfinding.findPath exists")
    else
        print("✗ Pathfinding.findPath missing")
    end
else
    print("✗ Pathfinding failed to load: " .. tostring(Pathfinding))
end

-- Test LOS
local success2, LOS = pcall(require, "battlescape.combat.los_optimized")
if success2 then
    print("✓ LOS loaded")
    if LOS.hasLineOfSight then
        print("✓ LOS.hasLineOfSight exists")
    else
        print("✗ LOS.hasLineOfSight missing")
    end
else
    print("✗ LOS failed to load: " .. tostring(LOS))
end

print("Validation complete.")





















