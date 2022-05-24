--- Mod entry point for the CreativeMode Mod. 
-- @author SirLich

-- Module setup
local creativeMode = {}

-- Sapiens
local keyCodes = mjrequire "mainThread/keyMapping".keyCodes
local timer = mjrequire "common/timer"

-- Hammerstone
local localeManager = mjrequire "hammerstone/locale/localeManager"
local inputManager = mjrequire "hammerstone/input/inputManager"
local uiManager = mjrequire "hammerstone/ui/uiManager"
local saveState = mjrequire "hammerstone/state/saveState"

-- Creative Mode
local cheat = mjrequire "creativeMode/cheat" -- Not really used, but we need to import so the global is exposed.
local cheatUI = mjrequire "creativeMode/cheatUI"


-- CreativeMode entrypoint, called by shadowing 'controller.lua' in the main thread.
function creativeMode:init()
	mj:log("Initializing CreativeMode Mod...")

    localeManager:addInputGroupMapping("creativeMode", "Creative Mode")
    localeManager:addInputKeyMapping("creativeMode", "toggleMenu", "Toggle Menu")

    inputManager:addGroup("creativeMode")
    inputManager:addMapping("creativeMode", "toggleMenu", keyCodes.period, nil)

    inputManager:addKeyChangedCallback("creativeMode", "toggleMenu", function (isDown, isRepeat)
        if cheatUI.view then
            cheatUI.view.hidden = not cheatUI.view.hidden
        end
    end)

    -- Register the cheatUI to the UIManager
    uiManager:registerGameElement(cheatUI);

    local testActionUI = mjrequire "creativeMode/actions/testActionUI"
    uiManager:registerActionElement(testActionUI);

    creativeMode:reapplySaveState()
end

function creativeMode:reapplySaveState()
    -- TODO: Doing timers like this is a stupid way to handle ordering.
    timer:addCallbackTimer(2, function()
        -- Restore state
        if saveState:get("instantBuild", false) then
            cheat:EnableInstantBuild()
        end
    end)
end

-- Module return
return creativeMode
