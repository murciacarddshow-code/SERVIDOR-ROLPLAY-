Config = Config or {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use qb-target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)

Config.AvailableJobs = {
    -- Empleos Habituales
    ['trucker'] = { ['label'] = 'Camionero de Transporte Pesado', ['isManaged'] = false },
    ['taxi'] = { ['label'] = 'Taxista Metropolitano', ['isManaged'] = false },
    ['tow'] = { ['label'] = 'Servicio de Grúa y Asistencia', ['isManaged'] = false },
    ['reporter'] = { ['label'] = 'Periodista Weazel News', ['isManaged'] = false },
    ['garbage'] = { ['label'] = 'Operario de Limpieza Urbana', ['isManaged'] = false },
    ['bus'] = { ['label'] = 'Conductor de Autobús', ['isManaged'] = false },
    ['hotdog'] = { ['label'] = 'Puesto de Perritos Calientes', ['isManaged'] = false },
    ['miner'] = { ['label'] = 'Minero de Cantera Davis Quartz', ['isManaged'] = false },
    ['lumberjack'] = { ['label'] = 'Leñador Forestal de Paleto', ['isManaged'] = false },
    ['fisherman'] = { ['label'] = 'Pescador Profesional de Alta Mar', ['isManaged'] = false },
    ['farmer'] = { ['label'] = 'Agricultor de Campo Grapeseed', ['isManaged'] = false },
    ['delivery'] = { ['label'] = 'Repartidor de Paquetería Express', ['isManaged'] = false },
    ['electrician'] = { ['label'] = 'Técnico Electricista Municipal', ['isManaged'] = false },
    ['gardener'] = { ['label'] = 'Jardinero y Paisajista Municipal', ['isManaged'] = false },
    ['pizza'] = { ['label'] = 'Repartidor de Pizza This', ['isManaged'] = false },
    ['windowcleaner'] = { ['label'] = 'Limpiador de Cristales en Rascacielos', ['isManaged'] = false },
    ['diver'] = { ['label'] = 'Buzo Profesional y Rescate', ['isManaged'] = false },
    ['security'] = { ['label'] = 'Vigilante de Seguridad Privada', ['isManaged'] = false },
    ['waiter'] = { ['label'] = 'Camarero y Personal de Sala', ['isManaged'] = false },

    -- Empleos Exclusivos / Inventados
    ['cards_courier'] = { ['label'] = 'Repartidor TCG Murcia Card Show', ['isManaged'] = false },
    ['vintage_picker'] = { ['label'] = 'Chatarrero Vintage y Reliquias', ['isManaged'] = false },
    ['content_creator'] = { ['label'] = 'Streamer Urbano / Creador de Contenido', ['isManaged'] = false },
    ['wildlife_ranger'] = { ['label'] = 'Guardabosques Monte Chiliad', ['isManaged'] = false },
    ['wine_sommelier'] = { ['label'] = 'Enólogo y Maestro Bodeguero Marlowe', ['isManaged'] = false },
    ['food_critic'] = { ['label'] = 'Inspector y Crítico Gastronómico', ['isManaged'] = false }
}

Config.Cityhalls = {
    { -- Cityhall 1 (Ayuntamiento Central)
        coords = vec3(-265.0, -963.6, 31.2),
        showBlip = true,
        blipData = {
            sprite = 487,
            display = 4,
            scale = 0.65,
            colour = 0,
            title = 'Ayuntamiento Central'
        },
        licenses = {
            ['id_card'] = {
                label = 'DNI Español',
                cost = 50,
            },
            ['driver_license'] = {
                label = 'Permiso de Conducir DGT',
                cost = 50,
                metadata = 'driver'
            },
            ['weaponlicense'] = {
                label = 'Licencia de Armas',
                cost = 50,
                metadata = 'weapon'
            },
        }
    },
}

Config.DrivingSchools = {
    { -- Driving School 1
        coords = vec3(240.3, -1379.89, 33.74),
        showBlip = true,
        blipData = {
            sprite = 225,
            display = 4,
            scale = 0.65,
            colour = 3,
            title = 'Driving School'
        },
        instructors = {
            'DJD56142',
            'DXT09752',
            'SRI85140',
        }
    },
}

Config.Peds = {
    -- Cityhall Ped
    {
        model = 'a_m_m_hasjew_01',
        coords = vec4(-262.79, -964.18, 30.22, 181.71),
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        cityhall = true,
        zoneOptions = { -- Used for when UseTarget is false
            length = 3.0,
            width = 3.0,
            debugPoly = false
        }
    },
    -- Driving School Ped
    {
        model = 'a_m_m_eastsa_02',
        coords = vec4(240.91, -1379.2, 32.74, 138.96),
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        drivingschool = true,
        zoneOptions = { -- Used for when UseTarget is false
            length = 3.0,
            width = 3.0
        }
    }
}
