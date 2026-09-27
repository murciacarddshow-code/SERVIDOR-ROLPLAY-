local QBCore = exports['qb-core']:GetCoreObject()
local isUIOpen = false
local headphoneProp = nil
local microphoneProp = nil

-- Crear Blip en el mapa de Los Santos
CreateThread(function()
    if not Config.Blip.enable then return end
    local blip = AddBlipForCoord(Config.Blip.coords.x, Config.Blip.coords.y, Config.Blip.coords.z)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.label)
    EndTextCommandSetBlipName(blip)
end)

-- Utilidad: Dibujar texto 3D en el mundo
local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 20, 20, 20, 180)
    end
end

-- Limpieza de props adjuntos
local function CleanupProps()
    if headphoneProp and DoesEntityExist(headphoneProp) then
        DeleteEntity(headphoneProp)
        headphoneProp = nil
    end
    if microphoneProp and DoesEntityExist(microphoneProp) then
        DeleteEntity(microphoneProp)
        microphoneProp = nil
    end
    ClearPedTasks(PlayerPedId())
end

-- Abrir Interfaz NUI del Estudio
local function OpenStudioUI(initialTab)
    if isUIOpen then return end

    QBCore.Functions.TriggerCallback('spain_recordstudio:server:getStudioData', function(data)
        if not data then
            QBCore.Functions.Notify('No se pudo conectar con los servidores de Vinewood Records', 'error')
            return
        end

        isUIOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openStudio",
            tab = initialTab or "mixer",
            data = data
        })
    end)
end

-- Bucle principal de interacción en las zonas del estudio
CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        local studioCenter = Config.Zones.mixer.coords
        local distToStudio = #(pos - studioCenter)

        if distToStudio < 60.0 then
            wait = 4
            for zoneKey, zone in pairs(Config.Zones) do
                local dist = #(pos - zone.coords)
                if dist < zone.radius + 1.0 then
                    DrawMarker(20, zone.coords.x, zone.coords.y, zone.coords.z - 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.45, 0.45, 0.45, 225, 29, 72, 200, false, true, 2, false, nil, nil, false)
                    
                    if dist < zone.radius then
                        DrawText3D(zone.coords.x, zone.coords.y, zone.coords.z + 0.35, zone.prompt)

                        if IsControlJustReleased(0, 38) then -- Tecla E
                            if zoneKey == "booth" then
                                -- Equipar auriculares al entrar a cabina
                                local pedId = PlayerPedId()
                                local hModel = `prop_headphones_01`
                                RequestModel(hModel)
                                while not HasModelLoaded(hModel) do Wait(10) end
                                headphoneProp = CreateObject(hModel, 0, 0, 0, true, true, true)
                                AttachEntityToEntity(headphoneProp, pedId, GetPedBoneIndex(pedId, 31086), 0.03, 0.0, 0.0, 0.0, 90.0, 90.0, true, true, false, true, 1, true)
                                SetModelAsNoLongerNeeded(hModel)
                            end

                            OpenStudioUI(zone.tab)
                        end
                    end
                end
            end
        end

        Wait(wait)
    end
end)

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    isUIOpen = false
    SetNuiFocus(false, false)
    CleanupProps()
    cb('ok')
end)

RegisterNUICallback('saveDraft', function(draftData, cb)
    TriggerServerEvent('spain_recordstudio:server:saveDraft', draftData)
    cb('ok')
end)

RegisterNUICallback('pressVinyl', function(data, cb)
    TriggerServerEvent('spain_recordstudio:server:pressVinyl', data)
    cb('ok')
end)

RegisterNUICallback('likeSong', function(data, cb)
    if data and data.songId then
        TriggerServerEvent('spain_recordstudio:server:likeSong', data.songId)
    end
    cb('ok')
end)

RegisterNUICallback('incrementPlays', function(data, cb)
    if data and data.songId then
        TriggerServerEvent('spain_recordstudio:server:incrementPlays', data.songId)
    end
    cb('ok')
end)

RegisterNUICallback('syncStudioAudio', function(data, cb)
    TriggerServerEvent('spain_recordstudio:server:syncStudioAudio', data)
    cb('ok')
end)

RegisterNUICallback('triggerRecordingAnim', function(data, cb)
    local ped = PlayerPedId()
    local animDict = "anim@mp_player_intcelebrationmale@air_guitar"
    RequestAnimDict(animDict)
    local timeout = 0
    while not HasAnimDictLoaded(animDict) and timeout < 50 do
        Wait(10)
        timeout = timeout + 1
    end

    if HasAnimDictLoaded(animDict) then
        TaskPlayAnim(ped, animDict, "air_guitar", 8.0, -8.0, -1, 49, 0, false, false, false)
    end
    cb('ok')
end)

RegisterNUICallback('stopRecordingAnim', function(data, cb)
    ClearPedTasks(PlayerPedId())
    cb('ok')
end)

-- Evento de actualización de likes
RegisterNetEvent('spain_recordstudio:client:updateSongLikes', function(songId, likes, isLiked)
    SendNUIMessage({
        action = "updateLikes",
        songId = songId,
        likes = likes,
        isLiked = isLiked
    })
end)

-- Sincronización de audio 3D en el recinto del estudio
RegisterNetEvent('spain_recordstudio:client:syncStudioAudio', function(audioPayload, studioCoords)
    local ped = PlayerPedId()
    local myCoords = GetEntityCoords(ped)
    local dist = #(myCoords - studioCoords)

    if dist <= Config.StudioSoundRadius then
        -- Calcular volumen con atenuación espacial
        local maxDist = Config.StudioSoundRadius
        local factor = 1.0 - (dist / maxDist)
        local baseVolume = (audioPayload.volume or 80) / 100
        local finalVol = math.max(0.05, math.min(1.0, factor * baseVolume))

        SendNUIMessage({
            action = "playStudioMonitor",
            payload = audioPayload,
            volume = finalVol
        })
    else
        SendNUIMessage({
            action = "stopStudioMonitor"
        })
    end
end)

-- Reproducir Disco de Vinilo (Usable en cualquier parte del mapa)
RegisterNetEvent('spain_recordstudio:client:playVinylItem', function(info)
    if not info then return end

    SendNUIMessage({
        action = "openVinylPlayer",
        info = info
    })

    QBCore.Functions.Notify('🎵 Reproduciendo Vinilo: ' .. (info.song_title or "Canción") .. ' - ' .. (info.artist_name or "Artista"), 'primary', 5000)

    -- Animación de sacar y mirar el disco
    local ped = PlayerPedId()
    local animDict = "cellphone@"
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(10) end
    TaskPlayAnim(ped, animDict, "cellphone_text_read_base", 3.0, 3.0, 3000, 49, 0, false, false, false)
end)

-- Comando de ayuda o apertura directa si estás en el estudio
RegisterCommand('estudio', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local dist = #(pos - Config.Zones.mixer.coords)

    if dist < 40.0 then
        OpenStudioUI("mixer")
    else
        QBCore.Functions.Notify('El Estudio de Grabación está en Vinewood. Puedes ver la marca en el mapa.', 'primary', 5000)
    end
end, false)

-- Comando para detener la música que tengas sonando
RegisterCommand('pararmusica', function()
    SendNUIMessage({ action = "stopAllAudio" })
    QBCore.Functions.Notify('Música detenida', 'primary')
end, false)
