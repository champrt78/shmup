-- Main gameplay state

local Player = require("player")
local Bullets = require("bullets")
local Enemies = require("enemies")
local Waves = require("waves")
local Powerups = require("powerups")
local Collision = require("collision")
local Background = require("background")
local HUD = require("hud")

local Gameplay = {}

local player = nil
local respawnTimer = 0
local RESPAWN_DELAY = 1.5

function Gameplay:enter()
    player = Player.new()
    Bullets.clear()
    Enemies.clear()
    Powerups.clear()
    Waves.reset()
    Background.init()
    HUD.init()
    respawnTimer = 0
end

function Gameplay:update(dt)
    Background.update(dt)

    if player.alive then
        player:update(dt)
    else
        -- respawn or game over
        respawnTimer = respawnTimer + dt
        if respawnTimer >= RESPAWN_DELAY then
            if player.lives > 0 then
                player:respawn()
                respawnTimer = 0
            else
                saveHighScore(player.score)
                getState("gameover").finalScore = player.score
                setState("gameover")
                return
            end
        end
    end

    Waves.update(dt)
    Enemies.update(dt)
    Bullets.update(dt)
    Powerups.update(dt)

    -- bomb clears all
    if player.bombActive then
        Enemies.killAll()
        Bullets.clear()
    end

    self:checkCollisions()
end

function Gameplay:checkCollisions()
    local enemies = Enemies.getActive()
    local pBullets = Bullets.getPlayerBullets()
    local eBullets = Bullets.getEnemyBullets()
    local pups = Powerups.getActive()

    -- player bullets vs enemies
    for _, b in ipairs(pBullets) do
        for _, e in ipairs(enemies) do
            if b.alive and e.alive then
                if Collision.aabb(b.x, b.y, b.w, b.h, e.x, e.y, e.w, e.h) then
                    b.alive = false
                    e.hp = e.hp - 1
                    if e.hp <= 0 then
                        e.alive = false
                        player:addScore(e.score)
                        -- chance to drop powerup
                        if math.random() < 0.15 then
                            local ptype = math.random() < 0.7 and "weapon" or "bomb"
                            Powerups.spawn(ptype, e.x, e.y)
                        end
                    end
                end
            end
        end
    end

    if not player.alive or player:isInvincible() then return end

    -- enemy bullets vs player
    for _, b in ipairs(eBullets) do
        if b.alive then
            if Collision.circleRect(player.x, player.y, player.hitboxRadius,
                                     b.x, b.y, b.w, b.h) then
                b.alive = false
                player:hit()
                return
            end
        end
    end

    -- enemy body vs player
    for _, e in ipairs(enemies) do
        if e.alive then
            if Collision.circleRect(player.x, player.y, player.hitboxRadius,
                                     e.x, e.y, e.w, e.h) then
                e.alive = false
                player:hit()
                return
            end
        end
    end

    -- powerups vs player (generous hitbox)
    for _, p in ipairs(pups) do
        if p.alive then
            if Collision.aabb(player.x, player.y, player.w, player.h,
                              p.x, p.y, p.w, p.h) then
                p.alive = false
                if p.type == "weapon" then
                    player:powerUp()
                elseif p.type == "bomb" then
                    player:addBomb()
                end
            end
        end
    end
end

function Gameplay:draw()
    love.graphics.clear(0, 0, 0.02)
    Background.draw()
    Powerups.draw()
    Enemies.draw()
    Bullets.draw()
    player:draw()

    -- bomb flash
    if player.bombActive then
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.rectangle("fill", 0, 0, 960, 1280)
        love.graphics.setColor(1, 1, 1)
    end

    HUD.draw(player, Waves.getCurrentWave())
end

function Gameplay:keypressed(key)
    if key == "z" or key == "space" then
        player.shooting = true
    elseif key == "x" or key == "lshift" then
        player:useBomb()
    end
end

function Gameplay:keyreleased(key)
    if key == "z" or key == "space" then
        player.shooting = false
    end
end

function Gameplay:gamepadpressed(joystick, button)
    if button == "a" then
        player.shooting = true
    elseif button == "b" then
        player:useBomb()
    end
end

function Gameplay:gamepadreleased(joystick, button)
    if button == "a" then
        player.shooting = false
    end
end

return Gameplay
