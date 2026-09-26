-- =========================================================================
-- SPAIN ROL - MARCADORES Y ACCIONES SANITARIAS PILLBOX (SERVIDOR)
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()

-- =========================================================================
-- 1. GESTIÓN DE FARMACIA Y SUMINISTROS MÉDICOS SAMUR
-- =========================================================================
RegisterNetEvent("spain_ems:server:givePharmacyItem", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.PlayerData.job.name ~= 'ambulance' and not QBCore.Functions.HasPermission('admin') then
        TriggerClientEvent('QBCore:Notify', src, "No tienes autorización para acceder a la farmacia del hospital.", "error")
        return
    end

    if data.type == 'full_kit' then
        Player.Functions.AddItem('firstaid', 3)
        Player.Functions.AddItem('bandage', 5)
        Player.Functions.AddItem('painkillers', 3)
        Player.Functions.AddItem('ifaks', 2)

        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['firstaid'] or { name = 'firstaid', label = 'Botiquín' }, 'add')
        TriggerClientEvent('QBCore:Notify', src, "Has retirado tu Dotación Completa de Guardia Sanitaria.", "success", 6000)

    elseif data.type == 'return_supplies' then
        local returnedItems = { 'firstaid', 'bandage', 'painkillers', 'ifaks' }
        for _, item in ipairs(returnedItems) do
            local current = Player.Functions.GetItemByName(item)
            if current then
                Player.Functions.RemoveItem(item, current.amount or 1)
            end
        end
        TriggerClientEvent('QBCore:Notify', src, "Has entregado todos los suministros médicos en el almacén de farmacia.", "primary", 5000)

    elseif data.item then
        local amount = data.amount or 1
        Player.Functions.AddItem(data.item, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[data.item] or { name = data.item, label = data.item }, 'add')
        TriggerClientEvent('QBCore:Notify', src, "Material retirado de farmacia.", "success", 4000)
    end
end)

