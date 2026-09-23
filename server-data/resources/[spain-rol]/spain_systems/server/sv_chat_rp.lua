-- =========================================================================
-- SPAIN ROL - SERVIDOR: COMANDOS DE CHAT ROLEPLAY (/anon, /twt, /do, etc.)
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()

-- Función auxiliar para obtener el nombre IC del personaje
local function GetCharacterName(Player)
    if not Player or not Player.PlayerData or not Player.PlayerData.charinfo then
        return "Desconocido"
    end
    local first = Player.PlayerData.charinfo.firstname or ""
    local last = Player.PlayerData.charinfo.lastname or ""
    local fullname = (first .. " " .. last):gsub("^%s*(.-)%s*$", "%1")
    return fullname ~= "" and fullname or Player.PlayerData.name or "Ciudadano"
end

-- =========================================================================
-- 1. COMANDO /anon (Mensaje Anónimo Clandestino)
-- =========================================================================
QBCore.Commands.Add('anon', 'Enviar un mensaje anónimo clandestino por la ciudad', { { name = 'mensaje', help = 'Texto del mensaje anónimo' } }, false, function(source, args)
    if #args < 1 then
        TriggerClientEvent('QBCore:Notify', source, "Debes escribir un mensaje para enviar de forma anónima.", "error")
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local message = table.concat(args, " ")

    -- Envío masivo a todos los jugadores con plantilla anónima
    TriggerClientEvent('chat:addMessage', -1, {
        templateId = 'anon',
        args = { message }
    })

    -- Registro en consola / logs para supervisión de administradores (evita toxicidad)
    print(("^3[CHAT ANÓNIMO]^7 ID: %s | Nombre: %s | CitizenID: %s | Mensaje: %s"):format(source, GetPlayerName(source), Player.PlayerData.citizenid, message))
end)

-- =========================================================================
-- 2. COMANDO /twt Y /twitter (Red Social Twitter)
-- =========================================================================
local function HandleTwitter(source, args)
    if #args < 1 then
        TriggerClientEvent('QBCore:Notify', source, "Debes escribir el texto de tu publicación de Twitter.", "error")
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local charName = GetCharacterName(Player):gsub("%s+", "")
    local message = table.concat(args, " ")

    TriggerClientEvent('chat:addMessage', -1, {
        templateId = 'twt',
        args = { charName, message }
    })
end

QBCore.Commands.Add('twt', 'Publicar un tweet público visible por toda la ciudad', { { name = 'mensaje', help = 'Contenido del tweet' } }, false, HandleTwitter)
QBCore.Commands.Add('twitter', 'Publicar un tweet público visible por toda la ciudad', { { name = 'mensaje', help = 'Contenido del tweet' } }, false, HandleTwitter)

-- =========================================================================
-- 3. COMANDO /do (Descripción de Entorno y Consecuencias)
-- =========================================================================
QBCore.Commands.Add('do', 'Describir el entorno o consecuencias de una situación', { { name = 'descripción', help = 'Descripción del estado o ambiente' } }, false, function(source, args)
    if #args < 1 then
        TriggerClientEvent('QBCore:Notify', source, "Debes detallar la descripción del entorno.", "error")
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local ped = GetPlayerPed(source)
    local pCoords = GetEntityCoords(ped)
    local charName = GetCharacterName(Player)
    local message = table.concat(args, " ")

    local players = QBCore.Functions.GetPlayers()
    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        local tCoords = GetEntityCoords(targetPed)
        if #(pCoords - tCoords) < 25.0 then
            TriggerClientEvent('chat:addMessage', playerId, {
                templateId = 'do',
                args = { charName, message }
            })
            TriggerClientEvent('spain_chat:client:showDo3D', playerId, source, message, charName)
        end
    end
end)

-- =========================================================================
-- 4. COMANDO /policia Y /911 (Llamadas de Urgencia Policial)
-- =========================================================================
local function HandlePoliceCall(source, args)
    if #args < 1 then
        TriggerClientEvent('QBCore:Notify', source, "Indica el motivo de la emergencia policial.", "error")
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local charName = GetCharacterName(Player)
    local message = table.concat(args, " ")
    local officersFound = 0

    local players = QBCore.Functions.GetPlayers()
    for _, playerId in ipairs(players) do
        local targetPlayer = QBCore.Functions.GetPlayer(playerId)
        if targetPlayer and targetPlayer.PlayerData.job.name == 'police' and targetPlayer.PlayerData.job.onduty then
            officersFound = officersFound + 1
            TriggerClientEvent('chat:addMessage', playerId, {
                templateId = 'policia',
                args = { charName, message }
            })
            TriggerClientEvent('QBCore:Notify', playerId, "🚨 Nueva llamada ciudadana al 091: " .. message, "primary", 8000)
        end
    end

    TriggerClientEvent('QBCore:Notify', source, "📞 Centralita 091: Tu llamada ha sido cursada a las unidades de la Policía Nacional disponibles (" .. officersFound .. " patrullas activas).", "success", 7000)
