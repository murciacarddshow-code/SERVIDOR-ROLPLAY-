-- =========================================================================
-- SPAIN ROL - MARCADORES 3D POLICIALES EN MISSION ROW
-- =========================================================================
-- Incluye:
-- 1. Flecha Flotante en Armería (Taser, Pistola, Escopeta, Carabina, Chaleco, Esposas, etc.)
-- 2. Flecha Flotante en Depósito de Pruebas (Entrada de Nº Caso y Limpieza/Eliminación)
-- 3. Flecha Flotante en Fichaje / Huellas Dactilares (Con reporte detallado al chat)
-- 4. Flecha Flotante en Garaje Exterior (Spawneo y guardado de patrullas)
-- 5. Flecha Flotante en Terraza / Helipuerto (Spawneo y guardado de helicóptero Falcon)

local QBCore = exports['qb-core']:GetCoreObject()

-- Coordenadas de los Puntos Policiales
local PolicePoints = {
    armory = {
        name = "Armería Policial CNP",
        coords = vector3(453.07, -980.12, 30.69),
        color = { r = 0, g = 140, b = 255 },
        prompt = "[E] Armería Policial CNP"
    },
    evidence = {
        name = "Depósito Judicial de Pruebas",
        coords = vector3(442.17, -996.06, 30.69),
        color = { r = 241, g = 196, b = 15 },
        prompt = "[E] Depósito Judicial de Pruebas"
    },
    fingerprint = {
        name = "Escáner Biométrico de Huellas",
        coords = vector3(460.96, -989.18, 24.92),
        color = { r = 46, g = 204, b = 113 },
        prompt = "[E] Escanear Huella Dactilar"
    },
    garage = {
        name = "Garaje de Patrullas CNP",
        coords = vector3(448.16, -1017.41, 28.56),
        spawnCoords = vector4(441.87, -1025.29, 28.56, 359.8),
        color = { r = 52, g = 152, b = 219 },
        prompt = "[E] Garaje Policial CNP"
    },
    helipad = {
        name = "Helipuerto Falcon CNP",
        coords = vector3(449.17, -981.33, 43.69),
        spawnCoords = vector4(449.17, -981.33, 43.69, 87.23),
        color = { r = 231, g = 76, b = 60 },
        prompt = "[E] Helipuerto Policial Falcon"
    }
}

-- Función para dibujar texto 3D en el mundo
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
        local factor = (string.len(text)) / 360
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 15, 20, 25, 170)
    end
end

-- Función para verificar si el jugador es policía de servicio
local function IsPoliceOnDuty()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData or not PlayerData.job then return false end
    return (PlayerData.job.type == 'leo' or PlayerData.job.name == 'police') and PlayerData.job.onduty
end

-- Bucle principal de Renderizado de Flechas Flotantes 3D
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)

        for key, pt in pairs(PolicePoints) do
            local dist = #(pCoords - pt.coords)
            if dist < 25.0 then
                sleep = 0
                -- Flecha Flotante Giratoria Superior (Tipo 2)
                DrawMarker(2, pt.coords.x, pt.coords.y, pt.coords.z + 0.35, 
                    0.0, 0.0, 0.0, 
                    0.0, 180.0, 0.0, 
                    0.40, 0.40, 0.35, 
                    pt.color.r, pt.color.g, pt.color.b, 210, 
                    false, true, 2, nil, nil, false
                )

                -- Cilindro Base en el Suelo (Tipo 25)
                DrawMarker(25, pt.coords.x, pt.coords.y, pt.coords.z - 0.95, 
                    0.0, 0.0, 0.0, 
                    0.0, 0.0, 0.0, 
                    1.2, 1.2, 0.8, 
                    pt.color.r, pt.color.g, pt.color.b, 100, 
                    false, false, 2, false, nil, nil, false
                )

                -- Interacción al estar dentro del rango
                if dist < 2.0 then
                    local promptText = pt.prompt
                    local inVeh = IsPedInAnyVehicle(playerPed, false)
                    if (key == 'garage' or key == 'helipad') and inVeh then
                        promptText = "~r~[E]~w~ Guardar Vehículo Oficial"
                    else
                        promptText = "~b~[E]~w~ " .. pt.name
                    end

                    DrawText3D(pt.coords.x, pt.coords.y, pt.coords.z + 0.85, promptText)

                    if IsControlJustPressed(0, 38) then -- Tecla E
                        if not IsPoliceOnDuty() then
                            QBCore.Functions.Notify("Acceso restringido: Debes ser agente de policía y estar de servicio.", "error")
                        else
                            TriggerEvent("spain_police:client:openPoint", key)
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- Enrutador de acciones según el punto interactuado
RegisterNetEvent("spain_police:client:openPoint", function(pointType)
    local playerPed = PlayerPedId()

    if pointType == 'armory' then
        OpenArmoryMenu()
    elseif pointType == 'evidence' then
        OpenEvidenceMenu()
    elseif pointType == 'fingerprint' then
        StartFingerprintScan()
    elseif pointType == 'garage' then
        if IsPedInAnyVehicle(playerPed, false) then
            StoreCurrentVehicle()
        else
            OpenGarageMenu()
        end
    elseif pointType == 'helipad' then
        if IsPedInAnyVehicle(playerPed, false) then
            StoreCurrentVehicle()
        else
            SpawnPoliceHelicopter()
        end
    end
end)

