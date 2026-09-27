-- =========================================================================
-- SPAIN ROL - EXPEDICIÓN Y RECUPERACIÓN DE DNI ESPAÑOL (SERVIDOR)
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()
local DNI_PRICE = 100

RegisterNetEvent('spain_police:server:reissueDNI', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local charinfo = Player.PlayerData.charinfo
    local citizenid = Player.PlayerData.citizenid

    -- Verificar fondos (efectivo o banco)
    local hasCash = Player.Functions.GetMoney('cash') >= DNI_PRICE
    local hasBank = Player.Functions.GetMoney('bank') >= DNI_PRICE

    if not hasCash and not hasBank then
        TriggerClientEvent('QBCore:Notify', src, "No dispones de suficiente dinero (100€) en efectivo ni en tu cuenta bancaria.", "error", 6000)
        return
    end

    -- Descontar el importe oficial
    if hasCash then
        Player.Functions.RemoveMoney('cash', DNI_PRICE, "duplicado-dni-policia")
    else
        Player.Functions.RemoveMoney('bank', DNI_PRICE, "duplicado-dni-policia")
    end

    -- Construir metadatos oficiales del DNI
    local info = {
        citizenid = citizenid,
        firstname = charinfo.firstname or 'Ciudadano',
        lastname = charinfo.lastname or 'Desconocido',
        birthdate = charinfo.birthdate or '01/01/2000',
        gender = charinfo.gender or 0,
        nationality = charinfo.nationality or 'Española'
    }

    -- Entregar tarjeta de identidad estándar e ítem temático español
    Player.Functions.AddItem('id_card', 1, false, info)
    Player.Functions.AddItem('dni_espana', 1, false, info)

    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['id_card'] or { name = 'id_card', label = 'DNI' }, 'add')

    TriggerClientEvent('chat:addMessage', src, {
        template = '<div style="padding: 10px; margin: 6px 0; background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%); color: #fff; border-radius: 8px; border-left: 5px solid #2ecc71; font-family: sans-serif;"><div style="font-weight: bold; font-size: 13px;">🇪🇸 POLICÍA NACIONAL &bull; OFICINA DE EXPEDICIÓN</div><div style="font-size: 12px; margin-top: 4px;">Se ha emitido con éxito el duplicado de tu <b>DNI Español</b> a nombre de <b>{0} {1}</b> con identificador <b>{2}</b>. Tasa abonada: {3}€.</div></div>',
        args = { info.firstname, info.lastname, info.citizenid, tostring(DNI_PRICE) }
    })

    TriggerClientEvent('QBCore:Notify', src, "Has recuperado un duplicado oficial de tu DNI (-100€).", "success", 7000)
end)
