local QBCore = exports['qb-core']:GetCoreObject()
local tabletProp = nil
local isTabletOpen = false

-- Función para cargar animaciones
local function LoadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

-- Abrir tablet con animación de prop
local function OpenTablet(data)
    if isTabletOpen then return end
    isTabletOpen = true

    local ped = PlayerPedId()
    LoadAnim('amb@world_human_seat_wall_tablet@female@base')
    TaskPlayAnim(ped, 'amb@world_human_seat_wall_tablet@female@base', 'base', 8.0, -8.0, -1, 50, 0, false, false, false)

    local model = `prop_cs_tablet`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    tabletProp = CreateObject(model, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(tabletProp, ped, GetPedBoneIndex(ped, 28422), -0.05, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        officer = data.officerName or 'Agente',
        job = data.job or 'CNP',
        callsign = data.callsign or '01'
    })
end

-- Cerrar tablet
local function CloseTablet()
    if not isTabletOpen then return end
    isTabletOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    local ped = PlayerPedId()
    ClearPedTasks(ped)
    if tabletProp and DoesEntityExist(tabletProp) then
        DeleteEntity(tabletProp)
        tabletProp = nil
    end
end

-- Comando /mdt y Asignación de Tecla (Default: F6)
RegisterCommand('mdt', function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData or not PlayerData.job then return end

    local jobName = PlayerData.job.name
    local jobType = PlayerData.job.type

    if jobType == 'leo' or jobName == 'police' or jobName == 'ambulance' then
        if isTabletOpen then
            CloseTablet()
        else
            OpenTablet({
                officerName = (PlayerData.charinfo.firstname or 'Agente') .. ' ' .. (PlayerData.charinfo.lastname or ''),
                job = PlayerData.job.label or 'Policía Nacional',
                callsign = PlayerData.metadata['callsign'] or '01'
            })
        end
    else
        QBCore.Functions.Notify("Acceso denegado: Terminal reservada a Fuerzas y Cuerpos de Seguridad.", "error")
    end
end, false)

RegisterKeyMapping('mdt', 'Policía: Abrir/Cerrar Tablet MDT', 'keyboard', 'F6')

-- =========================================================================
-- CONTROLES Y ASIGNACIONES DE TECLAS POLICIALES
-- =========================================================================
local function VerifyCop()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData or not PlayerData.job then return false end
    if (PlayerData.job.type == 'leo' or PlayerData.job.name == 'police') and PlayerData.job.onduty then
        return true
    end
    QBCore.Functions.Notify("Debes ser agente de policía y estar de servicio.", "error")
    return false
end

-- 1. Esposar / Desesposar
RegisterCommand('police_cuff', function()
    if VerifyCop() then TriggerEvent('police:client:CuffPlayer') end
end, false)
RegisterKeyMapping('police_cuff', 'Policía: Esposar / Desesposar', 'keyboard', '')

-- 2. Esposas Blandas
RegisterCommand('police_sc', function()
    if VerifyCop() then TriggerEvent('police:client:CuffPlayerSoft') end
end, false)
RegisterKeyMapping('police_sc', 'Policía: Esposas Blandas', 'keyboard', '')

-- 3. Escoltar Sospechoso
RegisterCommand('police_escort', function()
    if VerifyCop() then TriggerEvent('police:client:EscortPlayer') end
end, false)
RegisterKeyMapping('police_escort', 'Policía: Escoltar / Soltar', 'keyboard', '')

-- 4. Registrar / Cachear
RegisterCommand('police_search', function()
    if VerifyCop() then TriggerEvent('police:client:RobPlayer') end
end, false)
RegisterKeyMapping('police_search', 'Policía: Registrar / Cachear', 'keyboard', '')

-- 5. Meter en Vehículo Policial
RegisterCommand('police_putinveh', function()
    if VerifyCop() then TriggerEvent('police:client:PutPlayerInVehicle') end
end, false)
RegisterKeyMapping('police_putinveh', 'Policía: Meter en Patrulla', 'keyboard', '')

-- 6. Sacar de Vehículo Policial
RegisterCommand('police_takeoutveh', function()
    if VerifyCop() then TriggerEvent('police:client:SetPlayerOutVehicle') end
end, false)
RegisterKeyMapping('police_takeoutveh', 'Policía: Sacar de Patrulla', 'keyboard', '')

-- 7. Radar Láser de Velocidad
RegisterCommand('police_radar', function()
    if VerifyCop() then TriggerEvent('spain_police:client:useRadar') end
end, false)
RegisterKeyMapping('police_radar', 'Policía: Radar Láser de Velocidad', 'keyboard', '')

-- 8. Alcoholímetro Digital
RegisterCommand('police_breath', function()
    if VerifyCop() then TriggerEvent('spain_police:client:useBreathalyzer') end
end, false)
RegisterKeyMapping('police_breath', 'Policía: Alcoholímetro Digital', 'keyboard', '')

-- 9. Narcotest de Drogas
RegisterCommand('police_narco', function()
    if VerifyCop() then TriggerEvent('spain_police:client:useNarcotest') end
end, false)
RegisterKeyMapping('police_narco', 'Policía: Narcotest de Drogas', 'keyboard', '')

-- 10. Desplegar Banda de Pinchos
RegisterCommand('police_spikes', function()
    if VerifyCop() then TriggerEvent('spain_police:client:deploySpikes') end
end, false)
RegisterKeyMapping('police_spikes', 'Policía: Banda de Pinchos', 'keyboard', '')

-- 11. Botón de Pánico 112
RegisterCommand('police_panic', function()
    if VerifyCop() then
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        TriggerServerEvent('police:server:policeAlert', '🚨 ¡BOTÓN DE PÁNICO ACTIVADO! Agente en peligro requiere refuerzos urgentes.')
        QBCore.Functions.Notify("¡Botón de pánico emitido a todas las patrullas en servicio!", "error", 8000)
    end
end, false)
RegisterKeyMapping('police_panic', 'Policía: Botón de Pánico 112', 'keyboard', '')

RegisterNetEvent('spain_mdt:client:open', function(data)
    OpenTablet(data)
end)

RegisterNetEvent('spain_mdt:client:openCommand', function()
    ExecuteCommand('mdt')
end)

-- NUI Callbacks
RegisterNUICallback('close', function(_, cb)
    CloseTablet()
    cb('ok')
end)

RegisterNUICallback('searchCitizen', function(data, cb)
    QBCore.Functions.TriggerCallback('spain_mdt:server:searchCitizen', function(results)
        cb(results)
    end, data.query)
end)

RegisterNUICallback('searchVehicle', function(data, cb)
    QBCore.Functions.TriggerCallback('spain_mdt:server:searchVehicle', function(vehicle)
        cb(vehicle)
    end, data.plate)
end)

RegisterNUICallback('getPenalCode', function(_, cb)
    QBCore.Functions.TriggerCallback('spain_mdt:server:getPenalCode', function(code)
        cb(code)
    end)
end)

RegisterNUICallback('getWarrants', function(_, cb)
    QBCore.Functions.TriggerCallback('spain_mdt:server:getWarrants', function(warrants)
        cb(warrants)
    end)
end)

RegisterNUICallback('issueFine', function(data, cb)
    TriggerServerEvent('spain_mdt:server:issueFine', data)
    cb('ok')
end)

RegisterNUICallback('createWarrant', function(data, cb)
    TriggerServerEvent('spain_mdt:server:createWarrant', data)
    cb('ok')
end)

RegisterNUICallback('triggerAction', function(data, cb)
    local action = data.action
    if action and action ~= '' then
        ExecuteCommand(action)
    end
    cb('ok')
end)
