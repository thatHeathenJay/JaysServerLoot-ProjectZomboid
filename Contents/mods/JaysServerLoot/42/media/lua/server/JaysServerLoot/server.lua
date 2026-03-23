require "JaysServerLoot/config"
require "Items/SuburbsDistributions"

local initialized = false

local function modifyDistribution(distTable, itemName, newWeight)
    if not distTable or not distTable.items then return false end

    local items = distTable.items
    for i = 1, #items - 1, 2 do
        if items[i] == itemName then
            local oldWeight = items[i + 1]
            items[i + 1] = newWeight
            print("[JaysServerLoot] Modified: " .. itemName .. " weight " .. oldWeight .. " -> " .. newWeight)
            return true
        end
    end

    table.insert(items, itemName)
    table.insert(items, newWeight)
    print("[JaysServerLoot] Added: " .. itemName .. " with weight " .. newWeight)
    return true
end

local function parseAndApply()
    local str = JaysServerLoot.Items
    if not str or str == "" then
        print("[JaysServerLoot] WARNING: No items configured. Nothing to do.")
        return
    end

    local count = 0
    for entry in str:gmatch("[^;]+") do
        entry = entry:match("^%s*(.-)%s*$")
        local itemID, weightStr = entry:match("^(.+):([%d%.]+)$")
        if itemID and weightStr then
            itemID = itemID:match("^%s*(.-)%s*$")
            local weight = tonumber(weightStr)
            if weight and weight > 0 then
                local shortName = itemID:match("^Base%.(.+)$") or itemID

                local maleOk = pcall(modifyDistribution,
                    SuburbsDistributions["all"]["inventorymale"], shortName, weight)
                local femaleOk = pcall(modifyDistribution,
                    SuburbsDistributions["all"]["inventoryfemale"], shortName, weight)

                if maleOk or femaleOk then
                    count = count + 1
                else
                    print("[JaysServerLoot] WARNING: Could not modify distributions for '" .. itemID .. "'")
                end
            else
                print("[JaysServerLoot] WARNING: Invalid weight '" .. tostring(weightStr) .. "' for '" .. tostring(itemID) .. "'. Skipping.")
            end
        else
            if entry ~= "" then
                print("[JaysServerLoot] WARNING: Could not parse entry '" .. entry .. "'. Expected format: Module.ItemID:weight")
            end
        end
    end

    print("[JaysServerLoot] Initialized: modified " .. count .. " item(s) in zombie loot tables")
end

local function onGameStart()
    if initialized then return end

    local ok, err = pcall(parseAndApply)
    if ok then
        initialized = true
    else
        print("[JaysServerLoot] ERROR: Failed to initialize: " .. tostring(err))
    end
end

Events.OnInitGlobalModData.Add(onGameStart)
