local ADDON_NAME = "MudcrabTracker"
local ADDON_VERSION = "0.0.1"
local db

local function Print(msg)
	CHAT_SYSTEM:AddMessage(msg)
end

local function UpdateLabel()
	MudcrabTrackerLabel:SetText("Mudcrabs killed: " .. db.counter)
end

local function UpdateKillstat(targetName)
	if db.killstat[targetName] ~= nil then
		db.killstat[targetName] = db.killstat[targetName] + 1
	else
		db.killstat[targetName] = 1
	end
	-- Print(targetName .. ": " .. db.killstat[targetName])
end

local function onAddOnLoaded(_, addonName)
	if addonName ~= ADDON_NAME then
		return
	end

	local defaults = {
		counter = 0,
		killstat = {},
	}

	db = ZO_SavedVars:NewAccountWide("db", ADDON_VERSION, nil, defaults)

	UpdateLabel()
	MudcrabTrackerLabel:SetHidden(true)
end

local function onCombatEvent(
	_eventCode_,
	result,
	_isError_,
	_abilityName_,
	_abilityGraphic_,
	_abilityActionSlotType_,
	_sourceName_,
	_sourceType_,
	targetName,
	_targetType_,
	_hitValue_,
	_powerType_,
	_damageType_,
	_log_,
	_sourceUnitId_,
	_targetUnitId_,
	_abilityId_,
	_overflow_
)
	if (result == ACTION_RESULT_DIED_XP) or (result == ACTION_RESULT_DIED) then
		if not targetName or targetName == "" then
			return
		end

		local trimmedTargetName = targetName:gsub("%^n$", "")

		if
			-- EN
			(string.find(trimmedTargetName, "Mudcrab", 1, true) ~= nil)
			or (string.find(trimmedTargetName, "Coral Crab", 1, true) ~= nil)
			or (string.find(trimmedTargetName, "Hermit Crab", 1, true) ~= nil)
			-- RU
			or (string.find(trimmedTargetName, "Грязевой краб", 1, true) ~= nil)
			or (string.find(trimmedTargetName, "Коралловый краб", 1, true) ~= nil)
			or (string.find(trimmedTargetName, "Краб-отшельник", 1, true) ~= nil)
		then
			db.counter = db.counter + 1
			Print("You killed a mudcrab! Total crabs killed: " .. db.counter)
			UpdateLabel()
			--else
			--	Print(trimmedTargetName)
		end
		UpdateKillstat(trimmedTargetName)
	end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_start", EVENT_ADD_ON_LOADED, onAddOnLoaded)
-- EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_combat_player", EVENT_COMBAT_EVENT, onCombatEvent)
-- EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "_combat_player", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_combat_player_pet", EVENT_COMBAT_EVENT, onCombatEvent)
EVENT_MANAGER:AddFilterForEvent(
	ADDON_NAME .. "_combat_player_pet",
	EVENT_COMBAT_EVENT,
	REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
	COMBAT_UNIT_TYPE_PLAYER_PET
)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_combat_companion", EVENT_COMBAT_EVENT, onCombatEvent)
EVENT_MANAGER:AddFilterForEvent(
	ADDON_NAME .. "_combat_companion",
	EVENT_COMBAT_EVENT,
	REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
	COMBAT_UNIT_TYPE_COMPANION
)

SLASH_COMMANDS["/crabs"] = function()
	Print("Mudcrabs exterminated: " .. db.counter)
end

SLASH_COMMANDS["/togglecrabs"] = function()
	if MudcrabTrackerLabel:IsHidden() then
		MudcrabTrackerLabel:SetHidden(false)
		Print("Mudcrab Tracker is now visible.")
	else
		MudcrabTrackerLabel:SetHidden(true)
		Print("Mudcrab Tracker is now hidden.")
	end
end
