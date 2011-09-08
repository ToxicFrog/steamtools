package.cpath = package.cpath..";iup/lib?51.so"

require "iuplua"
local gui = require "bledit.gui"

local GAMES,COOKIE

bledit = {}

function bledit.games()
    return GAMES
end

function bledit.cookie()
    return COOKIE
end

function bledit.loadGames()
    COOKIE._games = nil -- delete cache to force a reload
    GAMES = COOKIE:games()
    gui.listGames(GAMES, "_console_str", "name")
end

function main(...)
    gui.init()
    
    -- load config file
    if loadfile("steam2backloggery.cfg") then
        local r,e = xpcall(loadfile("steam2backloggery.cfg"), debug.traceback)
        if not r then
            gui.warn("Warning", "Found config file steam2backloggery.cfg, but couldn't load it:\n"..e)
        end
    end
    
    -- log in to backloggery
    local bl = require "libbl"
    local cookie
    
    while not cookie do
        local status,user,pass = gui.getLogin(USER, PASS)
        if not status then os.exit(1) end
    
        cookie,status = bl.login(user,pass)
        if not cookie then
            gui.warn("Error", "Login failed: "..status)
        end
    end
    
    COOKIE = cookie
    gui.status("Logged in as "..cookie.user)
    bledit.loadGames()

    gui.main()
end

local r,e = xpcall(main, debug.traceback)
if not r then
    gui.warn("Error", tostring(e))
end

iup.Close()
os.exit(0)
