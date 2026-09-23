local QBCore = exports['qb-core']:GetCoreObject()

-- Evento de facturación de taller mecánico (Benny's y LSC)
RegisterNetEvent('spain_mechanic:server:sendBill', function(targetId, amount, reason)
    local src = source
    local Mechanic = QBCore.Functions.GetPlayer(src)
    if not Mechanic then return end

    local jobName = Mechanic.PlayerData.job.name
    if jobName ~= 'mechanic' and jobName ~= 'bennys' and jobName ~= 'canals' and Mechanic.PlayerData.job.type ~= 'mechanic' and not QBCore.Functions.HasPermission(src, 'admin') then
        TriggerClientEvent('QBCore:Notify', src, 'No tienes permiso para emitir facturas de taller.', 'error')
        return
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Importe no válido.', 'error')
        return
    end

    local Customer = QBCore.Functions.GetPlayer(tonumber(targetId))
    if not Customer then
        TriggerClientEvent('QBCore:Notify', src, 'El cliente no se encuentra en línea.', 'error')
        return
    end

    reason = reason or "Servicios de Taller Mecánico"

    -- Cobrar al cliente (primero banco, luego efectivo)
    local paid = false
    if Customer.Functions.RemoveMoney('bank', amount, reason) then
        paid = true
    elseif Customer.Functions.RemoveMoney('cash', amount, reason) then
        paid = true
    end

    if paid then
        -- 20% comisión directa para el empleado/mecánico
        local commission = math.floor(amount * 0.20)
        local societyAmount = amount - commission

        Mechanic.Functions.AddMoney('bank', commission, 'Comisión de reparación')
        TriggerClientEvent('QBCore:Notify', src, string.format('Factura cobrada con éxito. Recibes %d€ de comisión directa.', commission), 'success')

        -- 80% restante va a los fondos del taller (sociedad)
        local societyName = jobName
        if exports['qb-banking'] and exports['qb-banking'].AddMoney then
            pcall(function()
                exports['qb-banking']:AddMoney(societyName, societyAmount, 'Ingreso por factura: ' .. reason)
            end)
        end

        TriggerClientEvent('QBCore:Notify', Customer.PlayerData.source, string.format('Has pagado una factura de taller de %d€ por: %s', amount, reason), 'primary')
    else
        TriggerClientEvent('QBCore:Notify', src, 'El cliente no tiene fondos suficientes (banco o efectivo) para abonar la factura.', 'error')
        TriggerClientEvent('QBCore:Notify', Customer.PlayerData.source, 'No tienes saldo suficiente para pagar la factura de taller de ' .. amount .. '€.', 'error')
    end
end)

-- Ítems Usables de Taller Mecánico (Puertas, Capó, Maletero, Ruedas)
QBCore.Functions.CreateUseableItem('veh_door', function(source, item)
    TriggerClientEvent('spain_mechanic:client:installDoor', source)
end)

QBCore.Functions.CreateUseableItem('veh_hood', function(source, item)
    TriggerClientEvent('spain_mechanic:client:installHood', source)
end)

QBCore.Functions.CreateUseableItem('veh_trunk', function(source, item)
    TriggerClientEvent('spain_mechanic:client:installTrunk', source)
end)

QBCore.Functions.CreateUseableItem('veh_wheel', function(source, item)
    TriggerClientEvent('spain_mechanic:client:installWheel', source)
end)

-- Piezas de Rendimiento y Tuning (ONX Style)
local perfItems = {
    'turbo_racing',
    'engine_stage1',
    'engine_stage2',
    'engine_stage3',
    'racing_brakes',
    'racing_transmission',
    'drift_suspension',
    'nos_tank'
}

for _, itemName in ipairs(perfItems) do
    QBCore.Functions.CreateUseableItem(itemName, function(source, item)
        TriggerClientEvent('spain_mechanic:client:installPerformancePart', source, itemName)
    end)
end

RegisterNetEvent('spain_mechanic:server:removeRepairItem', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.RemoveItem(itemName, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'remove')
    end
end)
