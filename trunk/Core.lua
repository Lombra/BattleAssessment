local NUM_ROWS = 30
local NUM_COLUMNS = 21
local BUTTON_HEIGHT = 18

local combatLog = {}
local headers = {}

local addon = CreateFrame("Frame", "BattleAssessmentFrame", UIParent, "InsetFrameTemplate")
addon:EnableMouse(true)
addon:SetToplevel(true)
addon:SetSize(1024, (NUM_ROWS + 1) * (BUTTON_HEIGHT) + 8)
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


local sortBy = 0

local function argSort(a, b)
	-- print(a, b)
	if not (a and b) or a == b then return end
	-- reverse sort if negative value
	if sortBy < 0 then
		a, b = b, a
	end
	local sortBy = abs(sortBy)
	if a[sortBy] == b[sortBy] then
		return a[0] < b[0]--a[1] < b[1]
	else
		return (type(a[sortBy]) == type(b[sortBy])) and (a[sortBy] < b[sortBy]) or (type(a[sortBy]) < type(b[sortBy]))--not a[sortBy]
	end
end

local function onClick(self)
	local id = self:GetID()
	if abs(sortBy) > 0 then
		headers[abs(sortBy)].arrow:Hide()
	end
	if sortBy == id then
		sortBy = -id
	elseif sortBy == -id then
		sortBy = 0
	else
		sortBy = id
	end
	local arrow = headers[id].arrow
	if abs(sortBy) == id then
		arrow:Show()
		if sortBy < 0 then
			arrow:SetTexCoord(0, 1, 0.5, 1)
		else
			arrow:SetTexCoord(0, 1, 0, 0.5)
		end
	else
		arrow:Hide()
	end
	sort(combatLog, argSort)
	PlaySound("igMainMenuOptionCheckBoxOn")
	addon:Update()
end

local function createColumnHeader(parent)
	local btn = CreateFrame("Button", nil, parent)
	btn:SetNormalFontObject("GameFontNormalSmall")
	btn:SetScript("OnClick", onClick)
	
	local left = btn:CreateTexture(nil, "BACKGROUND")
	left:SetWidth(5)
	left:SetPoint("TOPLEFT")
	left:SetPoint("BOTTOMLEFT")
	left:SetTexture("Interface\\FriendsFrame\\WhoFrame-ColumnTabs")
	left:SetTexCoord(0, 0.078125, 0, 0.75)
	
	local right = btn:CreateTexture(nil, "BACKGROUND")
	right:SetWidth(4)
	right:SetPoint("TOPRIGHT")
	right:SetPoint("BOTTOMRIGHT")
	right:SetTexture("Interface\\FriendsFrame\\WhoFrame-ColumnTabs")
	right:SetTexCoord(0.90625, 0.96875, 0, 0.75)
	
	local middle = btn:CreateTexture(nil, "BACKGROUND")
	middle:SetPoint("TOPLEFT", left, "TOPRIGHT")
	middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
	middle:SetTexture("Interface\\FriendsFrame\\WhoFrame-ColumnTabs")
	middle:SetTexCoord(0.078125, 0.90625, 0, 0.75)
	
	local highlight = btn:CreateTexture()
	highlight:SetPoint("TOPLEFT", left, -2, 5)
	highlight:SetPoint("BOTTOMRIGHT", right, 2, -7)
	highlight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
	btn:SetHighlightTexture(highlight, "ADD")
	
	local sortArrow = btn:CreateTexture()
	sortArrow:SetSize(16, 8)
	sortArrow:SetPoint("RIGHT", -8, 0)
	sortArrow:SetTexture([[Interface\PaperDollInfoFrame\StatSortArrows]])
	sortArrow:Hide()
	btn.arrow = sortArrow
	
	return btn
end

local argWidth = {
	[6] = 96,
	[9] = 96,
	[10] = 64,
	[16] = 64,
	[17] = 64,
	[18] = 64,
	[19] = 32,
	[20] = 32,
	[21] = 32,
}

local argNames = {
	"timeStamp",
	"event",
	"hideCaster",
	"sourceGUID",
	"sourceName",
	"sourceFlags",
	"destGUID",
	"destName",
	"destFlags",
}

for i = 1, NUM_COLUMNS do
	local btn = createColumnHeader(addon)
	btn:SetID(i)
	btn:SetWidth((argWidth[i] or 128) + 2)
	btn:SetHeight(24)
	if i == 1 then
		btn:SetPoint("TOPLEFT", 8, -4)
	else
		btn:SetPoint("LEFT", headers[i - 1], "RIGHT", -2, 0)
	end
	btn:SetText(argNames[i] or "arg"..i)
	headers[i] = btn
end

local function createRow()
end

local function createCell(parent)
	local btn = CreateFrame("Button", nil, parent)
	btn:SetNormalFontObject("GameFontHighlightSmall")
	btn:SetHighlightFontObject("GameFontGreenSmall")
	
	-- local text = btn:CreateFontString(nil, "GameFontHighlightSmall")
	-- text:SetAllPoints()
	-- btn:GetFontString():SetJustifyH("LEFT")
	-- text:SetJustifyH("LEFT")
	-- btn:SetFontString(text)
	
	return btn
end

local rows = {}

for i = 1, NUM_ROWS do
	local row = CreateFrame("Frame", nil, addon)
	row:SetHeight(BUTTON_HEIGHT)
	row:SetPoint("LEFT", 4, 0)
	row:SetPoint("RIGHT", -4, 0)
	if i == 1 then
		row:SetPoint("TOP", headers[1], "BOTTOM")
	else
		row:SetPoint("TOP", rows[i - 1], "BOTTOM")
	end
	local line = {}
	for y = 1, NUM_COLUMNS do
		local btn = createCell(row)
		-- btn:SetJustifyH("LEFT")
		btn:SetWidth(argWidth[y] or 128)
		btn:SetHeight(BUTTON_HEIGHT)
		if y == 1 then
			btn:SetPoint("LEFT")
		else
			btn:SetPoint("LEFT", row[y - 1], "RIGHT")
		end
		line[y] = btn
		row[y] = btn
	end
	if i % 2 == 0 then
		local bg = row:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetTexture(1, 1, 1, 0.1)
	end
	rows[i] = row
	rows[i].cells = line
end

local numEvents = 0

addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
addon:SetScript("OnEvent", function(self, event, ...)
	numEvents = numEvents + 1
	combatLog[numEvents] = {[0] = numEvents, ...}
	for i = 1, select("#", ...) do
		local arg = select(i, ...)
		if type(arg) == "string" then
			arg = format("%q", arg)
		end
		rows[numEvents][i]:SetText(arg)
	end
	if numEvents == NUM_ROWS then
		self:UnregisterEvent(event)
	end
end)


function addon:Update()
	for row = 1, #combatLog do
		local v = combatLog[row]
		row = rows[row]
		for column = 1, #v do
			local arg = v[column]
			if type(arg) == "string" then
				arg = format("%q", arg)
			end
			row[column]:SetText(arg)
		end
	end
end