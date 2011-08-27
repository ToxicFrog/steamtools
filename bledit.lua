package.cpath = package.cpath..";iup/lib?51.so"

require "iuplua"

local function mock(name, expand)
    if expand == true then
        expand = "YES"
    elseif expand == false then
        expand = nil
    end
    return iup.frame { iup.label { fgcolor = "255 0 0"; expand = expand; title = '['..name..']' } }
end

local function frame(title)
    return function(init)
        init.title = title
        return iup.frame(init)
    end
end

local function SystemSelector()
    local bl = require "libbl"
    
    local systems = {}
    
    for short,long in pairs(bl.platforms) do
        table.insert(systems, long)
    end
    
    table.sort(systems)
    systems.dropdown = "YES";
    
    return iup.list(systems)
end

local function RegionSelector()
    return iup.list {
        dropdown = "YES";
        
        "Brazil";
        "China";
        "Japan";
        "Korea";
        "N.Amer";
        "PAL";
    }
end

local fields = {
    -- game information
    title = iup.text { expand = "HORIZONTAL" };
    compilation = iup.text { expand = "HORIZONTAL" };
    system = SystemSelector();
    original_system = SystemSelector();
    region = RegionSelector();
    ownership = {
        iup.toggle { image = "images/own_owned.bmp" };
        iup.toggle { image = "images/own_ghost.bmp" };
        iup.toggle { image = "images/own_borrow.bmp" };
        iup.toggle { image = "images/own_other.bmp" };
    };
        
    
    -- progress
    status = {
        iup.toggle { image = "images/unfinished.bmp" };
        iup.toggle { image = "images/beaten.bmp" };
        iup.toggle { image = "images/completed.bmp" };
        iup.toggle { image = "images/mastered.bmp" };
        iup.toggle { image = "images/null.bmp" };
    };
    achievements = iup.text { size = "30x"; spin = "YES"; spinmax = 999; };
    max_achievements = iup.text { size = "30x"; spin = "YES"; spinmax = 999; };
    notes = iup.text { expand = "HORIZONTAL" };
    online_info = iup.text { expand = "HORIZONTAL" };
    
    -- review
    rating = {
        iup.toggle { image = "images/5_5stars.bmp" };
        iup.toggle { image = "images/4_5stars.bmp" };
        iup.toggle { image = "images/3_5stars.bmp" };
        iup.toggle { image = "images/2_5stars.bmp" };
        iup.toggle { image = "images/1_5stars.bmp" };
        iup.toggle { title = "No Rating" };
    };
    comments = iup.text { expand = "YES"; multiline = "YES" };
}

local controls = {
    name = iup.label { title = "Not Logged In" };
    new = iup.button { title = "New"; padding = "4x" };
    edit = iup.button { title = "Edit"; padding = "4x" };
    delete = iup.button { title = "Delete"; padding = "4x" };
    save = iup.button { title = "Save"; padding = "4x" };
    gamelist = iup.tree {
        expand = "YES";
        size = "200x";
        maxsize = "200x";
    };
};

