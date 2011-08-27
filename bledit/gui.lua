require "iuplua"
require "util.table"

local gui = {}

--------------------------------------------------------------------------------
-- internal functions used for GUI creation
--------------------------------------------------------------------------------

-- create a mockup of an element. Used to create placeholders that will
-- later be replaced with the real thing
local function mock(name, expand)
    if expand == true then
        expand = "YES"
    elseif expand == false then
        expand = nil
    end
    return iup.frame { iup.label { fgcolor = "255 0 0"; expand = expand; title = '['..name..']' } }
end

-- create a frame with a title, as in frame "foo" { ... }
local function frame(title)
    return function(init)
        init.title = title
        return iup.frame(init)
    end
end

-- create a dropdown for selecting a gaming system from the list of systems
-- supported by backloggery
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

-- create a dropdown for selecting a region from the list of regions supported
-- by backloggery
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

--------------------------------------------------------------------------------
-- internal widget banks
--------------------------------------------------------------------------------

-- the set of all editing fields
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
        default = 6;
    };
    comments = iup.text { expand = "YES"; multiline = "YES" };
}

-- the set of all user controls not used for editing game data, as well as
-- feedback controls
local controls = {
    status = iup.label { title = "Not Logged In" };
    new = iup.button { title = "New"; padding = "4x"; active = "NO" };
    edit = iup.button { title = "Edit"; padding = "4x"; active = "NO" };
    delete = iup.button { title = "Delete"; padding = "4x" };
    save = iup.button { title = "Save"; padding = "4x"; active = "NO" };
    gamelist = iup.tree {
        expand = "YES";
        size = "200x";
        maxsize = "200x";
        markmode = "MULTIPLE";
    };
};

-- the main window
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
            iup.vbox {
                name = "editpane";
                active = "NO";
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

--------------------------------------------------------------------------------
-- callbacks
--------------------------------------------------------------------------------

function controls.delete:action()
    -- get list of selected games
    local selected = controls.gamelist.markednodes
    
    -- mark them for delete
    for i=1,#selected do
        if selected:sub(i,i) == "+" then
            local game = iup.TreeGetUserId(controls.gamelist, i-1)
            if game then
                game._delete = true
            end
        end
    end
    
    -- redisplay tree
    -- where do we get the master game list from?
    gui.listGames(GAMES, "_console_str", "name")
    
    -- restore list of selected nodes
    controls.gamelist.markednodes = selected
end

function controls.gamelist:selection_cb(id, status)
    local game = iup.TreeGetUserId(controls.gamelist, id)
    if not game then
        print("!!!!", id)
    elseif status == 1 then
        gui.loadFields(game)
    else
        gui.saveFields(game)
    end
end

--------------------------------------------------------------------------------
-- public API
--------------------------------------------------------------------------------

function gui.init()
    win:show()
    controls.editpane = iup.GetDialogChild(win, "editpane")
end

function gui.warn(title, message)
    iup.Alarm(title, message)
end

function gui.getLogin(USER,PASS)
    return iup.GetParam("Backloggery Login", nil, "Username: %s\nPassword:%s\n", USER or "", PASS or "")
end

function gui.status(status)
    controls.status.title = status
end

function gui.main()
    -- ok, now we can edit things
    win.active = "YES"
    iup.MainLoop()
end

function gui.listGames(allgames, group_by, sort_by)
    local function getNodeImage(game)
        if game._dirty then
            return "images/edit.bmp"
        elseif game._delete then
            return "images/delete.bmp"
        elseif game.playing then
            return "images/nowplaying.bmp"
        elseif game.wishlist then
            return "images/wishlist.bmp"
        else
            return "images/"..game._complete_str..".bmp"
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
    
    local games = {}; for _,game in pairs(allgames) do table.insert(games, game) end
    table.sort(games, sort)
    
    controls.gamelist.delnode = "ALL"
    
    local branches = {}
    for i,game in ipairs(games) do
        if not branches[game[group_by]] then
            branches[game[group_by]] = true
            controls.gamelist.addbranch = game[group_by]
        end
        controls.gamelist.addleaf0 = game.name
        controls.gamelist["image"..controls.gamelist.lastaddnode] = getNodeImage(game)
        iup.TreeSetUserId(controls.gamelist, controls.gamelist.lastaddnode, game)
    end
end

function iup:GetType()
    local t = tostring(self):match("IUP%((.*)%)")
    if not t then
        return type(self)
    else
        return "iup_"..t
    end
end

-- load all of the information for game into the editing fields
function gui.loadFields(game)
    local set = {}
    
    function set:iup_text(value)
        self.value = value or ""
    end
    
    function set:iup_list(value)
        if not value then
            self.value = 0; return
        end
        for i=1,self.count do
            if self[i] == value then
                self.value = i
                return
            end
        end
        self.value = 0
    end
    
    function set:table(value)
        if not value then
            table.map(self, function(w) w.value = "OFF" end)
        elseif self[value] then
            self[value].value = "ON"
        elseif self.default then
            self[self.default].value = "ON"
        end
    end
    
    local fields = {
        -- information
        name = fields.title;
        comp = fields.compilation;
        _console_str = fields.system;
        _orig_console_str = fields.original_system;
        _region_str = fields.region;
        own = fields.ownership; -- 1..4 -> owned, formerly, borrowed, other
        
        -- progress
        complete = fields.status; -- 1..5 UBCMN
        achieve1 = fields.achievements;
        achieve2 = fields.max_achievements;
        online = fields.online_info;
        note = fields.notes;
        
        -- review
        rating = fields.rating; -- 0..4 or 8
        comments = fields.comments;
        
        -- misc
        playing = fields.now_playing;
        wishlist = fields.wishlist;
    }
    
    for field,widget in pairs(fields) do
        if set[iup.GetType(widget)] then
            set[iup.GetType(widget)](widget, game[field])
        else
            print("Warning: couldn't load/set field", field, game[field], iup.GetType(widget))
        end
    end
    
    if game._dirty then
        controls.editpane.active = "YES"
    else
        controls.editpane.active = "NO"
    end
end

function gui.saveFields(game)
    print("SAVE", game.name, fields.title.value)
end

return gui
