-- =========================================================================
-- SPAIN ROL - SISTEMA INTEGRAL DE MECÁNICOS Y PIEZAS FÍSICAS (ONX / R1 MECH)
-- =========================================================================
-- Características:
-- 1. Sistema de Fichar (Entrar/Salir de Servicio) con punto en Benny's y comando /fichar.
-- 2. Piezas físicas reales que se portan con las manos (animación y prop 3D).
-- 3. Interacciones por huesos específicos del coche con ALT (qb-target):
--    - Capó / Motor: motor, turbo, transmisión, reparación de bloque.
--    - Ruedas: neumáticos, pastillas/pinzas de freno, amortiguadores y suspensión.
--    - Maletero: refuerzo y blindaje de chasis.
-- 4. Desmontaje físico de piezas instaladas para recuperarlas en el inventario.
-- 5. Efectos de partículas de chispas de soldadura y animaciones profesionales.
-- 6. Tablet interactiva "R1 MECH PRO" con diagnóstico por componentes y almacén físico.

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}

-- Variables para el porte de piezas físicas
local isCarryingPart = false
local carriedPartProp = nil
local carriedPartData = nil

-- Inicialización
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUpdated', function(val)
    PlayerData = val
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    if PlayerData and PlayerData.job then
        PlayerData.job.onduty = duty
    end
end)

AddEventHandler('onResourceStart', function(resName)
    if GetCurrentResourceName() == resName then
        PlayerData = QBCore.Functions.GetPlayerData()
    end
end)

-- Comprobación de rol de mecánico
local function IsMechanic()
    local job = (PlayerData and PlayerData.job) or QBCore.Functions.GetPlayerData().job
    if not job then return false end
    local jName = job.name
    local jType = job.type
    return jType == 'mechanic' or jName == 'bennys' or jName == 'mechanic' or jName == 'canals' or jName == 'mechanic2' or jName == 'mechanic3' or jName == 'beeker' or QBCore.Functions.HasPermission('admin') or QBCore.Functions.HasPermission('god')
end

-- Comprobación de servicio activo (Permite trabajar sobre vehículos en cualquier momento)
local function IsMechanicOnDuty()
    if not IsMechanic() then return false end
    return true
end

-- =========================================================================
-- 1. EFECTOS DE CHISPAS Y ANIMACIONES PROFESIONALES
-- =========================================================================
local function PlayWeldingSparks(coords, durationMs)
    RequestNamedPtfxAsset("core")
    local timeout = 0
    while not HasNamedPtfxAssetLoaded("core") and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
    UseParticleFxAssetNextCall("core")
    local ptfx = StartParticleFxLoopedAtCoord("ent_dst_gen_sparks_welder", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.2, false, false, false, false)
    SetTimeout(durationMs or 5000, function()
        StopParticleFxLooped(ptfx, 0)
    end)
end

-- =========================================================================
-- 2. SISTEMA DE PORTAR PIEZAS FÍSICAS EN LAS MANOS
-- =========================================================================
local propModels = {
    engine = { model = `prop_car_engine_01`, bone = 60309, pos = vec3(0.12, 0.28, 0.0), rot = vec3(-75.0, 0.0, 0.0) },
    wheel = { model = `prop_rub_tyre_01`, bone = 60309, pos = vec3(0.05, 0.32, 0.0), rot = vec3(0.0, 90.0, 0.0) },
    tire = { model = `prop_rub_tyre_01`, bone = 60309, pos = vec3(0.05, 0.32, 0.0), rot = vec3(0.0, 90.0, 0.0) },
    brakes = { model = `imp_prop_impexp_box_wood01`, bone = 60309, pos = vec3(0.05, 0.25, 0.0), rot = vec3(0.0, 0.0, 0.0) },
    suspension = { model = `imp_prop_impexp_box_wood01`, bone = 60309, pos = vec3(0.05, 0.25, 0.0), rot = vec3(0.0, 0.0, 0.0) },
    transmission = { model = `imp_prop_impexp_box_wood01`, bone = 60309, pos = vec3(0.05, 0.25, 0.0), rot = vec3(0.0, 0.0, 0.0) },
    turbo = { model = `prop_car_battery_01`, bone = 60309, pos = vec3(0.05, 0.22, 0.0), rot = vec3(0.0, 0.0, 0.0) },
    armor = { model = `imp_prop_impexp_box_wood01`, bone = 60309, pos = vec3(0.05, 0.25, 0.0), rot = vec3(0.0, 0.0, 0.0) },
    repairkit = { model = `imp_prop_impexp_span_03`, bone = 28422, pos = vec3(0.06, 0.01, -0.02), rot = vec3(0.0, 0.0, 0.0) }
}

local function DropCarriedPart()
    if carriedPartProp and DoesEntityExist(carriedPartProp) then
        DeleteEntity(carriedPartProp)
        carriedPartProp = nil
    end
    isCarryingPart = false
    carriedPartData = nil
    ClearPedTasks(PlayerPedId())
end

local function StartCarryingPart(partType, itemName, label)
    if isCarryingPart then
        DropCarriedPart()
    end

    local ped = PlayerPedId()
    local config = propModels[partType] or propModels.engine

    RequestModel(config.model)
    local timeout = 0
    while not HasModelLoaded(config.model) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    local pCoords = GetEntityCoords(ped)
    local prop = CreateObject(config.model, pCoords.x, pCoords.y, pCoords.z + 0.2, true, true, true)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, config.bone), config.pos.x, config.pos.y, config.pos.z, config.rot.x, config.rot.y, config.rot.z, true, true, false, true, 1, true)

    RequestAnimDict("anim@heists@box_carry@")
    while not HasAnimDictLoaded("anim@heists@box_carry@") do Wait(10) end
    TaskPlayAnim(ped, "anim@heists@box_carry@", "idle", 3.0, -8, -1, 49, 0, 0, 0, 0)

    isCarryingPart = true
    carriedPartProp = prop
    carriedPartData = { partType = partType, item = itemName, label = label }

    -- Hilo para controles mientras se porta la pieza física
    CreateThread(function()
        while isCarryingPart do
            Wait(0)
            local pPed = PlayerPedId()
            if not IsEntityPlayingAnim(pPed, "anim@heists@box_carry@", "idle", 3) then
                TaskPlayAnim(pPed, "anim@heists@box_carry@", "idle", 3.0, -8, -1, 49, 0, 0, 0, 0)
            end

            -- HUD de instrucción
            QBCore.Functions.DrawText3D(pCoords.x, pCoords.y, pCoords.z + 0.5, "")
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName("~y~Llevando:~s~ " .. (carriedPartData.label or "Pieza Física") .. "  |  ~g~[E]~s~ Montar en Coche  |  ~r~[X]~s~ Devolver a Inventario")
            SetTextFont(0)
            SetTextScale(0.35, 0.35)
            SetTextColour(255, 255, 255, 255)
            SetTextEntry('STRING')
            SetTextCentre(true)
            EndTextCommandDisplayText(0.5, 0.92)

            -- Cancelar y guardar
            if IsControlJustPressed(0, 73) then -- Tecla X
                local item = carriedPartData.item
                DropCarriedPart()
                QBCore.Functions.Notify('Has guardado la pieza en tu inventario.', 'primary')
                break
            end

            -- Intentar instalar con tecla E cerca del coche
            if IsControlJustPressed(0, 38) then -- Tecla E
                local closestVeh, dist = QBCore.Functions.GetClosestVehicle()
                if closestVeh ~= 0 and dist <= 3.5 then
                    local pData = carriedPartData
                    DropCarriedPart()
                    TriggerEvent('spain_mechanic:client:installPerformancePart', {
                        partType = pData.partType,
                        item = pData.item,
                        veh = closestVeh
                    })
                    break
                else
                    QBCore.Functions.Notify('Acércate al vehículo para montarle la pieza.', 'error')
                end
            end
        end
    end)
end

RegisterNetEvent('spain_mechanic:client:startCarryingPart', function(data)
    StartCarryingPart(data.partType, data.item, data.label)
end)

-- Cuando el jugador usa un ítem desde el inventario, puede elegir instalarlo directamente o sacarlo en mano
RegisterNetEvent('spain_mechanic:client:handleUsablePart', function(data)
    local usableMenu = {
        {
            header = "⚙️ Componente Físico: " .. (data.item or "Pieza"),
            isMenuHeader = true
        },
        {
            header = "🧰 Sacar en la Mano (Llevar Pieza Física)",
            txt = "Carga la pieza físicamente en tus manos para llevarla caminando al coche",
            params = {
                event = "spain_mechanic:client:carryFromInventory",
                args = data
            }
        },
        {
            header = "🔧 Instalar Directamente en el Vehículo Cercano",
            txt = "Inicia el montaje de forma inmediata si estás junto al coche",
            params = {
                event = "spain_mechanic:client:installPerformancePart",
                args = data
            }
        },
        {
            header = "❌ Cancelar",
            params = {
                event = "qb-menu:client:closeMenu"
            }
        }
    }
    exports['qb-menu']:openMenu(usableMenu)
end)

RegisterNetEvent('spain_mechanic:client:carryFromInventory', function(data)
    StartCarryingPart(data.partType, data.item, data.item)
end)

