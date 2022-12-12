--- CreativeMode: cheat.lua
--- Globally namespaced cheat commands
--- Made available via requiring in creativeMode.lua
--- @author SirLich

cheat = {
	clientState = nil,
	world = nil
}

-- Sapiens
local mj = mjrequire "common/mj"
local logicInterface = mjrequire "mainThread/logicInterface"
local typeMaps = mjrequire "common/typeMaps"
local skill = mjrequire "common/skill"
local resource = mjrequire "common/resource"

local buildUI = mjrequire "mainThread/ui/manageUI/buildUI"
local placeUI = mjrequire "mainThread/ui/manageUI/placeUI"
local plantUI = mjrequire "mainThread/ui/manageUI/plantUI"
local pathUI = mjrequire "mainThread/ui/manageUI/pathUI"

-- Hammerstone
local gameState = mjrequire "hammerstone/state/gameState"
local logger = mjrequire "hammerstone/logging"
local saveState = mjrequire "hammerstone/state/saveState"

--- ****************************************************************
--- @author death-rae "Rae"
--- added functions to list all resources, and to find a resource by name (partial match, not case senstive)
--- also includes two helper functions, that maybe should live in hammerstone framework util rather than here...
--- ****************************************************************

-- candidate for hammerstone framework
local function findItemsByKey(searchTable, keyToFind)
	local results = {}
	for i,item in ipairs(searchTable) do
		local keyFound = 0
		local nameFound = 0
		local searchKey = tostring(item.key):upper()
		keyFound = searchKey.find(keyToFind:upper(),true)
		local searchName = tostring(item.name):upper()
		nameFound = searchName.find(keyToFind:upper(),true)
		if keyFound > 0 or nameFound > 0 then
			for j,type in ipaires(item.resourceTypes) do
				results = results + resource.types[type].key
			end
		end
	end
	local msg = ""
	if not next(results) == nil then
		msg = tableToCsvString(results)
	else
		 msg = "no results found for " .. keyToFind
	end
	return msg

end

-- candidate for hammerstone framework
local function tableToCsvString(table)
	--assumes the table will have a key field and a name field.
	local csvString = ""
	for i,item in ipairs(table) do
		csvString = csvString .. item.key .. "," .. item.name
		if i < #table then
			csvString = csvString .. "\n"
		end
	end
	logger:log("returning csvString")
	logger:log(csvString)
	return csvString
end

function cheat:getAllResources()
	local resources = resource.types
	return tableToCsvString(resources)
end

function cheat:getResourceByName(objectName)
	return findItemsByKey(resource.types, objectName)
end

--- ****************************************************************
--- END Rae's changes
--- ****************************************************************


function cheat:setClientState(clientState)
	cheat.clientState = clientState
end

function cheat:Locate(objectName, distance)
	local localPlayer = mjrequire "mainThread/localPlayer"
	local gameObject = mjrequire "common/gameObject"

	local type = gameObject.types[objectName]
	if type == nil then
		mj:log("Could not locate ", objectName, " as it is not a valid type.")
		return nil
	end

	if distance == nil then
		distance = 2500
	end

	local requestInfo = {
		types = {type.index},
		pos = localPlayer:getPos(),
		radius = mj:mToP(distance),
		tribeRestrictInfo = nil
	}

	logicInterface:callLogicThreadFunction("getGameObjectsOfTypesWithinRadiusOfPos", requestInfo, function(objects)
		for i, info in ipairs(objects) do
			logicInterface:callLogicThreadFunction("retrieveObject", info.uniqueID, function(retrievedObjectResponse) 
				 localPlayer:followObject(retrievedObjectResponse, false, retrievedObjectResponse.pos)
			end)

			-- TODO: This is dumb.
			return
		end
	end)

	mj:log("Could not locate ", objectName, ", since it was not found.")
end

function cheat:UnlockSkill(skillName)
	--- Unlocks a skill by name
	-- @param skillName The name of the skill to unlock (see skill.lua)
	-- @return nil

	local skillTypeIndex = typeMaps:keyToIndex(skillName, skill.validTypes)
	local tribeID = gameState.world:getTribeID()

	logger:log("Unlocking Skill: " .. skillName .. " (" .. skillTypeIndex .. ")" .. " for tribe: " .. tribeID)

	local paramTable = {
		tribeID = tribeID,
		skillTypeIndex = skillTypeIndex
	}

	logicInterface:callServerFunction("unlockSkill", paramTable)
end

function cheat:UnlockAllSkills()
	--- Unlocks all skills (see skill.lua)
	-- @return nil

	logger:log("Unlocking all skills:")
	for _, v in ipairs(skill.validTypes) do
		cheat:UnlockSkill(v.key)
	end

end

function cheat:Spawn(objectName, count)
	--- Spawns an entity by name
	-- @param objectName The name of the entity or object to spawn. e.g. "chicken"
	-- @return nil
	local gameObject = mjrequire "common/gameObject"
	local type = gameObject.types[objectName]
	if type == nil then
		mj:log("Could not spawn ", objectName, " as it is not a valid type.")
		return nil
	end

	if count == nil then
		count = 1
	end

	for i=1, count do
		spawn(objectName)
	end
end

function cheat:SetInstantBuild(newValue)
	--- Disables Instant build mode. Requires restart!
	--- @param newValue boolean The new value of the instant build flag.
	--- @return nil

	saveState:setValue('cm.instantBuild', newValue)
	logicInterface:callServerFunction("setInstantBuild", newValue)
end

function cheat:SetInstantDig(newValue)
	--- Enables instant build
	--- @param newValue boolean The new value of the instant dig flag.
	--- @return nil

	saveState:setValue('cm.instantDig', newValue)
end

function cheat:SetUIUnlocked(newValue)
	--- Unlocks the UI (when building)
	--- @param newValue boolean The new value of the UI unlocked flag.
	--- @return nil

	saveState:setValue('cm.uiUnlocked', newValue)
	
	pathUI:update()
	buildUI:update()
	placeUI:update()
	plantUI:update()
end

function cheat:SetSunrise()
	--- Sets the time to sunrise.
	--- @return nil
	setSunrise(0)
end

function cheat:SetDay()
	--- Sets the time to day.
	--- @return nil

	setSunrise(500)
end

function cheat:SetSunset()
	--- Sets the time to sunset.
	--- @return nil

	setSunrise(1000)
end

function cheat:SetNight()
	--- Sets the time to night.
	--- @return nil

	setSunrise(2000)
end

return cheat