-- =========================================================================
-- 1. MENÚ DE ARMERÍA POLICIAL CNP
-- =========================================================================
function OpenArmoryMenu()
    local armoryMenu = {
        {
            header = "🛡️ Armería Central &bull; Policía Nacional",
            isMenuHeader = true,
        },
        {
            header = "🎒 Dotación Completa de Servicio",
            text = "Equipa Taser, Pistola 9mm, Linterna, Porra, Chaleco Pesado, Esposas y Munición",
            params = {
                event = "spain_police:client:giveArmoryItem",
                args = { type = 'full_kit' }
            }
        },
        {
            header = "⚡ Pistola Táser (No Letal)",
            text = "Arma eléctrica incapacitante para reducción no letal",
            params = {
                event = "spain_police:client:giveArmoryItem",
                args = { item = 'weapon_stungun', isWeapon = true }
            }
        },
        {
            header = "🔫 Pistola de Combate 9mm",
            text = "Arma corta reglamentaria CNP + 2 cargadores de 9mm",
            params = {
                event = "spain_police:client:giveArmoryItem",
                args = { item = 'weapon_combatpistol', ammo = 'pistol_ammo', isWeapon = true }
            }
        },
        {
            header = "🛡️ Chaleco Antibalas Pesado (UIP / CNP)",
            text = "Protección balística táctica reforzada de dotación",
            params = {
                event = "spain_police:client:giveArmoryItem",
                args = { item = 'heavyarmor', amount = 1 }
            }
        },
        {
            header = "🦯 Defensa / Porra Policial de Acero",
            text = "Defensa extensible reglamentaria",
            params = {
                event = "spain_police:client:giveArmoryItem",
                args = { item = 'weapon_nightstick', isWeapon = true }
            }
        },
        {
            header = "🔦 Linterna Táctica Policial",
            text = "Linterna de alta intensidad lumínica para intervenciones nocturnas",
            params = {
                event = "spain_police:client:giveArmoryItem",
                args = { item = 'weapon_flashlight', isWeapon = true }
            }
        },
        {
            header = "💥 Escopeta Policial Corredera (12G)",
            text = "Arma larga disuasoria + Cartuchos del calibre 12",
            params = {
                event = "spain_police:client:giveArmoryItem",
                args = { item = 'weapon_pumpshotgun', ammo = 'shotgun_ammo', isWeapon = true }
            }
        },
        {
            header = "🎯 Fusil de Asalto Carabina CNP",
            text = "Fusil táctico para situaciones de alto riesgo + Munición",
            params = {
                event = "spain_police:client:giveArmoryItem",
                args = { item = 'weapon_carbinerifle', ammo = 'rifle_ammo', isWeapon = true }
            }
        },
        {
            header = "🔗 Grilletes / Esposas de Detención",
            text = "Juego de esposas de acero con cerradura de seguridad",
            params = {
                event = "spain_police:client:giveArmoryItem",
                args = { item = 'handcuffs', amount = 2 }
            }
        },
        {
            header = "📡 Kit de Tráfico e Inspección",
            text = "Radar Láser, Alcoholímetro, Narcotest y Banda de Pinchos",
            params = {
                event = "spain_police:client:giveArmoryItem",
                args = { type = 'traffic_kit' }
            }
        },
        {
            header = "🩹 Botiquín Médico de Emergencias",
            text = "Kit de primeros auxilios y vendajes estériles",
            params = {
                event = "spain_police:client:giveArmoryItem",
                args = { item = 'firstaid', amount = 2 }
            }
        },
        {
            header = "📥 Devolver Armamento de Dotación",
            text = "Entrega tus armas policiales para guardarlas en el armero",
            params = {
                event = "spain_police:client:giveArmoryItem",
                args = { type = 'return_weapons' }
            }
        }
    }

    exports['qb-menu']:openMenu(armoryMenu)
