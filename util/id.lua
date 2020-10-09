

local base_id = 0
local function gen_id() 
    base_id = base_id + 1
    return base_id
end

return { gen_id = gen_id 
       }
