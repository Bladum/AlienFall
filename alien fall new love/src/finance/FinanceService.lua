--- FinanceService.lua
-- Manages organization funding, debt, score, and victory conditions
-- Tracks solvency, reputation, and campaign progress

local class = require 'lib.Middleclass'
local EventBus = require 'engine.event_bus'

local FinanceService = class("FinanceService")

--- Finance events
FinanceService.EVENT_MONTH_CLOSED = "finance:month_closed"
FinanceService.EVENT_LOAN_TAKEN = "finance:loan_taken"
FinanceService.EVENT_LOAN_DEFAULTED = "finance:loan_defaulted"
FinanceService.EVENT_SCORE_UPDATED = "finance:score_updated"
FinanceService.EVENT_GAME_WON = "finance:game_won"
FinanceService.EVENT_GAME_LOST = "finance:game_lost"

function FinanceService:initialize(registry)
    self.registry = registry
    self.eventBus = registry:eventBus()
    self.logger = registry:logger()

    -- Financial state
    self.cash = 100000  -- Starting cash
    self.monthlyIncome = 0
    self.monthlyExpenses = 0

    -- Funding system
    self.countryFunding = {}  -- country -> funding amount
    self.globalFunding = 0
    self.fundingMultiplier = 1.0

    -- Debt system
    self.loans = {}  -- loanId -> loan data
    self.debtSeed = "finance:debt"

    -- Score system
    self.score = 0
    self.reputation = 50  -- 0-100

    -- Victory conditions
    self.victoryProgress = {}
    self.defeatConditions = {}

    -- Load configuration
    self:_loadConfiguration()

    -- Set up event listeners
    self:_setupEventListeners()

    self.logger:info("FinanceService initialized")
end

function FinanceService:_loadConfiguration()
    -- Load finance configuration from TOML files
    local success, TomlLoader = pcall(require, "core.util.toml_loader")

    if success and TomlLoader then
        self.config = {
            funding = TomlLoader.load("data/finance/funding.toml"),
            debt = TomlLoader.load("data/finance/debt.toml"),
            score = TomlLoader.load("data/finance/score.toml"),
            victory = TomlLoader.load("data/finance/victory.toml")
        }
    else
        self.logger:warn("TOML loader not available, using default configuration")
        self.config = {}
    end

    -- Set defaults if config not loaded
    if not self.config.funding then
        self.config.funding = {
            baseFunding = 50000,
            satisfactionMultiplier = 1.0,
            securityBonus = 0.1,
            panicPenalty = 0.5
        }
    end

    if not self.config.debt then
        self.config.debt = {
            institutions = {
                { name = "IMF", rate = 0.05, maxAmount = 100000 },
                { name = "World Bank", rate = 0.03, maxAmount = 200000 },
                { name = "Private Bank", rate = 0.08, maxAmount = 50000 }
            }
        }
    end

    if not self.config.score then
        self.config.score = {
            missionSuccess = 10,
            missionFailure = -5,
            civilianLoss = -2,
            baseDestroyed = -20
        }
    end
end

function FinanceService:_setupEventListeners()
    -- Listen for mission outcomes
    self.eventBus:subscribe("mission:completed", function(event)
        self:updateScore(event.success and self.config.score.missionSuccess or self.config.score.missionFailure)
    end)

    -- Listen for base events
    self.eventBus:subscribe("base:destroyed", function(event)
        self:updateScore(self.config.score.baseDestroyed)
    end)

    -- Listen for month transitions
    self.eventBus:subscribe("time:month_start", function(event)
        self:_processMonthlyFinance()
    end)
end

--- Update organization score
-- @param delta Score change amount
function FinanceService:updateScore(delta)
    self.score = self.score + delta
    self:_updateReputation()

    self.eventBus:publish(FinanceService.EVENT_SCORE_UPDATED, {
        score = self.score,
        delta = delta,
        reputation = self.reputation
    })

    self.logger:info("Score updated: " .. self.score .. " (delta: " .. delta .. ")")
end

function FinanceService:_updateReputation()
    -- Reputation based on score ranges
    if self.score >= 100 then
        self.reputation = 90
    elseif self.score >= 50 then
        self.reputation = 70
    elseif self.score >= 0 then
        self.reputation = 50
    elseif self.score >= -50 then
        self.reputation = 30
    else
        self.reputation = 10
    end
end

