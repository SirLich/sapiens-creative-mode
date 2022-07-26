--- CreativeMode: constructableUIHelper.lua
--- @author SirLich

local mod = {
	loadOrder = 1
}

-- Sapiens
local mj = mjrequire "common/mj"

local function isUIUnlocked()
	local saveState = mjrequire "hammerstone/state/saveState"
	return saveState:getValueClient('cm.uiUnlocked')
end

function mod:onload(constructableUIHelper)

	-- Shadow checkHasSeenRequiredResources
	local super_checkHasSeenRequiredResources = constructableUIHelper.checkHasSeenRequiredResources
	constructableUIHelper.checkHasSeenRequiredResources = function(self, constructableType, missingResourceGroups)
		return isUIUnlocked() or super_checkHasSeenRequiredResources(self, constructableType, missingResourceGroups)
	end
	
	-- Shadow checkHasSeenRequiredTools
	local super_checkHasSeenRequiredTools = constructableUIHelper.checkHasSeenRequiredTools
	constructableUIHelper.checkHasSeenRequiredTools = function(self, constructableType, missingTools)
		return isUIUnlocked() or super_checkHasSeenRequiredTools(self, constructableType, missingTools)
	end
end

return mod