-- Test LuaJIT goto functionality
print("Testing LuaJIT goto...")

-- Test basic goto
local x = 0
::start::
x = x + 1
if x < 3 then goto start end
print("Basic goto test: x =", x)

-- Test goto for continue-like behavior
local sum = 0
for i = 1, 10 do
    if i % 2 == 0 then goto continue end
    sum = sum + i
    ::continue::
end
print("Continue-like goto test: sum of odd numbers 1-10 =", sum)

-- Test goto for break-like behavior
local found = false
for i = 1, 100 do
    if i == 42 then
        found = true
        goto break_loop
    end
end
::break_loop::
print("Break-like goto test: found 42 =", found)

print("All goto tests passed!")