-- =========================================================================
-- 3. BASE DE DATOS DE INGENIERÍA AUTOMOTRIZ REAL (13 VEHÍCULOS & UNIVERSAL)
-- =========================================================================
local VehicleEngData = {
    sultan = {
        label = "Karin Sultan (Subaru Impreza WRX STI GD)",
        engine = "2.5L Turbo Boxer-4 EJ257 DOHC 16V",
        architecture = "4 Cilindros Bóxer Opuestos (180°)",
        displacement = "2.457 cc",
        powerStock = "300 CV @ 6.000 RPM (407 Nm par)",
        turbo = "Twin-Scroll VF48 con Intercooler Top-Mount",
        drivetrain = "Symmetrical AWD Permanente + Diferencial Central DCCD",
        fuelSystem = "Inyección Secuencial Multipunto (Rampa 3.8 bar)",
        wiring = "Arnés Denso STI Ignífugo con Mazo Blindado y Conectores Weather-Pack",
        battery = "12V 65Ah 650CCA de Gel",
        ecu = "Denso STI ECM 32-Bit Multiplexada (CAN-Bus ISO 15765-4)",
        sparkPlugs = "NGK Laser Iridium ILFR6B con 4 Bobinas COP Directas",
        oil = "Sintético Motul 300V 5W-40 (Cárter 4.8 Litros)",
        oilCap = 4.8,
        brakes = "Brembo Monobloque 4 Pistones Delanteros (326mm) / 2 Traseros",
        suspension = "McPherson Invertida Delantera / Doble Triángulo Trasero STI",
        tires = "Michelin Pilot Sport 4S 245/40 R18 (32.0 PSI)",
        nomPsi = 32.0
    },
    elegy = {
        label = "Annis Elegy RH8 (Nissan GT-R R35 Nismo)",
        engine = "3.8L Twin-Turbo V6 VR38DETT DOHC 24V",
        architecture = "6 Cilindros en V a 60° con Camisas Pulverizadas por Plasma",
        displacement = "3.799 cc",
        powerStock = "570 CV @ 6.800 RPM (637 Nm par)",
        turbo = "Doble Turbocompresor IHI Integrado + Doble Intercooler Frontal",
        drivetrain = "ATTESA E-TS AWD con Transeje Trasero Dual-Clutch GR6 y LSD 1.5-Way",
        fuelSystem = "Inyección Multipunto Doble Banco con Doble Caudalímetro MAF Hitachi",
        wiring = "Mazo CAN-Bus Cuádruple de Alta Velocidad (500 kbaud) con 32 Módulos",
        battery = "12V 75Ah 720CCA de Gel Sellada",
        ecu = "ECU Gemela Hitachi/Nismo ECM + TCM Sincronizadas",
        sparkPlugs = "NGK DILKAR7B11 Doble Iridio con 6 Bobinas Amplificadas",
        oil = "Mobil 1 0W-40 Synthetic Racing Spec (Cárter 5.5 Litros con Doble Radiador)",
        oilCap = 5.5,
        brakes = "Brembo Monobloque 6 Pistones Delanteros (390mm Carbocerámicos) / 4 Traseros",
        suspension = "Doble Trapecio con Amortiguadores Bilstein DampTronic Regulables",
        tires = "Dunlop SP Sport Maxx GT600 285/35 R20 (31.5 PSI)",
        nomPsi = 31.5
    },
    futo = {
        label = "Karin Futo (Toyota Sprinter Trueno / AE86 Levin)",
        engine = "1.6L 4A-GE DOHC 16V TVIS (Culata Yamaha Racing)",
        architecture = "4 Cilindros en Línea Atmosférico de Alto Giro (7.800 RPM)",
        displacement = "1.587 cc",
        powerStock = "130 CV @ 6.600 RPM (149 Nm par)",
        turbo = "Atmosférico N/A con Colectores 4-2-1 Inox y Admisión Variable T-VIS",
        drivetrain = "Propulsión Trasera RWD con Eje Rígido y Diferencial LSD Kaaz 2-Way",
        fuelSystem = "Inyección Electrónica EFI Denso con Mariposas Pulidas y Filtro K&N",
        wiring = "Arnés Eléctrico Aligerado Wire-Tuck con Fusibles Térmicos",
        battery = "12V 45Ah 400CCA Batería Compacta",
        ecu = "Toyota TCCS con Mapeado de Avance de Encendido Agresivo",
        sparkPlugs = "NGK BCPR6EY Ranura en V con Cables de Silicona 8mm",
        oil = "Valvoline VR1 Racing 10W-40 Semisintético (Cárter 3.8 Litros)",
        oilCap = 3.8,
        brakes = "Discos Ventilados 242mm Delanteros / Macizos Traseros con Pastillas Ferodo DS2500",
        suspension = "Columnas McPherson Delanteras / Eje 4-Link Trasero con Muelles Cortos TRD",
        tires = "195/50 R15 Neumáticos de Drift (34.0 PSI)",
        nomPsi = 34.0
    },
    dominator = {
        label = "Vapid Dominator (Ford Mustang GT 5.0)",
        engine = "5.0L Coyote V8 DOHC 32V Ti-VCT",
        architecture = "8 Cilindros en V a 90° con Bloque de Aluminio y Culatas de Flujo Cruzado",
        displacement = "5.038 cc",
        powerStock = "450 CV @ 7.000 RPM (529 Nm par)",
        turbo = "Atmosférico Muscular con Colector de Admisión Runner Activo (Válvulas CMCV)",
        drivetrain = "Propulsión Trasera RWD con Eje Torsen 3.73:1 LSD",
        fuelSystem = "Inyección Dual PFDI (Directa en Cámara + Multipunto en Colector)",
        wiring = "Arnés Ford Copperhead Multiplexado de Alta Sección con Aislamiento Térmico",
        battery = "12V 70Ah 700CCA Motorcraft BXD con Sistema BMS Inteligente",
        ecu = "Ford PCM Tri-Core TC1797 con Detección de Octanaje en Tiempo Real",
        sparkPlugs = "Motorcraft SP-548 Iridio con 8 Bobinas Individuales",
        oil = "Motorcraft Full Synthetic 5W-20 con Filtro FL-500S (Cárter 9.5 Litros)",
        oilCap = 9.5,
        brakes = "Brembo 6 Pistones Monobloque Delanteros (380mm Rallados) / Pinza Flotante Trasera",
        suspension = "Doble Rótula McPherson Delantera / Suspensión Multibrazo Integral Trasera",
        tires = "Pirelli P Zero 275/40 R19 (32.0 PSI)",
        nomPsi = 32.0
    },
    banshee = {
        label = "Bravado Banshee (Dodge Viper SRT-10)",
        engine = "8.4L V10 OHV 20V Big Block de Aluminio",
        architecture = "10 Cilindros en V a 90° con Varillas de Empuje y Pistones Forjados",
        displacement = "8.390 cc",
        powerStock = "640 CV @ 6.200 RPM (813 Nm par)",
        turbo = "Atmosférico Puro de Par Masivo con Doble Mariposa Electrónica de 74mm",
        drivetrain = "Propulsión Trasera RWD con Embrague Bidisco Cerámico y Eje Dana 44 ViscoLok",
        fuelSystem = "Inyección Secuencial Multipunto con Doble Rampa Inyectores de Alto Flujo",
        wiring = "Cableado Blindado con Funda Ignífuga de Titanio Térmica",
        battery = "12V 80Ah 800CCA AGM en Subchasis Posterior para Reparto 50/50",
        ecu = "Chrysler GPEC2 PCM de Competición con Mapas Abiertos",
        sparkPlugs = "Champion Platinum Power (10 Bujías) con Bobinas Coil-Near-Plug",
        oil = "Pennzoil Ultra Platinum 0W-40 Cárter Seco (10.5 Litros con 2 Bombas de Barrido)",
        oilCap = 10.5,
        brakes = "StopTech 4 Pistones en las 4 Ruedas con Rotores Curvados de 355mm",
        suspension = "Doble Horquilla Triangular en Aluminio Fundido con Amortiguadores Ajustables",
        tires = "Michelin Pilot Sport Cup 2 345/30 R19 Traseros Ultranchos (29.0 PSI)",
        nomPsi = 29.0
    },
    kuruma = {
        label = "Karin Kuruma (Mitsubishi Lancer Evolution X)",
        engine = "2.0L Turbo 4B11T DOHC 16V MIVEC",
        architecture = "4 Cilindros en Línea con Bloque Semizerrado de Aluminio",
        displacement = "1.998 cc",
        powerStock = "295 CV @ 6.500 RPM (407 Nm par)",
        turbo = "Turbocompresor MHI TD05H-152G6-12T con Válvula Electrónica e Intercooler Frontal",
        drivetrain = "S-AWC AWD con ACD (Diferencial Central Activo) y AYC (Control Activo de Guiñada)",
        fuelSystem = "Inyección Multipunto de Presión Variable con Bomba de Retorno Rápido",
        wiring = "Mazo de Cables de Motor Mitsubishi Rally Spec Apantallado contra RFI",
        battery = "12V 60Ah 540CCA Relocalizada en Maletero para Distribución de Masas",
        ecu = "Mitsubishi Engine Control Module con Mapeado de Antilag",
        sparkPlugs = "NGK Laser Iridium ILKR8E6 con 4 Bobinas de Alta Tensión",
        oil = "Castrol Edge Supercar 10W-60 (Cárter 4.6 Litros con Radiador de Aceite Externo)",
        oilCap = 4.6,
        brakes = "Brembo Racing Rojas 4 Pistones Delanteros (350mm) / 2 Pistones Traseros (330mm)",
        suspension = "McPherson con Brazos Forjados de Aluminio y Amortiguadores Bilstein",
        tires = "Yokohama Advan Neova AD08R 245/40 R18 (32.0 PSI)",
        nomPsi = 32.0
    },
    sentinel = {
        label = "Übermacht Sentinel (BMW M3 E92 V8 / E46 CSL)",
        engine = "4.0L S65B40 V8 Atmosférico de Competición (8.400 RPM)",
        architecture = "8 Cilindros en V a 90° con Bloque de Aleación de Aluminio y Silicio (Alusil)",
        displacement = "3.999 cc",
        powerStock = "420 CV @ 8.300 RPM (400 Nm par)",
        turbo = "Atmosférico con 8 Mariposas de Admisión Individuales Servocontroladas",
        drivetrain = "Propulsión Trasera RWD con Diferencial Autoblocante Variable M (0-100%)",
        fuelSystem = "Inyección Secuencial Multipunto con Doble Bomba de Succión Lateral",
        wiring = "Arnés BMW Motorsport con Cableado Multiplexado y Buses FlexRay / CAN",
        battery = "12V 90Ah 900CCA AGM con Sensor Inteligente de Batería (IBS)",
        ecu = "Siemens MSS60 con Medición de Corriente de Iones en Bujías (Ion Current Sensing)",
        sparkPlugs = "NGK LKR8AP Platino con Doble Electrodo (Medición de Detonación Integrada)",
        oil = "Shell Helix Ultra Racing 10W-60 (Cárter 8.8 Litros con Doble Tapón)",
        oilCap = 8.8,
        brakes = "Discos Flotantes Compuestos Perforados de 360mm con Cubos de Aluminio Forjado",
        suspension = "Eje Delantero de Doble Articulación / Eje Trasero Multibrazo de 5 Brazos",
        tires = "Michelin Pilot Super Sport 265/35 R19 (33.0 PSI)",
        nomPsi = 33.0
    },
    blista = {
        label = "Dinka Blista (Honda Civic Type R EP3 / EK9)",
        engine = "2.0L K20A2 DOHC i-VTEC 16V (Corte a 8.200 RPM)",
        architecture = "4 Cilindros en Línea con Alzada y Cruce de Válvulas Variable VTEC",
        displacement = "1.998 cc",
        powerStock = "200 CV @ 7.400 RPM (196 Nm par)",
        turbo = "Atmosférico de Giro Rápido con Colector de Admisión Pulido RBC y Escape 4-2-1",
        drivetrain = "Tracción Delantera FWD con Diferencial Autoblocante Helicoidal (Helical LSD)",
        fuelSystem = "Inyección Honda PGM-FI con Inyectores Keihin 310 cc/min de Pulverización Fina",
        wiring = "Arnés Honda Racing Wire-Tuck Compacto con Conectores Mil-Spec",
        battery = "12V 45Ah 420CCA Batería Compacta Yuasa de Gel",
        ecu = "Honda PGM-FI con Módulo Hondata K-Pro Programable por USB",
        sparkPlugs = "NGK Iridium IX BKR7EIX-11 (Giro en Régimen Alto)",
        oil = "Castrol Magnatec 5W-40 Totalmente Sintético (Cárter 4.2 Litros)",
        oilCap = 4.2,
        brakes = "Pinzas Flotantes Reforzadas Nissin Type R con Discos Ventilados de 300mm",
        suspension = "Esquema McPherson Deportivo Delantero / Doble Horquilla Trasera Reactiva",
        tires = "Bridgestone Potenza RE070 215/45 R17 (32.0 PSI)",
        nomPsi = 32.0
    },
    buffalo = {
        label = "Bravado Buffalo (Dodge Charger SRT Hellcat / 392 HEMI)",
        engine = "6.4L 392 HEMI V8 Apache / 6.2L Supercharged HEMI V8",
        architecture = "8 Cilindros en V con Cámaras de Combustión Hemisféricas y Bloque Nodular",
        displacement = "6.417 cc",
        powerStock = "485 CV @ 6.100 RPM (644 Nm par)",
        turbo = "Compresor Volumétrico IHI de 2.4L de Doble Tornillo con Intercooler Aire-Líquido",
        drivetrain = "Propulsión Trasera RWD con Eje Reforzado ZF de 230mm y Diferencial LSD",
        fuelSystem = "Doble Bomba de Combustible de 300 LPH y Rampa de Aluminio Billete",
        wiring = "Mazo de Cables Reforzado de Gran Calibre con Fusibles de Protección de 150A",
        battery = "12V 85Ah 850CCA Mopar Heavy-Duty AGM",
        ecu = "FCA Powertrain Controller con Módulo de Control de Lanzamiento y Line-Lock",
        sparkPlugs = "16 Bujías de Iridio (2 Bujías por Cilindro) con Paquete de Bobinas Gemelas",
        oil = "Pennzoil Ultra Platinum 0W-40 SRT Spec (Cárter 6.6 Litros)",
        oilCap = 6.6,
        brakes = "Brembo Monobloque 6 Pistones Delanteros (390mm Ranurados) / 4 Pistones Traseros",
        suspension = "Suspensión de Brazo Corto y Largo (SLA) Delantera con Muelles de Tasa Progresiva",
        tires = "Pirelli P Zero All Season 275/40 R20 (32.0 PSI)",
        nomPsi = 32.0
    },
    coquette = {
        label = "Invetero Coquette (Chevrolet Corvette C7 Stingray)",
        engine = "6.2L LT1 Small Block V8 Inyección Directa",
        architecture = "8 Cilindros en V a 90° con Varillas de Empuje y Válvulas VVT de Fase Variable",
        displacement = "6.162 cc",
        powerStock = "460 CV @ 6.000 RPM (630 Nm par)",
        turbo = "Atmosférico con Tubo de Torsión Central de Fibra de Carbono Rígido",
        drivetrain = "Propulsión Trasera RWD con Transeje y Diferencial Electrónico de Deslizamiento (eLSD)",
        fuelSystem = "Inyección Directa en Cámara (DI) a 150 Bares con Bomba Mecánica de Alta Presión",
        wiring = "Arnés GM Mil-Spec con Conexiones Blindadas y Bus CAN de Alta Frecuencia",
        battery = "12V 70Ah 750CCA ACDelco Professional en Compartimento Posterior Aislado",
        ecu = "General Motors Delco E92 con Gestión de Desactivación Dinámica AFM",
        sparkPlugs = "ACDelco Professional Iridium 41-114 con 8 Bobinas Directas",
        oil = "Mobil 1 Dexos 0W-40 Cárter Seco Z51 (Cárter 9.3 Litros con Depósito Auxiliar)",
        oilCap = 9.3,
        brakes = "Brembo Monobloque 4 Pistones Delanteros con Discos Flotantes Co-Cast de 345mm",
        suspension = "Ballestas Transversales de Compuesto de Fibra de Vidrio con Amortiguadores Magnetic Ride",
        tires = "Michelin Pilot Super Sport ZP 285/30 R20 (30.0 PSI)",
        nomPsi = 30.0
    },
    schafter2 = {
        label = "Benefactor Schafter V12 (Mercedes-Benz E63 AMG W212)",
        engine = "5.5L M157 Bi-Turbo V8 AMG Direct Injection",
        architecture = "8 Cilindros en V a 90° Biturbo con Cárter de Aluminio Fundido en Arena",
        displacement = "5.461 cc",
        powerStock = "557 CV @ 5.500 RPM (720 Nm par)",
        turbo = "Doble Turbocompresor Garrett con Refrigeración por Agua y Presión de 1.0 Bar",
        drivetrain = "AMG Performance 4MATIC (Reparto 33% Delante / 67% Detrás) con Cambio Speedshift MCT 7G",
        fuelSystem = "Inyección Directa Piezoeléctrica Guiada por Chorro (Spray-Guided) a 200 Bar",
        wiring = "Arnés Mercedes-Benz Cuádruple CAN-Bus con Bucle de Fibra Óptica MOST",
        battery = "12V 95Ah 850CCA Varta AGM con Batería Auxiliar de Respaldo de 12Ah en Maletero",
        ecu = "Bosch MED 17.7.3 AMG con Mapas de Encendido Adaptativos por Cilindro",
        sparkPlugs = "Bosch Doble Platino ZR6SII3320 con Bobinas Rápidas Multichispa",
        oil = "Petronas Syntium 7000 0W-40 MB-Approval 229.5 (Cárter 8.5 Litros con Intercambiador)",
        oilCap = 8.5,
        brakes = "AMG High-Performance 6 Pistones Delanteros (360mm Perforados y Ventilados)",
        suspension = "AMG RIDE CONTROL con Eje Delantero Helicoidal y Suspensión Neumática Trasera Airmatic",
        tires = "Continental ContiSportContact 5P 285/30 R19 (33.0 PSI)",
        nomPsi = 33.0
    },
    tailgater = {
        label = "Obey Tailgater (Audi RS4 / S4 B8 Quattro)",
        engine = "4.2L FSI V8 DOHC Atmosférico de Alto Giro (8.250 RPM)",
        architecture = "8 Cilindros en V a 90° de Aleación Alusil con Distribución Trasera por 4 Cadenas",
        displacement = "4.163 cc",
        powerStock = "450 CV @ 8.250 RPM (430 Nm par)",
        turbo = "Atmosférico FSI con Colector de Admisión de Dos Fases en Magnesio",
        drivetrain = "Tracción Total Permanente Quattro con Diferencial Central Corona Dentada y Sport Diff Trasero",
        fuelSystem = "Inyección Directa FSI Homogénea con Dos Bombas Mecánicas Hitachi a 135 Bar",
        wiring = "Cableado Blindado Audi Sport con Protección Térmica Reforzada en Mampara Cortafuegos",
        battery = "12V 92Ah 850CCA Moll AGM en el Suelo del Maletero para Distribución de Masa",
        ecu = "Doble Centralita Bosch MED 9.1.1 en Configuración Maestro-Esclavo",
        sparkPlugs = "NGK Laser Platinum PFR7W-TG con Bobinas Tipo Lápiz Rojas Audi R8",
        oil = "Castrol Edge Professional LongLife III 5W-30 (Cárter 9.0 Litros)",
        oilCap = 9.0,
        brakes = "Pinzas Wave Design Flotantes 8 Pistones Delanteros (365mm Ondulados de Fundición Ligera)",
        suspension = "Eje Delantero de Cinco Brazos en Aluminio con Dynamic Ride Control (DRC)",
        tires = "Pirelli P Zero Trofeo R 265/30 R20 (32.5 PSI)",
        nomPsi = 32.5
    },
    comet2 = {
        label = "Pfister Comet (Porsche 911 997/991 Carrera / GT3)",
        engine = "3.8L Flat-6 Boxer Atmosférico DFI / Bi-Turbo Mezger",
        architecture = "6 Cilindros Bóxer Horizontales Opuestos Montados en Posición Posterior al Eje (RR)",
        displacement = "3.800 cc",
        powerStock = "400 CV @ 7.400 RPM (440 Nm par)",
        turbo = "Atmosférico de Competición con Colector de Admisión Resonante de Doble Cámara",
        drivetrain = "Propulsión Trasera RR con Cambio PDK de Doble Embrague y Bloqueo Mecánico de Diferencial",
        fuelSystem = "Inyección Directa DFI con Inyectores Electromagnéticos de Apertura Multietapa",
        wiring = "Arnés Ultraligero Porsche Motorsport Ignífugo con Conectores Deutsch Autosport",
        battery = "12V 70Ah 760CCA Batería de Ión-Litio Ultraligera (Ahorro de 10 kg)",
        ecu = "Bosch Motorsport Motronic ME7.8 / MED17 con Telemetría Integrada",
        sparkPlugs = "Bosch Platinum-Iridium FGR5KQE0 con Bobinas de Descarga de Alta Frecuencia",
        oil = "Mobil 1 0W-40 Cárter Seco Integrado con 4 Bombas de Evacuación (Capacidad 10.0 Litros)",
        oilCap = 10.0,
        brakes = "Porsche Ceramic Composite Brake (PCCB) 6 Pistones Amarillas con Discos Cerámicos 350mm",
        suspension = "Eje Delantero McPherson Porsche PASM con Eje Trasero Multibrazo LSA y Dirección Trasera Activa",
        tires = "Michelin Pilot Sport Cup 2 305/30 R20 Traseros (31.0 PSI)",
        nomPsi = 31.0
    }
}

