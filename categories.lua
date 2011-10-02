function initlibs()
    require "lfs"
    require "util.io"
    require "libsteam"
    
    -- like lfs.dir, but returns an iterator over all directory entries that
    -- don't start with .
    function lfs.dirdot(path)
        local iter = lfs.dir(path)
        return function()
            local path
            repeat
                path = iter()
            until not path or path:sub(1,1) ~= "."
            return path
        end
    end
    
    -- "sanitizes" a path by replacing characters windows doesn't understand
    -- with _
    function lfs.sanitize(path)
        return (path:gsub([=[[/\:*?"<>|]]=], "_"))
    end
end

local function addgame(game)
    local r,e
    local name = lfs.sanitize(game.name)
    local category = game.category and lfs.sanitize(game.category) or nil
    
    if category then
        if not lfs.attributes(category) then
            lfs.mkdir(category)
            io.writefile(category.."/category.txt", game.category)
        end
        
        r,e = io.writefile(category.."/"..name, tostring(game.appid))
    else
        r,e = io.writefile(name, tostring(game.appid))
    end
    
    if not r then
        io.eprintf("Error creating file for %s%s: %s\n", name, category and " in "..category, e) 
    end
end

local function apply_user_categories(steam)
    local function categorize(name, category)
        -- determine appID of game
        name = lfs.sanitize(name)
        local id = tonumber(io.readfile((category and category.."/" or "")..name))
        
        -- determine real name of category, if it got munged by the filesystem
        if category then
            category = (io.readfile(category.."/category.txt") or category):trim()
        end

        -- update game
        steam:games("appid")[id].category = category
    end

    for item in lfs.dirdot(".") do
        -- is this a category directory?
        if lfs.attributes(item).mode == "directory" then
            -- if so, process all the games in it
            for game in lfs.dirdot(item) do
                if game ~= "category.txt" then -- reserved to store unmunged category name
                    categorize(game, item)
                end
            end
        else
            -- otherwise, it's a game with no category
            categorize(item, nil)
        end
    end
end

local function add_new_games(steam)
    for _,game in ipairs(steam:games()) do
        addgame(game)
    end
end

function main(...)
    initlibs()
    
    -- initialize Steam
    local path = (...) or io.prompt("Steam location (drag-and drop steam.exe): ")
    
    local steam,err = steam.open(path:gsub('^"(.*)"$', '%1'))
    if not steam then
        io.eprintf("Couldn't read Steam directory: %s\n", err)
        return 1
    end
    
    io.printf("Found Steam account %s\n\n", tostring(steam))

    -- now the fun begins. We need to do the following:
    --  read the user's master game list
    --  read the sharedconfig.vdf
    --  read the contents of the category dir, if any
    --  foreach game in the category dir, update its category info in steam
    --  foreach game the user owns not in the category dir, create it in the category dir, categorized if necessary
    --  write out the updated VDF
    
    -- load master game list and steam category information
    io.printf("Loading Steam game list:"); io.flush()
    assert(steam:games())
    io.printf(" done\n")
    
    steam:load_categories()
    
    if not lfs.attributes(lfs.sanitize(steam.name)) then
        lfs.mkdir(lfs.sanitize(steam.name))
    end
    lfs.chdir(lfs.sanitize(steam.name))

    io.printf("Scanning categorization directory, and updating Steam as necessary...\n")
    apply_user_categories(steam)

    io.printf("Adding new games to categorization directory...\n")
    add_new_games(steam)

    io.printf("Writing new Steam category information...\n")
    steam:save_categories()
    
    io.printf("Done!\n")
    
    return 0
end

require "app"
return main(...)
