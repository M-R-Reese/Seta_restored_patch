SETA restored patch - ALPHA (version 1, 2026-11-07, game version 9.00)
Author: M.R. Reese

STATUS: ALPHA. Tested only briefly, on one save. Feedback welcome.

THE PROBLEM
Since game version 9.00 the SETA key (time acceleration) does nothing when you sit in
your personal office chair or at a ship's weapons console. Switching SETA off still works,
and the "Modes" dropdown of the Dock / Ship Interactions menu still works.

WHAT THIS PATCH DOES
While the Dock Interactions or Ship Interactions menu is open at such a seat, the SETA key
starts and stops SETA again, the same way the Modes dropdown does. SETA keeps running when
you open the map afterwards. The pilot seat is not touched.

NOT COVERED YET
- The Empire Overview (first screen at the office chair) and the map: there the SETA key
  still does nothing without a ship you fly. Use the Dock Interactions menu.

SIDE EFFECT
While the Dock / Ship Interactions menu is open at a console of a ship in space, the normal
flight keys are off (you cannot fly from a console anyway).

INSTALL
Copy the folder SETA_restored_patch into
  <X4 Foundations>\extensions\
so that content.xml is at <X4 Foundations>\extensions\SETA_restored_patch\content.xml.
Start the game. No new game needed.

REMOVE
Delete the folder. The patch saves nothing in your save game.

COMPATIBILITY
Standalone, no other mod needed. Lua only: it wraps two functions of the vanilla
Dock / Ship Interactions menu and replaces no game file. A mod that replaces that menu
could conflict. The game writes one line "SETA_restored_patch: ..." to its debug log
at start (only with -debug / -logfile).
