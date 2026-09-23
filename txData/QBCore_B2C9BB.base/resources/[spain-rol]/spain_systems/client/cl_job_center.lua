-- =========================================================================
-- SPAIN ROL - CENTRO DE INFORMACIÓN Y EMPLEO (INEM CENTRAL)
-- =========================================================================
-- Ubicado en la explanada peatonal junto al Concesionario Oficial de Los Santos (PDM).
-- Cuenta con NPC orientador laboral, blip oficial en el mapa y menú categorizado
-- para seleccionar cualquiera de los trabajos tradicionales o innovadores del servidor.

local QBCore = exports['qb-core']:GetCoreObject()
local spawnedPed = nil
local blip = nil

-- Configuración del Punto de Información
local CenterConfig = {
    coords = vector4(-38.45, -1100.5, 26.42, 68.0),
    pedModel = `a_m_m_business_01`,
    scenario = 'WORLD_HUMAN_CLIPBOARD',
    blip = {
        sprite = 407,
        color = 2,
        scale = 0.8,
        title = "🏢 Centro de Empleo e Información | Los Santos"
    }
}

-- Catálogo de Trabajos Clasificados
local JobCatalog = {
    ['transport'] = {
        title = "🚚 Transporte y Logística",
        icon = "fas fa-truck-moving",
        jobs = {
            {
                id = 'trucker',
                label = 'Camionero de Transporte Pesado',
                salary = '55€ - 140€ / hora',
                desc = 'Transporte de contenedores y mercancías pesadas por autopistas e industrias.',
                location = 'Terminal Portuaria de Los Santos',
                coords = vector3(-425.2, -2786.8, 6.0)
            },
            {
                id = 'delivery',
                label = 'Repartidor de Paquetería Express',
                salary = '55€ - 140€ / hora',
                desc = 'Reparto ágil de pedidos puerta a puerta en furgoneta Go Postal.',
                location = 'Central de Paquetería Go Postal',
                coords = vector3(68.9, -1569.8, 29.5)
            },
            {
                id = 'bus',
                label = 'Conductor de Autobús Urbano',
                salary = '50€ - 135€ / hora',
                desc = 'Transporte metropolitano de pasajeros con paradas programadas por la ciudad.',
                location = 'Estación Central Dashound',
                coords = vector3(437.2, -624.2, 28.5)
            },
            {
                id = 'pizza',
                label = 'Repartidor de Pizza This',
                salary = '50€ - 135€ / hora',
                desc = 'Entregas calientes de pizzas en ciclomotor con propinas al instante.',
                location = 'Pizzería Pizza This (Del Perro)',
                coords = vector3(-565.4, 274.6, 83.0)
            }
        }
    },
    ['services'] = {
        title = "🛠️ Servicios Ciudadanos y Asistencia",
        icon = "fas fa-wrench",
        jobs = {
            {
                id = 'taxi',
                label = 'Taxista Metropolitano',
                salary = '50€ - 150€ / hora',
                desc = 'Servicio público de transporte particular con taxímetro reglamentario.',
                location = 'Central Downtown Cab Co',
                coords = vector3(895.8, -179.3, 74.7)
            },
            {
                id = 'tow',
                label = 'Servicio de Grúa y Asistencia',
                salary = '50€ - 135€ / hora',
                desc = 'Retirada de vehículos averiados, mal estacionados y asistencia en carretera.',
                location = 'Depósito Municipal de Grúas',
                coords = vector3(491.0, -1332.2, 29.3)
            },
            {
                id = 'garbage',
                label = 'Operario de Limpieza Urbana',
                salary = '55€ - 140€ / hora',
                desc = 'Recogida de residuos y mantenimiento de higiene en los barrios de Los Santos.',
                location = 'Planta de Tratamiento de Residuos Sur',
                coords = vector3(-322.2, -1545.9, 31.0)
            },
            {
                id = 'windowcleaner',
                label = 'Limpiador de Cristales en Rascacielos',
                salary = '60€ - 145€ / hora',
                desc = 'Trabajos verticales de limpieza en andamios colgantes de grandes torres.',
                location = 'Torre Maze Bank Downtown',
                coords = vector3(-75.2, -819.3, 326.1)
            }
        }
    },
    ['industry'] = {
        title = "⚡ Industria, Oficios y Seguridad",
        icon = "fas fa-hard-hat",
        jobs = {
            {
                id = 'miner',
                label = 'Minero de Cantera Davis Quartz',
                salary = '55€ - 145€ / hora',
                desc = 'Extracción de roca, picado con barrena, lavado y fundición de metales preciosos.',
                location = 'Cantera Davis Quartz',
                coords = vector3(2953.5, 2787.6, 41.5)
            },
            {
                id = 'lumberjack',
                label = 'Leñador Forestal de Paleto',
                salary = '55€ - 145€ / hora',
                desc = 'Tala de árboles en bosques de Paleto, procesado de troncos y aserradero.',
                location = 'Aserradero Forestal de Paleto',
                coords = vector3(-552.8, 5348.6, 74.7)
            },
            {
                id = 'electrician',
                label = 'Técnico Electricista Municipal',
                salary = '55€ - 150€ / hora',
                desc = 'Mantenimiento del alumbrado público, cajas de fusibles y cableado de alta tensión.',
                location = 'Subestación Eléctrica Palmer-Taylor',
                coords = vector3(2732.1, 1573.4, 30.7)
            },
            {
                id = 'security',
                label = 'Vigilante de Seguridad Privada',
                salary = '55€ - 150€ / hora',
                desc = 'Custodia preventiva, patrullaje de centros comerciales y control de accesos.',
                location = 'Sede Central de Seguridad Gruppe Sechs',
                coords = vector3(454.4, -3051.2, 5.9)
            }
        }
    },
    ['nature'] = {
        title = "🌾 Campo, Pesca y Naturaleza",
        icon = "fas fa-leaf",
        jobs = {
            {
                id = 'fisherman',
                label = 'Pescador Profesional de Alta Mar',
                salary = '50€ - 140€ / hora',
                desc = 'Pesca en barcos o muelles, captura de especies autóctonas y venta a lonja.',
                location = 'Muelle Pesquero de Del Perro',
                coords = vector3(-1816.8, -1193.3, 19.3)
            },
            {
                id = 'farmer',
                label = 'Agricultor de Campo Grapeseed',
                salary = '50€ - 140€ / hora',
                desc = 'Arado de tierras, cosecha de cereales y distribución agrícola a tiendas locales.',
                location = 'Cooperativa Agrícola de Grapeseed',
                coords = vector3(2447.8, 4976.2, 46.8)
            },
            {
                id = 'diver',
                label = 'Buzo Profesional y Rescate Acuático',
                salary = '55€ - 150€ / hora',
                desc = 'Inmersiones con equipo autónomo para recuperación de pecios y recursos marinos.',
                location = 'Muelle de Inmersión Paleto Cove',
                coords = vector3(-1613.5, 5262.1, 3.9)
            },
            {
                id = 'gardener',
                label = 'Jardinero y Paisajista Municipal',
                salary = '50€ - 135€ / hora',
                desc = 'Cuidado botánico de parques de la ciudad y jardines residenciales de Vinewood.',
                location = 'Vivero y Parques de Vinewood Hills',
                coords = vector3(131.2, 558.1, 184.2)
            }
        }
    },
    ['hospitality'] = {
        title = "🍔 Hostelería, Ocio y Medios",
        icon = "fas fa-utensils",
        jobs = {
            {
                id = 'hotdog',
                label = 'Puesto de Perritos Calientes',
                salary = '50€ - 130€ / hora',
                desc = 'Venta ambulante de comida callejera, bebidas frías y aperitivos a transeúntes.',
                location = 'Plaza de Legion Square',
                coords = vector3(149.2, -1040.8, 29.3)
            },
            {
                id = 'waiter',
                label = 'Camarero y Personal de Sala',
                salary = '50€ - 135€ / hora',
                desc = 'Servicio de bebidas, cócteles selectos y atención a clientes en locales de ocio.',
                location = 'Bahama Mamas Club',
                coords = vector3(-1388.2, -588.6, 30.3)
            },
            {
                id = 'reporter',
                label = 'Periodista Weazel News',
                salary = '50€ - 140€ / hora',
                desc = 'Cobertura de sucesos en directo, entrevistas exclusivas e investigación periodística.',
                location = 'Edificio Central Weazel News',
                coords = vector3(-598.6, -929.8, 23.8)
            }
        }
    },
    ['exclusive'] = {
        title = "🌟 Empleos Exclusivos e Inventados [Spain Rol]",
        icon = "fas fa-gem",
        jobs = {
            {
                id = 'cards_courier',
                label = 'Repartidor Especialista TCG (Murcia Card Show)',
                salary = '60€ - 160€ / hora',
                desc = 'Transporte acorazado y custodia de cajas selladas, boosters y cartas graduadas PSA 10.',
                location = 'Almacén Central Murcia Card Show',
                coords = vector3(78.9, -1390.2, 29.3)
            },
            {
                id = 'vintage_picker',
                label = 'Chatarrero Vintage y Buscador de Reliquias',
                salary = '55€ - 155€ / hora',
                desc = 'Inspección de desguaces para rescatar piezas clásicas, reliquias y coches de época.',
                location = 'Desguace Central de La Puerta',
                coords = vector3(-474.3, -1717.8, 18.6)
            },
            {
                id = 'content_creator',
                label = 'Creador de Contenido Urbano / Streamer',
                salary = '50€ - 160€ / hora',
                desc = 'Directos en vivo, vlogs callejeros, entrevistas virales y donaciones de espectadores.',
                location = 'Paseo de la Fama de Vinewood',
                coords = vector3(312.3, 178.5, 104.2)
            },
            {
                id = 'wildlife_ranger',
                label = 'Guardabosques Monte Chiliad',
                salary = '55€ - 155€ / hora',
                desc = 'Vigilancia de parques naturales, protección de fauna autóctona y rescate de senderistas.',
                location = 'Estación de Rangers Monte Chiliad',
                coords = vector3(-438.1, 5600.3, 44.9)
            },
            {
                id = 'wine_sommelier',
                label = 'Enólogo y Maestro Bodeguero Marlowe',
                salary = '55€ - 160€ / hora',
                desc = 'Supervisión de añadas de uva, fermentación en barrica y catas exclusivas de vino selecto.',
                location = 'Bodegas del Viñedo Marlowe',
                coords = vector3(-1888.2, 2060.1, 140.9)
            },
            {
                id = 'food_critic',
                label = 'Inspector y Crítico Gastronómico',
                salary = '55€ - 160€ / hora',
                desc = 'Evaluación culinaria de locales, inspección de recetas y concesión de Estrellas Michelin.',
                location = 'Boulevard Gourmet de Rockford Hills',
                coords = vector3(-632.1, -237.2, 38.0)
            }
        }
    }
}

