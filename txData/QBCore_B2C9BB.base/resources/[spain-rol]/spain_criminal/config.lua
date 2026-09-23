Config = {}

-- Configuración General de la Tablet Criminal Origin
Config.ItemName = 'criminal_tablet'
Config.Command = 'crimtablet'
Config.Keybind = 'F7' -- Tecla configurable
Config.Debug = false

-- Localización del NPC Contrabandista Clandestino
Config.NPC = {
    model = 's_m_y_dealer_01',
    coords = vector4(752.87, -1864.21, 29.29, 270.0), -- Almacén del Polígono de El Burro
    animDict = 'amb@world_human_smoking@male@male_a@base',
    animName = 'base',
    tabletPrice = 3500,
    shopItems = {
        { name = 'weapon_parts', label = 'Piezas de Armamento Militar', price = 450, icon = 'fas fa-wrench' },
        { name = 'gunpowder', label = 'Bolsa de Pólvora Refinada', price = 250, icon = 'fas fa-fire' },
        { name = 'c4_components', label = 'Detonador y Placa C4', price = 1800, icon = 'fas fa-microchip' },
        { name = 'pure_chemicals', label = 'Precursores Químicos Sintéticos', price = 350, icon = 'fas fa-vial' },
        { name = 'acid', label = 'Garrafa de Ácido Clorhídrico', price = 400, icon = 'fas fa-flask' },
        { name = 'coca_extract', label = 'Pasta Base de Coca Concentrada', price = 800, icon = 'fas fa-cannabis' },
        { name = 'thermite', label = 'Carga de Termita Incendiaria', price = 2200, icon = 'fas fa-bomb' },
        { name = 'advancedlockpick', label = 'Ganzúa Avanzada de Acero', price = 600, icon = 'fas fa-key' }
    }
}

