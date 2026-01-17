local CRABS_ADDON_NAME = "MudcrabTracker"
local CRABS_DB_VERSION = "0.0.1"
local crabs_db
local clientLang = GetCVar("language.2")
local DEFAULT_CRABS_LABEL_LEFT = 10
local DEFAULT_CRABS_LABEL_TOP = 30
local cumulativeScore = 0
local cumulativeCrabs = 0

local playerTitles = {
	["en"] = {
		{ threshold = 0, title = "Mudcrab Enthusiast" },
		{ threshold = 10, title = "Mudcrab Wrangler" },
		{ threshold = 100, title = "Mudcrab Hunter" },
		{ threshold = 250, title = "Mudcrab Exterminator" },
		{ threshold = 500, title = "Mudcrab Slayer" },
		{ threshold = 1000, title = "Mudcrab Vanquisher" },
		{ threshold = 2500, title = "Mudcrab Conqueror" },
		{ threshold = 5000, title = "Mudcrab Champion" },
		{ threshold = 10000, title = "Mudcrab Legend" },
		{ threshold = 100000, title = "Mudcrab Lord" },
		{ threshold = 1000000, title = "Mudcrab Deity" },
	},
	["de"] = {
		{ threshold = 0, title = "Schlammkrabben-Enthusiast" },
		{ threshold = 10, title = "Schlammkrabben-Hüter" },
		{ threshold = 100, title = "Schlammkrabben-Jäger" },
		{ threshold = 250, title = "Schlammkrabben-Ausrotter" },
		{ threshold = 500, title = "Schlammkrabben-Schlächter" },
		{ threshold = 1000, title = "Schlammkrabben-Besieger" },
		{ threshold = 2500, title = "Schlammkrabben-Eroberer" },
		{ threshold = 5000, title = "Schlammkrabben-Champion" },
		{ threshold = 10000, title = "Schlammkrabben-Legende" },
		{ threshold = 100000, title = "Schlammkrabben-Lord" },
		{ threshold = 1000000, title = "Schlammkrabben-Gottheit" },
	},
	["ru"] = {
		{ threshold = 0, title = "Любитель Грязекрабов" },
		{ threshold = 10, title = "Укротитель Грязекрабов" },
		{ threshold = 100, title = "Охотник на Грязекрабов" },
		{ threshold = 250, title = "Истребитель Грязекрабов" },
		{ threshold = 500, title = "Убийца Грязекрабов" },
		{ threshold = 1000, title = "Победитель Грязекрабов" },
		{ threshold = 2500, title = "Завоеватель Грязекрабов" },
		{ threshold = 5000, title = "Чемпион Грязекрабов" },
		{ threshold = 10000, title = "Легенда Грязекрабов" },
		{ threshold = 100000, title = "Властелин Грязекрабов" },
		{ threshold = 1000000, title = "Грязекрабий Бог" },
	},
}
local titlesOfClientLang = playerTitles[clientLang]
local lastPlayerTitle = ""

