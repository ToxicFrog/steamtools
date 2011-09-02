require "iuplua"
require "util.table"

local gui = {}

--------------------------------------------------------------------------------
-- internal widgets and whatnot
--------------------------------------------------------------------------------

local fields = require "bledit.fields"
local controls = require "bledit.controls"
local win = require "bledit.window"

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
    gui.listGames(bledit.games(), "_console_str", "name")
    
    -- restore list of selected nodes
    controls.gamelist.markednodes = selected
end

function controls.edit:action()
    -- get list of selected games
    local selected = controls.gamelist.markednodes
    
    -- mark them for edit
    for i=1,#selected do
        if selected:sub(i,i) == "+" then
            local game = iup.TreeGetUserId(controls.gamelist, i-1)
            if game then
                game._dirty = true
            end
        end
    end
    
    -- redisplay tree
    gui.listGames(bledit.games(), "_console_str", "name")
    
    -- restore list of selected nodes
    controls.gamelist.markednodes = selected
    
    gui.loadFields(fields.game)
end

function controls.save:action()
    local changed,deleted,unchanged = 0,0,0
    
    table.foreach(bledit.games(), function(_, game)
        if game._delete then
            deleted = deleted+1
        elseif game._dirty then
            changed = changed+1
        else
            unchanged = unchanged+1
        end
    end)
    
    if changed + deleted == 0 then
        iup.Alarm("Nothing to save!", "You must edit or delete some games before you can save.", "OK")
        return
    end
    
    if 1 ~= iup.Alarm("Save changes?",
        "About to make the following changes to your Backloggery account:\n"
        .."  "..deleted.." games will be deleted entirely\n"
        .."  "..changed.." games will have their information edited\n"
        .."  "..unchanged.." games will be left untouched.\nProceed?",
        "OK", "Cancel")
    then
        return
    end
    
    table.foreach(bledit.games(), function(_, game)
        if game._delete then
            print("delete", game.name, bledit.cookie():deletegame(game.id))
            
        elseif game._dirty then
            print("edit", game.name)
        end
    end)
    
    bledit.loadGames()
end

function controls.gamelist:selection_cb(id, status)
    local game = iup.TreeGetUserId(controls.gamelist, id)
    if not game then
        -- there's no game associated with this id
    elseif status == 1 then
        -- we selected a new game - load it into the fields
        -- if we were editing another game, save that one first
        if fields.game and fields.game._dirty then
            gui.saveFields(fields.game)
        end
        
        gui.loadFields(game)
        controls.nrof_selected = controls.nrof_selected +1
    else
        -- we deselected a game - do nothing
        controls.nrof_selected = controls.nrof_selected -1
        gui.editable(false)
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
    iup.Alarm(title, message, "OK")
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

function gui.editable(on)
    controls.editpane.active = on and "YES" or "NO"
end


function iup:GetType()
    local t = tostring(self):match("IUP%((.*)%)")
    if not t then
        return type(self)
    else
        return "iup_"..t
    end
end

-- mapping between GUI widgets and game info struct fields
local fieldmap = {
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
        if self.writemap then
            value = self.writemap[value] or value
        end
        
        if not value then
            table.map(self, function(w) w.value = "OFF" end)
        elseif self[value] then
            self[value].value = "ON"
        else
            gui.warn("Display Game", "Couldn't set table:\n"..debug.traceback())
        end
    end
    
    
    for field,widget in pairs(fieldmap) do
        if set[iup.GetType(widget)] then
            set[iup.GetType(widget)](widget, game[field])
        else
            print("Warning: couldn't load/set field", field, game[field], iup.GetType(widget))
        end
    end
    
    fields.game = game
    
    gui.editable(game._dirty)
end

function gui.saveFields(game)
    local get = {}
    
    function get:iup_text()
        return self.value
    end
    
    function get:iup_list()
        if self.value == 0 then
            return ""
        else
            return self[self.value]
        end
    end
    
    function get:table()
        for i,widget in ipairs(self) do
            if widget.value == "ON" then
                if self.readmap then
                    i = self.readmap[i] or i
                end
                return i
            end
        end
        return nil
    end
    
    for field,widget in pairs(fieldmap) do
        if get[iup.GetType(widget)] then
            game[field] = get[iup.GetType(widget)](widget)
        else
            print("Warning: couldn't read field", field, game[field], iup.GetType(widget))
        end
    end
end

return gui
