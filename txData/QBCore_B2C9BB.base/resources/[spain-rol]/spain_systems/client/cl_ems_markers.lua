-- =========================================================================
-- SPAIN ROL - MARCADORES 3D SANITARIOS EN HOSPITAL PILLBOX HILL
-- =========================================================================
-- Incluye:
-- 1. Flecha Flotante en Farmacia Médica (Botiquines, Vendajes, Calmantes, Ifaks, etc.)
-- 2. Flecha Flotante en Depósito de Muestras Clínicas (Con Nº de Caso y Borrado para no saturar)
-- 3. Flecha Flotante en Monitor Biométrico de Constantes (Con ficha médica enviada al chat)
-- 4. Flecha Flotante en Garaje Exterior de Ambulancias (Spawneo y guardado)
-- 5. Flecha Flotante en Helipuerto de la Azotea (Spawneo y guardado de helicóptero médico)

local QBCore = exports['qb-core']:GetCoreObject()

-- Coordenadas de los Puntos Sanitarios del Hospital
local EMSPoints = {
    pharmacy = {
        name = "Farmacia y Suministros SAMUR",
        coords = vector3(309.78, -596.6, 43.29),
        color = { r = 0, g = 206, b = 201 },
        prompt = "[E] Farmacia y Material Sanitario"
    },
    samples = {
        name = "Depósito Clínico y Muestras Forenses",
        coords = vector3(312.43, -592.51, 43.29),
        color = { r = 241, g = 196, b = 15 },
        prompt = "[E] Depósito Clínico de Muestras"
    },
    biometric = {
        name = "Monitor Biométrico de Constantes",
        coords = vector3(317.0, -585.0, 43.29),
        color = { r = 46, g = 204, b = 113 },
        prompt = "[E] Monitorizar Constantes Vitales"
    },
    garage = {
        name = "Garaje de Ambulancias SAMUR",
        coords = vector3(294.58, -574.76, 43.18),
        spawnCoords = vector4(294.58, -574.76, 43.18, 35.79),
        color = { r = 52, g = 152, b = 219 },
        prompt = "[E] Garaje de Ambulancias SAMUR"
    },
    helipad = {
        name = "Helipuerto Sanitario SAMUR",
        coords = vector3(351.58, -587.45, 74.16),
        spawnCoords = vector4(351.58, -587.45, 74.16, 160.5),
        color = { r = 231, g = 76, b = 60 },
        prompt = "[E] Helipuerto Sanitario SAMUR"
    }
}

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
        local factor = (string.len(text)) / 360
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 15, 20, 25, 170)
    end
end

-- Función para comprobar si es personal sanitario de servicio
local function IsEMSOnDuty()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData or not PlayerData.job then return false end
    return (PlayerData.job.name == 'ambulance') and PlayerData.job.onduty
end

-- Bucle principal de Renderizado de Flechas Flotantes 3D
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)

        for key, pt in pairs(EMSPoints) do
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
                        promptText = "~r~[E]~w~ Guardar Vehículo Sanitario"
                    else
                        promptText = "~g~[E]~w~ " .. pt.name
                    end

                    DrawText3D(pt.coords.x, pt.coords.y, pt.coords.z + 0.85, promptText)

                    if IsControlJustPressed(0, 38) then -- Tecla E
                        if not IsEMSOnDuty() then
                            QBCore.Functions.Notify("Acceso restringido: Debes ser facultativo del SAMUR y estar de servicio.", "error")
                        else
                            TriggerEvent("spain_ems:client:openPoint", key)
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- Enrutador de acciones
RegisterNetEvent("spain_ems:client:openPoint", function(pointType)
    local playerPed = PlayerPedId()

    if pointType == 'pharmacy' then
        OpenPharmacyMenu()
    elseif pointType == 'samples' then
        OpenSamplesMenu()
    elseif pointType == 'biometric' then
        StartBiometricScan()
    elseif pointType == 'garage' then
        if IsPedInAnyVehicle(playerPed, false) then
            StoreCurrentEMSVehicle()
        else
            OpenAmbulanceGarageMenu()
        end
    elseif pointType == 'helipad' then
        if IsPedInAnyVehicle(playerPed, false) then
            StoreCurrentEMSVehicle()
        else
            SpawnEMSHelicopter()
        end
    end
end)

