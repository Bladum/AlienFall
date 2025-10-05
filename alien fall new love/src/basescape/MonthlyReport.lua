--- MonthlyReport class for displaying comprehensive strategic management reports.
-- @classmod basescape.MonthlyReport
-- @field report table Report data containing all sections and metrics

local MonthlyReport = {}
MonthlyReport.__index = MonthlyReport

--- Alert priority levels
MonthlyReport.ALERT_CRITICAL = "critical"
MonthlyReport.ALERT_WARNING = "warning"
MonthlyReport.ALERT_INFO = "info"

--- Creates a new MonthlyReport instance.
-- @param opts table Configuration options
-- @param opts.base_manager BaseManager instance for data access
-- @param opts.capacity_manager CapacityManager instance for utilization data
-- @param opts.service_manager ServiceManager instance for service status
-- @return MonthlyReport A new MonthlyReport instance
function MonthlyReport.new(opts)
    local self = setmetatable({}, MonthlyReport)
    self.base_manager = opts and opts.base_manager or nil
    self.capacity_manager = opts and opts.capacity_manager or nil
    self.service_manager = opts and opts.service_manager or nil
    self.report = {}
    return self
end

--- Generates a comprehensive monthly report from current base state
-- @return table Complete monthly report data
function MonthlyReport:generateReport()
    local report = {
        month = os.date("%B %Y"),
        timestamp = os.time(),
        sections = {},
        alerts = {},
        projections = {}
    }

    -- Generate all report sections
    report.sections.executive_summary = self:_generateExecutiveSummary()
    report.sections.operations = self:_generateOperationsReport()
    report.sections.financial = self:_generateFinancialReport()
    report.sections.research = self:_generateResearchReport()
    report.sections.manufacturing = self:_generateManufacturingReport()
    report.sections.personnel = self:_generatePersonnelReport()
    report.sections.security = self:_generateSecurityReport()

    -- Generate alerts
    report.alerts = self:_generateAlerts()

    -- Generate forward-looking projections
    report.projections = self:_generateProjections()

    self.report = report
    return report
end

--- Generate executive summary section
-- @return table Executive summary data
function MonthlyReport:_generateExecutiveSummary()
    local summary = {
        base_health_score = 85, -- Calculate from facility status
        monthly_net_income = 2400000,
        capacity_utilization = 92,
        operational_efficiency = 88,
        key_achievements = {
            "Completed 3 major research projects",
            "Produced 45 units of advanced weaponry",
            "Successfully intercepted 12 alien craft"
        },
        critical_issues = {
            "Power grid operating at 78% capacity",
            "3 facilities require maintenance within 2 weeks"
        }
    }

    if self.base_manager then
        local status = self.base_manager:getStatus()
        summary.facility_count = status.facility_count
        summary.operational_facilities = status.operational_facilities
    end

    return summary
end

--- Generate operations report section
-- @return table Operations report data
function MonthlyReport:_generateOperationsReport()
    local operations = {
        facilities_online = 24,
        facilities_total = 24,
        connectivity_status = 100,
        power_utilization = 78,
        storage_utilization = {
            item_storage = 65,
            resource_storage = 45,
            fuel_storage = 80
        },
        maintenance_due = {
            {facility = "Fusion Reactor", days = 12},
            {facility = "Hyperwave Decoder", days = 8},
            {facility = "Workshop", days = 5}
        }
    }

    if self.capacity_manager then
        local summary = self.capacity_manager:getCapacitySummary()
        operations.capacity_summary = summary
    end

    if self.service_manager then
        local service_summary = self.service_manager:getServiceSummary()
        operations.service_summary = service_summary
    end

    return operations
end

