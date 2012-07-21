#!/bin/bash
#LIBS="app.lua libbl.lua libsteam.lua libsteam/* xml/*.lua util/* config.lua html.lua lib/*.lua lib/socket/*.lua"
LIBS="app.lua libbl.lua libsteam.lua config.lua html.lua lib xml util libsteam steam2backloggery.lua clearbackloggery.lua"

#rsync -r $LIBS bin/

function mkmain() {
  echo "package.cpath = package.cpath .. ';lib/?.dll'; require '$1'" > main.lua
}

for app in steam2backloggery clearbackloggery; do
  mkmain $app
  enceladus -t ~/bin/enceladus.exe -o $app.exe main.lua
done

rm main.lua
