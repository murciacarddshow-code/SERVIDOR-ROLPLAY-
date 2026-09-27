-- =========================================================================
-- SPAIN ROL - MARCADORES 3D POLICIALES EN MISSION ROW (MLO & GARAJE)
-- =========================================================================
-- Incluye:
-- 1. Flecha Flotante en Armería (Taser, Pistola, Escopeta, Carabina, Chaleco, Esposas, etc.)
-- 2. Flecha Flotante en Depósito de Pruebas (Entrada de Nº Caso y Limpieza/Eliminación)
-- 3. Flecha Flotante en Fichaje / Huellas Dactilares (Con reporte detallado al chat)
-- 4. Flecha Flotante en Interior MLO de la Comisaría (Terminal de Despacho de Vehículos al Garaje)
-- 5. Flecha Flotante en Garaje Exterior de Patrullas (Spawneo con múltiples bahías)
-- 6. Flecha Flotante en Zona de Devolución/Aparcamiento (Guardado directo)
-- 7. Flecha Flotante en Terraza / Helipuerto (Spawneo y guardado de helicóptero Falcon)

local QBCore = exports['qb-core']:GetCoreObject()

-- Bahías de salida de vehículos del garaje policial (Mission Row)
local GarageBays = {
    vector4(441.87, -1025.29, 28.56, 359.8),
    vector4(438.42, -1025.71, 28.56, 359.8),
    vector4(445.31, -1025.01, 28.56, 359.8),
    vector4(452.40, -1024.50, 28.56, 359.8),
    vector4(434.60, -1014.20, 28.80, 270.0)
}

-- Coordenadas de los Puntos Policiales (Interior MLO y Exterior)
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
    mlo_garage = {
        name = "Terminal de Despacho de Flota (Interior Comisaría)",
        coords = vector3(441.25, -998.15, 30.69),
        color = { r = 0, g = 206, b = 201 },
        prompt = "[E] Terminal de Vehículos CNP"
    },
    garage = {
        name = "Garaje de Patrullas CNP (Exterior)",
        coords = vector3(448.16, -1017.41, 28.56),
        color = { r = 52, g = 152, b = 219 },
        prompt = "[E] Garaje Policial CNP"
    },
    garage_return = {
        name = "Zona de Devolución de Patrullas",
        coords = vector3(462.52, -1019.45, 28.10),
        color = { r = 230, g = 126, b = 34 },
        prompt = "[E] Devolver Patrulla CNP"
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

-- Función para verificar si el jugador es policía autorizado
local function IsPoliceAuthorized()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData or not PlayerData.job then return false end
    local isLeo = (PlayerData.job.type == 'leo' or PlayerData.job.name == 'police')
    local isAdmin = false
    if QBCore.Functions.HasPermission and QBCore.Functions.HasPermission('admin') then
        isAdmin = true
    end

    if isLeo or isAdmin then
        -- Si está fuera de servicio, poner en servicio automáticamente
        if not PlayerData.job.onduty then
            TriggerServerEvent('QBCore:ToggleDuty')
        end
        return true
    end
    return false
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
                if dist < 2.2 then
                    local promptText = pt.prompt
                    local inVeh = IsPedInAnyVehicle(playerPed, false)
                    if (key == 'garage' or key == 'mlo_garage' or key == 'garage_return' or key == 'helipad') and inVeh then
                        promptText = "~r~[E]~w~ Guardar Vehículo Oficial CNP"
                    else
                        promptText = "~b~[E]~w~ " .. pt.name
                    end

                    DrawText3D(pt.coords.x, pt.coords.y, pt.coords.z + 0.85, promptText)

                    if IsControlJustPressed(0, 38) then -- Tecla E
                        if not IsPoliceAuthorized() then
                            QBCore.Functions.Notify("Acceso restringido: Debes ser agente de policía del CNP.", "error", 4000)
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
    elseif pointType == 'garage' or pointType == 'mlo_garage' or pointType == 'garage_return' then
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
-- 4. GARAJE POLICIAL CNP (FLOTA COMPLETA CON BAHÍAS INTELIGENTES)
-- =========================================================================
function OpenGarageMenu()
    local garageMenu = {
        {
            header = "🚓 Parque Móvil CNP &bull; Flota Oficial Mission Row",
            isMenuHeader = true,
        },
        {
            header = "🚔 Vapid Stanier CNP (Zeta)",
            text = "Patrulla estándar de Seguridad Ciudadana &bull; Servicio 24 Horas",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'police', label = 'Vapid Stanier CNP' }
            }
        },
        {
            header = "⚡ Bravado Buffalo STX Interceptor",
            text = "Unidad Interceptora de Tráfico de Alta Velocidad &bull; Persecuciones",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'police2', label = 'Buffalo STX Interceptor' }
            }
        },
        {
            header = "🔥 Bravado Gauntlet Hellfire Interceptor",
            text = "Superdeportivo Especial de Intervención Rápida (Chop Shop DLC)",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'police5', fallback = 'police2', label = 'Gauntlet Hellfire Interceptor' }
            }
        },
        {
            header = "🐕 Vapid Torrence CNP (Unidad Canina K-9)",
            text = "Vehículo adaptado con compartimento especial para perros policía",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'police3', label = 'Vapid Torrence K-9' }
            }
        },
        {
            header = "🛡️ Declasse Granger 3600LX UIP",
            text = "Furgón táctico blindado de intervención pesada",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'police4', label = 'Declasse Granger UIP' }
            }
        },
        {
            header = "🚨 Furgón Blindado UIP Antidisturbios (Riot)",
            text = "Vehículo blindado de asalto y control de masas",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'riot', label = 'Furgón Blindado Riot UIP' }
            }
        },
        {
            header = "🚐 Furgón Celular de Detenidos",
            text = "Traslado penitenciario de reclusos hacia la prisión de Bolingbroke",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'policet', label = 'Furgón Celular CNP' }
            }
        },
        {
            header = "🏍️ Moto Policial Western CNP",
            text = "Motocicleta ágil para patrullaje urbano y escoltas de protocolo",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'policeb', label = 'Moto Policial CNP' }
            }
        },
        {
            header = "🌲 Declasse Park Ranger 4x4",
            text = "Patrulla todoterreno para persecuciones fuera de carretera / Seprona",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'pranger', label = 'Park Ranger 4x4 CNP' }
            }
        },
        {
            header = "🕵️ Buffalo Desrotulado (UCO / Paisano)",
            text = "Vehículo camuflado para agentes de paisano e información",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'fbi', label = 'Buffalo Desrotulado UCO' }
            }
        },
        {
            header = "🕶️ Declasse Granger Camuflado (UCO)",
            text = "SUV oscuro desrotulado para escoltas judiciales y operaciones secretas",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'fbi2', label = 'Granger Camuflado UCO' }
            }
        },
        {
            header = "🟢 Vapid Stanier Guardia Civil / Rural",
            text = "Patrulla de seguridad rural y comarcal",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'sheriff', label = 'Vapid Stanier Guardia Civil' }
            }
        },
        {
            header = "🟢 Declasse Granger Guardia Civil 4x4",
            text = "Vehículo rural reforzado para servicio en carretera y montaña",
            params = {
                event = "spain_police:client:spawnPatrolVehicle",
                args = { model = 'sheriff2', label = 'Granger Guardia Civil 4x4' }
            }
        }
    }

    exports['qb-menu']:openMenu(garageMenu)
