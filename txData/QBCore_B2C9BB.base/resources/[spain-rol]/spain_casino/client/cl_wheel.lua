local QBCore = exports['qb-core']:GetCoreObject()

local PodiumVehicleEntity = nil
local CurrentPodiumModel = Config.LuckyWheel.defaultPodiumVehicle
local LuckyWheelPropEntity = nil
local IsSpinning = false

-- ============================================================================
-- GENERACIÓN Y ROTACIÓN DEL VEHÍCULO DEL PODIO
-- ============================================================================

local function SpawnPodiumVehicle(model)
    if PodiumVehicleEntity and DoesEntityExist(PodiumVehicleEntity) then
        DeleteEntity(PodiumVehicleEntity)
        PodiumVehicleEntity = nil
    end

    local modelHash = joaat(model)
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    if HasModelLoaded(modelHash) then
        local coords = Config.LuckyWheel.podiumCoords
        PodiumVehicleEntity = CreateVehicle(modelHash, coords.x, coords.y, coords.z, coords.w, false, false)
        SetModelAsNoLongerNeeded(modelHash)
        
        SetVehicleOnGroundProperly(PodiumVehicleEntity)
        SetEntityInvincible(PodiumVehicleEntity, true)
        SetVehicleDoorsLocked(PodiumVehicleEntity, 2)
        SetVehicleDirtLevel(PodiumVehicleEntity, 0.0)
        SetVehicleDoorsLockedForAllPlayers(PodiumVehicleEntity, true)
        SetEntityCanBeDamaged(PodiumVehicleEntity, false)
        FreezeEntityPosition(PodiumVehicleEntity, true)
    end
end

-- ============================================================================
-- PROP DE LA RULETA DE LA SUERTE
-- ============================================================================

local function SpawnLuckyWheelProp()
    local propHash = joaat(Config.LuckyWheel.propModel)
    RequestModel(propHash)
    local timeout = 0
    while not HasModelLoaded(propHash) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    if HasModelLoaded(propHash) then
        local c = Config.LuckyWheel.coords
        local existing = GetClosestObjectOfType(c.x, c.y, c.z, 2.0, propHash, false, false, false)
        if existing and DoesEntityExist(existing) then
            LuckyWheelPropEntity = existing
        else
            LuckyWheelPropEntity = CreateObject(propHash, c.x, c.y, c.z, false, false, false)
            SetEntityHeading(LuckyWheelPropEntity, 0.0)
            FreezeEntityPosition(LuckyWheelPropEntity, true)
        end
        SetModelAsNoLongerNeeded(propHash)
    end
end

-- ============================================================================
-- HILO DE ACTUALIZACIÓN DEL PODIO Y PROMPT DE RULETA DIARIA
-- ============================================================================

CreateThread(function()
    -- Cargar modelo del podio inicial desde el servidor
    QBCore.Functions.TriggerCallback('spain_casino:server:getPodiumVehicle', function(serverModel)
        if serverModel and serverModel ~= '' then
            CurrentPodiumModel = serverModel
        end
    end)

    local currentHeading = Config.LuckyWheel.podiumCoords.w

    while true do
        local sleep = 1500
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        -- Distancia al podio (para rotar suavemente el coche en exhibición)
        local podDist = #(pos - vector3(Config.LuckyWheel.podiumCoords.x, Config.LuckyWheel.podiumCoords.y, Config.LuckyWheel.podiumCoords.z))
        if podDist < 45.0 then
            sleep = 0
            if not PodiumVehicleEntity or not DoesEntityExist(PodiumVehicleEntity) then
                SpawnPodiumVehicle(CurrentPodiumModel)
            else
                if Config.LuckyWheel.podiumRotate then
                    currentHeading = (currentHeading + 0.15) % 360.0
                    SetEntityHeading(PodiumVehicleEntity, currentHeading)
                end
            end
        else
            if PodiumVehicleEntity and DoesEntityExist(PodiumVehicleEntity) then
                DeleteEntity(PodiumVehicleEntity)
                PodiumVehicleEntity = nil
            end
        end

        -- Distancia a la Ruleta Diaria
        local wheelDist = #(pos - Config.LuckyWheel.coords)
        if wheelDist < 15.0 then
            sleep = 0
            if not LuckyWheelPropEntity or not DoesEntityExist(LuckyWheelPropEntity) then
                SpawnLuckyWheelProp()
            end

            DrawMarker(21, Config.LuckyWheel.coords.x, Config.LuckyWheel.coords.y, Config.LuckyWheel.coords.z + 1.2, 
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 215, 0, 180, false, false, 2, true, nil, nil, false)

            if wheelDist < 2.0 and not IsSpinning then
                DrawText3D(Config.LuckyWheel.coords.x, Config.LuckyWheel.coords.y, Config.LuckyWheel.coords.z + 1.5, Config.LuckyWheel.prompt)
                
                if IsControlJustReleased(0, 38) then -- Tecla E
                    QBCore.Functions.TriggerCallback('spain_casino:server:getPlayerCasinoData', function(data)
                        if data then
                            SetNuiFocus(true, true)
                            SendNUIMessage({
                                action = 'openLuckyWheel',
                                data = data,
                                prizes = Config.LuckyWheel.prizes,
                                podiumVehicle = CurrentPodiumModel
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
-- SINCRONIZACIÓN DEL VEHÍCULO DEL PODIO
-- ============================================================================

RegisterNetEvent('spain_casino:client:updatePodiumVehicle', function(newModel)
    CurrentPodiumModel = newModel:lower()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    if #(pos - vector3(Config.LuckyWheel.podiumCoords.x, Config.LuckyWheel.podiumCoords.y, Config.LuckyWheel.podiumCoords.z)) < 60.0 then
        SpawnPodiumVehicle(CurrentPodiumModel)
    end
end)

-- ============================================================================
-- NUI CALLBACKS & ANIMACIONES DE LA RULETA
-- ============================================================================

RegisterNUICallback('requestWheelSpin', function(data, cb)
    if IsSpinning then return cb('busy') end
    TriggerServerEvent('spain_casino:server:spinLuckyWheel')
    cb('ok')
end)

RegisterNetEvent('spain_casino:client:startWheelSpin', function(sliceIndex, prize)
    IsSpinning = true

    -- Notificar a la NUI para comenzar la animación
    SendNUIMessage({
        action = 'spinWheelToSlice',
        sliceIndex = sliceIndex,
        prize = prize
    })
end)

RegisterNUICallback('wheelSpinFinished', function(data, cb)
    IsSpinning = false
    local sliceIndex = data.sliceIndex
    TriggerServerEvent('spain_casino:server:claimWheelPrize', sliceIndex)
    cb('ok')
end)

-- Limpieza al parar el recurso
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        if PodiumVehicleEntity and DoesEntityExist(PodiumVehicleEntity) then
            DeleteEntity(PodiumVehicleEntity)
        end
        if LuckyWheelPropEntity and DoesEntityExist(LuckyWheelPropEntity) then
            DeleteEntity(LuckyWheelPropEntity)
        end
    end
end)