--- Generate financial report section
-- @return table Financial report data
function MonthlyReport:_generateFinancialReport()
    return {
        income_sources = {
            {category = "Item Sales", amount = 3200000, percentage = 57},
            {category = "Research Contracts", amount = 800000, percentage = 14},
            {category = "Resource Extraction", amount = 1200000, percentage = 21},
            {category = "Other", amount = 800000, percentage = 14}
        },
        expenses = {
            {category = "Facility Maintenance", amount = 1800000, percentage = 75},
            {category = "Personnel Salaries", amount = 1200000, percentage = 50},
            {category = "Resource Purchases", amount = 600000, percentage = 25},
            {category = "Other", amount = 300000, percentage = 12}
        },
        net_income = 2400000,
        total_reserves = 15700000,
        projected_income = 2600000,
        budget_alerts = {}
    }
end

--- Generate research report section
-- @return table Research report data
function MonthlyReport:_generateResearchReport()
    return {
        active_projects = 5,
        completed_projects = 3,
        research_utilization = 91,
        new_technologies = {
            "Alien Alloys Analysis",
            "Neural Implant Technology",
            "Plasma Weapon Improvements"
        },
        project_status = {
            {name = "Alien Alloys", progress = 67, eta_days = 60, budget = 500000},
            {name = "Neural Implants", progress = 34, eta_days = 90, budget = 750000},
            {name = "Plasma Weapons", progress = 89, eta_days = 15, budget = 250000}
        },
        scientist_utilization = 95,
        breakthrough_chance = 12
    }
end

--- Generate manufacturing report section
-- @return table Manufacturing report data
function MonthlyReport:_generateManufacturingReport()
    return {
        monthly_production = {
            {item = "Plasma Rifle", quantity = 12, efficiency = 98},
            {item = "Hovertank", quantity = 8, efficiency = 95},
            {item = "Personal Armor", quantity = 25, efficiency = 92}
        },
        production_backlog = 15,
        manufacturing_utilization = 94,
        engineer_utilization = 97,
        resource_shortages = {
            {resource = "Alien Alloys", current_stock = 45, days_remaining = 14}
        },
        efficiency_trends = {
            current = 94,
            previous_month = 89,
            improvement = 5
        }
    }
end

--- Generate personnel report section
-- @return table Personnel report data
function MonthlyReport:_generatePersonnelReport()
    return {
        total_personnel = 175,
        filled_positions = 156,
        vacancy_rate = 11,
        staffing_levels = {
            soldiers = {filled = 120, required = 125, percentage = 96},
            scientists = {filled = 18, required = 25, percentage = 72},
            engineers = {filled = 12, required = 15, percentage = 80},
            support = {filled = 6, required = 10, percentage = 60}
        },
        morale_average = 92,
        training_completed = 5,
        recruitment_needs = {
            {role = "Scientists", count = 12, priority = "high"},
            {role = "Engineers", count = 7, priority = "medium"},
            {role = "Medical Staff", count = 3, priority = "low"}
        },
        performance_trends = {
            productivity_increase = 15,
            casualty_rate = 8,
            promotion_rate = 12
        }
    }
end

--- Generate security report section
-- @return table Security report data
function MonthlyReport:_generateSecurityReport()
    return {
        defense_readiness = 82,
        security_incidents = 0,
        interception_readiness = 95,
        regional_threat_level = "moderate",
        defense_systems = {
            {system = "Base Turrets", status = "operational", effectiveness = 85},
            {system = "Missile Defense", status = "operational", effectiveness = 90},
            {system = "Security Stations", status = "operational", effectiveness = 75}
        },
        maintenance_alerts = 3,
        recommended_actions = {
            "Increase radar coverage in sector 7",
            "Schedule turret calibration",
            "Expand security monitoring"
        }
    }
end