local function GetVehicleEngineeringData(veh)
    if not veh or not DoesEntityExist(veh) then return nil end
    local modelHash = GetEntityModel(veh)
    local modelName = string.lower(GetDisplayNameFromVehicleModel(modelHash))

    if VehicleEngData[modelName] then
        return VehicleEngData[modelName]
    end

    local vClass = GetVehicleClass(veh)
    local vClassNames = {
        [0] = "Compacto / Utilitario", [1] = "Sedán / Berlina", [2] = "SUV / Todocamino",
        [3] = "Coupé Deportivo", [4] = "Muscle Car Clásico/Moderno", [5] = "Deportivo Clásico",
        [6] = "Deportivo GT", [7] = "Superdeportivo", [8] = "Motocicleta", [9] = "Todoterreno 4x4",
        [10] = "Industrial", [11] = "Utilitario", [12] = "Furgoneta", [18] = "Vehículo de Emergencia"
    }

    local dispName = GetLabelText(GetDisplayNameFromVehicleModel(modelHash))
    if dispName == "NULL" then dispName = GetDisplayNameFromVehicleModel(modelHash) end

    local fallback = {
        label = dispName .. " (" .. (vClassNames[vClass] or "Automóvil") .. ")",
        engine = (vClass == 7 and "5.2L V10 DOHC 40V Inyección Directa") or
                 (vClass == 4 and "5.7L V8 OHV HEMI de Fundición") or
                 (vClass == 6 and "3.0L Turbo Inline-6 DOHC 24V") or
                 (vClass == 8 and "1000cc 4 Cilindros DOHC Refrigerado por Agua") or
                 (vClass == 2 and "3.5L V6 Twin-Turbo EcoBoost DOHC") or
                 "2.0L 16V DOHC Inyección Directa con Distribución Variable",
        architecture = (vClass == 7 and "10 Cilindros en V a 90°") or
                       (vClass == 4 and "8 Cilindros en V a 90°") or
                       (vClass == 6 and "6 Cilindros en Línea Longitudinal") or
                       (vClass == 8 and "4 Cilindros en Línea Transversal") or
                       "4 Cilindros en Línea Delantero Transversal",
        displacement = (vClass == 7 and "5.204 cc") or (vClass == 4 and "5.654 cc") or (vClass == 6 and "2.998 cc") or "1.998 cc",
        powerStock = (vClass == 7 and "610 CV @ 8.250 RPM") or (vClass == 4 and "375 CV @ 5.600 RPM") or "190 CV @ 5.500 RPM",
        turbo = (vClass == 6 or vClass == 7) and "Turbocompresor Twin-Scroll con Intercooler Frontal" or "Atmosférico N/A",
        drivetrain = (vClass == 4 and "Propulsión Trasera RWD con Diferencial Autoblocante") or
                     (vClass == 7 and "Tracción Integral Permanente AWD con Reparto Inteligente") or
                     "Tracción Delantera FWD con Control de Tracción Electrónico",
        fuelSystem = "Inyección Electrónica Multipunto Secuencial con Bomba Eléctrica Sumergida",
        wiring = "Arnés de Cables Estándar Automotriz con Conectores Sellados y Fusibles de Protección",
        battery = "12V 70Ah 640CCA Libre de Mantenimiento",
        ecu = "Centralita Electrónica OEM OBD-II / EOBD CAN-Bus",
        sparkPlugs = "Bujías de Iridio NGK con Bobinas Individuales COP",
        oil = "Aceite 100% Sintético Multigrado 5W-30 (Cárter 4.5 Litros)",
        oilCap = 4.5,
        brakes = "Discos de Freno Ventilados Delanteros con Pinzas Flotantes de Doble Pistón",
        suspension = "Suspensión Independiente McPherson Delantera y Eje Torsional Trasero",
        tires = "Neumáticos Radiales de Compuesto Asimétrico (32.0 PSI)",
        nomPsi = 32.0
    }
    return fallback
end

-- =========================================================================
-- 4. INTERACCIONES REALISTAS CON MIRILLA (qb-target AddTargetBone)
-- =========================================================================
CreateThread(function()
    if GetResourceState('qb-target') == 'started' then
        -- 1. Vano Motor y Capó: Opciones técnicas hiperrealistas
        exports['qb-target']:AddTargetBone({'bonnet', 'engine'}, {
            options = {
                {
                    num = 1,
                    icon = 'fas fa-wrench',
                    label = '🔍 Diagnóstico Motor & Componentes',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        TriggerEvent('spain_mechanic:client:openEngineDiag', entity)
                    end
                },
                {
                    num = 2,
                    icon = 'fas fa-bolt',
                    label = '⚡ Cableado Eléctrico, Batería & Sensores',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        TriggerEvent('spain_mechanic:client:openElectricalWiring', entity)
                    end
                },
                {
                    num = 3,
                    icon = 'fas fa-oil-can',
                    label = '🛢️ Comprobar Nivel de Aceite (Varilla)',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        TriggerEvent('spain_mechanic:client:checkOilDipstick', entity)
                    end
                },
                {
                    num = 4,
                    icon = 'fas fa-laptop-code',
                    label = '💻 Diagnosis Electrónica OBD-II',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        TriggerEvent('spain_mechanic:client:openObdScanner', entity)
                    end
                },
                {
                    num = 5,
                    icon = 'fas fa-gauge-high',
                    label = '🏎️ Potencia & Modificaciones de Rendimiento',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        TriggerEvent('spain_mechanic:client:openEngineBayMenu', entity)
                    end
                }
            },
            distance = 2.2
        })

        -- 2. Ruedas, Frenos, Manómetro y Suspensión (En cada rueda)
        exports['qb-target']:AddTargetBone({'wheel_lf', 'wheel_rf', 'wheel_lr', 'wheel_rr'}, {
            options = {
                {
                    num = 1,
                    icon = 'fas fa-stop',
                    label = '🛑 Sistema de Frenos (Pastillas en mm & Discos)',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        TriggerEvent('spain_mechanic:client:openBrakesMenu', entity)
                    end
                },
                {
                    num = 2,
                    icon = 'fas fa-gauge',
                    label = '💨 Manómetro: Presión PSI & Dibujo de Neumáticos',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        TriggerEvent('spain_mechanic:client:checkTirePressureAction', entity)
                    end
                },
                {
                    num = 3,
                    icon = 'fas fa-car-tunnel',
                    label = '🛞 Suspensión, Trapecios & Silentblocks',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        TriggerEvent('spain_mechanic:client:openSuspensionDiag', entity)
                    end
                }
            },
            distance = 1.9
        })

        -- 3. Maletero, Escape y Diferencial Trasero
        exports['qb-target']:AddTargetBone({'boot'}, {
            options = {
                {
                    num = 1,
                    icon = 'fas fa-fire-flame-simple',
                    label = '💨 Línea de Escape & Diferencial Trasero',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        TriggerEvent('spain_mechanic:client:openExhaustDiffMenu', entity)
                    end
                },
                {
                    num = 2,
                    icon = 'fas fa-shield-halved',
                    label = '🛡️ Maletero & Refuerzo de Chasis (Blindaje)',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        TriggerEvent('spain_mechanic:client:openTrunkMenu', entity)
                    end
                }
            },
            distance = 2.2
        })
    end
end)

-- Menú específico del Vano Motor (Capó)
RegisterNetEvent('spain_mechanic:client:openEngineBayMenu', function(veh)
    if not veh or not DoesEntityExist(veh) then return end
    SetVehicleModKit(veh, 0)

    local engineMod = GetVehicleMod(veh, 11)
    local maxEngine = GetNumVehicleMods(veh, 11)
    local turboOn = IsToggleModOn(veh, 18)
    local transMod = GetVehicleMod(veh, 13)
    local maxTrans = GetNumVehicleMods(veh, 13)
    local engineHealth = math.floor(GetVehicleEngineHealth(veh) / 10)

    local menu = {
        {
            header = "🔧 Vano Motor: Diagnóstico de Potencia",
            isMenuHeader = true
        },
        {
            header = "⚙️ Estado del Bloque Motor: " .. engineHealth .. "%",
            txt = "Nivel Actual: " .. (engineMod == -1 and "Stock" or "Nivel " .. (engineMod + 1) .. " de " .. maxEngine),
            isMenuHeader = true
        },
        {
            header = "🌪️ Turbocompresor: " .. (turboOn and "✅ INSTALADO (+35% Potencia)" or "❌ NO INSTALADO"),
            isMenuHeader = true
        },
        {
            header = "🏎️ Montar / Mejorar Bloque de Motor",
            txt = "Requiere tener Kit de Motor en el inventario o en la mano",
            params = {
                event = "spain_mechanic:client:installPerformancePart",
                args = { partType = 'engine', veh = veh }
            }
        },
        {
            header = "🌪️ Montar Turbocompresor e Intercooler",
            txt = "Requiere Kit de Turbocompresor",
            params = {
                event = "spain_mechanic:client:installPerformancePart",
                args = { partType = 'turbo', veh = veh }
            }
        }
    }

    -- Opción de DESMONTAR TURBO físicamente
    if turboOn then
        menu[#menu + 1] = {
            header = "🔩 Desmontar Turbocompresor",
            txt = "Extrae el turbo físicamente para recuperarlo en tu inventario",
            params = {
                event = "spain_mechanic:client:dismantlePart",
                args = { partType = 'turbo', veh = veh }
            }
        }
    end

    -- Opción de DESMONTAR MOTOR físicamente
    if engineMod >= 0 then
        menu[#menu + 1] = {
            header = "🔩 Desmontar Kit de Motor a Stock",
            txt = "Retira las mejoras de motor y recupera el kit en tu inventario",
            params = {
                event = "spain_mechanic:client:dismantlePart",
                args = { partType = 'engine', veh = veh }
            }
        }
    end

    menu[#menu + 1] = {
        header = "🛠️ Reparar Bloque Motor con Kit",
        txt = "Restaura la salud del motor al 100%",
        params = {
            event = "spain_mechanic:client:useRepairKit",
            args = veh
        }
    }

    menu[#menu + 1] = {
        header = "❌ Cerrar",
        params = { event = "qb-menu:client:closeMenu" }
    }

    exports['qb-menu']:openMenu(menu)
end)

-- Menú específico de Rueda, Frenos y Suspensión
RegisterNetEvent('spain_mechanic:client:openWheelHubMenu', function(veh)
    if not veh or not DoesEntityExist(veh) then return end
    SetVehicleModKit(veh, 0)

    local brakesMod = GetVehicleMod(veh, 12)
    local maxBrakes = GetNumVehicleMods(veh, 12)
    local suspMod = GetVehicleMod(veh, 15)
    local maxSusp = GetNumVehicleMods(veh, 15)

    local menu = {
        {
            header = "🛞 Eje y Suspensión de Rueda",
            isMenuHeader = true
        },
        {
            header = "🛑 Frenos: " .. (brakesMod == -1 and "Stock" or "Nivel " .. (brakesMod + 1) .. " de " .. maxBrakes),
            isMenuHeader = true
        },
        {
            header = "🛞 Suspensión: " .. (suspMod == -1 and "Stock" or "Nivel " .. (suspMod + 1) .. " de " .. maxSusp),
            isMenuHeader = true
        },
        {
            header = "🛞 Sustituir y Equilibrar Neumático",
            txt = "Repara y cambia la goma de la rueda",
            params = {
                event = "spain_mechanic:client:fixTyres",
                args = { veh = veh }
            }
        },
        {
            header = "🛑 Montar / Mejorar Pinzas de Freno",
            txt = "Requiere Kit de Frenos Deportivos",
            params = {
                event = "spain_mechanic:client:installPerformancePart",
                args = { partType = 'brakes', veh = veh }
            }
        },
        {
            header = "🏎️ Montar / Ajustar Suspensión Deportiva",
            txt = "Requiere Kit de Suspensión Deportiva",
            params = {
                event = "spain_mechanic:client:installPerformancePart",
                args = { partType = 'suspension', veh = veh }
            }
        }
    }

    -- Desmontar frenos
    if brakesMod >= 0 then
        menu[#menu + 1] = {
            header = "🔩 Desmontar Frenos Deportivos",
            txt = "Devuelve los frenos a Stock y recupera el kit",
            params = {
                event = "spain_mechanic:client:dismantlePart",
                args = { partType = 'brakes', veh = veh }
            }
        }
    end

    -- Desmontar suspensión
    if suspMod >= 0 then
        menu[#menu + 1] = {
            header = "🔩 Desmontar Suspensión Deportiva",
            txt = "Devuelve la suspensión a Stock y recupera el kit",
            params = {
                event = "spain_mechanic:client:dismantlePart",
                args = { partType = 'suspension', veh = veh }
            }
        }
    end

    menu[#menu + 1] = {
        header = "❌ Cerrar",
        params = { event = "qb-menu:client:closeMenu" }
    }

    exports['qb-menu']:openMenu(menu)
end)

-- Menú específico del Maletero (Blindaje)
RegisterNetEvent('spain_mechanic:client:openTrunkMenu', function(veh)
    if not veh or not DoesEntityExist(veh) then return end
    SetVehicleModKit(veh, 0)

    local armorMod = GetVehicleMod(veh, 16)
    local maxArmor = GetNumVehicleMods(veh, 16)

    local menu = {
        {
            header = "🛡️ Maletero y Chasis Reforzado",
            isMenuHeader = true
        },
        {
            header = "🛡️ Nivel de Blindaje Actual: " .. (armorMod == -1 and "Stock (0%)" or "Nivel " .. (armorMod + 1) .. " de " .. maxArmor),
            isMenuHeader = true
        },
        {
            header = "🛡️ Montar Placas de Blindaje Reforzado",
            txt = "Requiere Kit de Blindaje en el inventario",
            params = {
                event = "spain_mechanic:client:installPerformancePart",
                args = { partType = 'armor', veh = veh }
            }
        }
    }

    if armorMod >= 0 then
        menu[#menu + 1] = {
            header = "🔩 Desmontar Blindaje de Chasis",
            txt = "Retira las placas y recupera el kit en tu inventario",
            params = {
                event = "spain_mechanic:client:dismantlePart",
                args = { partType = 'armor', veh = veh }
            }
        }
    end

    menu[#menu + 1] = {
        header = "❌ Cerrar",
        params = { event = "qb-menu:client:closeMenu" }
    }

    exports['qb-menu']:openMenu(menu)
end)

-- =========================================================================
-- 4. MENÚS Y ACCIONES INTERACTIVAS REALISTAS POR COMPONENTES AUTOMOTRICES
-- =========================================================================

