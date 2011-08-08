-- a simple script to upload game lists to backloggery. It expects the game
-- list on stdin as a set of tab-separated values in the format
-- platform \t status \t title
-- lines starting with # are ignored
-- It outputs the same list, with the following modifications:
-- - games that were successfully uploaded are prepended with '#'
-- - games that were not have '##' appended followed by an error message
-- In this way, you can take the output, find all the games with ##, correct
-- whatever the error was, and feed it back into the script for another go.

-- for example, given the following file as input:
--  # start game list
--  PC  DONE    Thief
--  PC  READY   Thief 2
--  DOS DONE    System Shock
-- it would add "Thief" and "Thief 2" to your backlog, marked as "beaten" and
-- "unfinished" respectively, and produce the following output:
--  # start game list
--  # PC    DONE    Thief
--  # PC    READY   Thief 2
--  DOS DONE    System Shock    ## Unrecognized platform DOS


-- username and login cookie. Get the cookie from your browser's cookies after
-- logging in to backloggery.com; it should have the same structure as the
-- example here, except with the '1234' parts replaced with much longer values
USER    = "Example"
COOKIE  = "c_user=Example; c_pass=1234; __utma=1234; __utmc=1234; __utmz=1234; __utmb=1234"

-- completion status of individual games. The completion status you report to
-- the program will be looked up here and thus translated into a completion
-- status that Backloggery understands.
-- If it doesn't show up here the game will be skipped.
local statii = {
    "BLOCKED READY PLAYING";            -- unfinished
    "DONE FINISHED";                    -- beaten
    "COMPLETE";                         -- complete
    "MASTERED";                         -- mastered
    "CASUAL MULTIPLAYER TRASH SANDBOX"; -- null
    "WISHLIST";                         -- unfinished + wishlist
}

-- END OF USER CONFIGURABLE STUFF --

-- set of platforms permitted by Backloggery. If it doesn't show up here,
-- Backloggery doesn't support it and the game will be skipped.
local platforms = {
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

local socket = require "socket"
local http = require "socket.http"

function mkpost(fields)
    local function hex(ch)
        return ("%%%02X"):format(ch:byte())
    end
    
    buf = {}
    
    --for _,field in ipairs { "name", "comp", "console", "orig_console", "region", "own", "complete", "achieve1", "achieve2", "online", "note", "rating", "submit1" } do
    for field,value in pairs(fields) do
        buf[#buf+1] = ("%s=%s"):format(
            field,
            value:gsub("[^a-zA-Z0-9 ]", hex):gsub(" ", "+"))
    end
    
    return table.concat(buf, "&")
end

function upload(fields)
    local body = mkpost(fields)
    
    local head = {
        ["content-type"] = "application/x-www-form-urlencoded";
        ["content-length"] = tostring(#body);
        ["referer"] = "http://backloggery.com/newgame.php?user="..USER;
        ["user-agent"] = "Opera/9.80 (X11; Linux x86_64; U; en) Presto/2.8.131 Version/11.10";
        ["cookie"] = COOKIE;
    }

    local response = {}
    local r,e = http.request {
        method = "POST";
        url = "http://backloggery.com/newgame.php?user="..USER;
        headers = head;
        source = ltn12.source.string(body);
        sink = ltn12.sink.table(response);
    }
    
    if not r then
        return nil,tostring(e)
    end

    return table.concat(response)
end

-- 12345 -> unfinished, beated, complete, mastered, null
function mkstatus(status)
    for i,v in ipairs(statii) do
        if v:match(status) then
            return tostring(i)
        end
    end
    
    return nil
end

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
}

function main(...)
    local function prompt(text)
        io.write(text)
        return io.read()
    end
    
    for line in io.lines() do
        line = line:gsub("\t##.*$", "")
        local platform,status,title = line:match("([^\t]+)\t([^\t]+)\t([^\t]+)")
        
        if line:match("^#") then
            print(line)
        elseif not platform or not status or not title then
            print(line.."\t## Malformed input line - make sure you're using tabs")
        elseif not platforms[platform] then
            print(line.."\t## Unrecognized platform "..platform)
        elseif not mkstatus(status) then
            print(line.."\t## Unrecognized status "..status)
        else
            fields.name = title;
            fields.console = platform;
            fields.complete = mkstatus(status);
            if fields.complete == "6" then --wishlist
                fields.complete = "1"
                fields.wishlist = "1"
            end
            
            local result,err = upload(fields)
            if not result then
                print(line.."\t## "..err)
            elseif result:match("was added successfully") then
                print("# "..line)
            else
                print(line.."\t## "..(result:match('<div class="update[^\n]+') or "unknown error"))
            end
            socket.sleep(4)
        end
    end
end

return main(...)
