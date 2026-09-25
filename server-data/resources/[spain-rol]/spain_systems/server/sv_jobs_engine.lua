-- =========================================================================
-- SPAIN ROL - SERVIDOR: MOTOR DINÁMICO DE EMPLEOS Y HORAS EXTRAS EN NEGRO
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()
local activeWorkers = {}

-- Evento de Entrada / Salida de Servicio (Turno de Trabajo)
RegisterNetEvent('spain_jobs:server:setDuty', function(onDuty, stationKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid

    if onDuty then
        activeWorkers[cid] = {
            src = src,
            job = stationKey,
            startTime = os.time(),
            lastOvertime = os.time(),
            tasksCount = 0,
            overtimeCash = 0
        }
        Player.Functions.SetJobDuty(true)
    else
        if activeWorkers[cid] then
            local session = activeWorkers[cid]
            local totalMinutes = math.floor((os.time() - session.startTime) / 60)
            TriggerClientEvent('QBCore:Notify', src, "Turno finalizado. Tiempo trabajado: " .. totalMinutes .. " minutos. Tareas completadas: " .. session.tasksCount, "primary", 7500)
            activeWorkers[cid] = nil
        end
        Player.Functions.SetJobDuty(false)
    end
end)

-- Entrega de llaves del vehículo de trabajo
RegisterNetEvent('spain_jobs:server:giveWorkKeys', function(plate)
    local src = source
    if not plate then return end
    if exports['qb-vehiclekeys'] and exports['qb-vehiclekeys'].GiveKeys then
        exports['qb-vehiclekeys']:GiveKeys(src, plate)
    end
end)

RegisterNetEvent('spain_jobs:server:giveWorkVehicleKeys', function(vehNetId, plate)
    local src = source
    if not plate then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and vehNetId and vehNetId ~= 0 then
        local cid = Player.PlayerData.citizenid
        if activeWorkers[cid] then
            activeWorkers[cid].vehNetId = vehNetId
        end
    end

    if exports['qb-vehiclekeys'] and exports['qb-vehiclekeys'].GiveKeys then
        exports['qb-vehiclekeys']:GiveKeys(src, plate)
    end
end)

-- Borrado garantizado del vehículo de trabajo en el servidor
RegisterNetEvent('spain_jobs:server:deleteWorkVehicle', function(vehNetId)
    local src = source
    if vehNetId and vehNetId ~= 0 then
        local entity = NetworkGetEntityFromNetworkId(vehNetId)
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end
end)

-- Callback para alimentar la nueva tablet NUI de trabajos (Spain Works Pro)
QBCore.Functions.CreateCallback('spain_jobs:server:getJobDashboardData', function(source, cb, stationKey)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local cid = Player.PlayerData.citizenid
    local station = JobsConfig.Stations[stationKey]
    local session = activeWorkers[cid]

    local workerData = {
        name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
        citizenid = cid,
        job = Player.PlayerData.job.name,
        jobLabel = Player.PlayerData.job.label or "Empleado",
        grade = Player.PlayerData.job.grade.name or "Operario",
        onDuty = (session ~= nil),
        tasksCount = session and session.tasksCount or 0,
        overtimeCash = session and session.overtimeCash or 0,
        minutesWorked = session and math.floor((os.time() - session.startTime) / 60) or 0,
        station = station or {}
    }

    cb(workerData)
end)

-- Evento al Completar una Tarea de Trabajo en el Mundo
RegisterNetEvent('spain_jobs:server:completeTask', function(stationKey, taskIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local station = JobsConfig.Stations[stationKey]
    if not station then return end

    -- 1. Pago Legal de Nómina / Salario Blanco (Directo a Cuenta Bancaria)
    local legalReward = math.random(station.pay.min, station.pay.max)
    Player.Functions.AddMoney('bank', legalReward, 'job-task-reward')
    TriggerClientEvent('QBCore:Notify', src, "Has cobrado €" .. legalReward .. " ingresados en tu cuenta bancaria por la tarea completada.", "success")

    -- 2. Registro de Avance de Turno
    if not activeWorkers[cid] then
        activeWorkers[cid] = {
            src = src,
            job = stationKey,
            startTime = os.time(),
            lastOvertime = os.time(),
            tasksCount = 0,
            overtimeCash = 0
        }
    end

    local worker = activeWorkers[cid]
    worker.tasksCount = worker.tasksCount + 1

    -- 3. Bonificación de Horas Extras en Dinero Negro (Cada X tareas)
    local otConfig = JobsConfig.Overtime
    if otConfig.enabled and (worker.tasksCount % otConfig.tasksInterval == 0) then
        local blackReward = math.random(otConfig.minBlackCash, otConfig.maxBlackCash)
        worker.overtimeCash = worker.overtimeCash + blackReward

        -- Entregar bolsa de dinero negro marcada con su valor exacto (totalmente compatible con spain_laundry)
        local info = {
            worth = blackReward,
            label = "Horas Extras No Declaradas (€" .. blackReward .. ")"
        }
        Player.Functions.AddItem('markedbills', 1, false, info)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'] or { label = "Dinero Negro Marcado" }, "add")

        local msg = string.format(otConfig.notifyMessage, blackReward)
        TriggerClientEvent('QBCore:Notify', src, msg, "success", 9000)
    end
end)

-- Bucle de Control de Horas Extras por Tiempo Continuado de Servicio
CreateThread(function()
    while true do
        Wait(60000) -- Comprobación cada minuto
        local now = os.time()
        local otConfig = JobsConfig.Overtime

        if otConfig.enabled then
            for cid, session in pairs(activeWorkers) do
                local timeWorking = now - (session.lastOvertime or session.startTime)
                if timeWorking >= otConfig.timeInterval then
                    session.lastOvertime = now
                    local Player = QBCore.Functions.GetPlayerByCitizenId(cid)
                    if Player then
                        local blackReward = math.random(otConfig.minBlackCash, otConfig.maxBlackCash)
                        session.overtimeCash = session.overtimeCash + blackReward

                        local info = {
                            worth = blackReward,
                            label = "Gratificación Horas Extras (€" .. blackReward .. ")"
                        }
                        Player.Functions.AddItem('markedbills', 1, false, info)
                        TriggerClientEvent('inventory:client:ItemBox', session.src, QBCore.Shared.Items['markedbills'] or { label = "Dinero Negro Marcado" }, "add")

                        local msg = string.format(otConfig.notifyMessage, blackReward)
                        TriggerClientEvent('QBCore:Notify', session.src, msg, "success", 9000)
                    end
                end
            end
        end
    end
end)

-- Limpieza si el jugador se desconecta
AddEventHandler('playerDropped', function()
    local src = source
    for cid, session in pairs(activeWorkers) do
        if session.src == src then
            if session.vehNetId and session.vehNetId ~= 0 then
                local entity = NetworkGetEntityFromNetworkId(session.vehNetId)
                if DoesEntityExist(entity) then
                    DeleteEntity(entity)
                end
            end
            activeWorkers[cid] = nil
            break
        end
    end
end)
