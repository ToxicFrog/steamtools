---
--  Overview:
--  =========
--      Standard XML event handler(s) for XML parser module (xml.lua)
--  
--  Features:
--  =========
--      printHandler        - Generate XML event trace
--      domHandler          - Generate DOM-like node tree
--      simpleTreeHandler   - Generate 'simple' node tree
--  
--  API:
--  ====
--      Must be called as handler function from xmlParser
--      and implement XML event callbacks (see xmlParser.lua 
--      for callback API definition)
--
--      printHandler:
--      -------------
--
--      printHandler prints event trace for debugging
--
--      domHandler:
--      -----------
--
--      domHandler generates a DOM-like node tree  structure with 
--      a single ROOT node parent - each node is a table comprising 
--      fields below.
--  
--      node = { _name = <Element Name>,
--              _type = ROOT|ELEMENT|TEXT|COMMENT|PI|DECL|DTD,
--              _attr = { Node attributes - see callback API },
--              _parent = <Parent Node>
--              _children = { List of child nodes - ROOT/NODE only }
--            }
--
--      The dom structure is capable of representing any valid XML document
--
--      simpleTreeHandler
--      -----------------
--
--      simpleTreeHandler is a simplified handler which attempts 
--      to generate a more 'natural' table based structure which
--      supports many common XML formats. 
--      
--      The XML tree structure is mapped directly into a recursive
--      table structure with node names as keys and child elements
--      as either a table of values or directly as a string value
--      for text. Where there is only a single child element this
--      is inserted as a named key - if there are multiple
--      elements these are inserted as a vector (in some cases it
--      may be preferable to always insert elements as a vector
--      which can be specified on a per element basis in the
--      options).  Attributes are inserted as a child element with
--      a key of '_attr'. 
--      
--      Only Tag/Text & CDATA elements are processed - all others
--      are ignored.
--      
--      This format has some limitations - primarily
--  
--      * Mixed-Content behaves unpredictably - the relationship 
--        between text elements and embedded tags is lost and 
--        multiple levels of mixed content does not work
--      * If a leaf element has both a text element and attributes
--        then the text must be accessed through a vector (to
--        provide a container for the attribute)
--
--      In general however this format is relatively useful. 
--
--      It is much easier to understand by running some test
--      data through 'textxml.lua -simpletree' than to read this)
--
--  Options
--  =======
--      simpleTreeHandler.options.noReduce = { <tag> = bool,.. }
--
--          - Nodes not to reduce children vector even if only 
--            one child
--
--      domHandler.options.(comment|pi|dtd|decl)Node = bool 
--          
--          - Include/exclude given node types
--  
--  Usage
--  =====
--      Pased as delegate in xmlParser constructor and called 
--      as callback by xmlParser:parse(xml) method.
--
--      See textxml.lua for examples
--  License:
--  ========
--
--      This code is freely distributable under the terms of the Lua license
--      (<a href="http://www.lua.org/copyright.html">http://www.lua.org/copyright.html</a>)
--
--  History
--  =======
--  $Id: handler.lua,v 1.1.1.1 2001/11/28 06:11:33 paulc Exp $
--
--  $Log: handler.lua,v $
--  Revision 1.1.1.1  2001/11/28 06:11:33  paulc
--  Initial Import
--@author Paul Chakravarti (paulc@passtheaardvark.com)<p/>
        
---Handler to generate a simple event trace
return function()
    local obj = {}
    obj.starttag = function(self,t,a,s,e) 
        io.write("Start    : "..t.."\n") 
        if a then 
            for k,v in pairs(a) do 
                io.write(string.format(" + %s='%s'\n",k,v))
            end 
        end
    end
    obj.endtag = function(self,t,s,e) 
        io.write("End      : "..t.."\n") 
    end
    obj.text = function(self,t,s,e)
        io.write("Text     : "..t.."\n") 
    end
    obj.cdata = function(self,t,s,e)
        io.write("CDATA    : "..t.."\n") 
    end
    obj.comment = function(self,t,s,e)
        io.write("Comment  : "..t.."\n") 
    end
    obj.dtd = function(self,t,a,s,e)     
        io.write("DTD      : "..t.."\n") 
        if a then 
            for k,v in pairs(a) do 
                io.write(string.format(" + %s='%s'\n",k,v))
            end 
        end
    end
    obj.pi = function(self,t,a,s,e) 
        io.write("PI       : "..t.."\n")
        if a then 
            for k,v in pairs(a) do 
               io. write(string.format(" + %s='%s'\n",k,v))
            end 
        end
    end
    obj.decl = function(self,t,a,s,e) 
        io.write("XML Decl : "..t.."\n")
        if a then 
            for k,v in pairs(a) do 
                io.write(string.format(" + %s='%s'\n",k,v))
            end 
        end
    end
    return obj
end
