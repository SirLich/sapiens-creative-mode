--- Mod entry point for the Cheat Manager. Currently this file is hydrated by
-- shadowing 'controller.lua' in the main thread.
-- @author SirLich

-- Module setup
local cheatManager = {}

-- Includes
local eventManager = mjrequire "erectus/eventManager"
local eventTypes = mjrequire "erectus/eventTypes"
local uiManager = mjrequire "erectus/uiManager"
local cheatUI = mjrequire "cheatManager/cheatUI"

-- Local state
local world = nil

-- CheatManager entrypoint, called by shadowing 'controller.lua' in the main thread.
function cheatManager:init()
	mj:log("Initializing Cheat Manager Mod.")
	
	-- Register the cheatUI to be created on UI Load.
	uiManager.registerGameView(cheatUI);

	mj:log("Cheat Manager Mod Initialized.")
end

-- Module return
return cheatManager