function initsteam()
    local path = CONFIG.STEAM or io.prompt("Steam location (drag-and drop steam.exe): ")

    local steam,err = steam.open(path:gsub('^"(.*)"$', '%1'))
    if not steam then
        io.eprintf("Couldn't read Steam directory: %s\n", err)
        os.exit(1)
    end

    io.printf("Found Steam account %s\n\n", tostring(steam))
    return steam
end

function initbl()
    local user = CONFIG.USER or io.prompt("Backloggery username: ")
    local pass = CONFIG.PASS or io.prompt("Backloggery password: ")

    local cookie,err = bl.login(user,pass)

    if not cookie then
        io.eprintf("Couldn't log in: %s\n", err)
        os.exit(1)
    else
        io.printf("Logged in to Backloggery as %s.\n\n", user)
    end

    return cookie
end

function steamgames(steam)
    io.printf("Loading Steam game lists:"); io.flush()
    io.printf(" games"); io.flush(); assert(steam:games())
    io.printf(" wishlist"); io.flush(); assert(steam:wishlist())

    if #steam:games() == 0 and #steam:wishlist() == 0 then
        io.eprintf("\n\nCouldn't find any Steam games in Games or Wishlist!\n"
                .."Please double-check that your Steam profile is set to 'public'\n"
                .."(And if it is, report this as a bug, along with your Steam ID\n")
        os.exit(1)
    end

    io.printf(" done.\n"); io.flush()
end

function blgames(cookie)
    io.printf(" done.\nLoading Backloggery game lists:"); io.flush()
    io.printf(" games+wishlist"); io.flush(); cookie:games()
    io.printf(" done.\n\n")
end

function filtergames(steam, cookie)
    io.printf("Filtering games:"); io.flush()
    local games = {}
    local count = 0
    for _,game in pairs(steam:games()) do
        count = count+1
        if not cookie:games("name")[game.name] and not CONFIG:ignored(game.name) then
            games[#games+1] = {
                name = game.name;
                status = "unplayed";
            }
        end
    end
    io.printf(" %d owned games,", count); io.flush(); count = 0
    for _,game in pairs(steam:wishlist()) do
        count = count+1
        if not cookie:hasgame(game.name) and not CONFIG:ignored(game.name) and not CONFIG:ignored("WISHLIST") then
            games[#games+1] = {
                name = game.name;
                status = "wishlist";
            }
        end
    end
    io.printf(" %d wishlisted games, %d games to add.\n\n", count, #games)

    return games
end

function writelist(games, platform)
    io.output("backloggery.txt")
    io.write [[
# This is a list of all of the games steam2backloggery is going to add to your
# backloggery account.
#
# Please edit this list as you see fit, then save and exit. In particular, you
# probably want to check the following:
#
# * change "unplayed" to "unfinished", "beaten", "completed", "mastered", or "null" as needed
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
        io.printf("%-8s%-16s%s\n", platform, game.status, game.name)
    end
    io.close()

    io.output(io.stdout)
end

function editlist()
    io.printf("Launching editor so you can can review the game list..."); io.flush()
    if os.execute("%s backloggery.txt" % CONFIG.EDITOR) > 0 then
        io.eprintf("\nError executing editor! Aborting.")
        os.exit(1)
    end
    io.printf("done.\n\n")
end

function readlist(cookie)
    -- now, we read the contents of the edited file so that we can upload the games
    -- to backloggery.
    io.printf("\nUpdating your Backloggery.\n")
    for line in io.lines("backloggery.txt") do
        local platform,status,name = line:match("^(%w+)%s+(%w+)%s+(.+)")
        if platform and status and name then
            local wishlist,unplayed
            if status == "wishlist" then
                status = "unplayed"
                wishlist = 1
            end

            if status == "unplayed" then
                status = "unfinished"
                unplayed = 1
            end

            if not bl.completecode(status) then
                io.eprintf("Warning: skipping game '%s': unknown status '%s'\n", name, status)
            elseif not bl.platforms[platform] then
                io.eprintf("Warning: skipping game '%s': platform '%s' not recognized by backloggery\n", name, platform)
            else
                local r,e = cookie:addgame {
                    name = name:trim();
                    console = platform;
                    complete = status;
                    wishlist = wishlist;
                    unplayed = unplayed;
                }
                if r then
                    io.printf("Added %s game '%s'%s\n", status, name, wishlist and " to wishlist" or "")
                else
                    io.printf("Couldn't add '%s': %s\n", name, e)
                end
            end
        end
    end
end

function main(source)
    require "libbl"
    require "libsteam"
    require "util.io"
    require "config"

    CONFIG = config.load("steamtools.cfg")

    -- initialize Steam
    local steam = initsteam()

    -- initialize Backloggery
    local backloggery = initbl()

    -- load game list
    steamgames(steam)
    blgames(backloggery)

    -- filter game list - exclude games ignored, or already in backloggery
    local games = filtergames(steam, backloggery)

    if #games == 0 then
        io.printf("No games to add - all of your Steam games are either already\n"
                .."on Backloggery, or in your steamtools.cfg ignore list.\n")
        os.exit(0)
    end
    
    local platform = CONFIG.CONSOLE
    while not bl.platforms[platform] do
        platform = io.prompt("Enter a Backloggery category (recommended: PC, PCDL, or Steam): ")
    end

    -- create the file listing all of the games to add
    writelist(games, platform)
    editlist()
    readlist(backloggery)

    io.printf("Backloggery updated. Have a nice day!\n")
    os.remove("backloggery.txt")
end

require "app"; main(...)
