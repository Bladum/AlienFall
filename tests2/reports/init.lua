-- tests2/reports/init.lua
-- Test report generation

local reports = {}

-- Report generation tools
reports.coverage = "coverage_matrix.json"
reports.hierarchy = "hierarchy_report.txt"

function reports:runAll()
    print("\n" .. string.rep("═", 80))
    print("TEST REPORTS - Report Generation")
    print(string.rep("═", 80))
    print("Reports are auto-generated after test runs")
    print(string.rep("═", 80) .. "\n")
end

return reports
