function main()
    require "libbl"
    require "util.init"
    require "config"

    CONFIG = config.load("steamtools.cfg")
    
    print("!!! WARNING !!!")
    print("This program will ERASE ALL ENTRIES from your Backloggery account!")
    print("If you want to proceed, PERMANENTLY DELETING ALL GAMES ON YOUR BACKLOGGERY, type 'yes'")
    print("Otherwise, type 'no' or just close this window and walk away.")
    
    io.printf("yes/no? ")
    
    local yes = false
    for line in io.lines() do
      if line:lower():trim() == "yes" then
        yes = true
        break
      elseif line:lower():trim() == "no" then
        break
      end
      io.printf("yes/no? ")
    end
    if not yes then os.exit(0) end
    
    local user = CONFIG.USER or io.prompt("Backloggery username: ")
    local pass = CONFIG.PASS or io.prompt("Backloggery password: ")
    
    local cookie,err = bl.login(user,pass)
    
    if not cookie then
        io.eprintf("Couldn't log in: %s\n", err)
        return 1
    else
        io.printf("Logged in to Backloggery as %s.\n\n", user)
    end

    io.printf("Loading Backloggery game lists:"); io.flush()
    io.printf(" games"); io.flush(); cookie:games()
    io.printf(" done.\n\n")

    local games = {}
    for _,game in pairs(cookie:games()) do
        games[#games+1] = game
    end
    
    table.sort(games, L "x,y -> x.name < y.name")
    
    for _,game in ipairs(games) do
      io.printf("Delete: %s\n", game.name)
      cookie:deletegame(game.id)
    end
end

require "app"; main(...)
