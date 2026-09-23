-- =========================================================================
-- SPAIN ROL - CLIENTE: APERTURA DE SOBRES POKÉMON TCG (POKÉVAULT)
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()

-- Evento de Apertura de Sobre con Animación y Efectos
RegisterNetEvent('spain_pokemon:client:openPack', function(packItem, packLabel)
    local ped = PlayerPedId()

    -- Animación de rasgar/abrir el sobre
    local animDict = "mp_common"
    local animClip = "givetake2_a"
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end

    TaskPlayAnim(ped, animDict, animClip, 8.0, -8.0, 3500, 49, 0, false, false, false)

    QBCore.Functions.Progressbar("open_pokemon_booster", "Abriendo " .. packLabel .. "...", 3500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Completado
        ClearPedTasks(ped)
        TriggerServerEvent('spain_pokemon:server:finishPackOpening', packItem)
    end, function() -- Cancelado
        ClearPedTasks(ped)
        TriggerEvent('QBCore:Notify', "Apertura de sobre cancelada.", "error")
    end)
end)

-- Efecto al conseguir una carta
RegisterNetEvent('spain_pokemon:client:cardObtained', function(cardLabel, rarity, isHit)
    if isHit then
        -- Sonido épico de premio gordo
        PlaySoundFrontend(-1, "CHALLENGE_UNLOCKED", "HUD_AWARDS", 1)
        TriggerEvent('QBCore:Notify', "🔥 ¡¡¡MENUDO HITAZO DE POKÉMON!!! 🔥<br>Has obtenido: <strong>" .. cardLabel .. "</strong> (" .. rarity .. ")", "success", 9000)
    else
        PlaySoundFrontend(-1, "LOCAL_PLYR_CASH_COUNTER_COMPLETE", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 1)
        TriggerEvent('QBCore:Notify', "✨ Has obtenido: <strong>" .. cardLabel .. "</strong> (" .. rarity .. ")", "primary", 5000)
    end
end)

-- =========================================================================
-- MENÚ INTERACTIVO CON EL DEPENDIENTE POKÉVAULT
-- =========================================================================
RegisterNetEvent('spain_pokemon:client:openMainStoreMenu', function()
    local storeMenu = {
        {
            isMenuHeader = true,
            header = '🏪 PokéVault TCG Shop (Murcia Card Show)',
            txt = 'Tienda oficial de cartas coleccionables y coleccionismo'
        },
        {
            header = '🛍️ Comprar Sobres y Cajas',
            txt = 'Ver catálogo de sobres 151, Prismatic, Charizard, Vintage y ETB',
            params = {
                event = 'qb-shops:client:openShop',
                args = 'pokevault'
            }
        },
        {
            header = '💰 Tasar y Vender Cartas Pokémon',
            txt = 'Hablar con el tasador en el mostrador para vender cartas por dinero en efectivo',
            params = {
                event = 'spain_pokemon:client:openBuyerMenu'
            }
        },
        {
            header = '❌ Cerrar',
            params = {
                event = 'qb-menu:client:closeMenu'
            }
        }
    }

    exports['qb-menu']:openMenu(storeMenu)
end)

