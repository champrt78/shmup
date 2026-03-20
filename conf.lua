function love.conf(t)
    t.title = "SHMUP"
    t.version = "11.4"

    t.window.width = 960
    t.window.height = 1280
    t.window.fullscreen = false      -- set true for arcade cab
    t.window.fullscreentype = "exclusive"
    t.window.vsync = 1
    t.window.resizable = false

    t.modules.joystick = true
    t.modules.audio = true
    t.modules.sound = true
end
