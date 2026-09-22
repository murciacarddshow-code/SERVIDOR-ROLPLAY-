-- =========================================================================
-- SPAIN ROL - SISTEMA DE TUNING Y PERSONALIZACIÓN DE VEHÍCULOS
-- =========================================================================
-- Menú completo de modificaciones estéticas y de rendimiento en Benny's y LSC.
-- Precios tipificados en Euros con guardado permanente en la base de datos.

local QBCore = exports['qb-core']:GetCoreObject()

local tuningShops = {
    { name = "Benny's Original Motor Works", coords = vector3(-211.34, -1323.98, 30.89) },
    { name = "Los Santos Customs (Centro)", coords = vector3(-338.44, -136.75, 39.0) },
    { name = "Los Santos Customs (Aeropuerto)", coords = vector3(-1155.54, -2007.18, 13.18) },
    { name = "Taller Mecánico Harmony", coords = vector3(1175.05, 2640.22, 37.75) }
}

-- Menú Principal de Modificaciones
local function OpenTuningMenu(veh)
    local tuningMenu = {
        {
            header = "🔧 Taller de Modificaciones & Tuning",
            isMenuHeader = true,
        },
        {
            header = "🚀 Mejoras de Rendimiento",
            txt = "Motor, Frenos, Transmisión, Suspensión y Turbo",
            params = {
                event = "spain_tuning:client:performanceMenu",
                args = { veh = veh }
            }
        },
        {
            header = "🎨 Carrocería y Pintura",
            txt = "Pintura principal, secundaria y tintado de lunas",
            params = {
                event = "spain_tuning:client:cosmeticMenu",
                args = { veh = veh }
            }
        },
        {
            header = "✨ Neones e Iluminación",
            txt = "Luces de neón bajo chasis y faros de xenón",
            params = {
                event = "spain_tuning:client:neonMenu",
                args = { veh = veh }
            }
        },
        {
            header = "🏁 Ruedas y Alerones",
            txt = "Alerones deportivos y llantas de competición",
            params = {
                event = "spain_tuning:client:wheelsMenu",
                args = { veh = veh }
            }
        },
        {
            header = "❌ Salir del Menú",
            params = {
                event = "qb-menu:client:closeMenu"
            }
        }
    }
    exports['qb-menu']:openMenu(tuningMenu)
end

-- Submenú Rendimiento
RegisterNetEvent('spain_tuning:client:performanceMenu', function(data)
    local veh = data.veh
    local perfMenu = {
        { header = "⬅️ Volver al Menú Principal", params = { event = "spain_tuning:client:openMain", args = { veh = veh } } },
        {
            header = "Motor de Competición (Nivel 4)",
            txt = "Potencia máxima de aceleración - 2.500€",
            params = { event = "spain_tuning:client:applyMod", args = { veh = veh, modType = 11, modIndex = 3, price = 2500, label = "Motor Nivel 4" } }
        },
        {
            header = "Frenos Cerámicos (Nivel 3)",
            txt = "Frenada deportiva de alta respuesta - 1.800€",
            params = { event = "spain_tuning:client:applyMod", args = { veh = veh, modType = 12, modIndex = 2, price = 1800, label = "Frenos Cerámicos" } }
        },
        {
            header = "Transmisión de Carreras (Nivel 3)",
            txt = "Cambio de marcha inmediato - 2.000€",
            params = { event = "spain_tuning:client:applyMod", args = { veh = veh, modType = 13, modIndex = 2, price = 2000, label = "Transmisión de Carreras" } }
        },
        {
            header = "Suspensión Deportiva Rebajada",
            txt = "Centro de gravedad optimizado para curvas - 1.200€",
            params = { event = "spain_tuning:client:applyMod", args = { veh = veh, modType = 15, modIndex = 3, price = 1200, label = "Suspensión de Competición" } }
        },
        {
            header = "Turbocompresor Deportivo",
            txt = "Sobrealimentación y sonido de descarga - 4.500€",
            params = { event = "spain_tuning:client:applyTurbo", args = { veh = veh, price = 4500 } }
        }
    }
    exports['qb-menu']:openMenu(perfMenu)
end)

-- Submenú Iluminación y Neones
RegisterNetEvent('spain_tuning:client:neonMenu', function(data)
    local veh = data.veh
    local neonMenu = {
        { header = "⬅️ Volver al Menú Principal", params = { event = "spain_tuning:client:openMain", args = { veh = veh } } },
        {
            header = "Instalar Neón Azul Spain",
            txt = "Kit completo de 4 laterales - 800€",
            params = { event = "spain_tuning:client:applyNeon", args = { veh = veh, r = 0, g = 150, b = 255, price = 800 } }
        },
        {
            header = "Instalar Neón Rojo Furia",
            txt = "Kit completo de 4 laterales - 800€",
            params = { event = "spain_tuning:client:applyNeon", args = { veh = veh, r = 255, g = 20, b = 20, price = 800 } }
        },
        {
            header = "Instalar Neón Verde Toxic",
            txt = "Kit completo de 4 laterales - 800€",
            params = { event = "spain_tuning:client:applyNeon", args = { veh = veh, r = 0, g = 255, b = 100, price = 800 } }
        },
        {
            header = "Instalar Neón Blanco Puro",
            txt = "Kit completo de 4 laterales - 800€",
            params = { event = "spain_tuning:client:applyNeon", args = { veh = veh, r = 255, g = 255, b = 255, price = 800 } }
        },
        {
            header = "Faros de Xenón",
            txt = "Haz de luz blanco brillante - 600€",
            params = { event = "spain_tuning:client:applyXenon", args = { veh = veh, price = 600 } }
        }
    }
    exports['qb-menu']:openMenu(neonMenu)
end)