end

RegisterNetEvent("spain_police:client:giveArmoryItem", function(data)
    TriggerServerEvent("spain_police:server:giveArmoryItem", data)
end)

-- =========================================================================
-- 2. DEPÓSITO JUDICIAL DE PRUEBAS (CON ENTRADA DE NÚMERO Y VACIADO)
-- =========================================================================
function OpenEvidenceMenu()
    local evidenceMenu = {
        {
            header = "📂 Depósito Judicial de Pruebas &bull; Mission Row",
            isMenuHeader = true,
        },
        {
            header = "🔍 Consultar / Depositar Pruebas del Caso",
            text = "Introduce el Nº de expediente o prueba para abrir el cajón judicial",
            params = {
                event = "spain_police:client:accessEvidenceStash"
            }
        },
        {
            header = "🗑️ Archivar y Eliminar Pruebas del Caso",
            text = "Limpia y borra el contenido del caso para liberar espacio y no saturar el servidor",
            params = {
                event = "spain_police:client:clearEvidenceStash"
            }
        }
    }

    exports['qb-menu']:openMenu(evidenceMenu)
end

-- Abrir depósito de pruebas por número de caso
RegisterNetEvent("spain_police:client:accessEvidenceStash", function()
    local dialog = exports['qb-input']:ShowInput({
        header = "Depósito Judicial de Pruebas",
        submitText = "Abrir Cajón",
        inputs = {
            {
                text = "Número de Caso / Prueba (Ej: 101, 204)",
                name = "case_id",
                type = "number",
                isRequired = true
            }
        }
    })

    if dialog and dialog.case_id then
        local stashId = "policeevidence_" .. tostring(dialog.case_id)
        TriggerServerEvent("spain_police:server:openEvidenceStash", stashId)
    end
end)

-- Limpiar / Eliminar depósito de pruebas para no saturar la base de datos
RegisterNetEvent("spain_police:client:clearEvidenceStash", function()
    local dialog = exports['qb-input']:ShowInput({
        header = "Archivar y Limpiar Pruebas del Caso",
        submitText = "Eliminar Pruebas",
        inputs = {
            {
                text = "Número de Caso a Eliminar (Ej: 101)",
                name = "case_id",
                type = "number",
                isRequired = true
            }
        }
    })

    if dialog and dialog.case_id then
        local stashId = "policeevidence_" .. tostring(dialog.case_id)
        TriggerServerEvent("spain_police:server:clearEvidenceStash", stashId, dialog.case_id)
    end
end)

-- =========================================================================
-- 3. ZONA DE HUELLAS DACTILARES Y FICHAJE (CON SALIDA COMPLETA AL CHAT)
-- =========================================================================
function StartFingerprintScan()
    local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
    local targetServerId = nil

    if closestPlayer ~= -1 and closestDistance < 2.5 then
        targetServerId = GetPlayerServerId(closestPlayer)
    else
        -- Si no hay nadie cerca, permite auto-ficharse para pruebas
        targetServerId = GetPlayerServerId(PlayerId())
    end

    QBCore.Functions.Progressbar("police_scan_fingerprint", "Escaneando huella en el lector biométrico policial...", 3500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mp_arresting",
        anim = "a_uncuff",
        flags = 49,
    }, {}, {}, function()
        TriggerServerEvent("spain_police:server:processFingerprintScan", targetServerId)
    end, function()
        QBCore.Functions.Notify("Escaneo biométrico cancelado.", "error")
    end)
end

