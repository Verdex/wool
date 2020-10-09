
--[[
    seq {

        iter : self -> something that can go into a for loop
        map : self<a> -> (a -> b) -> self<b>
        filter : self<a> -> (a -> bool) -> self<a>
        fold : self<a> -> (a -> b -> c) -> b -> c
        append : self<a> -> self<a> -> self<a>

    }
--]]

local function create_standard(items)
    local items = items or {}

    assert( type(items) == 'table', "seq::create_standard got passed non-table items" )

    local obj = {}
    obj.interface = 'seq'
    obj.items = items

    function obj:iter() 
        return ipairs(self.items)
    end

    function obj:map(f)
        local xs = {}
        for _, v in self:iter() do
            xs[#xs+1] = f(v)
        end
        return create_standard(xs)
    end

    function obj:filter(p)
        local xs = {}
        for _, v in self:iter() do
            if p(v) then
                xs[#xs+1] = v
            end
        end
        return create_standard(xs)
    end

    function obj:fold(c, i)
        local s = i
        for _, v in self:iter() do
            s = c(v, s) 
        end
        return s
    end

    function obj:append(o)
        local xs = {}
        for _, v in self:iter() do
            xs[#xs+1] = v
        end
        for _, v in o:iter() do
            xs[#xs+1] = v
        end
        return create_standard(xs)
    end

    return obj
end


return { create_standard = create_standard
       }
