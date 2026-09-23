-- =========================================================================
-- SPAIN ROL - CARGADOR DE INTERIORES (IPLS) Y PROTECCIÓN ANTI-VACÍO
-- =========================================================================
-- Soluciona el problema de que los jugadores se caigan al vacío al entrar
-- al Concesionario Central (PDM / Simeon), Hospital o Talleres.

local QBCore = exports['qb-core']:GetCoreObject()

-- Función central para cargar y fijar los interiores en memoria
local function LoadAllMapIpls()
    -- 1. CONCESIONARIO CENTRAL (PDM / Premium Deluxe Motorsport - Simeon)
    RequestIpl("shr_int")
    RequestIpl("shutter_open")
    RemoveIpl("shutter_closed")
    RequestIpl("csr_beforeMission")
    RemoveIpl("csr_afterMissionA")
    RemoveIpl("csr_afterMissionB")
    RemoveIpl("csr_inMission")

    local pdmInterior = GetInteriorAtCoords(-45.67, -1098.34, 26.42)
    if IsValidInterior(pdmInterior) then
        PinInteriorInMemory(pdmInterior)
        EnableInteriorProp(pdmInterior, "csr_beforeMission")
        EnableInteriorProp(pdmInterior, "shutter_open")
        DisableInteriorProp(pdmInterior, "shutter_closed")
        RefreshInterior(pdmInterior)
    end

    -- Forzar colisión del suelo de PDM
    RequestCollisionAtCoord(-45.67, -1098.34, 26.42)

    -- 2. HOSPITAL CENTRAL (Pillbox Hill)
    RequestIpl("rc12b_default")
    RequestIpl("rc12b_hospitalinterior")
    RequestIpl("rc12b_hospitalinterior_strm")
    local hospitalInterior = GetInteriorAtCoords(308.57, -595.27, 43.28)
    if IsValidInterior(hospitalInterior) then
        PinInteriorInMemory(hospitalInterior)
        RefreshInterior(hospitalInterior)
    end

    -- 3. TALLER MECÁNICO BENNY'S ORIGINAL MOTORWORKS
    RequestIpl("shutter_open")
    local bennyInterior = GetInteriorAtCoords(-205.51, -1310.22, 31.3)
    if IsValidInterior(bennyInterior) then
        PinInteriorInMemory(bennyInterior)
        RefreshInterior(bennyInterior)
    end

    -- 4. CASINO & AMMU-NATIONS
    RequestIpl("hei_dlc_windows_casino")
    RequestIpl("hei_dlc_casino_aircon")
end

-- Cargar inmediatamente al iniciar el recurso
CreateThread(function()
    LoadAllMapIpls()
end)

-- Cargar cuando el jugador se conecta o regenera su personaje
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    LoadAllMapIpls()
end)

-- Hilo de refuerzo por proximidad al Concesionario
CreateThread(function()
    local pdmCoords = vector3(-45.67, -1098.34, 26.42)
    while true do
        local wait = 2500
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local dist = #(pCoords - pdmCoords)

        if dist < 80.0 then
            wait = 1000
            -- Si el jugador se aproxima al concesionario, aseguramos la colisión del suelo
            if not IsIplActive("shr_int") then
                RequestIpl("shr_int")
                RequestIpl("shutter_open")
                RemoveIpl("shutter_closed")
                local pdmInterior = GetInteriorAtCoords(pdmCoords.x, pdmCoords.y, pdmCoords.z)
                if IsValidInterior(pdmInterior) then
                    PinInteriorInMemory(pdmInterior)
                    RefreshInterior(pdmInterior)
                end
            end
            RequestCollisionAtCoord(pdmCoords.x, pdmCoords.y, pdmCoords.z)

            -- PROTECCIÓN ANTI-CAÍDA AL VACÍO EN EL CONCESIONARIO
            -- Si el jugador atraviesa el suelo y cae por debajo de Z = 15.0 estando en PDM
            if pCoords.z < 15.0 and dist < 45.0 then
                ClearPedTasksImmediately(ped)
                SetEntityCoords(ped, -44.0, -1082.0, 26.7, false, false, false, true)
                SetEntityHeading(ped, 70.0)
                RequestCollisionAtCoord(-44.0, -1082.0, 26.7)
                LoadAllMapIpls()
                TriggerEvent('QBCore:Notify', "Has sido rescatado del vacío y devuelto a la entrada del concesionario.", "primary", 5000)
            end
        end

        Wait(wait)
    end
end)

-- Protección global contra caídas al vacío bajo el mapa
CreateThread(function()
    while true do
        Wait(3000)
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)

        -- Si el jugador cae por debajo del nivel del mar (-30.0) en cualquier punto
        if pCoords.z < -30.0 and not IsPedInAnyVehicle(ped, false) then
            local safeGround, groundZ = GetGroundZFor_3dCoord(pCoords.x, pCoords.y, 100.0, false)
            if safeGround and groundZ > 0.0 then
                SetEntityCoords(ped, pCoords.x, pCoords.y, groundZ + 1.0, false, false, false, true)
            else
                -- Teletransporte de seguridad a la Plaza Legion
                SetEntityCoords(ped, 195.0, -934.0, 30.7, false, false, false, true)
            end
            TriggerEvent('QBCore:Notify', "Sistema de seguridad: Se ha corregido tu posición para evitar caer al vacío.", "primary", 6000)
        end
    end
end)