-- =========================================================================
-- 1. MENÚ DE FARMACIA Y SUMINISTROS MÉDICOS SAMUR
-- =========================================================================
function OpenPharmacyMenu()
    local pharmacyMenu = {
        {
            header = "💊 Farmacia Central &bull; SAMUR Pillbox",
            isMenuHeader = true,
        },
        {
            header = "🎒 Dotación Sanitaria Completa",
            text = "Retira Botiquines x3, Vendajes x5, Analgésicos x3 e IFAKs x2",
            params = {
                event = "spain_ems:client:givePharmacyItem",
                args = { type = 'full_kit' }
            }
        },
        {
            header = "🩺 Botiquín Médico de Primeros Auxilios",
            text = "Kit completo para estabilización y RCP avanzada",
            params = {
                event = "spain_ems:client:givePharmacyItem",
                args = { item = 'firstaid', amount = 2 }
            }
        },
        {
            header = "🩹 Vendajes Estériles",
            text = "Pack de vendajes para contener hemorragias y fijar fracturas",
            params = {
                event = "spain_ems:client:givePharmacyItem",
                args = { item = 'bandage', amount = 5 }
            }
        },
        {
            header = "💊 Analgésicos y Calmantes",
            text = "Analgésicos potentes para mitigar dolor intenso",
            params = {
                event = "spain_ems:client:givePharmacyItem",
                args = { item = 'painkillers', amount = 3 }
            }
        },
        {
            header = "💉 IFAKs / Torniquetes Tácticos",
            text = "Kits individuales de traumatología de urgencia",
            params = {
                event = "spain_ems:client:givePharmacyItem",
                args = { item = 'ifaks', amount = 2 }
            }
        },
        {
            header = "🛏️ Desplegar / Retirar Camilla de Emergencias",
            text = "Coloca una camilla en el suelo para tender a un paciente grave",
            params = {
                event = "spain_ems:client:toggleStretcher"
            }
        },
        {
            header = "📥 Devolver Suministros Médicos Sobrantes",
            text = "Deposita los materiales sobrantes en el almacén de farmacia",
            params = {
                event = "spain_ems:client:givePharmacyItem",
                args = { type = 'return_supplies' }
            }
        }
    }

    exports['qb-menu']:openMenu(pharmacyMenu)
end

RegisterNetEvent("spain_ems:client:givePharmacyItem", function(data)
    TriggerServerEvent("spain_ems:server:givePharmacyItem", data)
end)

RegisterNetEvent("spain_ems:client:toggleStretcher", function()
    ExecuteCommand('camilla')
end)

-- =========================================================================
-- 2. DEPÓSITO CLÍNICO DE MUESTRAS (CON ENTRADA DE NÚMERO Y VACIADO)
-- =========================================================================
function OpenSamplesMenu()
    local samplesMenu = {
        {
            header = "🧪 Depósito de Muestras Clínicas &bull; Laboratorio",
            isMenuHeader = true,
        },
        {
            header = "🔍 Consultar / Depositar Muestras del Expediente",
            text = "Introduce el Nº de expediente o historial para abrir el depósito refrigerado",
            params = {
                event = "spain_ems:client:accessSampleStash"
            }
        },
        {
            header = "🗑️ Archivar y Eliminar Muestras del Expediente",
            text = "Limpia y purga las muestras para no saturar el servidor ni la base de datos",
            params = {
                event = "spain_ems:client:clearSampleStash"
            }
        }
    }

    exports['qb-menu']:openMenu(samplesMenu)
end

RegisterNetEvent("spain_ems:client:accessSampleStash", function()
    local dialog = exports['qb-input']:ShowInput({
        header = "Depósito Clínico de Muestras",
        submitText = "Abrir Depósito",
        inputs = {
            {
                text = "Número de Expediente Clínico (Ej: 101, 204)",
                name = "case_id",
                type = "number",
                isRequired = true
            }
        }
    })

    if dialog and dialog.case_id then
        local stashId = "emsevidence_" .. tostring(dialog.case_id)
        TriggerServerEvent("spain_ems:server:openSampleStash", stashId)
    end
end)

RegisterNetEvent("spain_ems:client:clearSampleStash", function()
    local dialog = exports['qb-input']:ShowInput({
        header = "Archivar y Limpiar Muestras del Expediente",
        submitText = "Eliminar Muestras",
        inputs = {
            {
                text = "Número de Expediente a Limpiar (Ej: 101)",
                name = "case_id",
                type = "number",
                isRequired = true
            }
        }
    })

    if dialog and dialog.case_id then
        local stashId = "emsevidence_" .. tostring(dialog.case_id)
        TriggerServerEvent("spain_ems:server:clearSampleStash", stashId, dialog.case_id)
    end
end)