-- Configuración de Organizaciones Criminales y sus Garajes Secretos
Config.Organizations = {
    ['cartel'] = {
        label = 'Cártel de Medellín',
        garageCoords = vector3(-1538.5, 87.2, 56.7), -- Mansión de Richman
        spawnCoords = vector4(-1543.8, 93.4, 56.7, 180.0),
        blip = { sprite = 326, color = 1, scale = 0.75, name = "Garaje Oculto: Cártel" },
        vehicles = {
            { model = 'sultanrs', label = 'Karin Sultan RS Blindado (Cártel)', minGrade = 0, icon = 'fas fa-car' },
            { model = 'dubsta3', label = 'Benefactor Dubsta 6x6 Negro Mate', minGrade = 1, icon = 'fas fa-truck' },
            { model = 'jugular', label = 'Ocelot Jugular V8 Blindado', minGrade = 2, icon = 'fas fa-bolt' },
            { model = 'kuruma', label = 'Karin Kuruma Blindado Pesado', minGrade = 3, icon = 'fas fa-shield-alt' }
        }
    },
    ['mafia'] = {
        label = 'Cosa Nostra / Mafia Española',
        garageCoords = vector3(897.6, -179.3, 73.7), -- Viñedo / Mansión Mafiosa
        spawnCoords = vector4(903.1, -172.5, 73.7, 240.0),
        blip = { sprite = 326, color = 40, scale = 0.75, name = "Garaje Oculto: Cosa Nostra" },
        vehicles = {
            { model = 'schafter3', label = 'Benefactor Schafter V12 Blindado', minGrade = 0, icon = 'fas fa-car' },
            { model = 'cognoscenti2', label = 'Enus Cognoscenti 55 Blindado', minGrade = 1, icon = 'fas fa-car-side' },
            { model = 'reblagts', label = 'Ubermacht Rebla GTS Mafia', minGrade = 2, icon = 'fas fa-car' },
            { model = 'paragon2', label = 'Enus Paragon R Blindado Ejecutivo', minGrade = 3, icon = 'fas fa-crown' }
        }
    },
    ['vagos'] = {
        label = 'Los Santos Vagos',
        garageCoords = vector3(338.2, -2012.8, 22.3), -- Rancho
        spawnCoords = vector4(344.0, -2015.5, 22.3, 140.0),
        blip = { sprite = 326, color = 5, scale = 0.75, name = "Garaje Oculto: Vagos" },
        vehicles = {
            { model = 'buccaneer2', label = 'Albany Buccaneer Custom Vagos', minGrade = 0, icon = 'fas fa-car' },
            { model = 'chino2', label = 'Vapid Chino Custom Amarillo', minGrade = 1, icon = 'fas fa-car' },
            { model = 'manana2', label = 'Albany Manana Custom Lowrider', minGrade = 2, icon = 'fas fa-car-side' },
            { model = 'faction3', label = 'Willard Faction Donk Blindado', minGrade = 3, icon = 'fas fa-truck-pickup' }
        }
    },
    ['ballas'] = {
        label = 'Rollin Heights Ballas',
        garageCoords = vector3(104.8, -1941.5, 20.8), -- Davis / Covenant
        spawnCoords = vector4(112.5, -1945.2, 20.8, 320.0),
        blip = { sprite = 326, color = 7, scale = 0.75, name = "Garaje Oculto: Ballas" },
        vehicles = {
            { model = 'primo2', label = 'Albany Primo Custom Ballas', minGrade = 0, icon = 'fas fa-car' },
            { model = 'voodoo2', label = 'Declasse Voodoo Custom Morado', minGrade = 1, icon = 'fas fa-car' },
            { model = 'virgo2', label = 'Albany Virgo Custom', minGrade = 2, icon = 'fas fa-car-side' },
            { model = 'slamvan3', label = 'Vapid Slamvan Custom Dragster', minGrade = 3, icon = 'fas fa-truck' }
        }
    },
    ['peaky'] = {
        label = 'Peaky Blinders',
        garageCoords = vector3(1215.4, -3004.9, 5.8), -- Almacén del Puerto
        spawnCoords = vector4(1220.6, -3008.2, 5.8, 90.0),
        blip = { sprite = 326, color = 39, scale = 0.75, name = "Garaje Oculto: Peaky Blinders" },
        vehicles = {
            { model = 'roosevelt', label = 'Albany Roosevelt Birmingham 1928', minGrade = 0, icon = 'fas fa-car' },
            { model = 'roosevelt2', label = 'Albany Roosevelt Valor Blindado', minGrade = 1, icon = 'fas fa-shield-alt' },
            { model = 'stafford', label = 'Enus Stafford Lujo Clásico', minGrade = 2, icon = 'fas fa-crown' },
            { model = 'windsor', label = 'Enus Windsor Drop V12', minGrade = 3, icon = 'fas fa-gem' }
        }
    },
    ['bratva'] = {
        label = 'Bratva Rusa',
        garageCoords = vector3(-574.3, 287.4, 82.2), -- Sede Clandestina
        spawnCoords = vector4(-580.1, 292.0, 82.2, 85.0),
        blip = { sprite = 326, color = 76, scale = 0.75, name = "Garaje Oculto: Bratva" },
        vehicles = {
            { model = 'kamacho', label = 'Canis Kamacho Blindado Ruso', minGrade = 0, icon = 'fas fa-truck-monster' },
            { model = 'xls2', label = 'Benefactor XLS Blindado Pesado', minGrade = 1, icon = 'fas fa-shield-alt' },
            { model = 'revolter', label = 'Ubermacht Revolter con Blindaje', minGrade = 2, icon = 'fas fa-bolt' },
            { model = 'insurgent', label = 'HVY Insurgent Militar Negro', minGrade = 3, icon = 'fas fa-tank' }
        }
    }
}

