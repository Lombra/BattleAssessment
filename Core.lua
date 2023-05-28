local Libra = LibStub("Libra")

local BattleAssessment = Libra:NewAddon(...)
Libra:Embed(BattleAssessment)

local combatLog = { }
BattleAssessment.combatLog = combatLog


SLASH_BATTLE_ASSESSMENT1 = "/ba"
SlashCmdList["BATTLE_ASSESSMENT"] = function()
	ToggleFrame(BattleAssessment.ui)
end


function BattleAssessment:AddCombatEvent(...)
	table.insert(combatLog, BattleAssessment:Process(...))
end

function BattleAssessment:FetchCombatEvents()
	wipe(combatLog)

	CombatLogResetFilter()
	for i = 1, CombatLogGetNumEntries() do
		CombatLogSetCurrentEntry(i)
		self:AddCombatEvent(CombatLogGetCurrentEntry())
	end
end
