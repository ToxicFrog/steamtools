require "util.misc"

local _main = main

function main(...)
    local r,e = va_xpcall(_main, debug.traceback, ...)
    if not r then
        io.eprintf("\n\nAn error occurred! Please report this to the developer.\n%s\n", e)
    end
    
    io.printf("\nPress enter to quit...\n")
    io.read()
    os.exit(r and e or -1)
end

