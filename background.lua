-- Scrolling parallax background

local Background = {}

local layers = {}

function Background.init()
    layers = {}
    -- star layers at different speeds
    for i = 1, 3 do
        local stars = {}
        for _ = 1, 40 * i do
            table.insert(stars, {
                x = math.random(0, 960),
                y = math.random(0, 1280),
                size = i,
                speed = 30 * i,
            })
        end
        table.insert(layers, stars)
    end
end

function Background.update(dt)
    for _, layer in ipairs(layers) do
        for _, star in ipairs(layer) do
            star.y = star.y + star.speed * dt
            if star.y > 1280 then
                star.y = -2
                star.x = math.random(0, 960)
            end
        end
    end
end

function Background.draw()
    for _, layer in ipairs(layers) do
        for _, star in ipairs(layer) do
            local brightness = 0.2 + star.size * 0.2
            love.graphics.setColor(brightness, brightness, brightness + 0.1)
            love.graphics.rectangle("fill", star.x, star.y, star.size, star.size)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return Background