-- Función para dibujar texto 3D sutil
local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 100)
    end
end

-- Menú de Confirmación y Firma de Contrato
local function OpenJobConfirmMenu(jobData)
    local menu = {
        {
            header = "📝 Contrato de Trabajo: " .. jobData.label,
            isMenuHeader = true
        },
        {
            header = "💼 Condiciones del Puesto",
            txt = "• Sueldo base: " .. jobData.salary .. "<br>• Funciones: " .. jobData.desc .. "<br>• Sede principal: " .. jobData.location,
            isMenuHeader = true
        },
        {
            header = "✅ Firmar Contrato y Empezar a Trabajar",
            txt = "Te incorporarás de inmediato y marcaremos la sede en tu GPS.",
            params = {
                event = "spain_jobs:client:confirmContract",
                args = jobData
            }
        },
        {
            header = "⬅️ Volver al Catálogo",
            txt = "Explorar otras ofertas de empleo.",
            params = {
                event = "spain_jobs:client:openCategory",
                args = { category = jobData.category }
            }
        }
    }

    exports['qb-menu']:openMenu(menu)
end

-- Submenú de una Categoría Específica
local function OpenCategoryMenu(catKey)
    local catData = JobCatalog[catKey]
    if not catData then return end

    local menu = {
        {
            header = catData.title,
            isMenuHeader = true
        },
        {
            header = "⬅️ Volver al Panel Principal",
            txt = "Ver todas las categorías de empleo.",
            params = {
                event = "spain_jobs:client:openMainMenu"
            }
        }
    }

    for _, j in ipairs(catData.jobs) do
        j.category = catKey
        table.insert(menu, {
            header = j.label,
            txt = "💰 " .. j.salary .. " | 📍 " .. j.location,
            params = {
                event = "spain_jobs:client:viewJob",
                args = j
            }
        })
    end

    exports['qb-menu']:openMenu(menu)
