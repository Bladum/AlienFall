-- Test Framework: Helper Methods
-- Common utilities for writing tests

local Assertions = require("tests.framework.assertions")

local Helpers = {}

---Create a mock object with specified properties
function Helpers.createMock(props)
    props = props or {}

    local mock = {}

    -- Set properties
    for key, value in pairs(props) do
        mock[key] = value
    end

    -- Track method calls
    mock.__calls = {}

    -- Create method tracker
    setmetatable(mock, {
        __index = function(_, key)
            return function(...)
                table.insert(mock.__calls, {method = key, args = {...}})
                return nil
            end
        end
    })

    return mock
end

---Assert a mock was called with specific arguments
function Helpers.assertMockCalled(mock, methodName, args)
    Assertions.assertIsNotNil(mock.__calls, "Not a mock object")

    local found = false
    for _, call in ipairs(mock.__calls) do
        if call.method == methodName then
            if not args then
                found = true
                break
            elseif #call.args == #args then
                local match = true
                for i, arg in ipairs(args) do
                    if call.args[i] ~= arg then
                        match = false
                        break
                    end
                end
                if match then
                    found = true
                    break
                end
            end
        end
    end

    Assertions.assertTrue(found, methodName .. " was not called")
end

---Get mock call count for method
function Helpers.getMockCallCount(mock, methodName)
    Assertions.assertIsNotNil(mock.__calls, "Not a mock object")

    local count = 0
    for _, call in ipairs(mock.__calls) do
        if call.method == methodName then
            count = count + 1
        end
    end

    return count
end

---Clear mock call history
function Helpers.clearMockCalls(mock)
    mock.__calls = {}
end

---Create a spy wrapper around a real function
function Helpers.createSpy(fn)
    Assertions.assertIsFunction(fn, "Must pass a function to spy on")

    local spy = {
        calls = {},
        callCount = 0,
        returnValue = nil
    }

    setmetatable(spy, {
        __call = function(_, ...)
            table.insert(spy.calls, {...})
            spy.callCount = spy.callCount + 1
            return fn(...)
        end
    })

    return spy
end

---Assert spy was called N times
function Helpers.assertSpyCalled(spy, count)
    Assertions.assertIsNotNil(spy.callCount, "Not a spy object")
    Assertions.assertEqual(spy.callCount, count,
        "Expected spy to be called " .. count .. " times, got " .. spy.callCount)
end

---Create a table copy (shallow)
function Helpers.copyTable(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = v
    end
    return copy
end

---Create a table copy (deep)
function Helpers.deepCopyTable(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = Helpers.deepCopyTable(v)
        else
            copy[k] = v
        end
    end
    return copy
end

---Wait for condition (with timeout)
function Helpers.waitFor(condition, maxWaitSeconds)
    maxWaitSeconds = maxWaitSeconds or 1

    local endTime = os.clock() + maxWaitSeconds

    while os.clock() < endTime do
        if condition() then
            return true
        end
        -- Small sleep to not spin
        os.execute("timeout /t 0 /nobreak")  -- Windows sleep
    end

    return false
end

---Create a fixture for setup/teardown
function Helpers.createFixture(setupFn, teardownFn)
    return {
        setup = setupFn,
        teardown = teardownFn,

        run = function(testFn)
            local self = this
            self:setup()
            local success, result = pcall(testFn)
            self:teardown()

            if not success then
                error(result)
            end

            return result
        end
    }
end

---Compare two objects for equality (recursive)
function Helpers.objectsEqual(obj1, obj2)
    if obj1 == obj2 then
        return true
    end

    local t1 = type(obj1)
    local t2 = type(obj2)

    if t1 ~= t2 then
        return false
    end

    if t1 ~= "table" then
        return false
    end

    -- Compare tables
    for key in pairs(obj1) do
        if not Helpers.objectsEqual(obj1[key], obj2[key]) then
            return false
        end
    end

    for key in pairs(obj2) do
        if not Helpers.objectsEqual(obj1[key], obj2[key]) then
            return false
        end
    end

    return true
end

---Convert object to string for display
function Helpers.objectToString(obj, indent)
    indent = indent or 0

    if obj == nil then
        return "nil"
    elseif type(obj) == "boolean" then
        return tostring(obj)
    elseif type(obj) == "number" then
        return tostring(obj)
    elseif type(obj) == "string" then
        return '"' .. obj .. '"'
    elseif type(obj) == "function" then
        return "[function]"
    elseif type(obj) == "table" then
        local parts = {}
        local prefix = string.rep("  ", indent)

        table.insert(parts, "{")
        for k, v in pairs(obj) do
            local keyStr = k
            if type(k) == "string" then
                keyStr = '"' .. k .. '"'
            end

            local valueStr = Helpers.objectToString(v, indent + 1)
            table.insert(parts, prefix .. "  " .. keyStr .. " = " .. valueStr)
        end
        table.insert(parts, prefix .. "}")

        return table.concat(parts, "\n")
    else
        return "[" .. type(obj) .. "]"
    end
end

---Get unique elements from array
function Helpers.getUnique(array)
    local seen = {}
    local result = {}

    for _, v in ipairs(array) do
        if not seen[v] then
            seen[v] = true
            table.insert(result, v)
        end
    end

    return result
end

---Filter array by predicate
function Helpers.filter(array, predicate)
    local result = {}
    for _, v in ipairs(array) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

---Map array with function
function Helpers.map(array, fn)
    local result = {}
    for _, v in ipairs(array) do
        table.insert(result, fn(v))
    end
    return result
end

---Reduce array with accumulator
function Helpers.reduce(array, fn, initial)
    local acc = initial
    for _, v in ipairs(array) do
        acc = fn(acc, v)
    end
    return acc
end

return Helpers