local win = iup.dialog {
    title = "Backloggery Editor";
    fontstyle = "bold";
    active = "NO";
    --size = "QUARTERxQUARTER";
    
    iup.hbox {
        iup.vbox { -- contains game list, sort buttons
            fontstyle = "";
            expandchildren = "YES";

            controls.gamelist;
            mock("Sort By");
            mock("Group By");
        };
        iup.vbox { -- contains edit controls
            iup.frame { -- general game information
                title = "Game Information";
                
                iup.vbox {
                    fontstyle = "";
                    
                    frame "Title" {
                        fields.title;
                    };
                    frame "Compilation" {
                        fields.compilation;
                    };
                    iup.hbox {
                        frame "System" {
                            fields.system;
                        };
                        frame "Original System" {
                            fields.original_system;
                        };
                        frame "Region" {
                            fields.region;
                        };
                    };
                    frame "Ownership" {
                        iup.radio{
                            iup.hbox {
                                alignment = "ACENTER";
                                
                                fields.ownership[1];
                                iup.label { title = "Owned" };
                                iup.fill { size = 20 };
                                fields.ownership[2];
                                iup.label { title = "Formerly Owned" };
                                iup.fill { size = 20 };
                                fields.ownership[3];
                                iup.label { title = "Borrowed/Rented" };
                                iup.fill { size = 20 };
                                fields.ownership[4];
                                iup.label { title = "Other" };
                                iup.fill {};
                            };
                        };
                    };
                };
            };
            
            iup.frame { -- status and progress controls
                title = "Progress";
                
                iup.vbox {
                    fontstyle = "";
                    
                    iup.frame {
                        title = "Status";
                        iup.radio{
                            iup.hbox {
                                alignment = "ACENTER";
                                
                                fields.status[1];
                                iup.label { title = "Unfinished" };
                                iup.fill { size = 20 };
                                fields.status[2];
                                iup.label { title = "Beaten" };
                                iup.fill { size = 20 };
                                fields.status[3];
                                iup.label { title = "Completed" };
                                iup.fill { size = 20 };
                                fields.status[4];
                                iup.label { title = "Mastered" };
                                iup.fill { size = 20 };
                                fields.status[5];
                                iup.label { title = "Null" };
                                iup.fill {};
                            };
                        };
                    };
                    
                    iup.hbox {
                        iup.frame {
                            title = "Achievements";
                            iup.hbox {
                                fields.achievements;
                                iup.label { title = " out of " };
                                fields.max_achievements;
                            };
                        };
                        iup.frame {
                            title = "Online Info";

                            fields.online_info;
                        };
                    };
                    
                    iup.frame {
                        title = "Notes";
                        fields.notes;
                    };
                };
            };
            
            iup.frame { -- rating and review controls
                title = "Review";
                iup.hbox {
                    fontstyle = "";
                    iup.frame {
                        title = "Rating";
                        iup.radio {
                            iup.vbox {
                                fontstyle = "";
                                expandchildren = "YES";
                                
                                unpack(fields.rating);
                            };
                        };
                    };
                    iup.frame {
                        title = "Comments";
                        
                        fields.comments;
                    };
                };
            };
            
            iup.hbox { -- command buttons
                fontstyle = "";
                alignment = "ACENTER";
                
                iup.fill {};
                controls.name;
                iup.fill {};
                controls.new;
                controls.edit;
                controls.delete;
                iup.fill {};
                controls.save;
                iup.fill {};
            };
        };
    };
}

local function mkGameList(games, group_by, sort_by)
    local function getNodeImage(game)
        if game.nowplaying then
            return "images/nowplaying.bmp"
        elseif game.wishlist then
            return "images/wishlist.bmp"
        else
            return "images/"..game.complete..".bmp"
        end
    end
    
    -- due to the way tree construction works, we need to do the categories
    -- in order, but the invidual games in reverse order - branches are added
    -- top-down, leaves bottom-up
    local function sort(x, y)
        if x[group_by] == y[group_by] then
            return x[sort_by] > y[sort_by]
        else
            return x[group_by] < y[group_by]
        end
    end
    table.sort(games, sort)
    
    controls.gamelist.delnode = "ALL"
    
    local branches = {}
    for i,game in ipairs(games) do
        print(game[group_by], game.name)
        if not branches[game[group_by]] then
            branches[game[group_by]] = true
            controls.gamelist.addbranch = game[group_by]
        end
        controls.gamelist.addleaf0 = game.name
        controls.gamelist["image"..controls.gamelist.lastaddnode] = getNodeImage(game)
        iup.TreeSetUserId(controls.gamelist, controls.gamelist.lastaddnode, game)
    end
end

function controls.gamelist:selection_cb(id, status)
    local game = iup.TreeGetUserId(controls.gamelist, id)
    if not game then
        print("!!!!", id)
    elseif status == 1 then
        print("selected", game.name)
    else
        print("deselected", game.name)
    end
end

function main(...)
    win:show()
    
    -- load config file
    if loadfile("steam2backloggery.cfg") then
        local r,e = xpcall(loadfile("steam2backloggery.cfg"), debug.traceback)
        if not r then
            iup.Alarm("Warning", "Found config file steam2backloggery.cfg, but couldn't load it:\n", e)
        end
    end
    
    -- log in to backloggery
    local bl = require "libbl"
    local cookie
    
    while not cookie do
        local status,user,pass = iup.GetParam("Backloggery Login", nil, "Username: %s\nPassword:%s\n", USER or "", PASS or "")
        if not status then os.exit(1) end
    
        cookie,status = bl.login(user,pass)
        if not cookie then
            iup.Alarm("Login Failed", "Login failed: "..status, "OK")
        end
    end
    
    controls.name.title = "Logged in as "..cookie.user

    -- download game list
    local games = {}
    for _,game in pairs(cookie:games()) do
        games[#games+1] = game
    end
    for _,game in pairs(cookie:wishlist()) do
        games[#games+1] = game
    end
    mkGameList(games, "console_name", "name")
    
    -- ok, now we can edit things
    win.active = "YES"
    iup.MainLoop()
end

local r,e = xpcall(main, debug.traceback)
if not r then
    iup.Alarm("Error", tostring(e), "OK")
end
