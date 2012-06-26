-- miscellaneous helper functions

-- an xpcall that permits varargs
function va_xpcall(f, e, ...)
    local argc = select('#', ...)
    local argv = {...}
    
    return xpcall(function() return f(unpack(argv,1,argc)) end, e)
end
        
-- fast lambda creation
function L(src)
    return assert(loadstring(src:gsub("%s+%-%>%s+", " = ...; return ")))
end

