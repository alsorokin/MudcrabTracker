local ADDON_NAME = "MudcrabTracker"
local ADDON_VERSION = "0.0.1"
local db

local function Print(msg)
    CHAT_SYSTEM:AddMessage(msg)
end

local function UpdateLabel()
    MudcrabTrackerLabel:SetText("Mudcrabs killed: " .. db.counter)
end

local function onAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    local defaults = {
        counter = 0
    }

    db = ZO_SavedVars:NewAccountWide("db", ADDON_VERSION, nil, defaults)

    UpdateLabel()
end

local function onCombatEvent(_eventCode_, result, _isError_, _abilityName_, _abilityGraphic_, _abilityActionSlotType_, _sourceName_,
        _sourceType_, targetName, _targetType_, _hitValue_, _powerType_, _damageType_, _log_, _sourceUnitId_, _targetUnitId_,
        _abilityId_, _overflow_)
    if result == ACTION_RESULT_DIED_XP or result == ACTION_RESULT_DIED then
        if targetName == "Mudcrab" then
            Print(targetName .. " died")
            db.counter = db.counter + 1
            UpdateLabel()
        end
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_start", EVENT_ADD_ON_LOADED, onAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_combat_player", EVENT_COMBAT_EVENT, onCombatEvent)
EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "_combat_player", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)