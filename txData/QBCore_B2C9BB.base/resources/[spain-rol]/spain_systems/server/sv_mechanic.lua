local QBCore = exports['qb-core']:GetCoreObject()

-- Comprobar si el jugador es mecánico
local function IsMechanic(Player)
    if not Player or not Player.PlayerData or not Player.PlayerData.job then return false end
    local job = Player.PlayerData.job
    local jobName = job.name
    local jobType = job.type
    return jobType == 'mechanic' or jobName == 'mechanic' or jobName == 'bennys' or jobName == 'canals' or jobName == 'mechanic2' or jobName == 'mechanic3' or jobName == 'beeker'
end

-- Comprobar si el mecánico está de servicio (fichado)
local function IsMechanicOnDuty(Player)
    if not IsMechanic(Player) then return false end
    return Player.PlayerData.job.onduty == true
end

-- Función para alternar servicio (fichar / salir de servicio) desde cualquier lugar
local function ToggleDutyForPlayer(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not IsMechanic(Player) then
        TriggerClientEvent('QBCore:Notify', src, "No tienes el trabajo de mecánico asignado.", "error")
        return
    end

    local playerJob = Player.PlayerData.job
    local currentDuty = playerJob.onduty
    local newDuty = not currentDuty
    Player.Functions.SetJobDuty(newDuty)
    TriggerClientEvent('QBCore:Client:SetDuty', src, newDuty)

    if newDuty then
        TriggerClientEvent('QBCore:Notify', src, "⏱️ Has fichado [🟢 EN SERVICIO] en: " .. (playerJob.label or "Taller") .. ". Sistema de taller activado.", "success", 4500)
    else
        TriggerClientEvent('QBCore:Notify', src, "⏱️ Has salido de turno [🔴 FUERA DE SERVICIO] de: " .. (playerJob.label or "Taller") .. ". ¡Buen descanso!", "primary", 4500)
    end
end

RegisterNetEvent('spain_mechanic:server:toggleDuty', function()
    local src = source
    ToggleDutyForPlayer(src)
end)

-- Comprar piezas y suministros en la Tablet de Mecánico (guardar en inventario)
RegisterNetEvent('spain_mechanic:server:buyItem', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data then return end

    if not IsMechanic(Player) then
        TriggerClientEvent('QBCore:Notify', src, "Solo mecánicos autorizados pueden comprar en este catálogo.", "error")
        return
    end

    if not Player.PlayerData.job.onduty then
        TriggerClientEvent('QBCore:Notify', src, "Debes fichar y estar de servicio para comprar suministros de taller.", "error")
        return
    end

    local item = data.item
    local price = tonumber(data.price) or 0
    local label = data.label or item

    if Player.Functions.RemoveMoney('cash', price) or Player.Functions.RemoveMoney('bank', price) then
        Player.Functions.AddItem(item, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item] or { label = label }, "add")
        TriggerClientEvent('QBCore:Notify', src, "Has adquirido " .. label .. " por " .. price .. "€.", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "No dispones de suficiente dinero (efectivo o banco) para adquirir esta pieza.", "error")
    end
end)

-- Comprar pieza física y llevarla inmediatamente en las manos (Sistema ONX / R1 Mech)
RegisterNetEvent('spain_mechanic:server:buyPhysicalPart', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data then return end

    if not IsMechanic(Player) then
        TriggerClientEvent('QBCore:Notify', src, "Solo mecánicos autorizados pueden despachar piezas físicas.", "error")
        return
    end

    if not Player.PlayerData.job.onduty then
        TriggerClientEvent('QBCore:Notify', src, "Debes fichar y estar de servicio en el taller.", "error")
        return
    end

    local item = data.item
    local price = tonumber(data.price) or 0
    local label = data.label or item
    local partType = data.partType or 'engine'

    if Player.Functions.RemoveMoney('cash', price) or Player.Functions.RemoveMoney('bank', price) then
        TriggerClientEvent('QBCore:Notify', src, "Has sacado " .. label .. " del almacén. Llévala al vehículo para instalarla.", "success")
        TriggerClientEvent('spain_mechanic:client:startCarryingPart', src, {
            partType = partType,
            item = item,
            label = label
        })
    else
        TriggerClientEvent('QBCore:Notify', src, "No dispones de suficiente dinero para despachar esta pieza.", "error")
    end
end)

-- =========================================================================
-- SISTEMA DE LOGÍSTICA, TRANSPORTE EN FURGONETA Y ALMACÉN DE TALLER
-- =========================================================================
local ActiveLogisticsOrders = {}