-- =========================================================================
-- 4. GARAJE POLICIAL CNP (PATRULLAS Y GUARDADO)
-- =========================================================================
function OpenGarageMenu()
    local garageMenu = {
        {
            header = "🚓 Parque Móvil CNP &bull; Mission Row",
            isMenuHeader = true,
        },
        {
            header = "🚔 Vapid Stanier CNP",
            text = "Patrulla básica de seguridad ciudadana (Zeta)",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'police', label = 'Vapid Stanier CNP' }
            }
        },
        {
            header = "⚡ Bravado Buffalo STX CNP",
            text = "Unidad Interceptora de Tráfico de alta velocidad",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'police2', label = 'Buffalo STX Interceptor' }
            }
        },
        {
            header = "🐕 Vapid Torrence CNP",
            text = "Vehículo de patrulla y Unidad Canina (K-9)",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'police3', label = 'Vapid Torrence CNP' }
            }
        },
        {
            header = "🛡️ Declasse Granger 3600LX UIP",
            text = "Furgoneta blindada pesada de intervención policial",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'police4', label = 'Declasse Granger UIP' }
            }
        },
        {
            header = "🏍️ Moto Policial CNP",
            text = "Motocicleta ágil para intervenciones rápidas en el centro urbano",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'policeb', label = 'Moto Policial CNP' }
            }
        },
        {
            header = "🚐 Furgón de Traslado de Presos",
            text = "Unidad celular blindada para traslado de detenidos",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'policet', label = 'Furgón Celular CNP' }
            }
        },
        {
            header = "🕵️ Buffalo Desrotulado / Camuflado",
            text = "Vehículo policial camuflado para operaciones encubiertas",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'fbi', label = 'Patrulla Camuflada' }
            }
        }
    }

    exports['qb-menu']:openMenu(garageMenu)
end

RegisterNetEvent("spain_police:client:spawnPatrolVehicle", function(data)
    local spawn = PolicePoints.garage.spawnCoords
    local modelHash = GetHashKey(data.model)

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(50)
    end

    -- Comprobar si hay un vehículo bloqueando la zona de salida
    local closestVeh = GetClosestVehicle(spawn.x, spawn.y, spawn.z, 3.0, 0, 71)
    if closestVeh ~= 0 and DoesEntityExist(closestVeh) then
        DeleteEntity(closestVeh)
    end

    local veh = CreateVehicle(modelHash, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    SetVehicleOnGroundProperly(veh)
    SetEntityHeading(veh, spawn.w)
    SetVehicleNumberPlateText(veh, "CNP" .. tostring(math.random(1000, 9999)))

    -- Llenar combustible y entregar llaves
    if GetResourceState('LegacyFuel') == 'started' then
        exports['LegacyFuel']:SetFuel(veh, 100.0)
    elseif GetResourceState('qb-fuel') == 'started' then
        exports['qb-fuel']:SetFuel(veh, 100.0)
    end

    TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)

    QBCore.Functions.Notify("Has desplegado: " .. data.label .. ". Las llaves están puestas y el depósito lleno.", "success", 6000)
end)

-- =========================================================================
-- 5. HELIPUERTO POLICIAL FALCON (TERRAZA DE MISSION ROW)
-- =========================================================================
function SpawnPoliceHelicopter()
    local spawn = PolicePoints.helipad.spawnCoords
    local modelHash = `polmav`

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(50)
    end

    local closestHeli = GetClosestVehicle(spawn.x, spawn.y, spawn.z, 5.0, 0, 71)
    if closestHeli ~= 0 and DoesEntityExist(closestHeli) then
        DeleteEntity(closestHeli)
    end

    local heli = CreateVehicle(modelHash, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    SetVehicleOnGroundProperly(heli)
    SetEntityHeading(heli, spawn.w)
    SetVehicleNumberPlateText(heli, "FALCON" .. tostring(math.random(10, 99)))

    if GetResourceState('LegacyFuel') == 'started' then
        exports['LegacyFuel']:SetFuel(heli, 100.0)
    elseif GetResourceState('qb-fuel') == 'started' then
        exports['qb-fuel']:SetFuel(heli, 100.0)
    end

    TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(heli))
    TaskWarpPedIntoVehicle(PlayerPedId(), heli, -1)

    QBCore.Functions.Notify("Helicóptero Policial Falcon desplegado en la terraza. Llaves entregadas.", "success", 6000)
end

-- Función para guardar cualquier vehículo en garaje o helipuerto
function StoreCurrentVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh and veh ~= 0 then
        TaskLeaveVehicle(ped, veh, 0)
        Wait(1500)
        DeleteEntity(veh)
        QBCore.Functions.Notify("Vehículo oficial guardado e inspeccionado en las dependencias policiales.", "success")
    else
        QBCore.Functions.Notify("No estás dentro de ningún vehículo para guardar.", "error")
    end
end
