local _, BattleAssessment = ...

function BattleAssessment:Process(timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	local combatLogEvent = {
		timestamp = timestamp,
		eventType = eventType,
		hideCaster = hideCaster,
		sourceGUID = sourceGUID,
		sourceName = sourceName,
		sourceFlags = sourceFlags,
		sourceRaidFlags = sourceRaidFlags,
		destGUID = destGUID,
		destName = destName,
		destFlags = destFlags,
		destRaidFlags = destRaidFlags,
	}

	local eventTypeCategory = strsub(eventType, 1, 5)

	if eventTypeCategory == "SWING" then
		combatLogEvent.spellName = ACTION_SWING
	end

	if eventTypeCategory == "SPELL" then
		local spellId, spellName, spellSchool = ...
		combatLogEvent.spellID = spellId
		combatLogEvent.spellName = spellName
	end

	if eventType == "SWING_DAMAGE" then
		local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
		combatLogEvent.amount = amount
		combatLogEvent.critical = critical
	end

	if eventType == "SPELL_DAMAGE" or eventType == "SPELL_BUILDING_DAMAGE" then
		local _, _, _, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
		combatLogEvent.amount = amount
		combatLogEvent.critical = critical
	end

	if eventType == "SPELL_PERIODIC_DAMAGE" then
		local _, _, _, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
		combatLogEvent.amount = amount
		combatLogEvent.critical = critical
	end

	if eventType == "RANGE_DAMAGE" then
		local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
		combatLogEvent.spellID = spellId
		combatLogEvent.spellName = spellName
		combatLogEvent.amount = amount
		combatLogEvent.critical = critical
	end

	if eventType == "DAMAGE_SHIELD" then
		local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		combatLogEvent.spellID = spellId
		combatLogEvent.spellName = spellName
		combatLogEvent.amount = amount
		combatLogEvent.critical = critical
	end

	if eventType == "ENVIRONMENTAL_DAMAGE" then
		local environmentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		combatLogEvent.spellID = spellId
		combatLogEvent.spellName = spellName
		combatLogEvent.environmentalType = environmentalType
		combatLogEvent.amount = amount
		combatLogEvent.critical = critical
	end

	if eventType == "SPELL_HEAL" or eventType == "SPELL_BUILDING_HEAL" then
		local _, _, _, amount, overhealing, absorbed, critical = ...
		combatLogEvent.amount = amount
		combatLogEvent.overhealing = overhealing
		combatLogEvent.critical = critical
	end

	if eventType == "SPELL_ENERGIZE" then
		local _, _, _, amount, overEnergize, powerType, alternatePowerType = ...
		combatLogEvent.amount = amount
		combatLogEvent.overEnergize = overEnergize
	end

	if eventType == "SPELL_INTERRUPT" then
		local _, _, _, extraSpellId, extraSpellName, extraSpellSchool = ...
		combatLogEvent.extraSpellName = extraSpellName
	end

	if eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REMOVED" or eventType == "SPELL_AURA_REFRESH" then
		local _, _, _, auraType, remainingPoints = ...
		combatLogEvent.auraType = auraType
	end

	if eventType == "SPELL_AURA_APPLIED_DOSE" or eventType == "SPELL_AURA_REMOVED_DOSE" then
		local _, _, _, auraType, amount = ...
		combatLogEvent.auraType = auraType
		combatLogEvent.amount = amount
	end

	if eventType == "SPELL_CAST_FAILED" then
		local _, _, _, missType = ...
		combatLogEvent.missType = missType
	end

	if eventType == "SWING_MISSED" then
		local missType, isOffHand, amountMissed, critical = ...
		combatLogEvent.missType = missType
	end

	if eventType == "RANGE_MISSED" then
		local spellId, spellName, spellSchool, missType, isOffHand, amountMissed, critical = ...
		combatLogEvent.missType = missType
	end

	if eventType == "SPELL_MISSED" then
		local _, _, _, missType, isOffHand, amountMissed, critical = ...
		combatLogEvent.missType = missType
	end

	if eventType == "UNIT_DIED" or eventType == "UNIT_DESTROYED" or eventType == "UNIT_DISSIPATES" then
		local recapID, unconsciousOnDeath = ...
	end

	return combatLogEvent
end
