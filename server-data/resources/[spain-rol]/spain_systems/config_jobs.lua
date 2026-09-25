-- =========================================================================
-- SPAIN ROL - CONFIGURACIÓN DEL MOTOR DINÁMICO DE EMPLEOS
-- =========================================================================
-- Define sedes físicas, NPCs capataces, vehículos de trabajo, tareas continuas
-- minijuegos de habilidad y bonificaciones de horas extras en dinero negro.

JobsConfig = {}

-- Configuración del Sistema de Horas Extras en Dinero Negro
JobsConfig.Overtime = {
    enabled = true,
    tasksInterval = 2,           -- Cada cuántas tareas completadas se entrega dinero en negro
    timeInterval = 180,          -- Cada cuántos segundos (3 minutos) de servicio continuado se genera bonus
    minBlackCash = 450,          -- Dinero negro mínimo por sobre de horas extras
    maxBlackCash = 1200,         -- Dinero negro máximo por sobre de horas extras
    blackMoneyItem = 'dirty_cash', -- Ítem entregado (compatible con spain_laundry)
    notifyMessage = "El encargado te ha deslizado un sobre con €%s de dinero negro por las horas extras. (¡No declares nada a Hacienda!)"
}

-- Sedes Laborales y Estaciones de Trabajo
JobsConfig.Stations = {
    -- 1. MINERO DE CANTERA DAVIS QUARTZ
    ['miner'] = {
        job = 'miner',
        name = "Cantera Davis Quartz - Extracción y Fundición",
        blip = { sprite = 365, color = 5, scale = 0.8, title = "⛏️ Sede: Cantera Davis Quartz (Minero)" },
        boss = {
            coords = vector4(2953.52, 2787.64, 41.5, 115.0),
            model = `s_m_y_construct_01`,
            scenario = 'WORLD_HUMAN_CLIPBOARD',
            label = "Capataz de Cantera Davis"
        },
        vehicle = {
            model = 'tiptruck',
            spawn = vector4(2945.12, 2795.84, 40.8, 205.0)
        },
        tasks = {
            { coords = vector3(2971.2, 2755.8, 38.6), label = "Veta de Hierro y Mineral", animDict = "melee@large_wpn@streamed_core", animClip = "ground_attack_on_spot", duration = 6000 },
            { coords = vector3(2936.5, 2742.1, 43.2), label = "Filón de Cobre y Plata", animDict = "melee@large_wpn@streamed_core", animClip = "ground_attack_on_spot", duration = 6000 },
            { coords = vector3(2985.4, 2792.0, 42.1), label = "Roca con Incrustación de Diamantes", animDict = "melee@large_wpn@streamed_core", animClip = "ground_attack_on_spot", duration = 6000 },
            { coords = vector3(2954.8, 2831.2, 43.5), label = "Punto de Lavado y Criba", animDict = "amb@world_human_gardener_plant@male@base", animClip = "base", duration = 5000 },
            { coords = vector3(2912.4, 2772.3, 44.8), label = "Tolva de Fundición Pesada", animDict = "amb@world_human_welding@male@base", animClip = "base", duration = 6000 }
        },
        minigame = 'easy',
        pay = { min = 120, max = 240 }
    },

    -- 2. LEÑADOR FORESTAL DE PALETO
    ['lumberjack'] = {
        job = 'lumberjack',
        name = "Aserradero y Explotación Forestal Paleto",
        blip = { sprite = 77, color = 25, scale = 0.8, title = "🪓 Sede: Aserradero Forestal (Leñador)" },
        boss = {
            coords = vector4(-552.82, 5348.65, 74.74, 70.0),
            model = `s_m_y_dockwork_01`,
            scenario = 'WORLD_HUMAN_STAND_MOBILE',
            label = "Encargado Forestal de Paleto"
        },
        vehicle = {
            model = 'bison',
            spawn = vector4(-545.2, 5355.8, 74.2, 160.0)
        },
        tasks = {
            { coords = vector3(-585.2, 5334.8, 70.2), label = "Pino Centenario Caído", animDict = "melee@hatchet@streamed_core", animClip = "plyr_front_takedown_b", duration = 6000 },
            { coords = vector3(-615.4, 5302.1, 74.0), label = "Corte de Tronco Robusto", animDict = "melee@hatchet@streamed_core", animClip = "plyr_front_takedown_b", duration = 6000 },
            { coords = vector3(-520.1, 5410.2, 65.4), label = "Poda y Apilado de Ramas", animDict = "amb@world_human_gardener_plant@male@base", animClip = "base", duration = 5000 },
            { coords = vector3(-570.6, 5285.4, 70.5), label = "Sierra Eléctrica de Bancada", animDict = "amb@world_human_welding@male@base", animClip = "base", duration = 6000 }
        },
        minigame = 'easy',
        pay = { min = 120, max = 230 }
    },

    -- 3. REPARTIDOR DE PAQUETERÍA GO POSTAL
    ['delivery'] = {
        job = 'delivery',
        name = "Central Logística Go Postal",
        blip = { sprite = 67, color = 17, scale = 0.8, title = "📦 Sede: Paquetería Go Postal (Repartidor)" },
        boss = {
            coords = vector4(68.9, -1569.8, 29.5, 50.0),
            model = `s_m_m_postal_01`,
            scenario = 'WORLD_HUMAN_CLIPBOARD',
            label = "Jefe de Reparto Go Postal"
        },
        vehicle = {
            model = 'boxville',
            spawn = vector4(63.2, -1578.4, 29.3, 140.0)
        },
        tasks = {
            { coords = vector3(112.5, -1300.2, 29.2), label = "Entrega en Portal Residencial Strawberry", animDict = "anim@heists@box_carry@", animClip = "idle", duration = 4000 },
            { coords = vector3(-228.4, -915.2, 32.3), label = "Paquete Certificado en Edificio Alta", animDict = "mp_common", animClip = "givetake2_a", duration = 4500 },
            { coords = vector3(-630.2, -236.4, 38.0), label = "Entrega Exprés en Joyería Rockford", animDict = "mp_common", animClip = "givetake2_a", duration = 4500 },
            { coords = vector3(321.4, 180.2, 103.5), label = "Caja Urgente en Estudio Vinewood", animDict = "anim@heists@box_carry@", animClip = "idle", duration = 4500 },
            { coords = vector3(-1380.5, -500.1, 33.1), label = "Envío Prioritario en Mansión Del Perro", animDict = "mp_common", animClip = "givetake2_a", duration = 4500 },
            { coords = vector3(1142.1, -440.5, 66.8), label = "Correspondencia en Barrio Mirror Park", animDict = "mp_common", animClip = "givetake2_a", duration = 4500 },
            { coords = vector3(-1080.2, -1260.4, 5.5), label = "Entrega en Paseo Canales Vespucci", animDict = "anim@heists@box_carry@", animClip = "idle", duration = 4500 },
            { coords = vector3(890.3, -2105.1, 30.5), label = "Envío Industrial en Docks del Puerto", animDict = "mp_common", animClip = "givetake2_a", duration = 4500 }
        },
        minigame = 'easy',
        pay = { min = 110, max = 220 }
    },

    -- 4. REPARTIDOR DE PIZZA THIS
    ['pizza'] = {
        job = 'pizza',
        name = "Pizzería Artesanal Pizza This",
        blip = { sprite = 267, color = 1, scale = 0.8, title = "🍕 Sede: Pizza This (Repartidor)" },
        boss = {
            coords = vector4(-565.4, 274.6, 83.0, 175.0),
            model = `s_m_y_chef_01`,
            scenario = 'WORLD_HUMAN_STAND_IMPARTIAL',
            label = "Encargado de Hornos Pizza This"
        },
        vehicle = {
            model = 'faggio',
            spawn = vector4(-560.8, 281.2, 82.2, 265.0)
        },
        tasks = {
            { coords = vector3(-680.1, 310.5, 83.2), label = "Pizza Cuatro Quesos en Dorset Dr", animDict = "mp_common", animClip = "givetake2_a", duration = 4000 },
            { coords = vector3(-850.4, 150.2, 65.8), label = "Pedido Familiar en Cougar Ave", animDict = "mp_common", animClip = "givetake2_a", duration = 4000 },
            { coords = vector3(-1100.8, -250.4, 37.8), label = "Pizza Calzone en Vespucci Boulevard", animDict = "mp_common", animClip = "givetake2_a", duration = 4000 },
            { coords = vector3(-1350.2, -750.8, 22.4), label = "Entrega al Paso en Paseo de la Playa", animDict = "mp_common", animClip = "givetake2_a", duration = 4000 },
            { coords = vector3(-340.2, 420.5, 110.2), label = "Cena Especial en Vinewood Hills", animDict = "mp_common", animClip = "givetake2_a", duration = 4000 },
            { coords = vector3(290.4, -620.1, 43.5), label = "Pizza Pepperoni en Pillbox Medical", animDict = "mp_common", animClip = "givetake2_a", duration = 4000 },
            { coords = vector3(-1480.2, -1005.4, 6.2), label = "Pedido Romántico en Muelle Marina", animDict = "mp_common", animClip = "givetake2_a", duration = 4000 }
        },
        minigame = 'easy',
        pay = { min = 95, max = 200 }
    },

    -- 5. PESCADOR PROFESIONAL DE ALTA MAR
    ['fisherman'] = {
        job = 'fisherman',
        name = "Muelle Pesquero y Lonja Del Perro",
        blip = { sprite = 356, color = 3, scale = 0.8, title = "🐟 Sede: Lonja y Muelle Pesquero" },
        boss = {
            coords = vector4(-1816.8, -1193.3, 19.3, 325.0),
            model = `s_m_m_ammucountry`,
            scenario = 'WORLD_HUMAN_STAND_FISHING',
            label = "Patrón Mayor de la Cofradía"
        },
        vehicle = {
            model = 'dinghy',
            spawn = vector4(-1805.2, -1202.5, 1.5, 55.0)
        },
        tasks = {
            { coords = vector3(-1845.2, -1245.8, 1.2), label = "Recogida de Red de Atún Rojo", animDict = "amb@world_human_gardener_plant@male@base", animClip = "base", duration = 6500 },
            { coords = vector3(-2002.5, -1350.1, 0.8), label = "Pesca de Arrastre en Boya Exterior", animDict = "amb@world_human_gardener_plant@male@base", animClip = "base", duration = 6500 },
            { coords = vector3(-2150.8, -1120.4, 1.0), label = "Captura de Marisco en Bajío", animDict = "amb@world_human_gardener_plant@male@base", animClip = "base", duration = 6500 }
        },
        minigame = 'medium',
        pay = { min = 130, max = 260 }
    },

    -- 6. AGRICULTOR DE CAMPO GRAPESEED
    ['farmer'] = {
        job = 'farmer',
        name = "Cooperativa Agrícola Grapeseed",
        blip = { sprite = 469, color = 2, scale = 0.8, title = "🌾 Sede: Cooperativa Agrícola Grapeseed" },
        boss = {
            coords = vector4(2447.8, 4976.2, 46.8, 130.0),
            model = `a_m_m_farmer_01`,
            scenario = 'WORLD_HUMAN_HANG_OUT_STREET',
            label = "Capataz Agrónomo de Finca"
        },
        vehicle = {
            model = 'rebel',
            spawn = vector4(2455.1, 4965.8, 45.9, 220.0)
        },
        tasks = {
            { coords = vector3(2490.2, 4945.1, 44.5), label = "Cosecha de Espigas de Maíz", animDict = "amb@world_human_gardener_plant@male@base", animClip = "base", duration = 5500 },
            { coords = vector3(2540.8, 4910.4, 44.2), label = "Recolección de Tomates Maduros", animDict = "amb@world_human_gardener_plant@male@base", animClip = "base", duration = 5500 },
            { coords = vector3(2410.5, 4995.8, 46.2), label = "Carga de Sacos en Silo Central", animDict = "anim@heists@box_carry@", animClip = "idle", duration = 5000 }
        },
        minigame = 'easy',
        pay = { min = 115, max = 225 }
    },

    -- 7. TÉCNICO ELECTRICISTA MUNICIPAL
    ['electrician'] = {
        job = 'electrician',
        name = "Subestación Eléctrica Palmer-Taylor",
        blip = { sprite = 354, color = 5, scale = 0.8, title = "⚡ Sede: Red Eléctrica Municipal" },
        boss = {
            coords = vector4(2732.1, 1573.4, 30.7, 265.0),
            model = `s_m_m_dockwork_01`,
            scenario = 'WORLD_HUMAN_CLIPBOARD',
            label = "Jefe Técnico de Alta Tensión"
        },
        vehicle = {
            model = 'burrito',
            spawn = vector4(2739.4, 1580.2, 30.4, 355.0)
        },
        tasks = {
            { coords = vector3(2680.2, 1610.5, 24.5), label = "Transformador Palmer-Taylor", animDict = "amb@world_human_welding@male@base", animClip = "base", duration = 6500 },
            { coords = vector3(1705.4, 1495.2, 84.1), label = "Caja de Fusibles en Torre Eólica", animDict = "amb@world_human_welding@male@base", animClip = "base", duration = 6500 },
            { coords = vector3(890.1, -120.4, 78.5), label = "Poste de Alta Tensión en Vinewood Racetrack", animDict = "amb@world_human_welding@male@base", animClip = "base", duration = 6500 },
            { coords = vector3(-120.4, -605.2, 35.8), label = "Armario Distribuidor en Downtown LS", animDict = "amb@world_human_welding@male@base", animClip = "base", duration = 6500 },
            { coords = vector3(-1550.2, -410.5, 36.2), label = "Subestación de Barrio Del Perro", animDict = "amb@world_human_welding@male@base", animClip = "base", duration = 6500 },
            { coords = vector3(590.2, -2800.5, 6.1), label = "Nodo Eléctrico Submarino Elysian Island", animDict = "amb@world_human_welding@male@base", animClip = "base", duration = 6500 }
        },
        minigame = 'medium',
        pay = { min = 135, max = 270 }
    },

    -- 8. OPERARIO DE LIMPIEZA URBANA (BASURERO)
    ['garbage'] = {
        job = 'garbage',
        name = "Centro de Gestión de Residuos South LS",
        blip = { sprite = 318, color = 47, scale = 0.8, title = "🗑️ Sede: Gestión de Residuos (Basurero)" },
        boss = {
            coords = vector4(-322.2, -1545.9, 31.0, 260.0),
            model = `s_m_y_garbage`,
            scenario = 'WORLD_HUMAN_CLIPBOARD',
            label = "Supervisor de Recogida Urbana"
        },
        vehicle = {
            model = 'trash',
            spawn = vector4(-333.5, -1538.4, 27.5, 345.0)
        },
        tasks = {
            { coords = vector3(-250.2, -1450.8, 30.2), label = "Contenedor de Basura Orgánica South LS", animDict = "anim@heists@box_carry@", animClip = "idle", duration = 5000 },
            { coords = vector3(-150.4, -1350.1, 29.5), label = "Contenedor Comercial en Carson Ave", animDict = "anim@heists@box_carry@", animClip = "idle", duration = 5000 },
            { coords = vector3(120.5, -1280.4, 28.8), label = "Punto Limpio Callejón Innocence", animDict = "anim@heists@box_carry@", animClip = "idle", duration = 5000 },
            { coords = vector3(415.2, -980.5, 29.4), label = "Recogida de Residuos Legion Square", animDict = "anim@heists@box_carry@", animClip = "idle", duration = 5000 },
            { coords = vector3(-610.4, -940.2, 21.8), label = "Contenedores de Little Seoul Market", animDict = "anim@heists@box_carry@", animClip = "idle", duration = 5000 },
            { coords = vector3(1030.1, -330.4, 67.2), label = "Vaciado de Contenedores en Mirror Park", animDict = "anim@heists@box_carry@", animClip = "idle", duration = 5000 }
        },
        minigame = 'easy',
        pay = { min = 110, max = 220 }
    },

    -- 9. REPARTIDOR TCG MURCIA CARD SHOW (INVENTADO)
    ['cards_courier'] = {
        job = 'cards_courier',
        name = "Almacén Central Murcia Card Show",
        blip = { sprite = 605, color = 46, scale = 0.85, title = "🎴 Sede: Almacén Oficial Murcia Card Show" },
        boss = {
            coords = vector4(78.9, -1390.2, 29.3, 90.0),
            model = `a_m_y_business_02`,
            scenario = 'WORLD_HUMAN_CLIPBOARD',
            label = "Director Logístico Murcia Card Show"
        },
        vehicle = {
            model = 'rumpo3',
            spawn = vector4(85.4, -1398.2, 29.0, 180.0)
        },
        tasks = {
            { coords = vector3(21.5, -1106.0, 29.8), label = "Suministro Oficial Tienda PokéVault (Legion)", animDict = "anim@heists@box_carry@", animClip = "idle", duration = 5500 },
            { coords = vector3(-150.2, -250.4, 43.5), label = "Entrega Blindada: Cajas Selladas PSA 10", animDict = "anim@heists@box_carry@", animClip = "idle", duration = 5500 },
            { coords = vector3(-780.5, 180.2, 72.8), label = "Maletín con Cartas Vintage Primera Edición", animDict = "mp_common", animClip = "givetake2_a", duration = 5500 },
            { coords = vector3(-1450.8, -200.4, 48.2), label = "Custodia de Mystery Boxes para Evento", animDict = "anim@heists@box_carry@", animClip = "idle", duration = 5500 },
            { coords = vector3(120.4, -620.5, 44.2), label = "Coleccionista VIP en Pillbox Hill", animDict = "mp_common", animClip = "givetake2_a", duration = 5000 },
            { coords = vector3(-1020.5, -1350.8, 5.5), label = "Despacho de Envíos en Muelle Vespucci", animDict = "anim@heists@box_carry@", animClip = "idle", duration = 5000 }
        },
        minigame = 'medium',
        pay = { min = 145, max = 290 }
    },

    -- 10. CHATARRERO VINTAGE Y RELIQUIAS (INVENTADO)
    ['vintage_picker'] = {
        job = 'vintage_picker',
        name = "Desguace y Recuperación La Puerta",
        blip = { sprite = 527, color = 40, scale = 0.8, title = "🔧 Sede: Desguace de Reliquias Clásicas" },
        boss = {
            coords = vector4(-474.3, -1717.8, 18.6, 145.0),
            model = `s_m_m_autoshop_02`,
            scenario = 'WORLD_HUMAN_WELDING',
            label = "Chatarrero Maestro La Puerta"
        },
        vehicle = {
            model = 'ratloader',
            spawn = vector4(-465.1, -1725.2, 18.2, 235.0)
        },
        tasks = {
            { coords = vector3(-500.5, -1740.2, 17.5), label = "Carrocería Antigua de Muscle Car", animDict = "amb@world_human_welding@male@base", animClip = "base", duration = 6000 },
            { coords = vector3(-440.8, -1690.4, 18.8), label = "Bloque de Motor V8 Clásico", animDict = "amb@world_human_welding@male@base", animClip = "base", duration = 6000 },
            { coords = vector3(-485.2, -1680.1, 18.0), label = "Chasis de Camión Rústico de los 70", animDict = "amb@world_human_gardener_plant@male@base", animClip = "base", duration = 5500 }
        },
        minigame = 'easy',
        pay = { min = 125, max = 250 }
    },

    -- 11. ENÓLOGO Y BODEGUERO MARLOWE (INVENTADO)
    ['wine_sommelier'] = {
        job = 'wine_sommelier',
        name = "Bodega y Cavas del Viñedo Marlowe",
        blip = { sprite = 478, color = 27, scale = 0.8, title = "🍷 Sede: Bodegas Viñedo Marlowe" },
        boss = {
            coords = vector4(-1888.2, 2060.1, 140.9, 335.0),
            model = `a_m_m_prolhost_01`,
            scenario = 'WORLD_HUMAN_STAND_MOBILE',
            label = "Sumiller Jefe Marlowe Hills"
        },
        vehicle = {
            model = 'surfer',
            spawn = vector4(-1875.4, 2072.1, 140.2, 65.0)
        },
        tasks = {
            { coords = vector3(-1920.4, 2085.2, 139.8), label = "Prensa Tradicional de Uva Tempranillo", animDict = "amb@world_human_gardener_plant@male@base", animClip = "base", duration = 5500 },
            { coords = vector3(-1860.1, 2040.5, 141.2), label = "Inspección de Barricas de Roble Francés", animDict = "amb@world_human_gardener_plant@male@base", animClip = "base", duration = 5500 },
            { coords = vector3(-1940.8, 2015.4, 142.5), label = "Embotellado de Reserva Exclusiva", animDict = "mp_common", animClip = "givetake2_a", duration = 5000 }
        },
        minigame = 'medium',
        pay = { min = 135, max = 275 }
    },

    -- 12. GUARDABOSQUES MONTE CHILIAD (INVENTADO)
    ['wildlife_ranger'] = {
        job = 'wildlife_ranger',
        name = "Estación de Rangers Monte Chiliad",
        blip = { sprite = 442, color = 43, scale = 0.8, title = "🌲 Sede: Estación Rangers Chiliad" },
        boss = {
            coords = vector4(-438.1, 5600.3, 44.9, 15.0),
            model = `s_m_m_paramedic_01`,
            scenario = 'WORLD_HUMAN_BINOCULARS',
            label = "Ranger Mayor de Parques"
        },
        vehicle = {
            model = 'kamacho',
            spawn = vector4(-446.5, 5612.4, 44.2, 105.0)
        },
        tasks = {
            { coords = vector3(-390.4, 5645.2, 54.8), label = "Punto de Observación y Huellas de Fauna", animDict = "amb@world_human_binoculars@male@base", animClip = "base", duration = 6000 },
            { coords = vector3(-320.1, 5720.8, 72.4), label = "Revisión de Trampa de Furtivos", animDict = "amb@world_human_gardener_plant@male@base", animClip = "base", duration = 5500 },
            { coords = vector3(-480.5, 5550.2, 60.1), label = "Caja de Primeros Auxilios de Sendero", animDict = "amb@world_human_gardener_plant@male@base", animClip = "base", duration = 5500 }
        },
        minigame = 'easy',
        pay = { min = 130, max = 265 }
    }
}
