local NUM_ROWS = 30
local NUM_COLUMNS = 23
local BUTTON_HEIGHT = 18
local NUM_BASE_ARGS = 11

local combatLog = {}
local filters = {}
local results = {}
local headers = {}

local addon = CreateFrame("Frame", "BattleAssessmentFrame", UIParent, "InsetFrameTemplate")
addon:EnableMouse(true)
addon:SetToplevel(true)
addon:SetHeight((NUM_ROWS + 1) * BUTTON_HEIGHT + 32)
addon:SetPoint("CENTER")
-- addon:SetBackdrop({
	-- bgFile = [[Interface\FrameGeneral\UI-Background-Marble]],
	-- tile = true,
-- })
addon:SetScript("OnShow", function(self) self:Update() end)

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


SLASH_BATTLE_ASSESSMENT1 = "/ba"
SlashCmdList["BATTLE_ASSESSMENT"] = function()
	(addon:IsShown() and addon.Hide or addon.Show)(addon)
end


local start = CreateFrame("Button", nil, addon)
start:SetSize(24, 24)
start:SetPoint("TOPLEFT", 8, -4)
start:SetNormalTexture([[Interface\Buttons\UI-SpellbookIcon-NextPage-Up]])
start:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD")
start:SetScript("OnClick", function(self) addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") end)

local stop = CreateFrame("Button", nil, addon)
stop:SetSize(24, 24)
stop:SetPoint("LEFT", start, "RIGHT", 4, 0)
stop:SetNormalTexture([[Interface\TimeManager\PauseButton]])
stop:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD")
stop:SetScript("OnClick", function(self) addon:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED") end)

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
		return a[0] < b[0]
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
			arrow:SetTexCoord(0, 1, 0.5, 0.9375)
		else
			arrow:SetTexCoord(0, 1, 0.0625, 0.5)
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
	[3] = 96,
	[6] = 96,
	[7] = 96,
	[10] = 96,
	[11] = 96,
	[12] = 64,
	[18] = 64,
	[19] = 64,
	[20] = 64,
	[21] = 32,
	[22] = 32,
	[23] = 32,
}

do
	local width = 0
	for i = 1, NUM_BASE_ARGS do
		width = width + (argWidth[i] or 128) + 2
	end
	addon:SetWidth(width)
end

local argNames = {
	"timeStamp",
	"event",
	"hideCaster",
	"sourceGUID",
	"sourceName",
	"sourceFlags",
	"sourceFlags2",
	"destGUID",
	"destName",
	"destFlags",
	"destFlags2",
}

for i = 1, NUM_COLUMNS do
	local btn = createColumnHeader(addon)
	btn:SetID(i)
	btn:SetWidth((argWidth[i] or 128) + 2)
	btn:SetHeight(24)
	if i == 1 then
		btn:SetPoint("TOPLEFT", 4, -32)
	else
		btn:SetPoint("LEFT", headers[i - 1], "RIGHT", -2, 0)
	end
	btn:SetText(argNames[i] or "arg"..i)
	headers[i] = btn
end

local function createRow()
end

local function onClick(self)
	local filter = results[self.index][self.column]
	if filters[self.column] == filter then
		filters[self.column] = nil
		headers[self.column]:SetNormalFontObject("GameFontNormalSmall")
	else
		filters[self.column] = filter
		headers[self.column]:SetNormalFontObject("GameFontGreenSmall")
	end
	addon:Update()
end

local function createCell(parent)
	local btn = CreateFrame("Button", nil, parent)
	btn:SetNormalFontObject("GameFontHighlightSmall")
	btn:SetHighlightFontObject("GameFontGreenSmall")
	btn:SetScript("OnClick", onClick)
	
	-- local text = btn:CreateFontString(nil, "GameFontHighlightSmall")
	-- text:SetAllPoints()
	-- text:SetJustifyH("LEFT")
	-- btn:SetFontString(text)
	
	return btn
end

local function updateRow(self, index)
	local data = results[index]
	for column = 1, NUM_COLUMNS do
		local arg = data[column]
		if type(arg) == "string" then
			-- arg = format("%q", arg)
		end
		self[column]:SetText(arg)
		self[column].index = index
	end
	-- self.index = index
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
	row.Update = updateRow
	local line = {}
	for y = 1, NUM_COLUMNS do
		local btn = createCell(row)
		btn:SetWidth(argWidth[y] or 128)
		btn:SetHeight(BUTTON_HEIGHT)
		if y == 1 then
			btn:SetPoint("LEFT")
		else
			btn:SetPoint("LEFT", row[y - 1], "RIGHT")
		end
		btn.column = y
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

local scroll = CreateFrame("ScrollFrame", "BattleAssessmentScroll", addon, "FauxScrollFrameTemplate")
scroll:SetAllPoints()
scroll:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll(self, offset, BUTTON_HEIGHT, scroll.Update) end)

function scroll:Update()
	local size = #results
	FauxScrollFrame_Update(self, size, NUM_ROWS, BUTTON_HEIGHT)
	
	local offset = FauxScrollFrame_GetOffset(self)
	
	for line = 1, NUM_ROWS do
		local row = rows[line]
		local lineplusoffset = line + offset
		if lineplusoffset <= size then
			row:Update(lineplusoffset)
			row:Show()
		else
			row:Hide()
		end
	end
end

local numEvents = 0

-- addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
addon:SetScript("OnEvent", function(self, event, ...)
	numEvents = numEvents + 1
	combatLog[numEvents] = {[0] = numEvents, ...}
	-- for i = 1, select("#", ...) do
		-- local arg = select(i, ...)
		-- if type(arg) == "string" then
			-- arg = format("%q", arg)
		-- end
		-- rows[numEvents][i]:SetText(arg)
	-- end
	-- if numEvents == NUM_ROWS then
		-- self:UnregisterEvent(event)
	-- end
	self:Update()
end)

function addon:UpdateRow(row)
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

function addon:Update()
	if not self:IsShown() then
		return
	end
	wipe(results)
	for i, v in ipairs(combatLog) do
		local include = true
		for arg, filter in pairs(filters) do
			if v[arg] ~= filter then
				include = false
				break
			end
		end
		if include then
			tinsert(results, v)
		end
	end
	scroll:Update()
	-- for row = 1, #combatLog do
		-- self:UpdateRow(row)
	-- end
end