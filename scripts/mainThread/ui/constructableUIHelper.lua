--- CreativeMode: constructableUIHelper.lua
--- @author SirLich

local mod = {
	loadOrder = 1
}

-- Base
local mj = mjrequire "common/mj"

local function isUIUnlocked()
	local saveState = mjrequire "hammerstone/state/saveState"
	return saveState:getValueClient('cm.uiUnlocked')
end

function mod:onload(constructableUIHelper)

	-- Shadow checkHasSeenRequiredResources
	local super_CheckHasSeenRequiredResources = constructableUIHelper.checkHasSeenRequiredResources
	constructableUIHelper.checkHasSeenRequiredResources = function(self, constructableType, missingResourceGroups)
		return isUIUnlocked() or super_CheckHasSeenRequiredResources(self, constructableType, missingResourceGroups)
	end
	
	-- Shadow checkHasSeenRequiredTools
	local superCheckHasSeenRequiredTools = constructableUIHelper.checkHasSeenRequiredTools
	constructableUIHelper.checkHasSeenRequiredTools = function(self, constructableType, missingTools)
		return isUIUnlocked() or superCheckHasSeenRequiredTools(self, constructableType, missingTools)
	end
end

return mod