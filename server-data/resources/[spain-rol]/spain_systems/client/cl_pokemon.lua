-- =========================================================================
-- SPAIN ROL - CLIENTE: APERTURA DE SOBRES POKÉMON TCG (POKÉVAULT)
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()

-- Evento de Apertura de Sobre con Animación y Efectos
RegisterNetEvent('spain_pokemon:client:openPack', function(packItem, packLabel)
    local ped = PlayerPedId()

    -- Animación de rasgar/abrir el sobre
    local animDict = "mp_common"
    local animClip = "givetake2_a"
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end

    TaskPlayAnim(ped, animDict, animClip, 8.0, -8.0, 3500, 49, 0, false, false, false)

    QBCore.Functions.Progressbar("open_pokemon_booster", "Abriendo " .. packLabel .. "...", 3500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Completado
        ClearPedTasks(ped)
        TriggerServerEvent('spain_pokemon:server:finishPackOpening', packItem)
    end, function() -- Cancelado
        ClearPedTasks(ped)
        TriggerEvent('QBCore:Notify', "Apertura de sobre cancelada.", "error")
    end)
end)

-- Efecto al conseguir una carta
RegisterNetEvent('spain_pokemon:client:cardObtained', function(cardLabel, rarity, isHit)
    if isHit then
        -- Sonido épico de premio gordo
        PlaySoundFrontend(-1, "CHALLENGE_UNLOCKED", "HUD_AWARDS", 1)
        TriggerEvent('QBCore:Notify', "🔥 ¡¡¡MENUDO HITAZO DE POKÉMON!!! 🔥<br>Has obtenido: <strong>" .. cardLabel .. "</strong> (" .. rarity .. ")", "success", 9000)
    else
        PlaySoundFrontend(-1, "LOCAL_PLYR_CASH_COUNTER_COMPLETE", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 1)
        TriggerEvent('QBCore:Notify', "✨ Has obtenido: <strong>" .. cardLabel .. "</strong> (" .. rarity .. ")", "primary", 5000)
    end
end)

-- =========================================================================
-- APERTURA DE LA NUEVA INTERFAZ POKÉVAULT NUI (MURCIA CARD SHOW)
-- =========================================================================

local isNuiOpen = false

RegisterNetEvent('spain_pokemon:client:openPokeVaultNui', function(defaultTab)
    if isNuiOpen then return end

    QBCore.Functions.TriggerCallback('spain_pokemon:server:getShopData', function(data)
        if not data then
            TriggerEvent('QBCore:Notify', "No se ha podido conectar con el terminal de PokéVault.", "error")
            return
        end

        isNuiOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'open',
            defaultTab = defaultTab or 'tab-shop',
            cash = data.cash or 0,
            bank = data.bank or 0,
            inventory = data.inventory or {}
        })
    end)
end)

-- Compatibilidad directa con eventos existentes y NPCs
RegisterNetEvent('spain_pokemon:client:openMainStoreMenu', function()
    TriggerEvent('spain_pokemon:client:openPokeVaultNui', 'tab-shop')
end)

RegisterNetEvent('spain_pokemon:client:openBuyerMenu', function()
    TriggerEvent('spain_pokemon:client:openPokeVaultNui', 'tab-sell')
end)

RegisterNetEvent('spain_pokemon:client:showPriceList', function()
    TriggerEvent('spain_pokemon:client:openPokeVaultNui', 'tab-market')
end)

-- =========================================================================
-- NUI CALLBACKS
-- =========================================================================

RegisterNUICallback('close', function(_, cb)
    isNuiOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('buyItem', function(data, cb)
    QBCore.Functions.TriggerCallback('spain_pokemon:server:buyItem', function(response)
        if response and response.success then
            SendNUIMessage({
                action = 'update',
                cash = response.cash,
                bank = response.bank,
                inventory = response.inventory
            })
        end
        cb(response)
    end, data)
end)

RegisterNUICallback('sellCards', function(data, cb)
    QBCore.Functions.TriggerCallback('spain_pokemon:server:sellCardsNui', function(response)
        if response and response.success then
            SendNUIMessage({
                action = 'update',
                cash = response.newCash,
                bank = response.newBank,
                inventory = response.inventory
            })
        end
        cb(response)
    end, data)
end)

RegisterNUICallback('openPackFromNui', function(data, cb)
    isNuiOpen = false
    SetNuiFocus(false, false)
    cb('ok')
    Wait(200)
    TriggerEvent('spain_pokemon:client:openPack', data.item, data.label)
end)

-- Notificación de venta completada con sonido de caja registradora
RegisterNetEvent('spain_pokemon:client:saleComplete', function(count, totalCash)
    PlaySoundFrontend(-1, "LOCAL_PLYR_CASH_COUNTER_COMPLETE", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 1)
    TriggerEvent('QBCore:Notify', "🤝 <strong>Tasación oficial completada</strong><br>Has vendido <strong>" .. count .. "</strong> carta(s) por <strong>€" .. totalCash .. "</strong> en efectivo.", "success", 7500)
end)

-- Blip en el Mapa para PokéVault TCG Shop
CreateThread(function()
    local blip = AddBlipForCoord(22.0, -1105.5, 29.8)
    SetBlipSprite(blip, 605)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.85)
    SetBlipColour(blip, 46) -- Amarillo oro
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("PokéVault TCG (Murcia Card Show)")
    EndTextCommandSetBlipName(blip)
end)


