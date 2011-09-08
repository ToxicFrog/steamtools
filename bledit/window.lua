local fields = require "bledit.fields"
local controls = require "bledit.controls"

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
                                    iup.fill { size = 20 };
                                    fields.ownership[2];
                                    iup.fill { size = 20 };
                                    fields.ownership[3];
                                    iup.fill { size = 20 };
                                    fields.ownership[4];
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
                                    iup.fill { size = 20 };
                                    fields.status[2];
                                    iup.fill { size = 20 };
                                    fields.status[3];
                                    iup.fill { size = 20 };
                                    fields.status[4];
                                    iup.fill { size = 20 };
                                    fields.status[5];
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

return win
