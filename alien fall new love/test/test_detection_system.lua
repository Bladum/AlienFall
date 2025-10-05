--- Test Detection System
-- Tests for mission detection mechanics

local lust = require 'test.framework.lust'
local Mission = require 'lore.Mission'
local BaseManager = require 'services.BaseManager'
local DetectionSystem = require 'systems.DetectionSystem'

local TestDetectionSystem = {}

function TestDetectionSystem:test_mission_detection_properties()
    lust.describe("Mission Detection Properties", function()
        lust.it("should initialize with default detection values", function()
            local mission_data = {
                id = "test_mission",
                name = "Test Mission",
                type = "recon",
                initial_cover = 100,
                armor = 10
            }
            local mission = Mission.new(mission_data)

            lust.expect(mission:getInitialCover()).to.equal(100)
            lust.expect(mission:getCurrentCover()).to.equal(100)
            lust.expect(mission:getArmor()).to.equal(10)
            lust.expect(mission:isDetected()).to.equal(false)
        end)

        lust.it("should apply detection correctly", function()
            local mission_data = {
                id = "test_mission",
                name = "Test Mission",
                type = "recon",
                initial_cover = 100,
                armor = 20  -- 20% armor = 0.8 multiplier
            }
            local mission = Mission.new(mission_data)

            -- Apply 50 detection power: 50 * (1-0.2) = 40 cover reduction
            local was_detected = mission:applyDetection(50)
            lust.expect(was_detected).to.equal(false)
            lust.expect(mission:getCurrentCover()).to.equal(60)
            lust.expect(mission:isDetected()).to.equal(false)
        end)

        lust.it("should detect mission when cover reaches zero", function()
            local mission_data = {
                id = "test_mission",
                name = "Test Mission",
                type = "recon",
                initial_cover = 50,
                armor = 0  -- No armor
            }
            local mission = Mission.new(mission_data)

            -- Apply 50 detection power: 50 * 1.0 = 50 cover reduction
            local was_detected = mission:applyDetection(50)
            lust.expect(was_detected).to.equal(true)
            lust.expect(mission:getCurrentCover()).to.equal(0)
            lust.expect(mission:isDetected()).to.equal(true)
        end)

        lust.it("should not apply detection to already detected missions", function()
            local mission_data = {
                id = "test_mission",
                name = "Test Mission",
                type = "recon",
                initial_cover = 10,
                armor = 0
            }
            local mission = Mission.new(mission_data)

            -- First detection
            mission:applyDetection(10)
            lust.expect(mission:isDetected()).to.equal(true)

            -- Second detection should not change anything
            mission:applyDetection(10)
            lust.expect(mission:getCurrentCover()).to.equal(0)
        end)

        lust.it("should reset cover correctly", function()
            local mission_data = {
                id = "test_mission",
                name = "Test Mission",
                type = "recon",
                initial_cover = 100,
                armor = 10
            }
            local mission = Mission.new(mission_data)

            mission:applyDetection(50)
            mission:resetCover()

            lust.expect(mission:getCurrentCover()).to.equal(100)
            lust.expect(mission:isDetected()).to.equal(false)
        end)
    end)
end

function TestDetectionSystem:test_base_manager_radar()
    lust.describe("BaseManager Radar Facilities", function()
        lust.it("should track radar facilities", function()
            local base_manager = BaseManager.new()

            -- Add base
            base_manager:addBase("base1", { name = "Test Base" })

            -- Add radar facility
            base_manager:addFacility("base1", "radar1", {
                type = "radar",
                detection_power = 25,
                detection_range = 100,
                position = { x = 0, y = 0 }
            })

            -- Check facility exists
            lust.expect(base_manager:hasFacility("base1", "radar1")).to.equal(true)

            -- Check radar facilities
            local radars = base_manager:getRadarFacilities()
            lust.expect(radars.base1.radar1.power).to.equal(25)
            lust.expect(radars.base1.radar1.range).to.equal(100)
        end)

        lust.it("should calculate total radar power", function()
            local base_manager = BaseManager.new()

            -- Add bases with radars
            base_manager:addBase("base1", { name = "Base 1" })
            base_manager:addBase("base2", { name = "Base 2" })

            base_manager:addFacility("base1", "radar1", {
                type = "radar", detection_power = 20
            })
            base_manager:addFacility("base1", "radar2", {
                type = "radar", detection_power = 30
            })
            base_manager:addFacility("base2", "radar1", {
                type = "radar", detection_power = 15
            })

            -- Non-radar facility should not count
            base_manager:addFacility("base2", "hangar1", {
                type = "hangar", detection_power = 50
            })

            local total_power = base_manager:getTotalRadarPower()
            lust.expect(total_power).to.equal(65)  -- 20 + 30 + 15
        end)
    end)
