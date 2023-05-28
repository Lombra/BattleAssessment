local Libra = LibStub("Libra")

local COMBAT_EVENT_FETCH_BATCH_SIZE = 100

local BattleAssessment = Libra:NewAddon(...)
Libra:Embed(BattleAssessment)

local combatLog = { }
BattleAssessment.combatLog = combatLog


SLASH_BATTLE_ASSESSMENT1 = "/ba"
SlashCmdList["BATTLE_ASSESSMENT"] = function()
	ToggleFrame(BattleAssessment.ui)
end

AddonCompartmentFrame:RegisterAddon({
	text = "BattleAssessment",
	icon = [[Interface\Icons\Ability_Racial_CombatAnalysis]],
	notCheckable = true,
	func = function()
		ToggleFrame(BattleAssessment.ui)
	end,
})


function BattleAssessment:AddCombatEvent(...)
	table.insert(combatLog, BattleAssessment:Process(...))
end

function BattleAssessment:FetchCombatEvents()
	wipe(combatLog)

	CombatLogResetFilter()

	local isValid = CombatLogSetCurrentEntry(1)
	if isValid then
		self.ui.overlay:Show()
		self.ui.progressBar:SetMinMaxValues(0, CombatLogGetNumEntries())
		self.ui.progressBar:SetValue(0)
		self.ui:SetScript("OnUpdate", function(self)
			local n = 0
			for i = 1, COMBAT_EVENT_FETCH_BATCH_SIZE do
				local isValid = CombatLogAdvanceEntry(1, true)
				if not isValid then
					self.overlay:Hide()
					self:SetScript("OnUpdate", nil)
					BattleAssessment:Update()
					return
				end
				BattleAssessment:AddCombatEvent(CombatLogGetCurrentEntry())
				n = n + 1
			end
			self.progressBar:SetValue(self.progressBar:GetValue() + n)
		end)
	end
end
