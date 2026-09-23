-- =========================================================================
-- SPAIN ROL - SERVIDOR: 3 COMPRA-VENTAS CON STOCK DINÁMICO REAL
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()
local transactionHistory = {}

-- Inicializar historial en memoria por concesionario
for key, _ in pairs(Config.Dealerships) do
    transactionHistory[key] = {
        {
            title = "Apertura de Terminal",
            date = "Hoy",
            details = "Sistema de Compra-Venta activado",
            amount = 0,
            type = "in"
        }
    }
end

-- Inicialización de la tabla de Stock Dinámico en Base de Datos
CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `dealership_stock` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `dealership` varchar(50) NOT NULL,
            `vehicle` varchar(50) NOT NULL,
            `label` varchar(50) NOT NULL,
            `brand` varchar(50) DEFAULT 'Ocasión',
            `category` varchar(50) DEFAULT 'sports',
            `plate` varchar(15) NOT NULL,
            `price` int(11) NOT NULL,
            `mods` longtext DEFAULT '{}',
            `seller_citizenid` varchar(50) DEFAULT NULL,
            `seller_name` varchar(100) DEFAULT 'Particular',
            `date_added` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`),
            KEY `dealership` (`dealership`),
            KEY `plate` (`plate`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Cargar vehículos de ocasión iniciales si el stock está vacío
    for dealerKey, starterList in pairs(Config.StarterStock) do
        local count = MySQL.scalar.await('SELECT COUNT(*) FROM dealership_stock WHERE dealership = ?', { dealerKey }) or 0
        if count == 0 then
            for _, item in ipairs(starterList) do
                MySQL.insert('INSERT INTO dealership_stock (dealership, vehicle, label, brand, category, plate, price, mods, seller_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
                    dealerKey,
                    item.model,
                    item.label,
                    item.brand,
                    item.category,
                    item.plate,
                    item.price,
                    '{}',
                    item.seller
                })
            end
            print('^2[Spain Dealerships]^7 Stock inicial generado con exito para: ' .. dealerKey)
        end
    end
end)

-- Obtener saldo bancario de sociedad de forma segura
local function GetSocietyBalance(societyAccount)
    local balance = 150000 -- Fondo inicial empresarial garantizado
    local success, bankBalance = pcall(function()
        if exports['qb-banking'] and exports['qb-banking'].GetAccountBalance then
            return exports['qb-banking']:GetAccountBalance(societyAccount)
        end
        return nil
    end)

    if success and bankBalance and type(bankBalance) == 'number' then
        return bankBalance
    end
    return balance
end

-- Modificar saldo de sociedad
local function ModifySocietyMoney(societyAccount, amount, isAdd)
    pcall(function()
        if exports['qb-banking'] then
            if isAdd and exports['qb-banking'].AddMoney then
                exports['qb-banking']:AddMoney(societyAccount, amount)
            elseif not isAdd and exports['qb-banking'].RemoveMoney then
                exports['qb-banking']:RemoveMoney(societyAccount, amount)
            end
        end
    end)
end

-- Callback principal para abrir la tablet con Stock Real
QBCore.Functions.CreateCallback('spain_dealerships:server:getTabletData', function(source, cb, dealerKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return cb(nil) end

    local dealer = Config.Dealerships[dealerKey]
    if not dealer then return cb(nil) end

    local playerJob = Player.PlayerData.job
    local isBoss = (playerJob and playerJob.name == dealer.job and playerJob.isboss == true)
    local gradeName = (playerJob and playerJob.grade and playerJob.grade.name) or "Cliente"

    -- 1. Balance bancario de la empresa
    local societyBalance = GetSocietyBalance(dealer.societyAccount)

    -- 2. Catálogo REAL de vehículos comprados en stock por la compra-venta
    local stockRaw = MySQL.query.await('SELECT * FROM dealership_stock WHERE dealership = ? ORDER BY id DESC', { dealerKey }) or {}
    local dynamicCatalog = {}

    for _, s in ipairs(stockRaw) do
        local meta = GetVehicleMetadata(s.vehicle)
        dynamicCatalog[#dynamicCatalog + 1] = {
            stockId = s.id,
            model = s.vehicle,
            label = s.label or meta.label,
            brand = s.brand or meta.brand,
            category = s.category or meta.category,
            plate = s.plate,
            price = s.price,
            sellerName = s.seller_name or 'Particular',
            speed = meta.speed,
            accel = meta.accel,
            brakes = meta.brakes,
            handling = meta.handling,
            image = meta.image
        }
    end

    -- 3. Vehículos en propiedad del jugador listos para tasar y vender
    local vehiclesRaw = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', { Player.PlayerData.citizenid }) or {}
    local ownedVehicles = {}

    for _, v in ipairs(vehiclesRaw) do
        local meta = GetVehicleMetadata(v.vehicle)
        local resellValue = math.floor(meta.basePrice * Config.ResellMultiplier)

        ownedVehicles[#ownedVehicles + 1] = {
            plate = v.plate,
            vehicle = v.vehicle,
            label = meta.label,
            garage = v.garage or Config.DefaultGarage,
            state = v.state or 1,
            resellPrice = resellValue
        }
    end

    -- 4. Plantilla de empleados (si tiene cargo en la empresa)
    local employees = {}
    if isBoss or (playerJob and playerJob.name == dealer.job) then
        local playersDb = MySQL.query.await("SELECT * FROM `players` WHERE `job` LIKE '%" .. dealer.job .. "%'", {}) or {}
        for _, pData in ipairs(playersDb) do
            local jobInfo = json.decode(pData.job)
            local charInfo = json.decode(pData.charinfo)
            local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(pData.citizenid)
            local isOnline = targetPlayer ~= nil

            employees[#employees + 1] = {
                citizenid = pData.citizenid,
                name = (charInfo.firstname or 'Empleado') .. ' ' .. (charInfo.lastname or ''),
                grade = jobInfo.grade.level or 0,
                gradeName = jobInfo.grade.name or 'En Prácticas',
                payment = jobInfo.payment or 55,
                isOnline = isOnline
            }
        end
        table.sort(employees, function(a, b) return a.grade > b.grade end)
    end

    cb({
        user = {
            name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            bank = Player.PlayerData.money.bank or 0,
            job = playerJob.name,
            grade = playerJob.grade.level or 0,
            gradeName = gradeName,
            isBoss = isBoss
        },
        societyBalance = societyBalance,
        catalog = dynamicCatalog, -- Stock real en base de datos
        ownedVehicles = ownedVehicles,
        employees = employees,
        history = transactionHistory[dealerKey] or {}
    })
end)

-- --------------------------------------------------------------------------
-- EVENTO: COMPRA DE VEHÍCULO DEL STOCK DE OCASIÓN
-- --------------------------------------------------------------------------
RegisterNetEvent('spain_dealerships:server:buyVehicle', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data or not data.stockId then return end

    local dealer = Config.Dealerships[data.dealershipId]
    if not dealer then return end

    -- Obtener el coche exacto del stock en base de datos
    local stockItem = MySQL.single.await('SELECT * FROM dealership_stock WHERE id = ? AND dealership = ?', {
        tonumber(data.stockId),
        data.dealershipId
    })

    if not stockItem then
        TriggerClientEvent('QBCore:Notify', src, "Este vehículo ya ha sido vendido a otro cliente.", "error")
        return
    end

    local price = stockItem.price
    local userBank = Player.PlayerData.money.bank or 0

    -- Comprobar fondos en la cuenta del banco
    if userBank < price then
        TriggerClientEvent('QBCore:Notify', src, "Saldo insuficiente en tu cuenta bancaria. Necesitas " .. price .. "€.", "error")
        return
    end

    -- 1. Cobrar al comprador desde su cuenta bancaria
    Player.Functions.RemoveMoney('bank', price, 'Compra de vehículo de ocasión: ' .. stockItem.label)

    -- 2. Ingresar el importe en la cuenta bancaria de la sociedad
    ModifySocietyMoney(dealer.societyAccount, price, true)

    -- 3. Eliminar del stock del compra-venta
    MySQL.query.await('DELETE FROM dealership_stock WHERE id = ?', { stockItem.id })

    -- 4. Registrar en player_vehicles a nombre del comprador (con sus mods/tuning intactos)
    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        Player.PlayerData.license,
        Player.PlayerData.citizenid,
        stockItem.vehicle,
        GetHashKey(stockItem.vehicle),
        stockItem.mods or '{}',
        stockItem.plate,
        Config.DefaultGarage,
        1 -- 1 = Guardado en garaje
    })

    -- 5. Registrar en historial
    if not transactionHistory[data.dealershipId] then transactionHistory[data.dealershipId] = {} end
    table.insert(transactionHistory[data.dealershipId], 1, {
        title = "Venta: " .. stockItem.label,
        date = os.date("%H:%M"),
        details = "Matrícula: " .. stockItem.plate .. " | Comprador: " .. Player.PlayerData.charinfo.firstname,
        amount = price,
        type = "in"
    })

    TriggerClientEvent('QBCore:Notify', src, "🎉 ¡Enhorabuena! Has adquirido el " .. stockItem.label .. " (Matrícula: " .. stockItem.plate .. "). Ya está listo en tu Garaje Central (Pillbox).", "success", 8000)

    -- Refrescar datos en la tablet
    TriggerClientEvent('spain_dealerships:client:updateBalances', src, {
        userBank = Player.PlayerData.money.bank,
        societyBalance = GetSocietyBalance(dealer.societyAccount)
    })
end)

-- --------------------------------------------------------------------------
-- EVENTO: VENTA DE VEHÍCULO AL CONCESIONARIO (INGRESO EN STOCK REAL)
-- --------------------------------------------------------------------------
RegisterNetEvent('spain_dealerships:server:sellVehicle', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data or not data.plate then return end

    local dealer = Config.Dealerships[data.dealershipId]
    if not dealer then return end

    -- Verificar que el vehículo es propiedad legítima del jugador
    local row = MySQL.single.await('SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?', {
        data.plate,
        Player.PlayerData.citizenid
    })

    if not row then
        TriggerClientEvent('QBCore:Notify', src, "Este vehículo no te pertenece o no figura en tu garaje.", "error")
        return
    end

    -- Calcular valor de tasación oficial y precio de reventa
    local meta = GetVehicleMetadata(row.vehicle)
    local payout = math.floor(meta.basePrice * Config.ResellMultiplier)
    local resellPrice = math.floor(payout * Config.ResellProfitMargin)
    local sellerFullName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

    -- 1. Abonar el importe de tasación directamente en la cuenta bancaria del jugador
    Player.Functions.AddMoney('bank', payout, 'Venta de vehículo a compra-venta: ' .. data.plate)

    -- 2. Retirar fondos de la sociedad
    ModifySocietyMoney(dealer.societyAccount, payout, false)

    -- 3. Eliminar de la propiedad del jugador en la base de datos
    MySQL.query.await('DELETE FROM player_vehicles WHERE plate = ? AND citizenid = ?', {
        data.plate,
        Player.PlayerData.citizenid
    })

    -- 4. INSERTAR EL VEHÍCULO REAL EN EL STOCK DEL COMPRA-VENTA
    MySQL.insert('INSERT INTO dealership_stock (dealership, vehicle, label, brand, category, plate, price, mods, seller_citizenid, seller_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        data.dealershipId,
        row.vehicle,
        meta.label,
        meta.brand,
        meta.category,
        row.plate,
        resellPrice,
        row.mods or '{}',
        Player.PlayerData.citizenid,
        sellerFullName
    })

    -- 5. Registrar en historial
    if not transactionHistory[data.dealershipId] then transactionHistory[data.dealershipId] = {} end
    table.insert(transactionHistory[data.dealershipId], 1, {
        title = "Compra: " .. meta.label,
        date = os.date("%H:%M"),
        details = "Matrícula: " .. data.plate .. " | Vendedor: " .. sellerFullName,
        amount = payout,
        type = "out"
    })

    TriggerClientEvent('QBCore:Notify', src, "✅ Has vendido tu " .. meta.label .. " (" .. data.plate .. ") a la compra-venta. Se han ingresado " .. payout .. "€ en tu cuenta bancaria y el coche ya está en el catálogo de ocasión.", "success", 8000)

    -- Refrescar datos en la tablet
    TriggerClientEvent('spain_dealerships:client:updateBalances', src, {
        userBank = Player.PlayerData.money.bank,
        societyBalance = GetSocietyBalance(dealer.societyAccount)
    })
end)

-- --------------------------------------------------------------------------
-- GESTIÓN BANCARIA DE SOCIEDAD
-- --------------------------------------------------------------------------
RegisterNetEvent('spain_dealerships:server:societyDeposit', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data or not data.amount then return end

    local dealer = Config.Dealerships[data.dealershipId]
    if not dealer then return end

    if not Player.PlayerData.job or Player.PlayerData.job.name ~= dealer.job or not Player.PlayerData.job.isboss then
        TriggerClientEvent('QBCore:Notify', src, "Solo la gerencia o propietarios pueden realizar ingresos en la sociedad.", "error")
        return
    end

    local amount = tonumber(data.amount)
    if not amount or amount <= 0 then return end

    if Player.PlayerData.money.bank < amount then
        TriggerClientEvent('QBCore:Notify', src, "No tienes suficiente saldo bancario personal.", "error")
        return
    end

    Player.Functions.RemoveMoney('bank', amount, 'Ingreso en cuenta sociedad ' .. dealer.name)
    ModifySocietyMoney(dealer.societyAccount, amount, true)

    TriggerClientEvent('QBCore:Notify', src, "Has ingresado " .. amount .. "€ en los fondos de la empresa.", "success")
    TriggerClientEvent('spain_dealerships:client:updateBalances', src, {
        userBank = Player.PlayerData.money.bank,
        societyBalance = GetSocietyBalance(dealer.societyAccount)
    })
end)

RegisterNetEvent('spain_dealerships:server:societyWithdraw', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data or not data.amount then return end

    local dealer = Config.Dealerships[data.dealershipId]
    if not dealer then return end

    if not Player.PlayerData.job or Player.PlayerData.job.name ~= dealer.job or not Player.PlayerData.job.isboss then
        TriggerClientEvent('QBCore:Notify', src, "Solo la gerencia o propietarios pueden retirar fondos de la sociedad.", "error")
        return
    end

    local amount = tonumber(data.amount)
    if not amount or amount <= 0 then return end

    local currentBalance = GetSocietyBalance(dealer.societyAccount)
    if currentBalance < amount then
        TriggerClientEvent('QBCore:Notify', src, "La cuenta de la empresa no dispone de fondos suficientes.", "error")
        return
    end

    ModifySocietyMoney(dealer.societyAccount, amount, false)
    Player.Functions.AddMoney('bank', amount, 'Retirada de beneficios ' .. dealer.name)

    TriggerClientEvent('QBCore:Notify', src, "Has retirado " .. amount .. "€ de la cuenta empresarial a tu cuenta personal.", "success")
    TriggerClientEvent('spain_dealerships:client:updateBalances', src, {
        userBank = Player.PlayerData.money.bank,
        societyBalance = GetSocietyBalance(dealer.societyAccount)
    })
end)

-- --------------------------------------------------------------------------
-- JERARQUÍA: CONTRATAR, ASCENDER/DEGRADAR Y DESPEDIR
-- --------------------------------------------------------------------------
RegisterNetEvent('spain_dealerships:server:setEmployeeGrade', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data or not data.citizenid then return end

    local dealer = Config.Dealerships[data.dealershipId]
    if not dealer or not Player.PlayerData.job or Player.PlayerData.job.name ~= dealer.job or not Player.PlayerData.job.isboss then
        return
    end

    local Target = QBCore.Functions.GetPlayerByCitizenId(data.citizenid) or QBCore.Functions.GetOfflinePlayerByCitizenId(data.citizenid)
    if Target then
        local newGrade = tonumber(data.grade)
        if newGrade and newGrade >= 0 and newGrade <= 4 then
            Target.Functions.SetJob(dealer.job, newGrade)
            Target.Functions.Save()
            TriggerClientEvent('QBCore:Notify', src, "Rango de empleado actualizado correctamente a nivel " .. newGrade, "success")
            if Target.PlayerData.source then
                TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, "Tu puesto en " .. dealer.name .. " ha cambiado a nivel " .. newGrade, "primary")
            end
        end
    end
end)

RegisterNetEvent('spain_dealerships:server:fireEmployee', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data or not data.citizenid then return end

    local dealer = Config.Dealerships[data.dealershipId]
    if not dealer or not Player.PlayerData.job or Player.PlayerData.job.name ~= dealer.job or not Player.PlayerData.job.isboss then
        return
    end

    if data.citizenid == Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', src, "No puedes despedirte a ti mismo siendo el dueño.", "error")
        return
    end

    local Target = QBCore.Functions.GetPlayerByCitizenId(data.citizenid) or QBCore.Functions.GetOfflinePlayerByCitizenId(data.citizenid)
    if Target then
        Target.Functions.SetJob('unemployed', 0)
        Target.Functions.Save()
        TriggerClientEvent('QBCore:Notify', src, "Empleado despedido de la empresa.", "success")
        if Target.PlayerData.source then
            TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, "Has finalizado tu relación laboral con " .. dealer.name, "error")
        end
    end
end)

RegisterNetEvent('spain_dealerships:server:hirePlayer', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data or not data.targetId then return end

    local dealer = Config.Dealerships[data.dealershipId]
    if not dealer or not Player.PlayerData.job or Player.PlayerData.job.name ~= dealer.job or not Player.PlayerData.job.isboss then
        return
    end

    local Target = QBCore.Functions.GetPlayer(tonumber(data.targetId))
    if Target then
        Target.Functions.SetJob(dealer.job, 0) -- Rango 0: En Prácticas
        Target.Functions.Save()
        TriggerClientEvent('QBCore:Notify', src, "Has contratado a " .. Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname .. " como Empleado en Prácticas.", "success")
        TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, "¡Has sido contratado en " .. dealer.name .. "! Accede a la tablet con [E] para empezar.", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "El ciudadano ya no está en la zona.", "error")
    end
end)

-- --------------------------------------------------------------------------
-- COMANDOS PARA ADMINISTRACIÓN (ASIGNAR DUEÑO / RANGO)
-- --------------------------------------------------------------------------

local function GiveDealershipJob(src, targetId, sedeKey, gradeLevel)
    local targetPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))
    if not targetPlayer then
        if src > 0 then
            TriggerClientEvent('QBCore:Notify', src, "ID de jugador no encontrada o desconectado.", "error")
        else
            print("[ERROR] Jugador no encontrado.")
        end
        return
    end

    local sedeClean = string.lower(tostring(sedeKey or 'sur'))
    local jobName = nil

    if sedeClean == 'sur' or sedeClean == 'dealership_sur' or sedeClean == '1' then
        jobName = 'dealership_sur'
    elseif sedeClean == 'sandy' or sedeClean == 'dealership_sandy' or sedeClean == '2' then
        jobName = 'dealership_sandy'
    elseif sedeClean == 'paleto' or sedeClean == 'dealership_paleto' or sedeClean == '3' then
        jobName = 'dealership_paleto'
    end

    if not jobName or not Config.Dealerships[jobName] then
        if src > 0 then
            TriggerClientEvent('QBCore:Notify', src, "Sede inválida. Usa: sur, sandy o paleto", "error")
        else
            print("[ERROR] Sede inválida. Opciones: sur | sandy | paleto")
        end
        return
    end

    local grade = tonumber(gradeLevel)
    if not grade or grade < 0 or grade > 4 then
        grade = 4 -- Por defecto asigna DUEÑO / PROPIETARIO
    end

    local dealer = Config.Dealerships[jobName]
    local gradeNames = {
        [0] = 'En Prácticas',
        [1] = 'Comercial Junior',
        [2] = 'Vendedor Senior',
        [3] = 'Gerente de Ventas',
        [4] = 'Dueño / Propietario'
    }

    targetPlayer.Functions.SetJob(jobName, grade)
    targetPlayer.Functions.Save()

    local targetName = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname
    local msgAdmin = string.format("✅ Asignado %s a %s (%s) como %s (Grado %d)", dealer.name, targetName, targetId, gradeNames[grade], grade)
    local msgPlayer = string.format("👔 Se te ha otorgado el cargo de %s en %s.", gradeNames[grade], dealer.name)

    if src > 0 then
        TriggerClientEvent('QBCore:Notify', src, msgAdmin, "success", 7000)
    else
        print("[ADMIN] " .. msgAdmin)
    end
    TriggerClientEvent('QBCore:Notify', targetPlayer.PlayerData.source, msgPlayer, "success", 8000)
end

-- Comando: /darcompraventa [id] [sur/sandy/paleto] [rango 0-4]
QBCore.Commands.Add('darcompraventa', 'Asignar puesto/propiedad de un Compra-Venta (Solo Administradores)', {
    { name = 'id', help = 'ID del jugador en el servidor' },
    { name = 'sede', help = 'sur | sandy | paleto' },
    { name = 'rango', help = '0: Prácticas | 1: Junior | 2: Senior | 3: Gerente | 4: Dueño (Opcional, defecto 4)' }
}, false, function(source, args)
    if not args[1] or not args[2] then
        TriggerClientEvent('QBCore:Notify', source, "Uso: /darcompraventa [id] [sur/sandy/paleto] [rango: 0-4]", "error")
        return
    end
    GiveDealershipJob(source, args[1], args[2], args[3])
end, 'admin')

-- Alias: /setdealer
QBCore.Commands.Add('setdealer', 'Asignar puesto/propiedad de un Compra-Venta (Solo Administradores)', {
    { name = 'id', help = 'ID del jugador en el servidor' },
    { name = 'sede', help = 'sur | sandy | paleto' },
    { name = 'rango', help = '0: Prácticas | 1: Junior | 2: Senior | 3: Gerente | 4: Dueño (Opcional, defecto 4)' }
}, false, function(source, args)
    if not args[1] or not args[2] then
        TriggerClientEvent('QBCore:Notify', source, "Uso: /setdealer [id] [sur/sandy/paleto] [rango: 0-4]", "error")
        return
    end
    GiveDealershipJob(source, args[1], args[2], args[3])
end, 'admin')

-- Comando: /quitarcompraventa [id]
QBCore.Commands.Add('quitarcompraventa', 'Despedir y retirar trabajo de Compra-Venta a un jugador (Solo Administradores)', {
    { name = 'id', help = 'ID del jugador en el servidor' }
}, false, function(source, args)
    if not args[1] then
        TriggerClientEvent('QBCore:Notify', source, "Uso: /quitarcompraventa [id]", "error")
        return
    end
    local targetPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', source, "Jugador no encontrado.", "error")
        return
    end

    targetPlayer.Functions.SetJob('unemployed', 0)
    targetPlayer.Functions.Save()
    TriggerClientEvent('QBCore:Notify', source, "Se ha retirado el trabajo de compra-venta al jugador.", "success")
    TriggerClientEvent('QBCore:Notify', targetPlayer.PlayerData.source, "La administración ha retirado tu cargo de compra-venta.", "error")
end, 'admin')
