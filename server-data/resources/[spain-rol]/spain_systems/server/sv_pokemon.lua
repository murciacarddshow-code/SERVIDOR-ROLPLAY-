-- =========================================================================
-- SPAIN ROL - SERVIDOR: SISTEMA DE APERTURA DE SOBRES Y CARTAS POKÉMON
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()

-- Catálogo de Nombres de Cartas Comunes e Infrecuentes
local CommonCards = {
    "Pikachu (Ilustración Especial 025/165)",
    "Charmander (Fuego Ardiente 004/165)",
    "Squirtle (Chorro de Agua 007/165)",
    "Bulbasaur (Látigo Cepa 001/165)",
    "Eevee (Evolución Genética 133/165)",
    "Gengar (Pesadilla Nocturna 094/165)",
    "Snorlax (Comida Campestre 143/165)",
    "Mew (Psíquico Místico 151/165)",
    "Psyduck (Dolor de Cabeza 054/165)",
    "Jolteon (Trueno Chispeante 135/165)",
    "Vaporeon (Burbuja Cristalina 134/165)",
    "Flareon (Llamarada Ígnea 136/165)"
}

-- Catálogo de Nombres de Cartas Holográficas
local HoloCards = {
    "Gyarados Holográfico (Ira Marina Foil)",
    "Dragonite V Holográfico (Impacto Dragón Foil)",
    "Mew Holográfico Foil (Brillo Estelar)",
    "Alakazam Ex Holográfico Foil (Telekinesis)",
    "Zapdos Ex Holográfico Foil (Rayo Dorado)",
    "Articuno Holográfico Foil (Hielo Ártico)",
    "Moltres Holográfico Foil (Fénix Ardiente)",
    "Gengar V Holográfico Foil (Sombra Espectral)"
}

-- Registro de Ítems Usables (Sobres y Cajas)
local packsList = {
    { item = 'pokemon_booster_151', label = 'Sobre Pokémon 151 (Kanto)' },
    { item = 'pokemon_booster_charizard', label = 'Sobre Destinos Brillantes (Charizard)' },
    { item = 'pokemon_booster_prismatic', label = 'Sobre Evoluciones Prismáticas (Eevee)' },
    { item = 'pokemon_booster_vintage', label = 'Sobre Vintage Base Set 1999' },
    { item = 'pokemon_etb_151', label = 'Caja de Entrenador Élite ETB 151' },
    { item = 'pokemon_mystery_box', label = 'Mystery Box Murcia Card Show' },
}

for _, p in ipairs(packsList) do
    QBCore.Functions.CreateUseableItem(p.item, function(source, item)
        TriggerClientEvent('spain_pokemon:client:openPack', source, p.item, p.label)
    end)
end

-- Uso del Álbum Coleccionista
QBCore.Functions.CreateUseableItem('pokemon_binder', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('QBCore:Notify', source, "Abres tu Álbum PokéVault de 9 bolsillos. ¡Todas tus cartas se encuentran seguras y en perfecto estado!", "primary", 5000)
end)

