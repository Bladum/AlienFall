local SquadPanel = {}
SquadPanel.__index = SquadPanel

function SquadPanel.new(opts)
    local self = setmetatable({}, SquadPanel)
    self.soldiers = opts and opts.soldiers or {}
    return self
end

function SquadPanel:populate(squad)
    self.soldiers = squad or {}
end

function SquadPanel:draw(x, y)
    love.graphics.setColor(0.15, 0.15, 0.18, 1)
    love.graphics.rectangle("fill", x, y, 520, 260)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Squad Loadout", x + 16, y + 12)
    love.graphics.setFont(love.graphics.newFont(16))

    if #self.soldiers == 0 then
        love.graphics.print("No soldiers assigned", x + 16, y + 48)
        return
    end

    for index, soldier in ipairs(self.soldiers) do
        local line = string.format("%d) %s - %s", index, soldier.name or "Soldier", soldier.role or "Rookie")
        love.graphics.print(line, x + 16, y + 48 + (index - 1) * 24)
    end
end

return SquadPanel
