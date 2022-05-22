--- Mod entry point for the CreativeMode Mod. 
-- @author SirLich

-- Module setup
local creativeMode = {}

-- Includes
local uiManager = mjrequire "hammerstone/ui/uiManager"
local cheatUI = mjrequire "creativeMode/cheatUI"
local inputManager = mjrequire "hammerstone/input/inputManager"
local keyCodes = mjrequire "mainThread/keyMapping".keyCodes
local localeManager = mjrequire "hammerstone/locale/localeManager"

-- CreativeMode entrypoint, called by shadowing 'controller.lua' in the main thread.
function creativeMode:init()
	mj:log("Initializing CreativeMode Mod...")

    localeManager:addInputGroupMapping("creativeMode", "Creative Mode")
    localeManager:addInputKeyMapping("creativeMode", "toggleMenu", "Toggle Menu")

    inputManager:addGroup("creativeMode")
    inputManager:addMapping("creativeMode", "toggleMenu", keyCodes.period, nil)
    inputManager:addMapping("creativeMode", "toggleMenu2", keyCodes.kp_period, nil)

    inputManager:addKeyChangedCallback("creativeMode", "toggleMenu", function (isDown, isRepeat)
        if cheatUI.view then
            cheatUI.view.hidden = not cheatUI.view.hidden
        end
    end)

    -- Register the cheatUI to the UIManager
    uiManager:registerGameElement(cheatUI);

    local testActionUI = mjrequire "creativeMode/actions/testActionUI"
    uiManager:registerActionElement(testActionUI);


end

-- Module return
return creativeMode