-- Procesamiento del Sobre y Tirada de Probabilidad
RegisterNetEvent('spain_pokemon:server:finishPackOpening', function(packItem)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Comprobar y retirar el sobre
    local hasPack = Player.Functions.GetItemByName(packItem)
    if not hasPack or hasPack.amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, "Ya no tienes ese sobre en tus manos.", "error")
        return
    end

    Player.Functions.RemoveItem(packItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[packItem] or { label = "Sobre Pokémon" }, "remove")

    local roll = math.random(1, 100)
    local cardItem = 'pokemon_card_common'
    local cardLabel = ""
    local rarity = "Común"
    local isHit = false

    -- Probabilidades según el tipo de producto:
    if packItem == 'pokemon_mystery_box' or packItem == 'pokemon_booster_vintage' then
        -- Cajas misteriosas o vintage: mayores probabilidades de hits legendarios
        if roll <= 15 then -- 15% PSA 10 Gem Mint
            cardItem = 'pokemon_card_psa10'
            cardLabel = "Charizard 1st Edition Shadowless - PSA 10 GEM MINT (#" .. math.random(88000000, 88999999) .. ")"
            rarity = "Gema Histórica PSA 10 💎💎💎"
            isHit = true
        elseif roll <= 40 then -- 25% Charizard VMAX o Moonbreon
            if math.random(1, 2) == 1 then
                cardItem = 'pokemon_card_charizard_vmax'
                cardLabel = "Charizard VMAX Shiny Full Art (Destinos Brillantes)"
                rarity = "Ultra Rara Secreta 🔥⭐⭐⭐"
            else
                cardItem = 'pokemon_card_moonbreon'
                cardLabel = "Umbreon VMAX Alt Art Moonbreon (Evoluciones Prismáticas)"
                rarity = "Ultra Rara Secreta 🌙⭐⭐⭐"
            end
            isHit = true
        elseif roll <= 75 then -- 35% Holográfica Rara
            cardItem = 'pokemon_card_holo'
            cardLabel = HoloCards[math.random(1, #HoloCards)]
            rarity = "Holográfica Rara Foil ✨"
            isHit = true
        else -- 25% Común Especial
            cardItem = 'pokemon_card_common'
            cardLabel = CommonCards[math.random(1, #CommonCards)]
            rarity = "Común Kanto"
        end
    else
        -- Sobres estándar (151, Charizard, Prismatic):
        if roll <= 4 then -- 4% PSA 10 Gem Mint
            cardItem = 'pokemon_card_psa10'
            cardLabel = "Pikachu Ilustración Especial - PSA 10 GEM MINT (#" .. math.random(88000000, 88999999) .. ")"
            rarity = "Graduada PSA 10 Gem Mint 💎"
            isHit = true
        elseif roll <= 12 then -- 8% Hit Secreto (Charizard / Moonbreon / Mewtwo Gold)
            local secretRoll = math.random(1, 3)
            if secretRoll == 1 then
                cardItem = 'pokemon_card_charizard_vmax'
                cardLabel = "Charizard VMAX Shiny Full Art"
                rarity = "Ultra Rara Secreta 🔥⭐⭐⭐"
            elseif secretRoll == 2 then
                cardItem = 'pokemon_card_moonbreon'
                cardLabel = "Umbreon VMAX Alt Art Moonbreon"
                rarity = "Ultra Rara Secreta 🌙⭐⭐⭐"
            else
                cardItem = 'pokemon_card_mewtwo_gold'
                cardLabel = "Mewtwo VSTAR Secreta Oro"
                rarity = "Secreta Oro 👑"
            end
            isHit = true
        elseif roll <= 38 then -- 26% Holográfica Rara
            cardItem = 'pokemon_card_holo'
            cardLabel = HoloCards[math.random(1, #HoloCards)]
            rarity = "Holográfica Rara Foil ✨"
            isHit = false
        else -- 62% Carta Común
            cardItem = 'pokemon_card_common'
            cardLabel = CommonCards[math.random(1, #CommonCards)]
            rarity = "Común"
            isHit = false
        end
    end

    -- Entregar la carta al jugador con metadatos específicos
    local itemInfo = {
        label = cardLabel,
        rarity = rarity,
        packOrigin = packItem,
        pullDate = os.date("%d/%m/%Y")
    }

    Player.Functions.AddItem(cardItem, 1, false, itemInfo)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[cardItem] or { label = cardLabel }, "add")
    TriggerClientEvent('spain_pokemon:client:cardObtained', src, cardLabel, rarity, isHit)

    -- Revelación Visual Interactiva en Pantalla (NUI 3D Shimmer)
    local marketPrice = (cardPrices[cardItem] and cardPrices[cardItem].price) or 15
    local cardDetails = {
        item = cardItem,
        name = cardLabel,
        rarity = rarity,
        isHit = isHit,
        image = "nui://qb-inventory/html/images/" .. cardItem .. ".png",
        marketValue = marketPrice,
        packOrigin = (QBCore.Shared.Items[packItem] and QBCore.Shared.Items[packItem].label) or packItem
    }
    TriggerClientEvent('spain_pokemon:client:revealCardNui', src, cardDetails)
end)

-- =========================================================================
-- TASACIÓN Y VENTA DE CARTAS POKÉMON MEDIANTE NPC (POKÉVAULT)
-- =========================================================================

local cardPrices = {
    ['pokemon_card_common'] = { price = 15, label = 'Carta Común Kanto' },
    ['pokemon_card_holo'] = { price = 65, label = 'Carta Holográfica Rara' },
    ['pokemon_card_charizard_vmax'] = { price = 1200, label = 'Charizard VMAX Shiny' },
    ['pokemon_card_moonbreon'] = { price = 1200, label = 'Umbreon VMAX Moonbreon' },
    ['pokemon_card_mewtwo_gold'] = { price = 900, label = 'Mewtwo VSTAR Dorada' },
    ['pokemon_card_psa10'] = { price = 2500, label = 'Slab Graduada PSA 10 Gem Mint' },
}

RegisterNetEvent('spain_pokemon:server:sellCards', function(cardType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Verificación de proximidad con el mostrador del Tasador de PokéVault (Legion Square)
    local playerPed = GetPlayerPed(src)
    local pCoords = GetEntityCoords(playerPed)
    local shopCoords = vector3(21.5, -1106.0, 29.8)
    if #(pCoords - shopCoords) > 15.0 then
        TriggerClientEvent('QBCore:Notify', src, "Debes estar junto al Tasador en la tienda PokéVault para vender tus cartas.", "error")
        return
    end

    local totalCash = 0
    local soldCount = 0

    if cardType == 'all' then
        for itemName, data in pairs(cardPrices) do
            local item = Player.Functions.GetItemByName(itemName)
            if item and item.amount > 0 then
                local amount = item.amount
                if Player.Functions.RemoveItem(itemName, amount) then
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName] or { label = data.label }, "remove")
                    totalCash = totalCash + (data.price * amount)
                    soldCount = soldCount + amount
                end
            end
        end

        if soldCount > 0 then
            Player.Functions.AddMoney('cash', totalCash, 'pokevault-card-sale')
            TriggerClientEvent('spain_pokemon:client:saleComplete', src, soldCount, totalCash)
        else
            TriggerClientEvent('QBCore:Notify', src, "El tasador revisa tu cartera: 'No tienes ninguna carta Pokémon para tasar.'", "error", 6000)
        end
    else
        local data = cardPrices[cardType]
        if not data then return end

        local item = Player.Functions.GetItemByName(cardType)
        if item and item.amount > 0 then
            local amount = item.amount
            if Player.Functions.RemoveItem(cardType, amount) then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[cardType] or { label = data.label }, "remove")
                totalCash = data.price * amount
                soldCount = amount
                Player.Functions.AddMoney('cash', totalCash, 'pokevault-card-sale')
                TriggerClientEvent('spain_pokemon:client:saleComplete', src, soldCount, totalCash)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "El tasador: 'No tienes cartas de " .. data.label .. " en tu inventario.'", "error", 6000)
        end
    end
end)

-- =========================================================================
-- CALLBACKS NATIVOS DE LA NUEVA INTERFAZ POKÉVAULT NUI
-- =========================================================================

local allPokemonItems = {
    'pokemon_booster_151',
    'pokemon_booster_charizard',
    'pokemon_booster_prismatic',
    'pokemon_booster_vintage',
    'pokemon_etb_151',
    'pokemon_mystery_box',
    'pokemon_binder',
    'pokemon_protective_sleeve',
    'pokemon_card_common',
    'pokemon_card_holo',
    'pokemon_card_charizard_vmax',
    'pokemon_card_moonbreon',
    'pokemon_card_mewtwo_gold',
    'pokemon_card_psa10'
}

local function getPlayerPokemonInventory(Player)
    local inv = {}
    for _, itemName in ipairs(allPokemonItems) do
        local itm = Player.Functions.GetItemByName(itemName)
        inv[itemName] = (itm and itm.amount) or 0
    end
    return inv
end

local shopPrices = {
    ['pokemon_booster_151'] = 45,
    ['pokemon_booster_charizard'] = 55,
    ['pokemon_booster_prismatic'] = 60,
    ['pokemon_booster_vintage'] = 350,
    ['pokemon_etb_151'] = 380,
    ['pokemon_mystery_box'] = 500,
    ['pokemon_binder'] = 40,
    ['pokemon_protective_sleeve'] = 15,
}

-- 1. Obtener Datos del Jugador para la NUI
QBCore.Functions.CreateCallback('spain_pokemon:server:getShopData', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local cash = Player.PlayerData.money['cash'] or 0
    local bank = Player.PlayerData.money['bank'] or 0
    local inv = getPlayerPokemonInventory(Player)

    cb({
        cash = cash,
        bank = bank,
        inventory = inv
    })
end)

-- 2. Compra Ilimitada de Sobres y Artículos desde la NUI
QBCore.Functions.CreateCallback('spain_pokemon:server:buyItem', function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({ success = false, message = "Error de sesión del jugador." }) end

    local item = data.item
    local amount = tonumber(data.amount) or 1
    local payment = data.payment == 'bank' and 'bank' or 'cash'

    if not shopPrices[item] or amount <= 0 or amount > 100 then
        return cb({ success = false, message = "Artículo o cantidad inválida." })
    end

    local unitPrice = shopPrices[item]
    local totalPrice = unitPrice * amount
    local currentMoney = Player.PlayerData.money[payment] or 0

    if currentMoney < totalPrice then
        local paymentLabel = payment == 'cash' and 'efectivo' or 'tu cuenta bancaria'
        return cb({ success = false, message = "No tienes suficiente dinero en " .. paymentLabel .. " (Total: €" .. totalPrice .. ")." })
    end

    if Player.Functions.RemoveMoney(payment, totalPrice, 'pokevault-purchase') then
        Player.Functions.AddItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item] or { label = item }, "add")
        
        local itemLabel = (QBCore.Shared.Items[item] and QBCore.Shared.Items[item].label) or item
        TriggerClientEvent('QBCore:Notify', source, "Has adquirido " .. amount .. "x " .. itemLabel .. " por €" .. totalPrice .. " (" .. (payment == 'cash' and "Efectivo" or "Banco") .. ").", "success", 5000)

        cb({
            success = true,
            cash = Player.PlayerData.money['cash'] or 0,
            bank = Player.PlayerData.money['bank'] or 0,
            inventory = getPlayerPokemonInventory(Player)
        })
    else
        cb({ success = false, message = "Fallo al procesar el cobro económico." })
    end
end)

-- 3. Tasación y Venta Dinámica desde la NUI
QBCore.Functions.CreateCallback('spain_pokemon:server:sellCardsNui', function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({ success = false, message = "Error de sesión." }) end

    local cardType = data.type
    local reqAmount = tonumber(data.amount)
    local totalCash = 0
    local soldCount = 0

    if cardType == 'all' then
        for itemName, pData in pairs(cardPrices) do
            local item = Player.Functions.GetItemByName(itemName)
            if item and item.amount > 0 then
                local amt = item.amount
                if Player.Functions.RemoveItem(itemName, amt) then
                    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[itemName] or { label = pData.label }, "remove")
                    totalCash = totalCash + (pData.price * amt)
                    soldCount = soldCount + amt
                end
            end
        end

        if soldCount > 0 then
            Player.Functions.AddMoney('cash', totalCash, 'pokevault-card-sale')
            TriggerClientEvent('spain_pokemon:client:saleComplete', source, soldCount, totalCash)
            cb({
                success = true,
                count = soldCount,
                cash = totalCash,
                newCash = Player.PlayerData.money['cash'] or 0,
                newBank = Player.PlayerData.money['bank'] or 0,
                inventory = getPlayerPokemonInventory(Player)
            })
        else
            cb({ success = false, message = "No tienes ninguna carta Pokémon para tasar." })
        end
    else
        local pData = cardPrices[cardType]
        if not pData then return cb({ success = false, message = "Tipo de carta desconocido." }) end

        local item = Player.Functions.GetItemByName(cardType)
        if item and item.amount > 0 then
            local toSell = (reqAmount and reqAmount > 0 and reqAmount <= item.amount) and reqAmount or item.amount
            if Player.Functions.RemoveItem(cardType, toSell) then
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[cardType] or { label = pData.label }, "remove")
                totalCash = pData.price * toSell
                soldCount = toSell
                Player.Functions.AddMoney('cash', totalCash, 'pokevault-card-sale')
                TriggerClientEvent('spain_pokemon:client:saleComplete', source, soldCount, totalCash)
                cb({
                    success = true,
                    count = soldCount,
                    cash = totalCash,
                    newCash = Player.PlayerData.money['cash'] or 0,
                    newBank = Player.PlayerData.money['bank'] or 0,
                    inventory = getPlayerPokemonInventory(Player)
                })
            else
                cb({ success = false, message = "Error al descontar las cartas del inventario." })
            end
        else
            cb({ success = false, message = "No tienes cartas de " .. pData.label .. " en tu inventario." })
        end
    end
end)

-- Si algún jugador escribe el comando antiguo, se le abre la NUI del tasador
QBCore.Commands.Add('venderpokecartas', 'Hablar con el tasador de PokéVault para vender cartas', {}, false, function(source, args)
    local src = source
    local playerPed = GetPlayerPed(src)
    local pCoords = GetEntityCoords(playerPed)
    local shopCoords = vector3(21.5, -1106.0, 29.8)

    if #(pCoords - shopCoords) <= 6.0 then
        TriggerClientEvent('spain_pokemon:client:openPokeVaultNui', src, 'tab-sell')
    else
        TriggerClientEvent('QBCore:Notify', src, "Para vender tus cartas acude a PokéVault (Plaza Legion) y habla con el Tasador Oficial en el mostrador [E].", "primary", 7500)
    end
end)
