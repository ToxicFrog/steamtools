At the moment the only program in here that's really "release-ready" is
steam2backloggery.

To use it, just double-click on steam2backloggery.lua. It will prompt you for
the location of your Steam install - the easiest way to do this is to drag-and-
drop your steam.exe into the window and press enter. It will also ask for your
Backloggery username and password.

Once it has this information, it will download your game lists. This may take
some time depending on how many games you have, especially on Backloggery; be
patient.

Once it has the game lists, it will create a file listing all of the games it's
going to add (backloggery.txt) and launch notepad to edit it. Instructions for
editing it are included in the file. Feel free to use another editor if you
like, but don't close notepad until you're done.

When you close notepad, it will prompt you for a Backloggery category to use,
and then add entries for all of the listed games to Backloggery. It is
recommended that you use "PC", "PCDL" (PC Download), or "Steam" as the category,
but it won't stop you from filing them under PS2 or SNES or whatever. If you
enter a category that Backloggery doesn't support, it'll re-prompt.

There is also a configuration file, "steam2backloggery.cfg", for configuring
commonly used settings. The contents of this file should be fairly self-
explanatory.

==== NOTES AND LIMITATIONS ====

It won't add a game twice, so it's safe to run this whenever you get new games
on Steam.

There is currently no support for Steam categories; all games default to being
added as "unfinished" regardless of which category they're in. This is planned
for a future version (along with a program to easily reorganize your Steam
categories).

It cannot distinguish between normal games, DLC, free trials, and beta tests;
all of these will show up in the list.

Related to the above, there's no way to permanently ignore a game. This may come
in a future version.
