Config = {}

-- Moneda y Nombres
Config.CurrencySymbol = '€'
Config.ChipsItem = 'casinochips'
Config.VipItem = 'casinovip'
Config.VipPrice = 50000
Config.ChipRate = 1 -- 1 € = 1 Ficha

-- Acceso y Teletransporte al Casino
Config.CasinoDoors = {
    Outside = {
        coords = vector4(929.84, 46.51, 81.11, 59.0),
        prompt = '[E] Entrar al Diamond Casino & Resort',
        drawDistance = 5.0
    },
    Inside = {
        coords = vector4(1089.62, 206.60, -48.99, 338.0),
        prompt = '[E] Salir al Exterior',
        drawDistance = 5.0
    }
}

-- Blip en el Mapa
Config.Blip = {
    coords = vector3(929.84, 46.51, 81.11),
    sprite = 679,
    color = 60, -- Oro / Amarillo Diamond
    scale = 0.85,
    name = 'The Diamond Casino & Resort'
}

-- Cajero (NPC de Fichas & Membresía VIP)
Config.Cashier = {
    coords = vector4(1116.07, 219.89, -49.44, 98.0),
    model = 'u_f_m_casinocash_01',
    prompt = '[E] Cajero: Comprar/Canjear Fichas & Pase VIP',
    distance = 2.5
}

-- Ruleta de la Suerte Diaria (24 Horas) & Podio
Config.LuckyWheel = {
    coords = vector3(1111.05, 229.81, -49.13),
    propModel = 'vw_prop_vw_luckywheel_02a',
    prompt = '[E] Girar Ruleta Diaria (Gratis cada 24h)',
    cooldown = 86400, -- 24 horas en segundos
    defaultPodiumVehicle = 'blista',
    defaultGarage = 'motelgarage',
    podiumCoords = vector4(1100.0, 220.0, -49.65, 310.0),
    podiumRotate = true,
    
    -- 16 Slices de la Ruleta Diaria con probabilidades ponderadas
    prizes = {
        [1] = { type = 'vehicle', label = 'Coche del Podio', icon = 'car', weight = 5, color = '#ffd700' },
        [2] = { type = 'chips', amount = 50000, label = '50.000 Fichas', icon = 'coins', weight = 10, color = '#00e5ff' },
        [3] = { type = 'cash', amount = 25000, label = '25.000 € Efectivo', icon = 'money-bill', weight = 12, color = '#00e676' },
        [4] = { type = 'chips', amount = 10000, label = '10.000 Fichas', icon = 'coins', weight = 18, color = '#2979ff' },
        [5] = { type = 'cash', amount = 15000, label = '15.000 € Efectivo', icon = 'money-bill', weight = 15, color = '#69f0ae' },
        [6] = { type = 'vip', label = 'Pase VIP Diamond', icon = 'crown', weight = 6, color = '#e040fb' },
        [7] = { type = 'chips', amount = 5000, label = '5.000 Fichas', icon = 'coins', weight = 22, color = '#40c4ff' },
        [8] = { type = 'cash', amount = 10000, label = '10.000 € Efectivo', icon = 'money-bill', weight = 20, color = '#b9f6ca' },
        [9] = { type = 'chips', amount = 2500, label = '2.500 Fichas', icon = 'coins', weight = 25, color = '#80d8ff' },
        [10] = { type = 'cash', amount = 5000, label = '5.000 € Efectivo', icon = 'money-bill', weight = 25, color = '#76ff03' },
        [11] = { type = 'chips', amount = 20000, label = '20.000 Fichas', icon = 'coins', weight = 12, color = '#00b0ff' },
        [12] = { type = 'cash', amount = 2500, label = '2.500 € Efectivo', icon = 'money-bill', weight = 28, color = '#ccff90' },
        [13] = { type = 'chips', amount = 1000, label = '1.000 Fichas', icon = 'coins', weight = 35, color = '#82b1ff' },
        [14] = { type = 'cash', amount = 1000, label = '1.000 € Efectivo', icon = 'money-bill', weight = 35, color = '#f4ff81' },
        [15] = { type = 'chips', amount = 35000, label = '35.000 Fichas', icon = 'coins', weight = 8, color = '#64ffda' },
        [16] = { type = 'cash', amount = 7500, label = '7.500 € Efectivo', icon = 'money-bill', weight = 20, color = '#a7ffeb' }
    }
}

-- Mesas de Ruleta de Apuestas (Francesa / Americana)
Config.Roulette = {
    Normal = {
        name = 'Ruleta Clásica',
        coords = vector3(1133.5, 261.2, -51.03),
        prompt = '[E] Jugar a la Ruleta Clásica (Máx 10.000 €)',
        maxBet = 10000,
        requiresVIP = false,
        chips = { 100, 250, 500, 1000, 2500, 5000, 10000 },
        distance = 2.0
    },
    Premium = {
        name = 'Ruleta Premium VIP',
        coords = vector3(1147.0, 263.0, -51.84),
        prompt = '[E] Jugar a la Ruleta Premium VIP (Máx 100.000 €)',
        maxBet = 100000,
        requiresVIP = true,
        chips = { 1000, 2500, 5000, 10000, 25000, 50000, 100000 },
        distance = 2.0
    }
}

-- Máquinas Tragaperras / Jackpot Diamond
Config.Slots = {
    coords = vector3(1103.0, 230.5, -49.84),
    prompt = '[E] Jugar a las Tragaperras Diamond / Jackpot',
    distance = 2.5,
    normalMaxBet = 2500,
    vipMaxBet = 25000,
    bets = { 100, 250, 500, 1000, 2500, 5000, 10000, 25000 },
    initialJackpot = 150000,
    jackpotCutPercent = 0.05, -- 5% de cada tirada se acumula al bote del jackpot

    symbols = {
        { id = 1, name = 'cherry', label = 'Cerezas', icon = '🍒', mult3 = 5, mult2 = 2, weight = 35 },
        { id = 2, name = 'lemon', label = 'Limón', icon = '🍋', mult3 = 10, mult2 = 0, weight = 28 },
        { id = 3, name = 'bell', label = 'Campana', icon = '🔔', mult3 = 15, mult2 = 0, weight = 22 },
        { id = 4, name = 'grape', label = 'Uvas', icon = '🍇', mult3 = 25, mult2 = 0, weight = 16 },
        { id = 5, name = 'diamond', label = 'Diamante', icon = '💎', mult3 = 50, mult2 = 0, weight = 10 },
        { id = 6, name = 'seven', label = 'Siete de Oro', icon = '7️⃣', mult3 = 75, mult2 = 0, weight = 6 },
        { id = 7, name = 'jackpot', label = 'JACKPOT DIAMOND', icon = '⭐', mult3 = 150, mult2 = 0, isJackpot = true, weight = 3 }
    }
}
