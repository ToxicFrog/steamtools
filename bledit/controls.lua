-- the set of all user controls not used for editing game data, as well as
-- feedback controls
local controls = {
    status = iup.label { title = "Not Logged In" };
    new = iup.button { title = "New"; padding = "4x"; active = "NO" };
    edit = iup.button { title = "Edit"; padding = "4x" };
    delete = iup.button { title = "Delete"; padding = "4x" };
    save = iup.button { title = "Save"; padding = "4x" };
    gamelist = iup.tree {
        expand = "YES";
        size = "200x";
        maxsize = "200x";
        markmode = "MULTIPLE";
    };
    nrof_selected = 0;
};

return controls