end

function TestDetectionSystem:test_detection_system()
    lust.describe("DetectionSystem Integration", function()
        lust.it("should calculate detection for missions", function()
            local base_manager = BaseManager.new()
            local detection_system = DetectionSystem.new({
                base_manager = base_manager
            })

            -- Setup base with radar
            base_manager:addBase("base1", { name = "Test Base" })
            base_manager:addFacility("base1", "radar1", {
                type = "radar",
                detection_power = 40,
                detection_range = 200,
                position = { x = 0, y = 0 }
            })

            -- Create mission
            local mission = Mission.new({
                id = "test_mission",
                name = "Test Mission",
                initial_cover = 100,
                armor = 10
            })

            -- Create mock province
            local province = {
                id = "province1",
                position = { x = 0, y = 0 },  -- Same position as radar
                missions = { test_mission = mission }
            }

            -- Run detection update
            local missions = { test_mission = mission }
            local provinces = { province1 = province }

            detection_system:updateDetection(missions, provinces)

            -- Mission should be detected: 40 * (1-0.1) = 36 cover reduction
            lust.expect(mission:getCurrentCover()).to.equal(64)  -- 100 - 36
            lust.expect(mission:isDetected()).to.equal(false)
        end)

        lust.it("should respect radar range limits", function()
            local base_manager = BaseManager.new()
            local detection_system = DetectionSystem.new({
                base_manager = base_manager
            })

            -- Setup base with short-range radar
            base_manager:addBase("base1", { name = "Test Base" })
            base_manager:addFacility("base1", "radar1", {
                type = "radar",
                detection_power = 50,
                detection_range = 50,  -- Short range
                position = { x = 0, y = 0 }
            })

            -- Create mission far away
            local mission = Mission.new({
                id = "test_mission",
                name = "Test Mission",
                initial_cover = 100,
                armor = 0
            })

            -- Create province far from radar
            local province = {
                id = "province1",
                position = { x = 100, y = 0 },  -- 100 units away, beyond 50 range
                missions = { test_mission = mission }
            }

            -- Run detection update
            local missions = { test_mission = mission }
            local provinces = { province1 = province }

            detection_system:updateDetection(missions, provinces)

            -- Mission should not be detected (out of range)
            lust.expect(mission:getCurrentCover()).to.equal(100)
            lust.expect(mission:isDetected()).to.equal(false)
        end)

        lust.it("should generate detection summary", function()
            local detection_system = DetectionSystem.new()

            -- Create test missions
            local mission1 = Mission.new({
                id = "mission1", initial_cover = 100, armor = 0
            })
            local mission2 = Mission.new({
                id = "mission2", initial_cover = 50, armor = 0
            })
            local mission3 = Mission.new({
                id = "mission3", initial_cover = 10, armor = 0
            })

            -- Apply some detection
            mission1:applyDetection(30)  -- 70 cover left
            mission2:applyDetection(60)  -- detected
            mission3:applyDetection(15)  -- detected

            local missions = {
                mission1 = mission1,
                mission2 = mission2,
                mission3 = mission3
            }

            local summary = detection_system:getDetectionSummary(missions)

            lust.expect(summary.total_missions).to.equal(3)
            lust.expect(summary.detected_missions).to.equal(2)
            lust.expect(summary.average_cover).to.be.near(80 / 3, 0.1)  -- (70 + 0 + 0) / 3
            lust.expect(summary.missions_by_cover_range.high).to.equal(1)    -- mission1
            lust.expect(summary.missions_by_cover_range.detected).to.equal(2) -- mission2, mission3
        end)
    end)
end

function TestDetectionSystem:test_distance_calculation()
    lust.describe("Distance Calculations", function()
        lust.it("should calculate distances correctly", function()
            local detection_system = DetectionSystem.new()

            local pos1 = { x = 0, y = 0 }
            local pos2 = { x = 3, y = 4 }  -- 5 units away (3-4-5 triangle)

            local distance = detection_system:calculateDistance(pos1, pos2)
            lust.expect(distance).to.equal(5)
        end)
    end)
end

return TestDetectionSystem