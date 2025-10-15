-- Test suite for Calendar system

-- Add engine path for requires
package.path = package.path .. ";../engine/?.lua;../engine/?/init.lua"

local Calendar = require("lore.calendar")

local TestCalendar = {}

---Run all calendar tests
function TestCalendar.runAll()
    print("\n========== CALENDAR TESTS ==========")
    
    local passed = 0
    local failed = 0
    
    -- Test 1: Calendar creation
    print("\n[TEST 1] Calendar Creation")
    local cal = Calendar.new()
    if cal and cal.year == 1 and cal.month == 1 and cal.day == 1 then
        print("? PASS: Calendar created at Year 1, Month 1, Day 1")
        passed = passed + 1
    else
        print("? FAIL: Calendar creation failed")
        failed = failed + 1
    end
    
    -- Test 2: Date formatting
    print("\n[TEST 2] Date Formatting")
    local shortDate = cal:getShortDate()
    local mediumDate = cal:getMediumDate()
    local fullDate = cal:getFullDate()
    if shortDate and mediumDate and fullDate then
        print(string.format("  Short: %s", shortDate))
        print(string.format("  Medium: %s", mediumDate))
        print(string.format("  Full: %s", fullDate))
        print("? PASS: All date formats work")
        passed = passed + 1
    else
        print("? FAIL: Date formatting failed")
        failed = failed + 1
    end
    
    -- Test 3: Turn advancement
    print("\n[TEST 3] Turn Advancement")
    cal:advanceTurn()
    if cal.day == 2 and cal.turn == 2 then
        print(string.format("? PASS: Advanced to day 2, turn 2 (%s)", cal:getShortDate()))
        passed = passed + 1
    else
        print(string.format("? FAIL: Expected day 2 turn 2, got day %d turn %d", cal.day, cal.turn))
        failed = failed + 1
    end
    
    -- Test 4: Month rollover
    print("\n[TEST 4] Month Rollover")
    cal = Calendar.new(1, 1, 30)
    cal:advanceTurn()
    if cal.month == 2 and cal.day == 1 then
        print(string.format("? PASS: Rolled over to month 2 (%s)", cal:getShortDate()))
        passed = passed + 1
    else
        print(string.format("? FAIL: Expected M2 D1, got M%d D%d", cal.month, cal.day))
        failed = failed + 1
    end
    
    -- Test 5: Year rollover
    print("\n[TEST 5] Year Rollover")
    cal = Calendar.new(1, 12, 30)
    cal:advanceTurn()
    if cal.year == 2 and cal.month == 1 and cal.day == 1 then
        print(string.format("? PASS: Rolled over to year 2 (%s)", cal:getShortDate()))
        passed = passed + 1
    else
        print(string.format("? FAIL: Expected Y2 M1 D1, got Y%d M%d D%d", 
            cal.year, cal.month, cal.day))
        failed = failed + 1
    end
    
    -- Test 6: Day of week calculation
    print("\n[TEST 6] Day of Week Calculation")
    cal = Calendar.new(1, 1, 1)
    local dow1 = cal.dayOfWeek
    cal:advanceDays(6)
    local dow7 = cal.dayOfWeek
    if dow1 == 1 and dow7 == 1 then  -- Day 1 and day 7 should both be day 1 of week
        print(string.format("? PASS: Week cycles correctly (D1=%s, D7=%s)", 
            cal.DAY_NAMES[dow1], cal.DAY_NAMES[dow7]))
        passed = passed + 1
    else
        print(string.format("? FAIL: Week cycle wrong (D1=%d, D7=%d)", dow1, dow7))
        failed = failed + 1
    end
    
    -- Test 7: Quarter calculation
    print("\n[TEST 7] Quarter Calculation")
    local q1 = Calendar.new(1, 1, 1).quarter
    local q2 = Calendar.new(1, 4, 1).quarter
    local q3 = Calendar.new(1, 7, 1).quarter
    local q4 = Calendar.new(1, 10, 1).quarter
    if q1 == 1 and q2 == 2 and q3 == 3 and q4 == 4 then
        print("? PASS: Quarter calculation correct (1,2,3,4)")
        passed = passed + 1
    else
        print(string.format("? FAIL: Quarter calculation wrong (%d,%d,%d,%d)", q1, q2, q3, q4))
        failed = failed + 1
    end
    
    -- Test 8: Day of year
    print("\n[TEST 8] Day of Year Calculation")
    local doy1 = Calendar.new(1, 1, 1).dayOfYear
    local doy2 = Calendar.new(1, 2, 1).dayOfYear
    local doy3 = Calendar.new(1, 12, 30).dayOfYear
    if doy1 == 1 and doy2 == 31 and doy3 == 360 then
        print(string.format("? PASS: Day of year correct (1, 31, 360)"))
        passed = passed + 1
    else
        print(string.format("? FAIL: Day of year wrong (%d, %d, %d)", doy1, doy2, doy3))
        failed = failed + 1
    end
    
    -- Test 9: Event scheduling
    print("\n[TEST 9] Event Scheduling")
    cal = Calendar.new()
    local eventFired = false
    cal:scheduleEvent(5, function(data) eventFired = true end)
    cal:advanceDays(4)
    if not eventFired then
        cal:advanceTurn()
        if eventFired then
            print("? PASS: Event fired at correct time")
            passed = passed + 1
        else
            print("? FAIL: Event did not fire")
            failed = failed + 1
        end
    else
        print("? FAIL: Event fired too early")
        failed = failed + 1
    end
    
    -- Test 10: Serialization
    print("\n[TEST 10] Serialization")
    cal = Calendar.new(5, 7, 15)
    local data = cal:serialize()
    local cal2 = Calendar.new()
    cal2:deserialize(data)
    if cal2.year == 5 and cal2.month == 7 and cal2.day == 15 then
        print("? PASS: Calendar serialization/deserialization works")
        passed = passed + 1
    else
        print(string.format("? FAIL: Serialization failed (Y%d M%d D%d)", 
            cal2.year, cal2.month, cal2.day))
        failed = failed + 1
    end
    
    -- Summary
    print("\n========== TEST SUMMARY ==========")
    print(string.format("PASSED: %d", passed))
    print(string.format("FAILED: %d", failed))
    print(string.format("TOTAL:  %d", passed + failed))
    
    if failed == 0 then
        print("\n?? ALL TESTS PASSED!")
    else
        print(string.format("\n?? %d TEST(S) FAILED", failed))
    end
    print("==================================\n")
    
    return failed == 0
end

return TestCalendar






















