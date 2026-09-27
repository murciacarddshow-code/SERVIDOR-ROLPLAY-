local QBCore = exports['qb-core']:GetCoreObject()

-- ============================================================================
-- HILO DE INTERACCIÓN CON LAS MÁQUINAS TRAGAPERRAS / JACKPOT
-- ============================================================================

CreateThread(function()
    while true do
        local sleep = 1500
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local c = Config.Slots.coords
        local dist = #(pos - c)

        if dist < 15.0 then
            sleep = 0
            DrawMarker(20, c.x, c.y, c.z + 0.8, 
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.45, 0.45, 0.45, 224, 64, 251, 180, false, false, 2, true, nil, nil, false)

            if dist < Config.Slots.distance then
                DrawText3D(c.x, c.y, c.z + 1.0, Config.Slots.prompt)

                if IsControlJustReleased(0, 38) then -- Tecla E
                    QBCore.Functions.TriggerCallback('spain_casino:server:getPlayerCasinoData', function(data)
                        if data then
                            SetNuiFocus(true, true)
                            SendNUIMessage({
                                action = 'openSlots',
                                isVip = data.isVip,
                                playerChips = data.chips,
                                currentJackpot = data.jackpot,
                                bets = Config.Slots.bets,
                                normalMaxBet = Config.Slots.normalMaxBet,
                                vipMaxBet = Config.Slots.vipMaxBet,
                                symbols = Config.Slots.symbols
                            })
                        end
                    end)
                end
            end
        end

        Wait(sleep)
    end
end)

-- ============================================================================
-- NUI CALLBACKS Y RESULTADOS DE SLOTS
-- ============================================================================

RegisterNUICallback('spinSlots', function(data, cb)
    local bet = tonumber(data.bet)
    if bet and bet > 0 then
        TriggerServerEvent('spain_casino:server:spinSlots', bet)
    end
    cb('ok')
end)

RegisterNetEvent('spain_casino:client:slotsResult', function(result)
    SendNUIMessage({
        action = 'slotsSpinResult',
        result = result
    })
end)
