-- Player ship

local Bullets = require("bullets")

local Player = {}
Player.__index = Player

local SPEED = 400
local SHOOT_COOLDOWN = 0.1       -- seconds between shots
local BOMB_COOLDOWN = 1.0        -- seconds between bombs
local INVINCIBLE_TIME = 2.0      -- seconds after respawn
local HITBOX_RADIUS = 4          -- tiny hitbox (classic shmup)
local SPRITE_W = 48
local SPRITE_H = 48

function Player.new()
    local self = setmetatable({}, Player)
    self.x = 960 / 2
    self.y = 1280 - 150
    self.w = SPRITE_W
    self.h = SPRITE_H
    self.hitboxRadius = HITBOX_RADIUS
    self.speed = SPEED
    self.lives = 3
    self.bombs = 3
    self.score = 0
    self.shootTimer = 0
    self.bombTimer = 0
    self.invincibleTimer = 0
    self.alive = true
    self.weaponLevel = 1          -- 1-4
    self.shooting = false
    self.bombActive = false
    self.bombFlashTimer = 0
    return self
end

function Player:reset()
    self.x = 960 / 2
    self.y = 1280 - 150
    self.lives = 3
    self.bombs = 3
    self.score = 0
    self.weaponLevel = 1
    self.alive = true
    self.invincibleTimer = 0
    self.bombActive = false
end

function Player:respawn()
    self.x = 960 / 2
    self.y = 1280 - 150
    self.invincibleTimer = INVINCIBLE_TIME
    self.weaponLevel = math.max(1, self.weaponLevel - 1)
    self.alive = true
end

function Player:update(dt)
    if not self.alive then return end

    -- movement (keyboard)
    local dx, dy = 0, 0
    if love.keyboard.isDown("left", "a") then dx = -1 end
    if love.keyboard.isDown("right", "d") then dx = 1 end
    if love.keyboard.isDown("up", "w") then dy = -1 end
    if love.keyboard.isDown("down", "s") then dy = 1 end

    -- joystick/gamepad
    local joysticks = love.joystick.getJoysticks()
    if #joysticks > 0 then
        local joy = joysticks[1]
        if joy:isGamepad() then
            local lx = joy:getGamepadAxis("leftx")
            local ly = joy:getGamepadAxis("lefty")
            if math.abs(lx) > 0.2 then dx = dx + lx end
            if math.abs(ly) > 0.2 then dy = dy + ly end
            -- d-pad
            if joy:isGamepadDown("dpleft") then dx = -1 end
            if joy:isGamepadDown("dpright") then dx = 1 end
            if joy:isGamepadDown("dpup") then dy = -1 end
            if joy:isGamepadDown("dpdown") then dy = 1 end
        else
            -- raw joystick (arcade stick)
            local ax = joy:getAxis(1) or 0
            local ay = joy:getAxis(2) or 0
            if math.abs(ax) > 0.2 then dx = dx + ax end
            if math.abs(ay) > 0.2 then dy = dy + ay end
        end
    end

    -- normalize diagonal
    local len = math.sqrt(dx*dx + dy*dy)
    if len > 1 then
        dx = dx / len
        dy = dy / len
    end

    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt

    -- clamp to screen
    self.x = math.max(self.w/2, math.min(960 - self.w/2, self.x))
    self.y = math.max(self.h/2, math.min(1280 - self.h/2, self.y))

    -- timers
    self.shootTimer = math.max(0, self.shootTimer - dt)
    self.bombTimer = math.max(0, self.bombTimer - dt)
    self.invincibleTimer = math.max(0, self.invincibleTimer - dt)

    -- autofire when holding shoot
    if self.shooting and self.shootTimer <= 0 then
        self:shoot()
    end

    -- bomb flash
    if self.bombActive then
        self.bombFlashTimer = self.bombFlashTimer - dt
        if self.bombFlashTimer <= 0 then
            self.bombActive = false
        end
    end
end

function Player:shoot()
    if self.shootTimer > 0 then return end
    self.shootTimer = SHOOT_COOLDOWN

    local bx = self.x
    local by = self.y - self.h/2

    if self.weaponLevel == 1 then
        -- single shot
        Bullets.spawnPlayer(bx, by, 0, -800)
    elseif self.weaponLevel == 2 then
        -- double shot
        Bullets.spawnPlayer(bx - 10, by, 0, -800)
        Bullets.spawnPlayer(bx + 10, by, 0, -800)
    elseif self.weaponLevel == 3 then
        -- triple spread
        Bullets.spawnPlayer(bx, by, 0, -800)
        Bullets.spawnPlayer(bx - 10, by, -80, -780)
        Bullets.spawnPlayer(bx + 10, by, 80, -780)
    else
        -- quad spread + fast
        Bullets.spawnPlayer(bx - 8, by, 0, -900)
        Bullets.spawnPlayer(bx + 8, by, 0, -900)
        Bullets.spawnPlayer(bx - 16, by, -120, -780)
        Bullets.spawnPlayer(bx + 16, by, 120, -780)
    end
end

function Player:useBomb()
    if self.bombs <= 0 or self.bombTimer > 0 then return false end
    self.bombs = self.bombs - 1
    self.bombTimer = BOMB_COOLDOWN
    self.bombActive = true
    self.bombFlashTimer = 0.6
    self.invincibleTimer = math.max(self.invincibleTimer, 0.8)
    return true
end

function Player:hit()
    if self.invincibleTimer > 0 or self.bombActive then return false end
    self.alive = false
    self.lives = self.lives - 1
    return true
end

function Player:isInvincible()
    return self.invincibleTimer > 0 or self.bombActive
end

function Player:addScore(points)
    self.score = self.score + points
end

function Player:powerUp()
    self.weaponLevel = math.min(4, self.weaponLevel + 1)
end

function Player:addBomb()
    self.bombs = math.min(9, self.bombs + 1)
end

function Player:draw()
    if not self.alive then return end

    -- blink when invincible
    if self.invincibleTimer > 0 then
        if math.floor(self.invincibleTimer * 10) % 2 == 0 then
            return
        end
    end

    -- placeholder ship (triangle)
    love.graphics.setColor(0.2, 0.6, 1.0)
    love.graphics.polygon("fill",
        self.x, self.y - self.h/2,
        self.x - self.w/2, self.y + self.h/2,
        self.x + self.w/2, self.y + self.h/2
    )
    -- cockpit
    love.graphics.setColor(0.8, 0.9, 1.0)
    love.graphics.circle("fill", self.x, self.y, 6)

    -- hitbox indicator (tiny dot)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.circle("fill", self.x, self.y, self.hitboxRadius)

    love.graphics.setColor(1, 1, 1)
end

return Player
