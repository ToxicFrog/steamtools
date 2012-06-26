require "util.init"

local steam = require "steam"

local function download_XML(url)
    local dom = require "xml.easyDOMHandler" ()
    local xml = require "xml.xml" (dom)

    local page,err = socket.http.request(url)
    if not page then return page,err end

    xml:parse(page)

    local games = {}
    for _,xgame in ipairs(dom.root.gamesList.games) do
        local game = {}
        for _,key in ipairs(xgame) do
            game[key._name] = key.TEXT
        end
        table.insert(games, game)
    end
    
    return games
end

local function download_HTML(url)
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

local function mapby(list, key)
    local games = {}
    for _,game in ipairs(list) do
        games[game[key]] = game
    end
    return games
end

local function download(self, name, downloader, url)
    if not self[name] then
        local list,err = downloader(url)
        if not list then
            return nil,err
        end
        
        self[name] = list
    end
    
    return self[name]
end

-- return the list of all games the user owns, optionally indexed by key
function steam:games(key)
    local games = download(self, "_games", download_XML, self:community_url().."/games?tab=all&xml=1")
    
    if key then
        return mapby(self, games, key)
    end
    return table.copy(games)
end

-- return the list of all games the user has on their wishlist, optionally
-- indexed by key
function steam:wishlist(key)
    local games = download(self, "_wishlist", download_HTML, self:community_url().."/wishlist/")
    
    if key then
        return mapby(games, key)
    end
    return table.copy(games)
end

