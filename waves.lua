-- Wave scripting — table-driven enemy spawns

local Enemies = require("enemies")

local Waves = {}

-- Define waves here: each entry is {time, enemyType, x, y}
-- time = seconds from wave start
local WAVE_DATA = {
    -- Wave 1: basic enemies filing in
    {
        {0.0, "basic", 200, -40},
        {0.3, "basic", 300, -40},
        {0.6, "basic", 400, -40},
        {0.9, "basic", 500, -40},
        {1.2, "basic", 600, -40},
        {3.0, "basic", 700, -40},
        {3.3, "basic", 600, -40},
        {3.6, "basic", 500, -40},
        {3.9, "basic", 400, -40},
        {4.2, "basic", 300, -40},
    },
    -- Wave 2: mix
    {
        {0.0, "fast", 150, -40},
        {0.2, "fast", 250, -40},
        {0.4, "fast", 350, -40},
        {1.5, "tough", 480, -40},
        {2.0, "basic", 600, -40},
        {2.3, "basic", 700, -40},
        {2.6, "basic", 800, -40},
    },
    -- Add more waves...
}

local currentWave = 0
local waveTimer = 0
local spawnIndex = 0
local betweenWaves = false
local betweenTimer = 0
local BETWEEN_DELAY = 3.0

function Waves.reset()
    currentWave = 0
    waveTimer = 0
    spawnIndex = 0
    betweenWaves = true
    betweenTimer = 1.0
end

function Waves.update(dt)
    if betweenWaves then
        betweenTimer = betweenTimer - dt
        if betweenTimer <= 0 then
            betweenWaves = false
            currentWave = currentWave + 1
            waveTimer = 0
            spawnIndex = 1
            if currentWave > #WAVE_DATA then
                currentWave = 1  -- loop waves (increase difficulty later)
            end
        end
        return
    end

    local wave = WAVE_DATA[currentWave]
    if not wave then return end

    waveTimer = waveTimer + dt

    while spawnIndex <= #wave and waveTimer >= wave[spawnIndex][1] do
        local entry = wave[spawnIndex]
        Enemies.spawn(entry[2], entry[3], entry[4])
        spawnIndex = spawnIndex + 1
    end

    -- wave done when all spawned and no enemies left
    if spawnIndex > #wave and #Enemies.getActive() == 0 then
        betweenWaves = true
        betweenTimer = BETWEEN_DELAY
    end
end

function Waves.getCurrentWave()
    return currentWave
end

return Waves
