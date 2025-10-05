--- Research Service Tests
-- Tests for the ResearchService class

local lust = require 'test.lust'
local ResearchService = require 'economy.ResearchService'

local function testResearchService()
    lust.describe("ResearchService", function()
        local registry
        local service

        lust.before(function()
            -- Create mock registry
            registry = {
                getService = function(name)
                    if name == 'eventBus' then
                        return {
                            emit = function() end -- Mock emit
                        }
                    end
                    return nil
                end,
                registerService = function() end -- Mock register
            }

            -- Create service instance
            service = ResearchService:new(registry)
        end)

        lust.it("should initialize correctly", function()
            lust.expect(service).to.exist()
            lust.expect(service.activeResearch).to.be.a('table')
            lust.expect(service.completedResearch).to.be.a('table')
            lust.expect(service.researchProgress).to.be.a('table')
        end)

        lust.it("should load research data", function()
            lust.expect(function()
                service:_loadResearchData()
            end).to_not.fail()
        end)

        lust.it("should get available research", function()
            local available = service:getAvailableResearch()
            lust.expect(available).to.be.a('table')
        end)

        lust.it("should get completed research", function()
            local completed = service:getCompletedResearch()
            lust.expect(completed).to.be.a('table')
        end)

        lust.it("should check prerequisites", function()
            local hasPrereqs = service:checkPrerequisites("basic_weaponry")
            lust.expect(hasPrereqs).to.be.a('boolean')
        end)

        lust.it("should start research", function()
            local success, message = service:startResearch("basic_weaponry", 1, 5)
            lust.expect(success).to.be.a('boolean')
            lust.expect(message).to.be.a('string')
        end)

        lust.it("should cancel research", function()
            local success, message = service:cancelResearch(1)
            lust.expect(success).to.be.a('boolean')
            lust.expect(message).to.be.a('string')
        end)

        lust.it("should update research progress", function()
            lust.expect(function()
                service:updateResearch()
            end).to_not.fail()
        end)

        lust.it("should get research progress", function()
            local progress = service:getResearchProgress("basic_weaponry")
            lust.expect(progress).to.be.a('number')
            lust.expect(progress).to.be.greater_than_or_equal(0)
            lust.expect(progress).to.be.less_than_or_equal(100)
        end)

        lust.it("should get active research", function()
            local active = service:getActiveResearch(1)
            -- May be nil if no active research
            lust.expect(active == nil or type(active) == 'table').to.equal(true)
        end)

        lust.it("should check if research is completed", function()
            local completed = service:isResearchCompleted("basic_weaponry")
            lust.expect(completed).to.be.a('boolean')
        end)

        lust.it("should get research by category", function()
            local weapons = service:getResearchByCategory("weaponry")
            lust.expect(weapons).to.be.a('table')
        end)

        lust.it("should get research by tier", function()
            local tier1 = service:getResearchByTier(1)
            lust.expect(tier1).to.be.a('table')
        end)

        lust.it("should get prerequisites", function()
            local prereqs = service:getPrerequisites("advanced_weaponry")
            lust.expect(prereqs).to.be.a('table')
        end)
    end)
end

return testResearchService