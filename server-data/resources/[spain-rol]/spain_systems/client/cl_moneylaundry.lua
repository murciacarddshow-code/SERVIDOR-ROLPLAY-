local QBCore = exports['qb-core']:GetCoreObject()

-- Spawnear NPC de Blanqueo de Dinero
CreateThread(function()
    local coords = Config.MoneyLaundry.coords
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dist = #(playerCoords - coords)

        if dist < 2.5 then
            sleep = 0
            DrawText3D(coords.x, coords.y, coords.z + 1.0, "[~g~E~w~] Blanquear Dinero Negro (-15% comision)")
            if IsControlJustPressed(0, 38) then -- Tecla E
                TriggerServerEvent('spain_laundry:server:startWash')
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('spain_laundry:client:doWash', function(amount, cleanAmount)
    local ped = PlayerPedId()
    QBCore.Functions.Progressbar("wash_money", "Contando y blanqueando €" .. amount .. " de dinero negro...", Config.MoneyLaundry.washTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@heists@prison_heiststation@cop_reactions",
        anim = "cop_b_idle",
        flags = 49,
    }, {}, {}, function()
        StopAnimTask(ped, "anim@heists@prison_heiststation@cop_reactions", "cop_b_idle", 1.0)
        TriggerServerEvent('spain_laundry:server:finishWash', amount, cleanAmount)
    end, function()
        QBCore.Functions.Notify("Cancelaste el blanqueo de dinero.", "error")
    end)
end)
