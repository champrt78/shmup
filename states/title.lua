-- Title screen state

local Background = require("background")

local Title = {}

local blinkTimer = 0

function Title:enter()
    Background.init()
    blinkTimer = 0
end

function Title:update(dt)
    Background.update(dt)
    blinkTimer = blinkTimer + dt
end

function Title:draw()
    love.graphics.clear(0, 0, 0)
    Background.draw()

    -- title
    local bigFont = love.graphics.newFont(72)
    love.graphics.setFont(bigFont)
    love.graphics.setColor(1, 0.3, 0.2)
    love.graphics.printf("SHMUP", 0, 350, 960, "center")

    -- subtitle
    local medFont = love.graphics.newFont(28)
    love.graphics.setFont(medFont)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("A VERTICAL SHOOTER", 0, 440, 960, "center")

    -- hi score
    love.graphics.setColor(0.8, 0.8, 0.2)
    love.graphics.printf("HI SCORE: " .. HIGH_SCORE, 0, 550, 960, "center")

    -- blink "press start"
    if math.floor(blinkTimer * 2) % 2 == 0 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("PRESS SHOOT TO START", 0, 750, 960, "center")
    end

    love.graphics.setColor(1, 1, 1)
end

function Title:keypressed(key)
    if key == "z" or key == "space" or key == "return" then
        setState("gameplay")
    end
end

function Title:gamepadpressed(joystick, button)
    -- button 1 (shoot) = start
    if button == "a" or button == "b" then
        setState("gameplay")
    end
end

return Title
