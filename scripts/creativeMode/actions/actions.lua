--- CreativeMode: actions.lua
--- @author SirLich, death-rae

local actions = {}

--- Sapiens 
local gameObject = mjrequire "common/gameObject"
local logicInterface = mjrequire "mainThread/logicInterface"
local gameState = mjrequire "hammerstone/state/gameState"

-- Hammerstone
local saveState = mjrequire "hammerstone/state/saveState"

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

local function showActions()
	return saveState:getValue('cm.showActionButtons')
end

function deleteAction:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	return showActions() and not isTerrain
end

function deleteAction:onClick(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	local type = gameObject.types[baseObjectInfo.objectTypeIndex]
	local tribeID = gameState.world:getTribeID()
	local mobIndex = type.mobTypeIndex

	local paramTable = {
		objects = multiSelectAllObjects,
		tribeID = tribeID
	}
	if type and type.key == 'sapien' then
		logicInterface:callServerFunction("removeSapiens", paramTable)
	elseif mobIndex then
		logicInterface:callServerFunction("removeMobs", paramTable)
	else
		for i,element in ipairs(multiSelectAllObjects) do
			logicInterface:callServerFunction("removeGameObject", element.uniqueID)
		end
	end
end

actions.deleteAction = deleteAction

--- ==========================================================================================
--- Send Notification Action - DISAbLED
--- ==========================================================================================

local notificationAction = {
	iconModelName = 'icon_craft',
	name = 'Send Test Notification'
}

function notificationAction:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	return showActions() and false
end

function notificationAction:onClick(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	local notificationsUI = mjrequire "mainThread/ui/notificationsUI"
	local notification = mjrequire "common/notification"

	notificationsUI:displayObjectNotification({
		typeIndex = notification.types.myNotification.index
	})

	notification:sendQuickNotification("Hello There!", baseObjectInfo, notification.colorTypes.veryBad)
end

actions.notificationAction = notificationAction

--- ==========================================================================================
--- Print Action -- DISAbLED
--- ==========================================================================================

local planAction = {
	iconModelName = 'icon_craft',
	name = 'Queue Test Plan'
}

function planAction:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	return showActions() and false
end

function planAction:onClick(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
end

-- actions.planAction = planAction

--- ==========================================================================================
--- Force Grow Actions
--- ==========================================================================================

local forceGrowAction = {
	iconModelName = 'icon_plant',
	name = 'Instantly Grow'
}

function forceGrowAction:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	return showActions() and not isTerrain and baseObjectInfo.sharedState and baseObjectInfo.sharedState.matureTime
end

function forceGrowAction:onClick(object, multiSelectAllObjects, lookAtPos)
	logicInterface:callServerFunction("growPlants", multiSelectAllObjects)
end

actions.forceGrowAction = forceGrowAction


-- ==========================================================================================
-- Force Harvest / Replenish Actions
-- ==========================================================================================

local forceReplenishtAction = {
	iconModelName = 'icon_plant',
	name = 'Instantly Replenish'
}

function forceReplenishtAction:visibilityFilter(baseObjectInfo, multiSelectAllObjects, lookAtPos, isTerrain)
	return showActions() and not isTerrain and baseObjectInfo.sharedState and gameObject.types[baseObjectInfo.objectTypeIndex].floraTypeIndex
end

function forceReplenishtAction:onClick(baseObjectInfo, multiSelectAllObjects, lookAtPos)
	logicInterface:callServerFunction("replenishPlants", multiSelectAllObjects)
end

actions.forceReplenishtAction = forceReplenishtAction

return actions