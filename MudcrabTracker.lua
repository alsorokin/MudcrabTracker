local CRABS_ADDON_NAME = "MudcrabTracker"
local CRABS_DB_VERSION = "0.0.1"
local crabs_db
local clientLang = GetCVar("language.2")

local localizedStrings = {
	["en"] = {
		MUDCRAB_TRACKER_LABEL = "Crab score: %s",
		CHAT_MESSAGE_MUDCRAB_KILLED = "You killed %s. Total crab score: %s",
		CHAT_MESSAGE_BOSS_KILLED = "You have defeated %s for %s points! Total crab score: %s",
		CHAT_MESSAGE_TRACKER_TOGGLE_ON = "Mudcrab Tracker is now visible.",
		CHAT_MESSAGE_TRACKER_TOGGLE_OFF = "Mudcrab Tracker is now hidden.",
		CHAT_MESSAGE_CRABSTAT = "Crab score: %s",
	},
	["de"] = {
		MUDCRAB_TRACKER_LABEL = "Krabbenscore: %s",
		CHAT_MESSAGE_MUDCRAB_KILLED = "Du hast %s getötet. Krabbenscore: %s",
		CHAT_MESSAGE_BOSS_KILLED = "Du hast %s besiegt und %s Punkte erhalten! Krabbenscore: %s",
		CHAT_MESSAGE_TRACKER_TOGGLE_ON = "Mudcrab Tracker ist jetzt sichtbar.",
		CHAT_MESSAGE_TRACKER_TOGGLE_OFF = "Mudcrab Tracker ist jetzt versteckt.",
		CHAT_MESSAGE_CRABSTAT = "Krabbenscore: %s",
	},
	["ru"] = {
		MUDCRAB_TRACKER_LABEL = "Очки крабов: %s",
		CHAT_MESSAGE_MUDCRAB_KILLED = "%s убит. Очки крабов: %s",
		CHAT_MESSAGE_BOSS_KILLED = "Вы победили %s и получили %s очков! Очки крабов: %s",
		CHAT_MESSAGE_TRACKER_TOGGLE_ON = "Трекер грязекрабов теперь виден.",
		CHAT_MESSAGE_TRACKER_TOGGLE_OFF = "Трекер грязекрабов теперь скрыт.",
		CHAT_MESSAGE_CRABSTAT = "Очки крабов: %s",
	},
}
local L = localizedStrings[clientLang] or localizedStrings["en"]

local crabNames = {
    -- English
    ["en"] = {
        ["Mudcrab"] = 1,
        ["Coral Crab"] = 1,
        ["Hermit Crab"] = 1,
		["Swarming Mudcrab"] = 1,
		["Clatterclaw"] = 15,
		["Grotto Mudcrab Swarmer Minions"] = 1,
    },
    -- German
    ["de"] = {
        ["Schlammkrabbe"] = 1,
        ["Korallenkrabbe"] = 1,
        ["Einsiedlerkrabbe"] = 1,
		["Schwärmende Schlammkrabbe"] = 1,
		["Klapperschere"] = 15,
		["Schwärmende Schlammkrabben"] = 1,
    },
    -- Russian
    ["ru"] = {
        ["Грязевой краб"] = 1,
        ["Коралловый краб"] = 1,
        ["Краб-отшельник"] = 1,
		["Грязевой краб из стаи"] = 1,
		["Щелкун"] = 15,
		["Помощники из стаи грязевого краба грота"] = 1,
    },
}
local crabsOfClientLang = crabNames[clientLang]
if crabsOfClientLang == nil then
    return
end


local function print(msg)
	CHAT_SYSTEM:AddMessage(msg)
end

local function updateLabel()
	if not MudcrabTrackerLabel then
		return
	end
	if not MudcrabTrackerLabel:IsHidden() then
		MudcrabTrackerLabel:SetText(string.format(L.MUDCRAB_TRACKER_LABEL, crabs_db.counter))
	end
end

local function updateKillstat(targetName)
	if crabs_db.killstat[targetName] ~= nil then
		crabs_db.killstat[targetName] = crabs_db.killstat[targetName] + 1
	else
		crabs_db.killstat[targetName] = 1
	end
	-- print(targetName .. ": " .. crabs_db.killstat[targetName])
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

		-- local trimmedTargetName = targetName:gsub("%^n$", "")
		local trimmedTargetName = ZO_CachedStrFormat("<<C:1>>", targetName)
		updateKillstat(trimmedTargetName)

		local score = crabsOfClientLang[trimmedTargetName]
		if score == nil then
			return
		end
		-- Wasn't found directly via the trimmedTargetName so check partial string find -> Sloooooooooooow....
		-- comment out for now, seems to be working fine with direct name match only
    	-- if not mudCrabDetected then
        --	for possibleMudcrabNamePart, _ in pairs(crabsOfClientLang) do
	    --        if not mudCrabDetected then --security skip of loop if break below does not work
        --        	mudCrabDetected = (str_find(trimmedTargetName, possibleMudcrabNamePart, 1, true) ~= nil and true) or false
        --        	if mudCrabDetected then
	    --                break --end the for loop
        --        	end
        --    	end
        --	end
    	-- end

    	crabs_db.counter = crabs_db.counter + score
		if score == 1 then
    		print(string.format(L.CHAT_MESSAGE_MUDCRAB_KILLED, trimmedTargetName, tostring(crabs_db.counter)))
		else
			print(string.format(L.CHAT_MESSAGE_BOSS_KILLED, trimmedTargetName, tostring(score), tostring(crabs_db.counter)))
		end
    	updateLabel()
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

	updateLabel()
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
		print(string.format(L.CHAT_MESSAGE_CRABSTAT, tostring(crabs_db.counter)))
	end

	SLASH_COMMANDS["/togglecrabs"] = function()
		if MudcrabTrackerLabel:IsHidden() then
			MudcrabTrackerLabel:SetHidden(false)
			updateLabel()
			print(L.CHAT_MESSAGE_TRACKER_TOGGLE_ON)
		else
			MudcrabTrackerLabel:SetHidden(true)
			print(L.CHAT_MESSAGE_TRACKER_TOGGLE_OFF)
		end
	end
end

EVENT_MANAGER:RegisterForEvent(CRABS_ADDON_NAME .. "_start", EVENT_ADD_ON_LOADED, onAddOnLoaded)

