local isOpen = false
local state = { title = "", options = {}, index = 1, anchor = nil, theme = "ravage" }
local duiObj, duiHandle, txd, txn = nil, nil, nil, nil
local lastScroll, lastSelect = 0, 0

-- Petite fonction utilitaire
local function playSfx(kind)
    if not Config.EnableSound then return end
    local snd = Config.Sounds[kind]
    if snd then PlaySoundFrontend(-1, snd.name, Config.Soundset, true) end
end

local function distance(a, b) return #(a - b) end
local function clamp(i, min, max) if i < min then return max elseif i > max then return min else return i end return i end
local function forwardFromHeading(heading) local h = math.rad(heading); return vector3(-math.sin(h), math.cos(h), 0.0) end

local function createDui()
    if duiObj then return end
    local url = ('nui://%s/html/ui.html'):format(GetCurrentResourceName())
    duiObj = CreateDui(url, Config.TexWidth, Config.TexHeight)
    duiHandle = GetDuiHandle(duiObj)
    txd = CreateRuntimeTxd('ravage_hud3d_txd')
    txn = CreateRuntimeTextureFromDuiHandle(txd, 'ravage_hud3d_txn', duiHandle)
end

CreateThread(function()
    Wait(1500)
    createDui() -- prépare le HUD en arrière-plan dès la connexion
end)

local function destroyDui()
    if duiObj then
        DestroyDui(duiObj)
        duiObj, duiHandle, txd, txn = nil, nil, nil, nil
    end
end

local function send(tbl)
    if not duiObj then return end
    local ok, payload = pcall(function() return json.encode(tbl) end)
    if ok then SendDuiMessage(duiObj, payload) end
end

local function openNui()
    createDui()
    send({ action = 'open', theme = state.theme, title = state.title, options = state.options, index = state.index })
    playSfx('open')
end

local function closeNui()
    if not isOpen then return end
    isOpen = false
    send({ action = 'close' })
    playSfx('close')
end

local function DrawPanel3D(pos)
    if not txd or not txn then return end
    SetDrawOrigin(pos.x, pos.y, pos.z, 0)
    DrawSprite('ravage_hud3d_txd', 'ravage_hud3d_txn', 0.0, 0.0, Config.WorldScaleX, Config.WorldScaleY, 0.0, 255, 255, 255, 235)
    ClearDrawOrigin()
end

-- =====================================================
-- 📤 EXPORTS
-- =====================================================

exports('OpenMenu', function(data)
    if not data or not data.options then return false end

    local entries = {}
    for _, v in pairs(data.options) do entries[#entries+1] = v end
    if #entries == 0 then
        entries[1] = { label = "Aucun butin", event = '', args = {}, type = 'client' }
    end

    local ped = PlayerPedId()
    local p = GetEntityCoords(ped)
    local f = forwardFromHeading(GetEntityHeading(ped))
    local anchor = (data.position and type(data.position)=='vector3')
        and data.position or (p + f * Config.ForwardDistance + vector3(0,0,Config.ZOffset))

    state.title = data.title or "Butin"
    state.theme = (data.theme == 'tech' or data.theme == 'ravage') and data.theme or Config.Theme
    state.options = entries
    state.index = 1
    state.anchor = anchor
    isOpen = true

    openNui()
    return true
end)

exports('CloseMenu', function()
    closeNui()
end)

exports('IsOpen', function()
    return isOpen
end)

-- =====================================================
-- 📡 EVENTS
-- =====================================================

RegisterNetEvent('ravage_hud_3d:updateOptions', function(newOptions)
    if not newOptions or not next(newOptions) then
        closeNui()
        return
    end
    state.options = {}
    for _, v in ipairs(newOptions) do state.options[#state.options+1] = v end
    state.index = math.min(state.index, #state.options)
    send({ action = 'update', options = state.options, index = state.index })
end)

RegisterNetEvent('ravage_hud_3d:closeLootMenu', function()
    closeNui()
end)

RegisterCommand('hudtheme', function(_, args)
    local t = (args[1] or ''):lower()
    if t ~= 'ravage' and t ~= 'tech' then
        print('^3[ravage_hud_3d]^7 Usage: /hudtheme ravage | tech')
        return
    end
    state.theme = t
    Config.Theme = t
    send({ action = 'theme', theme = t })
    playSfx('theme')
end)

-- =====================================================
-- 🎮 INPUT LOOP
-- =====================================================
CreateThread(function()
    while true do
        if not isOpen then
            Wait(200)
        else
            Wait(0)
            local ped = PlayerPedId()
            local myPos = GetEntityCoords(ped)
            local anchor = state.anchor

            if Config.DrawAnchorMarker then
                DrawMarker(28, anchor.x, anchor.y, anchor.z, 0,0,0,0,0,0, 0.05,0.05,0.05, 255,0,0,180, false, true, 2, false)
            end

            if distance(myPos, anchor) > Config.MaxDistance then
                closeNui()
            end

            if IsControlJustPressed(0, 241) and (GetGameTimer()-lastScroll > Config.ScrollCooldown) then
                lastScroll = GetGameTimer()
                state.index = clamp(state.index - 1, 1, #state.options)
                send({ action = 'index', index = state.index })
                playSfx('scroll')
            end
            if IsControlJustPressed(0, 242) and (GetGameTimer()-lastScroll > Config.ScrollCooldown) then
                lastScroll = GetGameTimer()
                state.index = clamp(state.index + 1, 1, #state.options)
                send({ action = 'index', index = state.index })
                playSfx('scroll')
            end

            if IsControlJustPressed(0, 38) and (GetGameTimer()-lastSelect > Config.SelectCooldown) then
                lastSelect = GetGameTimer()
                local o = state.options[state.index]
                if o then
                    playSfx('select')
                    if (o.type or 'server') == 'client' then
                        TriggerEvent(o.event, table.unpack(o.args or {}))
                    else
                        TriggerServerEvent(o.event, table.unpack(o.args or {}))
                    end
                end
            end

            if IsControlJustPressed(0, 177) then
                closeNui()
            end

            DrawPanel3D(anchor)
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then destroyDui() end
end)

RegisterCommand('test_ravage_hud3d', function()
    local demo = {
        { label = "Bandage x2", event = "hrs_zombies:getLoot", args = { 999, 1 }, type = "server" },
        { label = "Eau", event = "hrs_zombies:getLoot", args = { 999, 2 }, type = "server" },
        { label = "Tout prendre", event = "hrs_zombies:getLootAll", args = { 999 }, type = "server" }
    }
    exports[GetCurrentResourceName()]:OpenMenu({
        title = "Butin",
        options = demo,
        theme = Config.Theme
    })
end)
