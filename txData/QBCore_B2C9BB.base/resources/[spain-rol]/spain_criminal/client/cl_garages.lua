local QBCore = exports['qb-core']:GetCoreObject()
local myOrgBlip = nil

-- =========================================================================
-- BLIP DEL GARAJE: VISIBLE ÚNICAMENTE PARA MIEMBROS DE LA ORGANIZACIÓN
-- =========================================================================
local function UpdateOrgGarageBlip()
    if myOrgBlip and DoesBlipExist(myOrgBlip) then
        RemoveBlip(myOrgBlip)
        myOrgBlip = nil
    end

    local PlayerData = QBCore.Functions.GetPlayerData()
    local gangName = PlayerData.gang and PlayerData.gang.name

    if gangName and Config.Organizations[gangName] then
        local org = Config.Organizations[gangName]
        myOrgBlip = AddBlipForCoord(org.garageCoords.x, org.garageCoords.y, org.garageCoords.z)
        SetBlipSprite(myOrgBlip, org.blip.sprite or 326)
        SetBlipDisplay(myOrgBlip, 4)
        SetBlipScale(myOrgBlip, org.blip.scale or 0.75)
        SetBlipColour(myOrgBlip, org.blip.color or 1)
        SetBlipAsShortRange(myOrgBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(org.blip.name or "Garaje Clandestino")
        EndTextCommandSetBlipName(myOrgBlip)
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    UpdateOrgGarageBlip()
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function()
    UpdateOrgGarageBlip()
end)

-- =========================================================================
-- BUCLE DE MARCADOR E INTERACCIÓN DEL GARAJE PRIVADO
-- =========================================================================
CreateThread(function()
    Wait(1500)
    UpdateOrgGarageBlip()

    while true do
        local sleep = 1000
        local PlayerData = QBCore.Functions.GetPlayerData()
        local gangName = PlayerData.gang and PlayerData.gang.name

        if gangName and Config.Organizations[gangName] then
            local org = Config.Organizations[gangName]
            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)
            local dist = #(pCoords - org.garageCoords)

            if dist < 20.0 then
                sleep = 0
                -- Marcador exclusivo (solo visible si estás en la banda)
                DrawMarker(36, org.garageCoords.x, org.garageCoords.y, org.garageCoords.z + 0.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 1.0, 255, 42, 95, 180, false, false, 2, true, nil, nil, false)

                if dist < 3.0 then
                    local inVeh = IsPedInAnyVehicle(ped, false)
                    if inVeh then
                        QBCore.Functions.DrawText3D(org.garageCoords.x, org.garageCoords.y, org.garageCoords.z + 0.8, "~r~[E]~s~ Guardar Vehículo de la Organización")
                        if IsControlJustPressed(0, 38) then -- Tecla E
                            local veh = GetVehiclePedIsIn(ped, false)
                            TaskLeaveVehicle(ped, veh, 0)
                            Wait(1000)
                            DeleteVehicle(veh)
                            QBCore.Functions.Notify("Vehículo de la organización guardado en el hangar seguro.", "success")
                        end
                    else
                        QBCore.Functions.DrawText3D(org.garageCoords.x, org.garageCoords.y, org.garageCoords.z + 0.8, "~r~[E]~s~ Flota Privada de " .. org.label)
                        if IsControlJustPressed(0, 38) then
                            OpenCriminalTablet() -- Abre la tablet directa en el garaje
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- Spawnear vehículo de la organización en las coordenadas privadas
RegisterNetEvent('spain_criminal:client:spawnVehicle', function(model)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local gangName = PlayerData.gang and PlayerData.gang.name
    if not gangName or not Config.Organizations[gangName] then return end

    local org = Config.Organizations[gangName]
    local spawnCoords = org.spawnCoords

    QBCore.Functions.SpawnVehicle(model, function(veh)
        SetEntityHeading(veh, spawnCoords.w)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetVehicleNumberPlateText(veh, string.upper(string.sub(gangName, 1, 4)) .. tostring(math.random(1000, 9999)))
        SetEntityAsMissionEntity(veh, true, true)
        SetVehicleColours(veh, 0, 0) -- Pintura Negro Mate por defecto
        SetVehicleCustomPrimaryColour(veh, 15, 15, 15)
        SetVehicleWindowTint(veh, 1) -- Cristales tintados
        exports['qb-vehiclekeys']:SetOwner(QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true, false)
        QBCore.Functions.Notify("Vehículo de la organización extraído con éxito.", "success")
    end, spawnCoords, true)
end)
