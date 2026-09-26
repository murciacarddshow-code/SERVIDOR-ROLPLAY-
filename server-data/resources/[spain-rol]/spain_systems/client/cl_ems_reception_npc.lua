-- =========================================================================
-- SPAIN ROL - NPC DE ATENCIÓN SANITARIA Y RECEPCIÓN PILLBOX HILL
-- =========================================================================
-- Localizado en el mostrador principal del Hospital Central de Pillbox Hill.
-- Permite a los ciudadanos pasar consulta, chequeo médico y expedir tarjeta sanitaria / DNI.

local QBCore = exports['qb-core']:GetCoreObject()
local emsNpcCoords = vector4(308.19, -595.35, 43.29, 18.0)
local emsNpcModel = `s_m_m_doctor_01`
local spawnedEmsNpc = nil
local lastInteraction = 0

-- Función para dibujar texto 3D en pantalla
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
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 20, 20, 20, 160)
    end
end

-- Spawn del NPC médico en el mostrador de recepción
CreateThread(function()
    RequestModel(emsNpcModel)
    while not HasModelLoaded(emsNpcModel) do
        Wait(50)
    end

    spawnedEmsNpc = CreatePed(4, emsNpcModel, emsNpcCoords.x, emsNpcCoords.y, emsNpcCoords.z - 1.0, emsNpcCoords.w, false, true)
    SetEntityHeading(spawnedEmsNpc, emsNpcCoords.w)
    FreezeEntityPosition(spawnedEmsNpc, true)
    SetEntityInvincible(spawnedEmsNpc, true)
    SetBlockingOfNonTemporaryEvents(spawnedEmsNpc, true)
    TaskStartScenarioInPlace(spawnedEmsNpc, "WORLD_HUMAN_CLIPBOARD", 0, true)

    -- Soporte para qb-target si está activo
    if GetResourceState('qb-target') == 'started' then
        exports['qb-target']:AddTargetEntity(spawnedEmsNpc, {
            options = {
                {
                    type = "client",
                    event = "spain_ems:client:openReceptionMenu",
                    icon = "fas fa-user-md",
                    label = "Atención al Paciente / Servicios Sanitarios",
                }
            },
            distance = 2.5
        })
    end
end)

-- Bucle de proximidad para interacción mediante [E]
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)
        local dist = #(pCoords - vector3(emsNpcCoords.x, emsNpcCoords.y, emsNpcCoords.z))

        if dist < 6.0 then
            sleep = 0
            if dist < 2.5 then
                DrawText3D(emsNpcCoords.x, emsNpcCoords.y, emsNpcCoords.z + 1.0, "~g~[E]~w~ Mostrador de Admisión y Triaje Hospitalario")
                if IsControlJustPressed(0, 38) then -- Tecla E
                    if (GetGameTimer() - lastInteraction) > 2000 then
                        lastInteraction = GetGameTimer()
                        TriggerEvent("spain_ems:client:openReceptionMenu")
                    end
                end
            else
                DrawText3D(emsNpcCoords.x, emsNpcCoords.y, emsNpcCoords.z + 1.0, "Recepción SAMUR &bull; Hospital Pillbox")
            end
        end

        Wait(sleep)
    end
end)

-- Menú interactivo de recepción médica
RegisterNetEvent("spain_ems:client:openReceptionMenu", function()
    local receptionMenu = {
        {
            header = "🏥 Recepción &bull; Hospital Central Pillbox Hill",
            isMenuHeader = true,
        },
        {
            header = "🩺 Chequeo Médico y Cura de Heridas (150€)",
            text = "Tratamiento de heridas leves, vendaje y administración de analgésicos",
            params = {
                event = "spain_ems:client:requestCheckin"
            }
        },
        {
            header = "🪪 Duplicado de Tarjeta Sanitaria / DNI (100€)",
            text = "Expedición oficial de tu documento de identidad y registro médico",
            params = {
                event = "spain_ems:client:requestHealthCard"
            }
        },
        {
            header = "🚨 Solicitar Ambulancia de Urgencia al 112",
            text = "Emite un aviso prioritario a todas las ambulancias de guardia",
            params = {
                event = "spain_ems:client:callEmergencyAmbulance"
            }
        }
    }

    exports['qb-menu']:openMenu(receptionMenu)
end)

-- Acción: Chequeo médico y curación
RegisterNetEvent("spain_ems:client:requestCheckin", function()
    QBCore.Functions.Progressbar("ems_checkin", "Examinando constantes vitales y tratando heridas...", 4000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@cpr@char_a@cpr_str",
        anim = "cpr_pumpchest",
        flags = 49,
    }, {}, {}, function()
        TriggerServerEvent("spain_ems:server:processCheckin")
    end, function()
        QBCore.Functions.Notify("Tratamiento cancelado.", "error")
    end)
end)

-- Acción: Solicitar tarjeta médica / DNI
RegisterNetEvent("spain_ems:client:requestHealthCard", function()
    QBCore.Functions.Progressbar("ems_card", "Emitiendo Tarjeta Sanitaria del Sistema Nacional...", 3000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mp_common",
        anim = "givetake2_a",
        flags = 49,
    }, {}, {}, function()
        TriggerServerEvent("spain_ems:server:reissueHealthCard")
    end, function()
        QBCore.Functions.Notify("Trámite cancelado.", "error")
    end)
end)

-- Acción: Alerta de urgencia a las ambulancias
RegisterNetEvent("spain_ems:client:callEmergencyAmbulance", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    TriggerServerEvent("hospital:server:ambulanceAlert", "Aviso urgente en la recepción de Pillbox Hill: Paciente requiere asistencia médica.")
    QBCore.Functions.Notify("Aviso de urgencia transmitido a la centralita del SAMUR 112.", "success", 6000)
end)

-- Limpieza al parar el recurso
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if spawnedEmsNpc and DoesEntityExist(spawnedEmsNpc) then
        DeleteEntity(spawnedEmsNpc)
    end
end)
