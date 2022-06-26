--- Mod entry point for the CreativeMode Mod.
-- Can be considered as the 'main' file of the mod.
-- @author SirLich

local creativeMode = {}

-- Base
local keyCodes = mjrequire "mainThread/keyMapping".keyCodes
local timer = mjrequire "common/timer"

-- Hammerstone
local localeManager = mjrequire "hammerstone/locale/localeManager"
local inputManager = mjrequire "hammerstone/input/inputManager"
local uiManager = mjrequire "hammerstone/ui/uiManager"
local saveState = mjrequire "hammerstone/state/saveState"

-- Creative Mode
local cheat = mjrequire "creativeMode/cheat" -- Not really used, but we need to import so the global is exposed.
local settingsUI = mjrequire "creativeMode/settingsUI"


-- CreativeMode entrypoint, called by shadowing 'controller.lua' in the main thread.
function creativeMode:init()
	mj:log("Initializing CreativeMode Mod...")

    localeManager:addInputGroupMapping("creativeMode", "Creative Mode")
    localeManager:addInputKeyMapping("creativeMode", "toggleMenu", "Toggle Menu")

    inputManager:addGroup("creativeMode")
    inputManager:addMapping("creativeMode", "toggleMenu", keyCodes.period, nil)

    uiManager:registerManageElement(settingsUI);
end


-- Module return
return creativeMode
