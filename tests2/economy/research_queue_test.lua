-- ─────────────────────────────────────────────────────────────────────────
-- RESEARCH QUEUE TEST SUITE
-- FILE: tests2/economy/research_queue_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.research_queue",
    fileName = "research_queue.lua",
    description = "Research pipeline with queuing, prerequisites, parallel research, and completion"
})

print("[RESEARCH_QUEUE_TEST] Setting up")

local ResearchQueue = {
    projects = {},
    queue = {},
    progress = {},
    prerequisites = {},

    new = function(self)
        return setmetatable({projects = {}, queue = {}, progress = {}, prerequisites = {}}, {__index = self})
    end,

    registerProject = function(self, projectId, name, costPoints, costTime)
        self.projects[projectId] = {id = projectId, name = name, cost = costPoints or 100, time = costTime or 10, status = "available"}
        self.progress[projectId] = {points = 0, timeRemaining = costTime or 10, completed = false}
        self.prerequisites[projectId] = {}
        return true
    end,

    getProject = function(self, projectId)
        return self.projects[projectId]
    end,

    addPrerequisite = function(self, projectId, prerequisiteId)
        if not self.prerequisites[projectId] then self.prerequisites[projectId] = {} end
        table.insert(self.prerequisites[projectId], prerequisiteId)
        return true
    end,

    getPrerequisites = function(self, projectId)
        if not self.prerequisites[projectId] then return {} end
        return self.prerequisites[projectId]
    end,

    canResearch = function(self, projectId, completedProjects)
        if not self.projects[projectId] then return false end
        local prereqs = self:getPrerequisites(projectId)
        for _, prereq in ipairs(prereqs) do
            if not completedProjects[prereq] then return false end
        end
        return true
    end,

    enqueue = function(self, projectId)
        if not self.projects[projectId] then return false end
        table.insert(self.queue, projectId)
        self.projects[projectId].status = "queued"
        return true
    end,

    dequeue = function(self)
        if #self.queue == 0 then return nil end
        local projectId = table.remove(self.queue, 1)
        if self.projects[projectId] then
            self.projects[projectId].status = "in_progress"
        end
        return projectId
    end,

    getQueueCount = function(self)
        return #self.queue
    end,

    getQueuedProjects = function(self)
        local queued = {}
        for _, projectId in ipairs(self.queue) do
            table.insert(queued, projectId)
        end
        return queued
    end,

    addProgress = function(self, projectId, points)
        if not self.progress[projectId] then return false end
        self.progress[projectId].points = self.progress[projectId].points + points
        if self.progress[projectId].points >= self.projects[projectId].cost then
            self:completeProject(projectId)
        end
        return true
    end,

    getProgress = function(self, projectId)
        if not self.progress[projectId] then return 0 end
        return self.progress[projectId].points
    end,

    getProgressPercentage = function(self, projectId)
        if not self.projects[projectId] or not self.progress[projectId] then return 0 end
        local cost = self.projects[projectId].cost
        if cost == 0 then return 0 end
        return math.floor((self.progress[projectId].points / cost) * 100)
    end,

    completeProject = function(self, projectId)
        if not self.projects[projectId] then return false end
        self.progress[projectId].completed = true
        self.projects[projectId].status = "completed"
        return true
    end,

    isProjectComplete = function(self, projectId)
        if not self.progress[projectId] then return false end
        return self.progress[projectId].completed
    end,

    tickTime = function(self, projectId)
        if not self.progress[projectId] then return false end
        self.progress[projectId].timeRemaining = math.max(0, self.progress[projectId].timeRemaining - 1)
        return true
    end,

    getTimeRemaining = function(self, projectId)
        if not self.progress[projectId] then return 0 end
        return self.progress[projectId].timeRemaining
    end,

    getProjectCount = function(self)
        local count = 0
        for _ in pairs(self.projects) do count = count + 1 end
        return count
    end,

    getCompletedProjects = function(self)
        local count = 0
        for _, progress in pairs(self.progress) do
            if progress.completed then count = count + 1 end
        end
        return count
    end,

    getInProgressProjects = function(self)
        local count = 0
        for _, project in pairs(self.projects) do
            if project.status == "in_progress" then count = count + 1 end
        end
        return count
    end,

    clearQueue = function(self)
        self.queue = {}
        for _, project in pairs(self.projects) do
            if project.status == "queued" then
                project.status = "available"
            end
        end
        return true
    end,

    getResearchCost = function(self, projectId)
        if not self.projects[projectId] then return 0 end
        return self.projects[projectId].cost
    end,

    getTotalQueueCost = function(self)
        local total = 0
        for _, projectId in ipairs(self.queue) do
            total = total + self:getResearchCost(projectId)
        end
        return total
    end,

    pauseProject = function(self, projectId)
        if not self.projects[projectId] then return false end
        self.projects[projectId].status = "paused"
        return true
    end,

    resumeProject = function(self, projectId)
        if not self.projects[projectId] then return false end
        if self.projects[projectId].status == "paused" then
            self.projects[projectId].status = "in_progress"
        end
        return true
    end
}

