return function()
    local mt = {}
    
    function mt:__index(key)
        if key == "TEXT" then
            return table.concat(self)
        end
        if rawget(self, "_attr") and self._attr[key] then
            return self._attr[key]
        end
        for _,child in ipairs(self) do
            if child._name == key then
                return child
            end
        end
        return nil
    end
    
    local obj = {}
    obj.options = {commentNode=1,piNode=1,dtdNode=1,declNode=1}
    
    obj.root = setmetatable({ _type = "ROOT" }, mt)
    obj.current = obj.root
    
    obj.starttag = function(self,t,a)
        local node = {
            _type = 'ELEMENT';
            _name = t;
            _attr = a;
            _parent = self.current;
        }
        setmetatable(node, mt)
        table.insert(self.current, node)
        self.current = node
    end
    
    obj.endtag = function(self,t,s)
        if t ~= self.current._name then
            error("XML Error - Unmatched Tag ["..s..":"..t.."]\n")
        end
        self.current = self.current._parent
    end
    
    obj.text = function(self, t)
        table.insert(self.current, t)
    end
    
    obj.cdata = obj.text

    return obj
end
