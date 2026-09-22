-- =========================================================================
-- SPAIN ROL - RED DE NPCS INTERACTIVOS (DEPENDIENTES Y TRABAJADORES)
-- =========================================================================
-- Genera dependientes en todas las armerías, badulakes, hospitales y talleres.
-- Los sitúa detrás del mostrador con animación inmersiva y menú accesible con [E].

local QBCore = exports['qb-core']:GetCoreObject()
local spawnedPeds = {}

local npcList = {
    -- ARMERO AMMU-NATION (Plaza Legion)
    {
        model = `s_m_y_ammucity_01`,
        coords = vector4(22.58, -1105.47, 29.8, 160.0),
        scenario = 'WORLD_HUMAN_COP_IDLES',
        type = 'armory',
        text = '~r~[E]~s~ Hablar con Armero (Comprar Armamento)'
    },
    -- ARMERO AMMU-NATION (Vinewood)
    {
        model = `s_m_y_ammucity_01`,
        coords = vector4(253.94, -48.25, 69.94, 70.0),
        scenario = 'WORLD_HUMAN_COP_IDLES',
        type = 'armory',
        text = '~r~[E]~s~ Hablar con Armero (Comprar Armamento)'
    },
    -- ARMERO AMMU-NATION (Sandy Shores)
    {
        model = `s_m_y_ammucity_01`,
        coords = vector4(1692.62, 3760.91, 34.71, 226.0),
        scenario = 'WORLD_HUMAN_COP_IDLES',
        type = 'armory',
        text = '~r~[E]~s~ Hablar con Armero (Comprar Armamento)'
    },
    -- ARMERO AMMU-NATION (Paleto Bay)
    {
        model = `s_m_y_ammucity_01`,
        coords = vector4(-331.62, 6083.74, 31.45, 225.0),
        scenario = 'WORLD_HUMAN_COP_IDLES',
        type = 'armory',
        text = '~r~[E]~s~ Hablar con Armero (Comprar Armamento)'
    },
    -- DEPENDIENTE BADULAKE 24/7 (Plaza Legion / Innocence Blvd)
    {
        model = `mp_m_shopkeep_01`,
        coords = vector4(26.68, -1347.16, 29.5, 270.0),
        scenario = 'WORLD_HUMAN_STAND_IMPARTIAL',
        type = 'badulake',
        text = '~g~[E]~s~ Comprar en Badulake 24/7'
    },
    -- DEPENDIENTE BADULAKE (Clinton Ave / Downtown)
    {
        model = `mp_m_shopkeep_01`,
        coords = vector4(373.87, 325.86, 103.57, 255.0),
        scenario = 'WORLD_HUMAN_STAND_IMPARTIAL',
        type = 'badulake',
        text = '~g~[E]~s~ Comprar en Badulake 24/7'
    },
    -- DEPENDIENTE BADULAKE (Grove Street)
    {
        model = `mp_m_shopkeep_01`,
        coords = vector4(-48.42, -1757.93, 29.42, 50.0),
        scenario = 'WORLD_HUMAN_STAND_IMPARTIAL',
        type = 'badulake',
        text = '~g~[E]~s~ Comprar en Badulake 24/7'
    },
    -- DEPENDIENTE BADULAKE (Sandy Shores)
    {
        model = `mp_m_shopkeep_01`,
        coords = vector4(1960.94, 3740.91, 32.34, 300.0),
        scenario = 'WORLD_HUMAN_STAND_IMPARTIAL',
        type = 'badulake',
        text = '~g~[E]~s~ Comprar en Badulake 24/7'
    },
    -- RECEPCIONISTA HOSPITAL CENTRAL (Pillbox Hill)
    {
        model = `s_m_m_doctor_01`,
        coords = vector4(308.57, -595.27, 43.28, 25.0),
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        type = 'hospital_reception',
        text = '~b~[E]~s~ Consulta Médica / Ingreso Hospitalario'
    },
    -- JEFE MECÁNICO BENNY'S
    {
        model = `s_m_m_autoshop_01`,
        coords = vector4(-205.51, -1310.22, 31.3, 180.0),
        scenario = 'WORLD_HUMAN_WELDING',
        type = 'mechanic_boss',
        text = '~y~[E]~s~ Hablar con Jefe de Taller'
    }
}

-- Función para cargar modelos de manera segura
local function LoadModel(model)
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end
end

-- Spawn de todos los NPCs interactivos
CreateThread(function()
    for i, data in ipairs(npcList) do
        LoadModel(data.model)
        local ped = CreatePed(4, data.model, data.coords.x, data.coords.y, data.coords.z - 1.0, data.coords.w, false, true)
        SetEntityAsMissionEntity(ped, true, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        TaskStartScenarioInPlace(ped, data.scenario, 0, true)
        spawnedPeds[#spawnedPeds + 1] = {
            entity = ped,
            coords = vector3(data.coords.x, data.coords.y, data.coords.z),
            type = data.type,
            text = data.text
        }
    end
end)

-- Bucle de proximidad e interacción con tecla [E]
CreateThread(function()
    while true do
        local wait = 1000
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)

        for _, npc in ipairs(spawnedPeds) do
            local dist = #(pCoords - npc.coords)
            if dist < 2.5 then
                wait = 0
                QBCore.Functions.DrawText3D(npc.coords.x, npc.coords.y, npc.coords.z + 1.0, npc.text)
                
                if IsControlJustPressed(0, 38) then -- Tecla E
                    if npc.type == 'armory' then
                        TriggerEvent('qb-shops:client:openShop', 'weapons')
                    elseif npc.type == 'badulake' then
                        TriggerEvent('qb-shops:client:openShop', 'normal')
                    elseif npc.type == 'hospital_reception' then
                        TriggerEvent('hospital:client:CheckIn')
                    elseif npc.type == 'mechanic_boss' then
                        TriggerEvent('spain_mechanic:client:openTablet')
                    end
                end
            end
        end

        Wait(wait)
    end
end)

-- Limpieza al reiniciar recurso
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for _, npc in ipairs(spawnedPeds) do
            if DoesEntityExist(npc.entity) then
                DeleteEntity(npc.entity)
            end
        end
    end
end)
