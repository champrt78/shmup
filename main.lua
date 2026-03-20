-- Main entry point and state machine

local states = {}
local currentState = nil

function setState(name)
    if currentState and currentState.leave then
        currentState:leave()
    end
    currentState = states[name]
    if currentState and currentState.enter then
        currentState:enter()
    end
end

function getState(name)
    return states[name]
end

function love.load()
    -- seed RNG
    math.randomseed(os.time())

    -- pixel-perfect scaling
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- load all states
    states.title = require("states.title")
    states.gameplay = require("states.gameplay")
    states.gameover = require("states.gameover")

    -- load high score
    loadHighScore()

    setState("title")
end

function love.update(dt)
    -- cap delta to prevent spiral of death
    dt = math.min(dt, 1/30)
    if currentState and currentState.update then
        currentState:update(dt)
    end
end

function love.draw()
    if currentState and currentState.draw then
        currentState:draw()
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
        return
    end
    if currentState and currentState.keypressed then
        currentState:keypressed(key)
    end
end

function love.keyreleased(key)
    if currentState and currentState.keyreleased then
        currentState:keyreleased(key)
    end
end

function love.gamepadpressed(joystick, button)
    if currentState and currentState.gamepadpressed then
        currentState:gamepadpressed(joystick, button)
    end
end

function love.gamepadreleased(joystick, button)
    if currentState and currentState.gamepadreleased then
        currentState:gamepadreleased(joystick, button)
    end
end

-- High score persistence
HIGH_SCORE = 0

function loadHighScore()
    local info = love.filesystem.getInfo("highscore.dat")
    if info then
        local data = love.filesystem.read("highscore.dat")
        HIGH_SCORE = tonumber(data) or 0
    end
end

function saveHighScore(score)
    if score > HIGH_SCORE then
        HIGH_SCORE = score
        love.filesystem.write("highscore.dat", tostring(score))
    end
end
