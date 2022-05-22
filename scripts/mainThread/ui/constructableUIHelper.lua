-- Module Setup
local mod = {
	loadOrder = 1
}

--Sapiens
local mj = mjrequire "common/mj"

-- Hammerstone
local logger = mjrequire "hammerstone/logging"

function mod:onload(constructableUIHelper)

	-- Shadow checkHasSeenRequiredResources
	local superCheckHasSeenRequiredResources = constructableUIHelper.checkHasSeenRequiredResources
	constructableUIHelper.checkHasSeenRequiredResources = function(self, constructableType, missingResourceGroups)
		if constructableUIHelper.instantBuild == true then
			return true
		else
			superCheckHasSeenRequiredResources(self, constructableType, missingResourceGroups)
		end
	end
	
	-- Shadow checkHasSeenRequiredTools
	local superCheckHasSeenRequiredTools = constructableUIHelper.checkHasSeenRequiredTools
	constructableUIHelper.checkHasSeenRequiredTools = function(self, constructableType, missingTools)
		if constructableUIHelper.instantBuild == true then
			return true
		else
			superCheckHasSeenRequiredTools(self, constructableType, missingTools)
		end
	end

end

-- Module Return
return mod