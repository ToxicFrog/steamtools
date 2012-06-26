function io.writefile(name, data)
    local fd,e = io.open(name, "wb")
    if not fd then return fd,e end
    
    local r,e = fd:write(data)
    fd:close()
    return r,e
end

function io.readfile(name)
    local fd,e = io.open(name, "rb")
    if not fd then return fd,e end
    
    local r,e = fd:read('*a')
    fd:close()
    return r,e
end

function io.printf(...)
    return io.write(string.format(...))
end

function io.eprintf(...)
    return io.stderr:write(string.format(...))
end

function io.prompt(...)
    io.printf(...)
    return io.read()
end

function io.safe_lines(path)
    local result,iter = pcall(io.lines, path)
    if not result then
        return function() end
    else
        return iter
    end
end
