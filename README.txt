Blackwater Lake
Custom Survival map for Black Ops 7 Zombies (Kronos)
by DellxCell (The Hamster)


ABOUT THE MAP

Blackwater Lake is a Custom Survival map set on the lake area of Ashes of the
Damned (zm_sat_firefly). It runs as its own Survival location,
zone_lakefront, and the playable area covers the lakefront, the cabin
and its upper floor, the toolshed, the cliffs, and the paths to the
north and south.

CONTENTS

The Assets, custom_scripts and blackwater_rampage folders mirror the
Kronos install folder (C:\Kronos\cod25\kronos), so every file in them
is already in the place it belongs.

custom_scripts
  zm_blackwater_lake.gsc       Map script source
  zm_blackwater_lake.gscc      Compiled map script (loaded by the game)
  csm_survival.gscc            Kronos file with Blackwater changes

Assets\Lua
  blackwater_intro_post.lua    Loading screen intro
  zm_local_start_post.lua      Kronos launcher with Blackwater changes
  csm_mayhem_relic_post.lua    Kronos file with Blackwater changes
  ui\LUIFPSCounter.lua         Kronos HUD with Blackwater changes

Assets\Images
  blackwater_intro_01.png to blackwater_intro_05.png   Intro images
  blackwater_lake_save.png                             Map and save artwork
  blackwater_lake_save_tile.png                        Save list artwork

blackwater_rampage
  placement.json               Position of the Rampage Inducer (on the
                               barrel by the wall). Required: without
                               it the inducer is not placed there.

Intro Pictures
  The full-size originals of the five intro scenes, numbered in the
  order they appear on the loading screen. These are not needed to
  play the map. They are included in case you want to rebuild the
  intro, for example as a proper loading movie.

    01 - Main cabin.png        4646 x 2160
    02 - Pool room.png         3840 x 2287
    03 - Living room.png       3840 x 2259
    04 - Pyramid.png           3840 x 2282
    05 - Cabin entrance.png    3840 x 4006

  The intro shows each scene for 3 seconds (15 seconds in total) with
  a slow 100-pixel pan, cropped to a 3840 x 2160 frame.


INSTALLATION

1. Close Black Ops 7 and KronosLauncher. The launcher keeps some of the
   image files locked while it is running, so make sure it is fully
   closed.

2. Make a backup of these four files in C:\Kronos\cod25\kronos. They
   are replaced during installation and are needed if you want to
   remove the map later.

     Assets\Lua\zm_local_start_post.lua
     Assets\Lua\csm_mayhem_relic_post.lua
     Assets\Lua\ui\LUIFPSCounter.lua
     custom_scripts\csm_survival.gscc

3. Copy the Assets, custom_scripts and blackwater_rampage folders
   (not Intro Pictures) into C:\Kronos\cod25\kronos. When Windows asks, choose to replace the
   existing files.

4. Launch the game through Kronos as you normally would.

No DLLs or other system files are involved. Everything stays inside
the kronos folder.


PLAYING

The map appears in two places in the Zombies menu:

  Survival          Zombies > Survival > Blackwater Lake
  Cursed Survival   Zombies > Cursed Survival > Blackwater Lake

Each has a Solo option and a Squad option for up to four players.

Please avoid Save & Quit on this map for now. Saving and resuming at
the lake has not been fully tested yet.


REMOVAL

1. Close Black Ops 7 and KronosLauncher.
2. Delete the following files from C:\Kronos\cod25\kronos:

     custom_scripts\zm_blackwater_lake.gsc
     custom_scripts\zm_blackwater_lake.gscc
     Assets\Lua\blackwater_intro_post.lua
     Assets\Images\blackwater_intro_01.png to blackwater_intro_05.png
     Assets\Images\blackwater_lake_save.png
     Assets\Images\blackwater_lake_save_tile.png
     blackwater_rampage\placement.json

3. Restore the four Kronos files you backed up during installation.


INTEGRATION NOTES

Map details

  Map               zm_sat_firefly
  Survival POI      zone_lakefront

  Playlist IDs      1000000200   Survival, Solo           (based on 1000000008)
                    1000000201   Survival, Squad          (based on 1000000009)
                    1000000202   Cursed Survival, Solo    (based on 1000000068)
                    1000000203   Cursed Survival, Squad   (based on 1000000069)

Each Blackwater entry is a copy of the existing record listed next to
it. Only the POI, the play menu card and the artwork are different. No
existing records were modified.

