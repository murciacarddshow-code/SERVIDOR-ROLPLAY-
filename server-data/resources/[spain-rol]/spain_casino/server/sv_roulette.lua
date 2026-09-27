local QBCore = exports['qb-core']:GetCoreObject()

local RED_NUMBERS = {
    [1] = true, [3] = true, [5] = true, [7] = true, [9] = true, [12] = true,
    [14] = true, [16] = true, [18] = true, [19] = true, [21] = true, [23] = true,
    [25] = true, [27] = true, [30] = true, [32] = true, [34] = true, [36] = true
}

local function IsNumberRed(num)
    return RED_NUMBERS[num] == true
end

-- Procesar tirada de ruleta
RegisterNetEvent('spain_casino:server:spinRoulette', function(tableType, bets)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cfg = Config.Roulette[tableType]
    if not cfg then return end

    local cid = Player.PlayerData.citizenid
    local isVip = IsPlayerVip(cid) or (Player.Functions.GetItemByName(Config.VipItem) ~= nil)

    -- Verificación de exclusividad VIP para la mesa Premium
    if cfg.requiresVIP and not isVip then
        TriggerClientEvent('QBCore:Notify', src, '¡Acceso denegado! Esta mesa es exclusiva para miembros con Pase VIP (50.000 € en el cajero).', 'error', 6000)
        return
    end

    if not bets or type(bets) ~= 'table' or #bets == 0 then
        TriggerClientEvent('QBCore:Notify', src, 'No has realizado ninguna apuesta.', 'error')
        return
    end

    -- Calcular y validar apuesta total
    local totalBet = 0
    for _, b in ipairs(bets) do
        local amt = tonumber(b.amount) or 0
        if amt <= 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Apuesta inválida detectada.', 'error')
            return
        end
        totalBet = totalBet + amt
    end

    if totalBet > cfg.maxBet then
        TriggerClientEvent('QBCore:Notify', src, 'La apuesta total (' .. totalBet .. ' fichas) supera el límite máximo de esta mesa (' .. cfg.maxBet .. ' fichas).', 'error', 7000)
        return
    end

    -- Comprobar fichas del jugador
    local chipItem = Player.Functions.GetItemByName(Config.ChipsItem)
    local currentChips = chipItem and chipItem.amount or 0

    if currentChips < totalBet then
        TriggerClientEvent('QBCore:Notify', src, 'No tienes suficientes fichas de casino para esta apuesta (Tienes: ' .. currentChips .. ' | Necesitas: ' .. totalBet .. ').', 'error')
        return
    end

    -- Deducir fichas apostadas
    Player.Functions.RemoveItem(Config.ChipsItem, totalBet)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ChipsItem], 'remove')

    -- Generar número ganador (0 al 36)
    local winningNumber = math.random(0, 36)
    local isRed = IsNumberRed(winningNumber)
    local isGreen = (winningNumber == 0)
    local isBlack = (not isGreen and not isRed)

    -- Calcular ganancias
    local totalWinnings = 0
    local winBreakdown = {}

    for _, b in ipairs(bets) do
        local bAmt = tonumber(b.amount)
        local won = false
        local winMultiplier = 0

        if b.type == 'straight' then
            -- Apuesta a número pleno (0-36)
            if tonumber(b.value) == winningNumber then
                won = true
                winMultiplier = 36
            end
        elseif b.type == 'color' then
            -- Rojo o Negro
            if not isGreen then
                if (b.value == 'red' and isRed) or (b.value == 'black' and isBlack) then
                    won = true
                    winMultiplier = 2
                end
            end
        elseif b.type == 'even_odd' then
            -- Par o Impar
            if not isGreen then
                local isEven = (winningNumber % 2 == 0)
                if (b.value == 'even' and isEven) or (b.value == 'odd' and not isEven) then
                    won = true
                    winMultiplier = 2
                end
            end
        elseif b.type == 'low_high' then
            -- 1-18 o 19-36
            if not isGreen then
                if (b.value == 'low' and winningNumber >= 1 and winningNumber <= 18) or
                   (b.value == 'high' and winningNumber >= 19 and winningNumber <= 36) then
                    won = true
                    winMultiplier = 2
                end
            end
        elseif b.type == 'dozen' then
            -- 1ª, 2ª o 3ª docena
            if not isGreen then
                local val = tonumber(b.value)
                if (val == 1 and winningNumber >= 1 and winningNumber <= 12) or
                   (val == 2 and winningNumber >= 13 and winningNumber <= 24) or
                   (val == 3 and winningNumber >= 25 and winningNumber <= 36) then
                    won = true
                    winMultiplier = 3
                end
            end
        elseif b.type == 'column' then
            -- Columnas 1, 2 o 3
            if not isGreen then
                local val = tonumber(b.value)
                local col = ((winningNumber - 1) % 3) + 1
                if col == val then
                    won = true
                    winMultiplier = 3
                end
            end
        end

        if won then
            local gain = bAmt * winMultiplier
            totalWinnings = totalWinnings + gain
            table.insert(winBreakdown, { type = b.type, value = b.value, gain = gain })
        end
    end

    -- Pagar fichas al cliente si ganó
    if totalWinnings > 0 then
        Player.Functions.AddItem(Config.ChipsItem, totalWinnings)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ChipsItem], 'add')
    end

    -- Enviar resultado completo para la animación del cliente
    local colorStr = isGreen and 'green' or (isRed and 'red' or 'black')
    TriggerClientEvent('spain_casino:client:rouletteResult', src, {
        winningNumber = winningNumber,
        color = colorStr,
        totalBet = totalBet,
        totalWinnings = totalWinnings,
        netProfit = totalWinnings - totalBet,
        newChipBalance = (currentChips - totalBet + totalWinnings)
    })
end)