-- Realizar pedido logístico de piezas desde la Tablet
RegisterNetEvent('spain_mechanic:server:orderLogisticsSupply', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data then return end

    if not IsMechanic(Player) then
        TriggerClientEvent('QBCore:Notify', src, "Solo mecánicos autorizados pueden encargar suministros.", "error")
        return
    end

    if not Player.PlayerData.job.onduty then
        TriggerClientEvent('QBCore:Notify', src, "Debes fichar y estar de servicio en el taller para encargar repuestos.", "error")
        return
    end

    local item = data.item
    local price = tonumber(data.price) or 0
    local label = data.label or item
    local partType = data.partType or 'engine'
    local count = tonumber(data.count) or 1

    if Player.Functions.RemoveMoney('cash', price) or Player.Functions.RemoveMoney('bank', price) then
        ActiveLogisticsOrders[src] = {
            item = item,
            count = count,
            label = label,
            partType = partType,
            shop = Player.PlayerData.job.name
        }
        TriggerClientEvent('QBCore:Notify', src, "📦 Pedido tramitado por " .. price .. "€. Ve al punto de vehículos de tu taller para sacar la furgoneta.", "success", 5000)
        TriggerClientEvent('spain_mechanic:client:startLogisticsMission', src, ActiveLogisticsOrders[src])
    else
        TriggerClientEvent('QBCore:Notify', src, "No dispones de suficiente dinero para tramitar este pedido logístico.", "error")
    end
end)

-- Completar descarga en las estanterías del taller
RegisterNetEvent('spain_mechanic:server:completeSupplyDelivery', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local order = ActiveLogisticsOrders[src]
    if not order then
        TriggerClientEvent('QBCore:Notify', src, "No tienes ningún pedido activo pendiente de entrega.", "error")
        return
    end

    local jobName = Player.PlayerData.job.name
    local stashName = "mechanic_stash_" .. jobName

    -- Añadir ítems al inventario/almacén del taller (qb-inventory)
    local success = exports['qb-inventory']:AddItem(stashName, order.item, order.count)
    if not success then
        -- Fallback al inventario del mecánico si el stash no existiese aún
        Player.Functions.AddItem(order.item, order.count)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[order.item] or { label = order.label }, "add")
    end

    ActiveLogisticsOrders[src] = nil
    TriggerClientEvent('QBCore:Notify', src, "✅ ¡Caja de " .. order.label .. " colocada en el almacén del taller! El stock ya está disponible.", "success", 5000)
    TriggerClientEvent('spain_mechanic:client:orderDeliveredSuccess', src)
end)

-- Abrir el almacén / estanterías del taller en cualquier momento
RegisterNetEvent('spain_mechanic:server:openWorkshopStash', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not IsMechanic(Player) or not Player.PlayerData.job.onduty then
        TriggerClientEvent('QBCore:Notify', src, "Debes ser mecánico de servicio para acceder a las estanterías.", "error")
        return
    end

    local jobName = Player.PlayerData.job.name
    local stashName = "mechanic_stash_" .. jobName
    local stashLabel = "Almacén " .. (Player.PlayerData.job.label or "Taller")

    exports['qb-inventory']:OpenInventory(src, stashName, {
        label = stashLabel,
        maxweight = 5000000,
        slots = 50
    })
end)

-- Desmontar pieza física del vehículo y devolverla al inventario del mecánico
RegisterNetEvent('spain_mechanic:server:giveDismantledPart', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data then return end

    if not IsMechanic(Player) or not Player.PlayerData.job.onduty then
        TriggerClientEvent('QBCore:Notify', src, "Debes ser mecánico de servicio para desmontar componentes.", "error")
        return
    end

    local item = data.item
    local label = data.label or item

    Player.Functions.AddItem(item, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item] or { label = label }, "add")
    TriggerClientEvent('QBCore:Notify', src, "Has desmontado y recuperado: " .. label .. " en tu inventario.", "success")
end)

-- Consumir pieza o kit tras su instalación
RegisterNetEvent('spain_mechanic:server:consumeItem', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not itemName then return end

    if Player.Functions.RemoveItem(itemName, 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName] or { label = itemName }, "remove")
    end
end)

-- Guardar propiedades del vehículo en la base de datos
RegisterNetEvent('spain_mechanic:server:saveVehicleProps', function(props)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not props or not props.plate then return end

    local plate = props.plate
    MySQL.update('UPDATE player_vehicles SET mods = ? WHERE plate = ?', { json.encode(props), plate })
end)

