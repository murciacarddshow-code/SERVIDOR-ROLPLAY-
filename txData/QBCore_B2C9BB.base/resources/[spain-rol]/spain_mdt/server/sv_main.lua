local QBCore = exports['qb-core']:GetCoreObject()

-- Búsqueda de ciudadanos por DNI / Nombre
QBCore.Functions.CreateCallback('spain_mdt:server:searchCitizen', function(source, cb, query)
    if not query or query == '' then cb({}) return end

    local queryString = '%' .. query .. '%'
    MySQL.query('SELECT citizenid, charinfo, metadata FROM players WHERE citizenid LIKE ? OR charinfo LIKE ? LIMIT 10', { queryString, queryString }, function(results)
        local formatted = {}
        if results then
            for _, r in ipairs(results) do
                local charinfo = json.decode(r.charinfo) or {}
                table.insert(formatted, {
                    citizenid = r.citizenid,
                    firstname = charinfo.firstname or 'Desconocido',
                    lastname = charinfo.lastname or '',
                    phone = charinfo.phone or 'N/A',
                    birthdate = charinfo.birthdate or 'N/A',
                    gender = charinfo.gender == 0 and 'Hombre' or 'Mujer'
                })
            end
        end
        cb(formatted)
    end)
end)

-- Búsqueda de vehículos por matrícula
QBCore.Functions.CreateCallback('spain_mdt:server:searchVehicle', function(source, cb, plate)
    if not plate or plate == '' then cb(nil) return end

    MySQL.query('SELECT plate, citizenid, vehicle, hash FROM player_vehicles WHERE plate = ? LIMIT 1', { plate }, function(result)
        if result and result[1] then
            local veh = result[1]
            MySQL.query('SELECT charinfo FROM players WHERE citizenid = ?', { veh.citizenid }, function(pRes)
                local ownerName = 'Desconocido'
                if pRes and pRes[1] then
                    local charinfo = json.decode(pRes[1].charinfo) or {}
                    ownerName = (charinfo.firstname or '') .. ' ' .. (charinfo.lastname or '')
                end
                cb({
                    plate = veh.plate,
                    model = veh.vehicle or 'Modelo Estándar',
                    owner = ownerName,
                    citizenid = veh.citizenid
                })
            end)
        else
            cb(nil)
        end
    end)
end)

-- Obtener Código Penal
QBCore.Functions.CreateCallback('spain_mdt:server:getPenalCode', function(source, cb)
    cb(Config.PenalCode or {})
end)

-- Obtener Órdenes de Búsqueda y Captura
QBCore.Functions.CreateCallback('spain_mdt:server:getWarrants', function(source, cb)
    MySQL.query('SELECT * FROM mdt_warrants ORDER BY id DESC LIMIT 20', {}, function(warrants)
        cb(warrants or {})
    end)
end)

-- Emitir Multa
RegisterNetEvent('spain_mdt:server:issueFine', function(data)
    local src = source
    local Officer = QBCore.Functions.GetPlayer(src)
    if not Officer or not data then return end

    local citizenid = data.citizenid
    local amount = tonumber(data.amount) or 100
    local reason = data.reason or 'Infracción de Tráfico'
    local officerName = Officer.PlayerData.charinfo.firstname .. ' ' .. Officer.PlayerData.charinfo.lastname

    MySQL.insert('INSERT INTO mdt_fines (citizenid, amount, reason, officer, date) VALUES (?, ?, ?, ?, NOW())', {
        citizenid, amount, reason, officerName
    })

    local Target = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if Target then
        Target.Functions.RemoveMoney('bank', amount, 'police-fine')
        TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, "Has recibido una sanción policial de €" .. amount .. ": " .. reason, "error", 10000)
    end

    TriggerClientEvent('QBCore:Notify', src, "Sanción registrada correctamente en el sistema MDT.", "success")
end)

-- Emitir Orden de Búsqueda y Captura
RegisterNetEvent('spain_mdt:server:createWarrant', function(data)
    local src = source
    local Officer = QBCore.Functions.GetPlayer(src)
    if not Officer or not data then return end

    local citizenid = data.citizenid
    local name = data.name or 'Desconocido'
    local reason = data.reason or 'Reclamado por la justicia'
    local officerName = Officer.PlayerData.charinfo.firstname .. ' ' .. Officer.PlayerData.charinfo.lastname

    MySQL.insert('INSERT INTO mdt_warrants (citizenid, name, reason, officer, date) VALUES (?, ?, ?, ?, NOW())', {
        citizenid, name, reason, officerName
    })

    TriggerClientEvent('QBCore:Notify', -1, "🚨 MDT: Se ha emitido una Orden de Búsqueda y Captura contra " .. name, "primary")
end)
