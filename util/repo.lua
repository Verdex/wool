
local id = require 'util/id'

--[[
    repo {
        iter : self<a> -> iter<a>
        get_by_id : self<a> -> id -> bool, a
        add : self<a> -> a -> id
        remove_by_id : self<a> -> id -> ()
    }
--]]

local function create_standard() 
    local obj = {}

    obj.interface = 'standard_repo'
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
        item.id = id.gen()
        self.items[#self.items+1] = item
        return item.id
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

local function create_dict() 
    local obj = {}

    obj.interface = 'dictionary_repo'
    obj.items = {}

    function obj:iter()
        return pairs(self.items)
    end

    function obj:get_by_id(id)
        local t = self.items[id]
        if t then
            return true, t
        else
            return false
        end
    end

    function obj:add(item)
        item.id = id.gen()
        self.items[item.id] = item
        return item.id
    end

    function obj:remove_by_id(id)
        self.items[id] = nil
    end

    return obj
end


return { create_standard = create_standard
       ; create_dict = create_dict
       }