-- Submenú Carrocería
RegisterNetEvent('spain_tuning:client:cosmeticMenu', function(data)
    local veh = data.veh
    local cosMenu = {
        { header = "⬅️ Volver al Menú Principal", params = { event = "spain_tuning:client:openMain", args = { veh = veh } } },
        {
            header = "Pintura Negro Mate",
            txt = "Acabado premium mate - 500€",
            params = { event = "spain_tuning:client:applyColor", args = { veh = veh, color = 12, price = 500 } }
        },
        {
            header = "Pintura Blanco Puro Metalizado",
            txt = "Acabado perlado - 500€",
            params = { event = "spain_tuning:client:applyColor", args = { veh = veh, color = 111, price = 500 } }
        },
        {
            header = "Pintura Rojo Torino Metalizado",
            txt = "Brillo intenso - 500€",
            params = { event = "spain_tuning:client:applyColor", args = { veh = veh, color = 27, price = 500 } }
        },
        {
            header = "Pintura Azul Marino Metalizado",
            txt = "Elegante tono oscuro - 500€",
            params = { event = "spain_tuning:client:applyColor", args = { veh = veh, color = 64, price = 500 } }
        },
        {
            header = "Tintado de Lunas Limo (Negro Opaco)",
            txt = "Privacidad total en el habitáculo - 350€",
            params = { event = "spain_tuning:client:applyTint", args = { veh = veh, tint = 1, price = 350 } }
        }
    }
    exports['qb-menu']:openMenu(cosMenu)
end)

-- Submenú Alerones
RegisterNetEvent('spain_tuning:client:wheelsMenu', function(data)
    local veh = data.veh
    local wheelMenu = {
        { header = "⬅️ Volver al Menú Principal", params = { event = "spain_tuning:client:openMain", args = { veh = veh } } },
        {
            header = "Alerón de Competición GT",
            txt = "Mayor agarre a altas velocidades - 950€",
            params = { event = "spain_tuning:client:applyMod", args = { veh = veh, modType = 0, modIndex = 0, price = 950, label = "Alerón Deportivo" } }
        },
        {
            header = "Tubo de Escape Doble Cromado",
            txt = "Salidas de escape deportivas - 700€",
            params = { event = "spain_tuning:client:applyMod", args = { veh = veh, modType = 4, modIndex = 1, price = 700, label = "Escapes Deportivos" } }
        }
    }
    exports['qb-menu']:openMenu(wheelMenu)
end)

-- Handlers de aplicación y cobro
RegisterNetEvent('spain_tuning:client:openMain', function(data)
    OpenTuningMenu(data.veh)
end)

RegisterNetEvent('spain_tuning:client:applyMod', function(data)
    TriggerServerEvent('spain_tuning:server:payAndSave', data.price, function(paid)
        if paid then
            SetVehicleModKit(data.veh, 0)
            SetVehicleMod(data.veh, data.modType, data.modIndex, false)
            QBCore.Functions.Notify('Instalado: ' .. data.label .. ' por ' .. data.price .. '€.', 'success')
        end
    end)
end)

RegisterNetEvent('spain_tuning:client:applyTurbo', function(data)
    TriggerServerEvent('spain_tuning:server:payAndSave', data.price, function(paid)
        if paid then
            ToggleVehicleMod(data.veh, 18, true) -- Turbo
            QBCore.Functions.Notify('Turbocompresor de competición instalado por ' .. data.price .. '€.', 'success')
        end
    end)
end)

RegisterNetEvent('spain_tuning:client:applyXenon', function(data)
    TriggerServerEvent('spain_tuning:server:payAndSave', data.price, function(paid)
        if paid then
            ToggleVehicleMod(data.veh, 22, true) -- Xenon
            QBCore.Functions.Notify('Faros de xenón instalados por ' .. data.price .. '€.', 'success')
        end
    end)
end)

RegisterNetEvent('spain_tuning:client:applyColor', function(data)
    TriggerServerEvent('spain_tuning:server:payAndSave', data.price, function(paid)
        if paid then
            SetVehicleColours(data.veh, data.color, data.color)
            QBCore.Functions.Notify('Pintura aplicada por ' .. data.price .. '€.', 'success')
        end
    end)
end)

RegisterNetEvent('spain_tuning:client:applyTint', function(data)
    TriggerServerEvent('spain_tuning:server:payAndSave', data.price, function(paid)
        if paid then
            SetVehicleWindowTint(data.veh, data.tint)
            QBCore.Functions.Notify('Lunas tintadas por ' .. data.price .. '€.', 'success')
        end
    end)
end)

RegisterNetEvent('spain_tuning:client:applyNeon', function(data)
    TriggerServerEvent('spain_tuning:server:payAndSave', data.price, function(paid)
        if paid then
            for i = 0, 3 do
                SetVehicleNeonLightEnabled(data.veh, i, true)
            end
            SetVehicleNeonLightsColour(data.veh, data.r, data.g, data.b)
            QBCore.Functions.Notify('Kit de neones instalado por ' .. data.price .. '€.', 'success')
        end
    end)
end)

-- Bucle de detección en talleres mecánicos
CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(veh, -1) == ped then
                local coords = GetEntityCoords(veh)

                for _, shop in ipairs(tuningShops) do
                    local dist = #(coords - shop.coords)
                    if dist < 12.0 then
                        wait = 0
                        QBCore.Functions.DrawText3D(shop.coords.x, shop.coords.y, shop.coords.z + 1.2, "~r~[G]~s~ Personalizar Vehículo (Tuning & Mejoras)")

                        if IsControlJustPressed(0, 47) or IsControlJustPressed(0, 58) then -- Tecla G
                            OpenTuningMenu(veh)
                        end
                        break
                    end
                end
            end
        end

        Wait(wait)
    end
end)
