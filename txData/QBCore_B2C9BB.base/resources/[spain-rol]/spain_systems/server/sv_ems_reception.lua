-- =========================================================================
-- SPAIN ROL - ATENCIÓN SANITARIA EN RECEPCIÓN PILLBOX (SERVIDOR)
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()
local CHECKIN_COST = 150
local CARD_COST = 100

-- Chequeo y curación en recepción
RegisterNetEvent('spain_ems:server:processCheckin', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local hasCash = Player.Functions.GetMoney('cash') >= CHECKIN_COST
    local hasBank = Player.Functions.GetMoney('bank') >= CHECKIN_COST

    if not hasCash and not hasBank then
        TriggerClientEvent('QBCore:Notify', src, "No dispones de suficiente dinero (" .. CHECKIN_COST .. "€) para el reconocimiento médico.", "error", 6000)
        return
    end

    if hasCash then
        Player.Functions.RemoveMoney('cash', CHECKIN_COST, "chequeo-medico-pillbox")
    else
        Player.Functions.RemoveMoney('bank', CHECKIN_COST, "chequeo-medico-pillbox")
    end

    -- Curar heridas y restablecer salud
    TriggerClientEvent('hospital:client:HealInjuries', src, 'full')
    local ped = GetPlayerPed(src)
    SetEntityHealth(ped, 200)

    TriggerClientEvent('chat:addMessage', src, {
        template = '<div style="padding: 10px; margin: 6px 0; background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); color: #0a3d24; border-radius: 8px; border-left: 5px solid #00b894; font-family: sans-serif;"><div style="font-weight: bold; font-size: 13px;">🏥 HOSPITAL PILLBOX HILL &bull; INFORME DE CONSULTA</div><div style="font-size: 12px; margin-top: 4px;">Has recibido tratamiento de urgencia, vendaje de traumatismos y estabilización. Tasa hospitalaria abonada: <b>{0}€</b>.</div></div>',
        args = { tostring(CHECKIN_COST) }
    })

    TriggerClientEvent('QBCore:Notify', src, "Has sido curado por el facultativo de guardia (-" .. CHECKIN_COST .. "€).", "success", 7000)
end)

-- Expedición de duplicado de tarjeta sanitaria / DNI
RegisterNetEvent('spain_ems:server:reissueHealthCard', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local charinfo = Player.PlayerData.charinfo
    local citizenid = Player.PlayerData.citizenid

    local hasCash = Player.Functions.GetMoney('cash') >= CARD_COST
    local hasBank = Player.Functions.GetMoney('bank') >= CARD_COST

    if not hasCash and not hasBank then
        TriggerClientEvent('QBCore:Notify', src, "No dispones de suficiente dinero (" .. CARD_COST .. "€) para expedir tu documentación.", "error", 6000)
        return
    end

    if hasCash then
        Player.Functions.RemoveMoney('cash', CARD_COST, "tarjeta-sanitaria-pillbox")
    else
        Player.Functions.RemoveMoney('bank', CARD_COST, "tarjeta-sanitaria-pillbox")
    end

    local info = {
        citizenid = citizenid,
        firstname = charinfo.firstname or 'Ciudadano',
        lastname = charinfo.lastname or 'Desconocido',
        birthdate = charinfo.birthdate or '01/01/2000',
        gender = charinfo.gender or 0,
        nationality = charinfo.nationality or 'Española'
    }

    Player.Functions.AddItem('id_card', 1, false, info)
    Player.Functions.AddItem('dni_espana', 1, false, info)

    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['id_card'] or { name = 'id_card', label = 'DNI' }, 'add')

    TriggerClientEvent('chat:addMessage', src, {
        template = '<div style="padding: 10px; margin: 6px 0; background: linear-gradient(135deg, #0984e3 0%, #74b9ff 100%); color: #fff; border-radius: 8px; border-left: 5px solid #2ecc71; font-family: sans-serif;"><div style="font-weight: bold; font-size: 13px;">🪪 SERVICIO DE SALUD &bull; TARJETA SANITARIA SIP</div><div style="font-size: 12px; margin-top: 4px;">Se ha emitido tu tarjeta sanitaria y acreditación ciudadana a nombre de <b>{0} {1}</b> (Nº Historia / DNI: <b>{2}</b>).</div></div>',
        args = { info.firstname, info.lastname, info.citizenid }
    })

    TriggerClientEvent('QBCore:Notify', src, "Tarjeta Sanitaria y DNI expedidos con éxito (-" .. CARD_COST .. "€).", "success", 7000)
end)
