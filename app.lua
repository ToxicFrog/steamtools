local r,e = xpcall(main, debug.traceback)
if not r then
    io.eprintf("An error occurred! Please report this to the developer.\n%s\n", e)
end

io.printf("\nPress enter to quit...\n")
io.read()