-- =========================================================================
-- 2. DEPÓSITO CLÍNICO DE MUESTRAS (APERTURA Y LIMPIEZA)
-- =========================================================================
RegisterNetEvent("spain_ems:server:openSampleStash", function(stashId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.PlayerData.job.name ~= 'ambulance' and not QBCore.Functions.HasPermission('admin') then
        TriggerClientEvent('QBCore:Notify', src, "Acceso restringido a personal sanitario.", "error")
        return
    end

    exports['qb-inventory']:OpenInventory(src, stashId, {
        maxweight = 4000000,
        slots = 500,
    })
end)

-- Limpieza y purga de muestras clínicas de la base de datos
RegisterNetEvent("spain_ems:server:clearSampleStash", function(stashId, caseNumber)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.PlayerData.job.name ~= 'ambulance' and not QBCore.Functions.HasPermission('admin') then
        TriggerClientEvent('QBCore:Notify', src, "Acceso restringido a personal sanitario.", "error")
        return
    end

    -- 1. Vaciar memoria de qb-inventory
    if exports['qb-inventory'].ClearStash then
        exports['qb-inventory']:ClearStash(stashId)
    end

    -- 2. Eliminar registros de la base de datos
    MySQL.query('DELETE FROM inventories WHERE identifier = ?', { stashId })
    MySQL.query('DELETE FROM stashitems WHERE stash = ?', { stashId })

    local doctorName = (Player.PlayerData.charinfo.firstname or 'Facultativo') .. ' ' .. (Player.PlayerData.charinfo.lastname or '')
    TriggerClientEvent('QBCore:Notify', src, "Las muestras del expediente #" .. caseNumber .. " han sido archivadas y eliminadas del depósito clínico.", "success", 7000)

    -- Notificar al equipo médico
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.name == 'ambulance' and v.PlayerData.job.onduty then
            TriggerClientEvent('chat:addMessage', v.PlayerData.source, {
                template = '<div style="padding: 10px; margin: 5px 0; background: rgba(0, 184, 148, 0.2); border-left: 4px solid #00b894; color: #dfe6e9; border-radius: 6px; font-size: 13px;"><b>🧪 LABORATORIO CLÍNICO:</b> El facultativo {0} ha archivado y liberado las muestras del expediente #{1}.</div>',
                args = { doctorName, tostring(caseNumber) }
            })
        end
    end
end)

-- =========================================================================
-- 3. MONITOR BIOMÉTRICO DE CONSTANTES VITALES CON SALIDA AL CHAT
-- =========================================================================
local bloodTypes = { "0+", "A+", "B+", "AB+", "0-", "A-", "B-", "AB-" }

RegisterNetEvent("spain_ems:server:processBiometricScan", function(targetServerId)
    local src = source
    local Doctor = QBCore.Functions.GetPlayer(src)
    if not Doctor then return end

    local Target = QBCore.Functions.GetPlayer(tonumber(targetServerId))
    if not Target then
        TriggerClientEvent('QBCore:Notify', src, "No se ha detectado a ningún paciente en la camilla de triaje.", "error")
        return
    end

    local charinfo = Target.PlayerData.charinfo or {}
    local citizenid = Target.PlayerData.citizenid or "ES-000000"
    local fullName = (charinfo.firstname or 'Desconocido') .. ' ' .. (charinfo.lastname or '')
    local birthdate = charinfo.birthdate or 'N/A'
    local phone = charinfo.phone or 'N/A'

    -- Constantes vitales dinámicas
    local targetPed = GetPlayerPed(Target.PlayerData.source)
    local health = GetEntityHealth(targetPed)
    local isDead = (health <= 0 or Target.PlayerData.metadata['isdead'] or Target.PlayerData.metadata['inlaststand'])

    -- Grupo sanguíneo determinista basado en el ID
    local charHash = 1
    for i = 1, #citizenid do
        charHash = charHash + string.byte(citizenid, i)
    end
    local bloodGroup = bloodTypes[(charHash % #bloodTypes) + 1]

    local bpm = isDead and 0 or math.random(72, 86)
    local o2 = isDead and 0 or (health > 150 and math.random(97, 99) or math.random(88, 93))
    local bp = isDead and "0 / 0" or (health > 150 and "120 / 80" or "95 / 60")
    local temp = isDead and "32.0" or "36.6"

    local conditionStatus = "ESTABLE &bull; CONSTANTES EN RANGO FISIOLÓGICO"
    local statusColor = "#2ecc71"

    if isDead then
        conditionStatus = "PARADA CARDIORRESPIRATORIA &bull; ¡REQUIERE RCP Y DESFIBRILADOR!"
        statusColor = "#e74c3c"
    elseif health < 150 then
        conditionStatus = "TRAUMATISMO ACTIVO &bull; REQUIERE VENDAJE Y ANALGÉSICOS"
        statusColor = "#f39c12"
    end

    local chatTemplate = '<div style="padding: 14px 16px; margin: 8px 0; background: linear-gradient(135deg, #09203f 0%, #1e4258 50%, #295264 100%); color: #ecf0f1; border-radius: 10px; border-left: 6px solid #00cec9; box-shadow: 0 4px 14px rgba(0,0,0,0.5); font-family: sans-serif;">' ..
        '<div style="font-weight: 800; font-size: 14px; text-transform: uppercase; border-bottom: 1px solid rgba(255,255,255,0.15); padding-bottom: 6px; margin-bottom: 8px; color: #81ecec; letter-spacing: 0.5px;">' ..
        '🏥 SAMUR &bull; MONITORIZACIÓN CLÍNICA DE CONSTANTES VITALES' ..
        '</div>' ..
        '<div style="font-size: 13px; line-height: 1.7;">' ..
        '<b>👤 Paciente:</b> {0} &nbsp;&bull;&nbsp; <b>🆔 DNI / Historia:</b> <span style="color:#ffeaa7;">{1}</span><br>' ..
        '<b>🩸 Grupo Sanguíneo:</b> <span style="color:#ff7675; font-weight:bold;">{2}</span> &nbsp;&bull;&nbsp; <b>📅 Fecha Nac.:</b> {3}<br>' ..
        '<b>❤️ Ritmo Cardíaco:</b> {4} BPM &nbsp;&bull;&nbsp; <b>🫁 Saturación O₂:</b> {5}%<br>' ..
        '<b>🩺 Tensión Arterial:</b> {6} mmHg &nbsp;&bull;&nbsp; <b>🌡️ Temperatura:</b> {7} °C<br>' ..
        '<b>📊 Diagnóstico Clínico:</b> <span style="font-weight:bold; color:' .. statusColor .. ';">{8}</span>' ..
        '</div>' ..
        '</div>'

    local chatArgs = {
        fullName,
        citizenid,
        bloodGroup,
        birthdate,
        tostring(bpm),
        tostring(o2),
        bp,
        temp,
        conditionStatus
    }

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

    TriggerClientEvent('QBCore:Notify', src, "Informe biométrico de constantes de " .. fullName .. " procesado en el chat.", "success")
end)
