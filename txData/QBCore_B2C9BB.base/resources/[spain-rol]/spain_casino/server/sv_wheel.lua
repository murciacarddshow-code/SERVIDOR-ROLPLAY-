local QBCore = exports['qb-core']:GetCoreObject()

-- Función auxiliar para generar matrícula única
local function GenerateCasinoPlate()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local plate = 'CAS' .. tostring(math.random(100, 999))
    local randChar1 = chars:sub(math.random(1, #chars), math.random(1, #chars))
    local randChar2 = chars:sub(math.random(1, #chars), math.random(1, #chars))
    return plate .. randChar1 .. randChar2
end

-- Selección ponderada del slice ganador
local function SelectLuckyWheelSlice()
    local totalWeight = 0
    for _, slice in ipairs(Config.LuckyWheel.prizes) do
        totalWeight = totalWeight + (slice.weight or 10)
    end

    local randomVal = math.random(1, totalWeight)
    local currentWeight = 0

    for index, slice in ipairs(Config.LuckyWheel.prizes) do
        currentWeight = currentWeight + (slice.weight or 10)
        if randomVal <= currentWeight then
            return index, slice
        end
    end

    return 1, Config.LuckyWheel.prizes[1]
end

-- Callback para comprobar disponibilidad de tirada diaria
QBCore.Functions.CreateCallback('spain_casino:server:canSpinWheel', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false, 0) end

    local cid = Player.PlayerData.citizenid
    local row = MySQL.single.await('SELECT last_spin FROM casino_luckywheel WHERE citizenid = ?', { cid })
    local now = os.time()
    local lastSpin = row and tonumber(row.last_spin) or 0
    local remaining = math.max(0, (lastSpin + Config.LuckyWheel.cooldown) - now)

    if remaining > 0 then
        cb(false, remaining)
    else
        cb(true, 0)
    end
end)

-- Evento de girar la ruleta diaria
RegisterNetEvent('spain_casino:server:spinLuckyWheel', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local row = MySQL.single.await('SELECT last_spin FROM casino_luckywheel WHERE citizenid = ?', { cid })
    local now = os.time()
    local lastSpin = row and tonumber(row.last_spin) or 0
    local remaining = math.max(0, (lastSpin + Config.LuckyWheel.cooldown) - now)

    if remaining > 0 then
        local hours = math.floor(remaining / 3600)
        local minutes = math.floor((remaining % 3600) / 60)
        TriggerClientEvent('QBCore:Notify', src, '¡Ya has utilizado tu tirada diaria de la Ruleta de la Suerte! Vuelve en ' .. hours .. 'h ' .. minutes .. 'm.', 'error', 7000)
        return
    end

    -- Actualizar cooldown en la base de datos
    MySQL.query([[
        INSERT INTO casino_luckywheel (citizenid, last_spin, total_spins) 
        VALUES (?, ?, 1) 
        ON DUPLICATE KEY UPDATE last_spin = ?, total_spins = total_spins + 1
    ]], { cid, now, now })

    -- Obtener slice ganador
    local sliceIndex, prize = SelectLuckyWheelSlice()

    -- Notificar al cliente para ejecutar la animación de giro
    TriggerClientEvent('spain_casino:client:startWheelSpin', src, sliceIndex, prize)
end)

-- Reclamar premio una vez concluye la animación en el cliente
RegisterNetEvent('spain_casino:server:claimWheelPrize', function(sliceIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local slice = Config.LuckyWheel.prizes[tonumber(sliceIndex)]
    if not slice then return end

    local cid = Player.PlayerData.citizenid
    local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

    if slice.type == 'vehicle' then
        -- Coche del podio directamente al garaje
        local configVeh = MySQL.single.await('SELECT value FROM casino_config WHERE key_name = ?', { 'podium_vehicle' })
        local podiumModel = (configVeh and configVeh.value and configVeh.value ~= '') and configVeh.value or Config.LuckyWheel.defaultPodiumVehicle
        local plate = GenerateCasinoPlate()
        local hash = (type(joaat) == 'function' and joaat(podiumModel)) or GetHashKey(podiumModel)
        local garage = Config.LuckyWheel.defaultGarage or 'motelgarage'

        MySQL.insert([[
            INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state)
            VALUES (?, ?, ?, ?, ?, ?, ?, 1)
        ]], {
            Player.PlayerData.license,
            cid,
            podiumModel,
            hash,
            '{}',
            plate,
            garage
        })

        TriggerClientEvent('QBCore:Notify', src, '¡¡ENHORABUENA!! Has ganado el vehículo del podio (' .. string.upper(podiumModel) .. '). Matrícula: ' .. plate .. '. ¡Ya está guardado en tu garaje!', 'success', 15000)

        -- Anuncio global en el chat
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 215, 0 },
            multiline = true,
            args = { '🎰 DIAMOND CASINO', '🎉 ¡' .. playerName .. ' acaba de ganar el vehículo de lujo del podio (' .. string.upper(podiumModel) .. ') en la Ruleta Diaria! ¡Las llaves han sido depositadas en su garaje!' }
        })

    elseif slice.type == 'chips' then
        Player.Functions.AddItem(Config.ChipsItem, slice.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ChipsItem], 'add')
        TriggerClientEvent('QBCore:Notify', src, '¡Has ganado ' .. slice.amount .. ' Fichas de Casino en la Ruleta Diaria!', 'success', 10000)

    elseif slice.type == 'cash' then
        Player.Functions.AddMoney('cash', slice.amount, 'casino-wheel-prize')
        TriggerClientEvent('QBCore:Notify', src, '¡Has ganado ' .. slice.amount .. ' € en efectivo en la Ruleta Diaria!', 'success', 10000)

    elseif slice.type == 'vip' then
        MySQL.query('INSERT INTO casino_memberships (citizenid, is_vip) VALUES (?, 1) ON DUPLICATE KEY UPDATE is_vip = 1', { cid })
        Player.Functions.AddItem(Config.VipItem, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.VipItem], 'add')
        TriggerClientEvent('QBCore:Notify', src, '¡PREMIO ESPECIAL! Has ganado el Pase VIP Diamond Casino (Valorado en 50.000 €).', 'success', 12000)
    end

    TriggerClientEvent('spain_casino:client:refreshCasinoUI', src)
end)
