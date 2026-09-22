local QBCore = exports['qb-core']:GetCoreObject()

-- =========================================================================
-- MERCADO NEGRO
-- =========================================================================
RegisterNetEvent('spain_blackmarket:server:purchase', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data then return end

    local price = tonumber(data.price) or 0
    local item = data.item
    local label = data.label or item

    if Player.Functions.RemoveMoney('crypto', price) or Player.Functions.RemoveMoney('cash', price) then
        Player.Functions.AddItem(item, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item] or { label = label }, "add")
        TriggerClientEvent('QBCore:Notify', src, "Has comprado " .. label .. " por €" .. price, "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "No tienes suficiente dinero en efectivo ni criptomonedas.", "error")
    end
end)

-- =========================================================================
-- BLANQUEO DE DINERO
-- =========================================================================
RegisterNetEvent('spain_laundry:server:startWash', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local blackMoneyItem = Player.Functions.GetItemByName('markedbills')
    local amount = 0
    if blackMoneyItem then
        amount = (blackMoneyItem.info and blackMoneyItem.info.worth) or (blackMoneyItem.amount * 500)
    end

    if amount > 0 then
        local cut = Config.MoneyLaundry.laundryCut or 0.15
        local cleanAmount = math.floor(amount * (1.0 - cut))
        TriggerClientEvent('spain_laundry:client:doWash', src, amount, cleanAmount)
    else
        TriggerClientEvent('QBCore:Notify', src, "No tienes bolsas de dinero negro (markedbills) para blanquear.", "error")
    end
end)

RegisterNetEvent('spain_laundry:server:finishWash', function(amount, cleanAmount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.Functions.RemoveItem('markedbills', 1) then
        Player.Functions.AddMoney('cash', cleanAmount, 'money-laundry')
        TriggerClientEvent('QBCore:Notify', src, "Has blanqueado €" .. amount .. " y recibido €" .. cleanAmount .. " en efectivo limpio.", "success")
    end
end)

-- =========================================================================
-- HERRAMIENTAS POLICIALES (ALCOHOL Y DROGAS)
-- =========================================================================
RegisterNetEvent('spain_police:server:testAlcohol', function(targetId)
    local src = source
    local target = QBCore.Functions.GetPlayer(targetId)
    if not target then return end

    local alcoholRate = string.format("%.2f", math.random(0, 80) / 100)
    local resultMsg = "Prueba de Alcoholemia: " .. alcoholRate .. " mg/l en aire espirado."
    if tonumber(alcoholRate) > 0.25 then
        resultMsg = resultMsg .. " [POSITIVO - TASA SUPERADA]"
    else
        resultMsg = resultMsg .. " [NEGATIVO]"
    end

    TriggerClientEvent('QBCore:Notify', src, resultMsg, "primary", 8000)
    TriggerClientEvent('QBCore:Notify', targetId, "La Policía Nacional te ha realizado una prueba de alcoholemia.", "primary")
end)

RegisterNetEvent('spain_police:server:testDrugs', function(targetId)
    local src = source
    local target = QBCore.Functions.GetPlayer(targetId)
    if not target then return end

    local hasDrugs = math.random(1, 2) == 1 and "POSITIVO en THC / Cocaína" or "NEGATIVO"
    TriggerClientEvent('QBCore:Notify', src, "Narcotest CNP: " .. hasDrugs, "primary", 8000)
    TriggerClientEvent('QBCore:Notify', targetId, "La Policía te ha realizado una prueba salival de estupefacientes.", "primary")
end)

-- =========================================================================
-- RUTAS DE DROGAS Y VENTA EN ESQUINA
-- =========================================================================
RegisterNetEvent('spain_drugs:server:giveReward', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not item then return end

    Player.Functions.AddItem(item, amount or 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item] or { label = item }, "add")
end)

RegisterNetEvent('spain_drugs:server:sellCorner', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local drugs = { 'weed_baggy', 'cokebaggy', 'blue_meth', 'xtcbaggy' }
    local sold = false

    for _, drug in ipairs(drugs) do
        local item = Player.Functions.GetItemByName(drug)
        if item and item.amount > 0 then
            Player.Functions.RemoveItem(drug, 1)
            local earn = math.random(150, 450)
            Player.Functions.AddMoney('cash', earn, 'corner-drug-sell')
            TriggerClientEvent('QBCore:Notify', src, "Has vendido 1x " .. drug .. " a un transeúnte por €" .. earn, "success")
            sold = true
            break
        end
    end

    if not sold then
        TriggerClientEvent('QBCore:Notify', src, "No tienes sustancias preparadas para vender a los compradores.", "error")
    end
end)

-- =========================================================================
-- FACTURACIÓN DE MECÁNICOS Y TUNING
-- =========================================================================
RegisterNetEvent('spain_mechanic:server:sendBill', function(targetServerId, amount)
    local src = source
    local Sender = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(targetServerId)
    if not Sender or not Target then return end

    local cost = tonumber(amount) or 0
    if Target.Functions.RemoveMoney('bank', cost) or Target.Functions.RemoveMoney('cash', cost) then
        Sender.Functions.AddMoney('bank', math.floor(cost * 0.8), 'mechanic-commission')
        TriggerClientEvent('QBCore:Notify', targetServerId, "Has pagado una factura de taller de €" .. cost, "success")
        TriggerClientEvent('QBCore:Notify', src, "Factura cobrada con éxito. Recibes €" .. math.floor(cost * 0.8) .. " de comisión.", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "El cliente no tiene suficiente dinero para pagar la factura.", "error")
    end
end)

RegisterNetEvent('spain_tuning:server:payAndSave', function(price, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cost = tonumber(price) or 0
    if Player.Functions.RemoveMoney('cash', cost) or Player.Functions.RemoveMoney('bank', cost) then
        TriggerClientEvent('QBCore:Notify', src, "Modificación realizada por €" .. cost, "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "No tienes suficiente dinero para esta modificación.", "error")
    end
end)

-- =========================================================================
-- ATRACO AL MEGAYATE
-- =========================================================================
RegisterNetEvent('spain_yacht:server:alertPolice', function()
    TriggerClientEvent('spain_yacht:client:policeAlert', -1)
end)

RegisterNetEvent('spain_yacht:server:rewardSafe', function(safeId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local rewardCash = math.random(15000, 35000)
    Player.Functions.AddMoney('cash', rewardCash, 'yacht-heist-safe')
    Player.Functions.AddItem('goldbar', math.random(2, 5))
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['goldbar'] or { label = "Lingote de Oro" }, "add")
    TriggerClientEvent('QBCore:Notify', src, "Has extraído €" .. rewardCash .. " en efectivo y lingotes de oro.", "success")
end)
