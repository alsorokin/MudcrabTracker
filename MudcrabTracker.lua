local CRABS_ADDON_NAME = "MudcrabTracker"
local CRABS_DB_VERSION = "0.0.1"
local crabs_db

local function Print(msg)
	CHAT_SYSTEM:AddMessage(msg)
end

local function UpdateLabel()
	if not MudcrabTrackerLabel then
		return
	end
	if not MudcrabTrackerLabel:IsHidden() then
		MudcrabTrackerLabel:SetText("Mudcrabs killed: " .. crabs_db.counter)
	end
end

local function UpdateKillstat(targetName)
	if crabs_db.killstat[targetName] ~= nil then
		crabs_db.killstat[targetName] = crabs_db.killstat[targetName] + 1
	else
		crabs_db.killstat[targetName] = 1
	end
	-- Print(targetName .. ": " .. crabs_db.killstat[targetName])
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
			crabs_db.counter = crabs_db.counter + 1
			Print("You killed a mudcrab! Total crabs killed: " .. crabs_db.counter)
			UpdateLabel()
			--else
			--	Print(trimmedTargetName)
		end
		UpdateKillstat(trimmedTargetName)
	end
end

local function onAddOnLoaded(_, addonName)
	if addonName ~= CRABS_ADDON_NAME then
		return
	end

	local defaults = {
		counter = 0,
		killstat = {},
	}

	crabs_db = ZO_SavedVars:NewAccountWide("MudcrabTracker_db", CRABS_DB_VERSION, nil, defaults)

	UpdateLabel()
	MudcrabTrackerLabel:SetHidden(true)

	--register for events
	-- skip registering for player and player pet because only registering for companion somehow works even if no companion is unlocked
	EVENT_MANAGER:RegisterForEvent(CRABS_ADDON_NAME .. "_combat_companion", EVENT_COMBAT_EVENT, onCombatEvent)
	EVENT_MANAGER:AddFilterForEvent(
		CRABS_ADDON_NAME .. "_combat_companion",
		EVENT_COMBAT_EVENT,
		REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
		COMBAT_UNIT_TYPE_COMPANION
	)

	SLASH_COMMANDS["/crabs"] = function()
		Print("Mudcrabs exterminated: " .. crabs_db.counter)
	end

	SLASH_COMMANDS["/togglecrabs"] = function()
		if MudcrabTrackerLabel:IsHidden() then
			MudcrabTrackerLabel:SetHidden(false)
			UpdateLabel()
			Print("Mudcrab Tracker is now visible.")
		else
			MudcrabTrackerLabel:SetHidden(true)
			Print("Mudcrab Tracker is now hidden.")
		end
	end
end

EVENT_MANAGER:RegisterForEvent(CRABS_ADDON_NAME .. "_start", EVENT_ADD_ON_LOADED, onAddOnLoaded)