-- REGISTRO DE ÍTEMS USABLES DE MECÁNICO
-- Tablet de Taller
QBCore.Functions.CreateUseableItem('mechanic_tablet', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not IsMechanic(Player) then
        TriggerClientEvent('QBCore:Notify', source, "Esta tablet está codificada para uso exclusivo de mecánicos.", "error")
        return
    end
    TriggerClientEvent('spain_mechanic:client:openTablet', source)
end)

-- Kit de Reparación de Taller
QBCore.Functions.CreateUseableItem('repairkit', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('spain_mechanic:client:useRepairKit', source)
end)

QBCore.Functions.CreateUseableItem('advancedrepairkit', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('spain_mechanic:client:useRepairKit', source)
end)

-- Piezas de Rendimiento Físicas
local perfList = {
    veh_engine = 'engine',
    veh_brakes = 'brakes',
    veh_transmission = 'transmission',
    veh_suspension = 'suspension',
    veh_turbo = 'turbo',
    veh_armor = 'armor'
}

for item, partType in pairs(perfList) do
    QBCore.Functions.CreateUseableItem(item, function(source)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return end
        if not IsMechanic(Player) then
            TriggerClientEvent('QBCore:Notify', source, "Solo mecánicos autorizados saben manipular piezas de alto rendimiento.", "error")
            return
        end
        -- Permite al jugador elegir: instalar directamente o sacar en la mano como pieza física en cualquier momento
        TriggerClientEvent('spain_mechanic:client:handleUsablePart', source, { partType = partType, item = item })
    end)
end

-- Ítems de comprobación y mantenimiento realista
QBCore.Functions.CreateUseableItem('multimeter', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not IsMechanic(Player) then
        TriggerClientEvent('QBCore:Notify', source, "Solo un mecánico capacitado sabe operar el multímetro automotriz.", "error")
        return
    end
    TriggerClientEvent('spain_mechanic:client:useMultimeter', source)
end)

QBCore.Functions.CreateUseableItem('obd_scanner', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not IsMechanic(Player) then
        TriggerClientEvent('QBCore:Notify', source, "Este escáner OBD-II requiere conocimientos de diagnosis electrónica.", "error")
        return
    end
    TriggerClientEvent('spain_mechanic:client:useObdScanner', source)
end)

QBCore.Functions.CreateUseableItem('engine_oil', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('spain_mechanic:client:useEngineOil', source)
end)

QBCore.Functions.CreateUseableItem('sparkplugs', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('spain_mechanic:client:useSparkPlugs', source)
end)

QBCore.Functions.CreateUseableItem('veh_wiring', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('spain_mechanic:client:useWiringHarness', source)
end)

QBCore.Functions.CreateUseableItem('car_battery', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('spain_mechanic:client:useBattery', source)
end)

QBCore.Functions.CreateUseableItem('brake_pads', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('spain_mechanic:client:useBrakePads', source)
end)

-- Eventos de consumo de materiales en intervenciones
RegisterNetEvent('spain_mechanic:server:consumeSpecificItem', function(itemName, label)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not itemName then return end
    if Player.Functions.RemoveItem(itemName, 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName] or { label = label or itemName }, "remove")
    end
end)

-- Limpieza
QBCore.Functions.CreateUseableItem('cleaningkit', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('spain_mechanic:client:useCleaningKit', source)
end)

-- COMANDOS
-- Fichar
QBCore.Commands.Add('fichar', 'Fichar / Entrar o Salir de Servicio (Taller Mecánico)', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not IsMechanic(Player) then
        TriggerClientEvent('QBCore:Notify', source, "Este comando es exclusivo para personal de talleres.", "error")
        return
    end
    ToggleDutyForPlayer(source)
end)

QBCore.Commands.Add('duty', 'Alternar servicio de trabajo desde donde sea', {}, false, function(source)
    ToggleDutyForPlayer(source)
end)

-- Abrir tablet de mecánico
QBCore.Commands.Add('mecanico', 'Abrir Tablet de Taller Mecánico (R1 MECH PRO)', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not IsMechanic(Player) then
        TriggerClientEvent('QBCore:Notify', source, "No tienes el trabajo de mecánico asignado.", "error")
        return
    end
    TriggerClientEvent('spain_mechanic:client:openTablet', source)
end)

QBCore.Commands.Add('tablet', 'Abrir Tablet de Mecánico', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if IsMechanic(Player) then
        TriggerClientEvent('spain_mechanic:client:openTablet', source)
    end
end)
