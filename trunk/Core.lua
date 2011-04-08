local NUM_BUTTONS = 30
local BUTTON_HEIGHT = 18

local combatLog = {}

local addon = CreateFrame("Frame", nil, UIParent, "InsetFrameTemplate")
addon:EnableMouse(true)
addon:SetToplevel(true)
addon:SetSize(1024, (NUM_BUTTONS + 1) * (BUTTON_HEIGHT) + 8)
addon:SetPoint("CENTER")
-- addon:SetBackdrop({
	-- bgFile = [[Interface\FrameGeneral\UI-Background-Marble]],
	-- tile = true,
-- })

addon:Hide()

local bg = addon:CreateTexture(nil, "BACKGROUND")
bg:SetSize(64, 64)
-- bg:SetAllPoints()
bg:SetPoint("TOPLEFT")
bg:SetPoint("BOTTOMRIGHT")
-- bg:SetTexture([[Interface\FrameGeneral\UI-Background-Marble]])
bg:SetHorizTile(true)
bg:SetVertTile(true)

local close = CreateFrame("Button", nil, addon, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT")


local argWidth = {
	[5] = 96,
	[8] = 96,
	[9] = 64,
	[15] = 64,
	[16] = 64,
	[17] = 64,
	[18] = 32,
	[19] = 32,
	[20] = 32,
}

local argNames = {
	"timeStamp",
	"event",
	"sourceGUID",
	"sourceName",
	"sourceFlags",
	"destGUID",
	"destName",
	"destFlags",
}

local headers = {}
for i = 1, 20 do
	local btn = addon:CreateFontString(nil, nil, "GameFontNormalSmall")
	btn:SetJustifyH("LEFT")
	btn:SetWidth(argWidth[i] or 128)
	btn:SetHeight(BUTTON_HEIGHT)
	if i == 1 then
		btn:SetPoint("TOPLEFT", 8, -4)
	else
		btn:SetPoint("LEFT", headers[i - 1], "RIGHT")
	end
	btn:SetText(argNames[i])
	headers[i] = btn
end

local buttons = {}

for i = 1, NUM_BUTTONS do
	local line = {}
	local btn = addon:CreateFontString(nil, nil, "GameFontHighlightSmall")
	btn:SetJustifyH("LEFT")
	btn:SetWidth(128)
	btn:SetHeight(BUTTON_HEIGHT)
	if i == 1 then
		btn:SetPoint("TOP", headers[1], "BOTTOM")
	else
		btn:SetPoint("TOP", buttons[i - 1][1], "BOTTOM")
	end
	if i % 2 == 0 then
		local bg = addon:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints(btn)
		bg:SetTexture(1, 1, 1, 0.1)
	end
	-- btn:SetPoint("RIGHT")
	line[1] = btn
	for i = 2, 20 do
		local btn = addon:CreateFontString(nil, nil, "GameFontHighlightSmall")
		btn:SetJustifyH("LEFT")
		btn:SetWidth(argWidth[i] or 128)
		btn:SetHeight(BUTTON_HEIGHT)
		btn:SetPoint("LEFT", line[i - 1], "RIGHT")
		line[i] = btn
	end
	buttons[i] = line
end

local numEvents = 0

addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
addon:SetScript("OnEvent", function(self, event, ...)
	numEvents = numEvents + 1
	for i = 1, select("#", ...) do
		local arg = select(i, ...)
		if type(arg) == "string" then
			arg = format("%q", arg)
		end
		buttons[numEvents][i]:SetText(arg)
	end
	if numEvents == NUM_BUTTONS then
		self:UnregisterEvent(event)
	end
end)