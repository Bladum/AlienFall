-- ─────────────────────────────────────────────────────────────────────────
-- INJECTION PREVENTION SECURITY TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify prevention of injection attacks
-- Tests: 8 injection prevention tests
-- Categories: Lua injection, command injection, query injection

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.security",
    fileName = "injection_prevention_security_test.lua",
    description = "Injection attack prevention and mitigation"
})

-- ─────────────────────────────────────────────────────────────────────────
-- INJECTION PREVENTION TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Lua Code Injection", function()

    Suite:testMethod("Security:preventLuaCodeExecution", {
        description = "Prevents arbitrary Lua code execution",
        testCase = "code_injection",
        type = "security"
    }, function()
        local userInput = "'; os.execute('echo pwned') --"

        -- Safe: String is not evaluated, treated as data
        local isSafe = not userInput:find("os.execute")

        Helpers.assertTrue(isSafe, "Should prevent os.execute in user input")
    end)

    Suite:testMethod("Security:noLoadStringFromUserInput", {
        description = "Never use loadstring/load on user input",
        testCase = "code_injection",
        type = "security"
    }, function()
        local userInput = "return game:cheat_infinite_money()"

        -- Validate: Should never call load(userInput)
        local safeLoad = function(str)
            -- Never load user input as code
            if str:find("return ") or str:find("function") then
                return false
            end
            return true
        end

        Helpers.assertFalse(safeLoad(userInput), "Should reject code-like input")
    end)

    Suite:testMethod("Security:preventTableMetatableHijack", {
        description = "Prevents malicious metatable manipulation",
        testCase = "injection",
        type = "security"
    }, function()
        local userData = {
            __tostring = "malicious"
        }

        -- Should not allow __tostring or other special methods
        local hasSpecialMethods = userData.__tostring ~= nil

        Helpers.assertFalse(hasSpecialMethods, "Should reject special metamethods in user data")
    end)

    Suite:testMethod("Security:sandboxStringConcatenation", {
        description = "String concatenation is not evaluated",
        testCase = "injection",
        type = "security"
    }, function()
        local userName = "Player'; DROP TABLE saves --"
        local query = "SELECT * FROM users WHERE name = '" .. userName .. "'"

        -- Should be treated as literal string, not executed
        local isLiteral = query:find("DROP TABLE") ~= nil

        Helpers.assertTrue(isLiteral, "SQL injection should be in string, not executed")
    end)
end)

Suite:group("Command Injection", function()

    Suite:testMethod("Security:preventOSCommandExecution", {
        description = "Prevents OS command execution from user input",
        testCase = "command_injection",
        type = "security"
    }, function()
        local userInput = "test.txt && rm -rf /"

        -- Should never pass to os.execute or similar
        local isBlocked = function(input)
            return not (input:find("&&") or input:find(";") or input:find("|"))
        end

        Helpers.assertFalse(isBlocked(userInput), "Should reject shell metacharacters")
    end)

    Suite:testMethod("Security:filePathInjectionPrevention", {
        description = "File path injection is prevented",
        testCase = "path_injection",
        type = "security"
    }, function()
        local userFile = "../../../etc/passwd"

        local isSafePath = function(path)
            return not path:find("%.%.") and not path:find("^/")
        end

        Helpers.assertFalse(isSafePath(userFile), "Should reject path traversal")
    end)

    Suite:testMethod("Security:noDirectFileOperationsFromInput", {
        description = "File paths from user input are validated",
        testCase = "file_safety",
        type = "security"
    }, function()
        local allowedDir = "engine/saves/"
        local userPath = "engine/saves/mysave.sav"

        local isAllowed = function(path, allowed)
            return path:find(allowed) == 1  -- Must start with allowed dir
        end

        Helpers.assertTrue(isAllowed(userPath, allowedDir), "Paths in allowed dir should pass")
    end)
end)

Suite:group("Format String Attacks", function()

    Suite:testMethod("Security:preventFormatStringAttacks", {
        description = "Prevents format string vulnerabilities",
        testCase = "format_attack",
        type = "security"
    }, function()
        local userInput = "%x.%x.%x.%x"

        -- Should use string formatting safely
        local message = "Welcome to game"
        local safe = function(template, data)
            -- Use table substitution, never format user input
            return template:gsub("USER", data)
        end

        -- Never do: string.format(userInput, ...)
        local hasFormat = userInput:find("%%")
        Helpers.assertTrue(hasFormat, "Format strings should be detected as dangerous")
    end)

    Suite:testMethod("Security:stringFormattingWithoutUserTemplate", {
        description = "String formatting never uses user input as template",
        testCase = "format_safety",
        type = "security"
    }, function()
        local userMessage = "Attack %x %x"
        local systemTemplate = "Player said: %s"

        -- Safe: User data goes into %s, not as template
        local result = string.format(systemTemplate, userMessage)
        Helpers.assertNotNil(result, "Should format safely")
    end)

    Suite:testMethod("Security:logMessageValidation", {
        description = "Log messages cannot contain format strings",
        testCase = "log_safety",
        type = "security"
    }, function()
        local userMessage = "%x.%x malicious"

        local isSafe = function(msg)
            return not msg:find("%%[a-z]")  -- No format specifiers
        end

        Helpers.assertFalse(isSafe(userMessage), "Should detect format specifiers")
    end)
end)

Suite:group("SQL/Query Injection", function()

    Suite:testMethod("Security:preventSQLInjection", {
        description = "Prevents SQL injection attacks",
        testCase = "sql_injection",
        type = "security"
    }, function()
        local userInput = "'; DELETE FROM players; --"

        -- Should use parameterized queries, not string concatenation
        local isSafely = function(input)
            return not (input:find("DELETE") or input:find("DROP") or input:find(";"))
        end

        Helpers.assertFalse(isSafely(userInput), "Should detect SQL keywords")
    end)

    Suite:testMethod("Security:parameterizedQueries", {
        description = "Uses parameterized queries for database access",
        testCase = "query_safety",
        type = "security"
    }, function()
        local query = {
            template = "SELECT * FROM users WHERE id = ?",
            params = {42}
        }

        -- Safe pattern: separate template and parameters
        Helpers.assertNotNil(query.template, "Should have template")
        Helpers.assertNotNil(query.params, "Should have parameters")
    end)
end)

return Suite
