function initlibs()
    require "lfs"
    require "util.io"
    require "steamlib"
    
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
    
    function lfs.sanitize(path)
        return (path:gsub([=[[/\:*?"<>|]]=], "_"))
    end
end

function find_user()
    if not lfs.attributes("../userdata") then
        io.eprintf("Couldn't stat ../userdata - make sure organizer is installed properly\n")
        io.eprintf("(i.e in its own directory inside your Steam install directory\n")
        return nil
    end
    
    -- examine Steam log file to figure out who we should be reading the game
    -- list for
    io.printf("Reading log to find last logged in user...\n")
    
    local user = {}
    for line in io.lines("../steam.log") do
        user.name = line:match("CreateSession%(([^,]+)") or user.name
        user.id = line:match("for ([0-9:]+)%s*$") or user.id
    end
    
    if not (user.name and user.id) then
        return nil
    end

    user.X,user.Y,user.Z = user.id:match("(%d+):(%d+):(%d+)")
    user.dir = lfs.sanitize(user.name)
    
    return user
end

local function addgame(id, name, category)
    local r,e
    name = lfs.sanitize(name)
    
    if category then
        if not lfs.attributes(lfs.sanitize(category)) then
            lfs.mkdir(lfs.sanitize(category))
            io.writefile(lfs.sanitize(category).."/category.txt", category)
        end
        category = lfs.sanitize(category)
        
        r,e = io.writefile(category.."/"..name, id)
    else
        r,e = io.writefile(name, id)
    end
    if not r then
        io.eprintf("Error creating file for %s%s: %s\n", name, category and " in "..category, e) 
    end
end

local function apply_user_categories(games, categories)
    local function categorize(game, category)
        -- determine appID of game
        game = lfs.sanitize(game)
        local id = io.readfile((category and category.."/" or "")..game)

        -- update game tags
        if not categories[id] then
            categories[id] = {}
        end
        
        if (categories[id].tags or {})["0"] == "favorite" then
            categories[id].tags = {
                ["0"] = "favorite";
                ["1"] = category;
            }
        else
            categories[id].tags = {
                ["0"] = category;
            }
        end
        
        games[id] = nil
    end

    for category in lfs.dirdot(".") do
        -- is this actually a category?
        if lfs.attributes(category).mode == "directory" then
            -- if so, process all the games in it
            for game in lfs.dirdot(category) do
                if game ~= "category.txt" then -- reserved to store unmunged category name
                    categorize(game, category)
                end
            end
        else
            -- otherwise, it's a game with no category
            categorize(category, nil)
        end
    end
end

local function add_new_games(games, categories)
    for id,name in pairs(games) do
        local category
        if categories[id] and categories[id].tags then
            local i = 0
            while categories[id].tags[tostring(i)] do
                category = categories[id].tags[tostring(i)]
                i = i+1
            end
            if category == "favorite" then category = nil end
        end

        addgame(id, name, category)
    end
end

function main(...)
    initlibs()
    
    local user = find_user()
    if not user then
        io.eprintf("Couldn't determine name and ID of last logged in user.\n")
        io.eprintf("Please log in to Steam at least once before using this program.\n")
        return 1
    end
    
    io.printf("Selected user %s with id STEAM_%s\n", user.name, user.id)

    -- now the fun begins. We need to do the following:
    --  read the user's master game list
    --  read the sharedconfig.vdf
    --  read the contents of the category dir, if any
    --  foreach game in the category dir, categorize it appropriately
    --  foreach game the user owns not in the category dir, create it in the category dir, categorized if necessary
    --  write out the updated VDF
    
    io.printf("Reading Steam's category information...\n")
    local sharedconfig = assert(steam.loadVDF("../userdata/"..(user.Z*2 + user.Y).."/7/remote/sharedconfig.vdf"))
    local categories = sharedconfig.UserRoamingConfigStore.Software.Valve.Steam.apps
    
    io.printf("Loading %s's game list...\n", user.name)
    local games = steam.games(user.X, user.Y, user.Z)
    
    if not lfs.attributes(user.dir) then
        lfs.mkdir(user.dir)
    end
    
    lfs.chdir(user.dir)

    io.printf("Scanning categorization directory, and updating Steam as necessary...\n")
    apply_user_categories(games, categories)
    
    io.printf("Adding new games to categorization directory...\n")
    add_new_games(games, categories)
    
    lfs.chdir("../../userdata/"..(user.Z*2 + user.Y).."/7/remote/")
    
    io.printf("Backing up old Steam category information...\n")
    io.writefile("sharedconfig.vdf.backup", io.readfile("sharedconfig.vdf"))
    
    io.printf("Writing new Steam category information...\n")
    steam.saveVDF("sharedconfig.vdf", sharedconfig)
    
    io.printf("Done!\n")
    
    return 0
end

local r,e = xpcall(main, debug.traceback)
if not r then
    io.eprintf("Error in execution: %s\n", e)
end

io.printf("\n\nPress enter to quit...")
io.read()

