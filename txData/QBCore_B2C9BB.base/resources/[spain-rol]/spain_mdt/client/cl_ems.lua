local QBCore = exports['qb-core']:GetCoreObject()
local spawnedStretcher = nil

-- Comprobar si es médico / SAMUR
local function IsEMS()
    local PlayerData = QBCore.Functions.GetPlayerData()
    return PlayerData.job and PlayerData.job.name == 'ambulance'
end

-- Reanimación médica avanzada con desfibrilador
RegisterCommand('reanimar', function()
    if not IsEMS() and not QBCore.Functions.HasPermission('admin') then
        QBCore.Functions.Notify('Solo personal sanitario de emergencias (SAMUR) puede usar este comando.', 'error')
        return
    end

    local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 2.5 then
        local ped = PlayerPedId()
        QBCore.Functions.Progressbar("ems_revive", "Colocando parches y aplicando descarga eléctrica...", 6000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mini@cpr@char_a@cpr_str",
            anim = "cpr_pumpchest",
            flags = 1,
        }, {}, {}, function() -- Done
            local targetServerId = GetPlayerServerId(closestPlayer)
            TriggerServerEvent('hospital:server:RevivePlayer', targetServerId)
            QBCore.Functions.Notify('Paciente reanimado con éxito.', 'success')
        end)
    else
        QBCore.Functions.Notify('No hay ningún paciente inconsciente cerca.', 'error')
    end
end, false)

-- Curación y vendaje de heridas
RegisterCommand('curar', function()
    if not IsEMS() and not QBCore.Functions.HasPermission('admin') then return end

    local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 2.5 then
        QBCore.Functions.Progressbar("ems_heal", "Tratando y vendando heridas...", 4000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "anim@heists@narcotics@funding@gang_idle",
            anim = "gang_chatting_idle01",
            flags = 49,
        }, {}, {}, function()
            local targetServerId = GetPlayerServerId(closestPlayer)
            TriggerServerEvent('hospital:server:TreatWounds', targetServerId)
            QBCore.Functions.Notify('Heridas tratadas y vendadas.', 'success')
        end)
    else
        QBCore.Functions.Notify('No hay nadie cerca para tratar.', 'error')
    end
end, false)

-- Desplegar o retirar camilla de emergencias
RegisterCommand('camilla', function()
    if not IsEMS() then return end

    if spawnedStretcher and DoesEntityExist(spawnedStretcher) then
        DeleteEntity(spawnedStretcher)
        spawnedStretcher = nil
        QBCore.Functions.Notify('Camilla guardada en la ambulancia.', 'primary')
    else
        local ped = PlayerPedId()
        local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.8, -0.5)
        local heading = GetEntityHeading(ped)
        local model = `v_med_bed1`
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
        spawnedStretcher = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
        SetEntityHeading(spawnedStretcher, heading)
        PlaceObjectOnGroundProperly(spawnedStretcher)
        QBCore.Functions.Notify('Camilla desplegada. Pacientes pueden tenderse pulsando [E].', 'success')
    end
end, false)
