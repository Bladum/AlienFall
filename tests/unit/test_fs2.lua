print("Testing filesystem from engine/...")
local items = love.filesystem.getDirectoryItems("mods")
print("mods/ contains:", #items, "items")
for i, item in ipairs(items) do
    print(i, item)
end
























