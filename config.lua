config = {}

function config.load(file)
    local cfg = {
        EDITOR = "notepad";
        IGNORE = "";
    }
    
    if loadfile(file) then
        local f = loadfile(file)
        setfenv(f, cfg)
        f()
    else
        io.eprintf("Warning: couldn't load %s\n  Error message was: %s\n  Using default configuration\n\n"
            , tostring(file)
            , tostring(select(2, loadfile(file))))
    end
    
    -- build the set of ignore-game patterns
    local patterns = {}
    for pattern in cfg.IGNORE:gmatch("%s*([^\n]+)") do
        pattern = pattern:gsub("%W"
                  , function(c)
                      if c == "*" then
                          return ".*"
                      else
                          return "%"..c
                      end
                  end)
        patterns[#patterns+1] = pattern
    end

    function cfg:ignored(name)
        for _,pattern in ipairs(patterns) do
            if name:match(pattern) then
                return true
            end
        end
        return false
    end
    
    return cfg
end
