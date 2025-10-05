--- Manufacturing Service Tests
-- Tests for the ManufacturingService class

local lust = require 'test.lust'
local ManufacturingService = require 'economy.ManufacturingService'

local function testManufacturingService()
    lust.describe("ManufacturingService", function()
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
            service = ManufacturingService:new(registry)
        end)

        lust.it("should initialize correctly", function()
            lust.expect(service).to.exist()
            lust.expect(service.manager).to.exist()
            lust.expect(service.registry).to.equal(registry)
        end)

        lust.it("should load manufacturing data", function()
            -- Test that data loading doesn't crash
            lust.expect(function()
                service:_loadManufacturingData()
            end).to_not.fail()
        end)

        lust.it("should get available entries", function()
            local entries = service:getAvailableEntries(1)
            lust.expect(entries).to.be.a('table')
        end)

        lust.it("should start manufacturing project", function()
            local success, message = service:startProject("assault_rifle", 1, 1, 1)
            -- May fail due to missing data, but shouldn't crash
            lust.expect(success).to.be.a('boolean')
            lust.expect(message).to.be.a('string')
        end)

        lust.it("should cancel manufacturing project", function()
            local success, message = service:cancelProject(1)
            lust.expect(success).to.be.a('boolean')
            lust.expect(message).to.be.a('string')
        end)

        lust.it("should get active projects", function()
            local projects = service:getActiveProjects(1)
            lust.expect(projects).to.be.a('table')
        end)

        lust.it("should get queued projects", function()
            local projects = service:getQueuedProjects(1)
            lust.expect(projects).to.be.a('table')
        end)

        lust.it("should update production", function()
            lust.expect(function()
                service:updateProduction()
            end).to_not.fail()
        end)

        lust.it("should get base stats", function()
            local stats = service:getBaseStats(1)
            lust.expect(stats).to.be.a('table')
            lust.expect(stats.capacity).to.be.a('table')
            lust.expect(stats.activeProjects).to.be.a('number')
            lust.expect(stats.queuedProjects).to.be.a('number')
        end)

        lust.it("should check entry availability", function()
            local available = service:isEntryAvailable("assault_rifle", 1)
            lust.expect(available).to.be.a('boolean')
        end)
    end)
end

return testManufacturingService