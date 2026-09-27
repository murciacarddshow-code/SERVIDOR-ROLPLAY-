-- Variables
local QBCore = exports['qb-core']:GetCoreObject({ 'Functions', 'Commands' })
local sharedWeapons = exports['qb-core']:GetShared('Weapons')
local frozen = false
local permissions = {
    ['kill'] = 'admin',
    ['ban'] = 'admin',
    ['noclip'] = 'admin',
    ['kickall'] = 'admin',
    ['kick'] = 'admin',
    ['revive'] = 'admin',
    ['freeze'] = 'admin',
    ['goto'] = 'admin',
    ['spectate'] = 'admin',
    ['intovehicle'] = 'admin',
    ['bring'] = 'admin',
    ['inventory'] = 'admin',
    ['clothing'] = 'admin'
}

function GetQBPlayers()
    local playerReturn = {}
    local players = QBCore.Functions.GetQBPlayers()

    for id, player in pairs(players) do
        local playerPed = GetPlayerPed(id)
        local name = (player.PlayerData.charinfo.firstname or '') .. ' ' .. (player.PlayerData.charinfo.lastname or '')
        playerReturn[#playerReturn + 1] = {
            name = name .. ' | (' .. (player.PlayerData.name or '') .. ')',
            id = id,
            coords = GetEntityCoords(playerPed),
            cid = name,
            citizenid = player.PlayerData.citizenid,
            sources = playerPed,
            sourceplayer = id
        }
    end
    return playerReturn
end

-- Get Dealers
QBCore.Functions.CreateCallback('test:getdealers', function(_, cb)
    cb(exports['qb-drugs']:GetDealers())
end)

-- Get Players
QBCore.Functions.CreateCallback('test:getplayers', function(_, cb) -- WORKS
    local players = GetQBPlayers()
    cb(players)
end)

QBCore.Functions.CreateCallback('qb-admin:isAdmin', function(src, cb) -- WORKS
    cb(QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command'))
end)

QBCore.Functions.CreateCallback('qb-admin:server:getrank', function(source, cb)
    if QBCore.Functions.HasPermission(source, 'god') or IsPlayerAceAllowed(source, 'command') then
        cb(true)
    else
        cb(false)
    end
end)

-- Functions
local function tablelength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

local function BanPlayer(src)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(src),
        QBCore.Functions.GetIdentifier(src, 'license'),
        QBCore.Functions.GetIdentifier(src, 'discord'),
        QBCore.Functions.GetIdentifier(src, 'ip'),
        'Trying to revive theirselves or other players',
        2147483647,
        'qb-adminmenu'
    })
    TriggerEvent('qb-log:server:CreateLog', 'adminmenu', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(src), 'qb-adminmenu', 'Trying to trigger admin options which they dont have permission for'), true)
    DropPlayer(src, 'You were permanently banned by the server for: Exploiting')
end

-- Events
RegisterNetEvent('qb-admin:server:GetPlayersForBlips', function()
    local src = source
    local players = GetQBPlayers()
    TriggerClientEvent('qb-admin:client:Show', src, players)
end)

