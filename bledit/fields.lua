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
        
        readmap = {
            [6] = 8;
        };
        writemap = {
            [8] = 6;
        };
    };
    comments = iup.text { expand = "YES"; multiline = "YES" };
}

return fields