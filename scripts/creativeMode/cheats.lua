--- Globally namespaced cheat commands

-- Module Setup
cheat = {}

-- Sapiens
local mj = mjrequire "common/mj"
local logicInterface = mjrequire "mainThread/logicInterface"
local typeMaps = mjrequire "common/typeMaps"
local skill = mjrequire "common/skill"
local constructUIHelper = mjrequire "mainThread/ui/constructableUIHelper"

-- Hammerstone
local hammerstone = mjrequire "hammerstone/hammerstone"
local logger = mjrequire "hammerstone/logging"

function cheat:UnlockSkill(skillName)
	--- Unlocks a skill by name
	-- @param skillName The name of the skill to unlock (see skill.lua)
	-- @return nil

	local skillTypeIndex = typeMaps:keyToIndex(skillName, skill.validTypes)
	local tribeID = hammerstone.world:getTribeID()

	logger:log("Unlocking Skill: " .. skillName .. " (" .. skillTypeIndex .. ")" .. " for tribe: " .. tribeID)

	local paramTable = {
		test = "TEST 3432432423",
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
	--- Enables instant build
	-- @return nil

	completeCheat()
	constructUIHelper.instantBuild = true
end

-- Module return
return cheat