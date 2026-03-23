require "JaysServerLoot/config"

local parsedItems = {}
local initialized = false

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

local function onZombieDead(zombie)
    if not initialized or #parsedItems == 0 then return end

    local ok, body = pcall(function() return zombie:getInventory() end)
    if not ok or not body then return end

    local rolls = JaysServerLoot.ExtraRolls or 1
    for roll = 1, rolls do
        for _, item in ipairs(parsedItems) do
            if ZombRand(10000) < (item.chance * 10000) then
                local addOk, err = pcall(function()
                    body:AddItem(item.id)
                end)
                if not addOk then
                    print("[JaysServerLoot] WARNING: Failed to add '" .. item.id .. "': " .. tostring(err))
                end
            end
        end
    end
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

Events.OnGameStart.Add(onGameStart)
Events.OnZombieDead.Add(onZombieDead)
