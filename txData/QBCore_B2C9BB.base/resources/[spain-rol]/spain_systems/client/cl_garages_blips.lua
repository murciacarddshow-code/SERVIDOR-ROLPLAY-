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
    {
        name = "Benny's Original Motor Works",
        coords = vector3(-211.73, -1325.28, 30.89),
        sprite = 402,
        color = 46,
        bays = {
            { name = "Benny's - Bahía 1 (Elevador Principal)", coords = vector3(-211.73, -1325.28, 30.89) },
            { name = "Benny's - Bahía 2 (Puesto Tuning y Chapa)", coords = vector3(-205.50, -1318.80, 31.0) },
            { name = "Benny's - Bahía 3 (Puesta a Punto Rápida)", coords = vector3(-223.10, -1329.50, 30.89) }
        }
    },
    {
        name = "Canals Customs (Taller Vespucci)",
        coords = vector3(-1158.80, -1519.80, 4.37),
        sprite = 446,
        color = 18, -- Cyan / Azul Canals
        bays = {
            { name = "Canals - Bahía 1 (Elevador Principal)", coords = vector3(-1158.80, -1519.80, 4.37) },
            { name = "Canals - Bahía 2 (Puesto Competición y Motor)", coords = vector3(-1153.20, -1514.50, 4.37) },
            { name = "Canals - Bahía 3 (Alineación y Ruedas)", coords = vector3(-1164.50, -1524.20, 4.37) }
        }
    },
    {
        name = "Los Santos Customs (Centro)",
        coords = vector3(-338.44, -136.75, 39.0),
        sprite = 72,
        color = 46,
        bays = {
            { name = "LSC - Bahía 1 (Foso Principal)", coords = vector3(-338.44, -136.75, 39.0) },
            { name = "LSC - Bahía 2 (Cabina de Modificación)", coords = vector3(-324.11, -147.11, 39.10) },
            { name = "LSC - Bahía 3 (Inspección y Ruedas)", coords = vector3(-342.10, -145.50, 39.0) }
        }
    },
    {
        name = "Los Santos Customs (Aeropuerto)",
        coords = vector3(-1155.54, -2007.18, 13.18),
        sprite = 72,
        color = 46,
        bays = {
            { name = "LSC Aeropuerto - Bahía 1", coords = vector3(-1155.54, -2007.18, 13.18) },
            { name = "LSC Aeropuerto - Bahía 2", coords = vector3(-1146.40, -2002.05, 13.19) }
        }
    },
    {
        name = "Taller Harmony Repair",
        coords = vector3(1175.05, 2640.22, 37.75),
        sprite = 446,
        color = 5,
        bays = {
            { name = "Harmony - Bahía 1", coords = vector3(1175.05, 2640.22, 37.75) }
        }
    },
    {
        name = "Taller Paleto Bay",
        coords = vector3(110.82, 6626.34, 31.79),
        sprite = 446,
        color = 5,
        bays = {
            { name = "Paleto - Bahía 1", coords = vector3(110.82, 6626.34, 31.79) }
        }
    }
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

    -- Talleres Mecánicos con Blips y Sprites Propios
    for _, t in ipairs(mechanicShops) do
        local blip = AddBlipForCoord(t.coords.x, t.coords.y, t.coords.z)
        SetBlipSprite(blip, t.sprite or 446)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, t.color or 5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(t.name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Reparación y puesta a punto en bahías de talleres mecánicos
CreateThread(function()
    while true do
        local wait = 1000
        local playerPed = PlayerPedId()

        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            if GetPedInVehicleSeat(veh, -1) == playerPed then
                local coords = GetEntityCoords(veh)
                local inBay = false
                local activeBay = nil

                for _, shop in ipairs(mechanicShops) do
                    if shop.bays then
                        for _, bay in ipairs(shop.bays) do
                            if #(coords - bay.coords) < 4.0 then
                                inBay = true
                                activeBay = bay
                                break
                            end
                        end
                    end
                    if inBay then break end
                end

                if inBay and activeBay then
                    wait = 0
                    DrawMarker(36, activeBay.coords.x, activeBay.coords.y, activeBay.coords.z + 0.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.8, 1.8, 1.0, 240, 200, 0, 150, false, false, 2, true, nil, nil, false)
                    
                    QBCore.Functions.DrawText3D(activeBay.coords.x, activeBay.coords.y, activeBay.coords.z + 1.1, string.format("~y~[E]~s~ %s (Puesta a Punto)", activeBay.name))

                    if IsControlJustPressed(0, 38) then -- Tecla E
                        QBCore.Functions.Progressbar("repair_taller", "Mecánicos realizando puesta a punto en bahía...", 4000, false, true, {
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
                            QBCore.Functions.Notify("🔧 " .. activeBay.name .. ": Vehículo reparado y listo para rodar.", "success", 4000)
                        end)
                    end
                end
            end
        end

        Wait(wait)
    end
end)
