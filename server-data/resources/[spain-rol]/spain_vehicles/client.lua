CreateThread(function()
    -- Cuerpos de Seguridad Españoles
    AddTextEntry('POLICE', 'Citroen C4 Picasso - CNP Patrulla')
    AddTextEntry('POLICE2', 'Peugeot 308 - CNP Z')
    AddTextEntry('POLICE3', 'Seat Leon FR - Guardia Civil Trafico')
    AddTextEntry('POLICE4', 'Nissan Pathfinder - Guardia Civil')
    AddTextEntry('POLICEB', 'BMW R1200RT - Moto Guardia Civil')
    AddTextEntry('RIOT', 'Mercedes Sprinter - UIP Antidisturbios CNP')
    AddTextEntry('AMBULANCE', 'Mercedes Sprinter - SAMUR Urgencias')
    AddTextEntry('FIRETRUK', 'Camion de Bomberos de Espana')

    -- Vehículos Reales de Calle (Superdeportivos, berlinas y motos)
    AddTextEntry('ADDER', 'Bugatti Veyron Super Sport')
    AddTextEntry('NERO', 'Bugatti Chiron W16')
    AddTextEntry('ZENTORNO', 'Lamborghini Sesto Elemento')
    AddTextEntry('REAPER', 'Lamborghini Huracan LP 610-4')
    AddTextEntry('VACCA', 'Lamborghini Gallardo')
    AddTextEntry('TEMPESTA', 'Lamborghini Huracan Performante')
    AddTextEntry('ITALIGTB', 'Ferrari 488 GTB')
    AddTextEntry('TURISMOR', 'Ferrari LaFerrari')
    AddTextEntry('T20', 'McLaren P1 Hybrid')
    AddTextEntry('GP1', 'McLaren F1')
    AddTextEntry('OSIRIS', 'Pagani Huayra')
    AddTextEntry('TAILGATER', 'Audi RS6 Avant Quattro')
    AddTextEntry('TAILGATER2', 'Audi RS3 Sportback')
    AddTextEntry('SCHAFTER2', 'Mercedes-Benz Clase C 63 AMG')
    AddTextEntry('SCHAFTER3', 'Mercedes-Benz Clase E 63 AMG')
    AddTextEntry('DUBSTA', 'Mercedes-Benz Clase G 63 AMG')
    AddTextEntry('SENTINEL', 'BMW M3 E92 V8')
    AddTextEntry('ORACLE', 'BMW M5 F90')
    AddTextEntry('COMET2', 'Porsche 911 GT3 RS')
    AddTextEntry('ELEGY', 'Nissan GT-R R35 Nismo')
    AddTextEntry('SULTAN', 'Subaru Impreza WRX STI')
    AddTextEntry('BALLER', 'Range Rover Sport SVR')
    AddTextEntry('FELON', 'Maserati Ghibli Trofeo')
    AddTextEntry('BANSHEE', 'Dodge Viper ACR')
    AddTextEntry('COQUETTE', 'Chevrolet Corvette C7 Stingray')
    
    -- Motos Reales
    AddTextEntry('BATI', 'Ducati Panigale V4')
    AddTextEntry('AKUMA', 'Ducati Monster 1200')
    AddTextEntry('HAKUCHOU', 'Suzuki Hayabusa 1300')
    AddTextEntry('SANCHEZ', 'Yamaha YZ450F Motocross')
    AddTextEntry('FAGGIO', 'Vespa Piaggio 125cc')
end)

-- ============================================================================
-- DESACTIVACIÓN TOTAL DE LA RADIO Y EMISORAS EN VEHÍCULOS
-- ============================================================================

