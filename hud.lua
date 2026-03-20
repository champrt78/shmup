-- Heads-up display

local HUD = {}

local font = nil

function HUD.init()
    font = love.graphics.newFont(28)
end

function HUD.draw(player, wave)
    love.graphics.setFont(font)

    -- score (top left)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SCORE " .. player.score, 20, 10, 400, "left")

    -- hi score (top center)
    love.graphics.setColor(0.8, 0.8, 0.2)
    love.graphics.printf("HI " .. HIGH_SCORE, 0, 10, 960, "center")

    -- wave (top right area)
    love.graphics.setColor(0.6, 0.8, 1.0)
    love.graphics.printf("WAVE " .. (wave or 0), -20, 10, 960, "right")

    -- lives (bottom left)
    love.graphics.setColor(0.2, 0.6, 1.0)
    for i = 1, player.lives do
        love.graphics.polygon("fill",
            20 + (i-1)*35, 1260,
            20 + (i-1)*35 - 10, 1275,
            20 + (i-1)*35 + 10, 1275
        )
    end

    -- bombs (bottom right)
    love.graphics.setColor(1.0, 0.5, 0.1)
    for i = 1, player.bombs do
        love.graphics.circle("fill", 920 - (i-1)*30, 1268, 8)
    end

    love.graphics.setColor(1, 1, 1)
end

return HUD
