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

When you close notepad, it will read the edited file and create entries for all
of the games listed there in your Backloggery.

==== NOTES AND LIMITATIONS ====

It won't add a game twice, so it's safe to run this whenever you get new games
on Steam.

All games are added with platform "PC" (not "Steam").

There is currently no support for Steam categories; all games default to being
added as "unfinished" regardless of which category they're in. This is planned
for a future version (along with a program to easily reorganize your Steam
categories).

It cannot distinguish between normal games, DLC, free trials, and beta tests;
all of these will show up in the list.

Related to the above, there's no way to permanently ignore a game. This too may
come in a future version.