-- 4.1 DIAGNÓSTICO DE MOTOR, CULATA Y DISTRIBUCIÓN
RegisterNetEvent('spain_mechanic:client:openEngineDiag', function(veh)
    if not veh or not DoesEntityExist(veh) then return end
    local engData = GetVehicleEngineeringData(veh)
    local engineHealth = math.floor(GetVehicleEngineHealth(veh) / 10)
    SetVehicleDoorOpen(veh, 4, false, false)

    local compBar = string.format("%.1f", math.max(6.0, 11.2 * (engineHealth / 100)))
    local compText = engineHealth > 60 and ("<span style='color:#00ff88; font-weight:bold;'>Nominal (" .. compBar .. " bar)</span>") or ("<span style='color:#ff4757; font-weight:bold;'>Baja Compresión (" .. compBar .. " bar)</span>")
    local timingText = engineHealth > 60 and "<span style='color:#00ff88;'>95% - Tensión Óptima & Sin Holgura</span>" or "<span style='color:#ff4757;'>42% - Desgaste Acusado / Destensada</span>"
    local sparkText = engineHealth > 50 and "<span style='color:#00ff88;'>Electrodos Limpios & Chispa Estable</span>" or "<span style='color:#ffa502;'>Carbonización en Electrodos</span>"
    local coolingText = engineHealth > 40 and "<span style='color:#00ff88;'>98% Nivel G12+ (Circuito Estanco)</span>" or "<span style='color:#ff4757;'>Fuga Térmica / Nivel Bajo</span>"

    local menu = {
        {
            header = "🔍 Diagnóstico Motor: " .. engData.label,
            isMenuHeader = true
        },
        {
            header = "⚙️ Bloque & Culata",
            txt = engData.engine .. " | " .. engData.architecture .. "<br>Salud: " .. engineHealth .. "% | Compresión: " .. compText,
            isMenuHeader = true
        },
        {
            header = "⛓️ Sistema de Distribución",
            txt = "Estado: " .. timingText .. "<br>Sincronización de válvulas en fase",
            isMenuHeader = true
        },
        {
            header = "⚡ Encendido & Bujías",
            txt = engData.sparkPlugs .. "<br>Estado: " .. sparkText,
            isMenuHeader = true
        },
        {
            header = "⛽ Sistema de Alimentación",
            txt = engData.fuelSystem .. " (Presión nominal: 3.8 bar)",
            isMenuHeader = true
        },
        {
            header = "🧊 Circuito de Refrigeración",
            txt = "Radiador & Manguitos: " .. coolingText,
            isMenuHeader = true
        },
        {
            header = "🔧 Ajustar y Reconstruir Culata & Distribución",
            txt = "Restaura la compresión y la sincronización con herramientas de precisión",
            params = {
                event = "spain_mechanic:client:useRepairKit",
                args = veh
            }
        },
        {
            header = "🔌 Sustituir Juego de Bujías y Bobinas de Encendido",
            txt = "Requiere Juego de Bujías de Iridio",
            params = {
                event = "spain_mechanic:client:replacePlugsAction",
                args = { veh = veh }
            }
        },
        {
            header = "❌ Cerrar Diagnóstico",
            params = { event = "qb-menu:client:closeMenu" }
        }
    }
    exports['qb-menu']:openMenu(menu)
end)

-- 4.2 CABLEADO ELÉCTRICO, BATERÍA Y SENSORES ECU
RegisterNetEvent('spain_mechanic:client:openElectricalWiring', function(veh)
    if not veh or not DoesEntityExist(veh) then return end
    local engData = GetVehicleEngineeringData(veh)
    local engineHealth = math.floor(GetVehicleEngineHealth(veh) / 10)
    SetVehicleDoorOpen(veh, 4, false, false)

    local harnessHealth = math.max(25, engineHealth)
    local harnessText = harnessHealth > 60 and "<span style='color:#00ff88; font-weight:bold;'>98% (Aislamiento Íntegro & Conectores Sellados)</span>" or "<span style='color:#ff4757; font-weight:bold;'>38% (Derivación a Masa / Conectores Sulfatados)</span>"
    local batteryVolt = engineHealth > 40 and "12.6 V Reposo | 14.3 V Alternador (140A)" or "11.2 V (Batería Descargada)"

    local menu = {
        {
            header = "⚡ Arnés Eléctrico & Sensores: " .. engData.label,
            isMenuHeader = true
        },
        {
            header = "🔌 Arnés de Motor (Wiring Harness)",
            txt = "Especificación: " .. engData.wiring .. "<br>Integridad Eléctrica: " .. harnessText,
            isMenuHeader = true
        },
        {
            header = "🔋 Batería & Sistema de Carga",
            txt = engData.battery .. "<br>Voltaje medido: " .. batteryVolt,
            isMenuHeader = true
        },
        {
            header = "📡 Sensores Críticos de Motor",
            txt = "• Caudalímetro (MAF): 3.4 g/s al ralentí (Nominal)<br>• Sonda Lambda (O2): λ = 1.00 Estequiométrica<br>• Sensor Cigüeñal (CKP): Sincronizado<br>• Sensor Detonación: 0.0° Retardo",
            isMenuHeader = true
        },
        {
            header = "⚡ Reparar y Soldar Cableado de Motor con Multímetro",
            txt = "Mide resistencia y suelda terminales del mazo (Usa 'veh_wiring' o kit de mecánico)",
            params = {
                event = "spain_mechanic:client:repairWiringAction",
                args = { veh = veh }
            }
        },
        {
            header = "🔋 Sustituir Batería 12V AGM",
            txt = "Instala una batería automotriz nueva de alto rendimiento (Usa 'car_battery')",
            params = {
                event = "spain_mechanic:client:replaceBatteryAction",
                args = { veh = veh }
            }
        },
        {
            header = "🔌 Cambiar Bujías y Bobinas",
            txt = "Instala bujías de iridio nuevas para asegurar chispa perfecta",
            params = {
                event = "spain_mechanic:client:replacePlugsAction",
                args = { veh = veh }
            }
        },
        {
            header = "💻 Conectar Escáner OBD-II",
            txt = "Accede a la diagnosis en tiempo real de la centralita",
            params = {
                event = "spain_mechanic:client:openObdScanner",
                args = veh
            }
        },
        {
            header = "❌ Cerrar",
            params = { event = "qb-menu:client:closeMenu" }
        }
    }
    exports['qb-menu']:openMenu(menu)
end)

-- Acción interactiva: Reparar cableado con multímetro y soldadura
RegisterNetEvent('spain_mechanic:client:repairWiringAction', function(data)
    local veh = data.veh or QBCore.Functions.GetClosestVehicle()
    if veh == 0 then return end
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)

    SetVehicleDoorOpen(veh, 4, false, false)
    PlayWeldingSparks(pCoords, 5000)

    QBCore.Functions.Progressbar("repair_wiring", "Comprobando continuidad con multímetro y soldando arnés de cables...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        anim = "machinic_loop_mechandplayer",
        flags = 1,
    }, {}, {}, function()
        SetVehicleDoorShut(veh, 4, false)
        TriggerServerEvent('spain_mechanic:server:consumeSpecificItem', 'veh_wiring', 'Arnés de Cableado de Motor')
        SetVehicleEngineHealth(veh, 1000.0)
        TriggerServerEvent('spain_mechanic:server:saveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
        QBCore.Functions.Notify('⚡ Arnés de cableado saneado, soldaduras selladas con termorretráctil e instalación al 100%.', 'success', 5000)
    end, function()
        SetVehicleDoorShut(veh, 4, false)
    end)
end)

-- Acción interactiva: Sustituir batería
RegisterNetEvent('spain_mechanic:client:replaceBatteryAction', function(data)
    local veh = data.veh or QBCore.Functions.GetClosestVehicle()
    if veh == 0 then return end
    local ped = PlayerPedId()

    SetVehicleDoorOpen(veh, 4, false, false)

    QBCore.Functions.Progressbar("replace_battery", "Desembornando polos y colocando batería 12V AGM nueva...", 4500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_player",
        flags = 1,
    }, {}, {}, function()
        SetVehicleDoorShut(veh, 4, false)
        TriggerServerEvent('spain_mechanic:server:consumeSpecificItem', 'car_battery', 'Batería 12V 75Ah AGM')
        QBCore.Functions.Notify('🔋 Batería nueva instalada. Tensión nominal estable a 12.6V en reposo y 14.3V con alternador.', 'success', 5000)
    end, function()
        SetVehicleDoorShut(veh, 4, false)
    end)
end)

-- Acción interactiva: Cambiar bujías y bobinas
RegisterNetEvent('spain_mechanic:client:replacePlugsAction', function(data)
    local veh = data.veh or QBCore.Functions.GetClosestVehicle()
    if veh == 0 then return end
    local ped = PlayerPedId()

    SetVehicleDoorOpen(veh, 4, false, false)

    QBCore.Functions.Progressbar("replace_plugs", "Extrayendo bobinas y calibrando bujías de iridio nuevas...", 4500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_player",
        flags = 1,
    }, {}, {}, function()
        SetVehicleDoorShut(veh, 4, false)
        TriggerServerEvent('spain_mechanic:server:consumeSpecificItem', 'sparkplugs', 'Juego de Bujías de Iridio')
        SetVehicleEngineHealth(veh, math.max(GetVehicleEngineHealth(veh), 950.0))
        TriggerServerEvent('spain_mechanic:server:saveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
        QBCore.Functions.Notify('🔌 Bujías de iridio y bobinas de encendido sustituidas. Chispa perfecta en todos los cilindros.', 'success', 5000)
    end, function()
        SetVehicleDoorShut(veh, 4, false)
    end)
end)

-- 4.3 COMPROBAR NIVEL DE ACEITE CON VARILLA ANIMADA
RegisterNetEvent('spain_mechanic:client:checkOilDipstick', function(veh)
    if not veh or not DoesEntityExist(veh) then return end
    local engData = GetVehicleEngineeringData(veh)
    local engineHealth = math.floor(GetVehicleEngineHealth(veh) / 10)

    SetVehicleDoorOpen(veh, 4, false, false)

    QBCore.Functions.Progressbar("check_oil_dipstick", "Extrayendo varilla de nivel de aceite y limpiándola con trapo...", 3500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_player",
        flags = 1,
    }, {}, {}, function()
        local maxLit = engData.oilCap or 4.5
        local curLit = string.format("%.1f", math.max(1.5, maxLit * (engineHealth / 100)))
        local oilCond = engineHealth > 65 and "<span style='color:#00ff88;'>Viscosidad Óptima (Color Miel Translúcido)</span>" or "<span style='color:#ff4757;'>Aceite Degradado / Ennegrecido</span>"

        local oilMenu = {
            {
                header = "🛢️ Nivel de Aceite: " .. curLit .. "L / " .. maxLit .. "L",
                isMenuHeader = true
            },
            {
                header = "🛢️ Ficha de Lubricación: " .. engData.oil,
                txt = "Estado del fluido: " .. oilCond .. "<br>Filtro de aceite: Membrana sintética limpia",
                isMenuHeader = true
            },
            {
                header = "🛢️ Rellenar / Cambiar Aceite Sintético de Competición",
                txt = "Vierte aceite 100% sintético para dejar el cárter al nivel máximo (Usa 'engine_oil')",
                params = {
                    event = "spain_mechanic:client:refillEngineOil",
                    args = { veh = veh }
                }
            },
            {
                header = "❌ Guardar Varilla y Cerrar",
                params = {
                    event = "qb-menu:client:closeMenu"
                }
            }
        }
        exports['qb-menu']:openMenu(oilMenu)
    end, function()
        SetVehicleDoorShut(veh, 4, false)
    end)
end)

-- Acción interactiva: Rellenar o cambiar aceite sintético
RegisterNetEvent('spain_mechanic:client:refillEngineOil', function(data)
    local veh = data.veh or QBCore.Functions.GetClosestVehicle()
    if veh == 0 then return end
    local ped = PlayerPedId()

    SetVehicleDoorOpen(veh, 4, false, false)

    QBCore.Functions.Progressbar("refill_oil", "Vertiendo garrafa de lubricante sintético 5W-30 en el tapón...", 4500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_player",
        flags = 1,
    }, {}, {}, function()
        SetVehicleDoorShut(veh, 4, false)
        TriggerServerEvent('spain_mechanic:server:consumeSpecificItem', 'engine_oil', 'Aceite Sintético 5W-30 (5L)')
        SetVehicleEngineHealth(veh, 1000.0)
        TriggerServerEvent('spain_mechanic:server:saveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
        QBCore.Functions.Notify('🛢️ Nivel de aceite al 100% (marca MAX en varilla) y lubricación óptima restaurada.', 'success', 5000)
    end, function()
        SetVehicleDoorShut(veh, 4, false)
    end)
end)

-- 4.4 DIAGNOSIS OBD-II CON LECTURA Y BORRADO DE CÓDIGOS DTC
RegisterNetEvent('spain_mechanic:client:openObdScanner', function(veh)
    if not veh or not DoesEntityExist(veh) then return end
    local engData = GetVehicleEngineeringData(veh)
    local engineHealth = math.floor(GetVehicleEngineHealth(veh) / 10)

    QBCore.Functions.Progressbar("scan_obd", "Enlazando escáner de diagnosis con puerto OBD-II CAN-Bus...", 3000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mp_common",
        anim = "givetake_2_a",
        flags = 1,
    }, {}, {}, function()
        local dtcCode1, dtcCode2
        if engineHealth < 50 then
            dtcCode1 = "<span style='color:#ff4757; font-weight:bold;'>[DTC P0300] Fallo aleatorio de encendido en cilindros</span>"
            dtcCode2 = "<span style='color:#ffa502; font-weight:bold;'>[DTC P0101] Caudalímetro (MAF) fuera de rango de tolerancia</span>"
        elseif engineHealth < 80 then
            dtcCode1 = "<span style='color:#ffa502; font-weight:bold;'>[DTC P0420] Eficiencia del convertidor catalítico por debajo del umbral</span>"
            dtcCode2 = "<span style='color:#00ff88;'>[DTC 0000] Sin más anomalías de encendido registradas</span>"
        else
            dtcCode1 = "<span style='color:#00ff88; font-weight:bold;'>[DTC 0000] Sin códigos de avería almacenados. ECU nominal.</span>"
            dtcCode2 = "<span style='color:#00ff88;'>Check Engine: APAGADO (Valores estequiométricos OK)</span>"
        end

        local turboBoost = IsToggleModOn(veh, 18) and "1.35 Bar (19.5 PSI) Sobrepresión nominal" or "0.0 Bar (Aspiración atmosférica)"

        local obdMenu = {
            {
                header = "💻 Diagnosis OBD-II: " .. engData.ecu,
                isMenuHeader = true
            },
            {
                header = "📡 Protocolo de Comunicación",
                txt = "Enlace: ISO 15765-4 CAN (11-bit ID / 500 kbaud)<br>Unidad de Mando: " .. engData.ecu,
                isMenuHeader = true
            },
            {
                header = "⚠️ Registro de Fallos (Códigos DTC)",
                txt = dtcCode1 .. "<br>" .. dtcCode2,
                isMenuHeader = true
            },
            {
                header = "📊 Telemetría en Tiempo Real",
                txt = "• Régimen: 840 RPM al ralentí<br>• Presión Colector: " .. turboBoost .. "<br>• Refrigerante: 89°C (Termostato nominal)<br>• Avance Encendido: 14.5° BTDC",
                isMenuHeader = true
            },
            {
                header = "🧹 Borrar Códigos DTC y Resetear Testigo Check Engine",
                txt = "Elimina los fallos de la memoria no volátil y recalibra los sensores de la ECU",
                params = {
                    event = "spain_mechanic:client:clearDtcCodes",
                    args = { veh = veh }
                }
            },
            {
                header = "❌ Desconectar Escáner",
                params = { event = "qb-menu:client:closeMenu" }
            }
        }
        exports['qb-menu']:openMenu(obdMenu)
    end)
end)

RegisterNetEvent('spain_mechanic:client:clearDtcCodes', function(data)
    local veh = data.veh or QBCore.Functions.GetClosestVehicle()
    if veh == 0 then return end

    QBCore.Functions.Progressbar("clear_dtc", "Borrando memoria de fallos y reseteando testigos...", 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        QBCore.Functions.Notify('💻 Memoria DTC borrada con éxito. El testigo Check Engine se ha apagado.', 'success', 4500)
    end)
end)

