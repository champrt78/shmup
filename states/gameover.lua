-- Game over state

local Background = require("background")

local GameOver = {}

GameOver.finalScore = 0
local timer = 0

function GameOver:enter()
    timer = 0
end

function GameOver:update(dt)
    Background.update(dt)
    timer = timer + dt
end

function GameOver:draw()
    love.graphics.clear(0, 0, 0)
    Background.draw()

    local bigFont = love.graphics.newFont(64)
    love.graphics.setFont(bigFont)
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.printf("GAME OVER", 0, 400, 960, "center")

    local medFont = love.graphics.newFont(36)
    love.graphics.setFont(medFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SCORE: " .. self.finalScore, 0, 520, 960, "center")

    love.graphics.setColor(0.8, 0.8, 0.2)
    love.graphics.printf("HI SCORE: " .. HIGH_SCORE, 0, 580, 960, "center")

    if timer > 2.0 then
        if math.floor(timer * 2) % 2 == 0 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("PRESS SHOOT TO CONTINUE", 0, 750, 960, "center")
        end
    end

    love.graphics.setColor(1, 1, 1)
end

function GameOver:keypressed(key)
    if timer > 2.0 and (key == "z" or key == "space" or key == "return") then
        setState("title")
    end
end

function GameOver:gamepadpressed(joystick, button)
    if timer > 2.0 and (button == "a" or button == "b") then
        setState("title")
    end
end

return GameOver
