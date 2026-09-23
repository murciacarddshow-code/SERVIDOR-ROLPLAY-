Config = {}

-- Porcentaje de tasación oficial sobre el valor de mercado al vender al compra-venta (70%)
Config.ResellMultiplier = 0.70

-- Garaje por defecto donde se deposita el coche comprado
Config.DefaultGarage = 'pillboxgarage'

-- Configuracion de las 3 sedes de compra-venta
Config.Dealerships = {
    ['dealership_sur'] = {
        id = 'dealership_sur',
        job = 'dealership_sur',
        name = 'Motors Sur Ocasión',
        city = 'Los Santos Sur (Davis / Strawberry)',
        coords = vector4(-29.7, -1680.5, 29.4, 320.0),
        pedModel = 'a_m_y_business_02',
        blip = {
            sprite = 523,
            color = 2, -- Verde esmeralda
            scale = 0.85,
            label = 'Compra-Venta: Motors Sur'
        },
        spawnCoords = vector4(-23.6, -1674.2, 29.5, 140.0),
        societyAccount = 'dealership_sur'
    },
    ['dealership_sandy'] = {
        id = 'dealership_sandy',
        job = 'dealership_sandy',
        name = 'Desert Motors Sandy',
        city = 'Sandy Shores (Ruta 68)',
        coords = vector4(1224.7, 2728.1, 38.0, 180.0),
        pedModel = 'a_m_m_hillbilly_01',
        blip = {
            sprite = 523,
            color = 46, -- Ámbar / Dorado
            scale = 0.85,
            label = 'Compra-Venta: Desert Motors'
        },
        spawnCoords = vector4(1218.3, 2717.5, 38.0, 180.0),
        societyAccount = 'dealership_sandy'
    },
    ['dealership_paleto'] = {
        id = 'dealership_paleto',
        job = 'dealership_paleto',
        name = 'Costa Norte Motors',
        city = 'Paleto Bay (Costa Norte)',
        coords = vector4(-217.4, 6223.1, 31.5, 225.0),
        pedModel = 'a_m_y_smartcaspat_01',
        blip = {
            sprite = 523,
            color = 3, -- Azul marino
            scale = 0.85,
            label = 'Compra-Venta: Costa Norte Motors'
        },
        spawnCoords = vector4(-226.5, 6230.2, 31.5, 225.0),
        societyAccount = 'dealership_paleto'
    }
}

