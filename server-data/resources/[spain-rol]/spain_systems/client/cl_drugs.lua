local QBCore = exports['qb-core']:GetCoreObject()

-- Efecto de Marihuana / Porro
RegisterNetEvent('spain_drugs:client:useJoint', function()
    local ped = PlayerPedId()
    QBCore.Functions.Progressbar("smoke_joint", "Liando y fumando un porro...", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "amb@world_human_smoking@male@male_a@base",
        anim = "base",
        flags = 49,
    }, {}, {}, function()
        StopAnimTask(ped, "amb@world_human_smoking@male@male_a@base", "base", 1.0)
        TriggerServerEvent('hud:server:RelieveStress', 30)
        SetPedArmour(ped, math.min(100, GetPedArmour(ped) + 20))
        StartScreenEffect("DrugsTrevorClownsFightIn", 3000, false)
        QBCore.Functions.Notify("Te sientes relajado y sin estres.", "success")
    end)
end)

-- Efecto de Cocaina
RegisterNetEvent('spain_drugs:client:useCoke', function()
    local ped = PlayerPedId()
    QBCore.Functions.Progressbar("snort_coke", "Inhalando una raya de cocaina...", 3000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@amb@nightclub@peds@",
        anim = "missfbi3_party_snort_coke_b_male3",
        flags = 49,
    }, {}, {}, function()
        StopAnimTask(ped, "anim@amb@nightclub@peds@", "missfbi3_party_snort_coke_b_male3", 1.0)
        SetPedArmour(ped, math.min(100, GetPedArmour(ped) + 30))
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.35)
        StartScreenEffect("Rampage", 15000, false)
        QBCore.Functions.Notify("¡Sientes una explosion de adrenalina y velocidad!", "success")
        Wait(15000)
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end)
end)

-- Efecto de Metanfetamina / Cristal Azul
RegisterNetEvent('spain_drugs:client:useMeth', function(isBlue)
    local ped = PlayerPedId()
    local label = isBlue and "Fumando Cristal Azul de alta pureza..." or "Consumiendo Metanfetamina..."
    local armorGain = isBlue and 65 or 40
    local speedMulti = isBlue and 1.45 or 1.30

    QBCore.Functions.Progressbar("use_meth", label, 3500, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "switch@trevor@trev_smoking_meth",
        anim = "trev_smoking_meth_loop",
        flags = 49,
    }, {}, {}, function()
        StopAnimTask(ped, "switch@trevor@trev_smoking_meth", "trev_smoking_meth_loop", 1.0)
        SetPedArmour(ped, math.min(100, GetPedArmour(ped) + armorGain))
        SetRunSprintMultiplierForPlayer(PlayerId(), speedMulti)
        StartScreenEffect("DrugsMichaelAliensFight", 20000, false)
        QBCore.Functions.Notify("Efecto de metanfetamina activo. Eres imparable.", "success")
        Wait(20000)
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end)
end)

-- Efecto de Setas Alucinogenas y Extasis
RegisterNetEvent('spain_drugs:client:usePsychedelic', function(type)
    local ped = PlayerPedId()
    local label = type == 'mushrooms' and "Comiendo setas alucinogenas..." or "Tomando pastilla de Extasis..."
    
    QBCore.Functions.Progressbar("use_psych", label, 2000, false, true, {}, {
        animDict = "mp_suicide",
        anim = "pill",
        flags = 49,
    }, {}, {}, function()
        StopAnimTask(ped, "mp_suicide", "pill", 1.0)
        StartScreenEffect("DrugsTrevorClownsFight", 25000, false)
        SetTimecycleModifier("spectator5")
        QBCore.Functions.Notify("Empiezas a ver luces de colores y distorsion visual...", "primary")
        Wait(25000)
        ClearTimecycleModifier()
        StopScreenEffect("DrugsTrevorClownsFight")
    end)
end)

-- Efecto de Heroina
RegisterNetEvent('spain_drugs:client:useHeroin', function()
    local ped = PlayerPedId()
    QBCore.Functions.Progressbar("use_heroin", "Inyectando jeringa de heroina...", 4000, false, true, {}, {
        animDict = "rcmpaparazzo1ig_4",
        anim = "miranda_shooting_up",
        flags = 49,
    }, {}, {}, function()
        StopAnimTask(ped, "rcmpaparazzo1ig_4", "miranda_shooting_up", 1.0)
        SetEntityHealth(ped, 200)
        SetPedArmour(ped, 100)
        SetPedToRagdoll(ped, 3000, 3000, 0, 0, 0, 0)
        StartScreenEffect("ChopVision", 15000, false)
        QBCore.Functions.Notify("Efecto sedante total. Salud y armadura restauradas al maximo.", "success")
    end)
end)