-- 4.5 SISTEMA DE FRENOS, PASTILLAS EN MM Y DISCOS
RegisterNetEvent('spain_mechanic:client:openBrakesMenu', function(veh)
    if not veh or not DoesEntityExist(veh) then return end
    local engData = GetVehicleEngineeringData(veh)
    local engineHealth = math.floor(GetVehicleEngineHealth(veh) / 10)

    local padMm = string.format("%.1f", math.max(1.8, (engineHealth / 100) * 10.5))
    local padStatus = tonumber(padMm) > 3.0 and ("<span style='color:#00ff88; font-weight:bold;'>" .. padMm .. " mm (Correcto)</span>") or ("<span style='color:#ff4757; font-weight:bold;'>" .. padMm .. " mm (Límite DGT Crítico 2.0 mm)</span>")

    local brakesMod = GetVehicleMod(veh, 12)
    local maxBrakes = GetNumVehicleMods(veh, 12)

    local menu = {
        {
            header = "🛑 Conjunto de Frenos: " .. engData.label,
            isMenuHeader = true
        },
        {
            header = "🛑 Pinzas & Discos de Freno",
            txt = engData.brakes .. "<br>Nivel de mejora: " .. (brakesMod == -1 and "Stock / De Serie" or "Nivel " .. (brakesMod + 1) .. " de " .. maxBrakes),
            isMenuHeader = true
        },
        {
            header = "📏 Espesor de Pastillas de Freno",
            txt = "Grosor medido: " .. padStatus .. "<br>Espesor nuevo: 10.5 mm | Tolerancia de disco: Alabeo 0.015 mm",
            isMenuHeader = true
        },
        {
            header = "💧 Líquido de Frenos DOT 4 / 5.1",
            txt = "Punto de ebullición: 265°C | Humedad absorbida: 0.6% (Óptimo)",
            isMenuHeader = true
        },
        {
            header = "🛑 Sustituir Pastillas de Freno y Purgar Circuito",
            txt = "Instala pastillas cerámicas de alto coeficiente (Usa 'brake_pads')",
            params = {
                event = "spain_mechanic:client:replacePadsAction",
                args = { veh = veh }
            }
        },
        {
            header = "🏎️ Montar / Mejorar Kit de Frenos de Competición",
            txt = "Instala pinzas monobloque sobredimensionadas (Usa 'veh_brakes')",
            params = {
                event = "spain_mechanic:client:installPerformancePart",
                args = { partType = 'brakes', veh = veh }
            }
        }
    }

    if brakesMod >= 0 then
        menu[#menu + 1] = {
            header = "🔩 Desmontar Frenos Deportivos a Stock",
            txt = "Recupera el kit de frenos en tu inventario",
            params = {
                event = "spain_mechanic:client:dismantlePart",
                args = { partType = 'brakes', veh = veh }
            }
        }
    end

    menu[#menu + 1] = {
        header = "❌ Cerrar",
        params = { event = "qb-menu:client:closeMenu" }
    }
    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent('spain_mechanic:client:replacePadsAction', function(data)
    local veh = data.veh or QBCore.Functions.GetClosestVehicle()
    if veh == 0 then return end

    QBCore.Functions.Progressbar("replace_pads", "Desmontando pinza de freno, colocando pastillas cerámicas y purgando...", 4500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        anim = "machinic_loop_mechandplayer",
        flags = 1,
    }, {}, {}, function()
        TriggerServerEvent('spain_mechanic:server:consumeSpecificItem', 'brake_pads', 'Pastillas de Freno Cerámicas')
        SetVehicleModKit(veh, 0)
        SetVehicleMod(veh, 12, math.max(GetVehicleMod(veh, 12), 1), false)
        TriggerServerEvent('spain_mechanic:server:saveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
        QBCore.Functions.Notify('🛑 Pastillas cerámicas nuevas instaladas (10.5 mm de ferodo) y circuito purgado sin aire.', 'success', 5000)
    end)
end)

-- 4.6 MANÓMETRO, PRESIÓN PSI Y ESTADO DE NEUMÁTICOS
RegisterNetEvent('spain_mechanic:client:checkTirePressureAction', function(veh)
    if not veh or not DoesEntityExist(veh) then return end
    local engData = GetVehicleEngineeringData(veh)
    local engineHealth = math.floor(GetVehicleEngineHealth(veh) / 10)

    QBCore.Functions.Progressbar("gauge_tire", "Conectando manómetro digital a la válvula de la rueda...", 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        anim = "machinic_loop_mechandplayer",
        flags = 1,
    }, {}, {}, function()
        local isBurst = false
        for i = 0, 7 do
            if IsVehicleTyreBurst(veh, i, false) then
                isBurst = true
                break
            end
        end

        local psiReading = isBurst and "<span style='color:#ff4757; font-weight:bold;'>0.0 PSI (DESLLANTADO / PINCHADO)</span>" or ("<span style='color:#00ff88; font-weight:bold;'>" .. string.format("%.1f", engData.nomPsi or 32.0) .. " PSI (Nominal Óptima)</span>")
        local treadMm = isBurst and "0.0 mm" or (string.format("%.1f", math.max(1.6, (engineHealth / 100) * 7.5)) .. " mm (Límite legal DGT: 1.6 mm)")

        local tireMenu = {
            {
                header = "💨 Manómetro de Presión & Neumáticos",
                isMenuHeader = true
            },
            {
                header = "🛞 Especificación: " .. engData.tires,
                txt = "Presión de Inflado: " .. psiReading .. "<br>Profundidad de Dibujo: " .. treadMm,
                isMenuHeader = true
            },
            {
                header = "💨 Inflar y Calibrar Presión con Compresor (32.0 PSI)",
                txt = "Ajusta la presión exacta recomendada por el fabricante",
                params = {
                    event = "spain_mechanic:client:calibratePressure",
                    args = { veh = veh }
                }
            },
            {
                header = "🛞 Sustituir y Equilibrar Rueda / Neumático",
                txt = "Repara la goma pinchada y equilibra la rueda",
                params = {
                    event = "spain_mechanic:client:fixTyres",
                    args = { veh = veh }
                }
            },
            {
                header = "❌ Cerrar",
                params = { event = "qb-menu:client:closeMenu" }
            }
        }
        exports['qb-menu']:openMenu(tireMenu)
    end)
end)

RegisterNetEvent('spain_mechanic:client:calibratePressure', function(data)
    local veh = data.veh or QBCore.Functions.GetClosestVehicle()
    if veh == 0 then return end

    QBCore.Functions.Progressbar("calib_psi", "Inflando neumático y calibrando a 32.0 PSI...", 3000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        QBCore.Functions.Notify('💨 Ruedas infladas y calibradas con precisión a 32.0 PSI.', 'success', 4500)
    end)
end)

-- 4.7 SUSPENSIÓN Y SILENTBLOCKS
RegisterNetEvent('spain_mechanic:client:openSuspensionDiag', function(veh)
    if not veh or not DoesEntityExist(veh) then return end
    local engData = GetVehicleEngineeringData(veh)
    local suspMod = GetVehicleMod(veh, 15)
    local maxSusp = GetNumVehicleMods(veh, 15)

    local menu = {
        {
            header = "🛞 Esquema de Suspensión: " .. engData.label,
            isMenuHeader = true
        },
        {
            header = "🏎️ Configuración: " .. engData.suspension,
            txt = "Nivel de mejora: " .. (suspMod == -1 and "Stock / De Serie" or "Nivel " .. (suspMod + 1) .. " de " .. maxSusp),
            isMenuHeader = true
        },
        {
            header = "🔩 Elementos Elásticos & Trapecios",
            txt = "• Amortiguadores de gas presurizado: Sellos intactos sin fugas<br>• Silentblocks: Casquillos de poliuretano reforzados<br>• Barra estabilizadora: Bieletas ajustadas a par nominal",
            isMenuHeader = true
        },
        {
            header = "🏎️ Montar / Ajustar Suspensión Deportiva",
            txt = "Requiere Kit de Suspensión Deportiva en el inventario",
            params = {
                event = "spain_mechanic:client:installPerformancePart",
                args = { partType = 'suspension', veh = veh }
            }
        }
    }

    if suspMod >= 0 then
        menu[#menu + 1] = {
            header = "🔩 Desmontar Suspensión Deportiva a Stock",
            txt = "Devuelve los muelles a origen y recupera el kit",
            params = {
                event = "spain_mechanic:client:dismantlePart",
                args = { partType = 'suspension', veh = veh }
            }
        }
    end

    menu[#menu + 1] = {
        header = "❌ Cerrar",
        params = { event = "qb-menu:client:closeMenu" }
    }
    exports['qb-menu']:openMenu(menu)
end)

-- 4.8 LÍNEA DE ESCAPE Y DIFERENCIAL TRASERO
RegisterNetEvent('spain_mechanic:client:openExhaustDiffMenu', function(veh)
    if not veh or not DoesEntityExist(veh) then return end
    local engData = GetVehicleEngineeringData(veh)

    local menu = {
        {
            header = "💨 Línea de Escape & Diferencial: " .. engData.label,
            isMenuHeader = true
        },
        {
            header = "💨 Línea de Escape & Emisiones",
            txt = "• Tubería: Acero inoxidable T304 con resonador<br>• Catalizador: Metálico deportivo de 200 celdas<br>• Sonda Lambda posterior: Señal estequiométrica nominal",
            isMenuHeader = true
        },
        {
            header = "⚙️ Transmisión & Diferencial Trasero",
            txt = engData.drivetrain .. "<br>• Palieres: Guardapolvos íntegros con grasa de litio<br>• Bloqueo diferencial: Ajuste de par simétrico",
            isMenuHeader = true
        },
        {
            header = "❌ Cerrar",
            params = { event = "qb-menu:client:closeMenu" }
        }
    }
    exports['qb-menu']:openMenu(menu)
end)

-- 4.9 FICHA TÉCNICA OEM OFICIAL COMPLETA DEL AUTOMÓVIL
RegisterNetEvent('spain_mechanic:client:openVehicleDataSheet', function(veh)
    if not veh or not DoesEntityExist(veh) then return end
    local engData = GetVehicleEngineeringData(veh)
    local plate = QBCore.Functions.GetPlate(veh) or GetVehicleNumberPlateText(veh)
    local engineHealth = math.floor(GetVehicleEngineHealth(veh) / 10)
    local bodyHealth = math.floor(GetVehicleBodyHealth(veh) / 10)

    local turboOn = IsToggleModOn(veh, 18)

    local sheetMenu = {
        {
            header = "📋 Ficha Técnica OEM: " .. engData.label,
            txt = "Matrícula: " .. plate .. " | Estado General: " .. engineHealth .. "%",
            isMenuHeader = true
        },
        {
            header = "⚙️ Grupo Motopropulsor",
            txt = "• Motor: " .. engData.engine .. "<br>• Arquitectura: " .. engData.architecture .. "<br>• Cilindrada: " .. engData.displacement .. "<br>• Potencia: " .. engData.powerStock .. "<br>• Sobrealimentación: " .. (turboOn and "Turbo / Compresor ACTIVO" or engData.turbo),
            isMenuHeader = true
        },
        {
            header = "🏎️ Transmisión & Tren de Tracción",
            txt = "• Tracción: " .. engData.drivetrain .. "<br>• Inyección: " .. engData.fuelSystem,
            isMenuHeader = true
        },
        {
            header = "⚡ Instalación Eléctrica & ECU",
            txt = "• Arnés: " .. engData.wiring .. "<br>• Centralita: " .. engData.ecu .. "<br>• Batería: " .. engData.battery,
            isMenuHeader = true
        },
        {
            header = "🛑 Tren Rodante, Frenos & Ruedas",
            txt = "• Frenos: " .. engData.brakes .. "<br>• Suspensión: " .. engData.suspension .. "<br>• Neumáticos: " .. engData.tires .. " (" .. (engData.nomPsi or 32.0) .. " PSI)",
            isMenuHeader = true
        },
        {
            header = "🛢️ Capacidades de Fluidos",
            txt = "• Cárter Aceite: " .. (engData.oilCap or 4.5) .. " Litros (" .. engData.oil .. ")",
            isMenuHeader = true
        },
        {
            header = "🔍 Diagnóstico Integral Detallado",
            txt = "Ver desglose de desgastes por componente y averías",
            params = {
                event = "spain_mechanic:client:inspectClosest",
                args = {}
            }
        },
        {
            header = "❌ Cerrar Ficha",
            params = { event = "qb-menu:client:closeMenu" }
        }
    }
    exports['qb-menu']:openMenu(sheetMenu)
end)

-- 4.10 EVENTOS DE ACCIÓN DIRECTA DESDE ÍTEMS UTILIZABLES
RegisterNetEvent('spain_mechanic:client:useMultimeter', function()
    local ped = PlayerPedId()
    local veh, dist = QBCore.Functions.GetClosestVehicle()
    if veh ~= 0 and dist <= 3.5 then
        TriggerEvent('spain_mechanic:client:openElectricalWiring', veh)
    else
        QBCore.Functions.Notify('Acércate al motor de un vehículo para medir con el multímetro o pulsa Left ALT.', 'primary')
    end
end)

RegisterNetEvent('spain_mechanic:client:useObdScanner', function()
    local ped = PlayerPedId()
    local veh, dist = QBCore.Functions.GetClosestVehicle()
    if veh ~= 0 and dist <= 3.5 then
        TriggerEvent('spain_mechanic:client:openObdScanner', veh)
    else
        QBCore.Functions.Notify('Conecta el escáner al puerto OBD-II del vehículo apuntando con Left ALT.', 'primary')
    end
end)

RegisterNetEvent('spain_mechanic:client:useEngineOil', function()
    local ped = PlayerPedId()
    local veh, dist = QBCore.Functions.GetClosestVehicle()
    if veh ~= 0 and dist <= 3.5 then
        TriggerEvent('spain_mechanic:client:refillEngineOil', { veh = veh })
    else
        QBCore.Functions.Notify('Acércate al vano motor de un vehículo para rellenar aceite.', 'primary')
    end
end)

RegisterNetEvent('spain_mechanic:client:useSparkPlugs', function()
    local ped = PlayerPedId()
    local veh, dist = QBCore.Functions.GetClosestVehicle()
    if veh ~= 0 and dist <= 3.5 then
        TriggerEvent('spain_mechanic:client:replacePlugsAction', { veh = veh })
    else
        QBCore.Functions.Notify('Acércate al vano motor de un vehículo para sustituir las bujías.', 'primary')
    end
end)

RegisterNetEvent('spain_mechanic:client:useWiringHarness', function()
    local ped = PlayerPedId()
    local veh, dist = QBCore.Functions.GetClosestVehicle()
    if veh ~= 0 and dist <= 3.5 then
        TriggerEvent('spain_mechanic:client:repairWiringAction', { veh = veh })
    else
        QBCore.Functions.Notify('Acércate al vano motor de un vehículo para reparar el arnés de cables.', 'primary')
    end
end)

RegisterNetEvent('spain_mechanic:client:useBattery', function()
    local ped = PlayerPedId()
    local veh, dist = QBCore.Functions.GetClosestVehicle()
    if veh ~= 0 and dist <= 3.5 then
        TriggerEvent('spain_mechanic:client:replaceBatteryAction', { veh = veh })
    else
        QBCore.Functions.Notify('Acércate al compartimento de batería del vehículo para sustituirla.', 'primary')
    end
end)

RegisterNetEvent('spain_mechanic:client:useBrakePads', function()
    local ped = PlayerPedId()
    local veh, dist = QBCore.Functions.GetClosestVehicle()
    if veh ~= 0 and dist <= 3.5 then
        TriggerEvent('spain_mechanic:client:replacePadsAction', { veh = veh })
    else
        QBCore.Functions.Notify('Acércate a la rueda de un vehículo para montar las pastillas de freno.', 'primary')
    end
end)