local localizedStrings = {
	["en"] = {
		MUDCRAB_TRACKER_LABEL = "Crab score: %s",
		MUDCRAB_TRACKER_TITLE = "Title: %s",
		CHAT_MESSAGE_MUDCRAB_KILLED = "You killed |cAAAAFF%s|r. Total crab score: |cAAAAFF%s|r",
		CHAT_MESSAGE_BOSS_KILLED = "At last. The shores are free from this terror you call... |cAAAAFF%s|r. You earned |cAAAAFF%s|r points! Total crab score: |cAAAAFF%s|r",
		CHAT_MESSAGE_TRACKER_TOGGLE_ON = "Mudcrab Tracker is now visible.",
		CHAT_MESSAGE_TRACKER_TOGGLE_OFF = "Mudcrab Tracker is now hidden.",
		CHAT_MESSAGE_CRABSTAT = "Crab score: |cAAAAFF%s|r. You are a |cAAAAFF%s|r!",
		CHAT_MESSAGE_MULTIPLE_CRABS_KILLED = "You killed |cAAAAFF%s|r crabs, good job! Total crab score: |cAAAAFF%s|r",
		CHAT_MESSAGE_CRABS_TO_CHAT = "[MudcrabTracker] My crab score is: %s. I'm a %s!",
		CHAT_MESSAGE_NEW_TITLE = "You have attained a new crab title. You are now |cAAAAFF%s|r!",
		CHAT_MESSAGE_NEXT_TITLE = "Crab score needed for next title: |cAAAAFF%s|r",
	},
	["de"] = {
		MUDCRAB_TRACKER_LABEL = "Krabbenscore: |cAAAAFF%s|r",
		MUDCRAB_TRACKER_TITLE = "Titel: |cAAAAFF%s|r",
		CHAT_MESSAGE_MUDCRAB_KILLED = "Du hast |cAAAAFF%s|r getötet. Krabbenscore: |cAAAAFF%s|r",
		CHAT_MESSAGE_BOSS_KILLED = "Endlich. Die Ufer sind frei von diesen Schrecken, die ihr ... |cAAAAFF%s|r nennt. Du hast |cAAAAFF%s|r Punkte erhalten! Krabbenscore: |cAAAAFF%s|r",
		CHAT_MESSAGE_TRACKER_TOGGLE_ON = "Mudcrab Tracker ist jetzt sichtbar.",
		CHAT_MESSAGE_TRACKER_TOGGLE_OFF = "Mudcrab Tracker ist jetzt versteckt.",
		CHAT_MESSAGE_CRABSTAT = "Krabbenscore: |cAAAAFF%s|r. Du bist ein |cAAAAFF%s|r!",
		CHAT_MESSAGE_MULTIPLE_CRABS_KILLED = "Du hast |cAAAAFF%s|r Krabben getötet, gut gemacht! Krabbenscore: |cAAAAFF%s|r",
		CHAT_MESSAGE_CRABS_TO_CHAT = "[MudcrabTracker] Mein Krabbenscore ist: %s. Ich bin ein %s!",
		CHAT_MESSAGE_NEW_TITLE = "Du hast einen neuen Krabbentitel erreicht. Du bist jetzt |cAAAAFF%s|r!",
		CHAT_MESSAGE_NEXT_TITLE = "Krabbenscore für den nächsten Titel benötigt: |cAAAAFF%s|r",
	},
	["ru"] = {
		MUDCRAB_TRACKER_LABEL = "Очки крабов: |cAAAAFF%s|r",
		MUDCRAB_TRACKER_TITLE = "Звание: |cAAAAFF%s|r",
		CHAT_MESSAGE_MUDCRAB_KILLED = "|cAAAAFF%s|r убит. Очки крабов: |cAAAAFF%s|r",
		CHAT_MESSAGE_BOSS_KILLED = "Наконец этот берег свободен от напасти, имя которой... |cAAAAFF%s|r. Вы заработали |cAAAAFF%s|r очков! Очки крабов: |cAAAAFF%s|r",
		CHAT_MESSAGE_TRACKER_TOGGLE_ON = "Трекер грязекрабов теперь виден.",
		CHAT_MESSAGE_TRACKER_TOGGLE_OFF = "Трекер грязекрабов теперь скрыт.",
		CHAT_MESSAGE_CRABSTAT = "Очки крабов: |cAAAAFF%s|r. Вы |cAAAAFF%s|r!",
		CHAT_MESSAGE_MULTIPLE_CRABS_KILLED = "Вы убили |cAAAAFF%s|r крабов, хорошая работа! Очки крабов: |cAAAAFF%s|r",
		CHAT_MESSAGE_CRABS_TO_CHAT = "[MudcrabTracker] Мои очки крабов: %s. Я %s!",
		CHAT_MESSAGE_NEW_TITLE = "Вы получили новое крабозвание. Вы теперь |cAAAAFF%s|r!",
		CHAT_MESSAGE_NEXT_TITLE = "Для следующего крабозвания нужно набрать |cAAAAFF%s|r очков крабов.",
	},
}
local L = localizedStrings[clientLang] or localizedStrings["en"]

local crabNames = {
	-- English
	["en"] = {
		["Mudcrab"] = 1, -- the regular one
		["Coral Crab"] = 1, -- Summerset and High Isle mudcrab
		["Hermit Crab"] = 1, -- High Isle critter
		["Swarming Mudcrab"] = 1, -- Fungal Grotto trash mob
		["Clatterclaw"] = 15, -- Fungal Grotto boss
		["Grotto Mudcrab Swarmer Minions"] = 1, -- Fungal Grotto boss minions
		["Queen of the Reef"] = 15, -- Summerset boss
		["Coral Mudcrab"] = 1, -- Summerset boss minions
		["Mud Crab"] = 1, -- Solstice temple
		["Gravelclaw"] = 1, -- Craglorn
		["Colossal Coral Crab"] = 5, -- Solstice
		["Tidespite"] = 15, -- Solstice boss
	},
	-- German
	["de"] = {
		["Schlammkrabbe"] = 1,
		["Korallenkrabbe"] = 1,
		["Einsiedlerkrabbe"] = 1,
		["Schwärmende Schlammkrabbe"] = 1,
		["Klapperschere"] = 15,
		["Schwärmende Schlammkrabben"] = 1,
		["Die Königin des Riffs"] = 15,
		-- ["Korallenkrabbe"] = 1,
		-- ["Schlammkrabbe"] = 1,
		["Schotterkralle"] = 1,
		["Kolossale Korallenkrabbe"] = 5,
		["Gezeitentücke"] = 15,
	},
	-- Russian
	["ru"] = {
		["Грязевой краб"] = 1,
		["Коралловый краб"] = 1,
		["Краб-отшельник"] = 1,
		["Грязевой краб из стаи"] = 1,
		["Щелкун"] = 15,
		["Помощники из стаи грязевого краба грота"] = 1,
		["Королева Рифа"] = 15,
		["Коралловый грязевой краб"] = 1,
		-- ["Грязевой краб"] = 1,
		["Гравийный краб"] = 1,
		["Огромный коралловый краб"] = 5,
		["Злоба Прилива"] = 15,
	},
}
local crabsOfClientLang = crabNames[clientLang]
if crabsOfClientLang == nil then
	-- exit if language is unsupported
	return
