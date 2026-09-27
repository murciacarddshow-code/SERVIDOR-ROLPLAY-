local QBCore = exports['qb-core']:GetCoreObject()

-- Selección ponderada de símbolo para un rodillo
local function RollSlotSymbol()
    local totalWeight = 0
    for _, sym in ipairs(Config.Slots.symbols) do
        totalWeight = totalWeight + (sym.weight or 10)
    end

    local rand = math.random(1, totalWeight)
    local cur = 0
    for _, sym in ipairs(Config.Slots.symbols) do
        cur = cur + (sym.weight or 10)
        if rand <= cur then
            return sym
        end
    end
    return Config.Slots.symbols[1]
end

-- Tirada de máquina tragaperras / Jackpot
RegisterNetEvent('spain_casino:server:spinSlots', function(betAmount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    betAmount = tonumber(betAmount)
    if not betAmount or betAmount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Apuesta inválida para la tragaperras.', 'error')
        return
    end

    local cid = Player.PlayerData.citizenid
    local isVip = IsPlayerVip(cid) or (Player.Functions.GetItemByName(Config.VipItem) ~= nil)

    -- Verificación de límites normales vs VIP
    if betAmount > Config.Slots.normalMaxBet and not isVip then
        TriggerClientEvent('QBCore:Notify', src, 'Las apuestas mayores a ' .. Config.Slots.normalMaxBet .. ' fichas requieren el Pase VIP Diamond.', 'error', 6000)
        return
    end

    if betAmount > Config.Slots.vipMaxBet then
        TriggerClientEvent('QBCore:Notify', src, 'La apuesta máxima absoluta en tragaperras es de ' .. Config.Slots.vipMaxBet .. ' fichas.', 'error')
        return
    end

    -- Comprobar fichas del jugador
    local chipItem = Player.Functions.GetItemByName(Config.ChipsItem)
    local currentChips = chipItem and chipItem.amount or 0

    if currentChips < betAmount then
        TriggerClientEvent('QBCore:Notify', src, 'No tienes suficientes fichas de casino para apostar ' .. betAmount .. ' fichas.', 'error')
        return
    end

    -- Deducir apuesta
    Player.Functions.RemoveItem(Config.ChipsItem, betAmount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ChipsItem], 'remove')

    -- Incrementar bote del jackpot con el porcentaje de corte
    local jackpotContribution = math.max(1, math.floor(betAmount * Config.Slots.jackpotCutPercent))
    AddToJackpot(jackpotContribution)

    -- Girar 3 rodillos
    local s1 = RollSlotSymbol()
    local s2 = RollSlotSymbol()
    local s3 = RollSlotSymbol()

    local winAmount = 0
    local isJackpotWin = false

    -- Evaluación de combinaciones ganadoras
    if s1.id == s2.id and s2.id == s3.id then
        -- 3 símbolos iguales
        if s1.isJackpot then
            -- ¡¡¡GRAN BOTE JACKPOT!!!
            isJackpotWin = true
            local jackpotPrize = CurrentJackpot
            winAmount = (betAmount * s1.mult3) + jackpotPrize
            ResetJackpot()

            local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
            TriggerClientEvent('chat:addMessage', -1, {
                color = { 255, 215, 0 },
                multiline = true,
                args = { '🎰 GRAN JACKPOT DIAMOND', '💥 ¡' .. playerName .. ' ACABA DE REVENTAR EL BOTE DEL CASINO Y GANA ' .. winAmount .. ' FICHAS!' }
            })
        else
            winAmount = betAmount * s1.mult3
        end
    elseif s1.id == 1 and s2.id == 1 then
        -- 2 Cerezas al inicio
        winAmount = betAmount * s1.mult2
    elseif s2.id == 1 and s3.id == 1 then
        -- 2 Cerezas al final
        winAmount = betAmount * s2.mult2
    end

    -- Entregar premio en fichas si ganó
    if winAmount > 0 then
        Player.Functions.AddItem(Config.ChipsItem, winAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ChipsItem], 'add')
    end

    -- Enviar resultado a la interfaz NUI del cliente
    local updatedChips = (currentChips - betAmount + winAmount)
    TriggerClientEvent('spain_casino:client:slotsResult', src, {
        reels = { s1.id, s2.id, s3.id },
        symbols = { s1.icon, s2.icon, s3.icon },
        winAmount = winAmount,
        isJackpot = isJackpotWin,
        newChipBalance = updatedChips,
        currentJackpot = CurrentJackpot
    })
end)
