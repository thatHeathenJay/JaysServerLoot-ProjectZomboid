require "JaysServerLoot/config"
require "Items/SuburbsDistributions"

local initialized = false

local sandboxItemMap = {
    { option = "CigarettePackWeight",   item = "CigarettePack" },
    { option = "CigaretteSingleWeight", item = "CigaretteSingle" },
    { option = "CigarilloWeight",       item = "Cigarillo" },
    { option = "CigarWeight",           item = "Cigar" },
    { option = "LighterWeight",         item = "LighterDisposable" },
    { option = "MatchesWeight",         item = "Matches" },
    { option = "MoneyWeight",           item = "Money" },
    { option = "CoinsWeight",           item = "Coins" },
    { option = "PillsWeight",           item = "Pills" },
}

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

local function applyToDistributions(shortName, weight)
    local maleOk = pcall(modifyDistribution,
        SuburbsDistributions["all"]["inventorymale"], shortName, weight)
    local femaleOk = pcall(modifyDistribution,
        SuburbsDistributions["all"]["inventoryfemale"], shortName, weight)
    return maleOk or femaleOk
end

local function applySandboxOptions()
    local sv = SandboxVars.JaysServerLoot
    if not sv then
        print("[JaysServerLoot] No sandbox vars found, skipping sandbox options")
        return 0
    end

    local count = 0
    for _, entry in ipairs(sandboxItemMap) do
        local weight = sv[entry.option]
        if weight and weight > 0 then
            if applyToDistributions(entry.item, weight) then
                count = count + 1
            end
        end
    end
    return count
end

local function applyConfigFile()
    local str = JaysServerLoot.Items
    if not str or str == "" then return 0 end

    local count = 0
    for entry in str:gmatch("[^;]+") do
        entry = entry:match("^%s*(.-)%s*$")
        local itemID, weightStr = entry:match("^(.+):([%d%.]+)$")
        if itemID and weightStr then
            itemID = itemID:match("^%s*(.-)%s*$")
            local weight = tonumber(weightStr)
            if weight and weight > 0 then
                local shortName = itemID:match("^Base%.(.+)$") or itemID
                if applyToDistributions(shortName, weight) then
                    count = count + 1
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
    return count
end

local function onGameStart()
    if initialized then return end

    local ok, err = pcall(function()
        local sandboxCount = applySandboxOptions()
        local configCount = applyConfigFile()
        local total = sandboxCount + configCount
        print("[JaysServerLoot] Initialized: " .. total .. " item(s) modified (" .. sandboxCount .. " from sandbox, " .. configCount .. " from config)")
    end)

    if ok then
        initialized = true
    else
        print("[JaysServerLoot] ERROR: Failed to initialize: " .. tostring(err))
    end
end

Events.OnInitGlobalModData.Add(onGameStart)