local RADIO_STATIONS = {
    'RADIO_01_CLASS_ROCK',             -- Los Santos Rock Radio
    'RADIO_02_POP',                    -- Non-Stop-Pop FM
    'RADIO_03_HIPHOP_NEW',             -- Radio Los Santos
    'RADIO_04_PUNK',                   -- Channel X
    'RADIO_05_TALK_01',                -- West Coast Talk Radio
    'RADIO_06_COUNTRY',                -- Rebel Radio
    'RADIO_07_DANCE_01',               -- Soulwax FM
    'RADIO_08_MEXICAN',                -- East Los FM
    'RADIO_09_HIPHOP_OLD',             -- West Coast Classics
    'RADIO_11_TALK_02',                -- Blaine County Radio
    'RADIO_12_REGGAE',                 -- Blue Ark
    'RADIO_13_JAZZ',                   -- Worldwide FM
    'RADIO_14_DANCE_02',               -- FlyLo FM
    'RADIO_15_MOTOWN',                 -- The Lowdown 91.1
    'RADIO_16_SILVERLAKE',             -- Radio Mirror Park
    'RADIO_17_FUNK',                   -- Space 103.2
    'RADIO_18_90S_ROCK',               -- Vinewood Boulevard Radio
    'RADIO_19_USER',                   -- Self Radio
    'RADIO_20_THELAB',                 -- The Lab
    'RADIO_21_DLC_XM17',               -- Blonded Los Santos 97.8 FM
    'RADIO_22_DLC_BATTLE_MIX1_RADIO',  -- Los Santos Underground Radio
    'RADIO_23_DLC_XM19_RADIO',         -- iFruit Radio
    'RADIO_27_DLC_PRPlatform',         -- Still Slipping Los Santos
    'RADIO_34_DLC_HEI4_KULT',          -- Kult FM
    'RADIO_35_DLC_HEI4_MLR',           -- The Music Locker
    'RADIO_36_AUDIOPLAYER',            -- Media Player
    'RADIO_37_MOTOMAMI',               -- MOTOMAMI Los Santos
    'DLC_XM17_MUSIC_STOPS',            -- Blonded stops
    'HIDDEN_RADIO_01_CLASS_ROCK',
    'HIDDEN_RADIO_02_POP',
    'HIDDEN_RADIO_03_HIPHOP_NEW',
    'HIDDEN_RADIO_04_PUNK',
    'HIDDEN_RADIO_06_COUNTRY',
    'HIDDEN_RADIO_07_DANCE_01',
    'HIDDEN_RADIO_09_HIPHOP_OLD',
    'HIDDEN_RADIO_12_REGGAE',
    'HIDDEN_RADIO_14_DANCE_02',
    'HIDDEN_RADIO_15_MOTOWN',
    'HIDDEN_RADIO_16_SILVERLAKE',
    'HIDDEN_RADIO_17_FUNK',
    'HIDDEN_RADIO_18_90S_ROCK',
    'HIDDEN_RADIO_20_THELAB',
    'HIDDEN_RADIO_21_DLC_XM17',
    'HIDDEN_RADIO_34_DLC_HEI4_KULT',
    'HIDDEN_RADIO_35_DLC_HEI4_MLR',
    'HIDDEN_RADIO_AMBIENT_TV',
    'HIDDEN_RADIO_AMBIENT_TV_BRIGHT',
    'RADIO_24_DLC_XM19_RADIO',
    'RADIO_25_DLC_XM19_RADIO',
    'RADIO_26_DLC_XM19_RADIO'
}

-- Función para apagar radio inmediatamente en un vehículo
local function TurnOffRadio(veh)
    if veh and DoesEntityExist(veh) then
        SetVehRadioStation(veh, 'OFF')
    end
    SetRadioToStationName('OFF')
    SetUserRadioControlEnabled(false)
end

-- Ocultar todas las emisoras del selector / dial del juego y ajustar flags de audio
CreateThread(function()
    for _, station in ipairs(RADIO_STATIONS) do
        SetRadioStationIsVisible(station, false)
    end
    SetAudioFlag('RadioOffWhenLeaveCar', true)
    SetAudioFlag('DisableFlightMusic', true)
end)

-- Bucle de desactivación continua mientras se esté montado en cualquier vehículo
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            sleep = 0

            -- Bloquear controles de radio:
            -- 81: INPUT_VEH_NEXT_RADIO (.)
            -- 82: INPUT_VEH_PREV_RADIO (,)
            -- 83: INPUT_VEH_RADIO_WHEEL_NEXT
            -- 84: INPUT_VEH_RADIO_WHEEL_PREV
            -- 85: INPUT_VEH_RADIO_WHEEL (Q)
            DisableControlAction(0, 81, true)
            DisableControlAction(0, 82, true)
            DisableControlAction(0, 83, true)
            DisableControlAction(0, 84, true)
            DisableControlAction(0, 85, true)
            SetUserRadioControlEnabled(false)

            local veh = GetVehiclePedIsIn(ped, false)
            if DoesEntityExist(veh) then
                local currentRadio = GetPlayerRadioStationName()
                if currentRadio ~= nil and currentRadio ~= 'OFF' then
                    SetVehRadioStation(veh, 'OFF')
                    SetRadioToStationName('OFF')
                end
            end
        end

        Wait(sleep)
    end
end)

-- Eventos de entrada a vehículos para apagarla de golpe instantáneamente
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkPlayerEnteredVehicle' then
        local ped = PlayerPedId()
        if args[1] == ped then
            TurnOffRadio(args[2])
        end
    end
end)

RegisterNetEvent('QBCore:Client:EnteredVehicle', function(data)
    local veh = (type(data) == 'table' and data.vehicle) or data
    TurnOffRadio(veh)
end)

RegisterNetEvent('baseevents:enteredVehicle', function(veh, seat, name)
    TurnOffRadio(veh)
end)

