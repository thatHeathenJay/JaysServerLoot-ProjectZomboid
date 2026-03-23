require "JaysServerLoot/config"

local parsedItems = {}
local initialized = false
local pendingLoot = {} -- deferred items waiting for valid grid square

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

local function rollLoot()
    local wonItems = {}
    local rolls = JaysServerLoot.ExtraRolls or 1
    for roll = 1, rolls do
        for _, item in ipairs(parsedItems) do
            if ZombRand(10000) < (item.chance * 10000) then
                table.insert(wonItems, item.id)
            end
        end
    end
    return wonItems
end

local function addItemToBody(body, itemID)
    local added = body:AddItem(itemID)
    if added then
        if added.setUsedDelta then
            added:setUsedDelta(ZombRandFloat(0.2, 1.0))
        end
        sendAddItemToContainer(body, added)
    end
end

local function tryAddPendingLoot(zombie, items)
    local ok, body = pcall(function() return zombie:getInventory() end)
    if not ok or not body then return false end

    local okSq, square = pcall(function() return zombie:getSquare() end)
    if not okSq or not square then return false end

    for _, itemID in ipairs(items) do
        local addOk, err = pcall(addItemToBody, body, itemID)
        if not addOk then
            print("[JaysServerLoot] WARNING: Failed to add '" .. itemID .. "': " .. tostring(err))
        end
    end
    return true
end

local function onZombieDead(zombie)
    if not initialized or #parsedItems == 0 then return end

    local wonItems = rollLoot()
    if #wonItems == 0 then return end

    if not tryAddPendingLoot(zombie, wonItems) then
        table.insert(pendingLoot, { zombie = zombie, items = wonItems, retries = 0 })
    end
end

local function onTick()
    if #pendingLoot == 0 then return end

    local remaining = {}
    for _, entry in ipairs(pendingLoot) do
        local ok = pcall(function()
            if tryAddPendingLoot(entry.zombie, entry.items) then
                return
            end
            entry.retries = entry.retries + 1
            if entry.retries < 30 then
                table.insert(remaining, entry)
            else
                print("[JaysServerLoot] WARNING: Gave up adding loot after 30 retries")
            end
        end)
        if not ok then
            entry.retries = entry.retries + 1
            if entry.retries < 30 then
                table.insert(remaining, entry)
            end
        end
    end
    pendingLoot = remaining
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