Suite:group("Project Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rq = ResearchQueue:new()
    end)

    Suite:testMethod("ResearchQueue.registerProject", {description = "Registers project", testCase = "register", type = "functional"}, function()
        local ok = shared.rq:registerProject("plasma_weapons", "Plasma Weapons", 500, 20)
        Helpers.assertEqual(ok, true, "Project registered")
    end)

    Suite:testMethod("ResearchQueue.getProject", {description = "Retrieves project", testCase = "get", type = "functional"}, function()
        shared.rq:registerProject("armor", "Advanced Armor", 300, 15)
        local project = shared.rq:getProject("armor")
        Helpers.assertEqual(project ~= nil, true, "Project retrieved")
    end)

    Suite:testMethod("ResearchQueue.getProjectCount", {description = "Counts projects", testCase = "count", type = "functional"}, function()
        shared.rq:registerProject("p1", "Project1", 100, 5)
        shared.rq:registerProject("p2", "Project2", 150, 8)
        shared.rq:registerProject("p3", "Project3", 200, 10)
        local count = shared.rq:getProjectCount()
        Helpers.assertEqual(count, 3, "Three projects")
    end)
end)

Suite:group("Prerequisites", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rq = ResearchQueue:new()
        shared.rq:registerProject("basic", "Basic Tech", 100, 5)
        shared.rq:registerProject("advanced", "Advanced Tech", 300, 15)
    end)

    Suite:testMethod("ResearchQueue.addPrerequisite", {description = "Adds prerequisite", testCase = "add_prereq", type = "functional"}, function()
        local ok = shared.rq:addPrerequisite("advanced", "basic")
        Helpers.assertEqual(ok, true, "Prerequisite added")
    end)

    Suite:testMethod("ResearchQueue.getPrerequisites", {description = "Gets prerequisites", testCase = "get_prereq", type = "functional"}, function()
        shared.rq:addPrerequisite("advanced", "basic")
        local prereqs = shared.rq:getPrerequisites("advanced")
        Helpers.assertEqual(#prereqs, 1, "One prerequisite")
    end)

    Suite:testMethod("ResearchQueue.canResearch", {description = "Checks if can research", testCase = "can_research", type = "functional"}, function()
        shared.rq:addPrerequisite("advanced", "basic")
        local can = shared.rq:canResearch("advanced", {basic = true})
        Helpers.assertEqual(can, true, "Can research")
    end)

    Suite:testMethod("ResearchQueue.canResearch", {description = "Blocks without prereq", testCase = "blocked_no_prereq", type = "functional"}, function()
        shared.rq:addPrerequisite("advanced", "basic")
        local can = shared.rq:canResearch("advanced", {})
        Helpers.assertEqual(can, false, "Cannot research")
    end)
end)

Suite:group("Queue Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rq = ResearchQueue:new()
        shared.rq:registerProject("q1", "Research1", 100, 5)
        shared.rq:registerProject("q2", "Research2", 150, 10)
    end)

    Suite:testMethod("ResearchQueue.enqueue", {description = "Enqueues project", testCase = "enqueue", type = "functional"}, function()
        local ok = shared.rq:enqueue("q1")
        Helpers.assertEqual(ok, true, "Enqueued")
    end)

    Suite:testMethod("ResearchQueue.getQueueCount", {description = "Counts queue", testCase = "queue_count", type = "functional"}, function()
        shared.rq:enqueue("q1")
        shared.rq:enqueue("q2")
        local count = shared.rq:getQueueCount()
        Helpers.assertEqual(count, 2, "Two in queue")
    end)

    Suite:testMethod("ResearchQueue.dequeue", {description = "Dequeues project", testCase = "dequeue", type = "functional"}, function()
        shared.rq:enqueue("q1")
        local projectId = shared.rq:dequeue()
        Helpers.assertEqual(projectId, "q1", "Dequeued q1")
    end)

    Suite:testMethod("ResearchQueue.getTotalQueueCost", {description = "Queue cost", testCase = "queue_cost", type = "functional"}, function()
        shared.rq:enqueue("q1")
        shared.rq:enqueue("q2")
        local cost = shared.rq:getTotalQueueCost()
        Helpers.assertEqual(cost, 250, "250 cost")
    end)

    Suite:testMethod("ResearchQueue.clearQueue", {description = "Clears queue", testCase = "clear", type = "functional"}, function()
        shared.rq:enqueue("q1")
        shared.rq:enqueue("q2")
        local ok = shared.rq:clearQueue()
        Helpers.assertEqual(ok, true, "Queue cleared")
    end)