end

-- Menú Principal del Centro de Información y Empleo
local function OpenJobCenterMenu()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local currentJobLabel = (PlayerData.job and PlayerData.job.label) or "Civil / Desempleado"
    local currentGradeName = (PlayerData.job and PlayerData.job.grade and PlayerData.job.grade.name) or "Novato"
    local currentPayment = (PlayerData.job and PlayerData.job.payment) or 15

    local menu = {
        {
            header = "🏢 Centro de Información y Empleo | Los Santos",
            isMenuHeader = true
        },
        {
            header = "📌 Tu Empleo Actual",
            txt = "Puesto: <strong>" .. currentJobLabel .. "</strong> (" .. currentGradeName .. ")<br>Nómina actual: €" .. currentPayment .. " / ciclo",
            isMenuHeader = true
        },
        {
            header = JobCatalog['exclusive'].title,
            txt = "Cartas TCG Murcia, Chatarrero Vintage, Streamer, Guardabosques, Bodeguero...",
            params = {
                event = "spain_jobs:client:openCategory",
                args = { category = 'exclusive' }
            }
        },
        {
            header = JobCatalog['transport'].title,
            txt = "Camionero, Paquetería Go Postal, Conductor de Bus, Pizzero...",
            params = {
                event = "spain_jobs:client:openCategory",
                args = { category = 'transport' }
            }
        },
        {
            header = JobCatalog['services'].title,
            txt = "Taxista, Grúa y Asistencia, Limpieza Urbana, Cristales en Rascacielos...",
            params = {
                event = "spain_jobs:client:openCategory",
                args = { category = 'services' }
            }
        },
        {
            header = JobCatalog['industry'].title,
            txt = "Minero Davis Quartz, Leñador Paleto, Electricista de Alta Tensión, Seguridad Privada...",
            params = {
                event = "spain_jobs:client:openCategory",
                args = { category = 'industry' }
            }
        },
        {
            header = JobCatalog['nature'].title,
            txt = "Pescador de Alta Mar, Agricultor Grapeseed, Buzo Marino, Jardinería...",
            params = {
                event = "spain_jobs:client:openCategory",
                args = { category = 'nature' }
            }
        },
        {
            header = JobCatalog['hospitality'].title,
            txt = "Perritos Calientes, Camarero / Barman, Periodista Weazel News...",
            params = {
                event = "spain_jobs:client:openCategory",
                args = { category = 'hospitality' }
            }
        },
        {
            header = "🛑 Rescindir Contrato (Quedar Desempleado)",
            txt = "Dejar tu trabajo actual y pasar a percibir la prestación por desempleo.",
            params = {
                event = "spain_jobs:client:quitJob"
            }
        },
        {
            header = "❌ Cerrar Consulta",
            params = {
                event = "qb-menu:client:closeMenu"
            }
        }
    }

    exports['qb-menu']:openMenu(menu)
