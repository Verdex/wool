
-- bound, location, direction vector

-- id of movee
-- vector of the move
-- return boolean, ids of colliders
local function collides(move_id, vector)
    local suc, move = data.mobs:get_by_id( move_id )
    
    --local start_point = move.loc
    --local end_point = start_point:add(vector) 
    
    for _, wall in data.walls:iter() do
        if wall.collide( move.loc ) then
            return wall.id
        end
    end

    return false
    
end

local function wall(start_vec, end_vec)

    local collide = false

    if start_vec.x == end_vec.x then

        collide = function(v)
            return v.x - 10 < line_end.x and v.x + 10 > line_end.x
        end

    else
        local m = (end_vec.y - start_vec.y) / (end_vec.x - start_vec.x)
        local b = ((m * start_vec.x) - start_vec.y) * -1

        collide = function(v)
            return v.y - 10 < (m * v.x) + b and v.y + 10 > (m * v.x) + b 
        end

    end

    data.walls:add({ start_vec = start_vec
                   ; end_vec = end_vec
                   ; collide = collide
                   })
end


return { wall = wall
       ; collides = collides
       }