--- Generate alerts based on current conditions
-- @return table Array of alert objects
function MonthlyReport:_generateAlerts()
    local alerts = {}

    -- Critical alerts
    table.insert(alerts, {
        level = MonthlyReport.ALERT_CRITICAL,
        category = "power",
        message = "Power grid utilization at 78% - risk of brownouts",
        impact = "May cause facility shutdowns and production delays",
        recommendation = "Construct additional fusion reactor or reduce power consumption"
    })

    -- Warning alerts
    table.insert(alerts, {
        level = MonthlyReport.ALERT_WARNING,
        category = "maintenance",
        message = "3 facilities due for maintenance within 2 weeks",
        impact = "Reduced efficiency and potential failures",
        recommendation = "Schedule maintenance downtime or allocate repair teams"
    })

    table.insert(alerts, {
        level = MonthlyReport.ALERT_WARNING,
        category = "staffing",
        message = "Scientist staffing at 72% of requirements",
        impact = "Research progress slowed by 20%",
        recommendation = "Recruit additional scientists or reduce research load"
    })

    -- Info alerts
    table.insert(alerts, {
        level = MonthlyReport.ALERT_INFO,
        category = "expansion",
        message = "Workshop expansion would increase manufacturing capacity by 40%",
        impact = "Positive - increased production output",
        recommendation = "Consider workshop upgrade when budget allows"
    })

    return alerts
end

--- Generate forward-looking projections
-- @return table Projection data
function MonthlyReport:_generateProjections()
    return {
        financial_projections = {
            next_month_income = 2600000,
            next_month_expenses = 2200000,
            projected_reserves = 18300000,
            budget_trend = "positive"
        },
        capacity_projections = {
            storage_full_date = "45 days",
            research_completion = {
                {project = "Alien Alloys", completion_date = "60 days"},
                {project = "Neural Implants", completion_date = "90 days"}
            },
            manufacturing_backlog_clearance = "30 days"
        },
        risk_assessments = {
            {risk = "Alien attack", probability = 15, impact = "high", mitigation = "Increase interception patrols"},
            {risk = "Resource shortage", probability = 25, impact = "medium", mitigation = "Stockpile critical materials"},
            {risk = "Facility failure", probability = 10, impact = "high", mitigation = "Complete scheduled maintenance"}
        },
        recommended_actions = {
            {action = "Construct additional laboratory", priority = "high", reason = "Research bottleneck identified"},
            {action = "Expand living quarters", priority = "medium", reason = "Personnel capacity nearing limits"},
            {action = "Upgrade radar systems", priority = "low", reason = "Detection range optimization"}
        }
    }
end

