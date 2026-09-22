-- =========================================================================
-- SPAIN ROL - DESACTIVACIÓN TOTAL DE NPCS Y TRÁFICO IA (DENSIDAD CERO)
-- =========================================================================
-- Elimina completamente peatones IA, coches de tráfico, vehículos aparcados
-- y servicios de emergencia nativos de GTA V para una experiencia 100% Roleplay.

local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    -- Desactivar servicios de emergencia nativos una sola vez al inicio
    for i = 1, 15 do
        EnableDispatchService(i, false)
    end
    
    SetAudioFlag('PoliceScannerDisabled', true)
    SetAudioFlag('DisableFlightMusic', true)
    DistantCopCarSirens(false)
    SetCreateRandomCops(false)
    SetCreateRandomCopsNotOnScenarios(false)
    SetCreateRandomCopsOnScenarios(false)
    SetGarbageTrucks(false)
    SetRandomBoats(false)
    SetRandomTrains(false)
    SetMaxWantedLevel(0)

    -- Bucle continuo por fotograma para asegurar densidad 0
    while true do
        -- Densidad de peatones
        SetPedDensityMultiplierThisFrame(0.0)
        SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)

        -- Densidad de vehículos de tráfico
        SetVehicleDensityMultiplierThisFrame(0.0)
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetParkedVehicleDensityMultiplierThisFrame(0.0)
        SetAmbientVehicleRangeMultiplierThisFrame(0.0)

        Wait(0)
    end
end)

-- Limpieza periódica de cualquier ped ambiental generado por GTA
CreateThread(function()
    while true do
        Wait(5000)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Limpiar únicamente peds ambientales errantes que no sean jugadores ni dependientes
        local pedPool = GetGamePool('CPed')
        for _, ped in ipairs(pedPool) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsEntityAMissionEntity(ped) then
                -- No eliminar si está congelado en una tienda o es dependiente
                local isShopkeeper = IsEntityPositionFrozen(ped) or 
                                     GetEntityModel(ped) == `s_m_y_ammucity_01` or 
                                     GetEntityModel(ped) == `mp_m_shopkeep_01` or 
                                     GetEntityModel(ped) == `s_m_m_doctor_01` or 
                                     GetEntityModel(ped) == `s_m_m_autoshop_01` or
                                     GetEntityModel(ped) == `cs_bankman`
                
                if not isShopkeeper then
                    local pedType = GetPedType(ped)
                    if pedType ~= 28 then -- 28 son animales
                        DeleteEntity(ped)
                    end
                end
            end
        end

        -- Limpiar vehículos vacíos del ambiente que no pertenezcan a jugadores
        local vehPool = GetGamePool('CVehicle')
        for _, veh in ipairs(vehPool) do
            if DoesEntityExist(veh) and not IsEntityAMissionEntity(veh) then
                if GetPedInVehicleSeat(veh, -1) == 0 and not IsVehicleSeatFree(veh, -1) == false then
                    -- Si está vacío y sin conductor humano
                    local plate = GetVehicleNumberPlateText(veh)
                    -- Si no tiene matrícula válida guardada o es vehículo ambiental de tráfico
                    if not Entity(veh).state.isPlayerVehicle then
                        local distance = #(playerCoords - GetEntityCoords(veh))
                        if distance > 100.0 then
                            DeleteEntity(veh)
                        end
                    end
                end
            end
        end
    end
end)
