-- =========================================================================
-- SPAIN ROL - MARCADORES Y ACCIONES POLICIALES MISSION ROW (SERVIDOR)
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()

-- =========================================================================
-- 1. GESTIÓN DE ARMERÍA POLICIAL CNP
-- =========================================================================
RegisterNetEvent("spain_police:server:giveArmoryItem", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.PlayerData.job.type ~= 'leo' and Player.PlayerData.job.name ~= 'police' then
        TriggerClientEvent('QBCore:Notify', src, "No tienes permiso para acceder a la armería.", "error")
        return
    end

    if data.type == 'full_kit' then
        Player.Functions.AddItem('weapon_stungun', 1)
        Player.Functions.AddItem('weapon_combatpistol', 1)
        Player.Functions.AddItem('pistol_ammo', 2)
        Player.Functions.AddItem('weapon_nightstick', 1)
        Player.Functions.AddItem('weapon_flashlight', 1)
        Player.Functions.AddItem('heavyarmor', 1)
        Player.Functions.AddItem('handcuffs', 2)
        Player.Functions.AddItem('firstaid', 2)

        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['weapon_combatpistol'] or { name = 'weapon_combatpistol', label = 'Pistola de Combate' }, 'add')
        TriggerClientEvent('QBCore:Notify', src, "Has retirado tu Dotación Completa de Servicio CNP.", "success", 6000)

    elseif data.type == 'traffic_kit' then
        Player.Functions.AddItem('police_radar', 1)
        Player.Functions.AddItem('police_breathalyzer', 1)
        Player.Functions.AddItem('police_narcotest', 2)
        Player.Functions.AddItem('police_spikes', 1)

        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['police_radar'] or { name = 'police_radar', label = 'Radar Láser' }, 'add')
        TriggerClientEvent('QBCore:Notify', src, "Has retirado el Kit de Tráfico e Inspección.", "success", 5000)

    elseif data.type == 'return_weapons' then
        local returnedItems = {
            'weapon_stungun', 'weapon_combatpistol', 'weapon_nightstick',
            'weapon_flashlight', 'weapon_pumpshotgun', 'weapon_carbinerifle',
            'heavyarmor', 'police_radar', 'police_breathalyzer', 'police_spikes'
        }

        for _, item in ipairs(returnedItems) do
            local current = Player.Functions.GetItemByName(item)
            if current then
                Player.Functions.RemoveItem(item, current.amount or 1)
            end
        end

        TriggerClientEvent('QBCore:Notify', src, "Has entregado todo el armamento y equipo reglamentario en el armero.", "primary", 5000)

    elseif data.item then
        local amount = data.amount or 1
        Player.Functions.AddItem(data.item, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[data.item] or { name = data.item, label = data.item }, 'add')

        if data.ammo then
            Player.Functions.AddItem(data.ammo, 2)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[data.ammo] or { name = data.ammo, label = data.ammo }, 'add')
        end

        TriggerClientEvent('QBCore:Notify', src, "Equipo retirado de la armería.", "success", 4000)
    end
end)

