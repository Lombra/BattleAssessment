local NUM_ROWS = 30
local BUTTON_HEIGHT = 18

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

local function createColumnHeader(parent)
	local btn = CreateFrame("Button", nil, parent)
	btn:SetNormalFontObject("GameFontNormalSmall")
	
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
	
	return btn
end

local columns = {
	{
		name = "timestamp",
		label = "Timestamp",
		width = 90,
	},
	{
		name = "eventType",
		label = "Event type",
	},
	{
		name = "source",
		label = "Source",
		filterKey = "sourceGUID",
	},
	{
		name = "spell",
		label = "Spell",
		filterKey = "spellID",
		width = 160,
	},
	{
		name = "target",
		label = "Target",
		filterKey = "destGUID",
	},
	{
		name = "detail",
		label = "Details",
		justifyText = "RIGHT",
	},
}

for i, column in ipairs(columns) do
	local btn = createColumnHeader(addon)
	btn:SetID(i)
	btn:SetWidth((column.width or 150) + 2)
	btn:SetHeight(24)
	if i == 1 then
		btn:SetPoint("TOPLEFT", 4, -32)
	else
		btn:SetPoint("LEFT", headers[i - 1], "RIGHT", -2, 0)
	end
	btn:SetText(column.label)
	headers[i] = btn
	headers[column.name] = btn
end

local function createRow()
end

local function onClick(self)
	if filters[self.filterKey] == self.filterValue then
		filters[self.filterKey] = nil
		headers[self.columnName]:SetNormalFontObject("GameFontNormalSmall")
	else
		filters[self.filterKey] = self.filterValue
		headers[self.columnName]:SetNormalFontObject("GameFontGreenSmall")
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
	data.timestamp = data[1]
	data.eventType = data[2]
	data.sourceGUID = data[4]
	data.sourceName = data[5]
	data.sourceFlags = data[6]
	data.destGUID = data[8]
	data.destName = data[9]
	data.destFlags = data[10]
	if strsub(data.eventType, 1, 5) == "SPELL" then
		data.spellID = data[12]
		data.spellName = data[13]
	end
	self.timestamp:SetText(date("%X", data.timestamp)..strsub(format("%.3f", data.timestamp % 1), 2))
	self.eventType:SetText(data.eventType)
	self.source:SetText(data.sourceName)
	if bit.band(data.sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= 0 then
		self.source.text:SetTextColor(1.0, 0.25, 0.25)
	else
		self.source.text:SetTextColor(1.0, 1.0, 1.0)
		end
	self.target:SetText(data.destName)
	if bit.band(data.destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= 0 then
		self.target.text:SetTextColor(1.0, 0.25, 0.25)
	else
		self.target.text:SetTextColor(1.0, 1.0, 1.0)
	end
	self.spell:SetText(data.spellName)
	-- self.index = index

	for i, cell in ipairs(self.cells) do
		cell.filterValue = data[cell.filterKey]
	end
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
	for y, column in ipairs(columns) do
		local btn = createCell(row)
		btn:SetWidth(column.width or 150)
		btn:SetHeight(BUTTON_HEIGHT)
		btn.text:SetJustifyH(column.justifyText or "LEFT")
		if y == 1 then
			btn:SetPoint("LEFT")
		else
			btn:SetPoint("LEFT", row[y - 1], "RIGHT")
		end
		btn.column = y
		btn.filterKey = column.filterKey or column.name
		btn.columnName = column.name
		line[y] = btn
		row[y] = btn
		row[column.name] = btn
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
	for i, combatEvent in ipairs(combatLog) do
		local include = true
		for arg, filterValue in pairs(filters) do
			if combatEvent[arg] ~= filterValue then
				include = false
				break
			end
		end
		if include then
			tinsert(results, combatEvent)
		end
	end
	scroll:Update()
	-- for row = 1, #combatLog do
		-- self:UpdateRow(row)
	-- end
end