Changes to Kronos files

Four of the included files are existing Kronos files with Blackwater
support added. They were made against the Kronos release from early
November 2026, so we recommend merging the Blackwater sections into
your current versions instead of replacing the files outright. Search
for "Blackwater", "bwl" or "blackwater_lake" to find the relevant
code.

zm_local_start_post.lua
  Adds the four Blackwater playlist entries to the Survival and Cursed
  Survival categories. Displays "Blackwater Lake" in place of "Ashes of
  the Damned" on the map list, lobby card, loading screen and
  scoreboard, but only for Blackwater entries and matches. Sets the
  Blackwater artwork for the menu entry and lobby panel. Labels
  Blackwater saves as "Blackwater Lake - Survival" and applies
  zone_lakefront when one is loaded. Refreshes the Zombies menu
  categories when returning from a match.

ui\LUIFPSCounter.lua
  Adds one condition to hideQuest so the native quest tracker stays
  visible when the map is zm_sat_firefly and the Survival POI is
  zone_lakefront. This is what allows the Restore Power objective to
  appear. All other maps behave exactly as before.

csm_mayhem_relic_post.lua and csm_survival.gscc
  Updated so the Blackwater entries work in Cursed Survival. The
  Mayhem relic's list of allowed entries includes the two Blackwater
  Cursed entries (1000000202 and 1000000203), and the in-match script
  accepts zone_lakefront as a valid location.

Cursed Survival at the lake

The map script moves the Cursed Survival events from their usual
places to the lake:

  - Mr. Peeks appears above the cabin entrance. Shooting him drops an
    egg, and the pickup and reward work as normal.
  - TEDD Tasks use the console at the lake cabin. Starting a task and
    collecting its reward work as normal.

Round chances and rewards are left to the game. These were tested in
Cursed Survival with the Mr. Peeks relic; other relics and other TEDD
task types have not been tested separately.

Loading screen intro

blackwater_intro_post.lua replaces the Ashes of the Damned loading
movie with a 15-second picture intro, but only when Blackwater Lake is
loading. It decides that from the launcher's current request, a
Blackwater save being resumed, or the map being zm_sat_firefly with
the Survival POI set to zone_lakefront. Every other map is left alone.

When the loading screen appears, the script loads the five
blackwater_intro images from Assets\Images and places a full-screen
image directly above the native Bink movie widget. The original movie
keeps playing underneath, and the game's own loading text and hints
stay on top. Each picture is shown for 3 seconds with a slow pan,
then the sequence repeats until loading finishes.

If anything goes wrong (a missing image or an unavailable UI
function), the script removes its image and the normal loading movie
plays as usual. It writes a "k1 bwl intro" line to poi_reg.log when
that happens.

If you would rather use a proper loading movie, the full-size scenes
in the Intro Pictures folder can be used to build one, and this
script can then be dropped.

Known limitations

  - Co-op guests may still see "Ashes of the Damned" on their loading
    screen and scoreboard. The renaming runs on the host's launch, and
    guests don't go through it.
  - Blackwater saves share Kronos's single Ashes of the Damned
    Survival save slot, so saving on one map replaces a save on the
    other.
  - Save & Quit at the lake has not been fully tested.
  - Once, a Cursed Survival match with Mr. Peeks got stuck on a
    looping loading screen. After restarting the game, the same match
    loaded normally. The cause is unknown. If it happens, copy cod25\poi_reg.log before restarting, as
    the restart overwrites it.

Map script

zm_blackwater_lake.gsc is the readable source and
zm_blackwater_lake.gscc is the compiled version the game loads. Please
keep the two together. If the script is recompiled, the encrypted
native strings in the compiled file need to stay byte-for-byte
identical, otherwise the native function calls will fail.

Rampage Inducer position

The map reads the inducer's position from
blackwater_rampage\placement.json when a match starts (x, y, z and
yaw). With a valid position it holds the native Rampage setup briefly
during map startup, places the marker centred on the barrel, then lets
the game's own Rampage initialisation run. If the file is missing or
the values are outside the lake area, the inducer is not placed on the
barrel. Keep this file with the map.

Debugging

During a match the map writes its current state to
C:\Kronos\cod25\kronos\blackwater_lake\runtime.json. With the Kronos
Debug Log option enabled, it also writes lines starting with "k1 bwl"
to cod25\poi_reg.log. Both are useful for confirming that the map
loaded and set up correctly.