-- =========================================================================
-- MENÚ INTERACTIVO CON EL TASADOR OFICIAL DE CARTAS POKÉMON
-- =========================================================================
RegisterNetEvent('spain_pokemon:client:openBuyerMenu', function()
    local buyerMenu = {
        {
            isMenuHeader = true,
            header = '🪙 Tasador Oficial PokéVault (Murcia Card Show)',
            txt = 'Compramos tus cartas Pokémon al mejor precio del mercado en efectivo'
        },
        {
            header = '📦 Vender TODAS tus Cartas Repetidas',
            txt = 'Liquida todas las cartas coleccionables de tu inventario al instante',
            params = {
                event = 'spain_pokemon:client:sellAction',
                args = { type = 'all', label = 'todas tus cartas Pokémon' }
            }
        },
        {
            header = '🃏 Vender Cartas Comunes (Kanto)',
            txt = 'Cotización: €15 por cada carta básica',
            params = {
                event = 'spain_pokemon:client:sellAction',
                args = { type = 'pokemon_card_common', label = 'Cartas Comunes' }
            }
        },
        {
            header = '✨ Vender Holográficas Raras',
            txt = 'Cotización: €65 por cada carta holográfica foil',
            params = {
                event = 'spain_pokemon:client:sellAction',
                args = { type = 'pokemon_card_holo', label = 'Cartas Holográficas Raras' }
            }
        },
        {
            header = '🔥 Vender Charizard VMAX Shiny',
            txt = 'Cotización: €1.200 por cada carta Ultra Rara Secreta',
            params = {
                event = 'spain_pokemon:client:sellAction',
                args = { type = 'pokemon_card_charizard_vmax', label = 'Charizard VMAX Shiny' }
            }
        },
        {
            header = '🌙 Vender Umbreon VMAX Moonbreon',
            txt = 'Cotización: €1.200 por cada carta de Arte Alternativo',
            params = {
                event = 'spain_pokemon:client:sellAction',
                args = { type = 'pokemon_card_moonbreon', label = 'Umbreon Moonbreon' }
            }
        },
        {
            header = '⚡ Vender Mewtwo VSTAR Dorada',
            txt = 'Cotización: €900 por cada carta Secreta Oro',
            params = {
                event = 'spain_pokemon:client:sellAction',
                args = { type = 'pokemon_card_mewtwo_gold', label = 'Mewtwo VSTAR Dorada' }
            }
        },
        {
            header = '💎 Vender Cartas Graduadas PSA 10 Gem Mint',
            txt = 'Cotización: €2.500 por cada Slab PSA 10 Certificada',
            params = {
                event = 'spain_pokemon:client:sellAction',
                args = { type = 'pokemon_card_psa10', label = 'Slab PSA 10 Gem Mint' }
            }
        },
        {
            header = '📋 Consultar Tabla Oficial de Precios',
            txt = 'Revisar la lista de cotizaciones que paga la tienda por rareza',
            params = {
                event = 'spain_pokemon:client:showPriceList'
            }
        },
        {
            header = '❌ Cancelar y Salir',
            params = {
                event = 'qb-menu:client:closeMenu'
            }
        }
    }

    exports['qb-menu']:openMenu(buyerMenu)
end)

-- Acción de venta con animación y tasación
RegisterNetEvent('spain_pokemon:client:sellAction', function(data)
    local ped = PlayerPedId()

    local animDict = "mp_common"
    local animClip = "givetake2_a"
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end
    TaskPlayAnim(ped, animDict, animClip, 8.0, -8.0, 1500, 49, 0, false, false, false)

    QBCore.Functions.Progressbar("pokevault_evaluating", "Tasando " .. (data.label or "cartas") .. "...", 1500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        ClearPedTasks(ped)
        TriggerServerEvent('spain_pokemon:server:sellCards', data.type)
    end, function()
        ClearPedTasks(ped)
        TriggerEvent('QBCore:Notify', "Tasación cancelada.", "error")
    end)
end)

-- Tabla de cotizaciones
RegisterNetEvent('spain_pokemon:client:showPriceList', function()
    local priceMenu = {
        {
            isMenuHeader = true,
            header = '📊 Cotizaciones Oficiales PokéVault (Murcia Card Show)',
            txt = 'Tarifas garantizadas de compraventa al contado:'
        },
        {
            header = '🃏 Cartas Comunes (Kanto)',
            txt = 'Precio de recompra: €15 unidad (Pikachu, Charmander, Squirtle...)'
        },
        {
            header = '✨ Holográficas Raras Foil',
            txt = 'Precio de recompra: €65 unidad (Gyarados, Mew, Dragonite...)'
        },
        {
            header = '🔥 Charizard VMAX Shiny',
            txt = 'Precio de recompra: €1.200 unidad (Ultra Rara Secreta)'
        },
        {
            header = '🌙 Umbreon VMAX Moonbreon',
            txt = 'Precio de recompra: €1.200 unidad (Arte Alternativo Evolving Skies)'
        },
        {
            header = '⚡ Mewtwo VSTAR Secreta Oro',
            txt = 'Precio de recompra: €900 unidad (Edición Dorada Premium)'
        },
        {
            header = '💎 Carta Graduada PSA 10 Gem Mint',
            txt = 'Precio de recompra: €2.500 unidad (Slab Acrílica Calificación 10)'
        },
        {
            header = '⬅️ Volver al Menú del Tasador',
            params = {
                event = 'spain_pokemon:client:openBuyerMenu'
            }
        }
    }

    exports['qb-menu']:openMenu(priceMenu)
end)

-- Notificación de venta completada con sonido de caja registradora
RegisterNetEvent('spain_pokemon:client:saleComplete', function(count, totalCash)
    PlaySoundFrontend(-1, "LOCAL_PLYR_CASH_COUNTER_COMPLETE", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 1)
    TriggerEvent('QBCore:Notify', "🤝 <strong>Tasación oficial completada</strong><br>Has vendido <strong>" .. count .. "</strong> carta(s) por <strong>€" .. totalCash .. "</strong> en efectivo.", "success", 7500)
end)