-- Recetas de Fabricación de Armamento Clandestino
Config.WeaponsCrafting = {
    {
        id = 'glock',
        item = 'weapon_pistol50',
        label = 'Pistola Desert Eagle .50 de Combate',
        category = 'Armas Cortas',
        craftTime = 8000, -- en milisegundos
        image = 'https://cfx-nui-spain_criminal/html/img/pistol50.png',
        icon = 'fas fa-crosshairs',
        materials = {
            { item = 'weapon_parts', amount = 3, label = 'Piezas de Armamento' },
            { item = 'steel', amount = 5, label = 'Acero Refinado' },
            { item = 'iron', amount = 4, label = 'Hierro Forjado' }
        }
    },
    {
        id = 'microsmg',
        item = 'weapon_microsmg',
        label = 'Subfusil Micro SMG Táctico',
        category = 'Subfusiles',
        craftTime = 12000,
        icon = 'fas fa-stream',
        materials = {
            { item = 'weapon_parts', amount = 5, label = 'Piezas de Armamento' },
            { item = 'steel', amount = 10, label = 'Acero Refinado' },
            { item = 'aluminum', amount = 6, label = 'Aluminio Templado' }
        }
    },
    {
        id = 'ak47',
        item = 'weapon_assaultrifle',
        label = 'Fusil de Asalto AK-47 Clandestino',
        category = 'Fusiles',
        craftTime = 18000,
        icon = 'fas fa-fire-alt',
        materials = {
            { item = 'weapon_parts', amount = 10, label = 'Piezas de Armamento' },
            { item = 'steel', amount = 16, label = 'Acero Refinado' },
            { item = 'rubber', amount = 8, label = 'Polímero de Agarre' }
        }
    },
    {
        id = 'c4_explosive',
        item = 'heavy_c4',
        label = 'Carga de C4 Militar con Detonador',
        category = 'Explosivos',
        craftTime = 15000,
        icon = 'fas fa-bomb',
        materials = {
            { item = 'c4_components', amount = 2, label = 'Detonador y Circuitería C4' },
            { item = 'gunpowder', amount = 8, label = 'Bolsa de Pólvora Refinada' },
            { item = 'electronicscrap', amount = 5, label = 'Restos Electrónicos' }
        }
    },
    {
        id = 'advanced_lockpick',
        item = 'advancedlockpick',
        label = 'Ganzúa Avanzada de Robo',
        category = 'Herramientas',
        craftTime = 6000,
        icon = 'fas fa-key',
        materials = {
            { item = 'steel', amount = 3, label = 'Acero Refinado' },
            { item = 'iron', amount = 3, label = 'Hierro Forjado' }
        }
    },
    {
        id = 'ammo_pistol',
        item = 'pistol_ammo',
        label = 'Caja de Munición Calibre 9mm (x30)',
        category = 'Municiones',
        craftTime = 4000,
        icon = 'fas fa-boxes',
        materials = {
            { item = 'gunpowder', amount = 2, label = 'Pólvora Refinada' },
            { item = 'metalscrap', amount = 4, label = 'Chatarra Metálica' }
        }
    },
    {
        id = 'ammo_rifle',
        item = 'rifle_ammo',
        label = 'Caja de Munición Fusil 7.62mm (x30)',
        category = 'Municiones',
        craftTime = 5000,
        icon = 'fas fa-boxes',
        materials = {
            { item = 'gunpowder', amount = 4, label = 'Pólvora Refinada' },
            { item = 'metalscrap', amount = 6, label = 'Chatarra Metálica' }
        }
    }
}

-- Recetas de Fabricación de Drogas Sintéticas y Refinadas
Config.DrugsCrafting = {
    {
        id = 'blue_meth',
        item = 'blue_meth',
        label = 'Metanfetamina Azul 99.1% (Breaking Bad)',
        category = 'Sintéticos',
        craftTime = 10000,
        icon = 'fas fa-gem',
        materials = {
            { item = 'pure_chemicals', amount = 3, label = 'Precursores Químicos Sintéticos' },
            { item = 'acid', amount = 1, label = 'Garrafa de Ácido Clorhídrico' }
        }
    },
    {
        id = 'cocaine_pure',
        item = 'cokebaggy',
        label = 'Bolsita de Cocaína Escama de Pescado',
        category = 'Estimulantes',
        craftTime = 8000,
        icon = 'fas fa-snowflake',
        materials = {
            { item = 'coca_extract', amount = 2, label = 'Pasta Base de Coca Concentrada' },
            { item = 'acid', amount = 1, label = 'Ácido Clorhídrico' }
        }
    },
    {
        id = 'xtc_pill',
        item = 'xtcbaggy',
        label = 'Pastillas de Éxtasis Puro / Tussi',
        category = 'Sintéticos',
        craftTime = 7000,
        icon = 'fas fa-pills',
        materials = {
            { item = 'pure_chemicals', amount = 2, label = 'Precursores Químicos' },
            { item = 'sugar', amount = 2, label = 'Glucosa Excipiente' }
        }
    },
    {
        id = 'weed_cured',
        item = 'weed_baggy',
        label = 'Bolsa de Cogollos Curados OG Kush',
        category = 'Orgánicos',
        craftTime = 6000,
        icon = 'fas fa-cannabis',
        materials = {
            { item = 'weed_leaf', amount = 4, label = 'Hojas de Marihuana' },
            { item = 'plastic', amount = 2, label = 'Bolsitas Herméticas' }
        }
    }
}
