--- CreativeMode: testActionUI
--- @author SirLich

local maxNeedsAction = {}

-- Sapiens 
local gameObject = mjrequire "common/gameObject"
local logicInterface = mjrequire "mainThread/logicInterface"

-- Math
local mjm = mjrequire "common/mjm"
local vec3 = mjm.vec3
local vec2 = mjm.vec2

function maxNeedsAction:getName(baseObjectInfo, multiSelectAllObjects, lookAtPos)
	mj:log(baseObjectInfo)
	return "Max Needs"
end

function maxNeedsAction:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos)
	return gameObject.types[baseObjectInfo.objectTypeIndex].key == 'sapien'
end

function maxNeedsAction:onClick(baseObjectInfo, multiSelectAllObjects, lookAtPos)
	logicInterface:callServerFunction("maxFollowerNeeds", {
		[1] = baseObjectInfo.uniqueID
	})
end

return maxNeedsAction