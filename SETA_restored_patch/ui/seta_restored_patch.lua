-- SETA_restored_patch: SETA key at a seat without a flown ship, e.g. the personal office chair (M.R. Reese 2026-11-07).
-- ALPHA, tested only briefly with game version 9.00.
--
-- Game 9.00 fault: at the office chair or a ship's weapons console the SETA key sends a wrong 'stopactivity' and the
-- player leaves the control position; from then on SETA cannot start. Only the Modes dropdown of the Dock / Ship
-- Interactions menu still works: while that menu is open, the engine allows SETA, and the dropdown calls
-- C.StartPlayerActivity("seta").
--
-- So: while the vanilla DockedMenu is open at a seat without a flown ship (mode "docked" = Dock Interactions,
-- "cockpit" = Ship Interactions of a ship in space), we switch on the map's "modes" key group of ego_detailmonitor
-- (context INPUT_CONTEXT_ADDON_DETAILMONITOR_MODES, which switches off the space context, so the wrong stop cannot
-- fire) and handle its SETA key like vanilla menu_map.lua menu.hotkey.
-- Hook: we WRAP DockedMenu.onShowMenu and DockedMenu.cleanup (vanilla runs first, unchanged), nothing replaced.
-- Not touched: the pilot seat. While the menu is open at a console, the space context's keys are off.
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

local docked              -- vanilla DockedMenu table
local active = false      -- our key group and hotkey script are on

-- the SETA key of the "modes" key group; same logic as vanilla menu_map.lua menu.hotkey
local function onHotkey(action)
	if action ~= "INPUT_ACTION_ADDON_DETAILMONITOR_SETA" then
		return
	end
	if GetPlayerActivity() == "seta" then
		C.StopPlayerActivity("seta")
		C.TriggerInputFeedback("action", "INPUT_ACTION_ADDON_DETAILMONITOR_SETA", "inactive", "")
	elseif C.CanActivateSeta(false) then
		C.StartPlayerActivity("seta")
		C.TriggerInputFeedback("action", "INPUT_ACTION_ADDON_DETAILMONITOR_SETA", "active", "")
	end
end

local function switchOff()
	if active then
		active = false
		RemoveScript("onHotkey", onHotkey)
		-- the map registers the same group when it opens; leave it on if the map is open now
		local map = Helper.getMenu("MapMenu")
		if not (map and map.shown) then
			UnregisterAddonBindings("ego_detailmonitor", "modes")
		end
	end
end

local function init()
	docked = Helper.getMenu("DockedMenu")
	if not docked then
		DebugError("SETA_restored_patch: DockedMenu not found, patch inactive")
		return
	end
	-- only once, also if the UI is reloaded; same marker as the development version (patch_seta_mod),
	-- so two installed copies never both react to one key press
	if docked.patch_seta_onShowMenu then
		return
	end

	local origShow = docked.onShowMenu
	docked.patch_seta_onShowMenu = origShow
	docked.onShowMenu = function(...)
		origShow(...)
		-- only at a seat without a flown ship: office chair, consoles
		local noship = ConvertStringTo64Bit(tostring(C.GetPlayerOccupiedShipID())) == 0
		if noship and not active then
			active = true
			RegisterAddonBindings("ego_detailmonitor", "modes")
			SetScript("onHotkey", onHotkey)
		end
	end

	local origCleanup = docked.cleanup
	docked.cleanup = function(...)
		switchOff()
		return origCleanup(...)
	end
	DebugError("SETA_restored_patch: SETA key hooked into the Dock / Ship Interactions menu")
end

init()
