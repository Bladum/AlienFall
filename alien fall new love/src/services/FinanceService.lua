--- Finance Service
-- Manages funding, debt, score, and win/loss conditions for Alien Fall
--
-- @classmod services.FinanceService

local class = require 'lib.Middleclass'

--- FinanceService class
-- @type FinanceService
FinanceService = class('FinanceService')

--- Create a new FinanceService instance
-- @param registry Service registry for accessing other systems
-- @return FinanceService instance
function FinanceService:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.eventBus = registry and registry:eventBus() or nil

    -- Financial state
    self.cash = 50000  -- Starting funds
    self.monthlyIncome = 0
    self.monthlyExpenses = 0

    -- Funding system
    self.fundingSources = {}  -- Country funding contributions
    self.fundingModifiers = {}  -- Global funding modifiers

    -- Debt system
    self.loans = {}  -- Active loans
    self.loanOffers = {}  -- Available loan offers

    -- Score and reputation
    self.score = 0
    self.reputation = {
        fame = 0,
        karma = 0,
        diplomatic = {}
    }

    -- Win/loss tracking
    self.victoryConditions = {}
    self.defeatConditions = {}
    self.victoryProgress = {}

    -- Load finance data
    self:_loadFinanceData()

    -- Register with service registry
    if registry then
        registry:registerService('financeService', self)
    end
end

--- Load finance configuration data
function FinanceService:_loadFinanceData()
    local dataRegistry = self.registry and self.registry:resolve("data_registry")
    if not dataRegistry then
        if self.logger then
            self.logger:warn("FinanceService: No data registry available")
        end
        return
    end

    -- Load funding configuration
    local fundingData = dataRegistry:get("finance/funding") or {}
    self:_processFundingData(fundingData)

    -- Load debt configuration
    local debtData = dataRegistry:get("finance/debt") or {}
    self:_processDebtData(debtData)

    -- Load score configuration
    local scoreData = dataRegistry:get("finance/score") or {}
    self:_processScoreData(scoreData)

    -- Load victory conditions
    local victoryData = dataRegistry:get("finance/victory") or {}
    self:_processVictoryData(victoryData)
end

--- Process funding configuration data
-- @param data Funding configuration data
function FinanceService:_processFundingData(data)
    self.fundingSources = data.sources or {}
    self.fundingModifiers = data.modifiers or {}
end

--- Process debt configuration data
-- @param data Debt configuration data
function FinanceService:_processDebtData(data)
    self.loanOffers = data.offers or {}
end

--- Process score configuration data
-- @param data Score configuration data
function FinanceService:_processScoreData(data)
    -- Initialize score tracking
    self.scoreModifiers = data.modifiers or {}
end

--- Process victory condition data
-- @param data Victory condition data
function FinanceService:_processVictoryData(data)
    self.victoryConditions = data.victory or {}
    self.defeatConditions = data.defeat or {}
end

--- Get current cash balance
-- @return number Current cash amount
function FinanceService:getCash()
    return self.cash
end

--- Check if player can afford a purchase
-- @param amount Amount to check
-- @return boolean True if affordable
function FinanceService:canAfford(amount)
    return self.cash >= amount
end

--- Add funds to cash balance
-- @param amount Amount to add
-- @param source Source of the funds (optional)
function FinanceService:addFunds(amount, source)
    self.cash = self.cash + amount

    -- Emit funds added event
    if self.eventBus then
        self.eventBus:emit('finance:funds_added', {
            amount = amount,
            source = source or 'unknown',
            newBalance = self.cash
        })
    end

    if self.logger then
        self.logger:info(string.format("Added %d funds from %s, new balance: %d",
            amount, source or 'unknown', self.cash))
    end
end

--- Deduct funds from cash balance
-- @param amount Amount to deduct
-- @param reason Reason for deduction (optional)
-- @return boolean Success status
function FinanceService:deductFunds(amount, reason)
    if not self:canAfford(amount) then
        return false
    end

    self.cash = self.cash - amount

    -- Emit funds deducted event
    if self.eventBus then
        self.eventBus:emit('finance:funds_deducted', {
            amount = amount,
            reason = reason or 'unknown',
            newBalance = self.cash
        })
    end

    if self.logger then
        self.logger:info(string.format("Deducted %d funds for %s, new balance: %d",
            amount, reason or 'unknown', self.cash))
    end

    return true
end

--- Calculate monthly funding
-- @return number Monthly funding amount
function FinanceService:calculateMonthlyFunding()
    local totalFunding = 0

    -- Calculate funding from countries
    for countryId, fundingData in pairs(self.fundingSources) do
        local baseAmount = fundingData.baseAmount or 0
        local satisfactionModifier = self:_getCountrySatisfactionModifier(countryId)
        local securityModifier = self:_getCountrySecurityModifier(countryId)

        local countryFunding = baseAmount * satisfactionModifier * securityModifier
        totalFunding = totalFunding + countryFunding
    end

    -- Apply global modifiers
    for _, modifier in ipairs(self.fundingModifiers) do
        if modifier.type == 'multiplier' then
            totalFunding = totalFunding * modifier.value
        elseif modifier.type == 'flat' then
            totalFunding = totalFunding + modifier.value
        end
    end

    return math.floor(totalFunding)
