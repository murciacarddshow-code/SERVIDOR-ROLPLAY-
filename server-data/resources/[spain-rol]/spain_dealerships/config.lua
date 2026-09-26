Config = {}

-- Margen de beneficio al revender en el compra-venta (15% sobre el precio de tasación)
Config.ResellProfitMargin = 1.15

-- Porcentaje de tasación oficial sobre el valor de mercado al vender al compra-venta (70%)
Config.ResellMultiplier = 0.70

-- Garaje por defecto donde se deposita el coche comprado
Config.DefaultGarage = 'pillboxgarage'

-- Configuración de las 3 sedes de compra-venta
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

-- Stock inicial de vehículos usados para arrancar el servidor (si la base de datos está vacía)
Config.StarterStock = {
    ['dealership_sur'] = {
        { model = 'elegy2', label = 'Annis Elegy Retro Custom', brand = 'Annis', category = 'sports', price = 89000, plate = 'SUR 0110', seller = 'Particular' },
        { model = 'sultan', label = 'Karin Sultan RS', brand = 'Karin', category = 'sports', price = 39000, plate = 'SUR 0220', seller = 'Particular' },
        { model = 'schafter2', label = 'Benefactor Schafter V12', brand = 'Benefactor', category = 'sedans', price = 36000, plate = 'SUR 0330', seller = 'Empresa VTC' }
    },
    ['dealership_sandy'] = {
        { model = 'sandking', label = 'Vapid Sandking XL Monster', brand = 'Vapid', category = 'suvs', price = 38000, plate = 'SND 4040', seller = 'Rancho Desert' },
        { model = 'kamacho', label = 'Canis Kamacho All-Terrain', brand = 'Canis', category = 'suvs', price = 49000, plate = 'SND 5050', seller = 'Cazador Local' },
        { model = 'sanchez', label = 'Maibatsu Sanchez Motocross', brand = 'Maibatsu', category = 'bikes', price = 11500, plate = 'SND 6060', seller = 'Circuito Cross' }
    },
    ['dealership_paleto'] = {
        { model = 'dubsta', label = 'Benefactor Dubsta Luxury 4x4', brand = 'Benefactor', category = 'suvs', price = 58000, plate = 'PLT 7070', seller = 'Turista' },
        { model = 'tailgater', label = 'Obey Tailgater Ejecutivo', brand = 'Obey', category = 'sedans', price = 29500, plate = 'PLT 8080', seller = 'Empresario Norte' },
        { model = 'kuruma', label = 'Karin Kuruma Sport', brand = 'Karin', category = 'sports', price = 52000, plate = 'PLT 9090', seller = 'Particular' }
    }
}

