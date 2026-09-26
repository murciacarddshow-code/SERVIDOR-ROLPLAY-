-- =========================================================================
-- SPAIN ROL - NPC DE BIENVENIDA Y KIT INICIAL DE CIUDADANO
-- =========================================================================
-- Localizado justo enfrente del punto de aparición de nuevos ciudadanos (Aeropuerto y Garaje Central).
-- Entrega:
-- 1. Coche automático en propiedad (registrado a su nombre en la base de datos).
-- 2. 50.000€ en cuenta bancaria.
-- 3. 5.000€ en efectivo.
-- 4. Suministros vitales (5x Agua y 5x Comida).

local QBCore = exports['qb-core']:GetCoreObject()

-- Puntos donde se sitúa el NPC de Bienvenida y su bahía de aparcamiento para el vehículo
local WelcomePoints = {
    airport = {
        name = "Terminal de Llegadas (Aeropuerto Internacional)",
        npcCoords = vector4(-1034.4, -2729.0, 13.76, 150.0),
        vehicleSpawn = vector4(-1029.8, -2734.5, 13.76, 330.0),
        blip = true
    },
    central_garage = {
        name = "Plaza Central / Garaje Legion",
        npcCoords = vector4(218.0, -803.0, 30.73, 70.0),
        vehicleSpawn = vector4(221.0, -800.5, 30.73, 250.0),
        blip = false
    }
}

local spawnedPeds = {}
local lastInteraction = 0

-- Función para dibujar texto 3D en pantalla
local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 220)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 350
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 20, 20, 25, 170)
    end
end

-- Spawn de NPCs y configuración de Blips
CreateThread(function()
    local pedModel = `a_m_y_smartcaspat_01`
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(50)
    end

    for key, pt in pairs(WelcomePoints) do
        local ped = CreatePed(4, pedModel, pt.npcCoords.x, pt.npcCoords.y, pt.npcCoords.z - 1.0, pt.npcCoords.w, false, true)
        SetEntityHeading(ped, pt.npcCoords.w)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
        table.insert(spawnedPeds, ped)

        if pt.blip then
            local blip = AddBlipForCoord(pt.npcCoords.x, pt.npcCoords.y, pt.npcCoords.z)
            SetBlipSprite(blip, 580) -- Icono de regalo / bienvenida
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.85)
            SetBlipColour(blip, 5) -- Amarillo / Oro
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName("🎁 Kit de Bienvenida (Vehículo y 55k)")
            EndTextCommandSetBlipName(blip)
        end

        if GetResourceState('qb-target') == 'started' then
            exports['qb-target']:AddTargetEntity(ped, {
                options = {
                    {
                        type = "client",
                        event = "spain_welcome:client:openMenu",
                        icon = "fas fa-gift",
                        label = "Reclamar Kit de Bienvenida",
                        key = key
                    }
                },
                distance = 2.5
            })
        end
    end
end)

-- Bucle de proximidad interactivo
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)

        for key, pt in pairs(WelcomePoints) do
            local dist = #(pCoords - vector3(pt.npcCoords.x, pt.npcCoords.y, pt.npcCoords.z))
            if dist < 20.0 then
                sleep = 0
                -- Marcador giratorio 3D tipo flecha dorada
                DrawMarker(2, pt.npcCoords.x, pt.npcCoords.y, pt.npcCoords.z + 0.35, 
                    0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.35, 0.35, 0.3, 
                    241, 196, 15, 210, false, true, 2, nil, nil, false
                )

                -- Base cilíndrica iluminada
                DrawMarker(25, pt.npcCoords.x, pt.npcCoords.y, pt.npcCoords.z - 0.95, 
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.1, 1.1, 0.6, 
                    241, 196, 15, 100, false, false, 2, false, nil, nil, false
                )

                if dist < 2.5 then
                    DrawText3D(pt.npcCoords.x, pt.npcCoords.y, pt.npcCoords.z + 1.0, "~y~[E]~w~ Reclamar Kit de Bienvenida Spain Rol")
                    if IsControlJustPressed(0, 38) then -- Tecla E
                        if (GetGameTimer() - lastInteraction) > 2000 then
                            lastInteraction = GetGameTimer()
                            TriggerEvent("spain_welcome:client:openMenu", { key = key })
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- Menú para reclamar el Kit de Bienvenida
RegisterNetEvent("spain_welcome:client:openMenu", function(data)
    local locationKey = (data and data.key) or 'airport'

    local menu = {
        {
            header = "🎁 Kit de Bienvenida &bull; Spain Rol v2.0",
            isMenuHeader = true,
        },
        {
            header = "📦 Reclamar Paquete de Llegada Oficial",
            text = "Incluye:<br>&bull; 🚗 <b>Coche Dinka Blista</b> automático en propiedad con llaves<br>&bull; 💳 <b>50.000€</b> en cuenta bancaria y <b>5.000€</b> en efectivo<br>&bull; 🥪 5x Sandwiches artesanos y 5x Botellas de agua",
            params = {
                event = "spain_welcome:client:confirmClaim",
                args = { key = locationKey }
            }
        },
        {
            header = "❌ Cerrar",
            text = "Volver más tarde",
            params = {
                event = "qb-menu:client:closeMenu"
            }
        }
    }

    exports['qb-menu']:openMenu(menu)
end)

-- Confirmación y envío al servidor
RegisterNetEvent("spain_welcome:client:confirmClaim", function(data)
    local locationKey = data.key or 'airport'
    local pt = WelcomePoints[locationKey] or WelcomePoints.airport

    QBCore.Functions.Progressbar("claim_welcome_kit", "Firmando documentación de bienvenida y entrega de llaves...", 3500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mp_common",
        anim = "givetake2_a",
        flags = 49,
    }, {}, {}, function()
        TriggerServerEvent("spain_welcome:server:claimKit", {
            spawnCoords = pt.vehicleSpawn
        })
    end, function()
        QBCore.Functions.Notify("Trámite cancelado.", "error")
    end)
end)

-- Spawneo del coche de bienvenida entregado al jugador
RegisterNetEvent("spain_welcome:client:spawnStarterVehicle", function(data)
    local model = data.model or 'blista'
    local plate = data.plate
    local spawn = data.coords or WelcomePoints.airport.vehicleSpawn
    local modelHash = GetHashKey(model)

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(50)
    end

    -- Despejar la zona si hay otro vehículo
    local closestVeh = GetClosestVehicle(spawn.x, spawn.y, spawn.z, 3.5, 0, 71)
    if closestVeh ~= 0 and DoesEntityExist(closestVeh) then
        DeleteEntity(closestVeh)
    end

    local veh = CreateVehicle(modelHash, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    SetVehicleOnGroundProperly(veh)
    SetEntityHeading(veh, spawn.w)
    SetVehicleNumberPlateText(veh, plate)

    -- Combustible lleno y entrega de llaves
    if GetResourceState('LegacyFuel') == 'started' then
        exports['LegacyFuel']:SetFuel(veh, 100.0)
    elseif GetResourceState('qb-fuel') == 'started' then
        exports['qb-fuel']:SetFuel(veh, 100.0)
    end

    TriggerEvent('vehiclekeys:client:SetOwner', plate)

    -- Marcar ruta GPS al coche
    SetNewWaypoint(spawn.x, spawn.y)

    QBCore.Functions.Notify("¡Tu nuevo vehículo [Matrícula: " .. plate .. "] ha sido estacionado en la acera con las llaves puestas! Se ha marcado en tu GPS.", "success", 9000)
end)

-- Limpieza al reiniciar recurso
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, ped in ipairs(spawnedPeds) do
        if ped and DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)
