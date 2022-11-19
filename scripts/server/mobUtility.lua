--- CreativeMode: mobUtility.lua
--- @author death-rae "Rae"

local mjm = mjrequire "common/mjm"
local mj = mjrequire "common/mj"
local vec3 = mjm.vec3
local normalize = mjm.normalize
local length = mjm.length
local length2 = mjm.length2
local mix = mjm.mix
local mat3GetRow = mjm.mat3GetRow
local cross = mjm.cross
local mat3LookAtInverse = mjm.mat3LookAtInverse
local createUpAlignedRotationMatrix = mjm.createUpAlignedRotationMatrix
local mat3Inverse = mjm.mat3Inverse

--- references 
local gameObject = mjrequire "common/gameObject"
local mobInventory = mjrequire "common/mobInventory"
local timer = mjrequire "common/timer"
local worldHelper = mjrequire "common/worldHelper"
local physicsSets = mjrequire "common/physicsSets"
local mob = mjrequire "common/mob/mob"

local serverGOM = mjrequire "server/serverGOM"
local planManager = mjrequire "server/planManager"
local serverMob = mjrequire "server/objects/serverMob"


--- hammerstone
local gameState = mjrequire "hammerstone/state/gameState"


local mobUtility = {}


---create local functions for use
---basically just shadowing serverMob at this point...
local function removeFrequentUpdateIfNeeded(object, aiState)
    if aiState.frequentCallbackSet then
        if object.sharedState.dead or 
        (((not aiState.closeSapiens) or (not next(aiState.closeSapiens))) and (not aiState.agroTimer) and (not object.sharedState.attackSapienID)) then
            --mj:log("stop:", objectID)
            aiState.frequentCallbackSet = nil
            serverGOM:removeFrequentCallback(object.uniqueID) -- also call some kind of function to calm down the state now it might be 10 secs until the next infrequent update
        end
    end
end

local function getAIState(object)
    local unsavedState = serverGOM:getUnsavedPrivateState(object)
    local aiState = unsavedState.aiState
    if not aiState then
        aiState = {}
        unsavedState.aiState = aiState
    end
    return aiState
end

local function resetAIState(object)
    local unsavedState = serverGOM:getUnsavedPrivateState(object)
    unsavedState.aiState = nil
end

local function dropAllEmbededObjects(mobObject, tribeID)
    --mj:log("dropping embedded objects before deletion...")
    local sharedState = mobObject.sharedState
    local locationTypeIndex = mobInventory.locations.embeded.index
    if sharedState.inventories and sharedState.inventories[locationTypeIndex] then
        local inventory = sharedState.inventories[locationTypeIndex]
        local objects = inventory.objects
        if objects then
            local dropPosNormal = mobObject.normalizedPos
            local clampToSeaLevel = true
            local shiftedPos = worldHelper:getBelowSurfacePos(mobObject.pos, 1.0, physicsSets.walkable, nil, clampToSeaLevel)
            local shiftedPosLength = length(shiftedPos)
            local finalDropPos = dropPosNormal * (shiftedPosLength + mj:mToP(4.0)) --todo different heights
            for i,objectInfo in ipairs(objects) do
                serverGOM:dropObject(objectInfo, finalDropPos + mj:mToP(rng:randomVec() - vec3(0.5,0.5,0.5)), tribeID, true)
            end

            sharedState:remove("inventories", locationTypeIndex)
        end
    end
end

local function convertToDeadObject(object, mobType, tribeID)
    --mj:log("converting it to dead for deletion...")
    planManager:removeAllPlanStatesForObject(object, object.sharedState)
    dropAllEmbededObjects(object, tribeID)
    --mj:log("changing object type...")
    serverGOM:changeObjectType(object.uniqueID, mobType.deadObjectTypeIndex, false)
    serverGOM:removeGameObject(object.uniqueID)
    --mj:log("completed removing object")
end


function mobUtility:removeMobs(objects, tribeID)
    --mj:log("removing mobs")
    --mj:log("objects", objects)
    for i,object in ipairs(objects) do
        local obj = serverGOM:getObjectWithID(object.uniqueID)
        local sharedState = obj.sharedState
        local initialMobObjectTypeIndex = obj.objectTypeIndex
        local mobTypeIndex = gameObject.types[obj.objectTypeIndex].mobTypeIndex
        local mobType = mob.types[mobTypeIndex]
        --mj:log("removing plans for", obj)
        --it's easier to remove a dead mob, so lets just kill it first, then remove it after its dead.
        planManager:removeAllPlanStatesForObject(obj, sharedState)
        sharedState:set("dead", true)
        removeFrequentUpdateIfNeeded(obj, getAIState(obj))
        resetAIState(obj)
        --mj:log("waiting, then checking if the object is dead...")
        timer:addCallbackTimer(1.0, function()
            local objectReloaded = serverGOM:getObjectWithID(obj.uniqueID)
            if objectReloaded and objectReloaded.objectTypeIndex == initialMobObjectTypeIndex then
                -- its not dead yet so lets fix that
                convertToDeadObject(objectReloaded, mobType, tribeID)
            else
                --its already a dead mob type, so we can remove it
                serverGOM:removeGameObject(objectReloaded.uniqueID)
            end
        end)
        --mj:log("moving to next object in loop, if any")
    end
end

return mobUtility