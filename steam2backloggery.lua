function main(...)
    require "libbl"
    require "libsteam"
    require "util.io"
    
    local function loadconfig()
        if loadfile("steam2backloggery.cfg") then
            loadfile("steam2backloggery.cfg")()
        else
            io.eprintf("Warning: couldn't load steam2backloggery.cfg\nError message was: %s\nUsing default settings\n\n"
                     , tostring(select(2, loadfile("steam2backloggery.cfg"))))
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
    
    loadconfig()

    -- create ignore list
    IGNORE = mkignored(IGNORE or "")
    
    -- initialize Steam
    local path = STEAM or io.prompt("Steam location (drag-and drop steam.exe): ")
    
    local steam,err = steam.open(path:gsub('^"(.*)"$', '%1'))
    if not steam then
        io.eprintf("Couldn't read Steam directory: %s\n", err)
        return 1
    end
    
    io.printf("Found Steam account %s\n\n", tostring(steam))
    
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
    
    io.printf("Loading Steam game lists:"); io.flush()
    io.printf(" games"); io.flush(); steam:games()
    io.printf(" wishlist"); io.flush(); steam:wishlist()
    
    if #steam:games() == 0 and #steam:wishlist() == 0 then
        io.eprintf("\n\nCouldn't find any Steam games in Games or Wishlist!\n"
                   .."Please double-check that your Steam profile is set to 'public'\n"
                   .."(And if it is, report this as a bug, along with your Steam ID\n")
        return 1
    end
    
    io.printf(" done.\nLoading Backloggery game lists:"); io.flush()
    io.printf(" games"); io.flush(); cookie:games()
    io.printf(" wishlist"); io.flush(); cookie:wishlist()
    io.printf(" done.\n\n")
    
    io.printf("Filtering games:"); io.flush()
    local games = {}
    local count = 0
    for _,game in pairs(steam:games()) do
        count = count+1
        if not cookie:hasgame(game.name) and not ignored(game.name) then
            games[#games+1] = {
                name = game.name;
                status = "unfinished";
            }
        end
    end
    io.printf(" %d owned games,", count); io.flush(); count = 0
    for _,game in pairs(steam:wishlist()) do
        count = count+1
        if not cookie:hasgame(game.name) and not ignored(game.name) then
            games[#games+1] = {
                name = game.name;
                status = "wishlist";
            }
        end
    end
    io.printf(" %d wishlisted games, %d games to add.\n\n", count, #games)
    
    if #games == 0 then
        io.printf("No games to add - all of your Steam games are either already\n"
                .."on Backloggery, or in your steam2backloggery.cfg ignore list.\n")
        return 0
    end
    
    io.output("backloggery.txt")
    io.write [[
# This is a list of all of the games steam2backloggery is going to add to your
# backloggery account.
#
# Please edit this list as you see fit, then save and exit. In particular, you
# probably want to check the following:
#
# * change "unfinished" to "beaten", "completed", "mastered", or "null" as needed
# * delete DLC from the list
#
# Lines starting with '#' will be ignored.
#
# If you decide that you've made a terrible mistake and don't want to upload
# *anything* to your backloggery account, just erase everything in this file
# and then save and exit.
#
]]
    for _,game in ipairs(games) do
        io.printf("%-16s%s\n", game.status, game.name)
    end
    io.close()
    
    io.output(io.stdout)
    io.printf("Launching editor so you can can review the game list..."); io.flush()
    if os.execute("notepad backloggery.txt") > 0 then
        io.eprintf("\nError executing editor! Aborting.")
        return 1
    end
    io.printf("done.\n\n")
    
    local platform = CONSOLE
    while not bl.platforms[platform] do
        platform = io.prompt("Enter a Backloggery category (recommended: PC, PCDL, or Steam): ")
    end
    
    -- now, we read the contents of the edited file so that we can upload the games
    -- to backloggery.
    io.printf("\nUpdating your Backloggery.\n")
    for line in io.lines("backloggery.txt") do
        local status,name = line:match("^(%w+)%s+(.*)")
        if status and name then
            local wishlist
            if status == "wishlist" then
                status = "unfinished"
                wishlist = 1
            end
            
            if not bl.completecode(status) then
                io.eprintf("Warning: skipping game '%s': unknown status '%s'\n", name, status)
            else
                local r,e = cookie:addgame {
                    name = name:trim();
                    console = platform;
                    complete = status;
                    wishlist = wishlist;
                }
                if r then
                    io.printf("Added %s game '%s'%s\n", status, name, wishlist and " to wishlist" or "")
                else
                    io.printf("Couldn't add '%s': %s\n", name, e)
                end
            end
        end
    end
    
    io.printf("Backloggery updated. Have a nice day!\n")
    os.remove("backloggery.txt")
end

require "app"
