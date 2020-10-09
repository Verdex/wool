
local create_parser = function(input) 
    local o = {}
    o.input = input
    o.index = 1

    local is_end = function()
        return #o.input < o.index
    end

    local current = function()
        return string.sub(o.input, o.index, o.index)
    end

    function o:create_restore()
        return self.index
    end

    function o:restore(rp)
        self.index = rp
    end

    function o:clear()
        local i = string.match(self.input, "^%s*()", self.index)
        self.index = i
        return true
    end

    function o:expect_end()
        if is_end() then
            return true
        end
        return false
    end

    function o:expect( str )
        local s, e = self:clear()
        if not s then
            return false, e
        end

        local l = #str
        local i = 1
        local rp = self:create_restore()

        while i <= l do
            if is_end() then 
                self:restore(rp)
                return false, string.format("encountered end of file, but expected %s", str) 
            elseif current() ~= string.sub(str, i, i) then
                local err = string.format("encountered '%s' instead of '%s' when expecting '%s'"
                                         , current()  
                                         , string.sub(str, i, i)
                                         , str)

                self:restore(rp)
                return false, err
            else 
                self.index = self.index + 1 
                i = i + 1
            end
        end

        return true
    end

    function o:parse_symbol() 
        local s, e = self:clear()
        if not s then
            return false, e
        end

        local symbol, new_index = string.match(self.input, "^([_%a][_%w]*)()", self.index) 
        if not symbol then
            return false, string.format("encountered '%s' but expected symbol", current())
        end
        self.index = new_index
        return true, symbol
    end

    function o:parse_number()
        local s, e = self:clear()
        if not s then
            return false, e
        end
        
        local number, new_index = string.match(self.input, "^(%d+%.?%d*)()", self.index) 
        if not number then
            return false, string.format("encountered '%s' but expected number", current())
        end
        self.index = new_index
        return true, number 
    end

    function o:parse_string()
        local s, e = self:clear()
        if not s then
            return false, e
        end

        local rp = self:create_restore()

        s, e = self:expect('"')
        if not s then
            return false, e
        end

        local buffer = {}
        local escape = false

        while not is_end() do

            if escape and current() == '\\' then
                escape = false 
                self.index = self.index + 1
                buffer[#buffer+1] = '\\' 
            elseif escape and current() == 'n' then
                escape = false 
                self.index = self.index + 1
                buffer[#buffer+1] = '\n' 
            elseif escape and current() == 'r' then
                escape = false 
                self.index = self.index + 1
                buffer[#buffer+1] = '\r' 
            elseif escape and current() == 't' then
                escape = false 
                self.index = self.index + 1
                buffer[#buffer+1] = '\t' 
            elseif escape and current() == '0' then
                escape = false 
                self.index = self.index + 1
                buffer[#buffer+1] = '\0' 
            elseif escape and current() == '"' then
                escape = false 
                self.index = self.index + 1
                buffer[#buffer+1] = '\"' 
            elseif current() == '\\' then
                escape = true
                self.index = self.index + 1
            elseif current() == '"' then
                break
            elseif not escape then 
                buffer[#buffer+1] = current()
                self.index = self.index + 1
            else 
                return false, string.format("encountered unknown escape '%s'", current())
            end
        end
        
        if is_end() then
            return false, "encountered end of file inside of string"
        end

        s, e = self:expect('"')
        if not s then
            return false, e
        end
            
        return true, table.concat(buffer)
    end

    function o:maybe( parser )
        local rp = self:create_restore()

        local s, e = parser(self)
        if not s then 
            self:restore(rp)
            return true, nil
        end
        return true, e
    end

    function o:seq( parsers )
        local rp = self:create_restore()

        local res = {}
        for _, parser in ipairs(parsers) do
            local s, e = parser(self)
            if not s then
                self:restore(rp)
                return false, e
            end
            res[#res+1] = e
        end
        return true, res
    end

    function o:zero_or_more( parser )
        local res = {}
        while not is_end() do
            local rp = self:create_restore()

            local s, e = parser(self) 
            if not s then
                self:restore(rp)
                return true, res
            end
            res[#res+1] = e
        end
        return true, res
    end
   
    function o:one_or_more( parser )
        local rp = self:create_restore()

        local res = {}
        local s, e = parser(self) 
        if not s then
            self:restore(rp)
            return false, e
        end
        res[#res+1] = e
        while not is_end() do
            rp = self:create_restore()
            
            s, e = parser(self) 
            if not s then
                self:restore(rp)
                return true, res
            end
            res[#res+1] = e
        end
        return true, res
    end

    function o:list( parser )
        local rp = self:create_restore()

        local res = {}
        local s, e = parser(self) 
        if not s then
            self:restore(rp)
            return true, res
        end
        res[#res+1] = e
        while not is_end() do
            rp = self:create_restore()
            s, e = self:expect(",")
            if not s then
                return true, res 
            end
            s, e = parser(self) 
            if not s then
                self:restore(rp)
                return true, res
            end
            res[#res+1] = e
        end
        return true, res
    end

    function o:choice( parsers )
        local errors = {}
        for _, parser in ipairs(parsers) do
            local rp = self:create_restore()

            local s, e = parser(self)
            if s then
                return true, e
            end
            self:restore(rp)
            errors[#errors+1] = e
        end
        return false, "choices failed to find parser: " .. table.concat(errors, "\n")
    end

    return o
end


return { create_parser = create_parser }
