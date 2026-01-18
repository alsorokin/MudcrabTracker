local MT = MudcrabTracker

MT.LootLogger = {
	trackedItemIds = {
		71239, -- Rubedo Hide Scraps
		77591, -- Mudcrab Chitin
		114894, -- Decorative Wax
	},
	onLootReceived = function(
		_, --eventId,
		_, --receivedBy,
		itemName,
		quantity,
		_, --soundCategory,
		_, --lootType,
		lootedBySelf,
		_, --isPickpocketLoot,
		_, --questItemIcon,
		itemId,
		_ --isStolen
	)
		local isTracked = false
		for _, trackedId in ipairs(MT.LootLogger.trackedItemIds) do
			if trackedId == itemId then
				isTracked = true
				break
			end
		end

		if lootedBySelf == false or itemId == nil or not isTracked then
			return
		end

		if MT.db == nil then
			return
		end

		if MT.db.lootedItems == nil then
			MT.db.lootedItems = {}
		end
		if MT.db.lootedItems[itemId] == nil then
			MT.db.lootedItems[itemId] = 0
		end
		MT.db.lootedItems[itemId] = MT.db.lootedItems[itemId] + quantity
		MT.print("Looted " .. quantity .. " x " .. itemName .. " (Total: " .. MT.db.lootedItems[itemId] .. ")")
	end,
	startLogging = function()
		EVENT_MANAGER:RegisterForEvent("MudcrabTracker_LootLogger", EVENT_LOOT_RECEIVED, MT.LootLogger.onLootReceived)
	end,
	stopLogging = function()
		EVENT_MANAGER:UnregisterForEvent("MudcrabTracker_LootLogger", EVENT_LOOT_RECEIVED)
	end,
	init = function()
		if MT.db == nil then
			return
		end
		if MT.db.enableLootLogging then
			MT.LootLogger.startLogging()
		end
		SLASH_COMMANDS["/crablootstart"] = function()
			MT.LootLogger.startLogging()
			MT.print("Mudcrab Loot Logging Started.")
		end
		SLASH_COMMANDS["/crablootstop"] = function()
			MT.LootLogger.stopLogging()
			MT.print("Mudcrab Loot Logging Stopped.")
		end
	end,
}
