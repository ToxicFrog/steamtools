rm -rf {categories,app,libsteam}.lua util libsteam
cp -a ../{categories,app,libsteam}.lua ../{util,libsteam} .
./enceladus.exe categories.lua app.lua libsteam.lua socket.lua mime.lua ltn12.lua util/*.lua libsteam/*.lua socket/*.lua
mv categories.lua-enceladus.exe categories.exe
zip categories.zip categories.exe $(find . -name '*.dll')
