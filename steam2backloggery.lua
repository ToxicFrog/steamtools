require "libbl"
require "libsteam"
require "util.io"

-- get game list from Steam
if not ... then
    io.eprintf("Please run this program by drag-and-dropping your Steam directory onto it.\n")
    return 1
end

local steam,err = steam.init((...))
if not steam then
    io.eprintf("Couldn't read Steam directory: %s\n", err)
    return 1
end

-- upload game list to Backloggery
local user = io.prompt("Backloggery username: ")
local pass = io.prompt("Backloggery password: ")

local cookie,err = bl.login(user,pass)

if not cookie then
    io.eprintf("Couldn't log in: %s\n", err)
    return 1
end

for id,name in pairs(steam:games()) do
    if cookie:hasgame(name) then
        print("SKIP", name)
    else
        cookie:addgame {
            name = name;
            console = "PC";
            complete = "unfinished";
        }
        print("ADD", name)
    end
end

for id,name in pairs(steam:wishlist())
    if cookie:hasgame(name) then
        print("SKIP", name)
    else
        cookie:addgame {
            name = name;
            console = "PC";
            complete = "unfinished";
            wishlist = 1;
        }
        print("ADD", name)
    end
end

print("\nDone.")
