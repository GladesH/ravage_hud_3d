RegisterNetEvent('hrs_zombies:openLoot')
AddEventHandler('hrs_zombies:openLoot', function(checkId, lootType, coords, extraInfo)
    local src = source
    local xPlayer = GetPlayerFromId(src)
    if not xPlayer then return end

    local finalList = createNewLoot(checkId, lootType, xPlayer, coords, extraInfo)

    if not finalList or not next(finalList) then
        print(('[RAVAGE] Aucun loot généré pour %s'):format(checkId))
        TriggerClientEvent('hrs_zombies:closeLootMenu', src)
        return
    end

    print(("[RAVAGE DEBUG SERVER] Loot généré pour %s :"):format(checkId))
    local safeList = {}
    for i, v in pairs(finalList or {}) do
        print(("  #%s - %s x%s"):format(i, v.item or "nil", v.count or "?"))
        safeList[#safeList+1] = {
            item = tostring(v.item or "unknown"),
            label = tostring(v.label or v.item or "Item"),
            count = tonumber(v.count or 1),
            metadata = v.metadata and json.encode(v.metadata) or "{}"
        }
    end

    if #safeList == 0 then
        print(("[RAVAGE SERVER] Aucun item à envoyer pour %s, fermeture du menu."):format(checkId))
        TriggerClientEvent('hrs_zombies:closeLootMenu', src)
        return
    end

    print(("[RAVAGE SERVER] Envoi de %d items à %s"):format(#safeList, src))
    TriggerClientEvent('hrs_zombies:openLootMenu', src, checkId, safeList, lootType, checkId)
end)

-- Quand un joueur prend un item
RegisterNetEvent('hrs_zombies:getLoot', function(id, index)
    local src = source
    local xPlayer = GetPlayerFromId(src)
    if not xPlayer then return end

    local loot = lootList[id]
    if not loot or not loot[index] then return end

    local item = loot[index]
    AddInventoryItem(xPlayer, item.item, item.count, item.metadata)

    -- Retirer l'item du loot
        loot[index] = nil

    -- Si le loot est vide => fermer le menu
    local stillHasLoot = false
    for _,v in pairs(loot) do
        stillHasLoot = true
        break
    end
    if not stillHasLoot then
        TriggerClientEvent('ravage_hud_3d:closeLootMenu', src)
    end
end)

-- Quand le joueur prend tout
RegisterNetEvent('hrs_zombies:getLootAll', function(id)
    local src = source
    local xPlayer = GetPlayerFromId(src)
    if not xPlayer then return end

    local loot = lootList[id]
    if not loot then return end

    for _, item in pairs(loot) do
        AddInventoryItem(xPlayer, item.item, item.count, item.metadata)
    end

    lootList[id] = nil
    TriggerClientEvent('ravage_hud_3d:closeLootMenu', src)
end)
