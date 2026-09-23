local QBCore = exports['qb-core']:GetCoreObject()
local isTabletOpen = false
local tabletProp = nil

-- =========================================================================
-- ANIMACIÓN Y PROP DE LA TABLET
-- =========================================================================
local function PlayTabletAnimation()
    local ped = PlayerPedId()
    local dict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
    local model = GetHashKey("prop_cs_tablet")

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    tabletProp = CreateObject(model, 0.0, 0.0, 0.0, true, true, false)
    local boneIndex = GetPedBoneIndex(ped, 28422) -- Mano derecha
    AttachEntityToEntity(tabletProp, ped, boneIndex, 0.0, -0.03, 0.0, 20.0, -90.0, 0.0, true, true, false, true, 1, true)

    TaskPlayAnim(ped, dict, "base", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
end

local function StopTabletAnimation()
    local ped = PlayerPedId()
    StopAnimTask(ped, "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 2.0)
    if tabletProp and DoesEntityExist(tabletProp) then
        DeleteEntity(tabletProp)
        tabletProp = nil
    end
end

-- =========================================================================
-- APERTURA / CIERRE DE LA TABLET
-- =========================================================================
function OpenCriminalTablet()
    if isTabletOpen then return end

    local PlayerData = QBCore.Functions.GetPlayerData()
    local gangName = PlayerData.gang and PlayerData.gang.name

    if not gangName or gangName == 'none' then
        QBCore.Functions.Notify("No perteneces a ninguna organización o banda criminal.", "error", 5000)
        return
    end

    QBCore.Functions.TriggerCallback('spain_criminal:server:getTabletData', function(data)
        if not data then return end
        isTabletOpen = true
        SetNuiFocus(true, true)
        PlayTabletAnimation()
        SendNUIMessage({
            action = "openTablet",
            data = data
        })
    end)
end

RegisterNetEvent('spain_criminal:client:openTablet', function()
    OpenCriminalTablet()
end)

-- Comando y Keybind
RegisterCommand(Config.Command or 'crimtablet', function()
    OpenCriminalTablet()
end, false)

RegisterKeyMapping(Config.Command or 'crimtablet', 'Abrir Tablet Criminal (Origin)', 'keyboard', Config.Keybind or 'F7')

-- =========================================================================
-- NUI CALLBACKS
-- =========================================================================
RegisterNUICallback('closeTablet', function(_, cb)
    isTabletOpen = false
    SetNuiFocus(false, false)
    StopTabletAnimation()
    cb('ok')
end)

RegisterNUICallback('safeOperation', function(data, cb)
    TriggerServerEvent('spain_criminal:server:safeOperation', data)
    cb('ok')
end)

RegisterNUICallback('manageMember', function(data, cb)
    TriggerServerEvent('spain_criminal:server:manageMember', data)
    cb('ok')
end)

RegisterNUICallback('inviteMember', function(data, cb)
    TriggerServerEvent('spain_criminal:server:inviteMember', data.targetId)
    cb('ok')
end)

RegisterNUICallback('craftItem', function(data, cb)
    TriggerServerEvent('spain_criminal:server:craftItem', data)
    cb('ok')
end)

RegisterNUICallback('spawnOrgVehicle', function(data, cb)
    TriggerServerEvent('spain_criminal:server:requestSpawnOrgVehicle', data.model)
    cb('ok')
end)

RegisterNUICallback('buyMaterial', function(data, cb)
    TriggerServerEvent('spain_criminal:server:buyMaterial', data)
    cb('ok')
end)

-- Evento para refrescar datos de la organización en tiempo real
RegisterNetEvent('spain_criminal:client:refreshOrgData', function(orgData, members)
    if isTabletOpen then
        SendNUIMessage({
            action = "updateOrg",
            organization = orgData,
            members = members
        })
    end
end)
