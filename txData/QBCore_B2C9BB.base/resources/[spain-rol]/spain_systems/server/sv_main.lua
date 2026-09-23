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

-- =========================================================================
-- COMANDO ADMINISTRATIVO PARA DAR JEFATURA DE TALLER INDIVIDUAL
-- =========================================================================

QBCore.Commands.Add('darjefetaller', 'Asignar a un jugador como Jefe de Taller (Admin)', {
    { name = 'id', help = 'ID del jugador en el servidor' },
    { name = 'taller', help = 'Nombre del taller (canals, mechanic, bennys)' }
}, true, function(source, args)
    local targetId = tonumber(args[1])
    local shopName = tostring(args[2]):lower()

    if shopName == 'lsc' then shopName = 'mechanic' end

    if shopName ~= 'canals' and shopName ~= 'mechanic' and shopName ~= 'bennys' then
        TriggerClientEvent('QBCore:Notify', source, 'Taller no válido. Opciones: canals, mechanic, bennys', 'error')
        return
    end

    local Target = QBCore.Functions.GetPlayer(targetId)
    if not Target then
        TriggerClientEvent('QBCore:Notify', source, 'Jugador no encontrado en el servidor.', 'error')
        return
    end

    -- Grado 4 es Jefe de Taller (isboss = true)
    Target.Functions.SetJob(shopName, 4)

    local shopLabel = QBCore.Shared.Jobs[shopName] and QBCore.Shared.Jobs[shopName].label or shopName
    TriggerClientEvent('QBCore:Notify', source, string.format('Has nombrado a %s %s como JEFE de %s.', Target.PlayerData.charinfo.firstname, Target.PlayerData.charinfo.lastname, shopLabel), 'success', 6000)
    TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, string.format('👑 ¡Enhorabuena! Has sido nombrado JEFE de %s. Ya tienes acceso a la App Gestión Taller en tu móvil (F1).', shopLabel), 'success', 8000)
end, 'admin')

-- =========================================================================
-- BACKEND PARA LA APLICACIÓN MÓVIL DE GESTIÓN DE TALLER (QB-PHONE)
-- =========================================================================

-- Obtener todos los datos del taller para el móvil (Banco, Personal, Sueldos)
QBCore.Functions.CreateCallback('qb-phone:server:GetWorkshopData', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return cb(nil) end

    local job = Player.PlayerData.job
    local jobName = job.name

    if not job.isboss or (jobName ~= 'canals' and jobName ~= 'mechanic' and jobName ~= 'bennys' and job.type ~= 'mechanic') then
        return cb(nil)
    end

    -- 1. Saldo Bancario de la Empresa
    local bankBalance = 0
    if exports['qb-banking'] and exports['qb-banking'].GetAccountBalance then
        local success, result = pcall(function()
            return exports['qb-banking']:GetAccountBalance(jobName)
        end)
        if success and result then
            bankBalance = result
        end
    end

    -- 2. Lista de Empleados
    local employees = {}
    local players = MySQL.query.await("SELECT citizenid, charinfo, job FROM `players` WHERE JSON_EXTRACT(job, '$.name') = ?", { jobName })
    if players and #players > 0 then
        for _, p in ipairs(players) do
            local charInfo = json.decode(p.charinfo)
            local jobInfo = json.decode(p.job)
            local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(p.citizenid)

            local emp = {
                citizenid = p.citizenid,
                name = (charInfo.firstname or 'Desconocido') .. ' ' .. (charInfo.lastname or ''),
                grade = jobInfo.grade and jobInfo.grade.level or 0,
                gradeName = jobInfo.grade and jobInfo.grade.name or 'Aprendiz',
                salary = jobInfo.payment or (QBCore.Shared.Jobs[jobName].grades[tostring(jobInfo.grade and jobInfo.grade.level or 0)] and QBCore.Shared.Jobs[jobName].grades[tostring(jobInfo.grade and jobInfo.grade.level or 0)].payment or 50),
                isOnline = (targetPlayer ~= nil)
            }
            employees[#employees + 1] = emp
        end
    end

    -- 3. Lista de Rangos y Sueldos Configurados
    local gradesList = {}
    if QBCore.Shared.Jobs[jobName] and QBCore.Shared.Jobs[jobName].grades then
        for gradeKey, gradeData in pairs(QBCore.Shared.Jobs[jobName].grades) do
            gradesList[#gradesList + 1] = {
                grade = tonumber(gradeKey),
                name = gradeData.name,
                payment = gradeData.payment,
                isboss = gradeData.isboss or false
            }
        end
        table.sort(gradesList, function(a, b) return a.grade < b.grade end)
    end

    cb({
        jobName = jobName,
        jobLabel = job.label or shopName,
        bossName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        balance = bankBalance,
        employees = employees,
        grades = gradesList
    })
end)

-- Ingresar fondos en la cuenta del taller desde el móvil
RegisterNetEvent('qb-phone:server:WorkshopDeposit', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.job.isboss then return end
    amount = tonumber(amount)
    if not amount or amount <= 0 then return end

    local jobName = Player.PlayerData.job.name
    local removed = false
    if Player.Functions.RemoveMoney('bank', amount, 'Ingreso Taller') then
        removed = true
    elseif Player.Functions.RemoveMoney('cash', amount, 'Ingreso Taller') then
        removed = true
    end

    if removed then
        if exports['qb-banking'] and exports['qb-banking'].AddMoney then
            pcall(function()
                exports['qb-banking']:AddMoney(jobName, amount, 'Depósito móvil por ' .. Player.PlayerData.charinfo.firstname)
            end)
        end
        TriggerClientEvent('QBCore:Notify', src, string.format('Has ingresado %d€ en la cuenta del taller.', amount), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'No dispones de ese saldo en tu cuenta personal o efectivo.', 'error')
    end
end)

-- Retirar fondos de la cuenta del taller desde el móvil
RegisterNetEvent('qb-phone:server:WorkshopWithdraw', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.job.isboss then return end
    amount = tonumber(amount)
    if not amount or amount <= 0 then return end

    local jobName = Player.PlayerData.job.name
    local currentBalance = 0
    if exports['qb-banking'] and exports['qb-banking'].GetAccountBalance then
        local success, result = pcall(function()
            return exports['qb-banking']:GetAccountBalance(jobName)
        end)
        if success and result then currentBalance = result end
    end

    if currentBalance >= amount then
        if exports['qb-banking'] and exports['qb-banking'].RemoveMoney then
            pcall(function()
                exports['qb-banking']:RemoveMoney(jobName, amount, 'Retirada móvil por ' .. Player.PlayerData.charinfo.firstname)
            end)
        end
        Player.Functions.AddMoney('bank', amount, 'Retirada fondos Taller')
        TriggerClientEvent('QBCore:Notify', src, string.format('Has retirado %d€ de la cuenta del taller a tu banco.', amount), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'La cuenta del taller no tiene fondos suficientes.', 'error')
    end
end)

-- Actualizar rango de un empleado
RegisterNetEvent('qb-phone:server:WorkshopSetGrade', function(cid, newGrade)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.job.isboss then return end

    local jobName = Player.PlayerData.job.name
    newGrade = tonumber(newGrade)
    local Target = QBCore.Functions.GetPlayerByCitizenId(cid)

    local gradeName = (QBCore.Shared.Jobs[jobName] and QBCore.Shared.Jobs[jobName].grades[tostring(newGrade)]) and QBCore.Shared.Jobs[jobName].grades[tostring(newGrade)].name or 'Mecánico'

    if Target then
        Target.Functions.SetJob(jobName, newGrade)
        TriggerClientEvent('QBCore:Notify', src, 'Rango actualizado para ' .. Target.PlayerData.charinfo.firstname .. ' a ' .. gradeName, 'success')
        TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, 'Has sido actualizado al rango ' .. gradeName, 'primary')
    else
        local playerResult = MySQL.query.await("SELECT job FROM `players` WHERE `citizenid` = ?", { cid })
        if playerResult and playerResult[1] then
            local jobData = json.decode(playerResult[1].job)
            jobData.grade = {
                name = gradeName,
                level = newGrade
            }
            MySQL.update("UPDATE `players` SET `job` = ? WHERE `citizenid` = ?", { json.encode(jobData), cid })
            TriggerClientEvent('QBCore:Notify', src, 'Rango actualizado con éxito en la base de datos.', 'success')
        end
    end
end)

