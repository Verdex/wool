
local repo = require 'util/repo'
local vec = require 'util/vec'

data = {}

-- this only gets called once at the beginning
function love.load()

    local c1 = vec.create_color(1, 0, 0, 1)
    local c2 = vec.create_color(0, 1, 0, 1)

    color_path = c2:path(c1)

end

blarg = 0

-- this function is called continuously
-- dt is the delta time (in seconds) of the last
-- time that the function was called
function love.update(dt)

    blarg = blarg + dt

    if test_path_prog and blarg > 0.01 then
        blarg = 0
        test_path_prog = test_path_prog + 0.01
    end

    if test_path_prog and test_path_prog > 1 then
        test_path_prog = 0
    end
    
    if src and dest and not test_path then
        test_path = src:path(dest)
        test_path_prog = 0
    end
end

-- this is the only function that the graphics functions
-- will work in
function love.draw()

    love.graphics.clear()

    if src then
        love.graphics.setColor(0, 1, 0)
        love.graphics.circle('fill', src.x, src.y, 10, 10)
    end

    if dest then
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle('fill', dest.x, dest.y, 10, 10)
    end

    if test_path_prog then
        local c = color_path(test_path_prog)
        love.graphics.setColor(c.r, c.g, c.b, c.a)
        local p = test_path(test_path_prog) 
        love.graphics.circle('fill', p.x, p.y, 5, 10)
    end

end

function love.mousepressed(x, y, button, istouch)
    if not src then
        src = vec.create_2d(x, y)
        return
    end

    if not dest then
        dest = vec.create_2d(x, y)
        return
    end

    src = dest
    dest = vec.create_2d(x, y)
    test_path = nil
    
end

function love.mousereleased(x, y, button, istouch)

end

function love.keypressed(key)
    
end

function love.keyreleased(key)
end

function love.focus(in_focus)
end

function love.quit()
end