-- =========================================================================
-- 5. DESMONTAJE FÍSICO DE PIEZAS (SISTEMA ONX)
-- =========================================================================
RegisterNetEvent('spain_mechanic:client:dismantlePart', function(data)
    local veh = data.veh or QBCore.Functions.GetClosestVehicle()
    local partType = data.partType
    local ped = PlayerPedId()

    if not IsMechanicOnDuty() then
        QBCore.Functions.Notify('Debes estar de servicio como mecánico para desmontar piezas.', 'error')
        return
    end

    SetVehicleModKit(veh, 0)
    local pCoords = GetEntityCoords(ped)

    if partType == 'turbo' then
        SetVehicleDoorOpen(veh, 4, false, false)
        PlayWeldingSparks(pCoords, 5000)

        QBCore.Functions.Progressbar("dismantle_turbo", "Desconectando intercooler y desmontando turbocompresor...", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mini@repair",
            anim = "fixing_a_player",
            flags = 1,
        }, {}, {}, function()
            ToggleVehicleMod(veh, 18, false)
            SetVehicleDoorShut(veh, 4, false)
            TriggerServerEvent('spain_mechanic:server:giveDismantledPart', { item = 'veh_turbo', label = 'Kit de Turbocompresor' })
            TriggerServerEvent('spain_mechanic:server:saveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
            QBCore.Functions.Notify('Turbocompresor desmontado y guardado en tu inventario.', 'success')
        end, function()
            SetVehicleDoorShut(veh, 4, false)
        end)
    elseif partType == 'engine' then
        SetVehicleDoorOpen(veh, 4, false, false)
        PlayWeldingSparks(pCoords, 6000)

        QBCore.Functions.Progressbar("dismantle_engine", "Desmontando bloque de motor deportivo y retornando a Stock...", 6000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mini@repair",
            anim = "fixing_a_player",
            flags = 1,
        }, {}, {}, function()
            SetVehicleMod(veh, 11, -1, false)
            SetVehicleDoorShut(veh, 4, false)
            TriggerServerEvent('spain_mechanic:server:giveDismantledPart', { item = 'veh_engine', label = 'Kit de Motor Deportivo' })
            TriggerServerEvent('spain_mechanic:server:saveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
            QBCore.Functions.Notify('Motor desmontado y recuperado en tu inventario.', 'success')
        end, function()
            SetVehicleDoorShut(veh, 4, false)
        end)
    elseif partType == 'brakes' then
        QBCore.Functions.Progressbar("dismantle_brakes", "Aflojando tornillería y retirando pinzas de freno deportivas...", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 1,
        }, {}, {}, function()
            SetVehicleMod(veh, 12, -1, false)
            TriggerServerEvent('spain_mechanic:server:giveDismantledPart', { item = 'veh_brakes', label = 'Kit de Frenos Deportivos' })
            TriggerServerEvent('spain_mechanic:server:saveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
            QBCore.Functions.Notify('Frenos desmontados y guardados en tu inventario.', 'success')
        end)
    elseif partType == 'suspension' then
        QBCore.Functions.Progressbar("dismantle_susp", "Desmontando amortiguadores de competición y muelles...", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 1,
        }, {}, {}, function()
            SetVehicleMod(veh, 15, -1, false)
            TriggerServerEvent('spain_mechanic:server:giveDismantledPart', { item = 'veh_suspension', label = 'Kit de Suspensión Deportiva' })
            TriggerServerEvent('spain_mechanic:server:saveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
            QBCore.Functions.Notify('Suspensión deportiva desmontada y recuperada.', 'success')
        end)
    elseif partType == 'armor' then
        QBCore.Functions.Progressbar("dismantle_armor", "Retirando placas de blindaje de acero del chasis...", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mini@repair",
            anim = "fixing_a_player",
            flags = 1,
        }, {}, {}, function()
            SetVehicleMod(veh, 16, -1, false)
            TriggerServerEvent('spain_mechanic:server:giveDismantledPart', { item = 'veh_armor', label = 'Kit de Blindaje Reforzado' })
            TriggerServerEvent('spain_mechanic:server:saveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
            QBCore.Functions.Notify('Blindaje desmontado con éxito.', 'success')
        end)
    end
end)

-- =========================================================================
-- 5. INSTALACIÓN DE PIEZAS DE RENDIMIENTO CON CHISPAS Y ANIMACIÓN REALISTA
-- =========================================================================
local modTypeMapping = {
    engine = { id = 11, label = "Kit de Motor Deportivo", animType = 'hood' },
    brakes = { id = 12, label = "Kit de Frenos de Alto Rendimiento", animType = 'wheel' },
    transmission = { id = 13, label = "Kit de Transmisión de Competición", animType = 'hood' },
    suspension = { id = 15, label = "Kit de Suspensión Deportiva", animType = 'wheel' },
    turbo = { id = 18, label = "Kit de Turbocompresor", animType = 'hood' },
    armor = { id = 16, label = "Kit de Blindaje Reforzado", animType = 'wheel' }
}

RegisterNetEvent('spain_mechanic:client:installPerformancePart', function(data)
    local partType = data.partType
    local targetItem = data.item or ('veh_' .. partType)
    local ped = PlayerPedId()
    local veh = data.veh or QBCore.Functions.GetClosestVehicle()

    if veh == 0 or #(GetEntityCoords(ped) - GetEntityCoords(veh)) > 4.0 then
        QBCore.Functions.Notify('Debes situarte junto al vehículo para instalar esta pieza.', 'error')
        return
    end

    if not IsMechanicOnDuty() then
        QBCore.Functions.Notify('Debes estar de servicio como mecánico (fichado) para instalar piezas de alto rendimiento.', 'error')
        return
    end

    local modInfo = modTypeMapping[partType]
    if not modInfo then return end

    SetVehicleModKit(veh, 0)
    local pCoords = GetEntityCoords(ped)

    -- Turbo
    if partType == 'turbo' then
        if IsToggleModOn(veh, 18) then
            QBCore.Functions.Notify('Este vehículo ya cuenta con un turbocompresor instalado.', 'error')
            return
        end

        SetVehicleDoorOpen(veh, 4, false, false)
        PlayWeldingSparks(pCoords, 6500)

        QBCore.Functions.Progressbar("install_turbo", "Montando turbocompresor e intercooler de alta presión...", 6500, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mini@repair",
            anim = "fixing_a_player",
            flags = 1,
        }, {
            model = "imp_prop_impexp_span_03",
            bone = 28422,
            coords = vec3(0.06, 0.01, -0.02),
            rotation = vec3(0.0, 0.0, 0.0),
        }, {}, function()
            ToggleVehicleMod(veh, 18, true)
            SetVehicleDoorShut(veh, 4, false)
            TriggerServerEvent('spain_mechanic:server:consumeItem', targetItem)
            TriggerServerEvent('spain_mechanic:server:saveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
            QBCore.Functions.Notify('Turbocompresor instalado con éxito. El motor entrega un +35% de potencia.', 'success')
        end, function()
            SetVehicleDoorShut(veh, 4, false)
            QBCore.Functions.Notify('Instalación cancelada.', 'error')
        end)
        return
    end

    -- Piezas escalonadas (Motor, Frenos, Transmisión, Suspensión, Blindaje)
    local currentMod = GetVehicleMod(veh, modInfo.id)
    local maxMods = GetNumVehicleMods(veh, modInfo.id)

    if maxMods <= 0 then
        QBCore.Functions.Notify('Este modelo de vehículo no admite modificaciones en esta categoría.', 'error')
        return
    end

    local nextMod = currentMod + 1
    if nextMod >= maxMods then
        QBCore.Functions.Notify('Esta pieza ya se encuentra al nivel máximo posible en este vehículo (' .. maxMods .. '/' .. maxMods .. ').', 'error')
        return
    end

    local animDict = "mini@repair"
    local animName = "fixing_a_player"
    if modInfo.animType == 'hood' then
        SetVehicleDoorOpen(veh, 4, false, false)
        PlayWeldingSparks(pCoords, 6500)
    else
        animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
        animName = "machinic_loop_mechandplayer"
    end

    QBCore.Functions.Progressbar("install_part", "Instalando " .. modInfo.label .. " (Nivel " .. (nextMod + 1) .. ")...", 6500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = animDict,
        anim = animName,
        flags = 1,
    }, {}, {}, function()
        SetVehicleMod(veh, modInfo.id, nextMod, false)
        if modInfo.animType == 'hood' then
            SetVehicleDoorShut(veh, 4, false)
        end
        TriggerServerEvent('spain_mechanic:server:consumeItem', targetItem)
        TriggerServerEvent('spain_mechanic:server:saveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
        QBCore.Functions.Notify('Has instalado con éxito: ' .. modInfo.label .. ' (Nivel ' .. (nextMod + 1) .. ' de ' .. maxMods .. ').', 'success')
    end, function()
        if modInfo.animType == 'hood' then
            SetVehicleDoorShut(veh, 4, false)
        end
        QBCore.Functions.Notify('Instalación cancelada.', 'error')
    end)
end)

-- Reparación Integral con Kit
RegisterNetEvent('spain_mechanic:client:useRepairKit', function(targetVeh)
    local ped = PlayerPedId()
    local veh = targetVeh or QBCore.Functions.GetClosestVehicle()

    if veh == 0 or #(GetEntityCoords(ped) - GetEntityCoords(veh)) > 4.0 then
        QBCore.Functions.Notify('Debes estar cerca de un vehículo para poder repararlo.', 'error')
        return
    end

    if not IsMechanicOnDuty() then
        QBCore.Functions.Notify('Debes estar de servicio como mecánico (fichado) para utilizar este kit profesional.', 'error')
        return
    end

    SetVehicleDoorOpen(veh, 4, false, false)
    PlayWeldingSparks(GetEntityCoords(ped), 7000)

    QBCore.Functions.Progressbar("mech_repairkit", "Reparando motor, chapa y mecánica del vehículo...", 7000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_player",
        flags = 1,
    }, {
        model = "imp_prop_impexp_span_03",
        bone = 28422,
        coords = vec3(0.06, 0.01, -0.02),
        rotation = vec3(0.0, 0.0, 0.0),
    }, {}, function()
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehicleBodyHealth(veh, 1000.0)
        SetVehicleFixed(veh)
        SetVehicleDeformationFixed(veh)
        SetVehicleUndriveable(veh, false)
        for i = 0, 7 do
            SetVehicleTyreFixed(veh, i)
        end
        SetVehicleDoorShut(veh, 4, false)

        TriggerServerEvent('spain_mechanic:server:consumeItem', 'repairkit')
        TriggerServerEvent('spain_mechanic:server:saveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
        QBCore.Functions.Notify('Vehículo reparado al 100% y listo para circular.', 'success')
    end, function()
        SetVehicleDoorShut(veh, 4, false)
        QBCore.Functions.Notify('Reparación cancelada.', 'error')
    end)
end)

-- Reparar neumáticos
RegisterNetEvent('spain_mechanic:client:fixTyres', function(data)
    local veh = data.veh or QBCore.Functions.GetClosestVehicle()
    if veh == 0 then return end

    QBCore.Functions.Progressbar("mech_tyres", "Sustituyendo neumático y equilibrando llanta...", 4500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        anim = "machinic_loop_mechandplayer",
        flags = 1,
    }, {}, {}, function()
        for i = 0, 7 do
            SetVehicleTyreFixed(veh, i)
        end
        TriggerServerEvent('spain_mechanic:server:consumeItem', 'tirerepairkit')
        QBCore.Functions.Notify('Neumáticos sustituidos correctamente.', 'success')
    end)
end)

-- =========================================================================
-- 6. INSPECCIÓN TÉCNICA GLOBAL CON ALT (qb-target AddGlobalVehicle)
-- =========================================================================
local function FormatModLevel(level, maxLevels, customLabels)
    if level == -1 then
        return "<span style='color:#a0a0a0;'>Stock / De Fábrica</span>"
    end
    if customLabels and customLabels[level] then
        return "<span style='color:#4caf50; font-weight:bold;'>" .. customLabels[level] .. "</span>"
    end
    return "<span style='color:#00d2d3; font-weight:bold;'>Nivel " .. (level + 1) .. " de " .. maxLevels .. "</span>"
end

