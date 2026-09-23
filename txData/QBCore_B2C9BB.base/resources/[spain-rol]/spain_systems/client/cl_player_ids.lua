-- =========================================================================
-- SPAIN ROL - CLIENTE: SISTEMA DE VISUALIZACIÓN DE IDS (TECLA Z / /ids)
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()
local showPlayerIds = false
local maxDistance = 20.0

-- Función para dibujar texto 3D nítido sobre la cabeza
local function DrawIdText(coords, text, isTalking, isSelf)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end

    local camCoords = GetGameplayCamCoords()
    local distance = #(coords - camCoords)
    local scale = (1 / distance) * 2.2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(0.0 * scale, 0.40 * scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextCentre(1)

    -- Colores dinámicos
    if isTalking then
        SetTextColour(255, 235, 59, 255) -- Amarillo brillante si está hablando
    elseif isSelf then
        SetTextColour(77, 208, 225, 255) -- Cyan suave para tu propia ID
    else
        SetTextColour(255, 255, 255, 235) -- Blanco limpio para los demás
    end

    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)

    -- Fondo translúcido tipo placa para legibilidad perfecta
    local factor = (string.len(text)) / 320
    if isTalking then
        DrawRect(x, y + 0.0150 * scale, 0.025 + factor * scale, 0.035 * scale, 40, 40, 0, 160)
    else
        DrawRect(x, y + 0.0150 * scale, 0.025 + factor * scale, 0.035 * scale, 15, 15, 15, 160)
    end
end

-- Alternar visualización de IDs
local function TogglePlayerIds()
    showPlayerIds = not showPlayerIds
    if showPlayerIds then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
        TriggerEvent('QBCore:Notify', "👁️ IDs de jugadores: ACTIVADAS", "success", 2500)
    else
        PlaySoundFrontend(-1, "CANCEL", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
        TriggerEvent('QBCore:Notify', "👁️ IDs de jugadores: DESACTIVADAS", "error", 2500)
    end
end

-- Registro de comando /ids y /verids
RegisterCommand('ids', function()
    TogglePlayerIds()
end, false)

RegisterCommand('verids', function()
    TogglePlayerIds()
end, false)

-- Mapeo nativo de la tecla Z en FiveM
if RegisterKeyMapping then
    RegisterKeyMapping('ids', 'Mostrar / Ocultar IDs de Jugadores', 'keyboard', 'z')
end

-- Sugerencia de autocompletado en el chat
CreateThread(function()
    Wait(1500)
    TriggerEvent('chat:addSuggestion', '/ids', 'Activar o desactivar las IDs sobre los jugadores (o pulsa Z)')
    TriggerEvent('chat:addSuggestion', '/verids', 'Activar o desactivar las IDs sobre los jugadores (o pulsa Z)')
end)

-- Bucle de renderizado optimizado
CreateThread(function()
    while true do
        local wait = 500 -- Modo reposo a 0.00ms cuando está apagado

        if showPlayerIds then
            wait = 0
            local myPed = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)
            local activePlayers = GetActivePlayers()

            for _, player in ipairs(activePlayers) do
                local targetPed = GetPlayerPed(player)

                if DoesEntityExist(targetPed) then
                    local targetCoords = GetEntityCoords(targetPed)
                    local distance = #(myCoords - targetCoords)

                    if distance <= maxDistance then
                        local serverId = GetPlayerServerId(player)
                        local isTalking = NetworkIsPlayerTalking(player) or MumbleIsPlayerTalking(player)
                        local isSelf = (player == PlayerId())

                        -- Coordenada superior (sobre la cabeza del ped)
                        local headIndex = GetPedBoneIndex(targetPed, 31086)
                        local headCoords = GetPedBoneCoords(targetPed, 31086, 0.0, 0.0, 0.0)
                        local drawZ = (headIndex ~= -1 and headCoords.z or targetCoords.z) + 0.42

                        -- Texto a mostrar con indicador de voz
                        local displayText = ""
                        if isTalking then
                            displayText = "🎙️ [ID: " .. serverId .. "]"
                        else
                            displayText = "[ID: " .. serverId .. "]"
                        end

                        if isSelf then
                            displayText = displayText .. " (Tú)"
                        end

                        DrawIdText(vector3(targetCoords.x, targetCoords.y, drawZ), displayText, isTalking, isSelf)
                    end
                end
            end
        end

        Wait(wait)
    end
end)
