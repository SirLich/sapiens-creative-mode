--- CreativeMode: actions.lua
--- @author SirLich

local actions = {}

--- Sapiens 
local gameObject = mjrequire "common/gameObject"
local flora = mjrequire "common/flora"
local logicInterface = mjrequire "mainThread/logicInterface"
local logger = mjrequire "hammerstone/logging"
local gameState = mjrequire "hammerstone/state/gameState"
--- Math
local mjm = mjrequire "common/mjm"
local vec3 = mjm.vec3
local vec2 = mjm.vec2

--- ==========================================================================================
--- deleteAction
--- ==========================================================================================

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

function deleteAction:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	return not isTerrain
end

function deleteAction:onClick(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	local tribeID =  gameState.world:getTribeID()
	for i,element in ipairs(multiSelectAllObjects) do
		--- ****************************************************************
		--- @author death-rae "Rae"
		--- if the object is a sapien, we want to use a different method
		if gameObject.types[baseObjectInfo.objectTypeIndex].key == 'sapien' then
			logicInterface:callServerFunction("removeSapienObject", {element, tribeID, true, nil})
		else
			logicInterface:callServerFunction("removeGameObject", {element, tribeID})
		end
		--- ****************************************************************
	end
end

actions.deleteAction = deleteAction

--- ==========================================================================================
--- Print Action
--- ==========================================================================================

local printAction = {
	iconModelName = 'icon_craft',
	name = 'Print Debug Information'
}

function printAction:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	return false
end

function printAction:onClick(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)

	mj:log("Base: ", baseObjectInfo)
	mj:log("Multi: ", multiSelectAllObjects)
end

actions.printAction = printAction

--- ==========================================================================================
--- Force Grow Actions
--- ==========================================================================================

local forceGrowAction = {
	iconModelName = 'icon_plant',
	name = 'Instantly Grow'
}

function forceGrowAction:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	return not isTerrain and baseObjectInfo.sharedState and baseObjectInfo.sharedState.matureTime
end

function forceGrowAction:onClick(object, multiSelectAllObjects, lookAtPos)
	--- ****************************************************************
	--- @author death-rae "Rae"
	--- updated this to call the new function in server.lua
	logicInterface:callServerFunction("growPlant", multiSelectAllObjects)
	--- ****************************************************************
end

actions.forceGrowAction = forceGrowAction



--- ****************************************************************
--- @author death-rae "Rae"
--- added a force replenish action to spawn harvestables on an object
--- ****************************************************************

-- ==========================================================================================
-- Force Harvest / Replenish Actions
-- ==========================================================================================

local forceReplenishtAction = {
	iconModelName = 'icon_plant',
	name = 'Instantly Replenish'
}

function forceReplenishtAction:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	return not isTerrain and baseObjectInfo.sharedState and gameObject.types[baseObjectInfo.objectTypeIndex].floraTypeIndex
	--baseObjectInfo.sharedState.mature
end

function forceReplenishtAction:onClick(baseObjectInfo, multiSelectAllObjects, lookAtPos)
		logger:log("replenishing harvest")
		logicInterface:callServerFunction("replenishPlant", multiSelectAllObjects)

end

actions.forceReplenishtAction = forceReplenishtAction
--- ****************************************************************
--- END Rae's changes
--- ****************************************************************


return actions