-- =========================================================================
-- SPAIN ROL - SERVIDOR: GESTIÓN DE EMPLEOS Y ORIENTACIÓN LABORAL
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()

-- Lista blanca de empleos públicos permitidos para selección libre
local AllowedPublicJobs = {
    ['trucker'] = true,
    ['delivery'] = true,
    ['bus'] = true,
    ['pizza'] = true,
    ['taxi'] = true,
    ['tow'] = true,
    ['garbage'] = true,
    ['windowcleaner'] = true,
    ['miner'] = true,
    ['lumberjack'] = true,
    ['electrician'] = true,
    ['security'] = true,
    ['fisherman'] = true,
    ['farmer'] = true,
    ['diver'] = true,
    ['gardener'] = true,
    ['hotdog'] = true,
    ['waiter'] = true,
    ['reporter'] = true,
    -- Trabajos exclusivos / inventados Spain Rol
    ['cards_courier'] = true,
    ['vintage_picker'] = true,
    ['content_creator'] = true,
    ['wildlife_ranger'] = true,
    ['wine_sommelier'] = true,
    ['food_critic'] = true
}

-- Evento para firmar contrato y cambiar de trabajo
RegisterNetEvent('spain_jobs:server:selectJob', function(jobId, jobLabel, locationName, coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not AllowedPublicJobs[jobId] then
        TriggerClientEvent('QBCore:Notify', src, "Este puesto de trabajo no está disponible para contratación directa.", "error")
        return
    end

    if not QBCore.Shared.Jobs[jobId] then
        TriggerClientEvent('QBCore:Notify', src, "El oficio solicitado no figura registrado en el catálogo del Estado.", "error")
        return
    end

    -- Asignar el nuevo empleo en grado 0 (Novato / Aprendiz)
    Player.Functions.SetJob(jobId, 0)

    -- Guardar en base de datos inmediatamente
    Player.Functions.Save()

    local officialLabel = QBCore.Shared.Jobs[jobId].label or jobLabel

    TriggerClientEvent('spain_jobs:client:jobAssigned', src, officialLabel, locationName, coords)
    TriggerClientEvent('QBCore:Notify', src, "Has firmado tu contrato como " .. officialLabel .. ". ¡Bienvenido!", "success")
end)

-- Evento para renunciar y quedar desempleado
RegisterNetEvent('spain_jobs:server:quitJob', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    Player.Functions.SetJob('unemployed', 0)
    Player.Functions.Save()

    TriggerClientEvent('QBCore:Notify', src, "Has causado baja en tu empresa. Ahora figuras como Civil / Desempleado.", "primary")
end)
