-- SETA_restored_patch: SETA key at a seat without a flown ship, e.g. the personal office chair (M.R. Reese 2026-11-08).
-- Version 1.00, for game version 9.00.
--
-- Game 9.00 fault: at the office chair or a ship's weapons console the SETA key sends a wrong 'stopactivity' and the
-- player leaves the control position; from then on SETA cannot start. Only the Modes dropdown of the Dock / Ship
-- Interactions menu still works: while that menu is open, the engine allows SETA, and the dropdown calls
-- C.StartPlayerActivity("seta").
--
-- So the SETA key starts / stops SETA like vanilla menu_map.lua menu.hotkey while one of these vanilla menus is open
-- at a seat without a flown ship:
--   DockedMenu     (Dock Interactions, Ship Interactions of a ship in space)
--   PlayerInfoMenu (Empire Overview and the other player info pages)
--     -> we switch on the map's "modes" key group of ego_detailmonitor (context INPUT_CONTEXT_ADDON_DETAILMONITOR_MODES,
--        which switches off the space context, so the wrong stop cannot fire) and set one hotkey script.
--   MapMenu        (the map registers that group itself; its hotkey starts SETA only with a flown ship)
--     -> we wrap MapMenu.hotkey and start SETA without a ship; everything else goes to vanilla.
-- The key is the ACTION INPUT_ACTION_ADDON_DETAILMONITOR_SETA, not a fixed key: the options menu maps it together
-- with "Toggle SETA Mode" (gameoptions.lua controlFunctions, actions 225 + 323), so the player's own SETA key works.
-- Hooks: we WRAP onShowMenu / cleanup of DockedMenu and PlayerInfoMenu and MapMenu.hotkey (vanilla runs unchanged),
-- nothing replaced. Not touched: the pilot seat (vanilla handles the key there).
-- Loaded by ui.xml (environment "menus"). Log lines start with "SETA_restored_patch:".

local ffi = require("ffi")
local C = ffi.C
-- same declarations as vanilla menu_docked.lua / menu_map.lua
ffi.cdef[[
	typedef uint64_t UniverseID;
	bool CanActivateSeta(bool checkcomponentclass);
	void StartPlayerActivity(const char* activityid);
	void StopPlayerActivity(const char* activityid);
	UniverseID GetPlayerOccupiedShipID(void);
	void TriggerInputFeedback(const char* type, const char* action, const char* feedbackid, const char* params);
]]

local SETA = "INPUT_ACTION_ADDON_DETAILMONITOR_SETA"

local users = {}          -- open menus (by name) for which we switched the "modes" group and our script on
local scriptOn = false    -- our one hotkey script is set (one script for all menus: one key press = one toggle)

local function noShip()
	return ConvertStringTo64Bit(tostring(C.GetPlayerOccupiedShipID())) == 0
end

local function mapShown()
	local map = Helper.getMenu("MapMenu")
	return map and map.shown
end

local function startSeta()
	if C.CanActivateSeta(false) then
		C.StartPlayerActivity("seta")
		C.TriggerInputFeedback("action", SETA, "active", "")
	else
		DebugError("SETA_restored_patch: SETA key, but the game allows no SETA here")
	end
end

-- the SETA key in the docked menu and the player info menus; same logic as vanilla menu_map.lua menu.hotkey
local function onHotkey(action)
	-- with a flown ship vanilla handles the key; while the map is open, its hotkey (wrapped below) does
	if action ~= SETA or not noShip() or mapShown() then
		return
	end
	if GetPlayerActivity() == "seta" then
		C.StopPlayerActivity("seta")
		C.TriggerInputFeedback("action", SETA, "inactive", "")
	else
		startSeta()
	end
end

-- after any change: hotkey script and key group as the open menus need them
local function update()
	local any = next(users) ~= nil
	if any and not scriptOn then
		scriptOn = true
		SetScript("onHotkey", onHotkey)
	elseif scriptOn and not any then
		scriptOn = false
		RemoveScript("onHotkey", onHotkey)
	end
	-- registering twice is harmless; vanilla cleanups unregister ALL ego_detailmonitor groups, so register again
	if any then
		RegisterAddonBindings("ego_detailmonitor", "modes")
	end
end

local function leave(name)
	if not users[name] then
		return
	end
	users[name] = nil
	-- the map uses the same group; leave it on if the map is open now
	if next(users) == nil and not mapShown() then
		UnregisterAddonBindings("ego_detailmonitor", "modes")
	end
	update()
end

-- wraps onShowMenu and cleanup of one vanilla menu
local function hookMenu(name)
	local menu = Helper.getMenu(name)
	if not menu then
		DebugError("SETA_restored_patch: " .. name .. " not found, no SETA key there")
		return
	end
	local origShow = menu.onShowMenu
	menu.onShowMenu = function(...)
		local result = origShow(...)
		-- only at a seat without a flown ship: office chair, consoles
		if noShip() then
			users[name] = true
			update()
		end
		return result
	end
	local origCleanup = menu.cleanup
	menu.cleanup = function(...)
		local result = origCleanup(...)
		leave(name)
		-- the vanilla cleanup unregistered all groups: another open menu of ours may still need "modes"
		update()
		return result
	end
end

-- the map: vanilla stops SETA with or without a ship but starts it only with one; we add the start without a ship.
-- The map looks up menu.hotkey when it shows / restores, so the wrapper is used from the next opening on.
local function hookMap()
	local map = Helper.getMenu("MapMenu")
	if not map then
		DebugError("SETA_restored_patch: MapMenu not found, no SETA key on the map")
		return
	end
	local origHotkey = map.hotkey
	map.hotkey = function(action, ...)
		if action == SETA and noShip() and GetPlayerActivity() ~= "seta" then
			startSeta()
			return
		end
		return origHotkey(action, ...)
	end
end

local function init()
	local docked = Helper.getMenu("DockedMenu")
	-- only once, also if the UI is reloaded
	if docked and docked.seta_restored_hooked then
		return
	end
	-- the first test version (and the development copy patch_seta_mod) marked the docked menu so: then it is hooked already
	if docked and docked.patch_seta_onShowMenu then
		DebugError("SETA_restored_patch: an older copy of the patch is loaded too, this one stays off")
		return
	end
	if docked then
		docked.seta_restored_hooked = true
	end
	hookMenu("DockedMenu")
	hookMenu("PlayerInfoMenu")
	hookMap()
	DebugError("SETA_restored_patch: SETA key hooked into Dock / Ship Interactions, Empire Overview and map")
end

init()
