local QBCore = exports['qb-core']:GetCoreObject()
local tabletProp = nil
local isTabletOpen = false

-- Cargar diccionarios de animación
local function LoadAnim(dict)
    RequestAnimDict(dict)
    local timeout = 0
    while not HasAnimDictLoaded(dict) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
end

-- Abrir tablet con animación y prop
local function OpenTablet(data)
    if isTabletOpen then return end
    isTabletOpen = true

    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        LoadAnim('amb@world_human_seat_wall_tablet@female@base')
        TaskPlayAnim(ped, 'amb@world_human_seat_wall_tablet@female@base', 'base', 8.0, -8.0, -1, 50, 0, false, false, false)

        local model = `prop_cs_tablet`
        RequestModel(model)
        local timeout = 0
        while not HasModelLoaded(model) and timeout < 100 do
            Wait(10)
            timeout = timeout + 1
        end
        if HasModelLoaded(model) then
            tabletProp = CreateObject(model, 0.0, 0.0, 0.0, true, true, false)
            AttachEntityToEntity(tabletProp, ped, GetPedBoneIndex(ped, 28422), -0.05, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        end
    end

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
    if not IsPedInAnyVehicle(ped, false) then
        StopAnimTask(ped, 'amb@world_human_seat_wall_tablet@female@base', 'base', 1.5)
    end
    if tabletProp and DoesEntityExist(tabletProp) then
        DeleteEntity(tabletProp)
        tabletProp = nil
    end
end

-- Función para alternar (abrir/cerrar) la terminal MDT
local function TogglePoliceMDT()
    if isTabletOpen then
        CloseTablet()
        return
    end

    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData or not PlayerData.job then return end

    local jobName = PlayerData.job.name
    local isPolice = (jobName == 'police')
    local isEms = (jobName == 'ambulance')
    local isAdmin = false

    if QBCore.Functions.HasPermission and QBCore.Functions.HasPermission('admin') then
        isAdmin = true
    end

    if isPolice or isEms or isAdmin then
        local charinfo = PlayerData.charinfo or {}
        local name = (charinfo.firstname or 'Agente') .. ' ' .. (charinfo.lastname or '')
        local jobLabel = isEms and 'SAMUR' or 'CNP'
        local callsign = PlayerData.metadata and PlayerData.metadata.callsign or (isEms and 'SAMUR-01' or 'Z-10')

        OpenTablet({
            officerName = name,
            job = jobLabel,
            callsign = callsign
        })
    else
        QBCore.Functions.Notify('Acceso restringido: Solo agentes del CNP / SAMUR en servicio.', 'error', 3500)
    end
end

-- Comando y asignación de tecla F6 oficial
RegisterCommand('openpolicemdt', function()
    TogglePoliceMDT()
end, false)

RegisterKeyMapping('openpolicemdt', 'Abrir MDT Policial / Médico (F6)', 'keyboard', 'F6')

-- Comando /mdt alternativo
RegisterCommand('mdt', function()
    TogglePoliceMDT()
end, false)

RegisterNetEvent('spain_mdt:client:open', function(data)
    OpenTablet(data or {})
end)

RegisterNetEvent('spain_mdt:client:toggle', function()
    TogglePoliceMDT()
end)

RegisterNetEvent('spain_mdt:client:openCommand', function()
    TogglePoliceMDT()
end)

-- NUI Callbacks
RegisterNUICallback('close', function(_, cb)
    CloseTablet()
    cb('ok')
end)

RegisterNUICallback('searchCitizen', function(data, cb)
    QBCore.Functions.TriggerCallback('spain_mdt:server:searchCitizen', function(results)
        cb(results or {})
    end, data.query)
end)

RegisterNUICallback('searchVehicle', function(data, cb)
    QBCore.Functions.TriggerCallback('spain_mdt:server:searchVehicle', function(vehicle)
        cb(vehicle)
    end, data.plate)
end)

RegisterNUICallback('getPenalCode', function(_, cb)
    QBCore.Functions.TriggerCallback('spain_mdt:server:getPenalCode', function(code)
        cb(code or {})
    end)
end)

RegisterNUICallback('getWarrants', function(_, cb)
    QBCore.Functions.TriggerCallback('spain_mdt:server:getWarrants', function(warrants)
        cb(warrants or {})
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
