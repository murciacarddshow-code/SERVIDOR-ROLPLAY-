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
        officer = data.officerName or 'Agente CNP',
        job = data.job or 'CNP',
        callsign = data.callsign or 'Z-10'
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

RegisterNetEvent('spain_mdt:client:open', function(data)
    OpenTablet(data)
end)

RegisterNetEvent('spain_mdt:client:openCommand', function()
    ExecuteCommand('mdt')
end)

-- Comando rápido para abrir la tablet MDT
RegisterCommand('mdt', function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local allowedJobs = { ['police'] = true, ['ambulance'] = true }
    if allowedJobs[PlayerData.job.name] or QBCore.Functions.HasPermission('admin') then
        local charinfo = PlayerData.charinfo or {}
        local name = (charinfo.firstname or 'Agente') .. ' ' .. (charinfo.lastname or '')
        local jobLabel = PlayerData.job.name == 'ambulance' and 'SAMUR' or 'CNP'
        OpenTablet({
            officerName = name,
            job = jobLabel,
            callsign = PlayerData.metadata and PlayerData.metadata.callsign or 'Z-10'
        })
    else
        QBCore.Functions.Notify('No tienes autorización para acceder a la terminal policial/médica.', 'error')
    end
end, false)

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

RegisterNUICallback('executeCommand', function(data, cb)
    if data and data.command then
        ExecuteCommand(data.command)
    end
    cb('ok')
end)

RegisterNUICallback('panicAlert', function(data, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    TriggerServerEvent('spain_mdt:server:panicAlert', coords)
    QBCore.Functions.Notify('¡BOTÓN DE PÁNICO ACTIVADO! Transmitiendo posición GPS urgente a todas las unidades.', 'error', 8000)
    cb('ok')
end)