end

local function print(msg)
	CHAT_SYSTEM:AddMessage(msg)
end

local function getPlayerTitleForScore(score)
	local title = ""
	for _, t in ipairs(titlesOfClientLang) do
		if score >= t.threshold then
			title = t.title
		else
			break
		end
	end
	return title
end

local function getRequiredScoreForNextTitle(currentScore)
	local requiredScore = nil
	for _, t in ipairs(titlesOfClientLang) do
		if t.threshold > currentScore then
			if requiredScore == nil or t.threshold < requiredScore then
				requiredScore = t.threshold
			end
		end
	end
	return requiredScore
end

local function updateLabel()
	if not MudcrabTrackerIndicator or MudcrabTrackerIndicator:IsHidden() then
		return
	end

	MudcrabTrackerIndicatorLabel:SetText(string.format(L.MUDCRAB_TRACKER_LABEL, crabs_db.counter))
	MudcrabTrackerIndicatorTitleLabel:SetText(
		string.format(L.MUDCRAB_TRACKER_TITLE, getPlayerTitleForScore(crabs_db.counter))
	)
end

local function updateCrabKillstat(targetName)
	if crabs_db.crabKillstat[targetName] ~= nil then
		crabs_db.crabKillstat[targetName] = crabs_db.crabKillstat[targetName] + 1
	else
		crabs_db.crabKillstat[targetName] = 1
	end
end

local function onCrabKilled(targetName, score)
	updateCrabKillstat(targetName)
	cumulativeScore = cumulativeScore + score
	cumulativeCrabs = cumulativeCrabs + 1

	EVENT_MANAGER:RegisterForUpdate(CRABS_ADDON_NAME .. "CrabKillDebounce", 5000, function()
		EVENT_MANAGER:UnregisterForUpdate(CRABS_ADDON_NAME .. "CrabKillDebounce")
		local isFirstKill = crabs_db.counter == 0
		crabs_db.counter = crabs_db.counter + cumulativeScore
		if cumulativeCrabs == 1 then
			if cumulativeScore == 1 then
				print(string.format(L.CHAT_MESSAGE_MUDCRAB_KILLED, targetName, tostring(crabs_db.counter)))
			else
				print(
					string.format(L.CHAT_MESSAGE_BOSS_KILLED, targetName, tostring(score), tostring(crabs_db.counter))
				)
			end
		else
			print(
				string.format(
					L.CHAT_MESSAGE_MULTIPLE_CRABS_KILLED,
					tostring(cumulativeCrabs),
					tostring(crabs_db.counter)
				)
			)
		end
		local newPlayerTitle = getPlayerTitleForScore(crabs_db.counter)
		if newPlayerTitle ~= lastPlayerTitle or isFirstKill then
			lastPlayerTitle = newPlayerTitle
			print(string.format(L.CHAT_MESSAGE_NEW_TITLE, newPlayerTitle))
			local nextTitleScore = getRequiredScoreForNextTitle(crabs_db.counter)
			if nextTitleScore ~= nil and nextTitleScore > crabs_db.counter then
				print(string.format(L.CHAT_MESSAGE_NEXT_TITLE, tostring(nextTitleScore)))
			end
		end
		cumulativeScore = 0
		cumulativeCrabs = 0
		updateLabel()
	end)
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
	if not targetName or targetName == "" then
		return
	end

	local trimmedTargetName = ZO_CachedStrFormat("<<C:1>>", targetName)
	local score = crabsOfClientLang[trimmedTargetName]
	if score == nil then
		return
	end

	onCrabKilled(trimmedTargetName, score)
end

local function restoreIndicatorPosition()
	if crabs_db.counterPosition == nil then
		crabs_db.counterPosition = {
			left = DEFAULT_CRABS_LABEL_LEFT,
			top = DEFAULT_CRABS_LABEL_TOP,
		}
	end
	local left = crabs_db.counterPosition.left
	local top = crabs_db.counterPosition.top

	MudcrabTrackerIndicator:ClearAnchors()
	MudcrabTrackerIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function toggleIndicatorOnSceneChange(currentScene)
	if not crabs_db.counterEnabled then
		return
	end

	if currentScene == SCENE_SHOWING then
		MudcrabTrackerIndicator:SetHidden(false)
	else
		MudcrabTrackerIndicator:SetHidden(true)
	end
