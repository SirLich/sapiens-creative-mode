--- Globally namespaced cheat commands
-- Made available via requiring in creativeMode.lua

cheat = {}

-- Base
local mj = mjrequire "common/mj"
local logicInterface = mjrequire "mainThread/logicInterface"
local typeMaps = mjrequire "common/typeMaps"
local skill = mjrequire "common/skill"

-- Hammerstone
local gameState = mjrequire "hammerstone/state/gameState"
local logger = mjrequire "hammerstone/logging"
local saveState = mjrequire "hammerstone/state/saveState"

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

function cheat:Spawn(objectName)
	--- Spawns an entity by name
	-- @param objectName The name of the entity or object to spawn. e.g. "chicken"
	-- @return nil

	spawn(objectName)
end

function cheat:EnableInstantBuild()
	mj:log("CM: Enabled Instant Build")
	--- Enables instant build
	-- @return nil

	saveState:setWorldValue("instantBuild", true)
	completeCheat() -- Sapiens Global
end

function cheat:DisableInstantBuild()
	mj:log("CM: Disabled Instant Build")
	--- Disables Instant build mode. Requires restart.
	-- @return nil

	saveState:setWorldValue("instantBuild", false)
end

return cheat