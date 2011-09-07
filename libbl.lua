require "socket.http"
require "util.http"
require "ltn12"
require "util.string"
require "html"

bl = {}

-- set of platforms permitted by Backloggery.
bl.platforms = {
    ["32X"] = "32X";
    ["3DO"] = "3DO";
    ["AMG"] = "Amiga";
    ["CD32"] = "Amiga CD32";
    ["AMS"] = "Amstrad CPC";
    ["GX4k"] = "Amstrad GX4000";
    ["Droid"] = "Android";
    ["APF"] = "APF-M1000";
    ["AppII"] = "Apple II";
    ["Pippin"] = "Apple Bandai Pippin";
    ["ARC"] = "Arcade";
    ["2600"] = "Atari 2600";
    ["5200"] = "Atari 5200";
    ["7800"] = "Atari 7800";
    ["Atr8b"] = "Atari 8-bit";
    ["AtrST"] = "Atari ST";
    ["Astro"] = "Bally Astrocade";
    ["BBC"] = "BBC Micro";
    ["Brwsr"] = "Browser";
    ["CALC"] = "Calculator";
    ["CDi"] = "CD-i";
    ["CD32X"] = "CD32X";
    ["Adam"] = "Coleco Adam";
    ["CV"] = "ColecoVision";
    ["C64"] = "Commodore 64";
    ["VIC20"] = "Commodore VIC-20";
    ["CBoy"] = "Cougar Boy";
    ["Desura"] = "Desura";
    ["Dragon"] = "Dragon 32/64";
    ["DC"] = "Dreamcast";
    ["DSiW"] = "DSiWare";
    ["Arc2k1"] = "Emerson Arcadia 2001";
    ["ChF"] = "Fairchild Channel F";
    ["FDS"] = "Famicom Disk System";
    ["FMT"] = "FM Towns";
    ["FM7"] = "Fujitsu Micro 7";
    ["Gamate"] = "Gamate";
    ["GW"] = "Game &amp; Watch";
    ["GG"] = "Game Gear";
    ["GBC"] = "Game Boy/Color";
    ["GBA"] = "Game Boy Advance";
    ["eRdr"] = "e-Reader";
    ["GWFES"] = "Game Wave Family Entertainment System";
    ["GCN"] = "GameCube";
    ["G4W"] = "Games For Windows";
    ["GCOM"] = "Game.com";
    ["GEN"] = "Genesis / Mega Drive";
    ["Gizm"] = "Gizmondo";
    ["GOG"] = "Good Old Games";
    ["Wiz"] = "GP2X Wiz";
    ["HprScn"] = "HyperScan";
    ["Imp"] = "Impulse";
    ["IntVis"] = "Intellivision";
    ["iOS"] = "iOS";
    ["iPad"] = "iPad";
    ["iPod"] = "iPod";
    ["iPhone"] = "iPhone";
    ["JAG"] = "Jaguar";
    ["JagCD"] = "Jaguar CD";
    ["Lynx"] = "Lynx";
    ["Mac"] = "Mac";
    ["SMS"] = "Master System";
    ["Micvis"] = "Microvision";
    ["Misc"] = "Miscellaneous";
    ["Mobile"] = "Mobile";
    ["MSX"] = "MSX";
    ["NGage"] = "N-Gage";
    ["PC88"] = "NEC PC-8801";
    ["PC98"] = "NEC PC-9801";
    ["NG"] = "Neo Geo";
    ["NGCD"] = "Neo Geo CD";
    ["NGPC"] = "Neo Geo Pocket/Color";
    ["3DS"] = "Nintendo 3DS";
    ["3DSDL"] = "3DS Downloads";
    ["NDS"] = "Nintendo DS";
    ["N64"] = "Nintendo 64";
    ["64DD"] = "Nintendo 64DD";
    ["NES"] = "Nintendo Entertainment System";
    ["Nuon"] = "Nuon";
    ["Ody2"] = "Odyssey&sup2; / Videopac";
    ["OnLive"] = "OnLive";
    ["Origin"] = "Origin";
    ["Pndra"] = "Pandora";
    ["PC"] = "PC";
    ["PCDL"] = "PC Downloads";
    ["PC50X"] = "PC-50X";
    ["PCFX"] = "PC-FX";
    ["PB"] = "Pinball";
    ["PS"] = "PlayStation";
    ["PS2"] = "PlayStation 2";
    ["PS3"] = "PlayStation 3";
    ["PSN"] = "PlayStation Network";
    ["PS1C"] = "PSOne Classics";
    ["PSmini"] = "PlayStation minis";
    ["PSP"] = "PlayStation Portable";
    ["PSVita"] = "PlayStation Vita";
    ["PnP"] = "Plug-and-Play";
    ["PktStn"] = "PocketStation";
    ["PkMini"] = "Pok&eacute;mon Mini";
    ["RZN"] = "R-Zone";
    ["RCAS2"] = "RCA Studio II";
    ["SAM"] = "SAM Coup&eacute;";
    ["Saturn"] = "Saturn";
    ["SCD"] = "Sega CD";
    ["Pico"] = "Sega Pico";
    ["SG1000"] = "Sega SG-1000";
    ["X1"] = "Sharp X1";
    ["X68k"] = "Sharp X68000";
    ["Steam"] = "Steam";
    ["SNES"] = "Super Nintendo Entertainment System";
    ["TI99"] = "TI-99/4A";
    ["Tiger"] = "Tiger Handhelds";
    ["TDuo"] = "TurboDuo";
    ["TG16"] = "TurboGrafx-16";
    ["TRS80"] = "TRS-80";
    ["VECT"] = "Vectrex";
    ["VB"] = "Virtual Boy";
    ["VC"] = "Virtual Console";
    ["VCH"] = "VC (Handheld)";
    ["SVis"] = "Watara Supervision";
    ["Wii"] = "Wii";
    ["WW"] = "WiiWare";
    ["WiiU"] = "Wii U";
    ["WinP7"] = "Windows Phone 7";
    ["WSC"] = "WonderSwan/Color";
    ["Xbox"] = "Xbox";
    ["360"] = "Xbox 360";
    ["XBLA"] = "Xbox LIVE Arcade";
    ["XNA"] = "XNA Indie Games";
    ["XbxGoD"] = "Xbox 360 Games on Demand";
    ["Zeebo"] = "Zeebo";
    ["Zune"] = "Zune";
    ["ZXS"] = "ZX Spectrum";
}

