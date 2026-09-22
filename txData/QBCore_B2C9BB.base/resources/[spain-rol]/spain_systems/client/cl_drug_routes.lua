-- =========================================================================
-- SPAIN ROL - RUTAS DE DROGAS Y PUNTOS DE RECOLECCIÓN Y PROCESADO
-- =========================================================================
-- Puntos físicos en el mapa para recolectar, procesar y empaquetar
-- Marihuana, Cocaína y Metanfetamina Azul (Breaking Bad / Blue Meth).

local QBCore = exports['qb-core']:GetCoreObject()

local drugLocations = {
    -- MARIHUANA
    {
        type = 'weed_harvest',
        name = "Plantación de Cannabis (Recolección)",
        coords = vector3(2224.2, 5576.9, 53.8),
        markerColor = { r = 46, g = 204, b = 113 },
        prompt = "~g~[E]~s~ Recolectar Hojas de Cannabis",
        actionText = "Cosechando plantas de marihuana...",
        animDict = "amb@world_human_gardener_plant@male@base",
        anim = "base",
        time = 5000,
        giveItem = 'weed_leaf',
        giveAmount = 3
    },
    {
        type = 'weed_process',
        name = "Secadero y Procesado de Marihuana",
        coords = vector3(1435.5, 6344.2, 23.9),
        markerColor = { r = 39, g = 174, b = 96 },
        prompt = "~g~[E]~s~ Secar y Despalillar Cogollos de Marihuana",
        actionText = "Secando y manicurando cogollos...",
        animDict = "anim@amb@business@weed@weed_inspecting_high_lh@",
        anim = "weed_inspecting_high_base_inspector",
        time = 6000,
        giveItem = 'weed_baggy',
        giveAmount = 2
    },

    -- COCAÍNA
    {
        type = 'coke_harvest',
        name = "Cultivo Oculto de Coca (Recolección)",
        coords = vector3(2856.1, 4443.2, 48.5),
        markerColor = { r = 241, g = 196, b = 15 },
        prompt = "~y~[E]~s~ Recolectar Hojas de Coca",
        actionText = "Deshojando arbustos de cocaína...",
        animDict = "amb@world_human_gardener_plant@male@base",
        anim = "base",
        time = 5000,
        giveItem = 'coca_leaf',
        giveAmount = 3
    },
    {
        type = 'coke_process',
        name = "Laboratorio Químico de Cocaína",
        coords = vector3(1243.2, -3130.6, 5.5),
        markerColor = { r = 243, g = 156, b = 18 },
        prompt = "~y~[E]~s~ Sintetizar Pasta Base y Prensado",
        actionText = "Mezclando reactivos y prensando cocaína...",
        animDict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@",
        anim = "chemical_pour_short_cooker",
        time = 7000,
        giveItem = 'cokebaggy',
        giveAmount = 2
    },

    -- METANFETAMINA AZUL (BLUE METH)
    {
        type = 'meth_cook',
        name = "Caravana Laboratorio de Cristal Azul",
        coords = vector3(1391.1, 3605.3, 38.9),
        markerColor = { r = 52, g = 152, b = 219 },
        prompt = "~b~[E]~s~ Cocinar Cristal Azul de Alta Pureza",
        actionText = "Cocinando cristales de metanfetamina azul...",
        animDict = "anim@amb@business@meth@meth_monitoring_cooking@cooking@",
        anim = "chemical_pour_short_cooker",
        time = 8000,
        giveItem = 'blue_meth',
        giveAmount = 2
    }
}

-- Blips discretos en el mapa para las rutas clandestinas
CreateThread(function()
    for _, loc in ipairs(drugLocations) do
        local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
        SetBlipSprite(blip, 140) -- Icono de hoja/sustancia
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.65)
        SetBlipColour(blip, 25) -- Verde oscuro
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(loc.name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Bucle de recolección y procesado
CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)

        for _, loc in ipairs(drugLocations) do
            local dist = #(pCoords - loc.coords)
            if dist < 12.0 then
                wait = 0
                DrawMarker(1, loc.coords.x, loc.coords.y, loc.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.4, 1.4, 0.6, loc.markerColor.r, loc.markerColor.g, loc.markerColor.b, 160, false, false, 2, false, nil, nil, false)

                if dist < 2.0 then
                    QBCore.Functions.DrawText3D(loc.coords.x, loc.coords.y, loc.coords.z + 0.5, loc.prompt)

                    if IsControlJustPressed(0, 38) then -- Tecla E
                        StartDrugAction(loc)
                    end
                end
            end
        end

        Wait(wait)
    end
end)

function StartDrugAction(loc)
    local ped = PlayerPedId()
    QBCore.Functions.Progressbar("drug_work", loc.actionText, loc.time, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = loc.animDict,
        anim = loc.anim,
        flags = 49,
    }, {}, {}, function()
        TriggerServerEvent('spain_drugs:server:giveReward', loc.giveItem, loc.giveAmount)
        QBCore.Functions.Notify('Has obtenido mercancía: ' .. loc.giveAmount .. 'x unidades.', 'success')
    end, function()
        QBCore.Functions.Notify('Acción cancelada.', 'error')
    end)
end

-- =========================================================================
-- VENTA DE DROGA EN ESQUINAS (/esquina)
-- =========================================================================
local isCornerSelling = false

RegisterCommand('esquina', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        QBCore.Functions.Notify('No puedes vender droga desde dentro de un vehículo.', 'error')
        return
    end

    if isCornerSelling then
        isCornerSelling = false
        QBCore.Functions.Notify('Has dejado de vender droga en la esquina.', 'error')
    else
        isCornerSelling = true
        QBCore.Functions.Notify('Esperando compradores clandestinos en la esquina...', 'primary', 5000)
        StartCornerSellingLoop()
    end
end, false)

function StartCornerSellingLoop()
    CreateThread(function()
        while isCornerSelling do
            Wait(math.random(10000, 18000))
            if not isCornerSelling then break end

            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) or IsEntityDead(ped) then
                isCornerSelling = false
                break
            end

            -- Tratar de vender 1 bolsita
            TriggerServerEvent('spain_drugs:server:sellCorner')
        end
    end)
end
