-- =========================================================================
-- SPAIN ROL - NPC DE ATENCIÓN CIUDADANA Y RECUPERACIÓN DE DNI
-- =========================================================================
-- Localizado en la recepción principal de la Comisaría de Mission Row.
-- Permite a cualquier ciudadano recuperar o expedir un duplicado de su DNI.

local QBCore = exports['qb-core']:GetCoreObject()
local npcCoords = vector4(441.25, -981.85, 30.69, 180.0)
local npcModel = `s_m_m_security_01`
local spawnedNpc = nil
local lastInteraction = 0

-- Función para dibujar texto 3D en pantalla
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
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 20, 20, 20, 160)
    end
end

-- Spawn del NPC con persistencia y prevención de caída de mapa
CreateThread(function()
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Wait(50)
    end

    spawnedNpc = CreatePed(4, npcModel, npcCoords.x, npcCoords.y, npcCoords.z - 1.0, npcCoords.w, false, true)
    SetEntityHeading(spawnedNpc, npcCoords.w)
    FreezeEntityPosition(spawnedNpc, true)
    SetEntityInvincible(spawnedNpc, true)
    SetBlockingOfNonTemporaryEvents(spawnedNpc, true)
    TaskStartScenarioInPlace(spawnedNpc, "WORLD_HUMAN_CLIPBOARD", 0, true)

    -- Si qb-target está habilitado, agregamos opción interactiva
    if GetResourceState('qb-target') == 'started' then
        exports['qb-target']:AddTargetEntity(spawnedNpc, {
            options = {
                {
                    type = "client",
                    event = "spain_police:client:requestDniDuplicate",
                    icon = "fas fa-id-card",
                    label = "Recuperar / Duplicado de DNI (100€)",
                }
            },
            distance = 2.5
        })
    end
end)

-- Bucle de proximidad para interacción mediante [E]
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)
        local dist = #(pCoords - vector3(npcCoords.x, npcCoords.y, npcCoords.z))

        if dist < 6.0 then
            sleep = 0
            if dist < 2.5 then
                DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1.0, "~g~[E]~w~ Recuperar DNI extraviado ~y~(100€)")
                if IsControlJustPressed(0, 38) then -- Tecla E
                    if (GetGameTimer() - lastInteraction) > 2000 then
                        lastInteraction = GetGameTimer()
                        TriggerEvent("spain_police:client:requestDniDuplicate")
                    end
                end
            else
                DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1.0, "Oficina de Expedición del DNI")
            end
        end

        Wait(sleep)
    end
end)

-- Evento cliente para solicitar el duplicado
RegisterNetEvent("spain_police:client:requestDniDuplicate", function()
    local ped = PlayerPedId()
    
    QBCore.Functions.Progressbar("dni_reissue", "Tramitando duplicado de DNI oficial...", 3000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mp_common",
        anim = "givetake2_a",
        flags = 49,
    }, {}, {}, function()
        TriggerServerEvent("spain_police:server:reissueDNI")
    end, function()
        QBCore.Functions.Notify("Trámite cancelado.", "error")
    end)
end)

-- Limpieza al reiniciar recurso
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if spawnedNpc and DoesEntityExist(spawnedNpc) then
        DeleteEntity(spawnedNpc)
    end
end)
