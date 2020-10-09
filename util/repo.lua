
local seq = require 'seq'

--[[
    repo {
        iter : self<a> -> iter<a>
        get_by_id : self<a> -> id -> bool, a
        add : self<a> -> a -> ()
        remove_by_id : self<a> -> id -> ()
    }
--]]

local function create_standard() 
    local obj = {}

    obj.interface = 'container'
    obj.items = {}

    function obj:iter()
        return ipairs(self.items)    
    end

    function obj:get_by_id(id)
        for _, v in self:iter() do
            if v.id == id then
                return true, v
            end
        end
        return false
    end

    function obj:add(item)
        self.items[#self.items+1] = item
    end

    function obj:remove_by_id(id)
        local index = 0
        for k, v in self:iter() do
            if v.id == id then
                index = k
                break
            end
        end
        if index ~= 0 then
            table.remove(self.items, index)
        end
    end

    return obj
end



return { create_standard = create_standard
       }
