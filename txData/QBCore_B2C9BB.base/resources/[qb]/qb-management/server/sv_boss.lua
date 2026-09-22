local QBCore = exports['qb-core']:GetCoreObject()

-- Get employees for boss menu
QBCore.Functions.CreateCallback('qb-bossmenu:server:GetEmployees', function(source, cb, jobname)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.job.isboss then return cb({}) end

    local employees = {}
    local players = MySQL.query.await("SELECT * FROM `players` WHERE JSON_EXTRACT(job, '$.name') = ?", { jobname })
    if players and #players > 0 then
        for _, player in ipairs(players) do
            local charInfo = json.decode(player.charinfo)
            local jobInfo = json.decode(player.job)
            local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(player.citizenid)

            local employee = {
                empSource = player.citizenid,
                name = (charInfo.firstname or 'Desconocido') .. ' ' .. (charInfo.lastname or ''),
                grade = {
                    name = jobInfo.grade and jobInfo.grade.name or 'Rango',
                    level = jobInfo.grade and jobInfo.grade.level or 0
                }
            }
            if targetPlayer then
                employee.isOnline = true
            end
            employees[#employees + 1] = employee
        end
    end
    cb(employees)
end)

-- Get nearby players for hire
QBCore.Functions.CreateCallback('qb-bossmenu:getplayers', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.job.isboss then return cb({}) end

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

-- Update employee grade
RegisterNetEvent('qb-bossmenu:server:GradeUpdate', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.job.isboss then return end

    local cid = data.cid
    local newGrade = tonumber(data.grade)
    local gradeName = data.gradename
    local Target = QBCore.Functions.GetPlayerByCitizenId(cid)

    if Target then
        if Target.Functions.SetJob(Player.PlayerData.job.name, newGrade) then
            TriggerClientEvent('QBCore:Notify', src, 'Rango actualizado para ' .. Target.PlayerData.charinfo.firstname .. ' a ' .. gradeName, 'success')
            TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, 'Has sido ascendido/degradado a ' .. gradeName, 'primary')
        end
    else
        local playerResult = MySQL.query.await("SELECT job FROM `players` WHERE `citizenid` = ?", { cid })
        if playerResult and playerResult[1] then
            local job = json.decode(playerResult[1].job)
            job.grade = {
                name = gradeName,
                level = newGrade
            }
            MySQL.update("UPDATE `players` SET `job` = ? WHERE `citizenid` = ?", { json.encode(job), cid })
            TriggerClientEvent('QBCore:Notify', src, 'Rango actualizado con éxito.', 'success')
        end
    end
end)

-- Fire employee
RegisterNetEvent('qb-bossmenu:server:FireEmployee', function(targetCid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.job.isboss then return end

    local Target = QBCore.Functions.GetPlayerByCitizenId(targetCid)
    if Target then
        if Target.Functions.SetJob('unemployed', 0) then
            TriggerClientEvent('QBCore:Notify', src, 'Empleado despedido con éxito.', 'success')
            TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, 'Has sido despedido de tu trabajo.', 'error')
        end
    else
        local playerResult = MySQL.query.await("SELECT * FROM `players` WHERE `citizenid` = ?", { targetCid })
        if playerResult and playerResult[1] then
            local defaultJob = {
                name = 'unemployed',
                label = 'Civilian',
                payment = 10,
                onduty = true,
                isboss = false,
                grade = { name = 'Freelancer', level = 0 }
            }
            MySQL.update("UPDATE `players` SET `job` = ? WHERE `citizenid` = ?", { json.encode(defaultJob), targetCid })
            TriggerClientEvent('QBCore:Notify', src, 'Empleado despedido con éxito.', 'success')
        end
    end
end)

-- Hire employee
RegisterNetEvent('qb-bossmenu:server:HireEmployee', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.job.isboss then return end

    local Target = QBCore.Functions.GetPlayer(targetId)
    if Target then
        if Target.Functions.SetJob(Player.PlayerData.job.name, 0) then
            TriggerClientEvent('QBCore:Notify', src, 'Has contratado a ' .. Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname, 'success')
            TriggerClientEvent('QBCore:Notify', targetId, 'Has sido contratado en ' .. Player.PlayerData.job.label, 'success')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'El ciudadano no está en línea.', 'error')
    end
end)

-- Open boss stash
RegisterNetEvent('qb-bossmenu:server:stash', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.job.isboss then return end

    local stashName = 'boss_' .. Player.PlayerData.job.name
    exports['qb-inventory']:OpenInventory(src, stashName, {
        maxweight = 4000000,
        slots = 100,
    })
end)