-- Despedir empleado desde el móvil
RegisterNetEvent('qb-phone:server:WorkshopFire', function(cid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.job.isboss then return end

    local Target = QBCore.Functions.GetPlayerByCitizenId(cid)
    if Target then
        Target.Functions.SetJob('unemployed', 0)
        TriggerClientEvent('QBCore:Notify', src, 'Empleado despedido con éxito.', 'success')
        TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, 'Has sido despedido del taller mecánico.', 'error')
    else
        local defaultJob = {
            name = 'unemployed',
            label = 'Civilian',
            payment = 10,
            onduty = true,
            isboss = false,
            grade = { name = 'Freelancer', level = 0 }
        }
        MySQL.update("UPDATE `players` SET `job` = ? WHERE `citizenid` = ?", { json.encode(defaultJob), cid })
        TriggerClientEvent('QBCore:Notify', src, 'Empleado despedido de la base de datos.', 'success')
    end
end)

-- Contratar jugador cercano
RegisterNetEvent('qb-phone:server:WorkshopHire', function(targetServerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.job.isboss then return end

    local jobName = Player.PlayerData.job.name
    local Target = QBCore.Functions.GetPlayer(tonumber(targetServerId))
    if Target then
        Target.Functions.SetJob(jobName, 0) -- Grado 0: Aprendiz
        TriggerClientEvent('QBCore:Notify', src, 'Has contratado a ' .. Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname .. ' como Aprendiz.', 'success')
        TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, '¡Has sido contratado en ' .. Player.PlayerData.job.label .. ' como Aprendiz!', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'El ciudadano no se encuentra en línea.', 'error')
    end
end)

-- Modificar sueldo de un rango
RegisterNetEvent('qb-phone:server:WorkshopUpdateSalary', function(grade, newSalary)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.job.isboss then return end

    local jobName = Player.PlayerData.job.name
    grade = tostring(grade)
    newSalary = tonumber(newSalary)

    if not newSalary or newSalary < 0 or newSalary > 5000 then
        TriggerClientEvent('QBCore:Notify', src, 'Sueldo fuera de rango permitido (0 - 5000€).', 'error')
        return
    end

    if QBCore.Shared.Jobs[jobName] and QBCore.Shared.Jobs[jobName].grades[grade] then
        QBCore.Shared.Jobs[jobName].grades[grade].payment = newSalary
        TriggerClientEvent('QBCore:Notify', src, string.format('Sueldo de %s actualizado a %d€.', QBCore.Shared.Jobs[jobName].grades[grade].name, newSalary), 'success')
    end
end)
