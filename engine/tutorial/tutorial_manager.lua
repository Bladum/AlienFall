---Tutorial Manager - Basic Tutorial System
---
---Simple tutorial system for guiding new players through game mechanics.
---Provides step-by-step instructions, hints, and progression tracking.
---
---@module tutorial.tutorial_manager
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local TutorialManager = {}

---@class TutorialManager
---@field currentTutorial table? Current active tutorial
---@field completedTutorials table Set of completed tutorial IDs
---@field tutorialState table Current tutorial progress state

-- Singleton instance
TutorialManager.instance = nil

---Initialize the tutorial manager
---@return TutorialManager instance Manager instance
function TutorialManager.initialize()
    if TutorialManager.instance then
        return TutorialManager.instance
    end

    TutorialManager.instance = {
        currentTutorial = nil,
        completedTutorials = {},
        tutorialState = {}
    }

    print("[TutorialManager] Initialized")
    return TutorialManager.instance
end

---Get singleton instance
---@return TutorialManager instance Manager instance
function TutorialManager.getInstance()
    if not TutorialManager.instance then
        TutorialManager.initialize()
    end
    return TutorialManager.instance
end

---Start a tutorial
---@param tutorialId string Tutorial ID to start
---@return boolean success True if tutorial started successfully
function TutorialManager.startTutorial(tutorialId)
    local instance = TutorialManager.getInstance()

    -- Check if tutorial exists
    local tutorial = TutorialManager.getTutorialDefinition(tutorialId)
    if not tutorial then
        print("[TutorialManager] Tutorial not found: " .. tutorialId)
        return false
    end

    -- Check if already completed
    if instance.completedTutorials[tutorialId] then
        print("[TutorialManager] Tutorial already completed: " .. tutorialId)
        return false
    end

    instance.currentTutorial = tutorial
    instance.tutorialState = {
        tutorialId = tutorialId,
        currentStep = 1,
        startedAt = os.time(),
        hintsShown = {}
    }

    print("[TutorialManager] Started tutorial: " .. tutorialId)
    return true
end

---Advance to next tutorial step
---@return boolean hasNext True if there are more steps
function TutorialManager.nextStep()
    local instance = TutorialManager.getInstance()

    if not instance.currentTutorial then
        return false
    end

    local currentStep = instance.tutorialState.currentStep
    local totalSteps = #instance.currentTutorial.steps

    if currentStep < totalSteps then
        instance.tutorialState.currentStep = currentStep + 1
        print(string.format("[TutorialManager] Advanced to step %d/%d", instance.tutorialState.currentStep, totalSteps))
        return true
    else
        -- Tutorial completed
        TutorialManager.completeTutorial()
        return false
    end
end

---Complete current tutorial
function TutorialManager.completeTutorial()
    local instance = TutorialManager.getInstance()

    if not instance.currentTutorial then
        return
    end

    local tutorialId = instance.tutorialState.tutorialId
    instance.completedTutorials[tutorialId] = true
    instance.currentTutorial = nil
    instance.tutorialState = {}

    print("[TutorialManager] Completed tutorial: " .. tutorialId)
end

---Get current tutorial step
---@return table? step Current step data or nil if no active tutorial
function TutorialManager.getCurrentStep()
    local instance = TutorialManager.getInstance()

    if not instance.currentTutorial then
        return nil
    end

    local stepIndex = instance.tutorialState.currentStep
    return instance.currentTutorial.steps[stepIndex]
end

---Show hint for current step
---@return string? hint Hint text or nil if no hint available
function TutorialManager.showHint()
    local instance = TutorialManager.getInstance()

    local step = TutorialManager.getCurrentStep()
    if not step or not step.hint then
        return nil
    end

    local stepKey = instance.tutorialState.tutorialId .. "_" .. instance.tutorialState.currentStep
    instance.tutorialState.hintsShown[stepKey] = true

    return step.hint
end

---Check if hint was shown for current step
---@return boolean shown True if hint was shown
function TutorialManager.wasHintShown()
    local instance = TutorialManager.getInstance()

    if not instance.currentTutorial then
        return false
    end

    local stepKey = instance.tutorialState.tutorialId .. "_" .. instance.tutorialState.currentStep
    return instance.tutorialState.hintsShown[stepKey] == true
end

---Get tutorial definition (mock implementation)
---@param tutorialId string Tutorial ID
---@return table? tutorial Tutorial definition or nil if not found
function TutorialManager.getTutorialDefinition(tutorialId)
    local tutorials = {
        basic_movement = {
            id = "basic_movement",
            name = "Basic Movement",
            description = "Learn how to move your soldiers",
            steps = {
                {
                    title = "Select a Unit",
                    instruction = "Click on a soldier to select them",
                    hint = "Look for the blue highlight around units"
                },
                {
                    title = "Move the Unit",
                    instruction = "Right-click on an empty tile to move",
                    hint = "Green tiles show valid movement destinations"
                },
                {
                    title = "End Turn",
                    instruction = "Click the 'End Turn' button when ready",
                    hint = "It's usually in the bottom right corner"
                }
            }
        },
        combat_basics = {
            id = "combat_basics",
            name = "Combat Basics",
            description = "Learn the fundamentals of combat",
            steps = {
                {
                    title = "Target Enemy",
                    instruction = "Click on an enemy unit to target them",
                    hint = "Enemies are highlighted in red"
                },
                {
                    title = "Choose Action",
                    instruction = "Select an action from the action menu",
                    hint = "Actions include Shoot, Move, and Overwatch"
                }
            }
        }
    }

    return tutorials[tutorialId]
end

---Get all available tutorial IDs
---@return table tutorialIds Array of tutorial IDs
function TutorialManager.getAvailableTutorials()
    return {"basic_movement", "combat_basics"}
end

---Check if tutorial is completed
---@param tutorialId string Tutorial ID
---@return boolean completed True if tutorial is completed
function TutorialManager.isTutorialCompleted(tutorialId)
    local instance = TutorialManager.getInstance()
    return instance.completedTutorials[tutorialId] == true
end

---Get tutorial progress statistics
---@return table stats Progress statistics
function TutorialManager.getProgressStats()
    local instance = TutorialManager.getInstance()

    local available = TutorialManager.getAvailableTutorials()
    local completed = 0
    for _, tutorialId in ipairs(available) do
        if instance.completedTutorials[tutorialId] then
            completed = completed + 1
        end
    end

    return {
        total = #available,
        completed = completed,
        inProgress = instance.currentTutorial ~= nil
    }
end

return TutorialManager



