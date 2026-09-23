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
