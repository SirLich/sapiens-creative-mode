--- CreativeMode: sapienUtility.lua
--- @author death-rae "Rae"


local gameObject = mjrequire "common/gameObject"
local need = mjrequire "common/need"
local mood = mjrequire "common/mood"
local serverGOM = mjrequire "server/serverGOM"
local planMarkersUI = mjrequire "mainThread/ui/planMarkersUI"
local playerSapiens = mjrequire "mainThread/playerSapiens"
local serverSapien = mjrequire "server/serverSapien"

--- logging
local mj = mjrequire "common/mj"


local sapienUtility = {}

function sapienUtility:maxSapienNeeds(objects) 
	--mj:log("got to custom needs function in sapienUtility", objects)
		for i,sapienID in ipairs(objects) do
			-- if the sapien is in motion / walking somewhere, the data structure of the object changes
			local sapienUniqueID = sapienID.uniqueID
			local sapien = nil
			if sapienUniqueID then
				sapien = serverGOM:getObjectWithID(sapienUniqueID)
			else
				sapien = serverGOM:getObjectWithID(sapienID)
			end
			--mj:log("sapien found ", sapien)
			if sapien then
				local sharedState = sapien.sharedState
				mj:log("maxing needs for:", sharedState.name)
				if sharedState and sharedState.needs then
					--get max level for moods
					local moodType = mood.validTypes
					local moodDesc = moodType.descriptions
					local maxMoodLevel = 0
					if moodDesc then
						for i, key in ipairs(moodDesc) do
							maxMoodLevel = maxMoodLevel + 1
						end
					else
						maxMoodLevel = 6
					end
					--to max:
					for j,needType in ipairs(need.validTypes) do
						if sharedState.needs[needType.index] then
							sharedState:set("needs", needType.index, 0.0)
						else
							mj:log("skipping invalid need type")
						end
					end
					for j,moodType in ipairs(mood.validTypes) do
						if sharedState.moods[moodType.index] then
							sharedState:set("moods", moodType.index, maxMoodLevel)
						else
							mj:log("skipping invalid mood type")
						end
					end
					-- remove status effects
					sharedState:set("statusEffects", {})
				end
			end
		end
end

function sapienUtility:removeSapiens(objects, tribeID, followerInfos)
	--mj:log("custom remove sapiens function")
	--mj:log(objects)
	for i,sapien in ipairs(objects) do
		-- if the sapien is in motion / walking somewhere, the data structure of the object changes
		local sapienUniqueID = sapien.uniqueID
		local sapienToRemove = nil
		if sapienUniqueID then
			sapienToRemove = serverGOM:getObjectWithID(sapienUniqueID)
		end
		--mj:log("sapien found? ", sapienToRemove)
		if sapienToRemove then
			serverSapien:removeSapien(sapienToRemove, true, true)
			--mj:log("sapien removed")
		end
	end


end

return sapienUtility