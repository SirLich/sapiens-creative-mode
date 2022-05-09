--- GameView which will be used to display the cheat UI.
-- Lifecycle events will be called automatically by the uiManager.
-- @author SirLich

-- Module setup
local cheatUI = {
	gameUI = nil,
	name = "cheatUI",
	view = nil,
}

-- Requires
local mjm = mjrequire "common/mjm"
local vec3 = mjm.vec3
local vec2 = mjm.vec2
local model = mjrequire "common/model"
local uiStandardButton = mjrequire "mainThread/ui/uiCommon/uiStandardButton"
local mob = mjrequire "common/mob/mob"

-- Local state
local backgroundWidth = 1140
local backgroundHeight = 640
local backgroundSize = vec2(backgroundWidth, backgroundHeight)

local buttonBoxWidth = 80
local buttonBoxHeight = backgroundHeight - 80.0
local buttonBoxSize = vec2(buttonBoxWidth, buttonBoxHeight)

local buttonWidth = 180
local buttonHeight = 40
local buttonSize = vec2(buttonWidth, buttonHeight)

-- Called when the UI is ready to be geneated
function cheatUI:initGameElement(gameUI)
	mj:log("Initializing Cheat UI...")

	-- Main View
	self.view = View.new(gameUI.view)
	self.view.size = backgroundSize
	self.view.relativePosition = ViewPosition(MJPositionCenter, MJPositionCenter)

	-- Background view
	local backgroundView = ModelView.new(self.view )
	backgroundView:setModel(model:modelIndexForName("ui_bg_lg_16x9"))
	local scaleToUse = backgroundHeight
    backgroundView.scale3D = vec3(scaleToUse,scaleToUse,scaleToUse)
	backgroundView.relativePosition = ViewPosition(MJPositionCenter, MJPositionCenter)
	backgroundView.size = backgroundSize

	-- Button Box
	local buttonBox = ModelView.new(backgroundView )
    buttonBox:setModel(model:modelIndexForName("ui_inset_lg_2x3"))
    local scaleToUse = buttonBoxHeight * 0.5
    buttonBox.scale3D = vec3(scaleToUse,scaleToUse,scaleToUse)
	buttonBox.baseOffset = vec3(300, 0, 0)
    buttonBox.relativePosition = ViewPosition(MJPositionOuterLeft, MJPositionCenter)
    buttonBox.size = buttonBoxSize

	-- Close Button
    local closeButton = uiStandardButton:create(backgroundView, vec2(50,50), uiStandardButton.types.markerLike)
    closeButton.relativePosition = ViewPosition(MJPositionInnerRight, MJPositionAbove)
    closeButton.baseOffset = vec3(30, -20, 0)
    uiStandardButton:setIconModel(closeButton, "icon_cross")
    uiStandardButton:setClickFunction(closeButton, function()
		self.view.hidden = true
    end)

	local buttonSpacing = 60
	local buttonIndex = 1

	-- Add Spawn Buttons
	for i, mobType in ipairs(mob.validTypes) do
		local entityIdentifier = mobType.key
		local entityName = entityIdentifier

		local spawnButton = uiStandardButton:create(buttonBox, buttonSize)
		spawnButton.relativePosition = ViewPosition(MJPositionCenter, MJPositionTop)

		local offset = -1 * buttonSpacing * buttonIndex
		

		spawnButton.baseOffset = vec3(0, offset, 5) -- Top padding
		uiStandardButton:setText(spawnButton, entityName)
		uiStandardButton:setClickFunction(spawnButton, function()
			spawn(entityIdentifier)
		end)
		buttonIndex = buttonIndex + 1
	end

	mj:log("Cheat UI Initialized.")
end

-- Called every frame
function cheatUI:updateGameElement(gameUI)
	-- Do nothing
end

-- Module return
return cheatUI

