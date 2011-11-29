At the moment the only programs in here that're really "release-ready" are steam2backloggery and categories.

    CATEGORIES
    
To use it, double-click on categories.lua (or, if you downloaded the windows package, categories.exe). It will prompt you for the location of your Steam install - the easiest way to do this is to drag-and- drop your steam.exe into the window and press enter.

Once you've done that, everything is automatic - it'll figure out your account ID, read your existing category information, and create a new directory (bearing your account name) containing all of the category information - categories are represented as directories, games as files.

From then on, whenever you run it, it will scan this directory and update Steam's category information to match the arrangement of the files. Thus, this directory serves as both an easy way to organize your games on Steam, and as a backup of your categories in case Steam has a crazy and loses them.

Each category directory also contains a file named "category.txt"; if present, its contents override the name of the directory - ie, the category in Steam will be named whatever category.txt says regardless of the directory name. This is necessary for categories that use characters (like ':') that windows does not permit in filenames.

    STEAM2BACKLOGGERY

To use it, just double-click on steam2backloggery.lua. It will prompt you for the location of your Steam install - the easiest way to do this is to drag-and- drop your steam.exe into the window and press enter. It will also ask for your Backloggery username and password.

Once it has this information, it will download your game lists. This may take some time depending on how many games you have, especially on Backloggery; be patient.

Once it has the game lists, it will create a file listing all of the games it's going to add (backloggery.txt) and launch an editor (by default, notepad) to edit it. Instructions for editing it are included in the file.

When you close the editor, it will prompt you for a Backloggery category to use, and then add entries for all of the listed games to Backloggery. It is recommended that you use "PC", "PCDL" (PC Download), or "Steam" as the category, but it won't stop you from filing them under PS2 or SNES or whatever. If you enter a category that Backloggery doesn't support, it'll re-prompt.

There is also a configuration file, "steamtools.cfg", for configuring commonly used settings. The contents of this file should be fairly self- explanatory, but here is brief list of settings you can configure:

    STEAM       Location of Steam.exe
    USER,PASS   Login information for Backloggery
    CONSOLE     Platform (eg, PC, or Steam) to assign to games
    EDITOR      Editor to use for the game list
    IGNORE      Games to ignore

==== NOTES AND LIMITATIONS ====

It won't add a game twice, so it's safe to run this whenever you get new games on Steam.

There is currently no support for Steam categories; all games default to being added as "unfinished" regardless of which category they're in. This is planned for a future version (along with a program to easily reorganize your Steam categories).

It cannot distinguish between normal games, DLC, free trials, and beta tests; all of these will show up in the list. Use of the IGNORE setting in the config file can mitigate this.

:wrap=soft:
