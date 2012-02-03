require "util.io"
require "util.misc"

local _main = main
local _EXIT = {}
local os_exit = os.exit

function os.exit(code)
    _EXIT[1] = code
    error(_EXIT)
end

function main(...)
    local r,e = va_xpcall(_main, debug.traceback, ...)
    if not r and e ~= _EXIT then
        io.eprintf("\n\nAn error occurred! Please report this to the developer.\n%s\n", e)
    end
    
    io.printf("\nPress enter to quit...\n")
    io.read()
    os.exit(_EXIT[1] or (r and e) or -1)
end
