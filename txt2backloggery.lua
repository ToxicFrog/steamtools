function main(source)
    require "libbl"
    require "util.io"
    
    local function loadconfig()
        -- default settings
        EDITOR = "notepad"
        IGNORE = ""
        
        if loadfile("steamtools.cfg") then
            loadfile("steamtools.cfg")()
        else
            io.eprintf("Warning: couldn't load steamtools.cfg\nError message was: %s\nUsing default settings\n\n"
                     , tostring(select(2, loadfile("steamtools.cfg"))))
        end
    end
    
    local function mkignored(ignore)
        local patterns = {}
        for pattern in IGNORE:gmatch("%s*([^\n]+)") do
            pattern = pattern:gsub("%W"
                      , function(c)
                          if c == "*" then
                              return ".*"
                          else
                              return "%"..c
                          end
                      end)
            patterns[#patterns+1] = pattern
        end
        return patterns
    end
    
    local function ignored(name)
        for _,pattern in ipairs(IGNORE) do
            if name:match(pattern) then
                return true
            end
        end
        return false
    end
    
    local function loadgames(file)
        local games = {}
        
        for line in io.lines(file) do
            local game = {}
            
            game.platform,game.status,game.name = line:match("^(%w+)%s+(%w+)%s+(.+)")
            if game.status == "wishlist" then
                game.status = "unfinished"
                game.wishlist = true
            end

            if game.platform and game.status and game.name then
                if not bl.completecode(game.status) then
                    io.eprintf("Warning: skipping game '%s': unknown status '%s'\n", game.name, game.status)
                elseif not bl.platforms[game.platform] then
                    io.eprintf("Warning: skipping game '%s': platform '%s' not recognized by backloggery\n", game.name, game.platform)
                else
                    games[#games+1] = game
                end
            end
        end
        
        return games
    end
    
    loadconfig()

    -- create ignore list
    IGNORE = mkignored(IGNORE)
    
    -- initialize Backloggery
    local user = USER or io.prompt("Backloggery username: ")
    local pass = PASS or io.prompt("Backloggery password: ")
    
    local cookie,err = bl.login(user,pass)
    
    if not cookie then
        io.eprintf("Couldn't log in: %s\n", err)
        return 1
    else
        io.printf("Logged in to Backloggery as %s.\n\n", user)
    end
    
    io.output("backloggery.txt")
    io.write [[
# This is a list of all of the games txt2backloggery is going to add to your
# backloggery account.
#
# Please edit this list as you see fit, then save and exit.
#
# Blank lines and lines starting with '#' will be ignored.
#
# If you decide that you've made a terrible mistake and don't want to upload
# *anything* to your backloggery account, just erase everything in this file
# and then save and exit.
#
# Examples:
# PC        complete        System Shock
# PC        beaten          System Shock 2
# PCDL      unfinished      The Witcher
# Steam     wishlist        The Witcher 2: Assassins of Kings
# Steam     null            Team Fortress 2


]]

    local buf = io.readfile(source or "")
    if buf then
        io.write(buf)
    end
    
    io.close()
    io.output(io.stdout)

    io.printf("Launching editor so you can can review the game list..."); io.flush()
    if os.execute("%s backloggery.txt" % EDITOR) > 0 then
        io.eprintf("\nError executing editor! Aborting.")
        return 1
    end
    io.printf("done.\n\n")
    
    -- now, we read the contents of the edited file so that we can upload the games
    -- to backloggery.
    io.printf("\nUpdating your Backloggery.\n")
    for _,game in ipairs(loadgames("backloggery.txt")) do
        local r,e = cookie:addgame {
            name = game.name:trim();
            console = game.platform;
            complete = game.status;
            wishlist = game.wishlist and 1 or nil;
        }
        if r then
            io.printf("Added %s game '%s'%s\n", game.status, game.name, game.wishlist and " to wishlist" or "")
        else
            io.printf("Couldn't add '%s': %s\n", game.name, e)
        end
    end
    
    io.printf("Backloggery updated. Have a nice day!\n")
    os.remove("backloggery.txt")
end

require "app"; main(...)
