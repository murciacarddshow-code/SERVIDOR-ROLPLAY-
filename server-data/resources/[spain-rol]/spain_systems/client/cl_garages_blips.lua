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
    { name = "Taller Benny's Original Motor Works", coords = vector3(-211.34, -1323.98, 30.89) },
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

-- Los talleres mecánicos son atendidos exclusivamente por mecánicos en servicio con piezas físicas y kits de reparación.
