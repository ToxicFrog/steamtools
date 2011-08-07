local steam = require "steamlib"

for id,name in pairs(steam.games(...)) do
    print(id, name)
end
