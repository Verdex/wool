
parse = require 'parse'

--[[
    { a = "blah"
    , b = 1234.1234
    , c = true
    , d = false
    , e = { a = b }
    , f = [ 1, 2, 3, 4 }
--]]

local parse_bool = function(p)
    local s, e = p:expect("true")
    if s then
        return true, true 
    end
    s, e = p:expect("false")
    if s then
        return true, false
    end
    return false, "expected boolean"
end

local parse_number = function(p)
    local s, e = p:parse_number()
    if not s then
        return false, e
    end
    return true, tonumber(e)
end

local parse_array = function(parse_expr)
    return function(p)
        local s, e = p:expect("[")
        if not s then
            return false, e
        end
        s, e = p:list(parse_expr)
        local array = e
        if not s then
            return false, e
        end
        s, e = p:expect("]")
        if not s then
            return false, e
        end
        return true, array 
    end
end

local parse_object = function(parse_expr)
    local parse_slot = function(p)
        return p:seq { function(p) return p:parse_symbol() end
                     ; function(p) return p:expect("=") end
                     ; parse_expr
                     }
    end

    return function(p)

        local s, e = p:expect("{")
        if not s then 
            return false, e
        end

        s, e = p:list(parse_slot)
        local slots = e

        if not s then 
            return false, e
        end

        s, e = p:expect("}")
        if not s then
            return false, e
        end

        local obj = {}
        for _, v in ipairs(slots) do
            obj[v[1]] = v[2]
        end

        return true, obj
    end
end

local function parse_expr(p)
    return p:choice{ parse_number 
                   ; function(p) return p:parse_string() end
                   ; parse_bool
                   ; parse_array(parse_expr)
                   ; parse_object(parse_expr)
                   }
end

local function serialize( obj ) 
    if type(obj) == 'boolean' then
        return tostring(obj)
    elseif type(obj) == 'number' then
        return tostring(obj)
    elseif type(obj) == 'string' then
        return '"' .. obj .. '"'
    elseif type(obj) == 'table' then
        local array_items = {}
        for k, v in ipairs(obj) do
            array_items[#array_items + 1] = serialize( v )
        end
        if #array_items > 0 then
            return "[ " .. table.concat( array_items, ", " ) .. " ]"
        end
        local items = {}
        for k, v in pairs(obj) do
            items[#items + 1] = string.format( "%s = %s", k, serialize( v ) )
        end
        return "{ " .. table.concat( items, ", " ) .. " }"
    else
        error( "encountered unsupported type in serialize: " .. type(obj) )
    end
end

local deserialize = function( str )
    local p = parse.create_parser(str)
    local s, e = parse_expr(p)
    if not s then
        error( string.format( "deserialize encountered parse error: %s", e ) )
    end
    local expr = e
    s, e = p:clear()
    if not s then
        error( string.format( "deserialize encountered clear error: %s", e ) )
    end
    s, e = p:expect_end()
    if not s then
        error( string.format( "deserialize encountered additional text: %s", e ) )
    end
    return expr
end

local base_id = 0
local function gen_id() 
    base_id = base_id + 1
    return base_id
end

return { serialize = serialize
       ; deserialize = deserialize
       ; gen_id = gen_id
       }

