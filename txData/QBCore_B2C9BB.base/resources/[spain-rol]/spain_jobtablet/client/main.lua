local QBCore = exports['qb-core']:GetCoreObject()
local tabletProp = nil
local isTabletOpen = false

local function LoadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

-- Abrir Tablet de Trabajo
local function OpenJobTablet()
    if isTabletOpen then return end
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData or not PlayerData.job then return end

    local jobName = PlayerData.job.name
    local jobData = Config.JobsData[jobName] or {
        name = jobName,
        title = PlayerData.job.label or 'TERMINAL LABORAL',
        subtitle = 'Gremio de Trabajadores de Los Santos',
        icon = 'fa-briefcase',
        color = '#00cec9',
        gradient = 'linear-gradient(135deg, #0984e3, #00cec9)',
        vehicle = 'Vehículo de Empresa Autorizado',
        rate = 'Convenio Colectivo Oficial',
        hq = 'Sede Central de Los Santos',
        coords = vector3(230.0, -400.0, 45.0)
    }

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

    local charinfo = PlayerData.charinfo or {}
    local workerName = (charinfo.firstname or 'Empleado') .. ' ' .. (charinfo.lastname or '')
    local gradeName = PlayerData.job.grade and PlayerData.job.grade.name or 'Oficial'
    local salary = PlayerData.job.payment or 75
    local onDuty = PlayerData.job.onduty or false

    SendNUIMessage({
        action = 'open',
        worker = {
            name = workerName,
            jobLabel = PlayerData.job.label,
            jobName = jobName,
            grade = gradeName,
            salary = salary,
            onDuty = onDuty,
            citizenid = PlayerData.citizenid
        },
        corp = jobData
    })
end

-- Cerrar Tablet de Trabajo
local function CloseJobTablet()
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

-- Comandos para abrir la tablet de trabajo
RegisterCommand('tablettrabajo', function()
    OpenJobTablet()
end, false)

RegisterCommand('jobtablet', function()
    OpenJobTablet()
end, false)

RegisterNetEvent('spain_jobtablet:client:open', function()
    OpenJobTablet()
end)

-- NUI Callbacks
RegisterNUICallback('close', function(_, cb)
    CloseJobTablet()
    cb('ok')
end)

RegisterNUICallback('toggleDuty', function(_, cb)
    TriggerServerEvent('QBCore:ToggleDuty')
    Wait(200)
    local PlayerData = QBCore.Functions.GetPlayerData()
    cb({ onDuty = PlayerData.job.onduty })
end)

RegisterNUICallback('setGpsWaypoint', function(data, cb)
    if data and data.jobName and Config.JobsData[data.jobName] then
        local coords = Config.JobsData[data.jobName].coords
        SetNewWaypoint(coords.x, coords.y)
        QBCore.Functions.Notify('Destino fijado en tu GPS: Sede de ' .. Config.JobsData[data.jobName].title, 'success')
    end
    cb('ok')
end)

RegisterNUICallback('getColleagues', function(data, cb)
    QBCore.Functions.TriggerCallback('spain_jobtablet:server:getColleagues', function(colleagues)
        cb(colleagues or {})
    end, data.jobName)
end)
