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

local function toggle(text, image, both)
    if LINUX and both then
        return iup.hbox {
            alignment = "ACENTER";
            
            iup.toggle { image = image; };
            iup.label { title = text; };
        };
    elseif LINUX then
        return iup.toggle { image = image; }
    else
        return iup.toggle { text = text; }
    end
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
        toggle("Owned", "images/own_owned.bmp", true);
        toggle("Formerly Owned", "images/own_ghost.bmp", true);
        toggle("Borrowed/Rented", "images/own_borrow.bmp", true);
        toggle("Other", "images/own_other.bmp", true);
    };
    
    -- progress
    status = {
        toggle("Unfinished", "images/unfinished.bmp", true);
        toggle("Beaten", "images/beaten.bmp", true);
        toggle("Completed", "images/completed.bmp", true);
        toggle("Mastered", "images/mastered.bmp", true);
        toggle("Null", "images/null.bmp", true);
    };
    achievements = iup.text { size = "30x"; spin = "YES"; spinmax = 999; };
    max_achievements = iup.text { size = "30x"; spin = "YES"; spinmax = 999; };
    notes = iup.text { expand = "HORIZONTAL" };
    online_info = iup.text { expand = "HORIZONTAL" };
    
    -- review
    rating = {
        toggle("5 Stars", "images/5_5stars.bmp");
        toggle("4 Stars", "images/4_5stars.bmp");
        toggle("3 Stars", "images/3_5stars.bmp");
        toggle("2 Stars", "images/2_5stars.bmp");
        toggle("1 Star", "images/1_5stars.bmp");
        iup.toggle { title = "No Rating" };
        
        readmap = { 5, 4, 3, 2, 1, 0 };
        writemap = { [0] = 6, 5, 4, 3, 2, 1 };
    };
    comments = iup.text { expand = "YES"; multiline = "YES"; wordwrap = "YES" };
}

return fields
