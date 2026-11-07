SETA restored patch (version 1.00, 2026-11-08, game version 9.00)
Author: M.R. Reese

Feedback welcome.

THE PROBLEM
Since game version 9.00 the SETA key (time acceleration) does nothing when you sit in
your personal office chair or at a ship's weapons console. Switching SETA off still works,
and the "Modes" dropdown of the Dock / Ship Interactions menu still works.

WHAT THIS PATCH DOES
While the Dock Interactions or Ship Interactions menu, the Empire Overview (and the other
player info pages) or the map is open at such a seat, the SETA key starts and stops SETA
again, the same way the Modes dropdown does. It uses YOUR SETA key: whatever you set for
"Toggle SETA Mode" in Settings > Controls. The pilot seat is not touched.

SIDE EFFECT
While the Dock / Ship Interactions menu or the Empire Overview is open at a console of a
ship in space, the normal flight keys are off (you cannot fly from a console anyway).

INSTALL
Copy the folder SETA_restored_patch into
  <X4 Foundations>\extensions\
so that content.xml is at <X4 Foundations>\extensions\SETA_restored_patch\content.xml.
Start the game. No new game needed.

REMOVE
Delete the folder. The patch saves nothing in your save game.

COMPATIBILITY
Standalone, no other mod needed. Lua only: it wraps functions of the vanilla Dock / Ship
Interactions menu, the Empire Overview and the map and replaces no game file. A mod that
replaces one of these menus could conflict. The game writes one line
"SETA_restored_patch: ..." to its debug log at start (only with -debug / -logfile).
