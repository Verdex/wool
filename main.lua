
local repo = require 'repo'
local util = require 'util'
local geo = require 'geo'

local throw = require 'effects/throw'
local mob = require 'draws/mob'

local shake = require 'augs/shake'
local shift = require 'augs/shift'
local bounce = require 'augs/bounce'

local damage = require 'actions/damage'

data = {}

-- this only gets called once at the beginning
function love.load()

    data.draw = repo.create_standard()
    data.effects = repo.create_standard()
    data.update = repo.create_standard() 

    color_path = geo.vec_3d_path({x = 0, y = 1, z = 0}, {x = 1, y = 0, z = 0})

    local x = throw.create( function (x,y)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle('fill', x, y, 10, 10)
    end, 0, 0, 100, 100, 30)

    data.update:add(x)
    data.effects:add(x)

    local m = mob.create('@') 
    m.x = 300
    m.y = 300

    ID = m.id

    data.draw:add(m)
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
    
    if _x_dest and _x_src and not test_path then
        test_path = geo.vec_2d_path({x = _x_src, y = _y_src }, {x = _x_dest, y = _y_dest}) 
        test_path_prog = 0
    end


    local remove = {}
    for _, v in data.update:iter() do
        v:update(dt)     
        if v.dead then
            remove[#remove+1] = v.id
        end
    end

    for _, v in ipairs(remove) do
        data.update:remove_by_id(v)
    end

end

-- this is the only function that the graphics functions
-- will work in
function love.draw()

    love.graphics.clear()

    if _x_src then
        love.graphics.setColor(0, 1, 0)
        love.graphics.circle('fill', _x_src, _y_src, 10, 10)
    end

    if _x_dest then
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle('fill', _x_dest, _y_dest, 10, 10)
    end

    if test_path_prog then
        local c = color_path(test_path_prog)
        love.graphics.setColor(c.x, c.y, c.z)
        local p = test_path(test_path_prog) 
        love.graphics.circle('fill', p.x, p.y, 5, 10)
    end

    local rd = {}
    for _, v in data.draw:iter() do
        if v.visible then
            v:draw()
        end
        if v.dead then
            rd[#rd+1] = v.id 
        end
    end

    local re = {}
    for _, v in data.effects:iter() do
        if v.visible then
            v:draw()
        end
        if v.dead then
            re[#re+1] = v.id 
        end
    end

    for _, v in ipairs(rd) do
        data.draw:remove_by_id(v)
    end

    for _, v in ipairs(re) do
        data.effects:remove_by_id(v)
    end

end

function love.mousepressed(x, y, button, istouch)
    if not _x_src then
        _x_src = x
        _y_src = y
        return
    end

    if not _x_dest then
        _x_dest = x
        _y_dest = y
        return
    end

    _x_src = _x_dest
    _y_src = _y_dest
    _x_dest = x
    _y_dest = y
    test_path = nil
    
end

function love.mousereleased(x, y, button, istouch)

end

function love.keypressed(key)
    local suc, target = data.draw:get_by_id(ID) 

    damage.at("999", {r = 1, g = 1, b = 1, a = 1}, target.x, target.y)
    
end

function love.keyreleased(key)
end

function love.focus(in_focus)
end

function love.quit()
end