end

-- Eventos de Navegación del Menú
RegisterNetEvent('spain_jobs:client:openMainMenu', function()
    OpenJobCenterMenu()
end)

RegisterNetEvent('spain_jobs:client:openCategory', function(data)
    if data and data.category then
        OpenCategoryMenu(data.category)
    end
end)

RegisterNetEvent('spain_jobs:client:viewJob', function(jobData)
    OpenJobConfirmMenu(jobData)
end)

RegisterNetEvent('spain_jobs:client:confirmContract', function(jobData)
    TriggerServerEvent('spain_jobs:server:selectJob', jobData.id, jobData.label, jobData.location, jobData.coords)
end)

RegisterNetEvent('spain_jobs:client:quitJob', function()
    TriggerServerEvent('spain_jobs:server:quitJob')
end)

-- Evento al firmar contrato con éxito
RegisterNetEvent('spain_jobs:client:jobAssigned', function(jobLabel, locationName, coords)
    PlaySoundFrontend(-1, "BASE_JUMP_PASSED", "HUD_AWARDS", 1)

    if coords then
        SetNewWaypoint(coords.x, coords.y)
        TriggerEvent('QBCore:Notify', "¡Contrato firmado! Hemos marcado en tu GPS la sede de: " .. locationName, "success", 7500)
    else
        TriggerEvent('QBCore:Notify', "¡Contrato firmado! Ahora eres " .. jobLabel .. ".", "success", 5000)
    end
end)

