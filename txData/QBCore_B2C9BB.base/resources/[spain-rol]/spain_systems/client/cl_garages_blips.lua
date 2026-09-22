-- =========================================================================
-- SPAIN ROL - GARAJES PÚBLICOS Y TALLERES MECÁNICOS
-- =========================================================================
-- Señaliza todos los garajes y talleres en el mapa con blips claros y
-- proporciona punto de reparación y puesta a punto en los talleres.

local QBCore = exports['qb-core']:GetCoreObject()

local garages = {
    { name = "Garaje Central (Legion)", coords = vector3(215.18, -805.02, 30.73) },
    { name = "Garaje Hospital Central", coords = vector3(340.15, -584.94, 28.8) },
    { name = "Garaje Aeropuerto Internacional", coords = vector3(-1036.0, -2733.0, 13.75) },
    { name = "Garaje Puerto de Los Santos", coords = vector3(932.1, -3055.2, 5.9) },
    { name = "Garaje Sandy Shores", coords = vector3(1738.2, 3710.4, 34.1) },
    { name = "Garaje Paleto Bay", coords = vector3(-118.4, 6455.5, 31.4) },
}

local mechanicShops = {
    { name = "Taller Los Santos Customs (Centro)", coords = vector3(-338.44, -136.75, 39.0) },
    { name = "Taller Los Santos Customs (Aeropuerto)", coords = vector3(-1155.54, -2007.18, 13.18) },
    { name = "Taller Mecánico Harmony Repair", coords = vector3(1175.05, 2640.22, 37.75) },
    { name = "Taller Mecánico Paleto Bay", coords = vector3(110.82, 6626.34, 31.79) },
}

-- Crear Blips de Garajes y Talleres
CreateThread(function()
    -- Garajes Públicos
    for _, g in ipairs(garages) do
        local blip = AddBlipForCoord(g.coords.x, g.coords.y, g.coords.z)
        SetBlipSprite(blip, 357) -- Icono de garaje / parking
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.75)
        SetBlipColour(blip, 3) -- Azul claro
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(g.name)
        EndTextCommandSetBlipName(blip)
    end

    -- Talleres Mecánicos
    for _, t in ipairs(mechanicShops) do
        local blip = AddBlipForCoord(t.coords.x, t.coords.y, t.coords.z)
        SetBlipSprite(blip, 446) -- Icono de llave inglesa
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 5) -- Amarillo
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(t.name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Reparación rápida en talleres mecánicos
CreateThread(function()
    while true do
        local wait = 1000
        local playerPed = PlayerPedId()

        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            if GetPedInVehicleSeat(veh, -1) == playerPed then
                local coords = GetEntityCoords(veh)
                local inShop = false
                local currentShop = nil

                for _, shop in ipairs(mechanicShops) do
                    if #(coords - shop.coords) < 15.0 then
                        inShop = true
                        currentShop = shop
                        break
                    end
                end

                if inShop then
                    wait = 0
                    DrawMarker(36, currentShop.coords.x, currentShop.coords.y, currentShop.coords.z + 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.8, 1.8, 1.0, 240, 200, 0, 150, false, false, 2, true, nil, nil, false)
                    
                    QBCore.Functions.DrawText3D(currentShop.coords.x, currentShop.coords.y, currentShop.coords.z + 1.2, "~y~[E]~s~ Reparar y Limpiar Vehículo")

                    if IsControlJustPressed(0, 38) then -- Tecla E
                        QBCore.Functions.Progressbar("repair_taller", "Mecánicos realizando puesta a punto...", 4000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {}, {}, {}, function() -- Done
                            SetVehicleFixed(veh)
                            SetVehicleDeformationFixed(veh)
                            SetVehicleUndriveable(veh, false)
                            SetVehicleEngineHealth(veh, 1000.0)
                            SetVehicleBodyHealth(veh, 1000.0)
                            SetVehicleDirtLevel(veh, 0.0)
                            for i = 0, 7 do
                                SetVehicleTyreFixed(veh, i)
                            end
                            QBCore.Functions.Notify("🔧 Vehículo reparado y lavado al 100% por los mecánicos.", "success", 4000)
                        end)
                    end
                end
            end
        end

        Wait(wait)
    end
end)
