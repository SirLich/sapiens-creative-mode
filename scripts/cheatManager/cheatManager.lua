--- Mod entry point for the Cheat Manager. Currently this file is hydrated by
-- shadowing 'controller.lua' in the main thread.
-- @author SirLich

-- Module setup
local cheatManager = {}

-- Includes
local uiManager = mjrequire "erectus/ui/uiManager"
local cheatUI = mjrequire "cheatManager/cheatUI"

-- CheatManager entrypoint, called by shadowing 'controller.lua' in the main thread.
function cheatManager:init()
	mj:log("Initializing Cheat Manager Mod.")
	
	-- Register the cheatUI to the UIManager
	uiManager.registerGameView(cheatUI);

	mj:log("Cheat Manager Mod Initialized.")
end

-- Module return
return cheatManager