local function InspectVehicleParts(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then
        QBCore.Functions.Notify('No se detecta ningún vehículo válido enfrente.', 'error')
        return
    end

    SetVehicleModKit(vehicle, 0)

    local plate = QBCore.Functions.GetPlate(vehicle) or GetVehicleNumberPlateText(vehicle)
    local modelHash = GetEntityModel(vehicle)
    local modelLabel = GetLabelText(GetDisplayNameFromVehicleModel(modelHash))
    if modelLabel == "NULL" then modelLabel = GetDisplayNameFromVehicleModel(modelHash) end

    local engineMod = GetVehicleMod(vehicle, 11)
    local maxEngine = GetNumVehicleMods(vehicle, 11)
    local engineText = FormatModLevel(engineMod, maxEngine)

    local brakesMod = GetVehicleMod(vehicle, 12)
    local maxBrakes = GetNumVehicleMods(vehicle, 12)
    local brakesText = FormatModLevel(brakesMod, maxBrakes)

    local transMod = GetVehicleMod(vehicle, 13)
    local maxTrans = GetNumVehicleMods(vehicle, 13)
    local transText = FormatModLevel(transMod, maxTrans)

    local suspMod = GetVehicleMod(vehicle, 15)
    local maxSusp = GetNumVehicleMods(vehicle, 15)
    local suspText = FormatModLevel(suspMod, maxSusp)

    local turboOn = IsToggleModOn(vehicle, 18)
    local turboText = turboOn and "<span style='color:#00ff88; font-weight:bold;'>✅ INSTALADO (+35% Potencia)</span>" or "<span style='color:#ff5252;'>❌ NO INSTALADO (Sin Turbo)</span>"

    local armorMod = GetVehicleMod(vehicle, 16)
    local maxArmor = GetNumVehicleMods(vehicle, 16)
    local armorText = FormatModLevel(armorMod, maxArmor)

    local engineHealth = math.floor(GetVehicleEngineHealth(vehicle) / 10)
    local bodyHealth = math.floor(GetVehicleBodyHealth(vehicle) / 10)

    local burstCount = 0
    for i = 0, 7 do
        if IsVehicleTyreBurst(vehicle, i, false) then
            burstCount = burstCount + 1
        end
    end

    local inspectionMenu = {
        {
            header = "🔍 Diagnóstico Integral: " .. modelLabel .. " [" .. plate .. "]",
            isMenuHeader = true
        },
        {
            header = "⚙️ Bloque de Motor",
            txt = "Mejora: " .. engineText .. " | Salud: " .. (engineHealth < 40 and "<span style='color:red;'>" or "<span style='color:green;'>") .. engineHealth .. "%</span>",
            isMenuHeader = true
        },
        {
            header = "🏎️ Caja de Transmisión",
            txt = "Mejora: " .. transText,
            isMenuHeader = true
        },
        {
            header = "🛑 Sistema de Frenos",
            txt = "Mejora: " .. brakesText,
            isMenuHeader = true
        },
        {
            header = "🛞 Suspensión y Amortiguadores",
            txt = "Mejora: " .. suspText,
            isMenuHeader = true
        },
        {
            header = "🌪️ Turbocompresor",
            txt = "Estado: " .. turboText,
            isMenuHeader = true
        },
        {
            header = "🛡️ Blindaje de Chasis",
            txt = "Mejora: " .. armorText,
            isMenuHeader = true
        },
        {
            header = "🚗 Chapa y Neumáticos",
            txt = "Carrocería: " .. bodyHealth .. "% | Neumáticos dañados: " .. (burstCount > 0 and "<span style='color:red;'>" .. burstCount .. " ruedas</span>" or "<span style='color:green;'>0 (Correcto)</span>"),
            isMenuHeader = true
        },
        {
            header = "🔧 Reparar Vehículo con Kit",
            txt = "Restaura el motor, chapa y ruedas al 100%",
            params = {
                event = "spain_mechanic:client:useRepairKit",
                args = vehicle
            }
        },
        {
            header = "🧼 Lavado y Detailing",
            txt = "Eliminar toda la suciedad acumulada del vehículo",
            params = {
                event = "spain_mechanic:client:cleanVehicle",
                args = { veh = vehicle }
            }
        },
        {
            header = "💶 Emitir Factura a Cliente",
            txt = "Cobrar presupuesto o servicio al cliente más próximo",
            params = {
                event = "spain_mechanic:client:billCustomer",
                args = {}
            }
        },
        {
            header = "❌ Cerrar Diagnóstico",
            params = {
                event = "qb-menu:client:closeMenu"
            }
        }
    }

    exports['qb-menu']:openMenu(inspectionMenu)
end

CreateThread(function()
    if GetResourceState('qb-target') == 'started' then
        exports['qb-target']:AddGlobalVehicle({
            options = {
                {
                    num = 1,
                    icon = 'fas fa-clipboard-list',
                    label = '📋 Ficha Técnica OEM del Automóvil',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        TriggerEvent('spain_mechanic:client:openVehicleDataSheet', entity)
                    end
                },
                {
                    num = 2,
                    icon = 'fas fa-magnifying-glass',
                    label = '🔍 Diagnóstico Integral del Vehículo',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        InspectVehicleParts(entity)
                    end
                },
                {
                    num = 3,
                    icon = 'fas fa-tablet-screen-button',
                    label = '📱 Tablet de Taller Mecánico',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        TriggerEvent('spain_mechanic:client:openTablet')
                    end
                },
                {
                    num = 4,
                    icon = 'fas fa-soap',
                    label = '🧼 Lavado y Detailing con Presión',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        TriggerEvent('spain_mechanic:client:cleanVehicle', { veh = entity })
                    end
                },
                {
                    num = 5,
                    icon = 'fas fa-receipt',
                    label = '💶 Facturar al Cliente Próximo',
                    canInteract = function(entity)
                        return IsMechanic()
                    end,
                    action = function(entity)
                        TriggerEvent('spain_mechanic:client:billCustomer')
                    end
                }
            },
            distance = 2.5
        })
    end
end)

-- =========================================================================
-- 7. SISTEMA DE FICHAR (PUNTO FÍSICO EN BENNY'S + TARGET + COMANDO)
-- =========================================================================
local bennysDeskCoords = vector3(-202.92, -1313.74, 31.70)

CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local dist = #(pCoords - bennysDeskCoords)

        if dist < 8.0 and IsMechanic() then
            wait = 0
            DrawMarker(20, bennysDeskCoords.x, bennysDeskCoords.y, bennysDeskCoords.z - 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 200, 255, 180, false, true, 2, false, nil, nil, false)

            if dist < 2.0 then
                local onDuty = IsMechanicOnDuty()
                local dutyText = onDuty and "~r~[E]~s~ Salir de Servicio" or "~g~[E]~s~ Fichar / Entrar de Servicio"
                QBCore.Functions.DrawText3D(bennysDeskCoords.x, bennysDeskCoords.y, bennysDeskCoords.z + 0.3, dutyText .. "  |  ~y~[G]~s~ Tablet R1 Mech")

                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent('spain_mechanic:server:toggleDuty')
                    Wait(500)
                elseif IsControlJustPressed(0, 47) then
                    TriggerEvent('spain_mechanic:client:openTablet')
                    Wait(500)
                end
            end
        end

        Wait(wait)
    end
end)

CreateThread(function()
    if GetResourceState('qb-target') == 'started' then
        exports['qb-target']:AddCircleZone('bennys_duty_counter', bennysDeskCoords, 1.2, {
            name = 'bennys_duty_counter',
            debugPoly = false,
            useZ = true
        }, {
            options = {
                {
                    type = 'client',
                    event = 'spain_mechanic:client:toggleDuty',
                    icon = 'fas fa-user-clock',
                    label = 'Fichar / Entrar o Salir de Servicio',
                    canInteract = function()
                        return IsMechanic()
                    end
                },
                {
                    type = 'client',
                    event = 'spain_mechanic:client:openTablet',
                    icon = 'fas fa-tablet-screen-button',
                    label = 'Abrir Tablet R1 Mech Pro',
                    canInteract = function()
                        return IsMechanic()
                    end
                }
            },
            distance = 2.5
        })
    end
end)

RegisterNetEvent('spain_mechanic:client:toggleDuty', function()
    TriggerServerEvent('spain_mechanic:server:toggleDuty')
end)

-- =========================================================================
-- 8. TABLET DE MECÁNICO "R1 MECH PRO" Y ALMACÉN DE PIEZAS FÍSICAS
-- =========================================================================
local function OpenItemOptionMenu(itemData)
    local optionMenu = {
        {
            header = "📦 Adquirir " .. itemData.label .. " (" .. itemData.price .. "€)",
            isMenuHeader = true
        },
        {
            header = "🚚 Pedido Logístico con Furgoneta de Taller (Recomendado)",
            txt = "Encarga el suministro: recoge el pedido en el puerto de Los Santos y almacénalo en el taller",
            params = {
                isServer = true,
                event = "spain_mechanic:server:orderLogisticsSupply",
                args = itemData
            }
        },
        {
            header = "🧰 Sacar en la Mano (Pieza Física para Montar Ya)",
            txt = "Despacha la pieza físicamente en tus manos para llevarla al coche ahora mismo",
            params = {
                isServer = true,
                event = "spain_mechanic:server:buyPhysicalPart",
                args = itemData
            }
        },
        {
            header = "🎒 Comprar y Guardar en Mochila (Inventario)",
            txt = "Guarda la pieza en tu inventario para usarla cuando quieras",
            params = {
                isServer = true,
                event = "spain_mechanic:server:buyItem",
                args = itemData
            }
        },
        {
            header = "⬅️ Volver al Catálogo",
            params = {
                event = "spain_mechanic:client:openCatalog"
            }
        }
    }
    exports['qb-menu']:openMenu(optionMenu)
end

RegisterNetEvent('spain_mechanic:client:openItemOptions', function(data)
    OpenItemOptionMenu(data)
end)

local function OpenMechanicCatalog()
    local catalogMenu = {
        {
            header = "🛒 Almacén de Piezas Físicas & Suministros (R1 MECH PRO)",
            isMenuHeader = true
        },
        {
            header = "⬅️ Volver a la Tablet Principal",
            params = {
                event = "spain_mechanic:client:openTablet"
            }
        },
        {
            header = "🏎️ Bloque de Motor Deportivo (850€)",
            txt = "Aumenta compresión, potencia y aceleración punta",
            params = {
                event = "spain_mechanic:client:openItemOptions",
                args = { item = "veh_engine", partType = "engine", price = 850, label = "Bloque de Motor Deportivo" }
            }
        },
        {
            header = "🌪️ Kit de Turbocompresor e Intercooler (1200€)",
            txt = "Sobrealimenta el vehículo con un +35% de aceleración inmediata",
            params = {
                event = "spain_mechanic:client:openItemOptions",
                args = { item = "veh_turbo", partType = "turbo", price = 1200, label = "Turbocompresor" }
            }
        },
        {
            header = "🛑 Kit de Pinzas y Pastillas de Freno (500€)",
            txt = "Frenada deportiva de alta eficacia y reducción de distancia",
            params = {
                event = "spain_mechanic:client:openItemOptions",
                args = { item = "veh_brakes", partType = "brakes", price = 500, label = "Kit de Frenos Deportivos" }
            }
        },
        {
            header = "🛞 Kit de Suspensión Deportiva Rebajada (400€)",
            txt = "Baja el centro de gravedad para un agarre extremo en curva",
            params = {
                event = "spain_mechanic:client:openItemOptions",
                args = { item = "veh_suspension", partType = "suspension", price = 400, label = "Kit de Suspensión" }
            }
        },
        {
            header = "⚙️ Kit de Transmisión de Competición (650€)",
            txt = "Cambios de marcha instantáneos sin pérdida de empuje",
            params = {
                event = "spain_mechanic:client:openItemOptions",
                args = { item = "veh_transmission", partType = "transmission", price = 650, label = "Kit de Transmisión" }
            }
        },
        {
            header = "🛞 Neumático de Competición / Repuesto (75€)",
            txt = "Neumático nuevo para sustituir ruedas reventadas",
            params = {
                event = "spain_mechanic:client:openItemOptions",
                args = { item = "tirerepairkit", partType = "tire", price = 75, label = "Neumático de Repuesto" }
            }
        },
        {
            header = "🛡️ Placas de Blindaje de Chasis (1500€)",
            txt = "Protección extra contra colisiones e impactos armados",
            params = {
                event = "spain_mechanic:client:openItemOptions",
                args = { item = "veh_armor", partType = "armor", price = 1500, label = "Blindaje de Chasis" }
            }
        },
        {
            header = "🔧 Kit de Reparación de Taller (150€)",
            txt = "Herramientas de reparación integral para motor y chapa",
            params = {
                event = "spain_mechanic:client:openItemOptions",
                args = { item = "repairkit", partType = "repairkit", price = 150, label = "Kit de Reparación" }
            }
        },
        {
            header = "🧼 Kit de Detailing y Lavado (50€)",
            txt = "Espuma activa y bayetas para dejar el vehículo reluciente",
            params = {
                event = "spain_mechanic:client:openItemOptions",
                args = { item = "cleaningkit", partType = "repairkit", price = 50, label = "Kit de Limpieza" }
            }
        },
        {
            header = "📲 Tablet R1 Mech Pro de Repuesto (100€)",
            txt = "Terminal portátil de taller para llevar en el inventario",
            params = {
                event = "spain_mechanic:client:openItemOptions",
                args = { item = "mechanic_tablet", partType = "repairkit", price = 100, label = "Tablet R1 Mech Pro" }
            }
        }
    }

    exports['qb-menu']:openMenu(catalogMenu)
end

-- =========================================================================
-- 6. TERMINAL PORTÁTIL DE MECÁNICO & FICHAJE DESDE CUALQUIER LUGAR
-- =========================================================================
local function OpenMechanicTablet()
    if not IsMechanic() then
        QBCore.Functions.Notify('Solo personal de talleres mecánicos autorizados puede usar esta tablet.', 'error')
        return
    end

    local playerJob = (PlayerData and PlayerData.job) or QBCore.Functions.GetPlayerData().job
    local onDuty = IsMechanicOnDuty()
    local isBoss = playerJob and playerJob.isboss == true

    local shopName = (playerJob and playerJob.label) or "Taller Mecánico"
    local gradeName = (playerJob and playerJob.grade and playerJob.grade.name) or "Mecánico"

    if not onDuty then
        local offDutyMenu = {
            {
                header = "📲 R1 MECH PRO - " .. shopName,
                txt = "Mecánico: " .. gradeName .. " | [🔴 FUERA DE SERVICIO]",
                isMenuHeader = true
            },
            {
                header = "⏱️ Fichar / Entrar de Servicio (Desde donde sea)",
                txt = "Pulsa aquí para iniciar tu turno en " .. shopName .. ". Podrás despachar piezas físicas, diagnosticar y cobrar.",
                params = {
                    event = "spain_mechanic:client:toggleDuty"
                }
            },
            {
                header = "❌ Guardar Tablet",
                params = {
                    event = "qb-menu:client:closeMenu"
                }
            }
        }
        exports['qb-menu']:openMenu(offDutyMenu)
        return
    end

    local mainTabletMenu = {
        {
            header = "📲 R1 MECH PRO - " .. shopName,
            txt = "Mecánico: " .. gradeName .. " | [🟢 DE SERVICIO]",
            isMenuHeader = true
        },
        {
            header = "⏱️ Fichar: Estado Actual [🟢 EN SERVICIO]",
            txt = "Pulsa aquí para salir de servicio desde donde estés al terminar tu jornada",
            params = {
                event = "spain_mechanic:client:toggleDuty"
            }
        },
        {
            header = "🛒 Almacén de Piezas Físicas & Suministros",
            txt = "Saca piezas físicas en la mano (bloques motor, turbo, ruedas, frenos) o guárdalas",
            params = {
                event = "spain_mechanic:client:openCatalog"
            }
        },
        {
            header = "🔍 Diagnóstico Técnico del Coche Próximo",
            txt = "Escaneo visual de componentes, desgaste y mejoras",
            params = {
                event = "spain_mechanic:client:inspectClosest"
            }
        },
        {
            header = "🧼 Lavado y Detailing Profesional",
            txt = "Limpieza con manguera a presión y encerado",
            params = {
                event = "spain_mechanic:client:cleanClosest"
            }
        },
        {
            header = "🗄️ Abrir Estanterías / Almacén del Taller",
            txt = "Accede a las piezas y suministros almacenados en tu taller",
            params = {
                isServer = true,
                event = "spain_mechanic:server:openWorkshopStash"
            }
        },
        {
            header = "💶 Emitir Factura a Cliente Cercano",
            txt = "Genera un cobro directo con split (70% mecánico, 30% taller)",
            params = {
                event = "spain_mechanic:client:billCustomer"
            }
        }
    }

    if isBoss then
        mainTabletMenu[#mainTabletMenu + 1] = {
            header = "👔 Despacho de Gerencia / Empleados (Solo Dueño)",
            txt = "Contratar empleados, despedir, ascender de rango y almacén de empresa",
            params = {
                event = "qb-bossmenu:client:OpenMenu"
            }
        }
    end

    mainTabletMenu[#mainTabletMenu + 1] = {
        header = "❌ Guardar Tablet",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    }

    exports['qb-menu']:openMenu(mainTabletMenu)
end

-- =========================================================================
-- 9. SISTEMA DE LOGÍSTICA, TRANSPORTE EN FURGONETA Y DESCARGA EN ESTANTERÍAS
-- =========================================================================
local workshopLogistics = {
    bennys = {
        name = "Benny's Original Motor Works",
        vanSpawn = vector3(-217.15, -1304.30, 31.30),
        vanHeading = 180.0,
        shelves = vector3(-202.92, -1313.74, 31.30)
    },
    mechanic = {
        name = "Los Santos Customs (Centro)",
        vanSpawn = vector3(-363.0, -119.5, 38.7),
        vanHeading = 70.0,
        shelves = vector3(-342.50, -138.80, 39.01)
    },
    mechanic2 = {
        name = "Taller Harmony Repair",
        vanSpawn = vector3(1196.2, 2646.8, 37.8),
        vanHeading = 0.0,
        shelves = vector3(1182.20, 2639.80, 38.40)
    },
    mechanic3 = {
        name = "Los Santos Customs Sur (Aeropuerto)",
        vanSpawn = vector3(-1160.0, -2005.0, 13.0),
        vanHeading = 135.0,
        shelves = vector3(-1142.30, -1994.50, 13.18)
    },
    beeker = {
        name = "Beeker's Garage (Paleto Bay)",
        vanSpawn = vector3(118.5, 6618.2, 31.5),
        vanHeading = 225.0,
        shelves = vector3(104.20, 6627.80, 31.79)
    }
}

local centralDistributionDepot = vector3(893.2, -3105.8, 5.9)
local currentMission = nil
local missionBlip = nil

local function ClearMissionBlip()
    if missionBlip and DoesBlipExist(missionBlip) then
        RemoveBlip(missionBlip)
        missionBlip = nil
    end
end

local function SetMissionBlip(coords, label, sprite, color)
    ClearMissionBlip()
    missionBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(missionBlip, sprite or 1)
    SetBlipDisplay(missionBlip, 4)
    SetBlipScale(missionBlip, 0.85)
    SetBlipColour(missionBlip, color or 5)
    SetBlipRoute(missionBlip, true)
    SetBlipRouteColour(missionBlip, color or 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(label or "Misión de Taller")
    EndTextCommandSetBlipName(missionBlip)
end

RegisterNetEvent('spain_mechanic:client:startLogisticsMission', function(orderData)
    local jobName = (PlayerData and PlayerData.job and PlayerData.job.name) or "mechanic"
    local shop = workshopLogistics[jobName] or workshopLogistics['mechanic']

    currentMission = {
        state = 'GET_VAN',
        order = orderData,
        shop = shop,
        jobName = jobName,
        vanEntity = nil,
        isCarryingSupplyBox = false,
        supplyBoxProp = nil
    }

    SetMissionBlip(shop.vanSpawn, "🚐 Furgoneta de Taller: " .. shop.name, 477, 5)
    QBCore.Functions.Notify("📦 Pedido tramitado. Dirígete al punto exterior de furgonetas de tu taller marcado en tu mapa.", "success", 6000)
end)

RegisterNetEvent('spain_mechanic:client:orderDeliveredSuccess', function()
    ClearMissionBlip()
    currentMission = nil
end)

CreateThread(function()
    while true do
        local wait = 1000
        local pPed = PlayerPedId()
        local pCoords = GetEntityCoords(pPed)

        -- 1. Punto de Estanterías / Almacén del taller (Siempre activo para mecánicos de servicio)
        for jobKey, shop in pairs(workshopLogistics) do
            local sDist = #(pCoords - shop.shelves)
            if sDist < 12.0 then
                wait = 0
                DrawMarker(2, shop.shelves.x, shop.shelves.y, shop.shelves.z + 0.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.35, 0.35, 0.25, 0, 204, 255, 180, false, false, 2, true, nil, nil, false)
                if sDist < 2.0 then
                    if currentMission and currentMission.isCarryingSupplyBox then
                        QBCore.Functions.DrawText3D(shop.shelves.x, shop.shelves.y, shop.shelves.z + 0.5, "~g~[E]~s~ Colocar Caja en Estanterías del Taller")
                        if IsControlJustPressed(0, 38) then -- Tecla E
                            TaskPlayAnim(pPed, "anim@heists@box_carry@", "putdown", 3.0, -8, -1, 49, 0, 0, 0, 0)
                            QBCore.Functions.Progressbar("mech_put_crate", "Colocando caja de repuestos en las estanterías...", 3000, false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {}, {}, {}, function()
                                if currentMission and currentMission.supplyBoxProp and DoesEntityExist(currentMission.supplyBoxProp) then
                                    DeleteEntity(currentMission.supplyBoxProp)
                                    currentMission.supplyBoxProp = nil
                                end
                                if currentMission then
                                    currentMission.isCarryingSupplyBox = false
                                end
                                ClearPedTasks(pPed)
                                TriggerServerEvent('spain_mechanic:server:completeSupplyDelivery')
                            end)
                        end
                    else
                        QBCore.Functions.DrawText3D(shop.shelves.x, shop.shelves.y, shop.shelves.z + 0.5, "~y~[E]~s~ Almacén / Estanterías del Taller")
                        if IsControlJustPressed(0, 38) then -- Tecla E
                            TriggerServerEvent('spain_mechanic:server:openWorkshopStash')
                        end
                    end
                end
            end
        end

        -- 2. Lógica de la Misión Logística
        if currentMission then
            -- FASE A: Sacar la Furgoneta en el taller
            if currentMission.state == 'GET_VAN' then
                local vDist = #(pCoords - currentMission.shop.vanSpawn)
                if vDist < 20.0 then
                    wait = 0
                    DrawMarker(36, currentMission.shop.vanSpawn.x, currentMission.shop.vanSpawn.y, currentMission.shop.vanSpawn.z + 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.6, 1.6, 1.0, 255, 204, 0, 180, false, false, 2, true, nil, nil, false)
                    if vDist < 2.5 then
                        QBCore.Functions.DrawText3D(currentMission.shop.vanSpawn.x, currentMission.shop.vanSpawn.y, currentMission.shop.vanSpawn.z + 1.2, "~y~[E]~s~ Sacar Furgoneta de Taller (Reparto)")
                        if IsControlJustPressed(0, 38) then -- Tecla E
                            local model = `speedo`
                            RequestModel(model)
                            while not HasModelLoaded(model) do Wait(10) end
                            local veh = CreateVehicle(model, currentMission.shop.vanSpawn.x, currentMission.shop.vanSpawn.y, currentMission.shop.vanSpawn.z, currentMission.shop.vanHeading, true, false)
                            SetVehicleNumberPlateText(veh, "MECH" .. math.random(100, 999))
                            SetVehicleColours(veh, 111, 0)
                            SetEntityAsMissionEntity(veh, true, true)
                            TaskWarpPedIntoVehicle(pPed, veh, -1)
                            SetVehicleEngineOn(veh, true, true, false)
                            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))

                            currentMission.vanEntity = veh
                            currentMission.state = 'GO_TO_DEPOT'
                            SetMissionBlip(centralDistributionDepot, "📦 Centro de Distribución de Repuestos", 478, 5)
                            QBCore.Functions.Notify("🚚 Furgoneta lista. Conduce hacia el Centro de Distribución en los muelles de Los Santos (marcado en amarillo).", "success", 6000)
                        end
                    end
                end

            -- FASE B: Cargar en el Centro de Distribución
            elseif currentMission.state == 'GO_TO_DEPOT' then
                local dDist = #(pCoords - centralDistributionDepot)
                if dDist < 30.0 then
                    wait = 0
                    DrawMarker(1, centralDistributionDepot.x, centralDistributionDepot.y, centralDistributionDepot.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 1.5, 255, 204, 0, 150, false, false, 2, false, nil, nil, false)
                    if dDist < 5.0 then
                        QBCore.Functions.DrawText3D(centralDistributionDepot.x, centralDistributionDepot.y, centralDistributionDepot.z + 0.8, "~y~[E]~s~ Cargar Mercancía en la Furgoneta")
                        if IsControlJustPressed(0, 38) then -- Tecla E
                            local veh = currentMission.vanEntity
                            if DoesEntityExist(veh) and #(GetEntityCoords(veh) - centralDistributionDepot) < 25.0 then
                                SetVehicleDoorOpen(veh, 2, false, false)
                                SetVehicleDoorOpen(veh, 3, false, false)
                                QBCore.Functions.Progressbar("load_parts", "Cargando cajas de repuestos en la furgoneta...", 5000, false, true, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {
                                    animDict = "anim@heists@box_carry@",
                                    anim = "idle",
                                    flags = 49,
                                }, {}, {}, function()
                                    SetVehicleDoorShut(veh, 2, false)
                                    SetVehicleDoorShut(veh, 3, false)
                                    currentMission.state = 'RETURN_SHOP'
                                    SetMissionBlip(currentMission.shop.vanSpawn, "🏢 Tu Taller: " .. currentMission.shop.name, 446, 5)
                                    QBCore.Functions.Notify("📦 Mercancía asegurada en la furgoneta. Regresa a tu taller para descargarla.", "success", 6000)
                                end)
                            else
                                QBCore.Functions.Notify("Aparca la furgoneta de la empresa cerca del muelle de carga.", "error")
                            end
                        end
                    end
                end

            -- FASE C: Llegada al Taller y Descarga Manual
            elseif currentMission.state == 'RETURN_SHOP' then
                local sDist = #(pCoords - currentMission.shop.vanSpawn)
                if sDist < 35.0 then
                    currentMission.state = 'UNLOAD_BOX'
                    SetMissionBlip(currentMission.shop.shelves, "📦 Almacén del Taller (Descargar)", 501, 2)
                    QBCore.Functions.Notify("Has llegado al taller. Ve a las puertas traseras de la furgoneta para bajar la caja de repuestos en tus manos.", "primary", 6000)
                end

            -- FASE D: Bajar la Caja de la Furgoneta
            elseif currentMission.state == 'UNLOAD_BOX' then
                local veh = currentMission.vanEntity
                if DoesEntityExist(veh) then
                    local bootPos = GetOffsetFromEntityInWorldCoords(veh, 0.0, -2.5, 0.0)
                    local bDist = #(pCoords - bootPos)
                    if bDist < 2.5 and not currentMission.isCarryingSupplyBox then
                        wait = 0
                        QBCore.Functions.DrawText3D(bootPos.x, bootPos.y, bootPos.z + 0.5, "~y~[E]~s~ Bajar Caja de Piezas Físicas")
                        if IsControlJustPressed(0, 38) then -- Tecla E
                            SetVehicleDoorOpen(veh, 2, false, false)
                            SetVehicleDoorOpen(veh, 3, false, false)
                            QBCore.Functions.Progressbar("unload_box", "Bajando caja pesada del maletero...", 2500, false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {}, {}, {}, function()
                                SetVehicleDoorShut(veh, 2, false)
                                SetVehicleDoorShut(veh, 3, false)

                                local pModel = `imp_prop_impexp_box_wood01`
                                RequestModel(pModel)
                                while not HasModelLoaded(pModel) do Wait(10) end
                                local prop = CreateObject(pModel, pCoords.x, pCoords.y, pCoords.z, true, true, true)
                                AttachEntityToEntity(prop, pPed, GetPedBoneIndex(pPed, 60309), 0.05, 0.28, 0.0, -75.0, 0.0, 0.0, true, true, false, true, 1, true)

                                RequestAnimDict("anim@heists@box_carry@")
                                while not HasAnimDictLoaded("anim@heists@box_carry@") do Wait(10) end
                                TaskPlayAnim(pPed, "anim@heists@box_carry@", "idle", 3.0, -8, -1, 49, 0, 0, 0, 0)

                                currentMission.isCarryingSupplyBox = true
                                currentMission.supplyBoxProp = prop
                                currentMission.state = 'STORE_BOX'
                                QBCore.Functions.Notify("Lleva la caja dentro del taller y colócala en las estanterías de almacenamiento.", "success", 5000)
                            end)
                        end
                    end
                end

            -- FASE E: Llevando la caja hacia el almacén
            elseif currentMission.state == 'STORE_BOX' and currentMission.isCarryingSupplyBox then
                wait = 0
                if not IsEntityPlayingAnim(pPed, "anim@heists@box_carry@", "idle", 3) then
                    TaskPlayAnim(pPed, "anim@heists@box_carry@", "idle", 3.0, -8, -1, 49, 0, 0, 0, 0)
                end

                BeginTextCommandDisplayText('STRING')
                AddTextComponentSubstringPlayerName("~y~Llevando:~s~ Caja de Suministros  |  Llévala a las ~g~Estanterías del Taller~s~ [E]")
                SetTextFont(0)
                SetTextScale(0.35, 0.35)
                SetTextColour(255, 255, 255, 255)
                SetTextEntry('STRING')
                SetTextCentre(true)
                EndTextCommandDisplayText(0.5, 0.92)
            end

            -- Opción de Guardar Furgoneta si ya no se necesita
            if DoesEntityExist(currentMission.vanEntity) and not currentMission.isCarryingSupplyBox then
                local vDist = #(pCoords - currentMission.shop.vanSpawn)
                if vDist < 5.0 and IsPedInVehicle(pPed, currentMission.vanEntity, false) then
                    wait = 0
                    QBCore.Functions.DrawText3D(currentMission.shop.vanSpawn.x, currentMission.shop.vanSpawn.y, currentMission.shop.vanSpawn.z + 1.2, "~r~[E]~s~ Guardar Furgoneta de Empresa")
                    if IsControlJustPressed(0, 38) then
                        DeleteVehicle(currentMission.vanEntity)
                        currentMission.vanEntity = nil
                        QBCore.Functions.Notify("Furgoneta de empresa guardada.", "primary")
                    end
                end
            end
        end

        Wait(wait)
    end
end)