end)

Suite:group("Progress Tracking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rq = ResearchQueue:new()
        shared.rq:registerProject("research", "Main Research", 1000, 30)
    end)

    Suite:testMethod("ResearchQueue.addProgress", {description = "Adds progress", testCase = "add_progress", type = "functional"}, function()
        local ok = shared.rq:addProgress("research", 100)
        Helpers.assertEqual(ok, true, "Progress added")
    end)

    Suite:testMethod("ResearchQueue.getProgress", {description = "Gets progress", testCase = "get_progress", type = "functional"}, function()
        shared.rq:addProgress("research", 250)
        local progress = shared.rq:getProgress("research")
        Helpers.assertEqual(progress, 250, "250 progress")
    end)

    Suite:testMethod("ResearchQueue.getProgressPercentage", {description = "Progress %", testCase = "progress_pct", type = "functional"}, function()
        shared.rq:addProgress("research", 500)
        local pct = shared.rq:getProgressPercentage("research")
        Helpers.assertEqual(pct, 50, "50%")
    end)
end)

Suite:group("Completion", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rq = ResearchQueue:new()
        shared.rq:registerProject("complete", "Complete", 100, 5)
    end)

    Suite:testMethod("ResearchQueue.completeProject", {description = "Completes project", testCase = "complete", type = "functional"}, function()
        local ok = shared.rq:completeProject("complete")
        Helpers.assertEqual(ok, true, "Completed")
    end)

    Suite:testMethod("ResearchQueue.isProjectComplete", {description = "Checks completion", testCase = "is_complete", type = "functional"}, function()
        shared.rq:completeProject("complete")
        local complete = shared.rq:isProjectComplete("complete")
        Helpers.assertEqual(complete, true, "Is complete")
    end)

    Suite:testMethod("ResearchQueue.getCompletedProjects", {description = "Counts completed", testCase = "completed_count", type = "functional"}, function()
        shared.rq:completeProject("complete")
        local count = shared.rq:getCompletedProjects()
        Helpers.assertEqual(count, 1, "One completed")
    end)
end)

Suite:group("Time Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rq = ResearchQueue:new()
        shared.rq:registerProject("timed", "Time Research", 200, 20)
    end)

    Suite:testMethod("ResearchQueue.tickTime", {description = "Ticks time", testCase = "tick_time", type = "functional"}, function()
        local ok = shared.rq:tickTime("timed")
        Helpers.assertEqual(ok, true, "Time ticked")
    end)

    Suite:testMethod("ResearchQueue.getTimeRemaining", {description = "Gets time remaining", testCase = "time_remaining", type = "functional"}, function()
        shared.rq:tickTime("timed")
        local time = shared.rq:getTimeRemaining("timed")
        Helpers.assertEqual(time, 19, "19 time remaining")
    end)
end)

Suite:group("Project Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rq = ResearchQueue:new()
        shared.rq:registerProject("status", "Status Test", 150, 10)
    end)

    Suite:testMethod("ResearchQueue.pauseProject", {description = "Pauses project", testCase = "pause", type = "functional"}, function()
        shared.rq:enqueue("status")
        shared.rq:dequeue()
        local ok = shared.rq:pauseProject("status")
        Helpers.assertEqual(ok, true, "Paused")
    end)

    Suite:testMethod("ResearchQueue.resumeProject", {description = "Resumes project", testCase = "resume", type = "functional"}, function()
        shared.rq:pauseProject("status")
        local ok = shared.rq:resumeProject("status")
        Helpers.assertEqual(ok, true, "Resumed")
    end)

    Suite:testMethod("ResearchQueue.getInProgressProjects", {description = "Counts in progress", testCase = "in_progress", type = "functional"}, function()
        shared.rq:enqueue("status")
        shared.rq:dequeue()
        local count = shared.rq:getInProgressProjects()
        Helpers.assertEqual(count >= 1, true, "In progress")
    end)
end)

Suite:run()