end

local function crabStatToChat()
	local statString = string.format(
		L.CHAT_MESSAGE_CRABS_TO_CHAT,
		tostring(crabs_db.counter),
		getPlayerTitleForScore(crabs_db.counter)
	)
	CHAT_SYSTEM.textEntry.editControl:InsertText(statString)
end

local function resetCrabScore()
	crabs_db.counter = 0
	crabs_db.crabKillstat = {}
	updateLabel()
end

local function doCrabsDbMigrations(db)
	-- ensure crabKillstat exists
	if db.crabKillstat == nil then
		db.crabKillstat = {}
	end

	-- migrate old killstat to crabKillstat
	if db.killstat ~= nil then
		for k, v in pairs(db.killstat) do
			if crabsOfClientLang[k] ~= nil then
				db.crabKillstat[k] = v
			end
		end
	end
	-- killstat is deprecated, so erase it to not waste space
	db.killstat = nil
end

local function onAddOnLoaded(_, addonName)
	if addonName ~= CRABS_ADDON_NAME then
		return
	end

	local defaults = {
		counter = 0,
		killstat = nil,
		crabKillstat = {},
		counterEnabled = false,
		counterPosition = {
			left = DEFAULT_CRABS_LABEL_LEFT,
			top = DEFAULT_CRABS_LABEL_TOP,
		},
	}

	crabs_db = ZO_SavedVars:NewAccountWide("MudcrabTracker_db", CRABS_DB_VERSION, nil, defaults)
	doCrabsDbMigrations(crabs_db)
	lastPlayerTitle = getPlayerTitleForScore(crabs_db.counter)

	updateLabel()
	restoreIndicatorPosition()
	if crabs_db.counterEnabled then
		MudcrabTrackerIndicator:SetHidden(false)
	else
		MudcrabTrackerIndicator:SetHidden(true)
	end

	--register for events
	-- skip registering for player and player pet because only registering for companion somehow works even if no companion is unlocked
	EVENT_MANAGER:RegisterForEvent(CRABS_ADDON_NAME .. "_combat_companion_died_xp", EVENT_COMBAT_EVENT, onCombatEvent)
	EVENT_MANAGER:AddFilterForEvent(
		CRABS_ADDON_NAME .. "_combat_companion_died_xp",
		EVENT_COMBAT_EVENT,
		REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
		COMBAT_UNIT_TYPE_COMPANION,
		REGISTER_FILTER_COMBAT_RESULT,
		ACTION_RESULT_DIED_XP
	)
	EVENT_MANAGER:RegisterForEvent(CRABS_ADDON_NAME .. "_combat_companion_died", EVENT_COMBAT_EVENT, onCombatEvent)
	EVENT_MANAGER:AddFilterForEvent(
		CRABS_ADDON_NAME .. "_combat_companion_died",
		EVENT_COMBAT_EVENT,
		REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
		COMBAT_UNIT_TYPE_COMPANION,
		REGISTER_FILTER_COMBAT_RESULT,
		ACTION_RESULT_DIED
	)

	SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", toggleIndicatorOnSceneChange)
	SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", toggleIndicatorOnSceneChange)

	-- Slash Commands
	SLASH_COMMANDS["/crabs"] = function()
		if not crabs_db then
			return
		end
		print(
			string.format(L.CHAT_MESSAGE_CRABSTAT, tostring(crabs_db.counter), getPlayerTitleForScore(crabs_db.counter))
		)
	end

	SLASH_COMMANDS["/togglecrabs"] = function()
		if not crabs_db then
			return
		end
		if crabs_db.counterEnabled then
			MudcrabTrackerIndicator:SetHidden(true)
			crabs_db.counterEnabled = false
			print(L.CHAT_MESSAGE_TRACKER_TOGGLE_OFF)
		else
			MudcrabTrackerIndicator:SetHidden(false)
			crabs_db.counterEnabled = true
			updateLabel()
			print(L.CHAT_MESSAGE_TRACKER_TOGGLE_ON)
		end
	end

	SLASH_COMMANDS["/crabstochat"] = function()
		crabStatToChat()
	end

	SLASH_COMMANDS["/resetcrabs"] = function()
		resetCrabScore()
	end
end

function MudcrabTracker_OnCounterMoveStop()
	crabs_db.counterPosition.left = MudcrabTrackerIndicator:GetLeft()
	crabs_db.counterPosition.top = MudcrabTrackerIndicator:GetTop()
end

EVENT_MANAGER:RegisterForEvent(CRABS_ADDON_NAME .. "_start", EVENT_ADD_ON_LOADED, onAddOnLoaded)
