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
end)

-- Comando para vender cartas repetidas al tendero de PokéVault
QBCore.Commands.Add('venderpokecartas', 'Vender cartas Pokémon repetidas en la tienda PokéVault', {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local totalCash = 0
    local soldCount = 0

    local prices = {
        ['pokemon_card_common'] = 15,
        ['pokemon_card_holo'] = 65,
        ['pokemon_card_charizard_vmax'] = 1200,
        ['pokemon_card_moonbreon'] = 1200,
        ['pokemon_card_mewtwo_gold'] = 900,
        ['pokemon_card_psa10'] = 2500,
    }

    for cardName, price in pairs(prices) do
        local item = Player.Functions.GetItemByName(cardName)
        if item and item.amount > 0 then
            local count = item.amount
            if Player.Functions.RemoveItem(cardName, count) then
                totalCash = totalCash + (price * count)
                soldCount = soldCount + count
            end
        end
    end

    if soldCount > 0 then
        Player.Functions.AddMoney('cash', totalCash, 'pokevault-card-sale')
        TriggerClientEvent('QBCore:Notify', source, "Has vendido " .. soldCount .. " cartas Pokémon en PokéVault por €" .. totalCash .. " en efectivo.", "success", 7500)
    else
        TriggerClientEvent('QBCore:Notify', source, "No tienes cartas Pokémon en tu inventario para vender.", "error")
    end
end)