end

RegisterNetEvent("spain_police:client:spawnPatrolVehicle", function(data)
    local targetModel = data.model
    local modelHash = GetHashKey(targetModel)

    if not IsModelInCdimage(modelHash) or not IsModelAVehicle(modelHash) then
        if data.fallback then
            targetModel = data.fallback
            modelHash = GetHashKey(targetModel)
        else
            QBCore.Functions.Notify("El modelo de vehículo (" .. tostring(data.model) .. ") no está disponible.", "error")
            return
        end
    end

    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    if not HasModelLoaded(modelHash) then
        QBCore.Functions.Notify("Error al cargar el vehículo policial.", "error")
        return
    end

    -- Buscar una bahía de salida libre entre las disponibles
    local chosenBay = GarageBays[1]
    for _, bay in ipairs(GarageBays) do
        local checkVeh = GetClosestVehicle(bay.x, bay.y, bay.z, 2.5, 0, 71)
        if checkVeh == 0 or not DoesEntityExist(checkVeh) then
            chosenBay = bay
            break
        end
    end

    -- Si la bahía elegida aún tiene un vehículo, lo despeja
    local blockingVeh = GetClosestVehicle(chosenBay.x, chosenBay.y, chosenBay.z, 2.5, 0, 71)
    if blockingVeh ~= 0 and DoesEntityExist(blockingVeh) then
        DeleteEntity(blockingVeh)
    end

    local veh = CreateVehicle(modelHash, chosenBay.x, chosenBay.y, chosenBay.z, chosenBay.w, true, false)
    SetVehicleOnGroundProperly(veh)
    SetEntityHeading(veh, chosenBay.w)
    SetVehicleNumberPlateText(veh, "CNP" .. tostring(math.random(1000, 9999)))

    -- Llenar combustible
    if GetResourceState('LegacyFuel') == 'started' then
        exports['LegacyFuel']:SetFuel(veh, 100.0)
    elseif GetResourceState('qb-fuel') == 'started' then
        exports['qb-fuel']:SetFuel(veh, 100.0)
    end
    SetVehicleFuelLevel(veh, 100.0)

    -- Entregar llaves y montar al agente
    TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
    SetVehicleEngineOn(veh, true, true, false)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)

    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    QBCore.Functions.Notify("Has retirado: " .. data.label .. ". Las llaves están puestas y el depósito lleno.", "success", 6000)
end)

-- =========================================================================
-- 5. HELIPUERTO POLICIAL FALCON (TERRAZA DE MISSION ROW)
-- =========================================================================
function SpawnPoliceHelicopter()
    local spawn = PolicePoints.helipad.spawnCoords
    local modelHash = `polmav`

    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
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
    SetVehicleFuelLevel(heli, 100.0)

    TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(heli))
    SetVehicleEngineOn(heli, true, true, false)
    TaskWarpPedIntoVehicle(PlayerPedId(), heli, -1)

    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    QBCore.Functions.Notify("Helicóptero Policial Falcon desplegado en la terraza. Llaves entregadas.", "success", 6000)
end

-- =========================================================================
-- 6. FUNCIÓN UNIVERSAL PARA GUARDAR VEHÍCULOS OFICIALES
-- =========================================================================
function StoreCurrentVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh and veh ~= 0 then
        TaskLeaveVehicle(ped, veh, 0)
        Wait(1500)
        SetEntityAsMissionEntity(veh, true, true)
        DeleteVehicle(veh)
        if DoesEntityExist(veh) then
            DeleteEntity(veh)
        end
        PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
        QBCore.Functions.Notify("Vehículo oficial guardado e inspeccionado en las dependencias policiales.", "success", 5000)
    else
        QBCore.Functions.Notify("No estás dentro de ningún vehículo para guardar.", "error")
    end
end
