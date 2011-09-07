-- a simple HTML parser

html = {}

local Tag = {}

Tag.__index = Tag

function Tag:__tostring()
    return "html <"..self.TAG..">"
end

function Tag:Show()
    if #self == 0 then
        return "<"..self.TAG..">"
    end
    
    local buf = {}
    table.insert(buf, "<"..self.TAG..">")
    table.insert(buf, self:Content())
    table.insert(buf, "</"..self.TAG..">")
    
    return table.concat(buf)
end

function Tag:Content()
    local buf = {}
    
    for _,child in ipairs(self) do
        if type(child) == "string" then
            table.insert(buf, child)
        else
            table.insert(buf, child:Show())
        end
    end
    
    return table.concat(buf)
end

function Tag:Find(tag, key, value)
    if tag and key and not value then return self:Find(false, tag, key) end
    
    local function matches(x, y)
        if type(x) == "string" and type(y) == "string" then return x:match(y)
        else return x == y
        end
    end
            
    if (not key or self[key] and matches(self[key], value))
        and (not tag or matches(self.TAG, tag))
    then
        return self
    end
    
    for i,child in ipairs(self) do
        if type(child) ~= "string" then
            local found = child:Find(tag, key, value)
            if found then return found end
        end
    end
    return nil
end

function Tag:GFind(tag, key, value)
    if not value then return self:GFind(false, tag, key) end
    
    local function iter(self)
        if (not key or self[key] and self[key]:match(value))
            and (not tag or self.TAG:match(tag))
        then
            coroutine.yield(self)
        end
    
        for i,child in ipairs(self) do
            if type(child) ~= "string" then
                iter(child)
            end
        end
    end
    
    return coroutine.wrap(iter), self
end

function Tag:FindAll(...)
    local results = {}
    
    for tag in self:GFind(...) do
        table.insert(results, tag)
    end
    return results
end

function html.parse(buf, stack)
    assert(type(buf) == "string", tostring(buf))
    stack = stack or {}
    
    local function lex_tag(tag, buf)
        local close,name,attrs,end_close = tag:match("<(/?)(%S+)(.-)(/?)>")
        assert(name and attrs, "couldn't parse tag "..tag)
        
        local type = (close == "/" and "close")
                    or (end_close == "/" and "openclose")
                    or "open"
        local tag = setmetatable({}, Tag)
        
        tag.TAG = name
        attrs:gsub('(%S+)=(%b"")', function(k,v)
            tag[k:lower()] = v:sub(2,-2)
            return ""
        end):gsub('(%S+)=(%S+)', function(k,v)
            tag[k:lower()] = v
            return ""
        end):gsub('%S+', function(k)
            tag[k:lower()] = true
            return ""
        end)

        return type,tag,buf
    end
    
    local function lex(buf)
        if buf:match("^%s+") then
            return "whitespace",buf:match("^(%s+)(.*)")
            
        elseif buf:match("^%b<>") then
            return lex_tag(buf:match("^(%b<>)(.*)"))
            
        else
            return "text",buf:match("^([^<]+)(.*)")
        end
    end
    
    local function pop()
        return table.remove(stack)
    end
    
    local function push(elem)
        return table.insert(stack, elem)
    end
    
    local function append(elem)
        return table.insert(stack[#stack], elem)
    end
    
    local function flatten(tag)
        for i=#stack,1,-1 do
            if stack[i].TAG == tag then
                while stack[i+1] do
                    table.insert(stack[i], table.remove(stack, i+1))
                end
                return true
            end
        end
        return false
    end
    
    if #buf == 0 then
        if flatten("html") then
            for i,v in ipairs(stack) do
                if v.TAG == "html" then return v end
            end
        else
            stack.TAG = "html"
            setmetatable(stack, Tag)
            return stack
        end
    end
    
    local type,next,buf = lex(buf)
    
    if type == "whitespace" then
        -- discard
    
    elseif type == "text" then
        push(next)
        
    elseif type == "open" then
        push(next)
        
    elseif type == "close" then
        flatten(next.TAG)
        
    elseif type == "openclose" then
        push(next)
    end

    return html.parse(buf, stack)
end

return html
