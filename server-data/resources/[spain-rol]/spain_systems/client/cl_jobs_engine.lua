-- =========================================================================
-- SPAIN ROL - MOTOR CLIENTE DE TRABAJOS DINÁMICOS
-- =========================================================================
-- Gestiona las sedes de los trabajos, NPCs capataces, turnos de servicio,
-- asignación de vehículos con llaves automáticas, tablet NUI moderna,
-- bucle continuo de misiones con rutas GPS activas, minijuegos y horas extras.

local QBCore = exports['qb-core']:GetCoreObject()
local spawnedBosses = {}
local stationBlips = {}
local currentWorkVehicle = nil
local activeJobKey = nil
local isOnDuty = false
local currentTask = nil
local currentTaskBlip = nil
local isDoingTask = false
local isSpawningVehicle = false

-- Función auxiliar para texto 3D
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

-- Limpieza de blip de tarea activa
local function ClearTaskBlip()
    if currentTaskBlip and DoesBlipExist(currentTaskBlip) then
        RemoveBlip(currentTaskBlip)
        currentTaskBlip = nil
    end
end

-- Generación y asignación de la siguiente tarea con ruta GPS inmediata
local function AssignNextTask()
    if not isOnDuty or not activeJobKey then return end
    local station = JobsConfig.Stations[activeJobKey]
    if not station or not station.tasks or #station.tasks == 0 then return end

    ClearTaskBlip()

    -- Elegir una tarea aleatoria de la lista
    local randomIndex = math.random(1, #station.tasks)
    local nextTask = station.tasks[randomIndex]
    currentTask = {
        index = randomIndex,
        data = nextTask
    }

    -- Marcar Blip y ruta en el mapa
    currentTaskBlip = AddBlipForCoord(nextTask.coords.x, nextTask.coords.y, nextTask.coords.z)
    SetBlipSprite(currentTaskBlip, 1)
    SetBlipColour(currentTaskBlip, 5) -- Amarillo de objetivo
    SetBlipScale(currentTaskBlip, 0.9)
    SetBlipRoute(currentTaskBlip, true)
    SetBlipRouteColour(currentTaskBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("📍 Parada Laboral: " .. nextTask.label)
    EndTextCommandSetBlipName(currentTaskBlip)

    -- Fijar el Waypoint nativo de GTA V para que la línea del GPS aparezca en el minimap del vehículo
    SetNewWaypoint(nextTask.coords.x, nextTask.coords.y)

    PlaySoundFrontend(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", 1)
    TriggerEvent('QBCore:Notify', "📍 RUTA ASIGNADA: " .. nextTask.label .. ". Sigue la línea del GPS en tu radar.", "primary", 7000)
end

-- Aparición segura del vehículo de empresa (Anti-Duplicado y Llaves Automáticas)
local function SpawnCompanyVehicle(station)
    if not station.vehicle or not station.vehicle.model then return end
    if isSpawningVehicle then return end
    isSpawningVehicle = true

    -- 1. Eliminar vehículo anterior del empleado si aún existe
    if currentWorkVehicle and DoesEntityExist(currentWorkVehicle) then
        local oldNet = NetworkGetNetworkIdFromEntity(currentWorkVehicle)
        TriggerServerEvent('spain_jobs:server:deleteWorkVehicle', oldNet)
        SetEntityAsMissionEntity(currentWorkVehicle, true, true)
        DeleteVehicle(currentWorkVehicle)
        currentWorkVehicle = nil
    end

    local spawnCoords = station.vehicle.spawn

    -- 2. Limpieza preventiva del punto de spawn para evitar que se solapen vehículos existentes
    local existingVeh = GetClosestVehicle(spawnCoords.x, spawnCoords.y, spawnCoords.z, 3.5, 0, 70)
    if existingVeh ~= 0 and DoesEntityExist(existingVeh) then
        SetEntityAsMissionEntity(existingVeh, true, true)
        DeleteVehicle(existingVeh)
    end

    -- 3. Carga del modelo
    local modelHash = joaat(station.vehicle.model)
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    if HasModelLoaded(modelHash) then
        local veh = CreateVehicle(modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, true, false)
        SetVehicleOnGroundProperly(veh)
        local plate = "EMP" .. tostring(math.random(1000, 9999))
        SetVehicleNumberPlateText(veh, plate)
        local cleanPlate = QBCore.Functions.GetPlate(veh) or plate

        -- Desbloqueo total de puertas e inmovilizador desactivado
        SetVehicleDoorsLocked(veh, 1) -- 1 = Unlocked
        SetVehicleDoorsLockedForAllPlayers(veh, false)
        SetVehicleNeedsToBeHotwired(veh, false)

        -- Entrega de llaves nativas (Cliente y Servidor directo)
        local netId = NetworkGetNetworkIdFromEntity(veh)
        TriggerEvent("qb-vehiclekeys:client:AddKeys", cleanPlate)
        TriggerEvent("vehiclekeys:client:SetOwner", cleanPlate)
        TriggerServerEvent('spain_jobs:server:giveWorkVehicleKeys', netId, cleanPlate)
        TriggerServerEvent('spain_jobs:server:giveWorkKeys', cleanPlate)

        -- Subir al trabajador directamente al asiento del conductor
        local ped = PlayerPedId()
        TaskWarpPedIntoVehicle(ped, veh, -1)

        Wait(150)
        SetVehicleEngineOn(veh, true, true, false)
        SetModelAsNoLongerNeeded(modelHash)

        currentWorkVehicle = veh
        isSpawningVehicle = false

        TriggerEvent('QBCore:Notify', "Tu vehículo de empresa ha sido preparado. Tienes las llaves entregadas y el motor en marcha.", "success", 7000)
    else
        isSpawningVehicle = false
        TriggerEvent('QBCore:Notify', "Error al cargar el vehículo de empresa.", "error")
    end
end

-- Menú con el Capataz en la Sede Laboral (Apertura de la Tablet NUI)
local function OpenBossMenu(stationKey)
    local station = JobsConfig.Stations[stationKey]
    if not station then return end

    local PlayerData = QBCore.Functions.GetPlayerData()
    local playerJob = (PlayerData.job and PlayerData.job.name) or 'unemployed'

    if playerJob ~= station.job then
        TriggerEvent('QBCore:Notify', "ℹ️ Hola ciudadano. Esta es la sede oficial de <strong>" .. station.name .. "</strong>.<br>Para incorporarte a nuestra plantilla, firma tu contrato primero en la <strong>Oficina de Empleo</strong>.", "primary", 8000)
        return
    end

    QBCore.Functions.TriggerCallback('spain_jobs:server:getJobDashboardData', function(workerData)
        if not workerData then
            TriggerEvent('QBCore:Notify', "No se ha podido conectar con el terminal laboral.", "error")
            return
        end

        workerData.currentTaskIndex = currentTask and currentTask.index or 0
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openJobTablet',
            stationKey = stationKey,
            station = station,
            worker = workerData
        })
    end, stationKey)
end

-- Eventos de Gestión de Turno
RegisterNetEvent('spain_jobs:client:startShift', function(data)
    local stationKey = data.stationKey
    local station = JobsConfig.Stations[stationKey]
    if not station then return end

    if isOnDuty then
        TriggerEvent('QBCore:Notify', "Ya te encuentras de servicio activo.", "primary")
        return
    end

    activeJobKey = stationKey
    isOnDuty = true

    -- Notificar al servidor que entra de servicio
    TriggerServerEvent('spain_jobs:server:setDuty', true, stationKey)

    -- Entregar vehículo de empresa si procede
    SpawnCompanyVehicle(station)

    TriggerEvent('QBCore:Notify', "¡Has iniciado tu turno de trabajo en " .. station.name .. "! Buen servicio.", "success", 5000)

    -- Asignar primera tarea del bucle continuo con ruta GPS
    Wait(1500)
    AssignNextTask()
end)

RegisterNetEvent('spain_jobs:client:stopShift', function()
    if not isOnDuty then return end

    isOnDuty = false
    ClearTaskBlip()
    currentTask = nil

    -- Borrado garantizado del vehículo de trabajo tanto en cliente como en OneSync
    if currentWorkVehicle and DoesEntityExist(currentWorkVehicle) then
        local netId = NetworkGetNetworkIdFromEntity(currentWorkVehicle)
        TriggerServerEvent('spain_jobs:server:deleteWorkVehicle', netId)
        SetEntityAsMissionEntity(currentWorkVehicle, true, true)
        DeleteVehicle(currentWorkVehicle)
        currentWorkVehicle = nil
    end

    -- Notificar al servidor que finaliza turno
    TriggerServerEvent('spain_jobs:server:setDuty', false, activeJobKey)
    activeJobKey = nil

    TriggerEvent('QBCore:Notify', "Has finalizado tu jornada laboral. Tu vehículo ha sido retirado y tu liquidación procesada.", "primary", 7000)
end)

RegisterNetEvent('spain_jobs:client:respawnVehicle', function(data)
    local station = JobsConfig.Stations[data.stationKey]
    if station then
        SpawnCompanyVehicle(station)
    end
end)

-- NUI CALLBACKS DE LA TABLET DE EMPLEO (SPAIN WORKS PRO)
RegisterNUICallback('closeJobDashboard', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('startShiftFromNui', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
    Wait(200)
    TriggerEvent('spain_jobs:client:startShift', { stationKey = data.stationKey })
end)

RegisterNUICallback('stopShiftFromNui', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
    Wait(200)
    TriggerEvent('spain_jobs:client:stopShift')
end)

RegisterNUICallback('respawnVehicleFromNui', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
    Wait(200)
    TriggerEvent('spain_jobs:client:respawnVehicle', { stationKey = data.stationKey })
end)

RegisterNUICallback('setGpsToTask', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
    if currentTask and currentTask.data and currentTask.data.coords then
        SetNewWaypoint(currentTask.data.coords.x, currentTask.data.coords.y)
        TriggerEvent('QBCore:Notify', "Ruta GPS remarcada hacia: " .. currentTask.data.label, "success", 4000)
    else
        TriggerEvent('QBCore:Notify', "No tienes ninguna parada activa en este momento.", "error")
    end
end)

-- Ejecución de una Tarea de Trabajo en el Punto Asignado
local function ExecuteCurrentTask()
    if not isOnDuty or not currentTask or isDoingTask then return end
    local station = JobsConfig.Stations[activeJobKey]
    if not station then return end

    isDoingTask = true
    local taskData = currentTask.data
    local ped = PlayerPedId()

    -- 1. Intentar Minijuego de Habilidad si está disponible
    local passedMinigame = true
    if exports['qb-minigames'] and exports['qb-minigames'].Skillbar then
        local success = exports['qb-minigames']:Skillbar(station.minigame or 'easy')
        if not success then
            passedMinigame = false
            TriggerEvent('QBCore:Notify', "Has fallado la precisión del trabajo. Concéntrate y vuelve a intentarlo.", "error", 4000)
            isDoingTask = false
            return
        end
    end

    -- 2. Animación y Barra de Progreso
    local animDict = taskData.animDict or "amb@world_human_gardener_plant@male@base"
    local animClip = taskData.animClip or "base"
    local duration = taskData.duration or 5000

    QBCore.Functions.Progressbar("working_task", "Realizando: " .. taskData.label .. "...", duration, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = animDict,
        anim = animClip,
        flags = 1,
    }, {}, {}, function() -- Al completar con éxito
        ClearPedTasks(ped)
        isDoingTask = false

        -- Notificar al servidor para cobrar y sumar avance de horas extras
        TriggerServerEvent('spain_jobs:server:completeTask', activeJobKey, currentTask.index)

        PlaySoundFrontend(-1, "LOCAL_PLYR_CASH_COUNTER_COMPLETE", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 1)

        -- Asignar la siguiente tarea de forma continua
        Wait(2000)
        if isOnDuty then
            AssignNextTask()
        end
    end, function() -- Si cancela
        ClearPedTasks(ped)
        isDoingTask = false
        TriggerEvent('QBCore:Notify', "Has interrumpido la tarea.", "error")
    end)
end

-- Inicialización de Sedes, NPCs y Blips
local function InitJobStations()
    for sKey, sData in pairs(JobsConfig.Stations) do
        -- Crear Blip en el mapa
        if sData.blip then
            local b = AddBlipForCoord(sData.boss.coords.x, sData.boss.coords.y, sData.boss.coords.z)
            SetBlipSprite(b, sData.blip.sprite or 1)
            SetBlipDisplay(b, 4)
            SetBlipScale(b, sData.blip.scale or 0.8)
            SetBlipColour(b, sData.blip.color or 1)
            SetBlipAsShortRange(b, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(sData.blip.title or sData.name)
            EndTextCommandSetBlipName(b)
            table.insert(stationBlips, b)
        end

        -- Cargar y spawnear el NPC Capataz
        RequestModel(sData.boss.model)
        local timeout = 0
        while not HasModelLoaded(sData.boss.model) and timeout < 100 do
            Wait(50)
            timeout = timeout + 1
        end

        if HasModelLoaded(sData.boss.model) then
            local bCoords = sData.boss.coords
            local ped = CreatePed(4, sData.boss.model, bCoords.x, bCoords.y, bCoords.z - 1.0, bCoords.w, false, true)
            SetEntityHeading(ped, bCoords.w)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            TaskStartScenarioInPlace(ped, sData.boss.scenario or 'WORLD_HUMAN_CLIPBOARD', 0, true)
            table.insert(spawnedBosses, ped)

            -- Soporte qb-target
            if GetConvar('UseTarget', 'false') == 'true' or exports['qb-target'] then
                pcall(function()
                    exports['qb-target']:AddTargetEntity(ped, {
                        options = {
                            {
                                type = "client",
                                action = function()
                                    OpenBossMenu(sKey)
                                end,
                                icon = "fas fa-tablet-screen-button",
                                label = "Tablet Laboral de " .. sData.boss.label
                            }
                        },
                        distance = 2.5
                    })
                end)
            end
        end
    end
end

-- Bucle Principal de Interacción (Sedes de Capataces y Puntos de Tarea Activa)
CreateThread(function()
    InitJobStations()

    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)

        -- 1. Detección de proximidad a Capataces de Sedes
        for sKey, sData in pairs(JobsConfig.Stations) do
            local bCoords = vector3(sData.boss.coords.x, sData.boss.coords.y, sData.boss.coords.z)
            local dist = #(pCoords - bCoords)
            if dist < 5.0 then
                sleep = 0
                if dist < 2.3 then
                    DrawText3D(bCoords.x, bCoords.y, bCoords.z + 1.0, "~y~[E]~s~ Tablet de " .. sData.boss.label)
                    if IsControlJustReleased(0, 38) then
                        OpenBossMenu(sKey)
                    end
                end
            end
        end

        -- 2. Detección de proximidad al punto de Tarea Activa (cuando está de servicio)
        if isOnDuty and currentTask and not isDoingTask then
            local tCoords = currentTask.data.coords
            local distTask = #(pCoords - tCoords)
            if distTask < 80.0 then
                sleep = 0
                -- Baliza de luz cilíndrica 3D visible a larga distancia
                DrawMarker(1, tCoords.x, tCoords.y, tCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.8, 1.8, 4.0, 255, 204, 0, 90, false, false, 2, false, nil, nil, false)
                -- Marcador chevron pulsante en lo alto
                DrawMarker(2, tCoords.x, tCoords.y, tCoords.z + 1.2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.5, 0.5, 0.5, 255, 204, 0, 180, false, true, 2, false, nil, nil, false)

                if distTask < 6.0 then
                    local inVeh = IsPedInAnyVehicle(playerPed, false)
                    if inVeh then
                        DrawText3D(tCoords.x, tCoords.y, tCoords.z + 1.2, "~y~[🅿️ Estaciona y Desciende]~s~ para realizar: " .. currentTask.data.label)
                    else
                        DrawText3D(tCoords.x, tCoords.y, tCoords.z + 1.0, "~g~[E]~s~ Realizar Tarea: " .. currentTask.data.label)
                        if IsControlJustReleased(0, 38) then
                            ExecuteCurrentTask()
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- Limpieza al reiniciar recurso
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    ClearTaskBlip()
    for _, b in ipairs(stationBlips) do
        if DoesBlipExist(b) then RemoveBlip(b) end
    end
    for _, p in ipairs(spawnedBosses) do
        if DoesEntityExist(p) then DeletePed(p) end
    end
    if currentWorkVehicle and DoesEntityExist(currentWorkVehicle) then
        QBCore.Functions.DeleteVehicle(currentWorkVehicle)
    end
end)
