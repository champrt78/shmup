-- Bullet pool (player + enemy)

local Bullets = {}

local playerBullets = {}
local enemyBullets = {}

function Bullets.spawnPlayer(x, y, vx, vy)
    table.insert(playerBullets, {x=x, y=y, vx=vx, vy=vy, w=6, h=12, alive=true})
end

function Bullets.spawnEnemy(x, y, vx, vy)
    table.insert(enemyBullets, {x=x, y=y, vx=vx, vy=vy, w=8, h=8, alive=true})
end

function Bullets.getPlayerBullets() return playerBullets end
function Bullets.getEnemyBullets() return enemyBullets end

function Bullets.clear()
    playerBullets = {}
    enemyBullets = {}
end

function Bullets.update(dt)
    for i = #playerBullets, 1, -1 do
        local b = playerBullets[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt
        if b.y < -20 or not b.alive then
            table.remove(playerBullets, i)
        end
    end
    for i = #enemyBullets, 1, -1 do
        local b = enemyBullets[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt
        if b.y > 1300 or b.x < -20 or b.x > 980 or not b.alive then
            table.remove(enemyBullets, i)
        end
    end
end

function Bullets.draw()
    -- player bullets (yellow)
    love.graphics.setColor(1, 1, 0.3)
    for _, b in ipairs(playerBullets) do
        love.graphics.rectangle("fill", b.x - b.w/2, b.y - b.h/2, b.w, b.h)
    end
    -- enemy bullets (red)
    love.graphics.setColor(1, 0.2, 0.2)
    for _, b in ipairs(enemyBullets) do
        love.graphics.circle("fill", b.x, b.y, b.w/2)
    end
    love.graphics.setColor(1, 1, 1)
end

return Bullets
