local QBCore = exports['qb-core']:GetCoreObject()
local dealerPed = nil

-- =========================================================================
-- SPAWN DEL NPC CONTRABANDISTA CLANDESTINO
-- =========================================================================
CreateThread(function()
    local npcCfg = Config.NPC
    local model = GetHashKey(npcCfg.model)

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    dealerPed = CreatePed(4, model, npcCfg.coords.x, npcCfg.coords.y, npcCfg.coords.z - 1.0, npcCfg.coords.w, false, true)
    FreezeEntityPosition(dealerPed, true)
    SetEntityInvincible(dealerPed, true)
    SetBlockingOfNonTemporaryEvents(dealerPed, true)

    -- Animación de fumar / esperar
    RequestAnimDict(npcCfg.animDict)
    while not HasAnimDictLoaded(npcCfg.animDict) do Wait(10) end
    TaskPlayAnim(dealerPed, npcCfg.animDict, npcCfg.animName, 3.0, 3.0, -1, 49, 0, 0, 0, 0)

    -- Bucle de Interacción
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local dist = #(pCoords - vector3(npcCfg.coords.x, npcCfg.coords.y, npcCfg.coords.z))

        if dist < 6.0 then
            sleep = 0
            if dist < 2.5 then
                QBCore.Functions.DrawText3D(npcCfg.coords.x, npcCfg.coords.y, npcCfg.coords.z + 1.0, "~r~[E]~s~ Hablar con el Contrabandista de la Red Oscura")
                if IsControlJustPressed(0, 38) then -- Tecla E
                    OpenDealerMenu()
                end
            end
        end

        Wait(sleep)
    end
end)

-- Menú de Diálogo del Contrabandista
function OpenDealerMenu()
    local menu = {
        {
            header = "Red Oscura // Contacto Clandestino",
            isMenuHeader = true
        },
        {
            header = "Comprar Tablet Criminal Ilegal",
            txt = "Precio: €" .. Config.NPC.tabletPrice .. " (Dispositivo cifrado para organizaciones)",
            params = {
                event = "spain_criminal:client:buyTabletFromNpc"
            }
        },
        {
            header = "Conectar a la Tablet Criminal (Origin)",
            txt = "Abrir la interfaz directamente a través del terminal del contrabandista",
            params = {
                event = "spain_criminal:client:openTabletDirect"
            }
        },
        {
            header = "Tienda de Precursores y Armamento",
            txt = "Adquirir suministros, ácido, pólvora y detonadores militares",
            params = {
                event = "spain_criminal:client:openMaterialsShop"
            }
        }
    }

    exports['qb-menu']:openMenu(menu)
end

RegisterNetEvent('spain_criminal:client:buyTabletFromNpc', function()
    TriggerServerEvent('spain_criminal:server:buyTabletNpc')
end)

RegisterNetEvent('spain_criminal:client:openTabletDirect', function()
    OpenCriminalTablet()
end)

RegisterNetEvent('spain_criminal:client:openMaterialsShop', function()
    local menu = {
        {
            header = "Suministros Clandestinos de Laboratorio y Armería",
            isMenuHeader = true
        }
    }

    for _, item in ipairs(Config.NPC.shopItems) do
        table.insert(menu, {
            header = item.label,
            txt = "Coste: €" .. item.price .. " por unidad",
            params = {
                event = "spain_criminal:client:buyItemConfirm",
                args = {
                    item = item.name,
                    price = item.price,
                    label = item.label
                }
            }
        })
    end

    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent('spain_criminal:client:buyItemConfirm', function(data)
    TriggerServerEvent('spain_criminal:server:buyMaterial', data)
end)
