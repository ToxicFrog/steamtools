require "lfs"
require "socket.http"
require "util.string"
require "util.table"

steam = {}
package.loaded.steam = steam
require "libsteam.vdf"
require "libsteam.games"

steam.__index = steam
function steam:__tostring()
    if self.name then
        return "STEAM_%d:%d:%d (%s)" % { self.X, self.Y, self.Z, self.name }
    else
        return "STEAM_%d:%d:%d" % { self.X, self.Y, self.Z }
    end
end

function steam.open(path, name, X, Y, Z)
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
        self.name = name or "unknown_user"
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
        self.name = name or self.name
    end
    
    return setmetatable(self, steam)
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
