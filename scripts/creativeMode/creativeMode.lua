--- creativeMode.lua
--- Mod entry point for the CreativeMode Mod.
--- Can be considered as the 'main' file of the mod.
--- @author SirLich

local creativeMode = {
    clientState = nil
}

-- Sapiens
local timer = mjrequire "common/timer"

-- Hammerstone
local uiManager = mjrequire "hammerstone/ui/uiManager"
local saveState = mjrequire "hammerstone/state/saveState"
local settingsUI = mjrequire "creativeMode/settingsUI"

-- Creative Mode
local c = mjrequire "creativeMode/cheat" -- Not really used, but we need to import so the global is exposed.
local maxNeedsAction = mjrequire "creativeMode/actions/maxNeedsAction"
local actions = mjrequire "creativeMode/actions/actions"

-- CreativeMode entrypoint, called by shadowing 'controller.lua' in the main thread.
function creativeMode:init(clientState)
	mj:log("Initializing CreativeMode Mod...")

    local notification = mjrequire "common/notification"
    notification:addNotificationType("myNotification", {
        colorType = notification.colorTypes.veryBad,
        titleFunction = function(data)
            return "HELLO WORLD!"
        end
    })

    creativeMode.clientState = clientState

    uiManager:registerManageElement(settingsUI);
    uiManager:registerActionElement(maxNeedsAction);

    for k, action in pairs(actions) do
        uiManager:registerActionElement(action);
    end

    cheat:setClientState(clientState)
end

return creativeMode
