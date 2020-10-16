
--[[

    vec

    add : vec -> vec -> vec
    scale : vec -> number -> vec
    path : vec -> vec -> fun(number) -> vec

    add_mut
    scale_mut 

    distance : vec -> vec -> number
    distance_squared : vec -> vec -> number

    unit : vec -> vec
    unit_mut : vec -> vec

    magnitude : vec -> number

--]]

local function create_2d(x, y)
    local obj = { x = x
                ; y = y 
                ; interface = "2d_vec"
                }

    function obj:add(v)
        assert(v.interface == "2d_vec")
        return create_2d(self.x + v.x, self.y + v.y)
    end

    function obj:scale(s)
        return create_2d(self.x * s, self.y * s)
    end

    function obj:path(v)
        assert(v.interface == "2d_vec")

        local x = v.x - self.x
        local y = v.y - self.y

        return function(d)
            local dx = x * d
            local dy = y * d
            return create_2d(self.x + dx, self.y + dy)
        end 
    end

    function obj:add_mut(v)
        assert(v.interface == "2d_vec")
        self.x = self.x + v.x
        self.y = self.y + v.y
        return self
    end

    function obj:scale_mut(s)
        self.x = self.x * s
        self.y = self.y * s
        return self
    end

    function obj:distance_squared(v)
        assert(v.interface == "2d_vec")
        return math.pow(v.x - self.x, 2) + math.pow(v.y - self.y, 2)
    end

    function obj:distance(v)
        return math.pow(self:distance_squared(v), 0.5)
    end

    function obj:unit()
        local m = self:magnitude()
        return self:scale(1/m)
    end

    function obj:unit_mut()
        local m = self:magnitude()
        return self:scale_mut(1/m)
    end

    function obj:magnitude()
        self:distance(create_2d(0, 0))
    end

    return obj
end

local function create_color(r, g, b, a)
    local obj = { r = r
                ; g = g 
                ; b = b
                ; a = a
                ; interface = "color"
                }

    function obj:add(c)
        assert(c.interface == "color")
        return create_color(self.r + c.r, self.g + c.g, self.b + c.b, self.a + c.a)
    end

    function obj:scale(s)
        return create_color(self.r * s, self.g * s, self.b * s, self.a * s)
    end

    function obj:path(c)
        assert(c.interface == "color")

        local r = c.r - self.r
        local g = c.g - self.g
        local b = c.b - self.b
        local a = c.a - self.a

        return function(d)
            local dr = r * d
            local dg = g * d
            local db = b * d
            local da = a * d
            return create_color(self.r + dr, self.g + dg, self.b + db, self.a + da)
        end 
    end

    function obj:add_mut(c)
        assert(c.interface == "color")
        self.r = self.r + c.r
        self.g = self.g + c.g
        self.b = self.b + c.b
        self.a = self.a + c.a
        return self
    end

    function obj:scale_mut(s)
        self.r = self.r * s
        self.g = self.g * s 
        self.b = self.b * s 
        self.a = self.a * s 
        return self
    end

    function obj:distance_squared(c)
        assert(c.interface == "color")
        return math.pow(c.r - self.r, 2) 
             + math.pow(c.g - self.g, 2) 
             + math.pow(c.b - self.b, 2)
             + math.pow(c.a - self.a, 2)
    end

    function obj:distance(c)
        return math.pow(self:distance_squared(c), 0.5)
    end
    
    function obj:unit()
        local m = self:magnitude()
        return self:scale(1/m)
    end

    function obj:unit_mut()
        local m = self:magnitude()
        return self:scale_mut(1/m)
    end

    function obj:magnitude()
        self:distance(create_color(0, 0, 0, 0))
    end

    return obj
end

return { create_2d = create_2d
       ; create_color = create_color
       }
