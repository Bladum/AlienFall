--- TurnIndicator class for displaying current turn and active side in battlescape.
-- @classmod battlescape.TurnIndicator
-- @field turn number Current turn number
-- @field side string Current active side ("XCOM" or "Alien")

local TurnIndicator = {}
TurnIndicator.__index = TurnIndicator

--- Creates a new TurnIndicator instance.
-- @param opts table Configuration options
-- @param opts.side string Initial active side (default: "XCOM")
-- @return TurnIndicator A new TurnIndicator instance
function TurnIndicator.new(opts)
    local self = setmetatable({}, TurnIndicator)
    self.turn = 1
    self.side = opts and opts.side or "XCOM"
    return self
end

--- Sets the current turn and active side.
-- @param turn number Turn number
-- @param side string Active side ("XCOM" or "Alien")
function TurnIndicator:setTurn(turn, side)
    self.turn = turn or self.turn
    if side then
        self.side = side
    end
end

--- Draws the turn indicator panel.
-- @param x number X coordinate for the panel
-- @param y number Y coordinate for the panel
function TurnIndicator:draw(x, y)
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", x, y, 220, 80)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Turn " .. tostring(self.turn), x + 16, y + 12)
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.print("Active: " .. tostring(self.side), x + 16, y + 44)
end

return TurnIndicator
