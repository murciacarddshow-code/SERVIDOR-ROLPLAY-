-- =========================================================================
-- SPAIN ROL - SERVIDOR: 3 COMPRA-VENTAS, BANCO Y GARAJES
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

-- Generador de matrículas únicas
local function GenerateUniquePlate()
    local plate = nil
    local isUnique = false

    while not isUnique do
        local letters = ""
        local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for _ = 1, 4 do
            local rand = math.random(1, #chars)
            letters = letters .. string.sub(chars, rand, rand)
        end
        local numbers = string.format("%04d", math.random(1000, 9999))
        plate = string.sub(letters, 1, 4) .. numbers -- 8 caracteres: ej. "SPRN1234"

        local result = MySQL.scalar.await('SELECT 1 FROM player_vehicles WHERE plate = ?', { plate })
        if not result then
            isUnique = true
        end
    end

    return plate
end

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

-- Callback principal para abrir la tablet
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

    -- 2. Vehículos en propiedad del jugador
    local vehiclesRaw = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', { Player.PlayerData.citizenid }) or {}
    local ownedVehicles = {}

    for _, v in ipairs(vehiclesRaw) do
        local basePrice = 25000
        local friendlyLabel = v.vehicle

        -- Buscar en el catálogo para fijar el precio real y etiqueta
        for _, catVeh in ipairs(Config.Vehicles) do
            if string.lower(catVeh.model) == string.lower(v.vehicle) then
                basePrice = catVeh.price
                friendlyLabel = catVeh.label
                break
            end
        end

        local resellValue = math.floor(basePrice * Config.ResellMultiplier)

        ownedVehicles[#ownedVehicles + 1] = {
            plate = v.plate,
            vehicle = v.vehicle,
            label = friendlyLabel,
            garage = v.garage or Config.DefaultGarage,
            state = v.state or 1,
            resellPrice = resellValue
        }
    end

    -- 3. Plantilla de empleados (si tiene cargo en la empresa)
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
        ownedVehicles = ownedVehicles,
        employees = employees,
        history = transactionHistory[dealerKey] or {}
    })
end)

-- --------------------------------------------------------------------------
-- EVENTO: COMPRA DE VEHÍCULO
-- --------------------------------------------------------------------------
RegisterNetEvent('spain_dealerships:server:buyVehicle', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data or not data.model then return end

    local dealer = Config.Dealerships[data.dealershipId]
    if not dealer then return end

    -- Validar vehículo en catálogo
    local catalogVeh = nil
    for _, v in ipairs(Config.Vehicles) do
        if v.model == data.model then
            catalogVeh = v
            break
        end
    end
    if not catalogVeh then
        TriggerClientEvent('QBCore:Notify', src, "Vehículo no disponible en el stock oficial.", "error")
        return
    end

    local price = catalogVeh.price
    local userBank = Player.PlayerData.money.bank or 0

    -- Comprobar fondos en la cuenta del banco
    if userBank < price then
        TriggerClientEvent('QBCore:Notify', src, "Saldo insuficiente en tu cuenta bancaria. Necesitas " .. price .. "€.", "error")
        return
    end

    -- 1. Cobrar al comprador desde su cuenta bancaria
    Player.Functions.RemoveMoney('bank', price, 'Compra de vehículo de ocasión: ' .. catalogVeh.label)

    -- 2. Ingresar el pago en la cuenta bancaria de la sociedad
    ModifySocietyMoney(dealer.societyAccount, price, true)

    -- 3. Generar matrícula y registrar en la base de datos
    local newPlate = GenerateUniquePlate()
    local targetGarage = Config.DefaultGarage

    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        Player.PlayerData.license,
        Player.PlayerData.citizenid,
        catalogVeh.model,
        GetHashKey(catalogVeh.model),
        '{}',
        newPlate,
        targetGarage,
        1 -- 1 = Guardado en garaje
    })

    -- 4. Registrar en historial
    if not transactionHistory[data.dealershipId] then transactionHistory[data.dealershipId] = {} end
    table.insert(transactionHistory[data.dealershipId], 1, {
        title = "Venta: " .. catalogVeh.label,
        date = os.date("%H:%M"),
        details = "Matrícula: " .. newPlate .. " | Comprador: " .. Player.PlayerData.charinfo.firstname,
        amount = price,
        type = "in"
    })

    TriggerClientEvent('QBCore:Notify', src, "🎉 ¡Enhorabuena! Has comprado un " .. catalogVeh.label .. " (Matrícula: " .. newPlate .. "). Ya está disponible en tu Garaje Central (Pillbox).", "success", 8000)

    -- Refrescar datos en la tablet
    TriggerClientEvent('spain_dealerships:client:updateBalances', src, {
        userBank = Player.PlayerData.money.bank,
        societyBalance = GetSocietyBalance(dealer.societyAccount)
    })
end)

-- --------------------------------------------------------------------------
-- EVENTO: VENTA DE VEHÍCULO AL CONCESIONARIO
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

    -- Calcular valor de tasación
    local basePrice = 25000
    local vehicleLabel = row.vehicle
    for _, v in ipairs(Config.Vehicles) do
        if string.lower(v.model) == string.lower(row.vehicle) then
            basePrice = v.price
            vehicleLabel = v.label
            break
        end
    end
    local payout = math.floor(basePrice * Config.ResellMultiplier)

    -- 1. Abonar el importe directamente en la cuenta bancaria del jugador
    Player.Functions.AddMoney('bank', payout, 'Venta de vehículo a compra-venta: ' .. data.plate)

    -- 2. Retirar fondos de la sociedad
    ModifySocietyMoney(dealer.societyAccount, payout, false)

    -- 3. Eliminar de la propiedad del jugador en la base de datos
    MySQL.query.await('DELETE FROM player_vehicles WHERE plate = ? AND citizenid = ?', {
        data.plate,
        Player.PlayerData.citizenid
    })

    -- 4. Registrar en historial
    if not transactionHistory[data.dealershipId] then transactionHistory[data.dealershipId] = {} end
    table.insert(transactionHistory[data.dealershipId], 1, {
        title = "Compra: " .. vehicleLabel,
        date = os.date("%H:%M"),
        details = "Matrícula: " .. data.plate .. " | Vendedor: " .. Player.PlayerData.charinfo.firstname,
        amount = payout,
        type = "out"
    })

    TriggerClientEvent('QBCore:Notify', src, "✅ Has vendido tu vehículo " .. vehicleLabel .. " (" .. data.plate .. "). Se han ingresado " .. payout .. "€ directamente en tu cuenta bancaria.", "success", 7000)

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
        TriggerClientEvent('QBCore:Notify', src, "Solo la gerencia o propietarios pueden realizar transferencias a la sociedad.", "error")
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