--- Draws the comprehensive monthly report panel.
-- @param x number X coordinate for the panel
-- @param y number Y coordinate for the panel
-- @param width number Panel width (default 800)
-- @param height number Panel height (default 600)
function MonthlyReport:draw(x, y, width, height)
    width = width or 800
    height = height or 600

    -- Main panel background
    love.graphics.setColor(0.95, 0.95, 0.9, 1)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.rectangle("line", x, y, width, height)

    -- Title
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.print("Monthly Base Report - " .. (self.report.month or "Unknown Month"), x + 20, y + 20)

    -- Executive Summary
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.print("Executive Summary", x + 20, y + 60)

    love.graphics.setFont(love.graphics.newFont(14))
    local summary = self.report.sections and self.report.sections.executive_summary
    if summary then
        love.graphics.print(string.format("Base Health: %d%% | Net Income: $%d | Capacity Utilization: %d%%",
            summary.base_health_score or 0, summary.monthly_net_income or 0, summary.capacity_utilization or 0),
            x + 30, y + 85)

        love.graphics.print(string.format("Operational Efficiency: %d%% | Facilities: %d/%d Online",
            summary.operational_efficiency or 0, summary.operational_facilities or 0, summary.facility_count or 0),
            x + 30, y + 105)
    end

    -- Key Sections
    local sectionY = y + 140
    love.graphics.setFont(love.graphics.newFont(16))

    -- Operations
    love.graphics.print("Operations", x + 20, sectionY)
    love.graphics.setFont(love.graphics.newFont(12))
    local ops = self.report.sections and self.report.sections.operations
    if ops then
        love.graphics.print(string.format("Power: %d%% | Storage: %d%% | Services: %d/%d Online",
            ops.power_utilization or 0, ops.storage_utilization and ops.storage_utilization.item_storage or 0,
            ops.service_summary and ops.service_summary.online_services or 0,
            ops.service_summary and ops.service_summary.total_services or 0),
            x + 30, sectionY + 20)
    end

    -- Financial
    sectionY = sectionY + 50
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Financial", x + 20, sectionY)
    love.graphics.setFont(love.graphics.newFont(12))
    local financial = self.report.sections and self.report.sections.financial
    if financial then
        love.graphics.print(string.format("Income: $%d | Expenses: $%d | Net: $%d",
            financial.net_income and financial.net_income * 1.2 or 0, -- Approximate total income
            financial.net_income and (financial.net_income * 1.2 - financial.net_income) or 0, -- Approximate expenses
            financial.net_income or 0),
            x + 30, sectionY + 20)
    end

    -- Research
    sectionY = sectionY + 50
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Research", x + 20, sectionY)
    love.graphics.setFont(love.graphics.newFont(12))
    local research = self.report.sections and self.report.sections.research
    if research then
        love.graphics.print(string.format("Active Projects: %d | Utilization: %d%% | New Tech: %d",
            research.active_projects or 0, research.research_utilization or 0, #research.new_technologies),
            x + 30, sectionY + 20)
    end

    -- Manufacturing
    sectionY = sectionY + 50
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Manufacturing", x + 20, sectionY)
    love.graphics.setFont(love.graphics.newFont(12))
    local manufacturing = self.report.sections and self.report.sections.manufacturing
    if manufacturing then
        love.graphics.print(string.format("Production: %d items | Utilization: %d%% | Backlog: %d",
            manufacturing.monthly_production and #manufacturing.monthly_production or 0,
            manufacturing.manufacturing_utilization or 0, manufacturing.production_backlog or 0),
            x + 30, sectionY + 20)
    end

    -- Personnel
    sectionY = sectionY + 50
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Personnel", x + 20, sectionY)
    love.graphics.setFont(love.graphics.newFont(12))
    local personnel = self.report.sections and self.report.sections.personnel
    if personnel then
        love.graphics.print(string.format("Staffing: %d/%d | Morale: %d%% | Training: %d completed",
            personnel.filled_positions or 0, personnel.total_personnel or 0,
            personnel.morale_average or 0, personnel.training_completed or 0),
            x + 30, sectionY + 20)
    end

    -- Security
    sectionY = sectionY + 50
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Security", x + 20, sectionY)
    love.graphics.setFont(love.graphics.newFont(12))
    local security = self.report.sections and self.report.sections.security
    if security then
        love.graphics.print(string.format("Defense Readiness: %d%% | Incidents: %d | Threat Level: %s",
            security.defense_readiness or 0, security.security_incidents or 0, security.regional_threat_level or "unknown"),
            x + 30, sectionY + 20)
    end

    -- Alerts
    sectionY = sectionY + 50
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Alerts", x + 20, sectionY)

    love.graphics.setFont(love.graphics.newFont(12))
    local alerts = self.report.alerts or {}
    for i, alert in ipairs(alerts) do
        if i > 3 then break end -- Show only first 3 alerts

        local color = {0.1, 0.1, 0.1, 1} -- Default black
        if alert.level == MonthlyReport.ALERT_CRITICAL then
            color = {0.8, 0.1, 0.1, 1} -- Red
        elseif alert.level == MonthlyReport.ALERT_WARNING then
            color = {0.8, 0.6, 0.1, 1} -- Orange
        elseif alert.level == MonthlyReport.ALERT_INFO then
            color = {0.1, 0.6, 0.8, 1} -- Blue
        end

        love.graphics.setColor(color[1], color[2], color[3], color[4])
        love.graphics.print(string.format("[%s] %s", alert.level:upper(), alert.message), x + 30, sectionY + 15 + (i-1) * 15)
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
    end
end

return MonthlyReport
