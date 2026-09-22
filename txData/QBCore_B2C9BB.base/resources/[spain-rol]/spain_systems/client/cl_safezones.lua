-- =========================================================================
-- SPAIN ROL - SISTEMA DE ZONAS SEGURAS (SAFE ZONES)
-- =========================================================================
-- Desactiva armas, combate, agresiones y atropellos (VDM) dentro de las zonas.
-- Muestra interfaz visual y blips protectores en el mapa.

local QBCore = exports['qb-core']:GetCoreObject()

local safeZones = {
    {
        name = "Plaza Central / Spawn (Legion Square)",
        coords = vector3(195.17, -933.77, 30.69),
        radius = 100.0,
        blip = true
    },
    {
        name = "Hospital Central (Pillbox Hill)",
        coords = vector3(307.72, -595.25, 43.28),
        radius = 85.0,
        blip = true
    },
    {
        name = "Comisaría Central CNP (Mission Row)",
        coords = vector3(428.23, -984.28, 30.71),
        radius = 90.0,
        blip = true
    },
    {
        name = "Garaje Central Público",
        coords = vector3(215.86, -805.12, 30.8),
        radius = 80.0,
        blip = true
    },
    {
        name = "Concesionario Oficial de Vehículos",
        coords = vector3(-44.68, -1097.74, 26.42),
        radius = 70.0,
        blip = true
    },
    {
        name = "Hospital de Sandy Shores",
        coords = vector3(1839.5, 3672.93, 34.28),
        radius = 65.0,
        blip = true
    },
    {
        name = "Comisaría Guardia Civil (Paleto Bay)",
        coords = vector3(-447.24, 6012.87, 31.72),
        radius = 75.0,
        blip = true
    }
}

local inSafeZone = false
local currentZoneName = ""

-- Crear Blips en el Mapa
CreateThread(function()
    for _, zone in ipairs(safeZones) do
        if zone.blip then
            -- Blip de icono
            local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
            SetBlipSprite(blip, 161) -- Icono de escudo / cruz protectora
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.75)
            SetBlipColour(blip, 2) -- Color verde
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName("Zona Segura: " .. zone.name)
            EndTextCommandSetBlipName(blip)

            -- Radio visual sombreado en mapa
            local radiusBlip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, zone.radius)
            SetBlipColour(radiusBlip, 2)
            SetBlipAlpha(radiusBlip, 65)
        end
    end
end)

-- Comprobación de proximidad y activación de zona segura
CreateThread(function()
    while true do
        local wait = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local insideNow = false
        local matchedName = ""

        for _, zone in ipairs(safeZones) do
            local dist = #(playerCoords - zone.coords)
            if dist <= zone.radius then
                insideNow = true
                matchedName = zone.name
                break
            end
        end

        if insideNow and not inSafeZone then
            inSafeZone = true
            currentZoneName = matchedName
            QBCore.Functions.Notify("🛡️ Has entrado en " .. currentZoneName .. " [ZONA SEGURA]", "success", 5000)
            SetEntityInvincible(playerPed, true)
            SetPlayerInvincible(PlayerId(), true)
        elseif not insideNow and inSafeZone then
            inSafeZone = false
            currentZoneName = ""
            QBCore.Functions.Notify("⚠️ Has salido de la Zona Segura. Hostilidades y combate reactivados.", "error", 4000)
            SetEntityInvincible(playerPed, false)
            SetPlayerInvincible(PlayerId(), false)
            local veh = GetVehiclePedIsIn(playerPed, false)
            if veh ~= 0 then
                SetVehicleMaxSpeed(veh, 0.0) -- Quitar límite de velocidad
            end
        end

        Wait(wait)
    end
end)

-- Bucle de restricción de combate y velocidad dentro de la zona segura
CreateThread(function()
    while true do
        if inSafeZone then
            local playerPed = PlayerPedId()
            local playerId = PlayerId()

            -- Desarmar al jugador si empuña armas de fuego o cuerpo a cuerpo
            local currentWeapon = GetSelectedPedWeapon(playerPed)
            if currentWeapon ~= `WEAPON_UNARMED` then
                SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)
            end

            -- Bloquear todas las acciones de ataque y apuntado
            DisablePlayerFiring(playerId, true)
            DisableControlAction(0, 24, true)  -- Disparo / Ataque
            DisableControlAction(0, 25, true)  -- Apuntar con arma
            DisableControlAction(0, 47, true)  -- Detonar
            DisableControlAction(0, 58, true)  -- Acción de arma
            DisableControlAction(0, 140, true) -- Golpe cuerpo a cuerpo ligero
            DisableControlAction(0, 141, true) -- Golpe fuerte
            DisableControlAction(0, 142, true) -- Golpe alternativo
            DisableControlAction(0, 257, true) -- Disparo 2
            DisableControlAction(0, 263, true) -- Combate
            DisableControlAction(0, 264, true) -- Combate

            -- Evitar atropellos masivos (VDM) limitando la velocidad a ~55 km/h
            local veh = GetVehiclePedIsIn(playerPed, false)
            if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == playerPed then
                SetVehicleMaxSpeed(veh, 15.2) -- 55 km/h aprox
            end

            -- Texto visual permanente en la pantalla
            DrawSafeZoneBanner(currentZoneName)

            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- Renderizado de banner informativo de zona segura
function DrawSafeZoneBanner(zoneName)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.38, 0.38)
    SetTextColour(46, 204, 113, 230)
    SetTextDropshadow(1, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("🛡️ ZONA SEGURA (" .. zoneName .. ") - COMBATE DESACTIVADO")
    EndTextCommandDisplayText(0.5, 0.02)
end