-- Catálogo de vehículos disponibles en el stock de ocasión
Config.Vehicles = {
    -- SUPERDEPORTIVOS
    {
        model = 'zentorno',
        label = 'Pegassi Zentorno',
        brand = 'Pegassi',
        category = 'super',
        price = 320000,
        speed = 96,
        accel = 98,
        brakes = 88,
        handling = 90,
        image = 'https://docs.fivem.net/vehicles/zentorno.webp'
    },
    {
        model = 't20',
        label = 'Progen T20',
        brand = 'Progen',
        category = 'super',
        price = 450000,
        speed = 98,
        accel = 95,
        brakes = 92,
        handling = 92,
        image = 'https://docs.fivem.net/vehicles/t20.webp'
    },
    {
        model = 'turismor',
        label = 'Grotti Turismo R',
        brand = 'Grotti',
        category = 'super',
        price = 280000,
        speed = 94,
        accel = 93,
        brakes = 85,
        handling = 88,
        image = 'https://docs.fivem.net/vehicles/turismor.webp'
    },
    {
        model = 'adder',
        label = 'Truffade Adder',
        brand = 'Truffade',
        category = 'super',
        price = 520000,
        speed = 99,
        accel = 90,
        brakes = 84,
        handling = 82,
        image = 'https://docs.fivem.net/vehicles/adder.webp'
    },

    -- DEPORTIVOS & TUNING
    {
        model = 'elegy2',
        label = 'Annis Elegy Retro Custom',
        brand = 'Annis',
        category = 'sports',
        price = 110000,
        speed = 88,
        accel = 86,
        brakes = 80,
        handling = 94,
        image = 'https://docs.fivem.net/vehicles/elegy2.webp'
    },
    {
        model = 'jester',
        label = 'Dinka Jester Race',
        brand = 'Dinka',
        category = 'sports',
        price = 95000,
        speed = 85,
        accel = 84,
        brakes = 82,
        handling = 86,
        image = 'https://docs.fivem.net/vehicles/jester.webp'
    },
    {
        model = 'kuruma',
        label = 'Karin Kuruma Sport',
        brand = 'Karin',
        category = 'sports',
        price = 65000,
        speed = 82,
        accel = 80,
        brakes = 75,
        handling = 85,
        image = 'https://docs.fivem.net/vehicles/kuruma.webp'
    },
    {
        model = 'sultan',
        label = 'Karin Sultan RS',
        brand = 'Karin',
        category = 'sports',
        price = 45000,
        speed = 80,
        accel = 82,
        brakes = 76,
        handling = 88,
        image = 'https://docs.fivem.net/vehicles/sultan.webp'
    },
    {
        model = 'comet2',
        label = 'Pfister Comet GT',
        brand = 'Pfister',
        category = 'sports',
        price = 85000,
        speed = 87,
        accel = 85,
        brakes = 80,
        handling = 83,
        image = 'https://docs.fivem.net/vehicles/comet2.webp'
    },

    -- SEDANES & BERLINAS
    {
        model = 'schafter2',
        label = 'Benefactor Schafter V12',
        brand = 'Benefactor',
        category = 'sedans',
        price = 42000,
        speed = 82,
        accel = 78,
        brakes = 74,
        handling = 78,
        image = 'https://docs.fivem.net/vehicles/schafter2.webp'
    },
    {
        model = 'tailgater',
        label = 'Obey Tailgater',
        brand = 'Obey',
        category = 'sedans',
        price = 35000,
        speed = 76,
        accel = 72,
        brakes = 70,
        handling = 75,
        image = 'https://docs.fivem.net/vehicles/tailgater.webp'
    },
    {
        model = 'oracle',
        label = 'Ubermacht Oracle Executive',
        brand = 'Ubermacht',
        category = 'sedans',
        price = 32000,
        speed = 75,
        accel = 70,
        brakes = 72,
        handling = 74,
        image = 'https://docs.fivem.net/vehicles/oracle.webp'
    },
    {
        model = 'primo',
        label = 'Albany Primo Custom',
        brand = 'Albany',
        category = 'sedans',
        price = 18000,
        speed = 68,
        accel = 62,
        brakes = 65,
        handling = 70,
        image = 'https://docs.fivem.net/vehicles/primo.webp'
    },

    -- SUVS & TODOTERRENOS (4X4)
    {
        model = 'dubsta',
        label = 'Benefactor Dubsta Luxury 4x4',
        brand = 'Benefactor',
        category = 'suvs',
        price = 70000,
        speed = 78,
        accel = 74,
        brakes = 72,
        handling = 76,
        image = 'https://docs.fivem.net/vehicles/dubsta.webp'
    },
    {
        model = 'kamacho',
        label = 'Canis Kamacho All-Terrain',
        brand = 'Canis',
        category = 'suvs',
        price = 60000,
        speed = 76,
        accel = 82,
        brakes = 70,
        handling = 85,
        image = 'https://docs.fivem.net/vehicles/kamacho.webp'
    },
    {
        model = 'baller',
        label = 'Gallivanter Baller Sport',
        brand = 'Gallivanter',
        category = 'suvs',
        price = 55000,
        speed = 77,
        accel = 73,
        brakes = 71,
        handling = 74,
        image = 'https://docs.fivem.net/vehicles/baller.webp'
    },
    {
        model = 'sandking',
        label = 'Vapid Sandking XL Monster',
        brand = 'Vapid',
        category = 'suvs',
        price = 45000,
        speed = 70,
        accel = 75,
        brakes = 66,
        handling = 80,
        image = 'https://docs.fivem.net/vehicles/sandking.webp'
    },
    {
        model = 'rebel',
        label = 'Karin Rebel 4x4 Pickup',
        brand = 'Karin',
        category = 'suvs',
        price = 22000,
        speed = 69,
        accel = 71,
        brakes = 65,
        handling = 75,
        image = 'https://docs.fivem.net/vehicles/rebel.webp'
    },

    -- MOTOCICLETAS
    {
        model = 'bati',
        label = 'Pegassi Bati 801 Racing',
        brand = 'Pegassi',
        category = 'bikes',
        price = 25000,
        speed = 92,
        accel = 94,
        brakes = 82,
        handling = 86,
        image = 'https://docs.fivem.net/vehicles/bati.webp'
    },
    {
        model = 'akuma',
        label = 'Dinka Akuma Naked',
        brand = 'Dinka',
        category = 'bikes',
        price = 18000,
        speed = 88,
        accel = 92,
        brakes = 80,
        handling = 88,
        image = 'https://docs.fivem.net/vehicles/akuma.webp'
    },
    {
        model = 'sanchez',
        label = 'Maibatsu Sanchez Motocross',
        brand = 'Maibatsu',
        category = 'bikes',
        price = 14000,
        speed = 75,
        accel = 86,
        brakes = 74,
        handling = 90,
        image = 'https://docs.fivem.net/vehicles/sanchez.webp'
    },
    {
        model = 'daemon',
        label = 'Western Daemon Custom Chopper',
        brand = 'Western',
        category = 'bikes',
        price = 22000,
        speed = 78,
        accel = 76,
        brakes = 72,
        handling = 75,
        image = 'https://docs.fivem.net/vehicles/daemon.webp'
    },
    {
        model = 'faggio3',
        label = 'Pegassi Faggio Sport Scooter',
        brand = 'Pegassi',
        category = 'bikes',
        price = 4500,
        speed = 52,
        accel = 50,
        brakes = 60,
        handling = 82,
        image = 'https://docs.fivem.net/vehicles/faggio3.webp'
    },

    -- FURGONETAS Y COMERCIALES
    {
        model = 'burrito3',
        label = 'Declasse Burrito Custom',
        brand = 'Declasse',
        category = 'vans',
        price = 28000,
        speed = 72,
        accel = 66,
        brakes = 65,
        handling = 68,
        image = 'https://docs.fivem.net/vehicles/burrito3.webp'
    },
    {
        model = 'speedo',
        label = 'Vapid Speedo Express',
        brand = 'Vapid',
        category = 'vans',
        price = 22000,
        speed = 70,
        accel = 64,
        brakes = 64,
        handling = 66,
        image = 'https://docs.fivem.net/vehicles/speedo.webp'
    },
    {
        model = 'rumpo',
        label = 'Bravado Rumpo Delivery',
        brand = 'Bravado',
        category = 'vans',
        price = 20000,
        speed = 68,
        accel = 62,
        brakes = 63,
        handling = 65,
        image = 'https://docs.fivem.net/vehicles/rumpo.webp'
    }
}