-- =========================================================================
-- 3. MONITOR BIOMÉTRICO DE CONSTANTES VITALES (CON SALIDA AL CHAT)
-- =========================================================================
function StartBiometricScan()
    local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
    local targetServerId = nil

    if closestPlayer ~= -1 and closestDistance < 3.0 then
        targetServerId = GetPlayerServerId(closestPlayer)
    else
        targetServerId = GetPlayerServerId(PlayerId())
    end

    QBCore.Functions.Progressbar("ems_scan_vitals", "Monitorizando ritmo cardíaco y constantes biométricas...", 3500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@cpr@char_a@cpr_str",
        anim = "cpr_pumpchest",
        flags = 49,
    }, {}, {}, function()
        TriggerServerEvent("spain_ems:server:processBiometricScan", targetServerId)
    end, function()
        QBCore.Functions.Notify("Escaneo biométrico cancelado.", "error")
    end)
end

-- =========================================================================
-- 4. GARAJE DE AMBULANCIAS Y VEHÍCULOS DE INTERVENCIÓN RÁPIDA
-- =========================================================================
function OpenAmbulanceGarageMenu()
    local garageMenu = {
        {
            header = "🚑 Parque Móvil &bull; SAMUR Pillbox Hill",
            isMenuHeader = true,
        },
        {
            header = "🚨 Ambulancia Soporte Vital Básico",
            text = "Unidad asistencial medicalizada estándar para traslados",
            params = {
                event = "spain_ems:client:spawnAmbulance",
                args = { model = 'ambulance', label = 'Ambulancia SAMUR SVB' }
            }
        },
        {
            header = "⚡ UVI Móvil de Cuidados Intensivos",
            text = "Unidad de soporte vital avanzado para emergencias críticas",
            params = {
                event = "spain_ems:client:spawnAmbulance",
                args = { model = 'ambulance', label = 'UVI Móvil de Críticos' }
            }
        }
    }

    exports['qb-menu']:openMenu(garageMenu)
end

RegisterNetEvent("spain_ems:client:spawnAmbulance", function(data)
    local spawn = EMSPoints.garage.spawnCoords
    local modelHash = GetHashKey(data.model)

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(50)
    end

    local closestVeh = GetClosestVehicle(spawn.x, spawn.y, spawn.z, 3.5, 0, 71)
    if closestVeh ~= 0 and DoesEntityExist(closestVeh) then
        DeleteEntity(closestVeh)
    end

    local veh = CreateVehicle(modelHash, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    SetVehicleOnGroundProperly(veh)
    SetEntityHeading(veh, spawn.w)
    SetVehicleNumberPlateText(veh, "SAMUR" .. tostring(math.random(100, 999)))

    if GetResourceState('LegacyFuel') == 'started' then
        exports['LegacyFuel']:SetFuel(veh, 100.0)
    elseif GetResourceState('qb-fuel') == 'started' then
        exports['qb-fuel']:SetFuel(veh, 100.0)
    end

    TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)

    QBCore.Functions.Notify("Has desplegado: " .. data.label .. ". Depósito lleno y llaves entregadas.", "success", 6000)
end)

-- =========================================================================
-- 5. HELIPUERTO SANITARIO SAMUR (AZOTEA DE PILLBOX)
-- =========================================================================
function SpawnEMSHelicopter()
    local spawn = EMSPoints.helipad.spawnCoords
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
    SetVehicleNumberPlateText(heli, "MEDEVAC" .. tostring(math.random(10, 99)))

    -- Pintura blanca/roja médica
    SetVehicleCustomPrimaryColour(heli, 255, 255, 255)
    SetVehicleCustomSecondaryColour(heli, 200, 0, 0)

    if GetResourceState('LegacyFuel') == 'started' then
        exports['LegacyFuel']:SetFuel(heli, 100.0)
    elseif GetResourceState('qb-fuel') == 'started' then
        exports['qb-fuel']:SetFuel(heli, 100.0)
    end

    TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(heli))
    TaskWarpPedIntoVehicle(PlayerPedId(), heli, -1)

    QBCore.Functions.Notify("Helicóptero Medical Falcon SAMUR desplegado en la azotea.", "success", 6000)
end

-- Guardar cualquier vehículo sanitario
function StoreCurrentEMSVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh and veh ~= 0 then
        TaskLeaveVehicle(ped, veh, 0)
        Wait(1500)
        DeleteEntity(veh)
        QBCore.Functions.Notify("Vehículo sanitario desinfectado y guardado en la cochera del hospital.", "success")
    else
        QBCore.Functions.Notify("No estás dentro de ningún vehículo para guardar.", "error")
    end
end
