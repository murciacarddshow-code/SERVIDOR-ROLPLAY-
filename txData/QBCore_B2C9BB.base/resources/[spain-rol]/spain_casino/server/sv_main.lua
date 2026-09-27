local QBCore = exports['qb-core']:GetCoreObject()
local CurrentPodiumVehicle = Config.LuckyWheel.defaultPodiumVehicle
local CurrentJackpot = Config.Slots.initialJackpot

-- ============================================================================
-- INICIALIZACIÓN DE BASE DE DATOS
-- ============================================================================

CreateThread(function()
    -- Tabla para el cooldown de la ruleta diaria
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `casino_luckywheel` (
            `citizenid` VARCHAR(50) NOT NULL,
            `last_spin` BIGINT NOT NULL DEFAULT 0,
            `total_spins` INT NOT NULL DEFAULT 0,
            PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Tabla de membresías VIP
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `casino_memberships` (
            `citizenid` VARCHAR(50) NOT NULL,
            `is_vip` TINYINT(1) NOT NULL DEFAULT 0,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Tabla de configuración persistente (coche del podio, etc.)
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `casino_config` (
            `key_name` VARCHAR(50) NOT NULL,
            `value` VARCHAR(255) NOT NULL,
            PRIMARY KEY (`key_name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Tabla de bote acumulado del Jackpot
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `casino_jackpot` (
            `id` INT NOT NULL DEFAULT 1,
            `amount` INT NOT NULL DEFAULT 150000,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Cargar vehículo del podio configurado
    local configVeh = MySQL.single.await('SELECT value FROM casino_config WHERE key_name = ?', { 'podium_vehicle' })
    if configVeh and configVeh.value and configVeh.value ~= '' then
        CurrentPodiumVehicle = tostring(configVeh.value):lower()
    else
        MySQL.query.await('INSERT INTO casino_config (key_name, value) VALUES (?, ?)', { 'podium_vehicle', CurrentPodiumVehicle })
    end
    print('^2[Diamond Casino]^7 Vehiculo del podio activo: ^3' .. string.upper(CurrentPodiumVehicle) .. '^7')

    -- Cargar bote del Jackpot
    local jackpotData = MySQL.single.await('SELECT amount FROM casino_jackpot WHERE id = 1')
    if jackpotData and jackpotData.amount then
        CurrentJackpot = tonumber(jackpotData.amount)
    else
        MySQL.query.await('INSERT INTO casino_jackpot (id, amount) VALUES (1, ?)', { CurrentJackpot })
    end
    print('^2[Diamond Casino]^7 Bote Jackpot inicial: ^3' .. CurrentJackpot .. ' Fichas^7')
end)

-- ============================================================================
-- COMANDO STAFF: /setcasinoveh [modelo]
-- ============================================================================

QBCore.Commands.Add('setcasinoveh', 'Establecer el vehículo del podio del Casino (Admin)', { { name = 'modelo', help = 'Nombre de spawn del coche (ej: adder, blista, reaper)' } }, true, function(source, args)
    local model = tostring(args[1]):lower()
    if not model or model == '' then
        TriggerClientEvent('QBCore:Notify', source, 'Debes ingresar un nombre de modelo válido (ej: /setcasinoveh adder)', 'error')
        return
    end

    CurrentPodiumVehicle = model
    MySQL.query('INSERT INTO casino_config (key_name, value) VALUES ("podium_vehicle", ?) ON DUPLICATE KEY UPDATE value = ?', { model, model })
    
    -- Sincronizar podio en tiempo real con todos los jugadores conectados
    TriggerClientEvent('spain_casino:client:updatePodiumVehicle', -1, model)
    TriggerClientEvent('QBCore:Notify', source, 'Vehículo del podio del Casino actualizado a: ' .. string.upper(model), 'success', 8000)

    -- Anuncio elegante en el chat
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 215, 0 },
        multiline = true,
        args = { '🎰 DIAMOND CASINO', '¡El vehículo de exhibición del podio ha cambiado a un flamante ' .. string.upper(model) .. '! ¡Ven a la Ruleta Diaria a ganártelo!' }
    })
end, 'admin')

-- ============================================================================
-- CALLBACKS Y UTILIDADES GENERALES
-- ============================================================================

function IsPlayerVip(citizenid)
    local result = MySQL.single.await('SELECT is_vip FROM casino_memberships WHERE citizenid = ?', { citizenid })
    if result and tonumber(result.is_vip) == 1 then
        return true
    end
    return false
end

-- Obtener estado global del jugador al abrir cualquier interfaz del casino
QBCore.Functions.CreateCallback('spain_casino:server:getPlayerCasinoData', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local cid = Player.PlayerData.citizenid
    local cash = Player.PlayerData.money.cash or 0
    local bank = Player.PlayerData.money.bank or 0
    local chipItem = Player.Functions.GetItemByName(Config.ChipsItem)
    local chips = chipItem and chipItem.amount or 0
    local isVip = IsPlayerVip(cid) or (Player.Functions.GetItemByName(Config.VipItem) ~= nil)

    -- Cooldown ruleta diaria
    local wheelData = MySQL.single.await('SELECT last_spin FROM casino_luckywheel WHERE citizenid = ?', { cid })
    local now = os.time()
    local lastSpin = wheelData and tonumber(wheelData.last_spin) or 0
    local remainingSeconds = math.max(0, (lastSpin + Config.LuckyWheel.cooldown) - now)
    local canSpinWheel = (remainingSeconds <= 0)

    cb({
        cash = cash,
        bank = bank,
        chips = chips,
        isVip = isVip,
        canSpinWheel = canSpinWheel,
        wheelRemaining = remainingSeconds,
        podiumVehicle = CurrentPodiumVehicle,
        jackpot = CurrentJackpot
    })
end)

-- Obtener modelo del podio para sincronización
QBCore.Functions.CreateCallback('spain_casino:server:getPodiumVehicle', function(source, cb)
    cb(CurrentPodiumVehicle)
end)

-- ============================================================================
-- CAJERO: COMPRA, CANJE DE FICHAS Y PASE VIP (50.000 €)
-- ============================================================================

-- Comprar fichas con efectivo o banco
RegisterNetEvent('spain_casino:server:buyChips', function(amount, payMethod)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Cantidad inválida de fichas', 'error')
        return
    end

    payMethod = (payMethod == 'bank') and 'bank' or 'cash'
    local cost = amount * Config.ChipRate

    local playerMoney = Player.PlayerData.money[payMethod] or 0
    if playerMoney < cost then
        TriggerClientEvent('QBCore:Notify', src, 'No tienes suficiente dinero en ' .. (payMethod == 'bank' and 'el banco' or 'efectivo') .. ' para comprar ' .. amount .. ' fichas.', 'error')
        return
    end

    if Player.Functions.RemoveMoney(payMethod, cost, 'casino-buy-chips') then
        Player.Functions.AddItem(Config.ChipsItem, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ChipsItem], 'add')
        TriggerClientEvent('QBCore:Notify', src, 'Has comprado ' .. amount .. ' Fichas de Casino por ' .. cost .. ' €.', 'success')
        TriggerClientEvent('spain_casino:client:refreshCasinoUI', src)
    end
end)

-- Canjear fichas a dinero (efectivo o banco)
RegisterNetEvent('spain_casino:server:sellChips', function(amount, payMethod)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Cantidad inválida de fichas a canjear', 'error')
        return
    end

    payMethod = (payMethod == 'bank') and 'bank' or 'cash'
    local chipItem = Player.Functions.GetItemByName(Config.ChipsItem)
    local currentChips = chipItem and chipItem.amount or 0

    if currentChips < amount then
        TriggerClientEvent('QBCore:Notify', src, 'No tienes suficientes fichas para canjear esa cantidad. (Tienes: ' .. currentChips .. ')', 'error')
        return
    end

    local moneyGain = amount * Config.ChipRate
    if Player.Functions.RemoveItem(Config.ChipsItem, amount) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ChipsItem], 'remove')
        Player.Functions.AddMoney(payMethod, moneyGain, 'casino-sell-chips')
        TriggerClientEvent('QBCore:Notify', src, 'Has canjeado ' .. amount .. ' Fichas por ' .. moneyGain .. ' € en ' .. (payMethod == 'bank' and 'tu cuenta bancaria' or 'efectivo') .. '.', 'success')
        TriggerClientEvent('spain_casino:client:refreshCasinoUI', src)
    end
end)

-- Comprar Pase VIP (50.000 €)
RegisterNetEvent('spain_casino:server:buyVipPass', function(payMethod)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    if IsPlayerVip(cid) or (Player.Functions.GetItemByName(Config.VipItem) ~= nil) then
        TriggerClientEvent('QBCore:Notify', src, '¡Ya eres Miembro VIP del Diamond Casino & Resort!', 'primary')
        return
    end

    payMethod = (payMethod == 'bank') and 'bank' or 'cash'
    local cost = Config.VipPrice

    local playerMoney = Player.PlayerData.money[payMethod] or 0
    if playerMoney < cost then
        TriggerClientEvent('QBCore:Notify', src, 'No tienes los 50.000 € requeridos para adquirir el Pase VIP en ' .. (payMethod == 'bank' and 'el banco' or 'efectivo') .. '.', 'error')
        return
    end

    if Player.Functions.RemoveMoney(payMethod, cost, 'casino-buy-vip') then
        -- Insertar en base de datos
        MySQL.query('INSERT INTO casino_memberships (citizenid, is_vip) VALUES (?, 1) ON DUPLICATE KEY UPDATE is_vip = 1', { cid })
        
        -- Entregar tarjeta VIP física
        Player.Functions.AddItem(Config.VipItem, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.VipItem], 'add')

        TriggerClientEvent('QBCore:Notify', src, '¡Felicidades! Ahora eres Miembro VIP del Diamond Casino. Acceso a Ruleta Premium de 100k y salas privadas desbloqueado.', 'success', 9000)
        TriggerClientEvent('spain_casino:client:refreshCasinoUI', src)
    end
end)

-- Actualizar Jackpot en tiempo real
function AddToJackpot(amount)
    CurrentJackpot = CurrentJackpot + amount
    MySQL.query('UPDATE casino_jackpot SET amount = ? WHERE id = 1', { CurrentJackpot })
    TriggerClientEvent('spain_casino:client:updateJackpot', -1, CurrentJackpot)
end

function ResetJackpot()
    CurrentJackpot = Config.Slots.initialJackpot
    MySQL.query('UPDATE casino_jackpot SET amount = ? WHERE id = 1', { CurrentJackpot })
    TriggerClientEvent('spain_casino:client:updateJackpot', -1, CurrentJackpot)
end
