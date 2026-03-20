-- Enemy manager — add enemy types here

local Bullets = require("bullets")

local Enemies = {}

local active = {}

-- Enemy type definitions (extend these)
local TYPES = {
    basic = { w=32, h=32, hp=1, speed=150, score=100, color={1, 0.3, 0.3} },
    fast  = { w=28, h=28, hp=1, speed=280, score=150, color={1, 0.6, 0.2} },
    tough = { w=40, h=40, hp=3, speed=100, score=300, color={0.8, 0.2, 0.8} },
}

function Enemies.spawn(typeName, x, y)
    local def = TYPES[typeName] or TYPES.basic
    table.insert(active, {
        x = x, y = y,
        w = def.w, h = def.h,
        hp = def.hp,
        speed = def.speed,
        score = def.score,
        color = def.color,
        alive = true,
        shootTimer = math.random() * 2,
    })
end

function Enemies.getActive() return active end

function Enemies.clear()
    active = {}
end

function Enemies.killAll()
    for _, e in ipairs(active) do
        e.alive = false
    end
end

function Enemies.update(dt)
    for i = #active, 1, -1 do
        local e = active[i]
        -- basic downward movement (customize per type)
        e.y = e.y + e.speed * dt

        -- simple shoot timer
        e.shootTimer = e.shootTimer - dt
        if e.shootTimer <= 0 then
            Bullets.spawnEnemy(e.x, e.y + e.h/2, 0, 300)
            e.shootTimer = 1.5 + math.random() * 2
        end

        -- remove if off screen or dead
        if e.y > 1350 or not e.alive then
            table.remove(active, i)
        end
    end
end

function Enemies.draw()
    for _, e in ipairs(active) do
        love.graphics.setColor(e.color)
        love.graphics.rectangle("fill", e.x - e.w/2, e.y - e.h/2, e.w, e.h)
    end
    love.graphics.setColor(1, 1, 1)
end

return Enemies
