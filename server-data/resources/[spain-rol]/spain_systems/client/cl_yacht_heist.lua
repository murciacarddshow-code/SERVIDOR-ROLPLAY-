-- =========================================================================
-- SPAIN ROL - ATRACO AL YATE DE LUJO (OFFSHORE YACHT HEIST)
-- =========================================================================
-- Infiltración marítima y aérea al superyate de lujo.
-- Incluye apertura de cajas fuertes de alta seguridad, alarmas y botín exclusivo.

local QBCore = exports['qb-core']:GetCoreObject()

local yachtLocation = vector3(-2082.4, -1018.6, 8.97)

local yachtSafes = {
    {
        id = 1,
        name = "Caja Fuerte del Camarote Principal",
        coords = vector3(-2087.6, -1018.9, 8.97),
        opened = false,
        busy = false
    },
    {
        id = 2,
        name = "Caja Fuerte del Salón VIP",
        coords = vector3(-2065.2, -1023.5, 8.97),
        opened = false,
        busy = false
    },
    {
        id = 3,
        name = "Terminal de Criptoactivos del Puente",
        coords = vector3(-2044.8, -1031.2, 11.98),
        opened = false,
        busy = false
    }
}

-- Blip en el mapa del Yate
CreateThread(function()
    local blip = AddBlipForCoord(yachtLocation.x, yachtLocation.y, yachtLocation.z)
    SetBlipSprite(blip, 455) -- Icono de yate
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 1) -- Rojo
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Atraco al Megayate de Lujo")
    EndTextCommandSetBlipName(blip)
end)

-- Bucle de interacción con las cajas fuertes del yate
CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)

        if #(pCoords - yachtLocation) < 100.0 then
            for _, safe in ipairs(yachtSafes) do
                local dist = #(pCoords - safe.coords)
                if dist < 2.0 and not safe.opened and not safe.busy then
                    wait = 0
                    DrawMarker(2, safe.coords.x, safe.coords.y, safe.coords.z + 0.2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.35, 0.35, 0.35, 230, 40, 40, 180, true, true, 2, false, nil, nil, false)
                    QBCore.Functions.DrawText3D(safe.coords.x, safe.coords.y, safe.coords.z + 0.5, "~r~[E]~s~ Forzar " .. safe.name)

                    if IsControlJustPressed(0, 38) then
                        StartRobbingSafe(safe)
                    end
                end
            end
        end

        Wait(wait)
    end
end)

function StartRobbingSafe(safe)
    safe.busy = true
    local ped = PlayerPedId()

    -- Avisar a la policía de inmediato al comenzar el sabotaje
    TriggerServerEvent('spain_yacht:server:alertPolice')

    QBCore.Functions.Progressbar("yacht_safe", "Descifrando combinación de seguridad biométrica...", 8000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@safe_cracking",
        anim = "idle_base",
        flags = 49,
    }, {}, {}, function()
        safe.busy = false
        safe.opened = true
        TriggerServerEvent('spain_yacht:server:rewardSafe', safe.id)
        QBCore.Functions.Notify('¡Caja fuerte abierta! Has extraído el botín de lujo.', 'success', 6000)
    end, function()
        safe.busy = false
        QBCore.Functions.Notify('Apertura cancelada.', 'error')
    end)
end

RegisterNetEvent('spain_yacht:client:policeAlert', function()
    local ped = PlayerPedId()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job and (PlayerData.job.name == 'police' or PlayerData.job.name == 'guardiacivil') then
        PlaySoundFrontend(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0)
        QBCore.Functions.Notify('🚨 ALERTA 112: ¡Atraco a mano armada en el Yate de Lujo! Acudan unidades marítimas y aéreas.', 'error', 10000)
        SetNewWaypoint(yachtLocation.x, yachtLocation.y)
    end
end)
