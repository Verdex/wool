

local base_id = 0
local function gen() 
    base_id = base_id + 1
    return base_id
end

return { gen = gen
       }
