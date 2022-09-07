--- CreativeMode: settingsUI.lua 
--- GameView which will be used to display the cheat UI.
--- Lifecycle events will be called automatically by the uiManager.
--- @author SirLich

local settingsUI = {
	name = "Creative Mode",
	view = nil,
	parent = nil,
	icon = "icon_configure",
}

-- Base
local model = mjrequire "common/model"
local uiStandardButton = mjrequire "mainThread/ui/uiCommon/uiStandardButton"
local uiCommon = mjrequire "mainThread/ui/uiCommon/uiCommon"
local timer = mjrequire "common/timer"

-- Math
local mjm = mjrequire "common/mjm"
local vec3 = mjm.vec3
local vec2 = mjm.vec2
local vec4 = mjm.vec4

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

local elementControlX = backgroundWidth * 0.5
local elementYOffsetStart = -20
local elementYOffset = elementYOffsetStart
local yOffsetBetweenElements = buttonHeight
local elementTitleX = - backgroundWidth * 0.5 - 10

local requireRestartTextView

local function setRequireRestart(needsRestart)
	requireRestartTextView.hidden = false

	if needsRestart then
		requireRestartTextView.color = vec4(1.0, 0.0, 0.0, 1.0)
		requireRestartTextView.font = Font(uiCommon.fontName, 2)
		requireRestartTextView.text = "[Settings Applied] Restart Required!"
	else
		requireRestartTextView.color = vec4(1.0, 1.0, 1.0, 0.3)
		requireRestartTextView.font = Font(uiCommon.fontName, 15)
		requireRestartTextView.text = "[Settings Applied] No need to restart :)"
	end
end

-- ============================================================================
-- Copied from optionsView.lua
-- ============================================================================

local function addButton(parentView, buttonTitle, clickFunction)
	local button = uiStandardButton:create(parentView, buttonSize)
	button.relativePosition = ViewPosition(MJPositionCenter, MJPositionTop)
	button.baseOffset = vec3(0,elementYOffset, 0)
	uiStandardButton:setText(button, buttonTitle)
	uiStandardButton:setClickFunction(button, clickFunction)
	elementYOffset = elementYOffset - yOffsetBetweenElements
	return button
end

local function addTitleHeader(parentView, title)
	if elementYOffset ~= elementYOffsetStart then
		elementYOffset = elementYOffset - 20
	end

	local textView = TextView.new(parentView)
	textView.font = Font(uiCommon.fontName, 16)
	textView.relativePosition = ViewPosition(MJPositionCenter, MJPositionTop)
	textView.baseOffset = vec3(0,elementYOffset - 4, 0)
	textView.text = title

	elementYOffset = elementYOffset - yOffsetBetweenElements
	return textView
end

local function addToggleButton(parentView, toggleButtonTitle, settingID, changedFunction)
	--- @param settingID string The ID of the setting to toggle (used for initial state)

	local toggleButton = uiStandardButton:create(parentView, vec2(26,26), uiStandardButton.types.toggle)
	toggleButton.relativePosition = ViewPosition(MJPositionInnerLeft, MJPositionTop)
	toggleButton.baseOffset = vec3(elementControlX, elementYOffset, 0)

	timer:addCallbackTimer(3, function()
		local saveState = mjrequire "hammerstone/state/saveState"
		uiStandardButton:setToggleState(toggleButton, saveState:getValue(settingID))
	end)

	
	local textView = TextView.new(parentView)
	textView.font = Font(uiCommon.fontName, 16)
	textView.relativePosition = ViewPosition(MJPositionInnerRight, MJPositionTop)
	textView.baseOffset = vec3(elementTitleX, elementYOffset - 4, 0)
	textView.text = toggleButtonTitle

	uiStandardButton:setClickFunction(toggleButton, function()
		changedFunction(uiStandardButton:getToggleState(toggleButton))
	end)

	elementYOffset = elementYOffset - yOffsetBetweenElements
	
	return toggleButton
end

-- ============================================================================
-- End of copied from optionsView.lua
-- ============================================================================

function settingsUI:init(manageUI)
	--- Called when the UI is ready to be generated
	--- @param manageUI UI The UI that is your parent.

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

	addTitleHeader(backgroundView, "Options")

	-- Toggle buttons
	addToggleButton(backgroundView, "Instant Build", 'cm.instantBuild', function(newValue)
		cheat:SetInstantBuild(newValue)
	end)

	timer:addCallbackTimer(3, function()
		local saveState = mjrequire "hammerstone/state/saveState"
		cheat:SetInstantBuild(saveState:getValue('cm.instantBuild'))
	end)

	addToggleButton(backgroundView, "Instant Dig", 'cm.instantDig', function(newValue)
		cheat:SetInstantDig(newValue)
	end)

	addToggleButton(backgroundView, "Unlock UI", 'cm.uiUnlocked', function(newValue)
		cheat:SetUIUnlocked(newValue)
	end)

	addTitleHeader(backgroundView, "Actions")


	addButton(backgroundView, "Set Sunrise", function()
		cheat:SetSunrise()
	end)

	addButton(backgroundView, "Unlock All Skills", function()
		cheat:UnlockAllSkills()
	end)

	requireRestartTextView= TextView.new(backgroundView)
	requireRestartTextView.relativePosition = ViewPosition(MJPositionCenter, MJPositionBelow)
	requireRestartTextView.baseOffset = vec3(0, 100, 0)
	requireRestartTextView.color = vec4(1.0, 0.0, 0.0, 1.0)
	requireRestartTextView.font = Font(uiCommon.fontName, 50)
	requireRestartTextView.hidden = true
end

-- Called every frame
function settingsUI:update(gameUI)
	-- Do nothing
end

return settingsUI

