--- Mod entry point for the CreativeMode Mod. 
-- @author SirLich

-- Module setup
local creativeMode = {}

-- Includes
local uiManager = mjrequire "hammerstone/ui/uiManager"
local cheatUI = mjrequire "creativeMode/cheatUI"

-- CreativeMode entrypoint, called by shadowing 'controller.lua' in the main thread.
function creativeMode:init()
	mj:log("Initializing CreativeMode Mod...")
	
	-- Register the cheatUI to the UIManager
	uiManager:registerGameElement(cheatUI);

	local testActionUI = mjrequire "creativeMode/actions/testActionUI"
	uiManager:registerActionElement(testActionUI);
end

-- Module return
return creativeMode
