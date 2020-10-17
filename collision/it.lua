
-- bound, location, direction vector

-- id of movee
-- vector of the move
-- return boolean, ids of colliders
local function collides(move_id, vector)
    local suc, move = data.mobs:get_by_id( move_id )

    if not suc then
        return false, 'mob not found'
    end

    local direction = vector:unit()
    local point = direction:scale_mut(move.radius)
                           :add_mut(move.loc)


    for _, wall in data.walls:iter() do
        if wall.collide( point ) then
            return 'wall', wall.id
        end
    end

    for _, mob in data.mobs:iter() do
        if mob.id ~= move_id and mob.collide( point, mob.loc ) then
            return 'mob', mob.id
        end
    end

    return false, 'no collisions'
    
end

local function mob(loc, radius)
    local dist_sq = radius * radius

    local collide = function(v, s)
        return s:distance_squared(v) < dist_sq
    end

    return data.mobs:add({ loc = loc
                         ; radius = radius
                         ; collide = collide
                         })
end

local function wall(start_vec, end_vec)

    local collide = false

    if start_vec.x == end_vec.x then

        collide = function(v)
            return v.x - 2 < line_end.x and v.x + 2 > line_end.x
        end

    else
        local m = (end_vec.y - start_vec.y) / (end_vec.x - start_vec.x)
        local b = ((m * start_vec.x) - start_vec.y) * -1

        collide = function(v)
            return v.y - 2 < (m * v.x) + b and v.y + 2 > (m * v.x) + b 
        end

    end

    return data.walls:add({ start_vec = start_vec
                          ; end_vec = end_vec
                          ; collide = collide
                          })
end


return { wall = wall
       ; mob = mob
       ; collides = collides
       }