--- Process monthly financial calculations
function FinanceService:_processMonthlyFinance()
    -- Calculate income
    self:_calculateIncome()

    -- Calculate expenses
    self:_calculateExpenses()

    -- Apply cash flow
    self.cash = self.cash + self.monthlyIncome - self.monthlyExpenses

    -- Process debt payments
    self:_processDebtPayments()

    -- Check win/loss conditions
    self:_checkVictoryConditions()

    self.eventBus:publish(FinanceService.EVENT_MONTH_CLOSED, {
        cash = self.cash,
        income = self.monthlyIncome,
        expenses = self.monthlyExpenses,
        score = self.score
    })

    self.logger:info("Monthly finance processed - Cash: " .. self.cash)
end

function FinanceService:_calculateIncome()
    -- Calculate funding from countries
    self.monthlyIncome = 0

    -- Get geoscape service for country data
    local geoscapeService = self.registry:geoscapeService()
    if geoscapeService then
        for _, country in ipairs(geoscapeService:getCountries()) do
            local baseFunding = self.config.funding.baseFunding
            local satisfactionMult = country.satisfaction / 100.0
            local securityBonus = country.securityStatus and self.config.funding.securityBonus or 0
            local panicPenalty = country.panic > 50 and self.config.funding.panicPenalty or 0

            local countryFunding = baseFunding * satisfactionMult * (1 + securityBonus) * (1 - panicPenalty)
            self.countryFunding[country.id] = countryFunding
            self.monthlyIncome = self.monthlyIncome + countryFunding
        end
    end

    self.globalFunding = self.monthlyIncome
end

function FinanceService:_calculateExpenses()
    -- Calculate base maintenance, salaries, etc.
    self.monthlyExpenses = 0

    -- Get base manager for base expenses
    local baseManager = self.registry:baseManager()
    if baseManager then
        for _, base in ipairs(baseManager:getBases()) do
            self.monthlyExpenses = self.monthlyExpenses + base.monthlyCost
        end
    end

    -- Add other expenses (research, manufacturing, etc.)
    -- TODO: Integrate with other services
end

function FinanceService:_processDebtPayments()
    for loanId, loan in pairs(self.loans) do
        if loan.remaining > 0 then
            local payment = loan.monthlyPayment
            if self.cash >= payment then
                self.cash = self.cash - payment
                loan.remaining = loan.remaining - payment
                loan.monthsRemaining = loan.monthsRemaining - 1

                if loan.remaining <= 0 then
                    self.loans[loanId] = nil
                    self.logger:info("Loan " .. loanId .. " paid off")
                end
            else
                -- Default on loan
                self:_defaultOnLoan(loanId)
            end
        end
    end
end

function FinanceService:_defaultOnLoan(loanId)
    local loan = self.loans[loanId]
    if loan then
        self.logger:warn("Defaulted on loan " .. loanId)
        self.eventBus:publish(FinanceService.EVENT_LOAN_DEFAULTED, { loanId = loanId })

        -- Apply penalties
        self:updateScore(-50)
        self.cash = self.cash - loan.remaining * 0.1  -- Penalty fee

        self.loans[loanId] = nil
    end
end

--- Take out a loan
-- @param institutionIndex Index of lending institution
-- @param amount Loan amount
-- @return boolean success
function FinanceService:takeLoan(institutionIndex, amount)
    local institution = self.config.debt.institutions[institutionIndex]
    if not institution or amount > institution.maxAmount then
        return false
    end

    local loanId = "loan_" .. os.time()
    local monthlyRate = institution.rate / 12
    local months = 12  -- 1 year loans

    local loan = {
        id = loanId,
        institution = institution.name,
        amount = amount,
        remaining = amount,
        interestRate = institution.rate,
        monthlyPayment = amount * monthlyRate * (1 + monthlyRate)^months / ((1 + monthlyRate)^months - 1),
        monthsRemaining = months
    }

    self.loans[loanId] = loan
    self.cash = self.cash + amount

    self.eventBus:publish(FinanceService.EVENT_LOAN_TAKEN, loan)
    self.logger:info("Loan taken: " .. amount .. " from " .. institution.name)

    return true
end

function FinanceService:_checkVictoryConditions()
    -- Check defeat conditions
    if self.cash <= 0 then
        self.eventBus:publish(FinanceService.EVENT_GAME_LOST, { reason = "bankruptcy" })
        return
    end

    if self.score <= -200 then
        self.eventBus:publish(FinanceService.EVENT_GAME_LOST, { reason = "reputation" })
        return
    end

    -- Check victory conditions
    -- TODO: Implement specific victory conditions from config
end

--- Get current financial status
-- @return table Financial data
function FinanceService:getFinancialStatus()
    return {
        cash = self.cash,
        monthlyIncome = self.monthlyIncome,
        monthlyExpenses = self.monthlyExpenses,
        score = self.score,
        reputation = self.reputation,
        loans = self.loans,
        countryFunding = self.countryFunding
    }
end

return FinanceService