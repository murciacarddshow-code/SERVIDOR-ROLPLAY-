local QBCore = exports['qb-core']:GetCoreObject()
local IsInCasino = false

-- ============================================================================
-- CREACIÓN DEL BLIP DEL CASINO
-- ============================================================================

CreateThread(function()
    local blip = AddBlipForCoord(Config.Blip.coords.x, Config.Blip.coords.y, Config.Blip.coords.z)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.Blip.name)
    EndTextCommandSetBlipName(blip)
end)

-- ============================================================================
-- ENTRADA Y SALIDA DEL CASINO (TELETRANSPORTE FLUIDO)
-- ============================================================================

CreateThread(function()
    while true do
        local sleep = 1500
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        -- 1. Puerta Exterior (Para entrar)
        local outDist = #(pos - vector3(Config.CasinoDoors.Outside.coords.x, Config.CasinoDoors.Outside.coords.y, Config.CasinoDoors.Outside.coords.z))
        if outDist < Config.CasinoDoors.Outside.drawDistance then
            sleep = 0
            DrawMarker(20, Config.CasinoDoors.Outside.coords.x, Config.CasinoDoors.Outside.coords.y, Config.CasinoDoors.Outside.coords.z, 
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6, 0.6, 0.6, 255, 215, 0, 180, false, true, 2, false, nil, nil, false)

            if outDist < 1.8 then
                DrawText3D(Config.CasinoDoors.Outside.coords.x, Config.CasinoDoors.Outside.coords.y, Config.CasinoDoors.Outside.coords.z + 0.3, Config.CasinoDoors.Outside.prompt)
                if IsControlJustReleased(0, 38) then -- Tecla E
                    DoScreenFadeOut(600)
                    while not IsScreenFadedOut() do Wait(50) end
                    SetEntityCoords(ped, Config.CasinoDoors.Inside.coords.x, Config.CasinoDoors.Inside.coords.y, Config.CasinoDoors.Inside.coords.z, false, false, false, false)
                    SetEntityHeading(ped, Config.CasinoDoors.Inside.coords.w)
                    IsInCasino = true
                    Wait(800)
                    DoScreenFadeIn(600)
                end
            end
        end

        -- 2. Puerta Interior (Para salir)
        local inDist = #(pos - vector3(Config.CasinoDoors.Inside.coords.x, Config.CasinoDoors.Inside.coords.y, Config.CasinoDoors.Inside.coords.z))
        if inDist < Config.CasinoDoors.Inside.drawDistance then
            sleep = 0
            DrawMarker(20, Config.CasinoDoors.Inside.coords.x, Config.CasinoDoors.Inside.coords.y, Config.CasinoDoors.Inside.coords.z, 
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6, 0.6, 0.6, 255, 215, 0, 180, false, true, 2, false, nil, nil, false)

            if inDist < 1.8 then
                DrawText3D(Config.CasinoDoors.Inside.coords.x, Config.CasinoDoors.Inside.coords.y, Config.CasinoDoors.Inside.coords.z + 0.3, Config.CasinoDoors.Inside.prompt)
                if IsControlJustReleased(0, 38) then -- Tecla E
                    DoScreenFadeOut(600)
                    while not IsScreenFadedOut() do Wait(50) end
                    SetEntityCoords(ped, Config.CasinoDoors.Outside.coords.x, Config.CasinoDoors.Outside.coords.y, Config.CasinoDoors.Outside.coords.z, false, false, false, false)
                    SetEntityHeading(ped, Config.CasinoDoors.Outside.coords.w)
                    IsInCasino = false
                    Wait(800)
                    DoScreenFadeIn(600)
                end
            end
        end

        Wait(sleep)
    end
end)

-- ============================================================================
-- UTILIDAD: DIBUJAR TEXTO 3D EN EL MUNDO
-- ============================================================================

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 120)
    ClearDrawOrigin()
end

-- ============================================================================
-- CALLBACKS Y EVENTOS NUI COMUNES
-- ============================================================================

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('refreshData', function(data, cb)
    QBCore.Functions.TriggerCallback('spain_casino:server:getPlayerCasinoData', function(playerData)
        cb(playerData or {})
    end)
end)

RegisterNetEvent('spain_casino:client:updateJackpot', function(newJackpot)
    SendNUIMessage({
        action = 'updateJackpot',
        jackpot = newJackpot
    })
end)

RegisterNetEvent('spain_casino:client:refreshCasinoUI', function()
    QBCore.Functions.TriggerCallback('spain_casino:server:getPlayerCasinoData', function(data)
        if data then
            SendNUIMessage({
                action = 'updatePlayerData',
                data = data
            })
        end
    end)
end)
