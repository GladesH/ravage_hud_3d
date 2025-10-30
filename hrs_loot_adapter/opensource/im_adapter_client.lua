-------- MENU ---------

RegisterNetEvent('hrs_zombies:openLootMenu')
AddEventHandler('hrs_zombies:openLootMenu', function(id, list, lootType, customId)

    if GetResourceState('ravage_hud_3d') == 'started' then
    local entries = {}   -- { {key=originalKey, val=v}, ... }
        for k, v in pairs(list or {}) do
            entries[#entries+1] = { key = k, val = v }
        end        table.sort(entries, function(a, b)
            local na, nb = tonumber(a.key), tonumber(b.key)
            if na and nb then return na < nb end
            return tostring(a.key) < tostring(b.key)
        end)

        local opts = {}
        for _, e in ipairs(entries) do
            local k, v = e.key, e.val
        local label = v and (v.label or v.name or v.item) or "Objet"
        local count = v and v.count or 1
        label = tostring(label) .. " x" .. tostring(count)

                opts[#opts+1] = {
                    label = label,
                    event = "hrs_zombies:getLoot",
            args  = { id, k },  
                    type  = "server"
                }
            end

    -- 3) Bouton "Tout prendre"
    local getAllLabel = (Config.Locales and Config.Locales["get_all"]) or "Tout prendre"
            opts[#opts+1] = {
        label = getAllLabel,
                event = "hrs_zombies:getLootAll",
                args  = { id },
                type  = "server"
            }

    -- 5) Ouverture (petit délai pour DUI si nécessaire)
        CreateThread(function()
            Wait(100)
            exports['ravage_hud_3d']:OpenMenu({
                title   = "Butin",
                options = opts
            })
        end)
        return
    end
    -- Fallback : tout prendre si aucun menu disponible
    TriggerServerEvent('hrs_zombies:getLootAll', id)
end)
