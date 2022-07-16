--- Mod entry point for the CreativeMode Mod.
-- Can be considered as the 'main' file of the mod.
-- @author SirLich

local creativeMode = {
    clientState = nil
}

-- Base
local timer = mjrequire "common/timer"

-- Hammerstone
local uiManager = mjrequire "hammerstone/ui/uiManager"
local saveState = mjrequire "hammerstone/state/saveState"

-- Creative Mode
local cheat = mjrequire "creativeMode/cheat" -- Not really used, but we need to import so the global is exposed.
local settingsUI = mjrequire "creativeMode/settingsUI"


-- CreativeMode entrypoint, called by shadowing 'controller.lua' in the main thread.
function creativeMode:init(clientState)
	mj:log("Initializing CreativeMode Mod...")

    creativeMode.clientState = clientState

    uiManager:registerManageElement(settingsUI);

    cheat:setClientState(clientState)

    timer:addCallbackTimer(3, function()
        -- Restore state
        if saveState:getValueClient('instantBuild') then
            cheat:EnableInstantBuild()
        end
    end)

end


-- Module return
return creativeMode