-- Inicialización de Blip y NPC
local function InitJobCenter()
    -- Blip oficial en el mapa
    blip = AddBlipForCoord(CenterConfig.coords.x, CenterConfig.coords.y, CenterConfig.coords.z)
    SetBlipSprite(blip, CenterConfig.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, CenterConfig.blip.scale)
    SetBlipColour(blip, CenterConfig.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(CenterConfig.blip.title)
    EndTextCommandSetBlipName(blip)

    -- Cargar modelo del orientador laboral
    RequestModel(CenterConfig.pedModel)
    local timeout = 0
    while not HasModelLoaded(CenterConfig.pedModel) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    if HasModelLoaded(CenterConfig.pedModel) then
        spawnedPed = CreatePed(4, CenterConfig.pedModel, CenterConfig.coords.x, CenterConfig.coords.y, CenterConfig.coords.z - 1.0, CenterConfig.coords.w, false, true)
        SetEntityHeading(spawnedPed, CenterConfig.coords.w)
        FreezeEntityPosition(spawnedPed, true)
        SetEntityInvincible(spawnedPed, true)
        SetBlockingOfNonTemporaryEvents(spawnedPed, true)
        TaskStartScenarioInPlace(spawnedPed, CenterConfig.scenario, 0, true)

        -- Soporte para qb-target
        if GetConvar('UseTarget', 'false') == 'true' or exports['qb-target'] then
            pcall(function()
                exports['qb-target']:AddTargetEntity(spawnedPed, {
                    options = {
                        {
                            type = "client",
                            event = "spain_jobs:client:openMainMenu",
                            icon = "fas fa-briefcase",
                            label = "Orientador Laboral (Oficina de Empleo)"
                        }
                    },
                    distance = 2.5
                })
            end)
        end
    end
end

-- Bucle de Proximidad e Interacción [E]
CreateThread(function()
    InitJobCenter()

    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)
        local dist = #(pCoords - vector3(CenterConfig.coords.x, CenterConfig.coords.y, CenterConfig.coords.z))

        if dist < 6.0 then
            sleep = 0
            if dist < 2.3 then
                DrawText3D(CenterConfig.coords.x, CenterConfig.coords.y, CenterConfig.coords.z + 1.0, "~g~[E]~s~ Hablar con Orientador Laboral (Oficina de Empleo)")
                if IsControlJustReleased(0, 38) then -- Tecla [E]
                    OpenJobCenterMenu()
                end
            end
        end

        Wait(sleep)
    end
end)

-- Limpieza al reiniciar script
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
    if DoesEntityExist(spawnedPed) then
        DeletePed(spawnedPed)
    end
end)
