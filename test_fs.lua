print("Testing filesystem...")
local items = love.filesystem.getDirectoryItems("engine")
print("engine/ contains:", #items, "items")
for i, item in ipairs(items) do
    print(i, item)
end

local mods_items = love.filesystem.getDirectoryItems("engine/mods")
print("engine/mods contains:", #mods_items, "items")
for i, item in ipairs(mods_items) do
    print(i, item)
end