end

--- Get country satisfaction modifier
-- @param countryId Country ID
-- @return number Satisfaction modifier (0.0 to 2.0)
function FinanceService:_getCountrySatisfactionModifier(countryId)
    -- This would integrate with geoscape country satisfaction
    -- For now, return default
    return 1.0
end

--- Get country security modifier
-- @param countryId Country ID
-- @return number Security modifier
function FinanceService:_getCountrySecurityModifier(countryId)
    -- This would integrate with geoscape security status
    -- For now, return default
    return 1.0
end

--- Process monthly finance update
function FinanceService:processMonthlyUpdate()
    -- Calculate income
    local monthlyFunding = self:calculateMonthlyFunding()
    self.monthlyIncome = monthlyFunding

    -- Calculate expenses (bases, salaries, etc.)
    self.monthlyExpenses = self:_calculateMonthlyExpenses()

    -- Add income
    self:addFunds(monthlyFunding, 'monthly_funding')

    -- Process debt payments
    self:_processDebtPayments()

    -- Check win/loss conditions
    self:_checkWinLossConditions()

    -- Emit monthly update event
    if self.eventBus then
        self.eventBus:emit('finance:month_closed', {
            income = self.monthlyIncome,
            expenses = self.monthlyExpenses,
            netIncome = self.monthlyIncome - self.monthlyExpenses,
            cash = self.cash
        })
    end
end

--- Calculate monthly expenses
-- @return number Monthly expenses
function FinanceService:_calculateMonthlyExpenses()
    local expenses = 0

    -- Base maintenance costs
    expenses = expenses + 10000  -- Base council costs

    -- Base operating costs (would integrate with base manager)
    -- expenses = expenses + self:_getBaseOperatingCosts()

    -- Debt interest payments
    expenses = expenses + self:_calculateDebtInterest()

    return expenses
end

--- Process debt payments for the month
function FinanceService:_processDebtPayments()
    for loanId, loan in pairs(self.loans) do
        if loan.status == 'active' then
            local payment = loan.monthlyPayment
            if self:deductFunds(payment, 'loan_payment_' .. loanId) then
                loan.remainingPayments = loan.remainingPayments - 1
                if loan.remainingPayments <= 0 then
                    loan.status = 'paid'
                    if self.logger then
                        self.logger:info('Loan ' .. loanId .. ' fully paid off')
                    end
                end
            else
                -- Missed payment - escalate debt
                self:_handleMissedPayment(loanId)
            end
        end
    end
end

--- Handle missed loan payment
-- @param loanId ID of the loan with missed payment
function FinanceService:_handleMissedPayment(loanId)
    local loan = self.loans[loanId]
    if not loan then return end

    loan.missedPayments = (loan.missedPayments or 0) + 1

    if loan.missedPayments >= 3 then
        -- Default on loan
        loan.status = 'defaulted'
        if self.logger then
            self.logger:warn('Loan ' .. loanId .. ' defaulted after 3 missed payments')
        end

        -- Apply penalties
        self:_applyLoanDefaultPenalties(loan)
    end
end

--- Apply penalties for loan default
-- @param loan The defaulted loan
function FinanceService:_applyLoanDefaultPenalties(loan)
    -- Reduce funding from lender country
    -- Apply diplomatic penalties
    -- This would integrate with geoscape and organization systems
end

--- Calculate total debt interest for the month
-- @return number Monthly interest payments
function FinanceService:_calculateDebtInterest()
    local totalInterest = 0

    for _, loan in pairs(self.loans) do
        if loan.status == 'active' then
            local interestPayment = (loan.principal * loan.interestRate) / 12
            totalInterest = totalInterest + interestPayment
        end
    end

    return totalInterest
end

--- Take out a loan
-- @param loanOfferId ID of the loan offer
-- @return boolean Success status
function FinanceService:takeLoan(loanOfferId)
    local offer = self.loanOffers[loanOfferId]
    if not offer then
        return false, 'Loan offer not found'
    end

    -- Check if already have this loan
    if self.loans[loanOfferId] then
        return false, 'Loan already taken'
    end

    -- Add funds
    self:addFunds(offer.amount, 'loan_' .. loanOfferId)

    -- Create loan record
    local loan = {
        id = loanOfferId,
        principal = offer.amount,
        interestRate = offer.interestRate,
        termMonths = offer.termMonths,
        monthlyPayment = (offer.amount * (1 + offer.interestRate * offer.termMonths / 12)) / offer.termMonths,
        remainingPayments = offer.termMonths,
        status = 'active',
        missedPayments = 0,
        lender = offer.lender
    }

    self.loans[loanOfferId] = loan

    -- Emit loan taken event
    if self.eventBus then
        self.eventBus:emit('finance:loan_taken', {
            loanId = loanOfferId,
            amount = offer.amount,
            lender = offer.lender
        })
    end

    if self.logger then
        self.logger:info(string.format('Took loan %s for %d credits', loanOfferId, offer.amount))
    end

    return true
