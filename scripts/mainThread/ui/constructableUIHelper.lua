--- Shadow of constructableUIHelperlua
--- Used to allow the 'instant build' flag to unlock all buildables.
-- @author SirLich

local mod = {
	loadOrder = 1
}

-- Base
local mj = mjrequire "common/mj"

-- Hammerstone
local saveState = mjrequire "hammerstone/state/saveState"

function mod:onload(constructableUIHelper)

	-- Shadow checkHasSeenRequiredResources
	local super_CheckHasSeenRequiredResources = constructableUIHelper.checkHasSeenRequiredResources
	constructableUIHelper.checkHasSeenRequiredResources = function(self, constructableType, missingResourceGroups)
		if saveState:getWorldValue("instantBuild", false) == true then
			return true
		else
			super_CheckHasSeenRequiredResources(self, constructableType, missingResourceGroups)
		end
	end
	
	-- Shadow checkHasSeenRequiredTools
	local superCheckHasSeenRequiredTools = constructableUIHelper.checkHasSeenRequiredTools
	constructableUIHelper.checkHasSeenRequiredTools = function(self, constructableType, missingTools)
		if saveState:getWorldValue("instantBuild", false) == true then
			return true
		else
			superCheckHasSeenRequiredTools(self, constructableType, missingTools)
		end
	end

end

return mod