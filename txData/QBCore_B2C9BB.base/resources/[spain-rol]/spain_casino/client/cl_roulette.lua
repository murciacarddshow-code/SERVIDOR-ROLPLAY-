local QBCore = exports['qb-core']:GetCoreObject()

-- ============================================================================
-- HILO DE INTERACCIÓN CON MESAS DE RULETA (NORMAL Y PREMIUM)
-- ============================================================================

CreateThread(function()
    while true do
        local sleep = 1500
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        -- 1. Mesa Normal (Máx 10.000)
        local normalCfg = Config.Roulette.Normal
        local nDist = #(pos - normalCfg.coords)
        if nDist < 12.0 then
            sleep = 0
            DrawMarker(29, normalCfg.coords.x, normalCfg.coords.y, normalCfg.coords.z + 0.8, 
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.45, 0.45, 0.45, 0, 230, 118, 180, false, false, 2, true, nil, nil, false)

            if nDist < normalCfg.distance then
                DrawText3D(normalCfg.coords.x, normalCfg.coords.y, normalCfg.coords.z + 1.0, normalCfg.prompt)

                if IsControlJustReleased(0, 38) then -- Tecla E
                    QBCore.Functions.TriggerCallback('spain_casino:server:getPlayerCasinoData', function(data)
                        if data then
                            SetNuiFocus(true, true)
                            SendNUIMessage({
                                action = 'openRoulette',
                                tableType = 'Normal',
                                name = normalCfg.name,
                                maxBet = normalCfg.maxBet,
                                chips = normalCfg.chips,
                                isVip = data.isVip,
                                playerChips = data.chips
                            })
                        end
                    end)
                end
            end
        end

        -- 2. Mesa Premium VIP (Máx 100.000)
        local vipCfg = Config.Roulette.Premium
        local vDist = #(pos - vipCfg.coords)
        if vDist < 12.0 then
            sleep = 0
            DrawMarker(29, vipCfg.coords.x, vipCfg.coords.y, vipCfg.coords.z + 0.8, 
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 215, 0, 200, false, false, 2, true, nil, nil, false)

            if vDist < vipCfg.distance then
                DrawText3D(vipCfg.coords.x, vipCfg.coords.y, vipCfg.coords.z + 1.0, vipCfg.prompt)

                if IsControlJustReleased(0, 38) then -- Tecla E
                    QBCore.Functions.TriggerCallback('spain_casino:server:getPlayerCasinoData', function(data)
                        if data then
                            if not data.isVip then
                                QBCore.Functions.Notify('¡Acceso Denegado! Esta mesa es exclusiva para Miembros VIP. Adquiere tu Pase VIP en el Cajero por 50.000 €.', 'error', 7000)
                                return
                            end

                            SetNuiFocus(true, true)
                            SendNUIMessage({
                                action = 'openRoulette',
                                tableType = 'Premium',
                                name = vipCfg.name,
                                maxBet = vipCfg.maxBet,
                                chips = vipCfg.chips,
                                isVip = true,
                                playerChips = data.chips
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
-- NUI CALLBACKS Y RESULTADOS DE RULETA
-- ============================================================================

RegisterNUICallback('spinRoulette', function(data, cb)
    TriggerServerEvent('spain_casino:server:spinRoulette', data.tableType, data.bets)
    cb('ok')
end)

RegisterNetEvent('spain_casino:client:rouletteResult', function(result)
    SendNUIMessage({
        action = 'rouletteSpinResult',
        result = result
    })
end)