-- Comando directo en cliente para fichar desde cualquier lugar
RegisterCommand('fichar', function()
    if IsMechanic() then
        TriggerServerEvent('spain_mechanic:server:toggleDuty')
    else
        QBCore.Functions.Notify("No perteneces a ningún taller mecánico registrado.", "error")
    end
end, false)

RegisterKeyMapping('fichar', 'Fichar / Entrar o Salir de Servicio Mecánico', 'keyboard', '')

-- Eventos vinculados
RegisterNetEvent('spain_mechanic:client:toggleDuty', function()
    TriggerServerEvent('spain_mechanic:server:toggleDuty')
end)

RegisterNetEvent('spain_mechanic:client:openTablet', function()
    OpenMechanicTablet()
end)

RegisterNetEvent('spain_mechanic:client:openCatalog', function()
    OpenMechanicCatalog()
end)

RegisterNetEvent('spain_mechanic:client:inspectClosest', function()
    local ped = PlayerPedId()
    local veh = QBCore.Functions.GetClosestVehicle()
    if veh ~= 0 and #(GetEntityCoords(ped) - GetEntityCoords(veh)) <= 5.0 then
        InspectVehicleParts(veh)
    else
        QBCore.Functions.Notify('No hay ningún vehículo próximo para inspeccionar.', 'error')
    end
end)

RegisterNetEvent('spain_mechanic:client:cleanClosest', function()
    local ped = PlayerPedId()
    local veh = QBCore.Functions.GetClosestVehicle()
    if veh ~= 0 and #(GetEntityCoords(ped) - GetEntityCoords(veh)) <= 5.0 then
        TriggerEvent('spain_mechanic:client:cleanVehicle', { veh = veh })
    else
        QBCore.Functions.Notify('No hay ningún vehículo próximo para limpiar.', 'error')
    end
end)

RegisterNetEvent('spain_mechanic:client:cleanVehicle', function(data)
    local veh = data.veh or QBCore.Functions.GetClosestVehicle()
    if veh == 0 then return end

    QBCore.Functions.Progressbar("mech_clean", "Limpieza con pistola a presión y encerado...", 4000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        SetVehicleDirtLevel(veh, 0.0)
        QBCore.Functions.Notify('Vehículo limpio y reluciente.', 'success')
    end)
end)

RegisterNetEvent('spain_mechanic:client:billCustomer', function()
    local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.5 then
        local targetServerId = GetPlayerServerId(closestPlayer)

        if GetResourceState('qb-input') == 'started' then
            local dialog = exports['qb-input']:ShowInput({
                header = "Factura de Taller Mecánico",
                submitText = "Enviar Cobro",
                inputs = {
                    {
                        text = "Importe a facturar (€)",
                        name = "amount",
                        type = "number",
                        isRequired = true,
                        default = 250
                    }
                }
            })
            if dialog and dialog.amount then
                TriggerServerEvent('spain_mechanic:server:sendBill', targetServerId, tonumber(dialog.amount))
            end
        else
            TriggerServerEvent('spain_mechanic:server:sendBill', targetServerId, 250)
        end
    else
        QBCore.Functions.Notify('No hay ningún cliente cerca para facturar.', 'error')
    end
end)

