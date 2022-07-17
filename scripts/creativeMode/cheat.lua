--- CreativeMode: cheat.lua
--- Globally namespaced cheat commands
--- Made available via requiring in creativeMode.lua

cheat = {
	clientState = nil,
	world = nil
}

-- Base
local mj = mjrequire "common/mj"
local logicInterface = mjrequire "mainThread/logicInterface"
local typeMaps = mjrequire "common/typeMaps"
local skill = mjrequire "common/skill"

-- Hammerstone
local gameState = mjrequire "hammerstone/state/gameState"
local logger = mjrequire "hammerstone/logging"
local saveState = mjrequire "hammerstone/state/saveState"

function cheat:setClientState(clientState)
	cheat.clientState = clientState
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

function cheat:Spawn(objectName)
	--- Spawns an entity by name
	-- @param objectName The name of the entity or object to spawn. e.g. "chicken"
	-- @return nil

	spawn(objectName)
end

function cheat:SetInstantBuild(newValue)
	--- Disables Instant build mode. Requires restart!
	--- @param newValue boolean The new value of the instant build flag.
	--- @return nil

	saveState.setValueClient('cm.instantBuild', newValue)
	if newValue == true then
		completeCheat()
	else
		logger:log("Instant build mode disabled: Please restart.")
	end
end

function cheat:SetInstantDig(newValue)
	--- Enables instant build
	--- @param newValue boolean The new value of the instant dig flag.
	--- @return nil

	saveState:setValueClient('cm.instantDig', newValue)
end

function cheat:SetUIUnlocked(newValue)
	--- Unlocks the UI (when building)
	--- @param newValue boolean The new value of the UI unlocked flag.
	--- @return nil

	saveState:setValueClient('cm.uiUnlocked', newValue)
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