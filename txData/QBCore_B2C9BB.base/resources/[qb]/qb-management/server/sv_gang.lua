local QBCore = exports['qb-core']:GetCoreObject()

-- Get members for gang menu
QBCore.Functions.CreateCallback('qb-gangmenu:server:GetEmployees', function(source, cb, gangname)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.gang.isboss then return cb({}) end

    local members = {}
    local players = MySQL.query.await("SELECT * FROM `players` WHERE JSON_EXTRACT(gang, '$.name') = ?", { gangname })
    if players and #players > 0 then
        for _, player in ipairs(players) do
            local charInfo = json.decode(player.charinfo)
            local gangInfo = json.decode(player.gang)
            local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(player.citizenid)

            local member = {
                empSource = player.citizenid,
                name = (charInfo.firstname or 'Desconocido') .. ' ' .. (charInfo.lastname or ''),
                grade = {
                    name = gangInfo.grade and gangInfo.grade.name or 'Rango',
                    level = gangInfo.grade and gangInfo.grade.level or 0
                }
            }
            if targetPlayer then
                member.isOnline = true
            end
            members[#members + 1] = member
        end
    end
    cb(members)
end)

-- Get nearby players for gang recruitment
QBCore.Functions.CreateCallback('qb-gangmenu:getplayers', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.gang.isboss then return cb({}) end

    local ped = GetPlayerPed(src)
    local pCoords = GetEntityCoords(ped)
    local closePlayers = {}

    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        if v ~= src then
            local targetPed = GetPlayerPed(v)
            local tCoords = GetEntityCoords(targetPed)
            if #(pCoords - tCoords) <= 5.0 then
                local Target = QBCore.Functions.GetPlayer(v)
                if Target then
                    closePlayers[#closePlayers + 1] = {
                        sourceplayer = v,
                        name = Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname,
                        citizenid = Target.PlayerData.citizenid
                    }
                end
            end
        end
    end
    cb(closePlayers)
end)

-- Update gang member grade
RegisterNetEvent('qb-gangmenu:server:GradeUpdate', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.gang.isboss then return end

    local cid = data.cid
    local newGrade = tonumber(data.grade)
    local gradeName = data.gradename
    local Target = QBCore.Functions.GetPlayerByCitizenId(cid)

    if Target then
        if Target.Functions.SetGang(Player.PlayerData.gang.name, newGrade) then
            TriggerClientEvent('QBCore:Notify', src, 'Rango de banda actualizado a ' .. gradeName, 'success')
            TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, 'Tu rango en la banda es ahora ' .. gradeName, 'primary')
        end
    else
        local playerResult = MySQL.query.await("SELECT gang FROM `players` WHERE `citizenid` = ?", { cid })
        if playerResult and playerResult[1] then
            local gang = json.decode(playerResult[1].gang)
            gang.grade = {
                name = gradeName,
                level = newGrade
            }
            MySQL.update("UPDATE `players` SET `gang` = ? WHERE `citizenid` = ?", { json.encode(gang), cid })
            TriggerClientEvent('QBCore:Notify', src, 'Rango de banda actualizado en base de datos.', 'success')
        end
    end
end)

-- Fire gang member
RegisterNetEvent('qb-gangmenu:server:FireMember', function(targetCid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.gang.isboss then return end

    local Target = QBCore.Functions.GetPlayerByCitizenId(targetCid)
    if Target then
        if Target.Functions.SetGang('none', 0) then
            TriggerClientEvent('QBCore:Notify', src, 'Miembro expulsado de la banda.', 'success')
            TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, 'Has sido expulsado de la banda.', 'error')
        end
    else
        local playerResult = MySQL.query.await("SELECT * FROM `players` WHERE `citizenid` = ?", { targetCid })
        if playerResult and playerResult[1] then
            local defaultGang = {
                name = 'none',
                label = 'No Gang',
                isboss = false,
                grade = { name = 'none', level = 0 }
            }
            MySQL.update("UPDATE `players` SET `gang` = ? WHERE `citizenid` = ?", { json.encode(defaultGang), targetCid })
            TriggerClientEvent('QBCore:Notify', src, 'Miembro expulsado de la banda.', 'success')
        end
    end
end)

-- Hire gang member
RegisterNetEvent('qb-gangmenu:server:HireMember', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.gang.isboss then return end

    local Target = QBCore.Functions.GetPlayer(targetId)
    if Target then
        if Target.Functions.SetGang(Player.PlayerData.gang.name, 0) then
            TriggerClientEvent('QBCore:Notify', src, 'Has reclutado a ' .. Target.PlayerData.charinfo.firstname, 'success')
            TriggerClientEvent('QBCore:Notify', targetId, 'Has sido reclutado en ' .. Player.PlayerData.gang.label, 'success')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'El ciudadano no está en línea.', 'error')
    end
end)

-- Open gang stash
RegisterNetEvent('qb-gangmenu:server:stash', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.gang.isboss then return end

    local stashName = 'gang_' .. Player.PlayerData.gang.name
    exports['qb-inventory']:OpenInventory(src, stashName, {
        maxweight = 4000000,
        slots = 100,
    })
end)
