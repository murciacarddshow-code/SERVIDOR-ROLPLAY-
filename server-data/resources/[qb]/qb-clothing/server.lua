local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('qb-clothing:saveSkin', function(model, skin)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src) or exports['qb-core']:GetPlayer(src)
    if not Player then return end
    if model ~= nil and skin ~= nil then
        local citizenid = Player.PlayerData.citizenid
        local modelStr = tostring(model)
        MySQL.query('SELECT id FROM playerskins WHERE citizenid = ?', { citizenid }, function(result)
            if result and result[1] then
                MySQL.update('UPDATE playerskins SET model = ?, skin = ?, active = 1 WHERE citizenid = ?', {
                    modelStr,
                    skin,
                    citizenid
                })
            else
                MySQL.insert('INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, 1)', {
                    citizenid,
                    modelStr,
                    skin
                })
            end
        end)
    end
end)

RegisterServerEvent('qb-clothes:loadPlayerSkin', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src) or exports['qb-core']:GetPlayer(src)
    if not Player then return end
    local result = MySQL.query.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { Player.PlayerData.citizenid, 1 })
    if result and result[1] and result[1].model and result[1].skin then
        TriggerClientEvent('qb-clothes:loadSkin', src, false, result[1].model, result[1].skin)
    else
        local gender = (Player.PlayerData.charinfo and Player.PlayerData.charinfo.gender) or 0
        local defaultModel = (gender == 1) and 'mp_f_freemode_01' or 'mp_m_freemode_01'
        TriggerClientEvent('qb-clothes:loadSkin', src, true, defaultModel, nil)
    end
end)

RegisterServerEvent('qb-clothes:saveOutfit', function(outfitName, model, skinData)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    if model ~= nil and skinData ~= nil then
        local outfitId = 'outfit-' .. math.random(1, 10) .. '-' .. math.random(1111, 9999)
        MySQL.insert('INSERT INTO player_outfits (citizenid, outfitname, model, skin, outfitId) VALUES (?, ?, ?, ?, ?)', {
            Player.PlayerData.citizenid,
            outfitName,
            model,
            json.encode(skinData),
            outfitId
        }, function()
            local result = MySQL.query.await('SELECT * FROM player_outfits WHERE citizenid = ?', { Player.PlayerData.citizenid })
            if result[1] ~= nil then
                TriggerClientEvent('qb-clothing:client:reloadOutfits', src, result)
            else
                TriggerClientEvent('qb-clothing:client:reloadOutfits', src, nil)
            end
        end)
    end
end)

RegisterServerEvent('qb-clothing:server:removeOutfit', function(outfitName, outfitId)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    MySQL.query('DELETE FROM player_outfits WHERE citizenid = ? AND outfitname = ? AND outfitId = ?', {
        Player.PlayerData.citizenid,
        outfitName,
        outfitId
    }, function()
        local result = MySQL.query.await('SELECT * FROM player_outfits WHERE citizenid = ?', { Player.PlayerData.citizenid })
        if result[1] ~= nil then
            TriggerClientEvent('qb-clothing:client:reloadOutfits', src, result)
        else
            TriggerClientEvent('qb-clothing:client:reloadOutfits', src, nil)
        end
    end)
end)

QBCore.Functions.CreateCallback('qb-clothing:server:getOutfits', function(source, cb)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    local anusVal = {}

    local result = MySQL.query.await('SELECT * FROM player_outfits WHERE citizenid = ?', { Player.PlayerData.citizenid })
    if result[1] ~= nil then
        for k, v in pairs(result) do
            result[k].skin = json.decode(result[k].skin)
            anusVal[k] = v
        end
        cb(anusVal)
    end
    cb(anusVal)
end)
