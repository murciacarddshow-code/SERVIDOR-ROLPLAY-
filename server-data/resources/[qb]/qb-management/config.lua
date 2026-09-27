-- Zones for Menus
Config = Config or {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use qb-target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)

Config.BossMenus = {
    police = {
        vector3(447.16, -974.31, 30.47),
    },
    ambulance = {
        vector3(311.21, -599.36, 43.29),
    },
    cardealer = {
        vector3(-32.94, -1114.64, 26.42),
    },
    mechanic = { -- Los Santos Customs (Centro)
        vector3(-347.59, -133.35, 39.01),
    },
    bennys = { -- Benny's Original Motor Works
        vector3(-205.56, -1313.41, 31.30),
    },
    mechanic2 = { -- Taller Mecánico Harmony Repair
        vector3(1185.86, 2638.70, 38.40),
    },
    mechanic3 = { -- Los Santos Customs Sur (Aeropuerto)
        vector3(-1147.28, -1990.26, 13.18),
    },
    beeker = { -- Beeker's Garage (Paleto Bay)
        vector3(108.87, 6625.56, 31.79),
    },
}

Config.GangMenus = {
    lostmc = {
        vector3(0, 0, 0),
    },
    ballas = {
        vector3(0, 0, 0),
    },
    vagos = {
        vector3(0, 0, 0),
    },
    cartel = {
        vector3(0, 0, 0),
    },
    families = {
        vector3(0, 0, 0),
    },
}