RegisterNetEvent('qb-admin:server:kill', function(player)
    local src = source
    if QBCore.Functions.HasPermission(src, permissions['kill']) or IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('hospital:client:KillPlayer', player.id)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('qb-admin:server:revive', function(player)
    local src = source
    if QBCore.Functions.HasPermission(src, permissions['revive']) or IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('hospital:client:Revive', player.id)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('qb-admin:server:kick', function(player, reason)
    local src = source
    if QBCore.Functions.HasPermission(src, permissions['kick']) or IsPlayerAceAllowed(src, 'command') then
        TriggerEvent('qb-log:server:CreateLog', 'bans', 'Player Kicked', 'red', string.format('%s was kicked by %s for %s', GetPlayerName(player.id), GetPlayerName(src), reason), true)
        DropPlayer(player.id, Lang:t('info.kicked_server') .. ':\n' .. reason .. '\n\n' .. Lang:t('info.check_discord') .. QBCore.Config.Server.Discord)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('qb-admin:server:ban', function(player, time, reason)
    local src = source
    if QBCore.Functions.HasPermission(src, permissions['ban']) or IsPlayerAceAllowed(src, 'command') then
        time = tonumber(time)
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then
            banTime = 2147483647
        end
        local timeTable = os.date('*t', banTime)
        MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            GetPlayerName(player.id),
            QBCore.Functions.GetIdentifier(player.id, 'license'),
            QBCore.Functions.GetIdentifier(player.id, 'discord'),
            QBCore.Functions.GetIdentifier(player.id, 'ip'),
            reason,
            banTime,
            GetPlayerName(src)
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = "<div class=chat-message server'><strong>ANNOUNCEMENT | {0} has been banned:</strong> {1}</div>",
            args = { GetPlayerName(player.id), reason }
        })
        TriggerEvent('qb-log:server:CreateLog', 'bans', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(player.id), GetPlayerName(src), reason), true)
        if banTime >= 2147483647 then
            DropPlayer(player.id, Lang:t('info.banned') .. '\n' .. reason .. Lang:t('info.ban_perm') .. QBCore.Config.Server.Discord)
        else
            DropPlayer(player.id, Lang:t('info.banned') .. '\n' .. reason .. Lang:t('info.ban_expires') .. timeTable['day'] .. '/' .. timeTable['month'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'] .. '\n🔸 Check our Discord for more information: ' .. QBCore.Config.Server.Discord)
        end
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('qb-admin:server:spectate', function(player)
    local src = source
    if QBCore.Functions.HasPermission(src, permissions['spectate']) or IsPlayerAceAllowed(src, 'command') then
        local targetped = GetPlayerPed(player.id)
        local coords = GetEntityCoords(targetped)
        TriggerClientEvent('qb-admin:client:spectate', src, player.id, coords)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('qb-admin:server:freeze', function(player)
    local src = source
    if QBCore.Functions.HasPermission(src, permissions['freeze']) or IsPlayerAceAllowed(src, 'command') then
        local target = GetPlayerPed(player.id)
        if not frozen then
            frozen = true
            FreezeEntityPosition(target, true)
        else
            frozen = false
            FreezeEntityPosition(target, false)
        end
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('qb-admin:server:goto', function(player)
    local src = source
    if QBCore.Functions.HasPermission(src, permissions['goto']) or IsPlayerAceAllowed(src, 'command') then
        local admin = GetPlayerPed(src)
        local coords = GetEntityCoords(GetPlayerPed(player.id))
        SetEntityCoords(admin, coords)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('qb-admin:server:intovehicle', function(player)
    local src = source
    if QBCore.Functions.HasPermission(src, permissions['intovehicle']) or IsPlayerAceAllowed(src, 'command') then
        local admin = GetPlayerPed(src)
        local targetPed = GetPlayerPed(player.id)
        local vehicle = GetVehiclePedIsIn(targetPed, false)
        local seat = -1
        if vehicle ~= 0 then
            for i = 0, 8, 1 do
                if GetPedInVehicleSeat(vehicle, i) == 0 then
                    seat = i
                    break
                end
            end
            if seat ~= -1 then
                SetPedIntoVehicle(admin, vehicle, seat)
                TriggerClientEvent('QBCore:Notify', src, Lang:t('sucess.entered_vehicle'), 'success', 5000)
            else
                TriggerClientEvent('QBCore:Notify', src, Lang:t('error.no_free_seats'), 'danger', 5000)
            end
        end
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('qb-admin:server:bring', function(player)
    local src = source
    if QBCore.Functions.HasPermission(src, permissions['bring']) or IsPlayerAceAllowed(src, 'command') then
        local admin = GetPlayerPed(src)
        local coords = GetEntityCoords(admin)
        local target = GetPlayerPed(player.id)
        SetEntityCoords(target, coords)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('qb-admin:server:inventory', function(player)
    local src = source
    if QBCore.Functions.HasPermission(src, permissions['inventory']) or IsPlayerAceAllowed(src, 'command') then
        exports['qb-inventory']:OpenInventoryById(src, player.id)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('qb-admin:server:cloth', function(player)
    local src = source
    if QBCore.Functions.HasPermission(src, permissions['clothing']) or IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('qb-clothing:client:openMenu', player.id)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('qb-admin:server:setPermissions', function(targetId, group)
    local src = source
    if QBCore.Functions.HasPermission(src, 'god') or IsPlayerAceAllowed(src, 'command') then
        QBCore.Functions.AddPermission(targetId, group[1].rank)
        TriggerClientEvent('QBCore:Notify', targetId, Lang:t('info.rank_level') .. group[1].label)
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('qb-admin:server:SendReport', function(name, targetSrc, msg)
    local src = source
    if QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        if QBCore.Functions.IsOptin(src) then
            TriggerClientEvent('chat:addMessage', src, {
                color = { 255, 0, 0 },
                multiline = true,
                args = { Lang:t('info.admin_report') .. name .. ' (' .. targetSrc .. ')', msg }
            })
        end
    end
end)

RegisterServerEvent('qb-admin:giveWeapon', function(weapon)
    local src = source
    if QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        exports['qb-inventory']:AddItem(src, weapon, 1, false, false, 'qb-admin:giveWeapon')
    else
        BanPlayer(src)
    end
end)

RegisterNetEvent('qb-admin:server:SaveCar', function(mods, vehicle, _, plate)
    local src = source
    if QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        local Player = exports['qb-core']:GetPlayer(src)
        local result = MySQL.query.await('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
        if result[1] == nil then
            MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                Player.PlayerData.license,
                Player.PlayerData.citizenid,
                vehicle.model,
                vehicle.hash,
                json.encode(mods),
                plate,
                0
            })
            TriggerClientEvent('QBCore:Notify', src, Lang:t('success.success_vehicle_owner'), 'success', 5000)
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t('error.failed_vehicle_owner'), 'error', 3000)
        end
    else
        BanPlayer(src)
    end
end)

-- Commands

QBCore.Commands.Add('maxmods', Lang:t('desc.max_mod_desc'), {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-admin:client:maxmodVehicle', src)
end, 'admin')

QBCore.Commands.Add('blips', Lang:t('commands.blips_for_player'), {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-admin:client:toggleBlips', src)
end, 'admin')

QBCore.Commands.Add('names', Lang:t('commands.player_name_overhead'), {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-admin:client:toggleNames', src)
end, 'admin')

QBCore.Commands.Add('coords', Lang:t('commands.coords_dev_command'), {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-admin:client:ToggleCoords', src)
end, 'admin')

QBCore.Commands.Add('noclip', Lang:t('commands.toogle_noclip'), {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-admin:client:ToggleNoClip', src)
end, 'admin')

QBCore.Commands.Add('admincar', Lang:t('commands.save_vehicle_garage'), {}, false, function(source, _)
    TriggerClientEvent('qb-admin:client:SaveCar', source)
end, 'admin')

QBCore.Commands.Add('announce', Lang:t('commands.make_announcement'), {}, false, function(_, args)
    local msg = table.concat(args, ' ')
    if msg == '' then return end
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0 },
        multiline = true,
        args = { 'Announcement', msg }
    })
end, 'admin')

QBCore.Commands.Add('admin', Lang:t('commands.open_admin'), {}, false, function(source, _)
    TriggerClientEvent('qb-admin:client:openMenu', source)
end, 'admin')

QBCore.Commands.Add('report', Lang:t('info.admin_report'), { { name = 'message', help = 'Message' } }, true, function(source, args)
    local src = source
    local msg = table.concat(args, ' ')
    local Player = exports['qb-core']:GetPlayer(source)
    TriggerClientEvent('qb-admin:client:SendReport', -1, GetPlayerName(src), src, msg)
    TriggerEvent('qb-log:server:CreateLog', 'report', 'Report', 'green', '**' .. GetPlayerName(source) .. '** (CitizenID: ' .. Player.PlayerData.citizenid .. ' | ID: ' .. source .. ') **Report:** ' .. msg, false)
end)

QBCore.Commands.Add('staffchat', Lang:t('commands.staffchat_message'), { { name = 'message', help = 'Message' } }, true, function(source, args)
    local msg = table.concat(args, ' ')
    local name = GetPlayerName(source)

    local plrs = GetPlayers()

    for _, plr in ipairs(plrs) do
        plr = tonumber(plr)
        if plr then
            if QBCore.Functions.HasPermission(plr, 'admin') or IsPlayerAceAllowed(plr, 'command') then
                if QBCore.Functions.IsOptin(plr) then
                    TriggerClientEvent('chat:addMessage', plr, {
                        color = { 255, 0, 0 },
                        multiline = true,
                        args = { Lang:t('info.staffchat') .. name, msg }
                    })
                end
            end
        end
    end
end, 'admin')

QBCore.Commands.Add('givenuifocus', Lang:t('commands.nui_focus'), { { name = 'id', help = 'Player id' }, { name = 'focus', help = 'Set focus on/off' }, { name = 'mouse', help = 'Set mouse on/off' } }, true, function(_, args)
    local playerid = tonumber(args[1])
    local focus = args[2]
    local mouse = args[3]
    TriggerClientEvent('qb-admin:client:GiveNuiFocus', playerid, focus, mouse)
end, 'admin')

QBCore.Commands.Add('warn', Lang:t('commands.warn_a_player'), { { name = 'ID', help = 'Player' }, { name = 'Reason', help = 'Mention a reason' } }, true, function(source, args)
    local targetPlayer = exports['qb-core']:GetPlayer(tonumber(args[1]))
    local senderPlayer = exports['qb-core']:GetPlayer(source)
    table.remove(args, 1)
    local msg = table.concat(args, ' ')
    local warnId = 'WARN-' .. math.random(1111, 9999)
    if targetPlayer ~= nil then
        TriggerClientEvent('chat:addMessage', targetPlayer.PlayerData.source, { args = { 'SYSTEM', Lang:t('info.warning_chat_message') .. GetPlayerName(source) .. ',' .. Lang:t('info.reason') .. ': ' .. msg }, color = 255, 0, 0 })
        TriggerClientEvent('chat:addMessage', source, { args = { 'SYSTEM', Lang:t('info.warning_staff_message') .. GetPlayerName(targetPlayer.PlayerData.source) .. ', for: ' .. msg }, color = 255, 0, 0 })
        MySQL.insert('INSERT INTO player_warns (senderIdentifier, targetIdentifier, reason, warnId) VALUES (?, ?, ?, ?)', {
            senderPlayer.PlayerData.license,
            targetPlayer.PlayerData.license,
            msg,
            warnId
        })
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')

QBCore.Commands.Add('checkwarns', Lang:t('commands.check_player_warning'), { { name = 'id', help = 'Player' }, { name = 'Warning', help = 'Number of warning, (1, 2 or 3 etc..)' } }, false, function(source, args)
    if args[2] == nil then
        local targetPlayer = exports['qb-core']:GetPlayer(tonumber(args[1]))
        local result = MySQL.query.await('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
        TriggerClientEvent('chat:addMessage', source, 'SYSTEM', 'warning', targetPlayer.PlayerData.name .. ' has ' .. tablelength(result) .. ' warnings!')
    else
        local targetPlayer = exports['qb-core']:GetPlayer(tonumber(args[1]))
        local warnings = MySQL.query.await('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
        local selectedWarning = tonumber(args[2])
        if warnings[selectedWarning] ~= nil then
            local sender = exports['qb-core']:GetPlayer(warnings[selectedWarning].senderIdentifier)
            TriggerClientEvent('chat:addMessage', source, 'SYSTEM', 'warning', targetPlayer.PlayerData.name .. ' has been warned by ' .. sender.PlayerData.name .. ', Reason: ' .. warnings[selectedWarning].reason)
        end
    end
end, 'admin')

QBCore.Commands.Add('delwarn', Lang:t('commands.delete_player_warning'), { { name = 'id', help = 'Player' }, { name = 'Warning', help = 'Number of warning, (1, 2 or 3 etc..)' } }, true, function(source, args)
    local targetPlayer = exports['qb-core']:GetPlayer(tonumber(args[1]))
    local warnings = MySQL.query.await('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
    local selectedWarning = tonumber(args[2])
    if warnings[selectedWarning] ~= nil then
        TriggerClientEvent('chat:addMessage', source, 'SYSTEM', 'warning', 'You have deleted warning (' .. selectedWarning .. ') , Reason: ' .. warnings[selectedWarning].reason)
        MySQL.query('DELETE FROM player_warns WHERE warnId = ?', { warnings[selectedWarning].warnId })
    end
end, 'admin')

QBCore.Commands.Add('reportr', Lang:t('commands.reply_to_report'), { { name = 'id', help = 'Player' }, { name = 'message', help = 'Message to respond with' } }, false, function(source, args)
    local src = source
    local playerId = tonumber(args[1])
    table.remove(args, 1)
    local msg = table.concat(args, ' ')
    local OtherPlayer = exports['qb-core']:GetPlayer(playerId)
    if msg == '' then return end
    if not OtherPlayer then return TriggerClientEvent('QBCore:Notify', src, 'Player is not online', 'error') end
    if not QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') ~= 1 then return end
    TriggerClientEvent('chat:addMessage', playerId, {
        color = { 255, 0, 0 },
        multiline = true,
        args = { 'Admin Response', msg }
    })
    TriggerClientEvent('chat:addMessage', src, {
        color = { 255, 0, 0 },
        multiline = true,
        args = { 'Report Response (' .. playerId .. ')', msg }
    })
    TriggerClientEvent('QBCore:Notify', src, 'Reply Sent')
    TriggerEvent('qb-log:server:CreateLog', 'report', 'Report Reply', 'red', '**' .. GetPlayerName(src) .. '** replied on: **' .. OtherPlayer.PlayerData.name .. ' **(ID: ' .. OtherPlayer.PlayerData.source .. ') **Message:** ' .. msg, false)
end, 'admin')

QBCore.Commands.Add('setmodel', Lang:t('commands.change_ped_model'), { { name = 'model', help = 'Name of the model' }, { name = 'id', help = 'Id of the Player (empty for yourself)' } }, false, function(source, args)
    local model = args[1]
    local target = tonumber(args[2])
    if model ~= nil or model ~= '' then
        if target == nil then
            TriggerClientEvent('qb-admin:client:SetModel', source, tostring(model))
        else
            local Trgt = exports['qb-core']:GetPlayer(target)
            if Trgt ~= nil then
                TriggerClientEvent('qb-admin:client:SetModel', target, tostring(model))
            else
                TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.failed_set_model'), 'error')
    end
end, 'admin')

QBCore.Commands.Add('setspeed', Lang:t('commands.set_player_foot_speed'), {}, false, function(source, args)
    local speed = args[1]
    if speed ~= nil then
        TriggerClientEvent('qb-admin:client:SetSpeed', source, tostring(speed))
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t('error.failed_set_speed'), 'error')
    end
end, 'admin')

QBCore.Commands.Add('reporttoggle', Lang:t('commands.report_toggle'), {}, false, function(source, _)
    local src = source
    QBCore.Functions.ToggleOptin(src)
    if QBCore.Functions.IsOptin(src) then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('success.receive_reports'), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.no_receive_report'), 'error')
    end
end, 'admin')

QBCore.Commands.Add('kickall', Lang:t('commands.kick_all'), {}, false, function(source, args)
    local src = source
    if src > 0 then
        local reason = table.concat(args, ' ')
        if QBCore.Functions.HasPermission(src, 'god') or IsPlayerAceAllowed(src, 'command') then
            if reason and reason ~= '' then
                local players = GetPlayers()
                for _, playerId in ipairs(players) do
                    DropPlayer(playerId, reason)
                end
            else
                TriggerClientEvent('QBCore:Notify', src, Lang:t('info.no_reason_specified'), 'error')
            end
        end
    else
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            DropPlayer(playerId, Lang:t('info.server_restart') .. QBCore.Config.Server.Discord)
        end
    end
end, 'god')

QBCore.Commands.Add('setammo', Lang:t('commands.ammo_amount_set'), { { name = 'amount', help = 'Amount of bullets, for example: 20' } }, false, function(source, args)
    local src = source
    local ped = GetPlayerPed(src)
    local amount = tonumber(args[1])
    local weapon = GetSelectedPedWeapon(ped)
    if weapon and amount then
        SetPedAmmo(ped, weapon, amount)
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.ammoforthe', { value = amount, weapon = sharedWeapons[weapon]['label'] }), 'success')
    end
end, 'admin')

QBCore.Commands.Add('vector2', 'Copy vector2 to clipboard (Admin only)', {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-admin:client:copyToClipboard', src, 'coords2')
end, 'admin')

QBCore.Commands.Add('vector3', 'Copy vector3 to clipboard (Admin only)', {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-admin:client:copyToClipboard', src, 'coords3')
end, 'admin')

QBCore.Commands.Add('vector4', 'Copy vector4 to clipboard (Admin only)', {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-admin:client:copyToClipboard', src, 'coords4')
end, 'admin')

QBCore.Commands.Add('heading', 'Copy heading to clipboard (Admin only)', {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-admin:client:copyToClipboard', src, 'heading')
end, 'admin')

-- =========================================================================
-- SPAIN ROL - GESTIÓN DE ECONOMÍA (DAR Y QUITAR DINERO)
-- =========================================================================

QBCore.Functions.CreateCallback('qb-admin:server:getPlayerMoney', function(source, cb, targetId)
    local src = source
    if not (QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command')) then
        cb(nil)
        return
    end
    local target = QBCore.Functions.GetPlayer(tonumber(targetId))
    if target then
        cb({
            cash = target.PlayerData.money['cash'] or 0,
            bank = target.PlayerData.money['bank'] or 0,
            crypto = target.PlayerData.money['crypto'] or 0,
            name = (target.PlayerData.charinfo.firstname or '') .. ' ' .. (target.PlayerData.charinfo.lastname or '')
        })
    else
        cb(nil)
    end
end)

RegisterNetEvent('qb-admin:server:giveMoney', function(targetId, moneyType, amount)
    local src = source
    if not (QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command')) then
        BanPlayer(src)
        return
    end
    targetId = tonumber(targetId)
    amount = tonumber(amount)
    moneyType = tostring(moneyType or 'cash'):lower()

    if not targetId or not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Cantidad o ID no válido.', 'error')
        return
    end

    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    if TargetPlayer then
        TargetPlayer.Functions.AddMoney(moneyType, amount, 'Admin Give Money')
        local pName = (TargetPlayer.PlayerData.charinfo.firstname or '') .. ' ' .. (TargetPlayer.PlayerData.charinfo.lastname or '')
        TriggerClientEvent('QBCore:Notify', src, ('Se han entregado $%s (%s) a %s (ID: %s).'):format(amount, moneyType:upper(), pName, targetId), 'success')
        TriggerClientEvent('QBCore:Notify', targetId, ('Un Administrador te ha entregado $%s (%s).'):format(amount, moneyType:upper()), 'success')
        TriggerEvent('qb-log:server:CreateLog', 'adminmenu', 'Dar Dinero', 'green', string.format('**%s** (Admin: %s) dio **$%s** (%s) a **%s** (ID: %s)', GetPlayerName(src), src, amount, moneyType, GetPlayerName(targetId), targetId), true)
    else
        TriggerClientEvent('QBCore:Notify', src, 'El jugador con ID ' .. targetId .. ' no está conectado.', 'error')
    end
end)

RegisterNetEvent('qb-admin:server:removeMoney', function(targetId, moneyType, amount)
    local src = source
    if not (QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command')) then
        BanPlayer(src)
        return
    end
    targetId = tonumber(targetId)
    amount = tonumber(amount)
    moneyType = tostring(moneyType or 'cash'):lower()

    if not targetId or not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Cantidad o ID no válido.', 'error')
        return
    end

    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    if TargetPlayer then
        TargetPlayer.Functions.RemoveMoney(moneyType, amount, 'Admin Remove Money')
        local pName = (TargetPlayer.PlayerData.charinfo.firstname or '') .. ' ' .. (TargetPlayer.PlayerData.charinfo.lastname or '')
        TriggerClientEvent('QBCore:Notify', src, ('Se han retirado $%s (%s) a %s (ID: %s).'):format(amount, moneyType:upper(), pName, targetId), 'success')
        TriggerClientEvent('QBCore:Notify', targetId, ('Un Administrador te ha retirado $%s (%s).'):format(amount, moneyType:upper()), 'error')
        TriggerEvent('qb-log:server:CreateLog', 'adminmenu', 'Quitar Dinero', 'red', string.format('**%s** (Admin: %s) retiró **$%s** (%s) a **%s** (ID: %s)', GetPlayerName(src), src, amount, moneyType, GetPlayerName(targetId), targetId), true)
    else
        TriggerClientEvent('QBCore:Notify', src, 'El jugador con ID ' .. targetId .. ' no está conectado.', 'error')
    end
end)

-- =========================================================================
-- SPAIN ROL - NUI ADMIN DASHBOARD HANDLERS
-- =========================================================================

local playerFrozenState = {}

QBCore.Functions.CreateCallback('qb-admin:server:getDetailedPlayers', function(source, cb)
    local src = source
    if not (QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command')) then
        cb({})
        return
    end

    local playerList = {}
    local players = QBCore.Functions.GetQBPlayers()

    for id, player in pairs(players) do
        local ped = GetPlayerPed(id)
        local pData = player.PlayerData
        local charinfo = pData.charinfo or {}
        local job = pData.job or {}
        local money = pData.money or {}
        
        local health = GetEntityHealth(ped)
        local maxHealth = GetEntityMaxHealth(ped)
        local healthPct = 100
        if maxHealth and maxHealth > 0 and health then
            healthPct = math.min(100, math.max(0, math.floor((health / maxHealth) * 100)))
        end

        local coords = GetEntityCoords(ped)

        playerList[#playerList + 1] = {
            id = id,
            name = GetPlayerName(id) or 'Desconocido',
            charname = (charinfo.firstname or '') .. ' ' .. (charinfo.lastname or ''),
            citizenid = pData.citizenid or 'N/A',
            job = job.name or 'unemployed',
            jobLabel = job.label or 'Desempleado',
            jobGrade = (job.grade and job.grade.level) or 0,
            cash = money.cash or 0,
            bank = money.bank or 0,
            health = healthPct,
            ping = GetPlayerPing(id) or 0,
            isFrozen = playerFrozenState[id] or false,
            coords = { x = coords.x, y = coords.y, z = coords.z }
        }
    end

    cb(playerList)
end)

RegisterNetEvent('qb-admin:server:setJob', function(targetId, jobName, gradeLevel)
    local src = source
    if not (QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command')) then
        BanPlayer(src)
        return
    end

    targetId = tonumber(targetId)
    gradeLevel = tonumber(gradeLevel) or 0
    jobName = tostring(jobName or 'unemployed')

    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    if TargetPlayer then
        TargetPlayer.Functions.SetJob(jobName, gradeLevel)
        local pName = (TargetPlayer.PlayerData.charinfo.firstname or '') .. ' ' .. (TargetPlayer.PlayerData.charinfo.lastname or '')
        TriggerClientEvent('QBCore:Notify', src, ('Se ha asignado el trabajo %s (Grado %s) a %s (ID: %s).'):format(jobName:upper(), gradeLevel, pName, targetId), 'success')
        TriggerClientEvent('QBCore:Notify', targetId, ('Un Administrador te ha asignado el trabajo %s (Grado %s).'):format(jobName:upper(), gradeLevel), 'success')
        TriggerEvent('qb-log:server:CreateLog', 'adminmenu', 'Dar Trabajo', 'purple', string.format('**%s** asignó trabajo **%s** (Grado %s) a **%s** (ID: %s)', GetPlayerName(src), jobName, gradeLevel, GetPlayerName(targetId), targetId), true)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Jugador no encontrado.', 'error')
    end
end)

RegisterNetEvent('qb-admin:server:toggleFreezePlayer', function(targetId)
    local src = source
    if not (QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command')) then
        BanPlayer(src)
        return
    end

    targetId = tonumber(targetId)
    local ped = GetPlayerPed(targetId)
    if ped and ped ~= 0 then
        local newState = not (playerFrozenState[targetId] or false)
        playerFrozenState[targetId] = newState
        FreezeEntityPosition(ped, newState)
        TriggerClientEvent('QBCore:Notify', src, newState and ('Has congelado a ID: %s'):format(targetId) or ('Has descongelado a ID: %s'):format(targetId), 'primary')
        TriggerClientEvent('QBCore:Notify', targetId, newState and 'Has sido congelado por un administrador.' or 'Has sido descongelado.', newState and 'error' or 'success')
    end
end)

RegisterNetEvent('qb-admin:server:globalAnnouncement', function(message)
    local src = source
    if not (QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command')) then
        BanPlayer(src)
        return
    end

    message = tostring(message or '')
    if message ~= '' then
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 180, 0 },
            multiline = true,
            args = { '📢 ANUNCIO ADMINISTRACIÓN', message }
        })
        TriggerClientEvent('QBCore:Notify', -1, message, 'primary', 10000)
    end
end)

-- =========================================================================
-- SPAIN ROL - GESTIÓN INTEGRAL DE ARMAS Y MUNICIÓN (PANEL NUI + COMANDOS)
-- =========================================================================

local weaponAliases = {
    -- Pistolas
    ['pistola']         = 'weapon_pistol',
    ['pistol']          = 'weapon_pistol',
    ['glock']           = 'weapon_combatpistol',
    ['combatpistol']    = 'weapon_combatpistol',
    ['combate']         = 'weapon_combatpistol',
    ['ap']              = 'weapon_appistol',
    ['appistol']        = 'weapon_appistol',
    ['deagle']          = 'weapon_pistol50',
    ['pistol50']        = 'weapon_pistol50',
    ['desert']          = 'weapon_pistol50',
    ['heavypistol']     = 'weapon_heavypistol',
    ['pesada']          = 'weapon_heavypistol',
    ['revolver']        = 'weapon_revolver',
    ['taser']           = 'weapon_stungun',
    ['stungun']         = 'weapon_stungun',
    ['vintage']         = 'weapon_vintagepistol',
    ['vintagepistol']   = 'weapon_vintagepistol',
    -- Subfusiles
    ['smg']             = 'weapon_smg',
    ['mp5']             = 'weapon_smg',
    ['uzi']             = 'weapon_microsmg',
    ['microsmg']        = 'weapon_microsmg',
    ['pdw']             = 'weapon_combatpdw',
    ['combatpdw']       = 'weapon_combatpdw',
    ['p90']             = 'weapon_assaultsmg',
    ['assaultsmg']      = 'weapon_assaultsmg',
    ['tec9']            = 'weapon_machinepistol',
    ['machinepistol']   = 'weapon_machinepistol',
    ['minismg']         = 'weapon_minismg',
    ['skorpion']        = 'weapon_minismg',
    ['thompson']        = 'weapon_gusenberg',
    ['gusenberg']       = 'weapon_gusenberg',
    -- Fusiles de Asalto
    ['m4']              = 'weapon_carbinerifle',
    ['carabina']        = 'weapon_carbinerifle',
    ['carbine']         = 'weapon_carbinerifle',
    ['carbinerifle']    = 'weapon_carbinerifle',
    ['ak']              = 'weapon_assaultrifle',
    ['ak47']            = 'weapon_assaultrifle',
    ['assaultrifle']    = 'weapon_assaultrifle',
    ['kalashnikov']     = 'weapon_assaultrifle',
    ['g36']             = 'weapon_specialcarbine',
    ['g36c']            = 'weapon_specialcarbine',
    ['specialcarbine']  = 'weapon_specialcarbine',
    ['aug']             = 'weapon_militaryrifle',
    ['militaryrifle']   = 'weapon_militaryrifle',
    ['tar21']           = 'weapon_advancedrifle',
    ['advancedrifle']   = 'weapon_advancedrifle',
    ['miniak']          = 'weapon_compactrifle',
    ['compactrifle']    = 'weapon_compactrifle',
    ['scar']            = 'weapon_heavyrifle',
    ['heavyrifle']      = 'weapon_heavyrifle',
    -- Escopetas
    ['shotgun']         = 'weapon_pumpshotgun',
    ['pumpshotgun']     = 'weapon_pumpshotgun',
    ['escopeta']        = 'weapon_pumpshotgun',
    ['recortada']       = 'weapon_sawnoffshotgun',
    ['sawnoff']         = 'weapon_sawnoffshotgun',
    ['sawnoffshotgun']  = 'weapon_sawnoffshotgun',
    ['spas']            = 'weapon_combatshotgun',
    ['spas12']          = 'weapon_combatshotgun',
    ['combatshotgun']   = 'weapon_combatshotgun',
    ['doble']           = 'weapon_dbshotgun',
    ['dbshotgun']       = 'weapon_dbshotgun',
    ['autoshotgun']     = 'weapon_autoshotgun',
    -- Francotiradores
    ['sniper']          = 'weapon_sniperrifle',
    ['sniperrifle']     = 'weapon_sniperrifle',
    ['franco']          = 'weapon_sniperrifle',
    ['heavysniper']     = 'weapon_heavysniper',
    ['barrett']         = 'weapon_heavysniper',
    ['francopesado']    = 'weapon_heavysniper',
    ['marksman']        = 'weapon_marksmanrifle',
    ['marksmanrifle']   = 'weapon_marksmanrifle',
    -- Ametralladoras
    ['mg']              = 'weapon_mg',
    ['combatmg']        = 'weapon_combatmg',
    -- Cuerpo a cuerpo
    ['knife']           = 'weapon_knife',
    ['cuchillo']        = 'weapon_knife',
    ['bat']             = 'weapon_bat',
    ['bate']            = 'weapon_bat',
    ['machete']         = 'weapon_machete',
    ['navaja']          = 'weapon_switchblade',
    ['switchblade']     = 'weapon_switchblade',
    ['porra']           = 'weapon_nightstick',
    ['nightstick']      = 'weapon_nightstick',
    ['puño']            = 'weapon_knuckle',
    ['knuckle']         = 'weapon_knuckle',
    ['wrench']          = 'weapon_wrench',
    ['llave']           = 'weapon_wrench',
    ['palanca']         = 'weapon_crowbar',
    ['crowbar']         = 'weapon_crowbar',
    ['hacha']           = 'weapon_hatchet',
    ['hatchet']         = 'weapon_hatchet',
    ['linterna']        = 'weapon_flashlight',
    ['flashlight']      = 'weapon_flashlight',
    -- Equipamiento
    ['chaleco']         = 'heavyarmor',
    ['armor']           = 'heavyarmor',
    ['heavyarmor']      = 'heavyarmor'
}

local ammoItemByWeaponType = {
    ['AMMO_PISTOL']   = 'pistol_ammo',
    ['AMMO_SMG']      = 'smg_ammo',
    ['AMMO_RIFLE']    = 'rifle_ammo',
    ['AMMO_SHOTGUN']  = 'shotgun_ammo',
    ['AMMO_SNIPER']   = 'snp_ammo',
    ['AMMO_MG']       = 'mg_ammo',
    ['AMMO_STUNGUN']  = nil
}

local function resolveWeaponName(nameInput)
    if not nameInput then return nil end
    local clean = string.lower(string.gsub(tostring(nameInput), "%s+", ""))
    if weaponAliases[clean] then
        return weaponAliases[clean]
    end
    if QBCore.Shared.Items[clean] then
        return clean
    end
    local withPrefix = 'weapon_' .. clean
    if QBCore.Shared.Items[withPrefix] then
        return withPrefix
    end
    return nil
end

local function giveWeaponInternal(src, targetId, weaponInput, ammoCount, giveAmmoBox)
    targetId = tonumber(targetId)
    if not targetId then
        if src > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'ID de jugador no válida.', 'error')
        end
        return false
    end

    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not TargetPlayer then
        if src > 0 then
            TriggerClientEvent('QBCore:Notify', src, ('El jugador con ID %s no está conectado.'):format(targetId), 'error')
        end
        return false
    end

    local resolved = resolveWeaponName(weaponInput)
    if not resolved or not QBCore.Shared.Items[resolved] then
        if src > 0 then
            TriggerClientEvent('QBCore:Notify', src, ('El arma "%s" no es válida o no existe.'):format(weaponInput or ''), 'error')
        end
        return false
    end

    local itemData = QBCore.Shared.Items[resolved]
    ammoCount = tonumber(ammoCount) or 100

    local info = {
        serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4)),
        quality = 100,
        ammo = ammoCount
    }

    local success = exports['qb-inventory']:AddItem(targetId, resolved, 1, false, info, 'Admin Give Weapon')
    if success then
        TriggerClientEvent('qb-inventory:client:ItemBox', targetId, itemData, 'add', 1)

        -- Si es un arma de fuego y se solicitó caja de balas de reserva
        if giveAmmoBox and itemData.ammotype and ammoItemByWeaponType[itemData.ammotype] then
            local ammoItem = ammoItemByWeaponType[itemData.ammotype]
            if QBCore.Shared.Items[ammoItem] then
                exports['qb-inventory']:AddItem(targetId, ammoItem, 2, false, false, 'Admin Give Weapon Ammo')
                TriggerClientEvent('qb-inventory:client:ItemBox', targetId, QBCore.Shared.Items[ammoItem], 'add', 2)
            end
        end

        local pName = (TargetPlayer.PlayerData.charinfo.firstname or '') .. ' ' .. (TargetPlayer.PlayerData.charinfo.lastname or '')
        local adminName = src > 0 and GetPlayerName(src) or 'Consola'

        if src > 0 then
            TriggerClientEvent('QBCore:Notify', src, ('Arma entregada: %s (Balas: %s) a %s (ID: %s)'):format(itemData.label or resolved, ammoCount, pName, targetId), 'success')
        end
        TriggerClientEvent('QBCore:Notify', targetId, ('Has recibido: %s (Munición: %s)'):format(itemData.label or resolved, ammoCount), 'success')

        TriggerEvent('qb-log:server:CreateLog', 'adminmenu', 'Dar Arma', 'red', string.format('**%s** entregó arma **%s** (%s balas) a **%s** (ID: %s)', adminName, itemData.label or resolved, ammoCount, GetPlayerName(targetId), targetId), true)
        return true
    else
        if src > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'El inventario del jugador está lleno.', 'error')
        end
        return false
    end
end

local function clearWeaponsInternal(src, targetId)
    targetId = tonumber(targetId)
    if not targetId then return false end

    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not TargetPlayer then
        if src > 0 then
            TriggerClientEvent('QBCore:Notify', src, ('El jugador con ID %s no está conectado.'):format(targetId), 'error')
        end
        return false
    end

    local items = TargetPlayer.PlayerData.items
    local removedCount = 0
    if items then
        for slot, item in pairs(items) do
            if item and (item.type == 'weapon' or string.sub(string.lower(item.name), 1, 7) == 'weapon_') then
                TargetPlayer.Functions.RemoveItem(item.name, item.amount, slot)
                TriggerClientEvent('qb-inventory:client:ItemBox', targetId, QBCore.Shared.Items[item.name], 'remove', item.amount)
                removedCount = removedCount + 1
            end
        end
    end

    -- Desarmar ped inmediatamente
    TriggerClientEvent('qb-admin:client:stripPedWeapons', targetId)

    local pName = (TargetPlayer.PlayerData.charinfo.firstname or '') .. ' ' .. (TargetPlayer.PlayerData.charinfo.lastname or '')
    local adminName = src > 0 and GetPlayerName(src) or 'Consola'

    if src > 0 then
        TriggerClientEvent('QBCore:Notify', src, ('Se han retirado %s armas a %s (ID: %s).'):format(removedCount, pName, targetId), 'primary')
    end
    TriggerClientEvent('QBCore:Notify', targetId, 'Un administrador ha retirado todo tu armamento.', 'error')

    TriggerEvent('qb-log:server:CreateLog', 'adminmenu', 'Quitar Armas', 'red', string.format('**%s** retiró todas las armas (%s armas) a **%s** (ID: %s)', adminName, removedCount, GetPlayerName(targetId), targetId), true)
    return true
end

-- =========================================================================
-- EVENTOS NET
-- =========================================================================

RegisterNetEvent('qb-admin:server:giveWeaponToPlayer', function(targetId, weaponName, ammo, giveAmmoBox)
    local src = source
    if not (QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command')) then
        BanPlayer(src)
        return
    end
    giveWeaponInternal(src, targetId, weaponName, ammo, giveAmmoBox)
end)

RegisterNetEvent('qb-admin:server:giveAmmoToPlayer', function(targetId, ammoType, amount)
    local src = source
    if not (QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command')) then
        BanPlayer(src)
        return
    end

    targetId = tonumber(targetId)
    amount = tonumber(amount) or 1
    ammoType = tostring(ammoType or 'pistol_ammo')

    if not QBCore.Shared.Items[ammoType] then
        TriggerClientEvent('QBCore:Notify', src, 'Tipo de munición no válido.', 'error')
        return
    end

    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    if TargetPlayer then
        exports['qb-inventory']:AddItem(targetId, ammoType, amount, false, false, 'Admin Give Ammo')
        TriggerClientEvent('qb-inventory:client:ItemBox', targetId, QBCore.Shared.Items[ammoType], 'add', amount)
        TriggerClientEvent('QBCore:Notify', src, ('Has entregado %s paquetes de %s a ID: %s'):format(amount, QBCore.Shared.Items[ammoType].label or ammoType, targetId), 'success')
        TriggerClientEvent('QBCore:Notify', targetId, ('Has recibido %s paquetes de %s'):format(amount, QBCore.Shared.Items[ammoType].label or ammoType), 'success')
    end
end)

RegisterNetEvent('qb-admin:server:giveArmorToPlayer', function(targetId)
    local src = source
    if not (QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command')) then
        BanPlayer(src)
        return
    end

    targetId = tonumber(targetId)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    if TargetPlayer then
        exports['qb-inventory']:AddItem(targetId, 'heavyarmor', 1, false, false, 'Admin Give Armor')
        TriggerClientEvent('qb-inventory:client:ItemBox', targetId, QBCore.Shared.Items['heavyarmor'], 'add', 1)
        TriggerClientEvent('QBCore:Notify', src, ('Has entregado un Chaleco Blindado a ID: %s'):format(targetId), 'success')
        TriggerClientEvent('QBCore:Notify', targetId, 'Has recibido un Chaleco Blindado de Administración.', 'success')
    end
end)

RegisterNetEvent('qb-admin:server:clearPlayerWeapons', function(targetId)
    local src = source
    if not (QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command')) then
        BanPlayer(src)
        return
    end
    clearWeaponsInternal(src, targetId)
end)

-- =========================================================================
-- COMANDOS DE CHAT DE ADMINISTRACIÓN
-- =========================================================================

-- /dararma [id] [arma] [municion]
QBCore.Commands.Add('dararma', 'Entregar un arma a un jugador (Admin)', {
    { name = 'id', help = 'ID del jugador (o "me" para ti mismo)' },
    { name = 'arma', help = 'Nombre o alias del arma (ej: m4, ak47, glock, combatpistol, spas, sniper, knife)' },
    { name = 'municion', help = 'Cantidad de balas en el cargador (opcional, por defecto 100)' }
}, false, function(source, args)
    local targetInput = args[1]
    local weaponInput = args[2]
    local ammoInput = tonumber(args[3]) or 100

    if not targetInput or not weaponInput then
        TriggerClientEvent('QBCore:Notify', source, 'Uso: /dararma [id/me] [nombre_arma] [municion]', 'error')
        return
    end

    local targetId = (string.lower(tostring(targetInput)) == 'me') and source or tonumber(targetInput)
    giveWeaponInternal(source, targetId, weaponInput, ammoInput, true)
end, 'admin')

-- Alias /giveweapon
QBCore.Commands.Add('giveweapon', 'Entregar un arma a un jugador (Admin)', {
    { name = 'id', help = 'ID del jugador (o "me")' },
    { name = 'arma', help = 'Nombre o alias del arma (ej: m4, ak47, glock, combatpistol, spas, sniper)' },
    { name = 'municion', help = 'Cantidad de balas (opcional)' }
}, false, function(source, args)
    local targetInput = args[1]
    local weaponInput = args[2]
    local ammoInput = tonumber(args[3]) or 100

    if not targetInput or not weaponInput then
        TriggerClientEvent('QBCore:Notify', source, 'Uso: /giveweapon [id/me] [nombre_arma] [municion]', 'error')
        return
    end

    local targetId = (string.lower(tostring(targetInput)) == 'me') and source or tonumber(targetInput)
    giveWeaponInternal(source, targetId, weaponInput, ammoInput, true)
end, 'admin')

-- /quitararmas [id]
QBCore.Commands.Add('quitararmas', 'Retirar todas las armas del inventario de un jugador (Admin)', {
    { name = 'id', help = 'ID del jugador (o "me" para ti mismo)' }
}, false, function(source, args)
    local targetInput = args[1]
    if not targetInput then
        TriggerClientEvent('QBCore:Notify', source, 'Uso: /quitararmas [id/me]', 'error')
        return
    end

    local targetId = (string.lower(tostring(targetInput)) == 'me') and source or tonumber(targetInput)
    clearWeaponsInternal(source, targetId)
end, 'admin')

-- Alias /clearweapons
QBCore.Commands.Add('clearweapons', 'Retirar todas las armas de un jugador (Admin)', {
    { name = 'id', help = 'ID del jugador (o "me")' }
}, false, function(source, args)
    local targetInput = args[1]
    if not targetInput then
        TriggerClientEvent('QBCore:Notify', source, 'Uso: /clearweapons [id/me]', 'error')
        return
    end

    local targetId = (string.lower(tostring(targetInput)) == 'me') and source or tonumber(targetInput)
    clearWeaponsInternal(source, targetId)
end, 'admin')

-- /darbalas [id] [tipo] [cajas]
QBCore.Commands.Add('darbalas', 'Entregar cajas de munición a un jugador (Admin)', {
    { name = 'id', help = 'ID del jugador (o "me")' },
    { name = 'tipo', help = 'pistol, smg, rifle, shotgun, sniper, mg' },
    { name = 'cajas', help = 'Cantidad de cajas (por defecto 2)' }
}, false, function(source, args)
    local targetInput = args[1]
    local typeInput = tostring(args[2] or 'pistol'):lower()
    local amountInput = tonumber(args[3]) or 2

    if not targetInput then
        TriggerClientEvent('QBCore:Notify', source, 'Uso: /darbalas [id/me] [pistol/smg/rifle/shotgun/sniper/mg] [cajas]', 'error')
        return
    end

    local targetId = (string.lower(tostring(targetInput)) == 'me') and source or tonumber(targetInput)
    local ammoItemMap = {
        ['pistol']   = 'pistol_ammo',
        ['pistola']  = 'pistol_ammo',
        ['smg']      = 'smg_ammo',
        ['rifle']    = 'rifle_ammo',
        ['fusil']    = 'rifle_ammo',
        ['shotgun']  = 'shotgun_ammo',
        ['escopeta'] = 'shotgun_ammo',
        ['sniper']   = 'snp_ammo',
        ['franco']   = 'snp_ammo',
        ['mg']       = 'mg_ammo'
    }

    local ammoItem = ammoItemMap[typeInput] or (typeInput .. '_ammo')
    if not QBCore.Shared.Items[ammoItem] then
        TriggerClientEvent('QBCore:Notify', source, 'Tipo de munición no reconocido.', 'error')
        return
    end

    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    if TargetPlayer then
        exports['qb-inventory']:AddItem(targetId, ammoItem, amountInput, false, false, 'Admin Give Ammo Command')
        TriggerClientEvent('qb-inventory:client:ItemBox', targetId, QBCore.Shared.Items[ammoItem], 'add', amountInput)
        TriggerClientEvent('QBCore:Notify', source, ('Entregadas %s cajas de %s a ID: %s'):format(amountInput, QBCore.Shared.Items[ammoItem].label, targetId), 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Jugador no encontrado.', 'error')
    end
end, 'admin')

-- /armas : Información y ayuda de comandos de armamento
QBCore.Commands.Add('armas', 'Ver ayuda de comandos de armamento para administradores', {}, false, function(source)
    TriggerClientEvent('chat:addMessage', source, {
        color = { 239, 68, 68 },
        multiline = true,
        args = { '🔫 SPAIN ROL - COMANDOS DE ARMAS', 'Comandos disponibles:\n' ..
            '• /dararma [id/me] [arma] [municion] (o /giveweapon)\n' ..
            '• /quitararmas [id/me] (o /clearweapons)\n' ..
            '• /darbalas [id/me] [pistol/rifle/smg/shotgun/sniper] [cajas]\n\n' ..
            'Alias de armas populares:\n' ..
            'glock, pistol, ap, deagle, mp5, uzi, pdw, p90, m4, ak47, g36, aug, spas, recortada, sniper, heavysniper, knife, bat, chaleco.'
        }
    })
end, 'admin')