end

QBCore.Commands.Add('policia', 'Llamar a la Policía Nacional para dar un aviso de urgencia', { { name = 'motivo', help = 'Describa el incidente y ubicación' } }, false, HandlePoliceCall)
QBCore.Commands.Add('911', 'Llamar a la Policía Nacional para dar un aviso de urgencia', { { name = 'motivo', help = 'Describa el incidente y ubicación' } }, false, HandlePoliceCall)

-- =========================================================================
-- 5. COMANDO /ems Y /112 (Llamadas de Emergencia Sanitaria)
-- =========================================================================
local function HandleEmsCall(source, args)
    if #args < 1 then
        TriggerClientEvent('QBCore:Notify', source, "Indica la emergencia médica que requieres.", "error")
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local charName = GetCharacterName(Player)
    local message = table.concat(args, " ")
    local emsFound = 0

    local players = QBCore.Functions.GetPlayers()
    for _, playerId in ipairs(players) do
        local targetPlayer = QBCore.Functions.GetPlayer(playerId)
        if targetPlayer and targetPlayer.PlayerData.job.name == 'ambulance' and targetPlayer.PlayerData.job.onduty then
            emsFound = emsFound + 1
            TriggerClientEvent('chat:addMessage', playerId, {
                templateId = 'ems',
                args = { charName, message }
            })
            TriggerClientEvent('QBCore:Notify', playerId, "🚑 Solicitud de Ambulancia 112: " .. message, "error", 8000)
        end
    end

    TriggerClientEvent('QBCore:Notify', source, "📞 Centralita 112: Tu solicitud médica ha sido enviada al personal de urgencias sanitarias (" .. emsFound .. " médicos de guardia).", "success", 7000)
end

QBCore.Commands.Add('ems', 'Solicitar asistencia de Urgencias Sanitarias (112)', { { name = 'motivo', help = 'Describa la urgencia médica' } }, false, HandleEmsCall)
QBCore.Commands.Add('112', 'Solicitar asistencia de Urgencias Sanitarias (112)', { { name = 'motivo', help = 'Describa la urgencia médica' } }, false, HandleEmsCall)

-- =========================================================================
-- 6. COMANDO /ad (Publicidad y Anuncios Clasificados - €100)
-- =========================================================================
QBCore.Commands.Add('ad', 'Publicar un anuncio comercial en la prensa (€100)', { { name = 'anuncio', help = 'Texto de tu oferta o venta' } }, false, function(source, args)
    if #args < 1 then
        TriggerClientEvent('QBCore:Notify', source, "Escribe el contenido de tu anuncio.", "error")
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local price = 100
    if not Player.Functions.RemoveMoney('cash', price, 'newspaper-ad') and not Player.Functions.RemoveMoney('bank', price, 'newspaper-ad') then
        TriggerClientEvent('QBCore:Notify', source, "No dispones de €100 para costear la publicación del anuncio.", "error")
        return
    end

    local charName = GetCharacterName(Player)
    local phone = Player.PlayerData.charinfo.phone or "Sin Teléfono"
    local message = table.concat(args, " ")
    local authorTag = ("%s (Tlf: %s)"):format(charName, phone)

    TriggerClientEvent('chat:addMessage', -1, {
        templateId = 'ad',
        args = { authorTag, message }
    })

    TriggerClientEvent('QBCore:Notify', source, "Tu anuncio ha sido publicado con éxito en la prensa por €100.", "success")
end)

-- =========================================================================
-- 7. COMANDO /ayuda Y /report (Soporte Directo con Staff)
-- =========================================================================
local function HandleStaffReport(source, args)
    if #args < 1 then
        TriggerClientEvent('QBCore:Notify', source, "Indica la duda o problema que deseas trasladar al equipo de administración.", "error")
        return
    end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local charName = GetCharacterName(Player)
    local message = table.concat(args, " ")

    -- Enviar copia al propio jugador
    TriggerClientEvent('chat:addMessage', source, {
        templateId = 'staff',
        args = { tostring(source), charName, message }
    })
    TriggerClientEvent('QBCore:Notify', source, "Tu solicitud ha sido entregada al equipo de administración.", "success")

    -- Enviar a todos los administradores conectados
    local players = QBCore.Functions.GetPlayers()
    for _, playerId in ipairs(players) do
        if QBCore.Functions.HasPermission(playerId, 'admin') or QBCore.Functions.HasPermission(playerId, 'god') then
            if playerId ~= source then
                TriggerClientEvent('chat:addMessage', playerId, {
                    templateId = 'staff',
                    args = { tostring(source), charName, message }
                })
            end
        end
    end
end

QBCore.Commands.Add('ayuda', 'Enviar una consulta o reporte al equipo de Staff', { { name = 'duda', help = 'Describa su problema' } }, false, HandleStaffReport)
QBCore.Commands.Add('report', 'Enviar una consulta o reporte al equipo de Staff', { { name = 'duda', help = 'Describa su problema' } }, false, HandleStaffReport)
