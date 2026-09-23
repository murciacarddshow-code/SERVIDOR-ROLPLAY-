local QBCore = exports['qb-core']:GetCoreObject()
local vehicleStatus = {}
local vehicleComponents = {}
local nitrousVehicles = {}
local tunedVehicles = {}

-- Items usables de personalización y rendimiento
local usableItems = {
    'veh_armor', 'veh_brakes', 'veh_engine', 'veh_suspension', 'veh_transmission', 'veh_turbo',
    'veh_interior', 'veh_exterior', 'veh_wheels', 'veh_neons', 'veh_xenons', 'veh_tint', 'veh_plates'
}

for _, item in ipairs(usableItems) do
    QBCore.Functions.CreateUseableItem(item, function(source)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return end
        if Config.RequireJob then
            local jobName = Player.PlayerData.job.name
            local jobType = Player.PlayerData.job.type
            if jobName ~= 'mechanic' and jobName ~= 'bennys' and jobName ~= 'canals' and jobType ~= 'mechanic' and not QBCore.Functions.HasPermission(source, 'admin') then
                TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_mechanic') or 'Solo los mecánicos pueden instalar esta pieza.', 'error')
                return
            end
        end
        TriggerClientEvent('qb-mechanicjob:client:installPart', source, item)
    end)
end

-- Tuner Laptop
QBCore.Functions.CreateUseableItem('tunerlaptop', function(source)
    TriggerClientEvent('qb-mechanicjob:client:openTunerLaptop', source)
end)

-- Nitrous
QBCore.Functions.CreateUseableItem('nitrous', function(source)
    TriggerClientEvent('qb-mechanicjob:client:applyNitrous', source)
end)

-- Eliminar item de inventario al usarlo
RegisterNetEvent('qb-mechanicjob:server:removeItem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    amount = amount or 1
    Player.Functions.RemoveItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove')
end)

-- Comprobar permisos
QBCore.Functions.CreateCallback('qb-mechanicjob:server:hasPermission', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end
    local jobName = Player.PlayerData.job.name
    local jobType = Player.PlayerData.job.type
    local hasPerm = (jobName == 'mechanic' or jobName == 'bennys' or jobName == 'canals' or jobType == 'mechanic' or QBCore.Functions.HasPermission(source, 'admin'))
    cb(hasPerm)
end)

-- Guardar propiedades del vehículo
RegisterNetEvent('qb-mechanicjob:server:SaveVehicleProps', function(props)
    local plate = props.plate
    if not plate then return end
    MySQL.update('UPDATE player_vehicles SET mods = ? WHERE plate = ?', { json.encode(props), plate })
end)

-- Pintura del vehículo
RegisterNetEvent('qb-mechanicjob:server:sprayVehicle', function(netId, primary, secondary, pearlescent, wheel, colors)
    TriggerClientEvent('qb-mechanicjob:client:sprayVehicle', -1, netId, primary, secondary, pearlescent, wheel, colors)
end)

RegisterNetEvent('qb-mechanicjob:server:sprayVehicleCustom', function(netId, section, paintType, color)
    TriggerClientEvent('qb-mechanicjob:client:sprayVehicleCustom', -1, netId, section, paintType, color)
end)

-- Nitrous sync
RegisterNetEvent('qb-mechanicjob:server:syncNitrous', function(plate, hasNitro, level)
    nitrousVehicles[plate] = {
        hasNitro = hasNitro,
        level = level or 100
    }
    TriggerClientEvent('qb-mechanicjob:client:syncNitrous', -1, plate, hasNitro, level)
end)

RegisterNetEvent('qb-mechanicjob:server:syncNitrousFlames', function(netId, toggle)
    TriggerClientEvent('qb-mechanicjob:client:syncNitrousFlames', -1, netId, toggle)
end)

QBCore.Functions.CreateCallback('qb-mechanicjob:server:getnitrousVehicles', function(source, cb)
    cb(nitrousVehicles)
end)

-- Diagnóstico y estado de piezas
QBCore.Functions.CreateCallback('qb-mechanicjob:server:getVehicleStatus', function(source, cb, plate)
    cb(vehicleStatus[plate] or {})
end)

RegisterNetEvent('qb-mechanicjob:server:repairVehicleComponent', function(plate, component)
    if not vehicleStatus[plate] then vehicleStatus[plate] = {} end
    vehicleStatus[plate][component] = 100
end)

-- Driving distance & components
RegisterNetEvent('qb-mechanicjob:server:updateDrivingDistance', function(plate, distance)
    -- Guardado local en memoria
end)

RegisterNetEvent('qb-mechanicjob:server:updateVehicleComponents', function(plate, components)
    vehicleComponents[plate] = components
end)

-- Tuner chip tune check
QBCore.Functions.CreateCallback('qb-mechanicjob:server:checkTune', function(source, cb, plate)
    cb(tunedVehicles[plate] or false)
end)

RegisterNetEvent('qb-mechanicjob:server:tuneStatus', function(plate, status)
    tunedVehicles[plate] = status
end)
