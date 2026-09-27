local QBCore = exports['qb-core']:GetCoreObject()

-- Inicialización de Base de Datos (Auto-migración limpia)
MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `studio_songs` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `citizenid` VARCHAR(50) NOT NULL,
            `artist_name` VARCHAR(100) NOT NULL,
            `song_title` VARCHAR(100) NOT NULL,
            `genre` VARCHAR(50) NOT NULL DEFAULT 'Urbano',
            `lyrics` MEDIUMTEXT DEFAULT NULL,
            `beat_id` VARCHAR(50) NOT NULL DEFAULT 'reggaeton_flow',
            `audio_url` TEXT DEFAULT NULL,
            `cover_url` TEXT DEFAULT NULL,
            `bpm` INT(11) DEFAULT 120,
            `duration` INT(11) DEFAULT 180,
            `plays` INT(11) DEFAULT 0,
            `likes` INT(11) DEFAULT 0,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `citizenid` (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

        CREATE TABLE IF NOT EXISTS `studio_likes` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `song_id` INT(11) NOT NULL,
            `citizenid` VARCHAR(50) NOT NULL,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `song_citizen` (`song_id`, `citizenid`),
            CONSTRAINT `fk_studio_likes_song` FOREIGN KEY (`song_id`) REFERENCES `studio_songs` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

        CREATE TABLE IF NOT EXISTS `studio_drafts` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `citizenid` VARCHAR(50) NOT NULL,
            `title` VARCHAR(100) NOT NULL,
            `lyrics` MEDIUMTEXT NOT NULL,
            `genre` VARCHAR(50) DEFAULT 'Urbano',
            `bpm` INT(11) DEFAULT 120,
            `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `citizenid` (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
    print("^2[Spain Rol Studio]^7 Tablas de estudio de grabacion Vinewood A-Records inicializadas correctamente.")
end)

-- Obtener datos iniciales del estudio y Top Éxitos
QBCore.Functions.CreateCallback('spain_recordstudio:server:getStudioData', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return cb(nil) end

    local citizenid = Player.PlayerData.citizenid
    local charName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname

    -- Consultar Top Canciones del Billboard
    local topSongs = MySQL.query.await([[
        SELECT s.*, 
        EXISTS(SELECT 1 FROM studio_likes l WHERE l.song_id = s.id AND l.citizenid = ?) as user_liked
        FROM studio_songs s 
        ORDER BY (s.likes * 3 + s.plays) DESC, s.id DESC 
        LIMIT 30
    ]], { citizenid }) or {}

    -- Consultar borradores de letras del jugador
    local drafts = MySQL.query.await([[
        SELECT * FROM studio_drafts WHERE citizenid = ? ORDER BY updated_at DESC LIMIT 10
    ]], { citizenid }) or {}

    -- Consultar canciones publicadas del jugador
    local mySongs = MySQL.query.await([[
        SELECT * FROM studio_songs WHERE citizenid = ? ORDER BY id DESC LIMIT 20
    ]], { citizenid }) or {}

    cb({
        citizenid = citizenid,
        playerName = charName,
        cash = Player.PlayerData.money['cash'] or 0,
        bank = Player.PlayerData.money['bank'] or 0,
        topSongs = topSongs,
        drafts = drafts,
        mySongs = mySongs,
        pressCost = Config.VinylPressCost,
        defaultBeats = Config.DefaultBeats,
        defaultCovers = Config.DefaultCovers
    })
end)

-- Guardar / Actualizar borrador de letras
RegisterNetEvent('spain_recordstudio:server:saveDraft', function(draftData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not draftData then return end

    local citizenid = Player.PlayerData.citizenid
    local title = draftData.title or "Nueva Canción"
    local lyrics = draftData.lyrics or ""
    local genre = draftData.genre or "Urbano"
    local bpm = tonumber(draftData.bpm) or 120

    if draftData.id then
        MySQL.update.await([[
            UPDATE studio_drafts SET title = ?, lyrics = ?, genre = ?, bpm = ? WHERE id = ? AND citizenid = ?
        ]], { title, lyrics, genre, bpm, draftData.id, citizenid })
        TriggerClientEvent('QBCore:Notify', src, 'Borrador actualizado con éxito', 'success')
    else
        MySQL.insert.await([[
            INSERT INTO studio_drafts (citizenid, title, lyrics, genre, bpm) VALUES (?, ?, ?, ?, ?)
        ]], { citizenid, title, lyrics, genre, bpm })
        TriggerClientEvent('QBCore:Notify', src, 'Nuevo borrador guardado en tu cuaderno', 'success')
    end
end)

-- Prensado y Masterización de Vinilo Oficial
RegisterNetEvent('spain_recordstudio:server:pressVinyl', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data then return end

    local citizenid = Player.PlayerData.citizenid
    local artist = (data.artist and data.artist ~= "") and data.artist or (Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname)
    local title = (data.title and data.title ~= "") and data.title or "Sin Título"
    local genre = data.genre or "Urbano"
    local lyrics = data.lyrics or ""
    local beatId = data.beatId or "reggaeton_flow"
    local audioUrl = data.audioUrl or ""
    local coverUrl = (data.coverUrl and data.coverUrl ~= "") and data.coverUrl or Config.DefaultCovers[1]
    local bpm = tonumber(data.bpm) or 120
    local duration = tonumber(data.duration) or 180

    local cost = Config.VinylPressCost

    -- Cobrar coste de prensado
    if Player.PlayerData.money.bank >= cost then
        Player.Functions.RemoveMoney('bank', cost, 'studio-vinyl-press')
    elseif Player.PlayerData.money.cash >= cost then
        Player.Functions.RemoveMoney('cash', cost, 'studio-vinyl-press')
    else
        TriggerClientEvent('QBCore:Notify', src, 'No tienes suficiente dinero en efectivo ni en el banco (' .. cost .. '€)', 'error')
        return
    end

    -- Insertar canción en el catálogo del servidor
    local songId = MySQL.insert.await([[
        INSERT INTO studio_songs (citizenid, artist_name, song_title, genre, lyrics, beat_id, audio_url, cover_url, bpm, duration)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        citizenid, artist, title, genre, lyrics, beatId, audioUrl, coverUrl, bpm, duration
    })

    -- Crear el ítem de Vinilo Físico con metadata personalizada
    local itemInfo = {
        song_id = songId,
        song_title = title,
        artist_name = artist,
        genre = genre,
        audio_url = audioUrl,
        cover_url = coverUrl,
        bpm = bpm,
        duration = duration,
        pressed_date = os.date("%d/%m/%Y")
    }

    local added = Player.Functions.AddItem('disco_musica', 1, false, itemInfo)
    if added then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['disco_musica'], 'add')
        TriggerClientEvent('QBCore:Notify', src, '¡Disco de vinilo prensado con éxito! Recibes "' .. title .. '" en tu inventario', 'success')

        -- Anuncio global en Los Santos
        TriggerClientEvent('chat:addMessage', -1, {
            template = '<div style="padding: 10px 14px; margin: 6px 0; background: linear-gradient(135deg, rgba(225, 29, 72, 0.9), rgba(139, 92, 246, 0.9)); color: white; border-radius: 8px; font-family: sans-serif; box-shadow: 0 4px 15px rgba(0,0,0,0.4);"><span style="font-size: 16px;">🎙️ <b>VINEWOOD A-RECORDS</b></span><br><span style="font-size: 14px;">El artista <b>{0}</b> acaba de lanzar su nuevo single oficial <b>«{1}»</b> ({2}). ¡Ya disponible en las tiendas de música y en vinilo!</span></div>',
            args = { artist, title, genre }
        })
    else
        TriggerClientEvent('QBCore:Notify', src, 'No tienes espacio suficiente en el inventario para el disco', 'error')
    end
end)

-- Sistema de Dar Like / Fuego a canciones
RegisterNetEvent('spain_recordstudio:server:likeSong', function(songId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not songId then return end

    local citizenid = Player.PlayerData.citizenid

    local existing = MySQL.single.await([[
        SELECT id FROM studio_likes WHERE song_id = ? AND citizenid = ?
    ]], { songId, citizenid })

    if existing then
        -- Quitar like
        MySQL.query.await([[ DELETE FROM studio_likes WHERE song_id = ? AND citizenid = ? ]], { songId, citizenid })
        MySQL.query.await([[ UPDATE studio_songs SET likes = GREATEST(0, likes - 1) WHERE id = ? ]], { songId })
        TriggerClientEvent('QBCore:Notify', src, 'Has quitado tu apoyo a esta canción', 'primary')
    else
        -- Añadir like
        MySQL.insert.await([[ INSERT INTO studio_likes (song_id, citizenid) VALUES (?, ?) ]], { songId, citizenid })
        MySQL.query.await([[ UPDATE studio_songs SET likes = likes + 1 WHERE id = ? ]], { songId })
        TriggerClientEvent('QBCore:Notify', src, '¡Le has dado FUEGO a la canción! 🔥', 'success')
    end

    -- Devolver datos actualizados al cliente
    local updated = MySQL.single.await([[ SELECT likes FROM studio_songs WHERE id = ? ]], { songId })
    TriggerClientEvent('spain_recordstudio:client:updateSongLikes', src, songId, updated and updated.likes or 0, not existing)
end)

-- Incrementar reproducciones
RegisterNetEvent('spain_recordstudio:server:incrementPlays', function(songId)
    if not songId then return end
    MySQL.query([[ UPDATE studio_songs SET plays = plays + 1 WHERE id = ? ]], { songId })
end)

-- Sincronizar audio en directo en el estudio entre jugadores cercanos
RegisterNetEvent('spain_recordstudio:server:syncStudioAudio', function(audioPayload)
    local src = source
    local pPed = GetPlayerPed(src)
    local pCoords = GetEntityCoords(pPed)

    -- Retransmitir a todos los jugadores cercanos a las coordenadas del estudio
    local players = QBCore.Functions.GetPlayers()
    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local dist = #(targetCoords - Config.Zones.mixer.coords)

        if dist <= Config.StudioSoundRadius + 15.0 then
            TriggerClientEvent('spain_recordstudio:client:syncStudioAudio', playerId, audioPayload, Config.Zones.mixer.coords)
        end
    end
end)

-- Registrar Ítem Usable: Disco de Vinilo
QBCore.Functions.CreateUseableItem('disco_musica', function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not item or not item.info then return end

    TriggerClientEvent('spain_recordstudio:client:playVinylItem', src, item.info)
end)
