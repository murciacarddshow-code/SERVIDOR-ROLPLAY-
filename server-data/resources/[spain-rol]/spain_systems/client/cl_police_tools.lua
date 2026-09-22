local QBCore = exports['qb-core']:GetCoreObject()
local spawnedSpikes = {}

-- Radar de Velocidad Laser CNP
RegisterNetEvent('spain_police:client:useRadar', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        QBCore.Functions.Notify("No puedes usar el radar de mano dentro de un vehiculo.", "error")
        return
    end

    local vehicle = QBCore.Functions.GetClosestVehicle()
    if vehicle ~= 0 and #(GetEntityCoords(ped) - GetEntityCoords(vehicle)) < 40.0 then
        local speedMps = GetEntitySpeed(vehicle)
        local speedKmh = math.floor(speedMps * 3.6)
        local plate = GetVehicleNumberPlateText(vehicle)
        QBCore.Functions.Notify("Radar CNP: Matricula [" .. plate .. "] - Velocidad: " .. speedKmh .. " km/h", "primary", 6000)
    else
        QBCore.Functions.Notify("No hay ningun vehiculo en el rango del radar.", "error")
    end
end)

-- Alcoholimetro Digital
RegisterNetEvent('spain_police:client:useBreathalyzer', function()
    local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance < 2.5 then
        QBCore.Functions.Progressbar("breathalyzer", "Realizando prueba de alcoholemia...", 3000, false, true, {}, {
            animDict = "mp_arresting",
            anim = "a_uncuff",
            flags = 49,
        }, {}, {}, function()
            TriggerServerEvent('spain_police:server:testAlcohol', GetPlayerServerId(closestPlayer))
        end)
    else
        QBCore.Functions.Notify("No hay ningun sospechoso cerca para soplar.", "error")
    end
end)

-- Narcotest de Drogas
RegisterNetEvent('spain_police:client:useNarcotest', function()
    local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance < 2.5 then
        QBCore.Functions.Progressbar("narcotest", "Tomando muestra de saliva (Narcotest)...", 4000, false, true, {}, {
            animDict = "mp_arresting",
            anim = "a_uncuff",
            flags = 49,
        }, {}, {}, function()
            TriggerServerEvent('spain_police:server:testDrugs', GetPlayerServerId(closestPlayer))
        end)
    else
        QBCore.Functions.Notify("No hay ningun sospechoso cerca para la prueba.", "error")
    end
end)

-- Banda de Pinchos Stinger
RegisterNetEvent('spain_police:client:deploySpikes', function()
    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.5, 0.0)
    local heading = GetEntityHeading(ped)

    QBCore.Functions.Progressbar("deploy_spikes", "Desplegando banda de pinchos...", 2000, false, true, {}, {
        animDict = "pickup_object",
        anim = "pickup_low",
        flags = 49,
    }, {}, {}, function()
        local spikeModel = GetHashKey("p_ld_stinger_s")
        RequestModel(spikeModel)
        while not HasModelLoaded(spikeModel) do Wait(10) end

        local spikeObj = CreateObject(spikeModel, coords.x, coords.y, coords.z - 0.9, true, true, true)
        SetEntityHeading(spikeObj, heading)
        PlaceObjectOnGroundProperly(spikeObj)
        table.insert(spawnedSpikes, spikeObj)
        QBCore.Functions.Notify("Banda de pinchos desplegada en la calzada.", "success")
    end)
end)

-- Hilo para pinchar neumaticos al pasar por encima
CreateThread(function()
    while true do
        local sleep = 500
        if #spawnedSpikes > 0 then
            sleep = 100
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                local veh = GetVehiclePedIsIn(ped, false)
                local vehCoords = GetEntityCoords(veh)
                for _, spike in ipairs(spawnedSpikes) do
                    local spikeCoords = GetEntityCoords(spike)
                    if #(vehCoords - spikeCoords) < 3.0 then
                        SetVehicleTyreBurst(veh, 0, true, 1000.0)
                        SetVehicleTyreBurst(veh, 1, true, 1000.0)
                        SetVehicleTyreBurst(veh, 4, true, 1000.0)
                        SetVehicleTyreBurst(veh, 5, true, 1000.0)
                        QBCore.Functions.Notify("¡Has pasado por una banda de pinchos policial! Neumaticos reventados.", "error")
                    end
                end
            end
        end
        Wait(sleep)
    end
end)
