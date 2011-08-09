require "socket.http"
require "util.http"
require "ltn12"
require "util.string"

bl = {}

-- set of platforms permitted by Backloggery.
bl.platforms = {
    ["32X"] = true; -- 32X
    ["3DO"] = true; -- 3DO
    ["AMG"] = true; -- Amiga
    ["CD32"] = true; -- Amiga CD32
    ["AMS"] = true; -- Amstrad CPC
    ["GX4k"] = true; -- Amstrad GX4000
    ["Droid"] = true; -- Android
    ["APF"] = true; -- APF-M1000
    ["AppII"] = true; -- Apple II
    ["Pippin"] = true; -- Apple Bandai Pippin
    ["ARC"] = true; -- Arcade
    ["2600"] = true; -- Atari 2600
    ["5200"] = true; -- Atari 5200
    ["7800"] = true; -- Atari 7800
    ["Atr8b"] = true; -- Atari 8-bit
    ["AtrST"] = true; -- Atari ST
    ["Astro"] = true; -- Bally Astrocade
    ["BBC"] = true; -- BBC Micro
    ["Brwsr"] = true; -- Browser
    ["CALC"] = true; -- Calculator
    ["CDi"] = true; -- CD-i
    ["CD32X"] = true; -- CD32X
    ["Adam"] = true; -- Coleco Adam
    ["CV"] = true; -- ColecoVision
    ["C64"] = true; -- Commodore 64
    ["VIC20"] = true; -- Commodore VIC-20
    ["CBoy"] = true; -- Cougar Boy
    ["Desura"] = true; -- Desura
    ["Dragon"] = true; -- Dragon 32/64
    ["DC"] = true; -- Dreamcast
    ["DSiW"] = true; -- DSiWare
    ["Arc2k1"] = true; -- Emerson Arcadia 2001
    ["ChF"] = true; -- Fairchild Channel F
    ["FDS"] = true; -- Famicom Disk System
    ["FMT"] = true; -- FM Towns
    ["FM7"] = true; -- Fujitsu Micro 7
    ["Gamate"] = true; -- Gamate
    ["GW"] = true; -- Game &amp; Watch
    ["GG"] = true; -- Game Gear
    ["GBC"] = true; -- Game Boy/Color
    ["GBA"] = true; -- Game Boy Advance
    ["eRdr"] = true; -- e-Reader
    ["GWFES"] = true; -- Game Wave Family Entertainment System
    ["GCN"] = true; -- GameCube
    ["G4W"] = true; -- Games For Windows
    ["GCOM"] = true; -- Game.com
    ["GEN"] = true; -- Genesis / Mega Drive
    ["Gizm"] = true; -- Gizmondo
    ["GOG"] = true; -- Good Old Games
    ["Wiz"] = true; -- GP2X Wiz
    ["HprScn"] = true; -- HyperScan
    ["Imp"] = true; -- Impulse
    ["IntVis"] = true; -- Intellivision
    ["iOS"] = true; -- iOS
    ["iPad"] = true; -- iPad
    ["iPod"] = true; -- iPod
    ["iPhone"] = true; -- iPhone
    ["JAG"] = true; -- Jaguar
    ["JagCD"] = true; -- Jaguar CD
    ["Lynx"] = true; -- Lynx
    ["Mac"] = true; -- Mac
    ["SMS"] = true; -- Master System
    ["Micvis"] = true; -- Microvision
    ["Misc"] = true; -- Miscellaneous
    ["Mobile"] = true; -- Mobile
    ["MSX"] = true; -- MSX
    ["NGage"] = true; -- N-Gage
    ["PC88"] = true; -- NEC PC-8801
    ["PC98"] = true; -- NEC PC-9801
    ["NG"] = true; -- Neo Geo
    ["NGCD"] = true; -- Neo Geo CD
    ["NGPC"] = true; -- Neo Geo Pocket/Color
    ["3DS"] = true; -- Nintendo 3DS
    ["3DSDL"] = true; -- 3DS Downloads
    ["NDS"] = true; -- Nintendo DS
    ["N64"] = true; -- Nintendo 64
    ["64DD"] = true; -- Nintendo 64DD
    ["NES"] = true; -- Nintendo Entertainment System
    ["Nuon"] = true; -- Nuon
    ["Ody2"] = true; -- Odyssey&sup2; / Videopac
    ["OnLive"] = true; -- OnLive
    ["Origin"] = true; -- Origin
    ["Pndra"] = true; -- Pandora
    ["PC"] = true; -- PC
    ["PCDL"] = true; -- PC Downloads
    ["PC50X"] = true; -- PC-50X
    ["PCFX"] = true; -- PC-FX
    ["PB"] = true; -- Pinball
    ["PS"] = true; -- PlayStation
    ["PS2"] = true; -- PlayStation 2
    ["PS3"] = true; -- PlayStation 3
    ["PSN"] = true; -- PlayStation Network
    ["PS1C"] = true; -- PSOne Classics
    ["PSmini"] = true; -- PlayStation minis
    ["PSP"] = true; -- PlayStation Portable
    ["PSVita"] = true; -- PlayStation Vita
    ["PnP"] = true; -- Plug-and-Play
    ["PktStn"] = true; -- PocketStation
    ["PkMini"] = true; -- Pok&eacute;mon Mini
    ["RZN"] = true; -- R-Zone
    ["RCAS2"] = true; -- RCA Studio II
    ["SAM"] = true; -- SAM Coup&eacute;
    ["Saturn"] = true; -- Saturn
    ["SCD"] = true; -- Sega CD
    ["Pico"] = true; -- Sega Pico
    ["SG1000"] = true; -- Sega SG-1000
    ["X1"] = true; -- Sharp X1
    ["X68k"] = true; -- Sharp X68000
    ["Steam"] = true; -- Steam
    ["SNES"] = true; -- Super Nintendo Entertainment System
    ["TI99"] = true; -- TI-99/4A
    ["Tiger"] = true; -- Tiger Handhelds
    ["TDuo"] = true; -- TurboDuo
    ["TG16"] = true; -- TurboGrafx-16
    ["TRS80"] = true; -- TRS-80
    ["VECT"] = true; -- Vectrex
    ["VB"] = true; -- Virtual Boy
    ["VC"] = true; -- Virtual Console
    ["VCH"] = true; -- VC (Handheld)
    ["SVis"] = true; -- Watara Supervision
    ["Wii"] = true; -- Wii
    ["WW"] = true; -- WiiWare
    ["WiiU"] = true; -- Wii U
    ["WinP7"] = true; -- Windows Phone 7
    ["WSC"] = true; -- WonderSwan/Color
    ["Xbox"] = true; -- Xbox
    ["360"] = true; -- Xbox 360
    ["XBLA"] = true; -- Xbox LIVE Arcade
    ["XNA"] = true; -- XNA Indie Games
    ["XbxGoD"] = true; -- Xbox 360 Games on Demand
    ["Zeebo"] = true; -- Zeebo
    ["Zune"] = true; -- Zune
    ["ZXS"] = true; -- ZX Spectrum
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
        err = body:match [[div class="update%-r">([^<]+)]] or "unknown error"
        return nil,err
    end
    
    local cookies = { user = user }
    for crumb in headers["set-cookie"]:gmatch("c_%w+=[^;]+") do
        cookies[#cookies+1] = crumb
    end
    
    return setmetatable(cookies, bl)
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

    local body = socket.http.mkpost(fields)
    
    local headers = {
        ["content-type"] = "application/x-www-form-urlencoded";
        ["content-length"] = tostring(#body);
        ["referer"] = "http://backloggery.com/newgame.php?user="..self.user;
        ["cookie"] = table.concat(self, "; ")
    }

    local response = {}
    local r,e = socket.http.request {
        method = "POST";
        url = "http://backloggery.com/newgame.php?user="..self.user;
        headers = head;
        source = ltn12.source.string(body);
        sink = ltn12.sink.table(response);
    }
    
    socket.sleep(1)
    
    if not r then
        return nil,tostring(e)
    end

    return r
end

-- returns true if the user has a game of this name, and false otherwise
function bl:hasgame(game)
    return self:games()[game] ~= nil or self:wishlist()[game] ~= nil
end

local function getAllGames(self, wishlist)
    local games = {}
    
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
        
        local body = socket.http.request("http://backloggery.com/ajax_moregames.php?"..socket.http.mkpost(fields))
        socket.sleep(1)
        
        for status,name in body:gmatch("games%.php.-status=(%d+).-<b>(.-)</b>") do
            games[name] = {
                name = name:trim();
                status = bl.completestring(tonumber(status));
            }
        end
        
        id,temp_sys,aj_id,total = body:match([[getMoreGames%((%d+),%s*'(.-)',%s*'(%d+)',%s*(%d+)%)]])
    end
    
    repeat getMoreGames(wishlist) until not id
    
    return games
end
    
function bl:games()
    if not self._games then
        self._games = getAllGames(self, false)
    end
    
    return self._games
end

function bl:wishlist()
    if not self._wishlist then
        self._wishlist = getAllGames(self, true)
    end
    
    return self._wishlist
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