end

--- Get available loan offers
-- @return table Array of available loan offers
function FinanceService:getLoanOffers()
    local available = {}

    for offerId, offer in pairs(self.loanOffers) do
        if not self.loans[offerId] then
            table.insert(available, offer)
        end
    end

    return available
end

--- Update score based on mission outcome
-- @param scoreDelta Score change amount
-- @param reason Reason for score change
function FinanceService:updateScore(scoreDelta, reason)
    self.score = self.score + scoreDelta

    -- Emit score updated event
    if self.eventBus then
        self.eventBus:emit('finance:score_updated', {
            delta = scoreDelta,
            reason = reason,
            newScore = self.score
        })
    end

    if self.logger then
        self.logger:info(string.format('Score updated by %d for %s, new score: %d',
            scoreDelta, reason or 'unknown', self.score))
    end
end

--- Get current score
-- @return number Current score
function FinanceService:getScore()
    return self.score
end

--- Update reputation
-- @param reputationType Type of reputation ('fame', 'karma', or 'diplomatic')
-- @param value Change amount
-- @param target Target for diplomatic reputation (country ID)
function FinanceService:updateReputation(reputationType, value, target)
    if reputationType == 'diplomatic' and target then
        self.reputation.diplomatic[target] = (self.reputation.diplomatic[target] or 0) + value
    else
        self.reputation[reputationType] = (self.reputation[reputationType] or 0) + value
    end

    -- Emit reputation updated event
    if self.eventBus then
        self.eventBus:emit('finance:reputation_updated', {
            type = reputationType,
            value = value,
            target = target,
            newValue = self.reputation[reputationType]
        })
    end
end

--- Get reputation value
-- @param reputationType Type of reputation
-- @param target Target for diplomatic reputation
-- @return number Reputation value
function FinanceService:getReputation(reputationType, target)
    if reputationType == 'diplomatic' and target then
        return self.reputation.diplomatic[target] or 0
    else
        return self.reputation[reputationType] or 0
    end
end

--- Check win/loss conditions
function FinanceService:_checkWinLossConditions()
    -- Check defeat conditions
    for _, condition in ipairs(self.defeatConditions) do
        if self:_checkCondition(condition) then
            self:_triggerDefeat(condition.reason)
            return
        end
    end

    -- Check victory conditions
    for _, condition in ipairs(self.victoryConditions) do
        if self:_checkCondition(condition) then
            self:_triggerVictory(condition.reason)
            return
        end
    end
end

--- Check if a condition is met
-- @param condition Condition to check
-- @return boolean True if condition is met
function FinanceService:_checkCondition(condition)
    if condition.type == 'cash_below' then
        return self.cash < condition.threshold
    elseif condition.type == 'debt_above' then
        local totalDebt = self:_calculateTotalDebt()
        return totalDebt > condition.threshold
    elseif condition.type == 'score_below' then
        return self.score < condition.threshold
    elseif condition.type == 'time_elapsed' then
        -- Would check game time
        return false
    elseif condition.type == 'objectives_complete' then
        -- Would check narrative objectives
        return false
    end

    return false
end

--- Calculate total outstanding debt
-- @return number Total debt amount
function FinanceService:_calculateTotalDebt()
    local total = 0

    for _, loan in pairs(self.loans) do
        if loan.status == 'active' then
            total = total + loan.principal
        end
    end

    return total
end

--- Trigger victory
-- @param reason Victory reason
function FinanceService:_triggerVictory(reason)
    if self.eventBus then
        self.eventBus:emit('finance:game_won', {
            reason = reason,
            finalScore = self.score,
            finalCash = self.cash
        })
    end

    if self.logger then
        self.logger:info('Victory achieved: ' .. reason)
    end
end

--- Trigger defeat
-- @param reason Defeat reason
function FinanceService:_triggerDefeat(reason)
    if self.eventBus then
        self.eventBus:emit('finance:game_lost', {
            reason = reason,
            finalScore = self.score,
            finalCash = self.cash
        })
    end

    if self.logger then
        self.logger:warn('Defeat triggered: ' .. reason)
    end
end

--- Generate monthly financial report
-- @return table Monthly report data
function FinanceService:generateMonthlyReport()
    return {
        cash = self.cash,
        income = self.monthlyIncome,
        expenses = self.monthlyExpenses,
        netIncome = self.monthlyIncome - self.monthlyExpenses,
        score = self.score,
        reputation = self.reputation,
        loans = self.loans,
        fundingSources = self.fundingSources
    }
end

--- Get finance service status summary
-- @return table Status summary
function FinanceService:getStatusSummary()
    return {
        cash = self.cash,
        monthlyIncome = self.monthlyIncome,
        monthlyExpenses = self.monthlyExpenses,
        score = self.score,
        activeLoans = #self.loans,
        totalDebt = self:_calculateTotalDebt()
    }
end

return FinanceService