local QBCore = exports['qb-core']:GetCoreObject()

-- Spawnear NPC Traficante de Armas
CreateThread(function()
    local model = GetHashKey(Config.BlackMarket.pedModel)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local ped = CreatePed(4, model, Config.BlackMarket.coords.x, Config.BlackMarket.coords.y, Config.BlackMarket.coords.z - 1.0, Config.BlackMarket.heading, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPARTIAL", 0, true)

    -- Zona de Interaccion
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dist = #(playerCoords - Config.BlackMarket.coords)

        if dist < 3.0 then
            sleep = 0
            DrawText3D(Config.BlackMarket.coords.x, Config.BlackMarket.coords.y, Config.BlackMarket.coords.z + 1.0, "[~r~E~w~] Mercado Negro de Armas")
            if IsControlJustPressed(0, 38) then -- Tecla E
                OpenBlackMarketMenu()
            end
        end
        Wait(sleep)
    end
end)

function OpenBlackMarketMenu()
    local menu = {
        {
            header = "Mercado Negro Clandestino",
            isMenuHeader = true
        }
    }

    for _, item in ipairs(Config.BlackMarket.items) do
        table.insert(menu, {
            header = item.label,
            txt = "Precio: €" .. item.price,
            params = {
                event = "spain_blackmarket:client:buyItem",
                args = {
                    item = item.name,
                    price = item.price,
                    label = item.label
                }
            }
        })
    end

    exports['qb-menu']:openMenu(menu)
end

RegisterNetEvent('spain_blackmarket:client:buyItem', function(data)
    TriggerServerEvent('spain_blackmarket:server:purchase', data)
end)

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
