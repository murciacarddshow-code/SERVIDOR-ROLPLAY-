Config = {}

-- Configuración de Blanqueo de Dinero Negro
Config.MoneyLaundry = {
    coords = vector3(1122.45, -3194.32, -40.40), -- Interior de lavandería clandestina
    pedModel = 'g_m_m_chigoon_01',
    pedCoords = vector4(1122.45, -3194.32, -40.40, 180.0),
    laundryCut = 0.15, -- 15% de comisión que se queda el mafioso
    washTime = 10000   -- Tiempo de lavado en ms
}

-- Configuración del Mercado Negro Clandestino de Armas
Config.BlackMarket = {
    coords = vector3(980.52, -1820.73, 31.15), -- Callejón de El Burro Heights
    pedModel = 's_m_y_dealer_01',
    heading = 85.0,
    items = {
        { name = 'weapon_pistol50', price = 4500, label = 'Pistola Desert Eagle .50' },
        { name = 'weapon_appistol', price = 7500, label = 'Pistola Automática AP' },
        { name = 'weapon_microsmg', price = 12000, label = 'Subfusil Micro SMG (Uzi)' },
        { name = 'weapon_assaultrifle', price = 28000, label = 'Fusil de Asalto AK-47' },
        { name = 'weapon_carbinerifle', price = 32000, label = 'Carabina Militar M4A1' },
        { name = 'weapon_pumpshotgun', price = 15000, label = 'Escopeta Calibre 12' },
        { name = 'heavy_c4', price = 10000, label = 'Cargas Explosivas C4 Militar' },
        { name = 'pistol_ammo', price = 250, label = 'Caja de Munición 9mm' },
        { name = 'smg_ammo', price = 450, label = 'Caja de Munición Subfusil' },
        { name = 'rifle_ammo', price = 850, label = 'Caja de Munición 7.62 / 5.56' },
        { name = 'shotgun_ammo', price = 500, label = 'Cartuchos Escopeta Cal. 12' },
        { name = 'advancedlockpick', price = 1200, label = 'Ganzúa Avanzada de Robo' },
        { name = 'thermite', price = 3500, label = 'Carga de Termita Incendiaria' },
    }
}

-- Efectos de Drogas
Config.DrugEffects = {
    ['joint'] = { armor = 15, stress = 30, duration = 12000 },
    ['cokebaggy'] = { speed = 1.3, armor = 25, duration = 15000 },
    ['meth'] = { speed = 1.4, armor = 40, duration = 20000 },
    ['blue_meth'] = { speed = 1.5, armor = 60, duration = 25000 },
    ['xtcbaggy'] = { effect = 'visual_rainbow', duration = 30000 },
    ['mushrooms'] = { effect = 'visual_distortion', duration = 30000 },
    ['heroin_syringe'] = { armor = 100, health = 50, duration = 25000 }
}