-- Base de datos de referencia técnica para calcular especificaciones y precios de tasación
Config.VehicleDatabase = {
    -- COMPACTOS & UTILITARIOS
    ['blista'] = { label = 'Dinka Blista', brand = 'Dinka', category = 'compacts', basePrice = 13000, speed = 65, accel = 68, brakes = 70, handling = 72, image = 'https://docs.fivem.net/vehicles/blista.webp' },

    -- SUPERDEPORTIVOS
    ['zentorno'] = { label = 'Pegassi Zentorno', brand = 'Pegassi', category = 'super', basePrice = 320000, speed = 96, accel = 98, brakes = 88, handling = 90, image = 'https://docs.fivem.net/vehicles/zentorno.webp' },
    ['t20'] = { label = 'Progen T20', brand = 'Progen', category = 'super', basePrice = 450000, speed = 98, accel = 95, brakes = 92, handling = 92, image = 'https://docs.fivem.net/vehicles/t20.webp' },
    ['turismor'] = { label = 'Grotti Turismo R', brand = 'Grotti', category = 'super', basePrice = 280000, speed = 94, accel = 93, brakes = 85, handling = 88, image = 'https://docs.fivem.net/vehicles/turismor.webp' },
    ['adder'] = { label = 'Truffade Adder', brand = 'Truffade', category = 'super', basePrice = 520000, speed = 99, accel = 90, brakes = 84, handling = 82, image = 'https://docs.fivem.net/vehicles/adder.webp' },
    ['vacca'] = { label = 'Pegassi Vacca', brand = 'Pegassi', category = 'super', basePrice = 180000, speed = 90, accel = 88, brakes = 82, handling = 85, image = 'https://docs.fivem.net/vehicles/vacca.webp' },

    -- DEPORTIVOS & TUNING
    ['elegy2'] = { label = 'Annis Elegy Retro Custom', brand = 'Annis', category = 'sports', basePrice = 110000, speed = 88, accel = 86, brakes = 80, handling = 94, image = 'https://docs.fivem.net/vehicles/elegy2.webp' },
    ['jester'] = { label = 'Dinka Jester Race', brand = 'Dinka', category = 'sports', basePrice = 95000, speed = 85, accel = 84, brakes = 82, handling = 86, image = 'https://docs.fivem.net/vehicles/jester.webp' },
    ['kuruma'] = { label = 'Karin Kuruma Sport', brand = 'Karin', category = 'sports', basePrice = 65000, speed = 82, accel = 80, brakes = 75, handling = 85, image = 'https://docs.fivem.net/vehicles/kuruma.webp' },
    ['sultan'] = { label = 'Karin Sultan RS', brand = 'Karin', category = 'sports', basePrice = 45000, speed = 80, accel = 82, brakes = 76, handling = 88, image = 'https://docs.fivem.net/vehicles/sultan.webp' },
    ['comet2'] = { label = 'Pfister Comet GT', brand = 'Pfister', category = 'sports', basePrice = 85000, speed = 87, accel = 85, brakes = 80, handling = 83, image = 'https://docs.fivem.net/vehicles/comet2.webp' },
    ['massacro'] = { label = 'Dewbauchee Massacro', brand = 'Dewbauchee', category = 'sports', basePrice = 120000, speed = 89, accel = 86, brakes = 82, handling = 85, image = 'https://docs.fivem.net/vehicles/massacro.webp' },

    -- SEDANES & BERLINAS
    ['schafter2'] = { label = 'Benefactor Schafter V12', brand = 'Benefactor', category = 'sedans', basePrice = 42000, speed = 82, accel = 78, brakes = 74, handling = 78, image = 'https://docs.fivem.net/vehicles/schafter2.webp' },
    ['tailgater'] = { label = 'Obey Tailgater', brand = 'Obey', category = 'sedans', basePrice = 35000, speed = 76, accel = 72, brakes = 70, handling = 75, image = 'https://docs.fivem.net/vehicles/tailgater.webp' },
    ['oracle'] = { label = 'Ubermacht Oracle Executive', brand = 'Ubermacht', category = 'sedans', basePrice = 32000, speed = 75, accel = 70, brakes = 72, handling = 74, image = 'https://docs.fivem.net/vehicles/oracle.webp' },
    ['primo'] = { label = 'Albany Primo Custom', brand = 'Albany', category = 'sedans', basePrice = 18000, speed = 68, accel = 62, brakes = 65, handling = 70, image = 'https://docs.fivem.net/vehicles/primo.webp' },
    ['fugitive'] = { label = 'Cheval Fugitive', brand = 'Cheval', category = 'sedans', basePrice = 24000, speed = 72, accel = 68, brakes = 68, handling = 72, image = 'https://docs.fivem.net/vehicles/fugitive.webp' },

    -- SUVS & TODOTERRENOS (4X4)
    ['dubsta'] = { label = 'Benefactor Dubsta Luxury 4x4', brand = 'Benefactor', category = 'suvs', basePrice = 70000, speed = 78, accel = 74, brakes = 72, handling = 76, image = 'https://docs.fivem.net/vehicles/dubsta.webp' },
    ['kamacho'] = { label = 'Canis Kamacho All-Terrain', brand = 'Canis', category = 'suvs', basePrice = 60000, speed = 76, accel = 82, brakes = 70, handling = 85, image = 'https://docs.fivem.net/vehicles/kamacho.webp' },
    ['baller'] = { label = 'Gallivanter Baller Sport', brand = 'Gallivanter', category = 'suvs', basePrice = 55000, speed = 77, accel = 73, brakes = 71, handling = 74, image = 'https://docs.fivem.net/vehicles/baller.webp' },
    ['sandking'] = { label = 'Vapid Sandking XL Monster', brand = 'Vapid', category = 'suvs', basePrice = 45000, speed = 70, accel = 75, brakes = 66, handling = 80, image = 'https://docs.fivem.net/vehicles/sandking.webp' },
    ['rebel'] = { label = 'Karin Rebel 4x4 Pickup', brand = 'Karin', category = 'suvs', basePrice = 22000, speed = 69, accel = 71, brakes = 65, handling = 75, image = 'https://docs.fivem.net/vehicles/rebel.webp' },
    ['bison'] = { label = 'Bravado Bison Pickup', brand = 'Bravado', category = 'suvs', basePrice = 30000, speed = 70, accel = 68, brakes = 65, handling = 72, image = 'https://docs.fivem.net/vehicles/bison.webp' },

    -- MOTOCICLETAS
    ['bati'] = { label = 'Pegassi Bati 801 Racing', brand = 'Pegassi', category = 'bikes', basePrice = 25000, speed = 92, accel = 94, brakes = 82, handling = 86, image = 'https://docs.fivem.net/vehicles/bati.webp' },
    ['akuma'] = { label = 'Dinka Akuma Naked', brand = 'Dinka', category = 'bikes', basePrice = 18000, speed = 88, accel = 92, brakes = 80, handling = 88, image = 'https://docs.fivem.net/vehicles/akuma.webp' },
    ['sanchez'] = { label = 'Maibatsu Sanchez Motocross', brand = 'Maibatsu', category = 'bikes', basePrice = 14000, speed = 75, accel = 86, brakes = 74, handling = 90, image = 'https://docs.fivem.net/vehicles/sanchez.webp' },
    ['daemon'] = { label = 'Western Daemon Custom Chopper', brand = 'Western', category = 'bikes', basePrice = 22000, speed = 78, accel = 76, brakes = 72, handling = 75, image = 'https://docs.fivem.net/vehicles/daemon.webp' },
    ['faggio3'] = { label = 'Pegassi Faggio Sport Scooter', brand = 'Pegassi', category = 'bikes', basePrice = 4500, speed = 52, accel = 50, brakes = 60, handling = 82, image = 'https://docs.fivem.net/vehicles/faggio3.webp' },

    -- FURGONETAS Y COMERCIALES
    ['burrito3'] = { label = 'Declasse Burrito Custom', brand = 'Declasse', category = 'vans', basePrice = 28000, speed = 72, accel = 66, brakes = 65, handling = 68, image = 'https://docs.fivem.net/vehicles/burrito3.webp' },
    ['speedo'] = { label = 'Vapid Speedo Express', brand = 'Vapid', category = 'vans', basePrice = 22000, speed = 70, accel = 64, brakes = 64, handling = 66, image = 'https://docs.fivem.net/vehicles/speedo.webp' },
    ['rumpo'] = { label = 'Bravado Rumpo Delivery', brand = 'Bravado', category = 'vans', basePrice = 20000, speed = 68, accel = 62, brakes = 63, handling = 65, image = 'https://docs.fivem.net/vehicles/rumpo.webp' }
}

-- Función auxiliar para obtener detalles técnicos de un modelo
function GetVehicleMetadata(modelName)
    local key = string.lower(modelName)
    if Config.VehicleDatabase[key] then
        return Config.VehicleDatabase[key]
    end
    -- Fallback si el modelo no está en el catálogo
    return {
        label = string.upper(string.sub(modelName, 1, 1)) .. string.sub(modelName, 2),
        brand = 'Ocasión',
        category = 'sports',
        basePrice = 25000,
        speed = 75,
        accel = 75,
        brakes = 75,
        handling = 75,
        image = 'https://docs.fivem.net/vehicles/' .. key .. '.webp'
    }
end
