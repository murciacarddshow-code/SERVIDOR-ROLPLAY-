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
        { model = 'm3e92', label = 'BMW M3 E92 V8', brand = 'BMW', category = 'sports', price = 52000, plate = 'SUR 0110', seller = 'Particular' },
        { model = 'golfgti7', label = 'Volkswagen Golf VII GTI', brand = 'Volkswagen', category = 'compacts', price = 29500, plate = 'SUR 0220', seller = 'Particular' },
        { model = 'c6320', label = 'Mercedes-AMG C63s Coupe', brand = 'Mercedes-Benz', category = 'sports', price = 86000, plate = 'SUR 0330', seller = 'Empresa VTC' },
        { model = 'rs6', label = 'Audi RS6 Avant C7', brand = 'Audi', category = 'sedans', price = 122000, plate = 'SUR 0440', seller = 'Particular' }
    },
    ['dealership_sandy'] = {
        { model = 'raptor2017', label = 'Ford F-150 Raptor Offroad', brand = 'Ford', category = 'suvs', price = 72000, plate = 'SND 4040', seller = 'Rancho Desert' },
        { model = '09tahoe', label = 'Chevrolet Tahoe LTZ V8', brand = 'Chevrolet', category = 'suvs', price = 28000, plate = 'SND 5050', seller = 'Cazador Local' },
        { model = 'trx', label = 'RAM 1500 TRX 6.2 Supercharged', brand = 'Dodge', category = 'muscle', price = 95000, plate = 'SND 6060', seller = 'Circuito Cross' },
        { model = 'mustang50th', label = 'Ford Mustang 50th V8', brand = 'Ford', category = 'muscle', price = 49000, plate = 'SND 7070', seller = 'Particular' }
    },
    ['dealership_paleto'] = {
        { model = 'q820', label = 'Audi Q8 50 TDI Quattro', brand = 'Audi', category = 'suvs', price = 78000, plate = 'PLT 8080', seller = 'Empresario Norte' },
        { model = 'G65', label = 'Mercedes-AMG G65 V12 Biturbo', brand = 'Mercedes-Benz', category = 'suvs', price = 165000, plate = 'PLT 9090', seller = 'Turista' },
        { model = 'skyline', label = 'Nissan Skyline GT-R R34 V-Spec', brand = 'Nissan', category = 'sports', price = 82000, plate = 'PLT 1010', seller = 'Particular' },
        { model = '718caymans', label = 'Porsche 718 Cayman S', brand = 'Porsche', category = 'sports', price = 69000, plate = 'PLT 2020', seller = 'Particular' }
    }
}
-- Base de datos de referencia técnica para calcular especificaciones y precios de tasación
Config.VehicleDatabase = {
    -- COCHES REALES OFICIALES (100) --
    ['bolide'] = { label = 'Bugatti Bolide W16', brand = 'Bugatti', category = 'super', basePrice = 2800000, speed = 99, accel = 99, brakes = 95, handling = 96, image = 'https://docs.fivem.net/vehicles/bolide.webp' },
    ['chiron'] = { label = 'Bugatti Chiron Super Sport', brand = 'Bugatti', category = 'super', basePrice = 2400000, speed = 99, accel = 98, brakes = 94, handling = 92, image = 'https://docs.fivem.net/vehicles/chiron.webp' },
    ['laferrari'] = { label = 'Ferrari LaFerrari Aperta', brand = 'Ferrari', category = 'super', basePrice = 1400000, speed = 97, accel = 96, brakes = 93, handling = 94, image = 'https://docs.fivem.net/vehicles/laferrari.webp' },
    ['fxxk'] = { label = 'Ferrari FXX-K Evo', brand = 'Ferrari', category = 'super', basePrice = 1650000, speed = 98, accel = 97, brakes = 96, handling = 97, image = 'https://docs.fivem.net/vehicles/fxxk.webp' },
    ['488'] = { label = 'Ferrari 488 GTB Spider', brand = 'Ferrari', category = 'super', basePrice = 285000, speed = 95, accel = 94, brakes = 90, handling = 91, image = 'https://docs.fivem.net/vehicles/488.webp' },
    ['f812'] = { label = 'Ferrari 812 Superfast V12', brand = 'Ferrari', category = 'super', basePrice = 340000, speed = 96, accel = 95, brakes = 91, handling = 90, image = 'https://docs.fivem.net/vehicles/f812.webp' },
    ['f430s'] = { label = 'Ferrari F430 Scuderia', brand = 'Ferrari', category = 'super', basePrice = 195000, speed = 91, accel = 90, brakes = 87, handling = 88, image = 'https://docs.fivem.net/vehicles/f430s.webp' },
    ['svj63'] = { label = 'Lamborghini Aventador SVJ', brand = 'Lamborghini', category = 'super', basePrice = 520000, speed = 97, accel = 96, brakes = 93, handling = 93, image = 'https://docs.fivem.net/vehicles/svj63.webp' },
    ['huracanst'] = { label = 'Lamborghini Huracan ST', brand = 'Lamborghini', category = 'super', basePrice = 310000, speed = 94, accel = 95, brakes = 90, handling = 92, image = 'https://docs.fivem.net/vehicles/huracanst.webp' },
    ['veneno'] = { label = 'Lamborghini Veneno LP 750', brand = 'Lamborghini', category = 'super', basePrice = 1800000, speed = 98, accel = 96, brakes = 94, handling = 95, image = 'https://docs.fivem.net/vehicles/veneno.webp' },
    ['lambose'] = { label = 'Lamborghini Sesto Elemento', brand = 'Lamborghini', category = 'super', basePrice = 1500000, speed = 97, accel = 98, brakes = 95, handling = 96, image = 'https://docs.fivem.net/vehicles/lambose.webp' },
    ['mclarenp1'] = { label = 'McLaren P1 Hyper Hybrid', brand = 'McLaren', category = 'super', basePrice = 1250000, speed = 97, accel = 96, brakes = 92, handling = 94, image = 'https://docs.fivem.net/vehicles/mclarenp1.webp' },
    ['mclaren720s'] = { label = 'McLaren 720S Performance', brand = 'McLaren', category = 'super', basePrice = 315000, speed = 96, accel = 96, brakes = 91, handling = 93, image = 'https://docs.fivem.net/vehicles/mclaren720s.webp' },
    ['senna'] = { label = 'McLaren Senna Track Edition', brand = 'McLaren', category = 'super', basePrice = 1100000, speed = 97, accel = 97, brakes = 97, handling = 98, image = 'https://docs.fivem.net/vehicles/senna.webp' },
    ['cgt'] = { label = 'Porsche Carrera GT V10', brand = 'Porsche', category = 'super', basePrice = 850000, speed = 94, accel = 91, brakes = 89, handling = 91, image = 'https://docs.fivem.net/vehicles/cgt.webp' },
    ['911gt3rs'] = { label = 'Porsche 911 GT3 RS', brand = 'Porsche', category = 'super', basePrice = 235000, speed = 95, accel = 94, brakes = 94, handling = 96, image = 'https://docs.fivem.net/vehicles/911gt3rs.webp' },
    ['r820'] = { label = 'Audi R8 V10 Performance 2020', brand = 'Audi', category = 'sports', basePrice = 195000, speed = 94, accel = 95, brakes = 90, handling = 91, image = 'https://docs.fivem.net/vehicles/r820.webp' },
    ['r8ppi'] = { label = 'Audi R8 V10 Razor GTR', brand = 'Audi', category = 'sports', basePrice = 165000, speed = 92, accel = 93, brakes = 88, handling = 89, image = 'https://docs.fivem.net/vehicles/r8ppi.webp' },
    ['ttrs'] = { label = 'Audi TT RS Quattro', brand = 'Audi', category = 'sports', basePrice = 78000, speed = 87, accel = 89, brakes = 84, handling = 87, image = 'https://docs.fivem.net/vehicles/ttrs.webp' },
    ['rs72020'] = { label = 'Audi RS7 Sportback 2020', brand = 'Audi', category = 'sports', basePrice = 142000, speed = 92, accel = 93, brakes = 88, handling = 88, image = 'https://docs.fivem.net/vehicles/rs72020.webp' },
    ['m2'] = { label = 'BMW M2 Competition', brand = 'BMW', category = 'sports', basePrice = 72000, speed = 87, accel = 89, brakes = 85, handling = 89, image = 'https://docs.fivem.net/vehicles/m2.webp' },
    ['m3e36'] = { label = 'BMW M3 E36 3.2', brand = 'BMW', category = 'sports', basePrice = 42000, speed = 82, accel = 81, brakes = 78, handling = 85, image = 'https://docs.fivem.net/vehicles/m3e36.webp' },
    ['m3e92'] = { label = 'BMW M3 E92 V8', brand = 'BMW', category = 'sports', basePrice = 58000, speed = 86, accel = 85, brakes = 83, handling = 87, image = 'https://docs.fivem.net/vehicles/m3e92.webp' },
    ['m3f80'] = { label = 'BMW M3 F80 TwinTurbo', brand = 'BMW', category = 'sports', basePrice = 82000, speed = 89, accel = 90, brakes = 86, handling = 88, image = 'https://docs.fivem.net/vehicles/m3f80.webp' },
    ['m4f82'] = { label = 'BMW M4 F82 Coupe', brand = 'BMW', category = 'sports', basePrice = 89000, speed = 90, accel = 91, brakes = 87, handling = 89, image = 'https://docs.fivem.net/vehicles/m4f82.webp' },
    ['m6f13'] = { label = 'BMW M6 Gran Coupe', brand = 'BMW', category = 'sports', basePrice = 98000, speed = 91, accel = 90, brakes = 86, handling = 86, image = 'https://docs.fivem.net/vehicles/m6f13.webp' },
    ['bmci'] = { label = 'BMW M8 Competition', brand = 'BMW', category = 'sports', basePrice = 168000, speed = 93, accel = 94, brakes = 89, handling = 90, image = 'https://docs.fivem.net/vehicles/bmci.webp' },
    ['i8'] = { label = 'BMW i8 Roadster Hybrid', brand = 'BMW', category = 'sports', basePrice = 115000, speed = 88, accel = 90, brakes = 86, handling = 89, image = 'https://docs.fivem.net/vehicles/i8.webp' },
    ['z419'] = { label = 'BMW Z4 M40i Roadster', brand = 'BMW', category = 'sports', basePrice = 68000, speed = 85, accel = 86, brakes = 83, handling = 86, image = 'https://docs.fivem.net/vehicles/z419.webp' },
    ['c6320'] = { label = 'Mercedes-AMG C63s Coupe 2020', brand = 'Mercedes-Benz', category = 'sports', basePrice = 98000, speed = 90, accel = 91, brakes = 87, handling = 88, image = 'https://docs.fivem.net/vehicles/c6320.webp' },
    ['mbc63'] = { label = 'Mercedes-AMG C63 Black Series', brand = 'Mercedes-Benz', category = 'sports', basePrice = 120000, speed = 91, accel = 92, brakes = 88, handling = 89, image = 'https://docs.fivem.net/vehicles/mbc63.webp' },
    ['amggtrr20'] = { label = 'Mercedes-AMG GT R Pro', brand = 'Mercedes-Benz', category = 'sports', basePrice = 215000, speed = 94, accel = 94, brakes = 92, handling = 93, image = 'https://docs.fivem.net/vehicles/amggtrr20.webp' },
    ['sl500'] = { label = 'Mercedes-Benz SL 500 V8', brand = 'Mercedes-Benz', category = 'sports', basePrice = 74000, speed = 85, accel = 84, brakes = 82, handling = 84, image = 'https://docs.fivem.net/vehicles/sl500.webp' },
    ['718caymans'] = { label = 'Porsche 718 Cayman S', brand = 'Porsche', category = 'sports', basePrice = 79000, speed = 88, accel = 90, brakes = 88, handling = 91, image = 'https://docs.fivem.net/vehicles/718caymans.webp' },
    ['taycan'] = { label = 'Porsche Taycan Turbo S', brand = 'Porsche', category = 'sports', basePrice = 185000, speed = 93, accel = 97, brakes = 91, handling = 92, image = 'https://docs.fivem.net/vehicles/taycan.webp' },
    ['ast'] = { label = 'Aston Martin Vanquish V12', brand = 'Aston Martin', category = 'sports', basePrice = 210000, speed = 92, accel = 91, brakes = 88, handling = 89, image = 'https://docs.fivem.net/vehicles/ast.webp' },
    ['cgts'] = { label = 'Bentley Continental GT V8', brand = 'Bentley', category = 'sports', basePrice = 225000, speed = 91, accel = 90, brakes = 87, handling = 86, image = 'https://docs.fivem.net/vehicles/cgts.webp' },
    ['cats'] = { label = 'Cadillac ATS-V Coupe TwinTurbo', brand = 'Cadillac', category = 'sports', basePrice = 68000, speed = 87, accel = 88, brakes = 85, handling = 86, image = 'https://docs.fivem.net/vehicles/cats.webp' },
    ['c7'] = { label = 'Chevrolet Corvette C7 Stingray', brand = 'Chevrolet', category = 'sports', basePrice = 78000, speed = 90, accel = 91, brakes = 87, handling = 88, image = 'https://docs.fivem.net/vehicles/c7.webp' },
    ['czr1'] = { label = 'Chevrolet Corvette C6 ZR1', brand = 'Chevrolet', category = 'sports', basePrice = 92000, speed = 92, accel = 92, brakes = 88, handling = 87, image = 'https://docs.fivem.net/vehicles/czr1.webp' },
    ['rs6'] = { label = 'Audi RS6 Avant C7 V8', brand = 'Audi', category = 'sedans', basePrice = 138000, speed = 92, accel = 93, brakes = 89, handling = 89, image = 'https://docs.fivem.net/vehicles/rs6.webp' },
    ['aaq4'] = { label = 'Audi A4 Quattro S-Line', brand = 'Audi', category = 'sedans', basePrice = 44000, speed = 80, accel = 79, brakes = 78, handling = 82, image = 'https://docs.fivem.net/vehicles/aaq4.webp' },
    ['80B4'] = { label = 'Audi RS2 Avant B4 Turbo', brand = 'Audi', category = 'sedans', basePrice = 48000, speed = 81, accel = 82, brakes = 79, handling = 84, image = 'https://docs.fivem.net/vehicles/80B4.webp' },
    ['s8d2'] = { label = 'Audi S8 Quattro V8', brand = 'Audi', category = 'sedans', basePrice = 54000, speed = 83, accel = 81, brakes = 80, handling = 82, image = 'https://docs.fivem.net/vehicles/s8d2.webp' },
    ['760li04'] = { label = 'BMW 760Li V12 E66', brand = 'BMW', category = 'sedans', basePrice = 62000, speed = 84, accel = 82, brakes = 80, handling = 80, image = 'https://docs.fivem.net/vehicles/760li04.webp' },
    ['e34'] = { label = 'BMW M5 E34 Classic', brand = 'BMW', category = 'sedans', basePrice = 38000, speed = 80, accel = 79, brakes = 76, handling = 83, image = 'https://docs.fivem.net/vehicles/e34.webp' },
    ['e400'] = { label = 'Mercedes-Benz E 400 Sedan', brand = 'Mercedes-Benz', category = 'sedans', basePrice = 59000, speed = 83, accel = 81, brakes = 80, handling = 82, image = 'https://docs.fivem.net/vehicles/e400.webp' },
    ['s500w222'] = { label = 'Mercedes-Benz S 500 W222', brand = 'Mercedes-Benz', category = 'sedans', basePrice = 112000, speed = 86, accel = 85, brakes = 84, handling = 83, image = 'https://docs.fivem.net/vehicles/s500w222.webp' },
    ['tltypes'] = { label = 'Acura TL Type-S 3.5 V6', brand = 'Acura', category = 'sedans', basePrice = 32000, speed = 78, accel = 77, brakes = 76, handling = 80, image = 'https://docs.fivem.net/vehicles/tltypes.webp' },
    ['passat'] = { label = 'Volkswagen Passat R-Line', brand = 'Volkswagen', category = 'sedans', basePrice = 36000, speed = 76, accel = 75, brakes = 75, handling = 79, image = 'https://docs.fivem.net/vehicles/passat.webp' },
    ['v250'] = { label = 'Mercedes-Benz V-Class 250d', brand = 'Mercedes-Benz', category = 'sedans', basePrice = 64000, speed = 72, accel = 70, brakes = 74, handling = 75, image = 'https://docs.fivem.net/vehicles/v250.webp' },
    ['pm19'] = { label = 'Porsche Panamera Turbo 2019', brand = 'Porsche', category = 'sedans', basePrice = 155000, speed = 91, accel = 92, brakes = 89, handling = 88, image = 'https://docs.fivem.net/vehicles/pm19.webp' },
    ['q820'] = { label = 'Audi Q8 50 TDI Quattro', brand = 'Audi', category = 'suvs', basePrice = 89000, speed = 83, accel = 81, brakes = 82, handling = 82, image = 'https://docs.fivem.net/vehicles/q820.webp' },
    ['sq72016'] = { label = 'Audi SQ7 4.0 TDI V8', brand = 'Audi', category = 'suvs', basePrice = 98000, speed = 85, accel = 86, brakes = 84, handling = 83, image = 'https://docs.fivem.net/vehicles/sq72016.webp' },
    ['x5e53'] = { label = 'BMW X5 4.8is V8', brand = 'BMW', category = 'suvs', basePrice = 46000, speed = 79, accel = 80, brakes = 78, handling = 79, image = 'https://docs.fivem.net/vehicles/x5e53.webp' },
    ['x6m'] = { label = 'BMW X6M V8 TwinTurbo', brand = 'BMW', category = 'suvs', basePrice = 135000, speed = 89, accel = 91, brakes = 86, handling = 85, image = 'https://docs.fivem.net/vehicles/x6m.webp' },
    ['G65'] = { label = 'Mercedes-AMG G65 V12 Biturbo', brand = 'Mercedes-Benz', category = 'suvs', basePrice = 195000, speed = 85, accel = 88, brakes = 82, handling = 79, image = 'https://docs.fivem.net/vehicles/G65.webp' },
    ['gl63'] = { label = 'Mercedes-AMG GL 63 4MATIC', brand = 'Mercedes-Benz', category = 'suvs', basePrice = 110000, speed = 84, accel = 86, brakes = 83, handling = 80, image = 'https://docs.fivem.net/vehicles/gl63.webp' },
    ['urus'] = { label = 'Lamborghini Urus 4.0 V8 Biturbo', brand = 'Lamborghini', category = 'suvs', basePrice = 260000, speed = 92, accel = 94, brakes = 90, handling = 88, image = 'https://docs.fivem.net/vehicles/urus.webp' },
    ['bbentayga'] = { label = 'Bentley Bentayga W12 Luxury', brand = 'Bentley', category = 'suvs', basePrice = 245000, speed = 89, accel = 90, brakes = 86, handling = 84, image = 'https://docs.fivem.net/vehicles/bbentayga.webp' },
    ['amdbx'] = { label = 'Aston Martin DBX Carbon Edition', brand = 'Aston Martin', category = 'suvs', basePrice = 215000, speed = 88, accel = 90, brakes = 87, handling = 86, image = 'https://docs.fivem.net/vehicles/amdbx.webp' },
    ['cesc21'] = { label = 'Cadillac Escalade Platinum 2021', brand = 'Cadillac', category = 'suvs', basePrice = 125000, speed = 80, accel = 79, brakes = 78, handling = 76, image = 'https://docs.fivem.net/vehicles/cesc21.webp' },
    ['09tahoe'] = { label = 'Chevrolet Tahoe LTZ 2009', brand = 'Chevrolet', category = 'suvs', basePrice = 34000, speed = 74, accel = 72, brakes = 72, handling = 74, image = 'https://docs.fivem.net/vehicles/09tahoe.webp' },
    ['15tahoe'] = { label = 'Chevrolet Tahoe Premier 2015', brand = 'Chevrolet', category = 'suvs', basePrice = 48000, speed = 76, accel = 75, brakes = 75, handling = 76, image = 'https://docs.fivem.net/vehicles/15tahoe.webp' },
    ['tahoe21'] = { label = 'Chevrolet Tahoe RST V8 2021', brand = 'Chevrolet', category = 'suvs', basePrice = 76000, speed = 79, accel = 80, brakes = 78, handling = 78, image = 'https://docs.fivem.net/vehicles/tahoe21.webp' },
    ['raptor2017'] = { label = 'Ford F-150 Raptor Offroad', brand = 'Ford', category = 'suvs', basePrice = 82000, speed = 81, accel = 84, brakes = 79, handling = 82, image = 'https://docs.fivem.net/vehicles/raptor2017.webp' },
    ['f150'] = { label = 'Ford F-150 Lariat 4x4', brand = 'Ford', category = 'suvs', basePrice = 56000, speed = 76, accel = 76, brakes = 75, handling = 76, image = 'https://docs.fivem.net/vehicles/f150.webp' },
    ['amarok'] = { label = 'Volkswagen Amarok V6 4Motion', brand = 'Volkswagen', category = 'suvs', basePrice = 47000, speed = 75, accel = 76, brakes = 76, handling = 78, image = 'https://docs.fivem.net/vehicles/amarok.webp' },
    ['16challenger'] = { label = 'Dodge Challenger SRT 392', brand = 'Dodge', category = 'muscle', basePrice = 62000, speed = 87, accel = 88, brakes = 82, handling = 81, image = 'https://docs.fivem.net/vehicles/16challenger.webp' },
    ['demon'] = { label = 'Dodge Challenger SRT Demon', brand = 'Dodge', category = 'muscle', basePrice = 115000, speed = 94, accel = 98, brakes = 86, handling = 80, image = 'https://docs.fivem.net/vehicles/demon.webp' },
    ['16charger'] = { label = 'Dodge Charger R/T Hemi', brand = 'Dodge', category = 'muscle', basePrice = 54000, speed = 85, accel = 86, brakes = 81, handling = 82, image = 'https://docs.fivem.net/vehicles/16charger.webp' },
    ['chr20'] = { label = 'Dodge Charger Hellcat Widebody', brand = 'Dodge', category = 'muscle', basePrice = 92000, speed = 91, accel = 93, brakes = 86, handling = 83, image = 'https://docs.fivem.net/vehicles/chr20.webp' },
    ['99viper'] = { label = 'Dodge Viper GTS V10 ACR', brand = 'Dodge', category = 'muscle', basePrice = 125000, speed = 92, accel = 91, brakes = 84, handling = 83, image = 'https://docs.fivem.net/vehicles/99viper.webp' },
    ['trx'] = { label = 'RAM 1500 TRX 6.2 Supercharged', brand = 'Dodge', category = 'muscle', basePrice = 110000, speed = 86, accel = 90, brakes = 80, handling = 80, image = 'https://docs.fivem.net/vehicles/trx.webp' },
    ['ram2500'] = { label = 'Dodge RAM 2500 Heavy Duty', brand = 'Dodge', category = 'muscle', basePrice = 52000, speed = 72, accel = 74, brakes = 72, handling = 73, image = 'https://docs.fivem.net/vehicles/ram2500.webp' },
    ['camrs17'] = { label = 'Chevrolet Camaro RS 2017', brand = 'Chevrolet', category = 'muscle', basePrice = 49000, speed = 84, accel = 85, brakes = 82, handling = 83, image = 'https://docs.fivem.net/vehicles/camrs17.webp' },
    ['2020ss'] = { label = 'Chevrolet Camaro SS 6.2 V8', brand = 'Chevrolet', category = 'muscle', basePrice = 68000, speed = 88, accel = 89, brakes = 85, handling = 85, image = 'https://docs.fivem.net/vehicles/2020ss.webp' },
    ['corvettec5z06'] = { label = 'Chevrolet Corvette C5 Z06', brand = 'Chevrolet', category = 'muscle', basePrice = 39000, speed = 86, accel = 86, brakes = 82, handling = 85, image = 'https://docs.fivem.net/vehicles/corvettec5z06.webp' },
    ['mustang50th'] = { label = 'Ford Mustang 50th Edition V8', brand = 'Ford', category = 'muscle', basePrice = 58000, speed = 86, accel = 87, brakes = 83, handling = 84, image = 'https://docs.fivem.net/vehicles/mustang50th.webp' },
    ['mustang2005gt'] = { label = 'Ford Mustang GT 2005', brand = 'Ford', category = 'muscle', basePrice = 29000, speed = 81, accel = 82, brakes = 78, handling = 80, image = 'https://docs.fivem.net/vehicles/mustang2005gt.webp' },
    ['fgt'] = { label = 'Ford GT Supercharged 2005', brand = 'Ford', category = 'muscle', basePrice = 360000, speed = 94, accel = 92, brakes = 88, handling = 89, image = 'https://docs.fivem.net/vehicles/fgt.webp' },
    ['gt17'] = { label = 'Ford GT TwinTurbo 2017', brand = 'Ford', category = 'muscle', basePrice = 550000, speed = 96, accel = 95, brakes = 92, handling = 93, image = 'https://docs.fivem.net/vehicles/gt17.webp' },
    ['gtr'] = { label = 'Nissan GT-R R35 Black Edition', brand = 'Nissan', category = 'sports', basePrice = 125000, speed = 94, accel = 96, brakes = 90, handling = 92, image = 'https://docs.fivem.net/vehicles/gtr.webp' },
    ['gtrc'] = { label = 'Nissan GT-R Nismo Carbon', brand = 'Nissan', category = 'sports', basePrice = 165000, speed = 95, accel = 97, brakes = 92, handling = 94, image = 'https://docs.fivem.net/vehicles/gtrc.webp' },
    ['skyline'] = { label = 'Nissan Skyline GT-R R34 V-Spec', brand = 'Nissan', category = 'sports', basePrice = 95000, speed = 88, accel = 89, brakes = 84, handling = 90, image = 'https://docs.fivem.net/vehicles/skyline.webp' },
    ['nis15'] = { label = 'Nissan Silvia S15 Spec-R Turbo', brand = 'Nissan', category = 'sports', basePrice = 46000, speed = 84, accel = 85, brakes = 81, handling = 92, image = 'https://docs.fivem.net/vehicles/nis15.webp' },
    ['180sx'] = { label = 'Nissan 180SX Type X SR20DET', brand = 'Nissan', category = 'sports', basePrice = 34000, speed = 81, accel = 82, brakes = 78, handling = 91, image = 'https://docs.fivem.net/vehicles/180sx.webp' },
    ['ns350'] = { label = 'Nissan 350Z Fairlady Z33', brand = 'Nissan', category = 'sports', basePrice = 28000, speed = 83, accel = 83, brakes = 80, handling = 87, image = 'https://docs.fivem.net/vehicles/ns350.webp' },
    ['z32'] = { label = 'Nissan 300ZX Twin Turbo Z32', brand = 'Nissan', category = 'sports', basePrice = 36000, speed = 82, accel = 82, brakes = 79, handling = 84, image = 'https://docs.fivem.net/vehicles/z32.webp' },
    ['Safari97'] = { label = 'Nissan Patrol GR Safari 4x4', brand = 'Nissan', category = 'suvs', basePrice = 27000, speed = 70, accel = 71, brakes = 70, handling = 75, image = 'https://docs.fivem.net/vehicles/Safari97.webp' },
    ['toysupmk4'] = { label = 'Toyota Supra MK4 Turbo 2JZ-GTE', brand = 'Toyota', category = 'sports', basePrice = 88000, speed = 89, accel = 90, brakes = 84, handling = 89, image = 'https://docs.fivem.net/vehicles/toysupmk4.webp' },
    ['ae86'] = { label = 'Toyota Sprinter Trueno AE86', brand = 'Toyota', category = 'compacts', basePrice = 26000, speed = 74, accel = 75, brakes = 75, handling = 92, image = 'https://docs.fivem.net/vehicles/ae86.webp' },
    ['mk2100'] = { label = 'Toyota Mark II Tourer V 1JZ', brand = 'Toyota', category = 'sedans', basePrice = 32000, speed = 82, accel = 83, brakes = 78, handling = 88, image = 'https://docs.fivem.net/vehicles/mk2100.webp' },
    ['vxr'] = { label = 'Toyota Land Cruiser V8 VXR', brand = 'Toyota', category = 'suvs', basePrice = 72000, speed = 76, accel = 75, brakes = 76, handling = 77, image = 'https://docs.fivem.net/vehicles/vxr.webp' },
    ['golfgti7'] = { label = 'Volkswagen Golf VII GTI Performance', brand = 'Volkswagen', category = 'compacts', basePrice = 33000, speed = 82, accel = 83, brakes = 81, handling = 86, image = 'https://docs.fivem.net/vehicles/golfgti7.webp' },
    ['golf8gti'] = { label = 'Volkswagen Golf VIII GTI 2.0 TSI', brand = 'Volkswagen', category = 'compacts', basePrice = 42000, speed = 84, accel = 85, brakes = 83, handling = 87, image = 'https://docs.fivem.net/vehicles/golf8gti.webp' },
    ['vwr'] = { label = 'Volkswagen Golf VII R 4Motion', brand = 'Volkswagen', category = 'compacts', basePrice = 48000, speed = 86, accel = 89, brakes = 85, handling = 88, image = 'https://docs.fivem.net/vehicles/vwr.webp' },
    ['audquattros'] = { label = 'Audi Sport Quattro Classic', brand = 'Audi', category = 'sports', basePrice = 85000, speed = 84, accel = 85, brakes = 82, handling = 89, image = 'https://docs.fivem.net/vehicles/audquattros.webp' },
    ['f15078'] = { label = 'Ford F-150 Ranger Classic 1978', brand = 'Ford', category = 'suvs', basePrice = 18500, speed = 68, accel = 67, brakes = 65, handling = 70, image = 'https://docs.fivem.net/vehicles/f15078.webp' },
    ['cam8tun'] = { label = 'Toyota Camry XSE V6 Sport', brand = 'Toyota', category = 'sedans', basePrice = 35000, speed = 78, accel = 77, brakes = 76, handling = 80, image = 'https://docs.fivem.net/vehicles/cam8tun.webp' },
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