bl.regions = {
    [0] = "N.Amer",
    "Japan",
    "PAL",
    "China",
    "Korea",
    "Brazil"
}

bl.__index = bl
function bl:__tostring()
    return "backloggery:"..self.user
end

-- log in to Backloggery and return a cookie that the caller can use to
-- interact with the site
function bl.login(user, pass)
    local post = socket.http.mkpost {
        username = user;
        password = pass;
        duration = "hour";
    }
    local body,code,headers = socket.http.request("http://backloggery.com/login.php", post)
    
    if code ~= 302 then
        err = html.parse(body):Find("div", "class", "update%-r")
        err = err and err:Content() or "unknown error"
        return nil,err
    end
    
    local cookies = { user = user }
    for crumb in headers["set-cookie"]:gmatch("c_%w+=[^;]+") do
        cookies[#cookies+1] = crumb
    end
    
    return setmetatable(cookies, bl)
end

local function request(self, fields, method, url)
    local body = socket.http.mkpost(fields)
    
    local headers = {
        ["referer"] = "http://backloggery.com/newgame.php?user="..self.user;
        ["cookie"] = table.concat(self, "; ")
    }

    if method == "POST" then
        headers["content-type"] = "application/x-www-form-urlencoded"
        headers["content-length"] = tostring(#body)
    end

    local response = {}
    local request = {
        method = method;
        url = url;
        headers = headers;
        sink = ltn12.sink.table(response);
    }
    
    if method == "POST" then
        request.source = ltn12.source.string(body)
    else
        request.url = url.."?"..body
    end

    print("request", request.url)
    local r,e = socket.http.request(request)
    socket.sleep(0.2)
    
    if r then
        return html.parse(table.concat(response))
    else
        return nil,e
    end
end

-- add a game to a backloggery account. Required fields are "name", "console",
-- and "complete". Other fields are optional.
function bl:addgame(game)
    local fields = {
        name = false; -- to be filled in
        comp = "";
        console = false; -- to be filled in
        orig_console = "";
        region = "0";
        own = "1";
        complete = false; -- to be filled in
        achieve1 = "";
        achieve2 = "";
        online = "";
        note = "";
        rating = "8";
        submit1 = "Add Game";
        --wishlist = "1"; -- caller needs to set this if they want it
    }
    
    for k,v in pairs(game) do
        fields[k] = v
    end
    
    fields.complete = bl.completecode(fields.complete)
    
    assert(fields.name and fields.complete, "invalid argument to bl:addgame - name and completion status required")
    assert(bl.platforms[fields.console], "invalid argument to bl:addgame - platform '"..tostring(fields.console).."' is not supported by backloggery")
    
    if self:hasgame(fields.name) then
        return nil,"game '%s' is already in this Backloggery" % fields.name
    end

    local r,e = request(self, fields, "POST", "http://backloggery.com/newgame.php?user="..self.user)
    
    if not r then
        return nil,tostring(e)
    end
    
    if r:Find("div", "class", "update%-r") then
        return nil,r:Find("div", "class", "update%-r"):Content()
    end

    return r:Find("div", "class", "update%-g"):Content()
end

-- returns true if the user has a game of this name, and false otherwise
function bl:hasgame(game)
    return self:games()[game] ~= nil
end

local function getAllGames(self, wishlist, games)
    games = games or {}
    
    local id, temp_sys, aj_id, total = 1, "ZZZ", 0, 0
    local function getMoreGames(wishlist)
        local fields = {
            user = self.user;
            temp_sys = temp_sys;
            total = total;
            aid = id;
            ajid = aj_id;
            search = ""; console = ""; rating = ""; status = ""; own = "";
            region = ""; region_u = 0; wish = wishlist and "1" or ""; alpha = "";
        }
        
        local body = assert(request(self, fields, "GET", "http://backloggery.com/ajax_moregames.php"))
        
        for gamebox in body:GFind("section", "class", "gamebox.*") do
            if gamebox.class == "gamebox" or gamebox.class == "gamebox nowplaying" then
                local info = {}
                info.name = gamebox:Find("b"):Content()
                info.console = gamebox:Find("a", "href", "^games.php").href:match("console=([^&]+)")
                info.id = tonumber(gamebox:Find("a", "href", "^update.php").href:match([[gameid=(%d+)]]))

                info.complete = gamebox:Find("a", "href", "^games.php").href:match("status=(%d+)")
                info.complete = tonumber(info.complete)

                info.note = gamebox:FindAll("div", "class", "gamerow")[2]
                info.note = info.note and info.note:Content()

                info.rating = gamebox:Find("img", "src", "stars%.gif$")
                info.rating = info.rating and (tonumber(info.rating.src:match("(%d)_5stars")) - 1) or 8 -- 8 == no rating
                info._stars = info.rating == 8 and 0 or (info.rating +1)
                
                info.own = gamebox:Find("img", "src", "own_")
                if info.own then
                    if info.own.src:match("own_ghost") then
                        info.own = 2
                    elseif info.own.src:match("own_borrow") then
                        info.own = 3
                    elseif info.own.src:match("own_other") then
                        info.own = 4
                    else
                        info.own = 1
                    end
                else
                    info.own = 1
                end
                
                info.wishlist = wishlist
                info.playing = gamebox.class == "gamebox nowplaying"

                games[info.id] = info
            end
        end
        
        if body:Find("input", "value", "Show more games") then
            id,temp_sys,aj_id,total = body:Find("input", "value", "Show more games").onclick:match([[getMoreGames%((%d+),%s*'(.-)',%s*'(%d+)',%s*(%d+)%)]])
        else
            id = nil
        end
    end
    
    repeat getMoreGames(wishlist) until not id
    
    return games
end
    
function bl:games(key)
    if not self._games then
        self._games = getAllGames(self, false)
        getAllGames(self, true, self._games)
        
        for _,game in pairs(self._games) do
            game._complete_str = bl.completestring(game.complete)
            game._console_str = bl.platforms[game.console]
        end
    end
    
    key = key or "id"
    local games = {}
    for id,game in pairs(self._games) do
        games[game[key]] = game
    end
    
    return games
end

-- translate a completion string into a numeric completion code
function bl.completecode(complete)
    if type(complete) == "number" and complete >= 1 and complete <= 5 then
        return complete
    end
    
    local code = {
        "unfinished",
        "beaten finished done",
        "completed",
        "mastered",
        "null casual multiplayer sandbox"
    }
    
    for i,v in ipairs(code) do
        if v:match(complete:lower()) then
            return i
        end
    end
    
    return nil
end

function bl.completestring(code)
    local complete = { "unfinished", "beaten", "completed", "mastered", "null" }
    return complete[code]
end

function bl:deletegame(game)
    assert(type(game) == "number", 'invalid argument to bl:deletegame')
    
    local fields = {
        user = self.user;
        delete2 = "Stealth Delete";
    }
        
    return request(self, fields, "POST", "http://backloggery.com/update.php?user=%s&gameid=%d" % { self.user, game })
end

function bl:details(game)
    assert(type(game) == "number", 'invalid argument to bl:details')
    
    game = assert(self:games()[game], 'no game with id '..game)
    
    local body = assert(request(self, { user = self.user, gameid = game.id }, "GET", "http://backloggery.com/update.php"))
    
    local function set(key, value)
        if not game[key] then
            game[key] = value
        end
    end
    
    -- name, console, complete, note, wishlist, and playing were already
    -- filled in by the initial loading of the game list
    -- FIXME own should be as well
    
    -- this leaves: comp, orig_console, region
    -- achieve1, achieve2, online
    -- rating, comments
    
    print(body:Show())
    
    set("comp", body:Find("input", "name", "comp").value)
    set("orig_console", body:Find("select", "name", "orig_console"):Find("option", "selected", true).value)
    set("region", body:Find("select", "name", "region"):Find("option", "selected", true).value)
    set("achieve1", tonumber(body:Find("input", "name", "achieve1").value) or "")
    set("achieve2", tonumber(body:Find("input", "name", "achieve2").value) or "")
    set("online", body:Find("input", "name", "online").value)
    set("comments", body:Find("textarea", "name", "comments"):Content())
    
end

return bl

--[[
http://backloggery.com/update.php?user=ToxicFrog&gameid=4183025

backloggery game editor form field names

    INFORMATION
name
comp
console -- see bl.platforms
orig_console
region -- 0..5 -> NA, JP, PAL, China, Korea, Brazil
own -- 1..4 -> owned, formerly, borrowed, other

    PROGRESS
complete -- 1..5 unf bea com mas nul
achieve1 -- current
achieve2 -- max
online
note

    REVIEW
rating -- 0..4 for 1..5 stars, 8 for no rating
comments

    MISC
playing -- now playing, =1 if set, omitted if unset
wishlist -- wishlisted, =1 if set, omitted if unset
submit1=Save -- normal save
submit2=Stealth+Save -- stealth save
delete1=Delete+Game
delete2=Stealth+Delete

--]]
