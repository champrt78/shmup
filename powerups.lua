-- Powerup system — stub, we'll design types together

local Powerups = {}

local active = {}

-- TODO: define powerup types, drop rates, effects
local TYPES = {
    weapon = { color={0.2, 0.8, 1.0}, label="W" },
    bomb   = { color={1.0, 0.5, 0.1}, label="B" },
}

function Powerups.spawn(typeName, x, y)
    local def = TYPES[typeName] or TYPES.weapon
    table.insert(active, {
        x=x, y=y, w=24, h=24,
        type=typeName, color=def.color, label=def.label,
        speed=80, alive=true,
    })
end

function Powerups.getActive() return active end

function Powerups.clear() active = {} end

function Powerups.update(dt)
    for i = #active, 1, -1 do
        local p = active[i]
        p.y = p.y + p.speed * dt
        if p.y > 1300 or not p.alive then
            table.remove(active, i)
        end
    end
end

function Powerups.draw()
    for _, p in ipairs(active) do
        love.graphics.setColor(p.color)
        love.graphics.rectangle("fill", p.x - p.w/2, p.y - p.h/2, p.w, p.h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(p.label, p.x - p.w/2, p.y - 6, p.w, "center")
    end
    love.graphics.setColor(1, 1, 1)
end

return Powerups
