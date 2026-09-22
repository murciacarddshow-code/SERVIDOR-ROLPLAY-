------
-- Interaction Sounds by Scott
-- Path: server/main.lua
------

RegisterNetEvent('InteractSound_SV:PlayOnOne', function(clientNetId, soundFile, soundVolume)
    TriggerClientEvent('InteractSound_CL:PlayOnOne', clientNetId, soundFile, soundVolume)
end)

RegisterNetEvent('InteractSound_SV:PlayOnSource', function(soundFile, soundVolume)
    TriggerClientEvent('InteractSound_CL:PlayOnOne', source, soundFile, soundVolume)
end)

RegisterNetEvent('InteractSound_SV:PlayOnAll', function(soundFile, soundVolume)
    TriggerClientEvent('InteractSound_CL:PlayOnAll', -1, soundFile, soundVolume)
end)

RegisterNetEvent('InteractSound_SV:PlayWithinDistance', function(maxDistance, soundFile, soundVolume)
    local src = source
    local coords = GetEntityCoords(GetPlayerPed(src))
    TriggerClientEvent('InteractSound_CL:PlayWithinDistance', -1, coords, maxDistance, soundFile, soundVolume)
end)
