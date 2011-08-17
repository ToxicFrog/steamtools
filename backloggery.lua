function main()
    require "libbl"
    require "util.init"
    
    local user = USER or io.prompt("Backloggery username: ")
    local pass = PASS or io.prompt("Backloggery password: ")
    
    local cookie,err = bl.login(user,pass)
    
    if not cookie then
        io.eprintf("Couldn't log in: %s\n", err)
        return 1
    else
        io.printf("Logged in to Backloggery as %s.\n\n", user)
    end

    io.printf("Loading Backloggery game lists:"); io.flush()
    io.printf(" games"); io.flush(); cookie:games()
    io.printf(" wishlist"); io.flush(); cookie:wishlist()
    io.printf(" done.\n\n")

    local games = {}
    for _,game in pairs(cookie:games()) do
        games[#games+1] = game
    end
    for _,game in pairs(cookie:wishlist()) do
        games[#games+1] = game
    end
    
    table.sort(games, L "x,y -> x.name < y.name")
    
    for _,game in ipairs(games) do
        io.printf("%-10s%-14s%s\n%-24s%s\n", game.console, game.wishlist and "wishlist" or game.complete, game.name, tostring(game.id), game.note)
    end
end

require "app"
