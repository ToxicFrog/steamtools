LIBS="app.lua libbl.lua libsteam.lua libsteam/* xml/*.lua util/* config.lua html.lua lib/*.lua lib/socket/*.lua"

enceladus -t ~/bin/enceladus.exe -o embed.exe steam2backloggery.lua app.lua $LIBS
mv steam2backloggery.lua-embed.exe bin/steam2backloggery.exe

enceladus -t ~/bin/enceladus.exe -o embed.exe categories.lua $LIBS
mv categories.lua-embed.exe bin/categories.exe
