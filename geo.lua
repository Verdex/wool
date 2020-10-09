
local function distance_square(x1, y1, x2, y2)
    return math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2)
end

local function distance(x1, y1, x2, y2)
    return math.pow(distance_square(x1, y1, x2, y2), 0.5)
end

local function vec_2d_path(v1, v2)
    local v = { x = v2.x - v1.x
              ; y = v2.y - v1.y
              }

    return function(d)
        local x = v.x * d
        local y = v.y * d
        return { x = x + v1.x
               ; y = y + v1.y
               }
    end 
end

local function vec_3d_path(v1, v2)
    local v = { x = v2.x - v1.x
              ; y = v2.y - v1.y
              ; z = v2.z - v1.z
              }

    return function(d)
        local x = v.x * d
        local y = v.y * d
        local z = v.z * d
        return { x = x + v1.x
               ; y = y + v1.y
               ; z = z + v1.z
               }
    end 
end

return { distance_square = distance_square
       ; distance = distance
       ; vec_2d_path = vec_2d_path
       ; vec_3d_path = vec_3d_path
       }
