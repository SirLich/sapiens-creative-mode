--- CreativeMode: testActionUI
--- @author SirLich

local actions = {}

-- Sapiens 
local gameObject = mjrequire "common/gameObject"
local flora = mjrequire "common/flora"
local logicInterface = mjrequire "mainThread/logicInterface"

-- Math
local mjm = mjrequire "common/mjm"
local vec3 = mjm.vec3
local vec2 = mjm.vec2

-- ==========================================================================================
-- deleteAction
-- ==========================================================================================

local deleteAction = {
	iconModelName = 'icon_cancel_thic'
}

function deleteAction:getName(baseObjectInfo, multiSelectAllObjects, lookAtPos)
	local baseName = 'Game Object'
	local typeName = 'Unknown'

	local gameObjectType = gameObject.types[baseObjectInfo.objectTypeIndex]
	if gameObjectType.name then
		baseName = gameObjectType.name
		typeName = baseName
	end

	if baseObjectInfo.name then
		baseName = baseObjectInfo.name
	end

	if baseObjectInfo.sharedState and baseObjectInfo.sharedState.name then
		baseName = baseObjectInfo.sharedState.name
	end


	if #multiSelectAllObjects == 1 then
		return "Remove " .. baseName
	else
		return "Remove " ..  typeName .. " (" .. #multiSelectAllObjects .. ")"
	end
end

function deleteAction:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos)
	return true
end

function deleteAction:onClick(baseObjectInfo, multiSelectAllObjects, lookAtPos)

	mj:log(baseObjectInfo)
	mj:log(multiSelectAllObjects)

	for i,element in ipairs(multiSelectAllObjects) do
		logicInterface:callServerFunction("removeGameObject", element.uniqueID)
	end
end

actions.deleteAction = deleteAction

-- ==========================================================================================
-- Print Action
-- ==========================================================================================

local printAction = {
	iconModelName = 'icon_craft',
	name = 'Print Debug Information'
}

function printAction:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos)
	return false
end

function printAction:onClick(baseObjectInfo, multiSelectAllObjects, lookAtPos)

	mj:log("Base: ", baseObjectInfo)
	mj:log("Multi: ", multiSelectAllObjects)
end

actions.printAction = printAction

-- ==========================================================================================
-- Force Grow Actions
-- ==========================================================================================

local forceGrowAction = {
	iconModelName = 'icon_plant',
	name = 'Instantly Grow'
}

function forceGrowAction:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos)
	return baseObjectInfo.sharedState and baseObjectInfo.sharedState.matureTime
end

function forceGrowAction:onClick(object, multiSelectAllObjects, lookAtPos)

	for i,element in ipairs(multiSelectAllObjects) do
		local prevObjectTypeIndex = element.objectTypeIndex
		local gameObjectType = gameObject.types[element.objectTypeIndex]
		local floraInfo = flora.types[gameObjectType.floraTypeIndex]
		local saplingGameObjectTypeKey = floraInfo.saplingGameObjectTypeKey
		local saplingGameObjectTypeIndex = gameObject.types[saplingGameObjectTypeKey].index
	
		local saplingObjectTypeIndex = element.objectTypeIndex
		local gameObjectType = gameObject.types[saplingObjectTypeIndex]
	
		if gameObjectType.floraTypeIndex then
			local floraInfo = flora.types[gameObjectType.floraTypeIndex]
			local newTypeIndex = floraInfo.gameObjectTypeIndex
			if newTypeIndex ~= saplingObjectTypeIndex then
				logicInterface:callServerFunction("changeGameObject", {
					objectID = element.uniqueID,
					newTypeIndex = newTypeIndex
				})
			end
		end
	end
end

actions.forceGrowAction = forceGrowAction

return actions