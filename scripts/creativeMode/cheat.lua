--- CreativeMode: cheat.lua
--- Globally namespaced cheat commands
--- Made available via requiring in creativeMode.lua
--- @author SirLich, death-rae

cheat = {
	clientState = nil,
	world = nil
}

-- Sapiens
local mj = mjrequire "common/mj"
local logicInterface = mjrequire "mainThread/logicInterface"
local research = mjrequire "common/research"
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
--- @author  "Rae"
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

--- Converts a table into a CSV string.
-- @param table - The table to convety. Must have a 'name' and a 'key' field.
-- @author death-rae
-- @todo This function could be migrated into Hammerstone
local function tableToCsvString(table)
	local csvString = ""
	for i,item in ipairs(table) do
		csvString = csvString .. item.key .. "," .. item.name
		if i < #table then
			csvString = csvString .. "\n"
		end
	end
	return csvString
end

function cheat:getAllResources()
	local resources = resource.types
	return tableToCsvString(resources)
end

function cheat:getResourceByName(objectName)
	return findItemsByKey(resource.types, objectName)
end


function cheat:setClientState(clientState)
	cheat.clientState = clientState
end

--- Snaps the player character to the closest instance of the named GOM.
-- This is useful for locating hard-to-find resources.
-- @param objectName - The name of the object you want to locate, such as 'mammoth'
-- @param distance - The distance in meters to search. Defaults to 2500.
-- @return nil
-- @todo This is currently locating the *first* instance. I don't know whether this is the closest.
function cheat:locate(objectName, distance)
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
		if #objects > 1 then
			logicInterface:callLogicThreadFunction("retrieveObject", objects[1].uniqueID, function(retrievedObjectResponse)
				localPlayer:followObject(retrievedObjectResponse, false, retrievedObjectResponse.pos)
			end)
			return nil
		end
		mj:log("Could not locate ", objectName, ", since it was not found.")
	end)

end

--- Unlocks a skill by name
-- @param skillName - The name of the skill to unlock (see skill.lua)
-- @return nil
function cheat:unlockSkill(researchTypeIndex, skillName)
	local tribeID = gameState.world:getTribeID()

	logger:log("Unlocking Skill: " .. skillName .. " (" .. researchTypeIndex .. ")" .. " for tribe: " .. tribeID)

	local paramTable = {
		tribeID = tribeID,
		researchTypeIndex = researchTypeIndex
	}

	logicInterface:callServerFunction("unlockSkill", paramTable)
end

--- Unlocks all skills (see skill.lua)
-- @return nil
function cheat:unlockAllSkills()
	logger:log("Unlocking all skills:")
	for k, v in pairs(research.types) do
		if not tonumber(k) then
			cheat:unlockSkill(v.index, k)
		end
	end
end

--- "Discovers" every resource and object, for the current tribe. This mostly replaces the 'Unlock UI', but is destructive.
--- @return nil
function cheat:discoverEverything()
	local tribeID = gameState.world:getTribeID()

	logger:log("Discovering Everything for tribe: " .. tribeID)

	local paramTable = {
		tribeID = tribeID,
	}

	logicInterface:callServerFunction("unlockSkill", paramTable)
end


--- Spawns an entity by name
-- @param objectName - The name of the entity or object to spawn. e.g. "chicken"
-- @return nil
function cheat:spawn(objectName, count)
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
		-- This is a global function defined in Sapiens core.
		spawn(objectName)
	end
end

--- Toggles instant built mode, which allows placing structures and completing them instantly.
--- @param newValue - If true, instant build will be turned on. If false, it will be turned off.
--- @return nil
function cheat:setInstantBuild(newValue)
	saveState:setValue('cm.instantBuild', newValue)
	logicInterface:callServerFunction("setInstantBuild", newValue)
end

-- startSevereWeatherEvent
function cheat:startStorm()
	logicInterface:callServerFunction("startStorm")
end

-- startSevereWeatherEvent
function cheat:stopStorm()
	logicInterface:callServerFunction("stopStorm")
end

function cheat:quickResources()
	spawn("birchBranch", 20)
	spawn("chickenMeatCooked", 15)
	spawn("flintHatchet", 1)
	spawn("flintPickaxe", 1)
	spawn("flintHammer", 1)
end

--- Enables instant build mode, which allows digging/filling instantly.
--- @param newValue boolean - If true, instant dig will be turned on. If false, it will be turned off.
--- @return nil
function cheat:setInstantDig(newValue)
	saveState:setValue('cm.instantDig', newValue)
end

--- Unlocks the UI, allowing you to place or interact with resources that you haven't discovered/unlocked yet.
--- @param newValue boolean - The new value of the UI unlocked flag.
--- @return nil
function cheat:setUIUnlocked(newValue)
	saveState:setValue('cm.uiUnlocked', newValue)
	
	-- Refresh the UI to prevent stuff from being stale.
	pathUI:update()
	buildUI:update()
	placeUI:update()
	plantUI:update()
end

--- Sets the time to sunrise.
--- @return nil
function cheat:SetSunrise()
	setSunrise(0)
end

--- Sets the time to day.
--- @return nil
function cheat:SetDay()
	setSunrise(500)
end

--- Sets the time to sunset.
--- @return nil
function cheat:SetSunset()
	setSunrise(1000)
end

--- Sets the time to night.
--- @return nil
function cheat:SetNight()
	setSunrise(2000)
end

local c = cheat
return cheat
