-- sometimes, VDFs are case insensitive and use all lowercase for field names!
-- what the hell, Valve
local vdf_mt = {}

function vdf_mt:__index(key)
    return rawget(self, key:lower())
end

function vdf_mt:__newindex(key, value)
    if rawget(self, key:lower()) then
        return rawset(self, key:lower(), value)
    else
        return rawset(self, key, value)
    end
end

-- parse a string containing VDF data
function steam.parseVDF(buf)
    assert(type(buf) == "string", "invalid argument to steam.parseVDF")
    
    local function tokens()
        buf = buf:gsub("^%s+", "") -- strip leading whitespace
        if #buf == 0 then return nil end
        
        local token = buf:match('^%b""') or buf:match('^%b{}')
        if not token then
            error("Invalid VDF data:\n"..buf)
        end
        
        buf = buf:sub(#token+1) -- consume token from input
        
        if token:sub(1,1) == '"' then
            token = token:sub(2,-2)
            if #token == 0 then token = false end
        else
            token = steam.parseVDF(token:sub(2,-2))
        end
        
        return token
    end
    
    local vdf = setmetatable({}, vdf_mt)
    
    for key in tokens do
        local value = tokens()
        if value then
            vdf[key] = value
        end
    end
    
    return vdf
end

function steam.writeVDF(vdf, indent)
    indent = indent or 0
    local buf = {}
    local function append(str) buf[#buf+1] = ("\t"):rep(indent)..str end
    
    local function write(key, value)
        assert(type(key) == "string" and (type(value) == "string" or type(value) == "table"),
               "invalid table passed to writeVDF")
        if type(value) == "string" then
            append('"'..key..'"\t\t"'..value..'"')
        else
            append('"'..key..'"')
            append('{\n'..steam.writeVDF(value, indent+1))
            append('}')
        end
    end
    
    for k,v in pairs(vdf) do
        write(k,v)
    end
    
    return table.concat(buf, "\n")
end

-- load a VDF data store from path
function steam.loadVDF(path)
    local fin,err = io.open(path, "rb")
    if not fin then return fin,err end
    
    local data = fin:read('*a')
    fin:close()
    
    return steam.parseVDF(data)
end

function steam.saveVDF(path, vdf)
    local fin,ferr = io.open(path, "wb")
    if not fin then return fin,err end
    
    fin:write(steam.writeVDF(vdf))
    fin:close()
end
