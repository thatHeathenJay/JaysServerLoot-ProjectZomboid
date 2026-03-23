require "JaysServerLoot/config"

local parsedItems = {}
local initialized = false
local pendingSyncs = {} -- items added but not yet synced to clients

local function parseItemString(str)
    local items = {}
    if not str or str == "" then return items end

    for entry in str:gmatch("[^;]+") do
        entry = entry:match("^%s*(.-)%s*$")
        local itemID, chanceStr = entry:match("^(.+):([%d%.]+)$")
        if itemID and chanceStr then
            itemID = itemID:match("^%s*(.-)%s*$")
            local chance = tonumber(chanceStr)
            if chance and chance > 0 and chance <= 1.0 then
                local ok, scriptItem = pcall(function()
                    return ScriptManager.instance:getItem(itemID)
                end)
                if ok and scriptItem then
                    table.insert(items, { id = itemID, chance = chance })
                    print("[JaysServerLoot] Registered: " .. itemID .. " at " .. (chance * 100) .. "% per roll")
                else
                    print("[JaysServerLoot] WARNING: Item '" .. itemID .. "' not found in game. Skipping.")
                end
            else
                print("[JaysServerLoot] WARNING: Invalid chance '" .. tostring(chanceStr) .. "' for '" .. tostring(itemID) .. "'. Must be 0.0-1.0. Skipping.")
            end
        else
            if entry ~= "" then
                print("[JaysServerLoot] WARNING: Could not parse entry '" .. entry .. "'. Expected format: Module.ItemID:chance")
            end
        end
    end

    return items
end

local function trySyncItem(body, item)
    local ok = pcall(sendAddItemToContainer, body, item)
    return ok
end

local function onZombieDead(zombie)
    if not initialized or #parsedItems == 0 then return end

    local ok, body = pcall(function() return zombie:getInventory() end)
    if not ok or not body then return end

    local rolls = JaysServerLoot.ExtraRolls or 1
    for roll = 1, rolls do
        for _, item in ipairs(parsedItems) do
            if ZombRand(10000) < (item.chance * 10000) then
                local addOk, added = pcall(function()
                    local a = body:AddItem(item.id)
                    if a and a.setUsedDelta then
                        a:setUsedDelta(ZombRandFloat(0.2, 1.0))
                    end
                    return a
                end)
                if addOk and added then
                    if not trySyncItem(body, added) then
                        table.insert(pendingSyncs, { body = body, item = added, retries = 0 })
                    end
                end
            end
        end
    end
end

local function onTick()
    if #pendingSyncs == 0 then return end

    local remaining = {}
    for _, entry in ipairs(pendingSyncs) do
        if not trySyncItem(entry.body, entry.item) then
            entry.retries = entry.retries + 1
            if entry.retries < 60 then
                table.insert(remaining, entry)
            end
        end
    end
    pendingSyncs = remaining
end

local function onGameStart()
    local ok, err = pcall(function()
        parsedItems = parseItemString(JaysServerLoot.Items)
        initialized = true

        local rolls = JaysServerLoot.ExtraRolls or 1
        print("[JaysServerLoot] Initialized with " .. #parsedItems .. " item(s), " .. rolls .. " extra roll(s) per zombie")
    end)
    if not ok then
        print("[JaysServerLoot] ERROR: Failed to initialize: " .. tostring(err))
        initialized = false
    end
end

Events.OnInitGlobalModData.Add(onGameStart)
Events.OnZombieDead.Add(onZombieDead)
Events.OnTick.Add(onTick)
