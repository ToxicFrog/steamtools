steam = {}

require "steamlib.vdf"

local function get_gamelist(url)
    local http = require "socket.http"

    local page,err = http.request(url)
    if not page then return page,err end

    local games = {}

    for id,name in page:gmatch('id="game_(%d+)">.-<h4>([^<]+)</h4>') do
        games[id] = name
    end
    
    return games
end    

function steam.xyz2community(X, Y, Z)
    return "7656"..(Y + Z*2 + 1197960265728) 
end

-- given a Steam user ID, return a table of appID => game name mappings
function steam.games(X, Y, Z)
    -- if the UID is in X,Y,Z format, we need to do a bit of massaging
    if Y and Z then
        return get_gamelist("http://steamcommunity.com/profiles/"..steam.xyz2community(X, Y, Z).."/games?tab=all")
    end
        
    return get_gamelist("http://steamcommunity.com/id/"..X.."/games?tab=all")
end

-- as games, but returns the contents of the user's wishlist
function steam.wishlist(X, Y, Z)
    -- if the UID is in X,Y,Z format, we need to do a bit of massaging
    if Y and Z then
        return get_gamelist("http://steamcommunity.com/profiles/"..steam.xyz2community(X, Y, Z).."/wishlist/")
    end
        
    return get_gamelist("http://steamcommunity.com/id/"..uid.."/wishlist/")
end

-- given an appID, return the name of the corresponding game
local names = {}
function steam.name(appid)
    if names[appid] ~= nil then return names[appid] end
    
    local http = require "socket.http"
    
    local page,err = http.request("http://store.steampowered.com/app/"..appid)
    if not page then return page,err end
    
    local name = page:match('<title>(.*) on Steam</title>')
    names[appid] = name or false
    
    return name
end
 
return steam
