local toml_loader = require "core.util.toml_loader"

-- Test what the parser produces for strings
local test_toml = [[
winpath = "C:\\Users\\nodejs\\templates"
str = "I'm a string. \"You can quote me\". Name\tJosé\nLocation\tSF."
]]

local data = toml_loader.parse(test_toml)
print("winpath:", data.winpath)
print("str:", data.str)
print("winpath repr:", string.format("%q", data.winpath))
print("str repr:", string.format("%q", data.str))
if data.point then
    print("data.point.x:", data.point.x)
    print("data.point.y:", data.point.y)
end

print("data.config:", data.config)
if data.config then
    print("data.config.enabled:", data.config.enabled)
    print("data.config.timeout:", data.config.timeout)
end