require "lfs"
require "socket.http"
require "util.string"
require "util.table"

steam = {}
require "libsteam.vdf"

steam.__index = steam
function steam:__tostring()
    if self.name then
        return "STEAM_%d:%d:%d (%s)" % { self.X, self.Y, self.Z, self.name }
    else
        return "STEAM_%d:%d:%d" % { self.X, self.Y, self.Z }
    end
end

function steam.open(path, X, Y, Z)
    -- strip trailing filename
    path = path:gsub("[/\\]?[^/\\]+$", "")
    
    -- we do it using io.open because lfs.attributes has useless error messages
    local fd,err = io.open(path.."/Steam.exe", "rb")
    if not fd then
        return nil,"Couldn't find Steam.exe: "..err
    end
    fd:close()
    
    local self = {
        path = path;
    }
    
    if X and Y and Z then
        self.X,self.Y,self.Z = X,Y,Z
        self.name = "(unknown)"
    else
        -- no user ID specified - get last logged in user from log file
        local name,id
        for line in io.safe_lines(path.."/steam.log") do
            name = line:match("CreateSession%(([^,]+)") or name
            id = line:match("for ([0-9:]+)%s*$") or id
        end
        if not id then
            return nil,"Couldn't determine last logged in user from steam.log"
        end
        self.X,self.Y,self.Z = id:match("(%d+):(%d+):(%d+)")
        self.name = name
    end
    
    return setmetatable(self, steam)
end

local function get_gamelist(url)
    local page,err = socket.http.request(url)
    if not page then return page,err end

    local games = {}

    for id,name in page:gmatch('id="game_(%d+)">.-<h4>([^<]+)</h4>') do
        games[#games+1] = {
            appid = tonumber(id:trim());
            name = name:trim();
        }
    end
    
    return games
end

local function games_aux(self, key, name, url)
    if not self[name] then
        local list,err = get_gamelist(url)
        if not list then
            return nil,err
        end
        
        self[name] = list
    end
    
    local games
    if key then
        games = {}
        for _,game in ipairs(self[name]) do
            games[game[key]] = game
        end
    else
        games = table.copy(self[name])
    end
    return games
end

-- return the list of all games the user owns, optionally indexed by key
function steam:games(key)
    return games_aux(self, key, "_games", self:community_url().."/games?tab=all")
end

-- return the list of all games the user has on their wishlist, optionally
-- indexed by key
function steam:wishlist(key)
    return games_aux(self, key, "_wishlist", self:community_url().."/wishlist/")
end

-- return the URL of this user's Steam Community page
function steam:community_url()
    return "http://steamcommunity.com/profiles/7656%.0f" % (self.Y + self.Z * 2 + 1197960265728)
end

function steam:config_path()
    return self.path.."/userdata/"..(self.Z*2 + self.Y).."/7/remote/sharedconfig.vdf"
end

function steam:load_categories() 
    local sharedconfig = assert(steam.loadVDF(self.path.."/userdata/"..(self.Z*2 + self.Y).."/7/remote/sharedconfig.vdf"))
    
    local apps
    if sharedconfig.UserRoamingConfigStore then
        apps = sharedconfig.UserRoamingConfigStore.Software.Valve.Steam.apps
    elseif sharedconfig.UserLocalConfigStore then
        apps = sharedconfig.UserLocalConfigStore.Software.Valve.Steam.apps
    else
        return error("Couldn't find User(Roaming|Local)ConfigStore in sharedconfig.vdf")
    end
    
    for appid,game in pairs(self:games("appid")) do
        local tags = (apps[tostring(appid)] and apps[tostring(appid)].tags)
        if tags then
            for k,v in pairs(tags) do
                if v == "favorite" then
                    game.favorite = true
                else
                    game.category = v
                end
            end
        end
    end
    
    return self:games()
end

function steam:save_categories()
    -- extract the apps table from the VDF in the same manner as load_categories
    local sharedconfig = assert(steam.loadVDF(self:config_path()))
    
    local apps
    if sharedconfig.UserRoamingConfigStore then
        apps = sharedconfig.UserRoamingConfigStore.Software.Valve.Steam.apps
    elseif sharedconfig.UserLocalConfigStore then
        apps = sharedconfig.UserLocalConfigStore.Software.Valve.Steam.apps
    else
        return error("Couldn't find User(Roaming|Local)ConfigStore in sharedconfig.vdf")
    end
    
    -- now iterate over every game in the steam game list and update the 
    -- category information for it
    for appid,game in pairs(self:games("appid")) do
        local app = apps[tostring(appid)] or {}
        app.tags = {}
        if game.favorite then
            app.tags["0"] = "favorite"
            app.tags["1"] = game.category
        else
            app.tags["0"] = game.category
        end
        apps[tostring(appid)] = app
    end
    
    -- create a backup of the old VDF file, and save the new
    io.writefile(self:config_path()..".backup."..tostring(os.time()), io.readfile(self:config_path()))
    steam.saveVDF(self:config_path(), sharedconfig)
end
