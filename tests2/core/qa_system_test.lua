-- ─────────────────────────────────────────────────────────────────────────
-- QA SYSTEM TEST SUITE
-- FILE: tests2/core/qa_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.systems.qa_system",
    fileName = "qa_system.lua",
    description = "QA system for testing and debugging"
})

print("[QA_SYSTEM_TEST] Setting up")

local QASystem = {
    enabled = true,
    debugMode = false,
    logLevel = "info",
    issues = {},
    nextIssueId = 1,

    enable = function(self) self.enabled = true; return true end,
    disable = function(self) self.enabled = false; return true end,
    isEnabled = function(self) return self.enabled end,

    setDebugMode = function(self, enabled) self.debugMode = enabled; return true end,
    isDebugMode = function(self) return self.debugMode end,

    setLogLevel = function(self, level)
        if level ~= "debug" and level ~= "info" and level ~= "warn" and level ~= "error" then
            return false
        end
        self.logLevel = level
        return true
    end,

    getLogLevel = function(self) return self.logLevel end,

    reportIssue = function(self, title, description, severity)
        if not title then return false end
        table.insert(self.issues, {
            id = self.nextIssueId,
            title = title,
            description = description or "",
            severity = severity or "normal"
        })
        self.nextIssueId = self.nextIssueId + 1
        return true
    end,

    getIssues = function(self, severity)
        if not severity then return self.issues end
        local filtered = {}
        for _, issue in ipairs(self.issues) do
            if issue.severity == severity then
                table.insert(filtered, issue)
            end
        end
        return filtered
    end,

    clearIssues = function(self) self.issues = {}; return true end
}

Suite:group("QA Control", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.qa = setmetatable({enabled = true, debugMode = false, logLevel = "info", issues = {}, nextIssueId = 1}, {__index = QASystem})
    end)

    Suite:testMethod("QASystem.enable", {description = "Enables QA system", testCase = "enable", type = "functional"}, function()
        shared.qa:disable()
        local ok = shared.qa:enable()
        Helpers.assertEqual(ok, true, "Enable successful")
        Helpers.assertEqual(shared.qa:isEnabled(), true, "QA enabled")
    end)

    Suite:testMethod("QASystem.disable", {description = "Disables QA system", testCase = "disable", type = "functional"}, function()
        local ok = shared.qa:disable()
        Helpers.assertEqual(ok, true, "Disable successful")
        Helpers.assertEqual(shared.qa:isEnabled(), false, "QA disabled")
    end)

    Suite:testMethod("QASystem.setDebugMode", {description = "Sets debug mode", testCase = "debug_mode", type = "functional"}, function()
        shared.qa:setDebugMode(true)
        Helpers.assertEqual(shared.qa:isDebugMode(), true, "Debug mode enabled")
    end)
end)

Suite:group("Logging", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.qa = setmetatable({enabled = true, debugMode = false, logLevel = "info", issues = {}, nextIssueId = 1}, {__index = QASystem})
    end)

    Suite:testMethod("QASystem.setLogLevel", {description = "Sets log level", testCase = "set_level", type = "functional"}, function()
        local ok = shared.qa:setLogLevel("debug")
        Helpers.assertEqual(ok, true, "Level set")
        Helpers.assertEqual(shared.qa:getLogLevel(), "debug", "Log level changed")
    end)

    Suite:testMethod("QASystem.setLogLevel", {description = "Rejects invalid level", testCase = "invalid_level", type = "functional"}, function()
        local ok = shared.qa:setLogLevel("invalid")
        Helpers.assertEqual(ok, false, "Invalid level rejected")
    end)
end)

Suite:group("Issue Reporting", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.qa = setmetatable({enabled = true, debugMode = false, logLevel = "info", issues = {}, nextIssueId = 1}, {__index = QASystem})
    end)

    Suite:testMethod("QASystem.reportIssue", {description = "Reports issue", testCase = "report", type = "functional"}, function()
        local ok = shared.qa:reportIssue("Bug found", "Description", "critical")
        Helpers.assertEqual(ok, true, "Issue reported")
    end)

    Suite:testMethod("QASystem.getIssues", {description = "Retrieves all issues", testCase = "get_all", type = "functional"}, function()
        shared.qa:reportIssue("Issue 1", "", "normal")
        shared.qa:reportIssue("Issue 2", "", "critical")
        local issues = shared.qa:getIssues()
        Helpers.assertEqual(#issues, 2, "Two issues retrieved")
    end)

    Suite:testMethod("QASystem.getIssues", {description = "Filters by severity", testCase = "filter_severity", type = "functional"}, function()
        shared.qa:reportIssue("Issue 1", "", "normal")
        shared.qa:reportIssue("Issue 2", "", "critical")
        local critical = shared.qa:getIssues("critical")
        Helpers.assertEqual(#critical, 1, "One critical issue")
    end)

    Suite:testMethod("QASystem.clearIssues", {description = "Clears all issues", testCase = "clear", type = "functional"}, function()
        shared.qa:reportIssue("Issue 1", "", "normal")
        shared.qa:clearIssues()
        local issues = shared.qa:getIssues()
        Helpers.assertEqual(#issues, 0, "Issues cleared")
    end)
end)

Suite:run()
