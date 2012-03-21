require "util.init"

local dom = require "xml.easyDOMHandler" ()
local xml = require "xml.xml" (dom)

xml:parse(io.read("*a"))

local games = {}

for _,xgame in ipairs(dom.root.gamesList.games) do
    local game = {}
    for _,key in ipairs(xgame) do
        game[key._name] = key.TEXT
    end
    table.insert(games, game)
end

for _,game in ipairs(games) do
    print(game.name)
end