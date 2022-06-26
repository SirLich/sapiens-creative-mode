--- GameView which will be used to display the cheat UI.
-- Lifecycle events will be called automatically by the uiManager.
-- @author SirLich

local settingsUI = {
	name = "Creative Mode",
	view = nil,
	parent = nil,
	icon = "icon_configure",
}

-- Base
local model = mjrequire "common/model"
local uiStandardButton = mjrequire "mainThread/ui/uiCommon/uiStandardButton"

-- Math
local mjm = mjrequire "common/mjm"
local vec3 = mjm.vec3
local vec2 = mjm.vec2

-- Globals
local backgroundWidth = 1140
local backgroundHeight = 640
local backgroundSize = vec2(backgroundWidth, backgroundHeight)

local buttonBoxWidth = 80
local buttonBoxHeight = backgroundHeight - 80.0
local buttonBoxSize = vec2(buttonBoxWidth, buttonBoxHeight)

local buttonWidth = 180
local buttonHeight = 40
local buttonSize = vec2(buttonWidth, buttonHeight)

-- Called when the UI is ready to be generated
function settingsUI:init(manageUI)

	-- Main View
	self.view = View.new(manageUI.view)
	self.view.size = backgroundSize
	self.view.relativePosition = ViewPosition(MJPositionCenter, MJPositionCenter)
	self.view.hidden = true

	-- Background View
	local backgroundView = ModelView.new(self.view )
	backgroundView:setModel(model:modelIndexForName("ui_bg_lg_16x9"))
	local scaleToUse = backgroundSize.x * 0.5
	backgroundView.scale3D = vec3(scaleToUse,scaleToUse,scaleToUse)
	backgroundView.relativePosition = ViewPosition(MJPositionCenter, MJPositionCenter)
	backgroundView.size = backgroundSize

	-- Close Button
	local closeButton = uiStandardButton:create(backgroundView, vec2(50,50), uiStandardButton.types.markerLike)
	closeButton.relativePosition = ViewPosition(MJPositionInnerRight, MJPositionAbove)
	closeButton.baseOffset = vec3(30, -20, 0)
	uiStandardButton:setIconModel(closeButton, "icon_cross")
	uiStandardButton:setClickFunction(closeButton, function()
		self.view.hidden = true
	end)
end

-- Called every frame
function settingsUI:update(gameUI)
	-- Do nothing
end

return settingsUI