-- =========================================================================
-- 2. DEPÓSITO JUDICIAL DE PRUEBAS (APERTURA Y LIMPIEZA)
-- =========================================================================
RegisterNetEvent("spain_police:server:openEvidenceStash", function(stashId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.PlayerData.job.type ~= 'leo' and Player.PlayerData.job.name ~= 'police' then
        TriggerClientEvent('QBCore:Notify', src, "Acceso restringido a agentes de policía.", "error")
        return
    end

    exports['qb-inventory']:OpenInventory(src, stashId, {
        maxweight = 4000000,
        slots = 500,
    })
end)

-- Limpiar / Eliminar pruebas para no saturar la base de datos ni el servidor
RegisterNetEvent("spain_police:server:clearEvidenceStash", function(stashId, caseNumber)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.PlayerData.job.type ~= 'leo' and Player.PlayerData.job.name ~= 'police' then
        TriggerClientEvent('QBCore:Notify', src, "Acceso restringido a agentes de policía.", "error")
        return
    end

    -- 1. Vaciar de la memoria de qb-inventory
    if exports['qb-inventory'].ClearStash then
        exports['qb-inventory']:ClearStash(stashId)
    end

    -- 2. Eliminar registros de la base de datos (inventories y stashitems)
    MySQL.query('DELETE FROM inventories WHERE identifier = ?', { stashId })
    MySQL.query('DELETE FROM stashitems WHERE stash = ?', { stashId })

    -- 3. Notificar a los agentes y confirmar
    local officerName = (Player.PlayerData.charinfo.firstname or 'Agente') .. ' ' .. (Player.PlayerData.charinfo.lastname or '')
    TriggerClientEvent('QBCore:Notify', src, "Las pruebas del caso #" .. caseNumber .. " han sido archivadas y eliminadas del depósito judicial.", "success", 7000)

    -- Registro en el chat policial
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and (v.PlayerData.job.type == 'leo' or v.PlayerData.job.name == 'police') and v.PlayerData.job.onduty then
            TriggerClientEvent('chat:addMessage', v.PlayerData.source, {
                template = '<div style="padding: 10px; margin: 5px 0; background: rgba(39, 174, 96, 0.2); border-left: 4px solid #2ecc71; color: #dfe6e9; border-radius: 6px; font-size: 13px;"><b>⚖️ DEPÓSITO JUDICIAL:</b> El agente {0} ha archivado y liberado las pruebas del caso #{1}.</div>',
                args = { officerName, tostring(caseNumber) }
            })
        end
    end
end)

-- =========================================================================
-- 3. ESCÁNER BIOMÉTRICO DE HUELLAS DACTILARES CON SALIDA AL CHAT
-- =========================================================================
RegisterNetEvent("spain_police:server:processFingerprintScan", function(targetServerId)
    local src = source
    local Officer = QBCore.Functions.GetPlayer(src)
    if not Officer then return end

    local Target = QBCore.Functions.GetPlayer(tonumber(targetServerId))
    if not Target then
        TriggerClientEvent('QBCore:Notify', src, "No se ha encontrado al sujeto en la sala de fichaje.", "error")
        return
    end

    local charinfo = Target.PlayerData.charinfo or {}
    local citizenid = Target.PlayerData.citizenid or "ES-000000"
    local fullName = (charinfo.firstname or 'Desconocido') .. ' ' .. (charinfo.lastname or '')
    local birthdate = charinfo.birthdate or 'N/A'
    local phone = charinfo.phone or 'N/A'
    local bankMoney = Target.PlayerData.money and Target.PlayerData.money['bank'] or 0
    local licenses = Target.PlayerData.metadata and Target.PlayerData.metadata['licences'] or {}

    local driverLic = licenses['driver'] and "VIGENTE" or "NO AUTORIZADO"
    local weaponLic = licenses['weapon'] and "AUTORIZADA (TIPO B)" or "NO AUTORIZADO"

    -- Comprobar si tiene orden de busca y captura en mdt_warrants
    MySQL.query('SELECT * FROM mdt_warrants WHERE citizenid = ? LIMIT 1', { citizenid }, function(warrants)
        local statusText = "LIMPIO &bull; SIN RECLAMACIONES JUDICIALES PENDIENTES"
        local statusColor = "#2ecc71"

        if warrants and #warrants > 0 then
            statusText = "🚨 ¡EN BUSCA Y CAPTURA ACTIVA! (" .. (warrants[1].reason or 'Orden Judicial') .. ")"
            statusColor = "#e74c3c"
        end

        local chatTemplate = '<div style="padding: 14px 16px; margin: 8px 0; background: linear-gradient(135deg, #0b141d 0%, #172a3a 50%, #203f53 100%); color: #ecf0f1; border-radius: 10px; border-left: 6px solid #0984e3; box-shadow: 0 4px 14px rgba(0,0,0,0.5); font-family: sans-serif;">' ..
            '<div style="font-weight: 800; font-size: 14px; text-transform: uppercase; border-bottom: 1px solid rgba(255,255,255,0.15); padding-bottom: 6px; margin-bottom: 8px; color: #74b9ff; letter-spacing: 0.5px;">' ..
            '🏛️ POLICÍA NACIONAL &bull; FICHA BIOMÉTRICA DACTILAR' ..
            '</div>' ..
            '<div style="font-size: 13px; line-height: 1.7;">' ..
            '<b>👤 Nombre y Apellidos:</b> {0}<br>' ..
            '<b>🆔 DNI / CitizenID:</b> <span style="color:#ffeaa7;">{1}</span><br>' ..
            '<b>📅 Fecha de Nacimiento:</b> {2} &nbsp;&bull;&nbsp; <b>📞 Teléfono:</b> {3}<br>' ..
            '<b>💳 Saldo en Cuenta Bancaria:</b> {4}€<br>' ..
            '<b>🪪 Permisos Oficiales:</b> Conducir: <span style="color:#00cec9;">{5}</span> &nbsp;&bull;&nbsp; Armas: <span style="color:#fab1a0;">{6}</span><br>' ..
            '<b>⚖️ Estado Judicial:</b> <span style="font-weight:bold; color:' .. statusColor .. ';">{7}</span>' ..
            '</div>' ..
            '</div>'

        local chatArgs = {
            fullName,
            citizenid,
            birthdate,
            phone,
            string.format("%s", bankMoney),
            driverLic,
            weaponLic,
            statusText
        }

        -- Enviar reporte al agente y al sujeto escaneado
        TriggerClientEvent('chat:addMessage', src, {
            template = chatTemplate,
            args = chatArgs
        })

        if Target.PlayerData.source ~= src then
            TriggerClientEvent('chat:addMessage', Target.PlayerData.source, {
                template = chatTemplate,
                args = chatArgs
            })
        end

        TriggerClientEvent('QBCore:Notify', src, "Ficha biométrica de " .. fullName .. " procesada y enviada al chat.", "success")
    end)
end)
