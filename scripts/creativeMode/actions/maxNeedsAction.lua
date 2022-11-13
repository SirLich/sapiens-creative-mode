--- CreativeMode: maxNeedsAction.lua
--- @author SirLich

local maxNeedsAction = {
	iconModelName = 'icon_happy'
}

-- Sapiens 
local gameObject = mjrequire "common/gameObject"
local logger = mjrequire "hammerstone/logging"
local statusEffect = mjrequire "common/statusEffect"
local mood = mjrequire "common/mood"
local need = mjrequire "common/need"

-- Math
local mjm = mjrequire "common/mjm"
local vec3 = mjm.vec3
local vec2 = mjm.vec2

function maxNeedsAction:getName(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	local name = baseObjectInfo.sharedState.name

	if #multiSelectAllObjects > 1 then
		name = 'your Sapiens'
	end

	return "Make " .. name .. " happy."
end

function maxNeedsAction:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	return not isTerrain and gameObject.types[baseObjectInfo.objectTypeIndex].key == 'sapien'
end

function maxNeedsAction:onClick(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	for i,element in ipairs(multiSelectAllObjects) do
		logger:log("maxing element:")
		logger:log(element)
		local sharedState = element.sharedState
		if sharedState and sharedState.needs then
			for j,needType in ipairs(need.validTypes) do
				logger:log("maxing need type:")
				logger:log(needType)
				sharedState:set("needs", needType.index, 0.0)
			end
			for j,moodType in ipairs(mood.validTypes) do
				logger:log("maxing mood type:")
				logger:log(moodType)
				local maxLevel = getTableSize(moodType.descriptions)
				logger:log(maxLevel)
				sharedState:set("moods", moodType.index, maxLevel)
			end
		end
		sharedState:set("statusEffects", {})
	end
end

function getTableSize(table)
	local count = 0
	for i, key in ipairs(table) do
		count = count + 1
	end
	return count
end

return maxNeedsAction
