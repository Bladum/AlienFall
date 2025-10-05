--- Test suite for basescape.MonthlyReport class
-- @module test.basescape.test_monthly_report

local test_framework = require "test.framework.test_framework"
local MonthlyReport = require 'basescape.MonthlyReport'

local test_monthly_report = {}

--- Run all MonthlyReport tests
function test_monthly_report.run()
    test_framework.run_suite("MonthlyReport", {
        test_monthly_report_creation = test_monthly_report.test_monthly_report_creation,
        test_report_generation = test_monthly_report.test_report_generation,
        test_executive_summary = test_monthly_report.test_executive_summary,
        test_operations_section = test_monthly_report.test_operations_section,
        test_financial_section = test_monthly_report.test_financial_section,
        test_alerts_system = test_monthly_report.test_alerts_system,
        test_projections_section = test_monthly_report.test_projections_section
    })
end

--- Setup function run before each test
function test_monthly_report.setup()
    -- Create mock registry for testing
    _G.mock_registry = {
        logger = function() return {
            info = function() end,
            debug = function() end,
            warn = function() end,
            error = function() end
        } end,
        eventBus = function() return {
            publish = function() end
        } end
    }
end

--- Test monthly report creation and initialization
function test_monthly_report.test_monthly_report_creation()
    local report = MonthlyReport.new({
        base_manager = nil,
        capacity_manager = nil,
        service_manager = nil
    })

    test_framework.assert_nil(report.base_manager, "Report should have no base manager initially")
    test_framework.assert_nil(report.capacity_manager, "Report should have no capacity manager initially")
    test_framework.assert_nil(report.service_manager, "Report should have no service manager initially")
    test_framework.assert_not_nil(report.report, "Report should have report table")
end

--- Test report generation with mock data
function test_monthly_report.test_report_generation()
    -- Mock managers
    local mock_base_manager = {
        getStatus = function() return {
            facility_count = 5,
            operational_facilities = 4
        } end
    }

    local mock_capacity_manager = {
        getCapacitySummary = function() return {
            total_capacities = 10,
            average_utilization = 75
        } end
    }

    local mock_service_manager = {
        getServiceSummary = function() return {
            total_services = 5,
            operational_services = 4
        } end
    }

    local report = MonthlyReport.new({
        base_manager = mock_base_manager,
        capacity_manager = mock_capacity_manager,
        service_manager = mock_service_manager
    })

    -- Generate report
    local report_data = report:generateReport()

    -- Check report structure
    test_framework.assert_not_nil(report_data.sections, "Should have sections")
    test_framework.assert_not_nil(report_data.sections.executive_summary, "Should have executive summary")
    test_framework.assert_not_nil(report_data.sections.operations, "Should have operations section")
    test_framework.assert_not_nil(report_data.sections.financial, "Should have financial section")
    test_framework.assert_not_nil(report_data.sections.research, "Should have research section")
    test_framework.assert_not_nil(report_data.sections.manufacturing, "Should have manufacturing section")
    test_framework.assert_not_nil(report_data.sections.personnel, "Should have personnel section")
    test_framework.assert_not_nil(report_data.sections.security, "Should have security section")
    test_framework.assert_not_nil(report_data.projections, "Should have projections")
end

--- Test executive summary generation
function test_monthly_report.test_executive_summary()
    local report = MonthlyReport.new({})

    local summary = report:_generateExecutiveSummary()

    test_framework.assert_not_nil(summary, "Executive summary should be generated")
    test_framework.assert_not_nil(summary.base_health_score, "Should include base health score")
    test_framework.assert_not_nil(summary.monthly_net_income, "Should include monthly net income")
    test_framework.assert_not_nil(summary.capacity_utilization, "Should include capacity utilization")
end

--- Test operations section generation
function test_monthly_report.test_operations_section()
    local report = MonthlyReport.new({})

    local operations = report:_generateOperationsReport()

    test_framework.assert_not_nil(operations, "Operations section should be generated")
    test_framework.assert_not_nil(operations.facilities_online, "Should include facilities online")
    test_framework.assert_not_nil(operations.facilities_total, "Should include facilities total")
end

--- Test financial section generation
function test_monthly_report.test_financial_section()
    local report = MonthlyReport.new({})

    local financial = report:_generateFinancialReport()

    test_framework.assert_not_nil(financial, "Financial section should be generated")
    test_framework.assert_not_nil(financial.income_sources, "Should include income sources")
    test_framework.assert_not_nil(financial.expenses, "Should include expenses")
    test_framework.assert_not_nil(financial.net_income, "Should include net income")
end

--- Test alerts system
function test_monthly_report.test_alerts_system()
    local report = MonthlyReport.new({})

    -- Generate alerts (this is internal to the report generation)
    local alerts = report:_generateAlerts()

    test_framework.assert_not_nil(alerts, "Alerts should be generated")
    test_framework.assert_true(type(alerts) == "table", "Alerts should be a table")
end

--- Test projections section generation
function test_monthly_report.test_projections_section()
    local report = MonthlyReport.new({})

    local projections = report:_generateProjections()

    test_framework.assert_not_nil(projections, "Projections should be generated")
    test_framework.assert_not_nil(projections.financial_projections, "Should include financial projections")
    test_framework.assert_not_nil(projections.capacity_projections, "Should include capacity projections")
end

return test_monthly_report