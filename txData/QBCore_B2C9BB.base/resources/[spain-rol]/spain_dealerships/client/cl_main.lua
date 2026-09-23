-- =========================================================================
-- SPAIN ROL - CLIENTE: 3 COMPRA-VENTAS Y TABLET DE OCASIÓN
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()
local spawnedPeds = {}
local tabletProp = nil
local isTabletOpen = false
local currentDealerId = nil

-- Función para dibujar texto 3D nítido
local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if not onScreen then return end

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)

    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 20, 20, 20, 160)
end

-- Limpieza de Peds y Props
local function CleanupEntities()
    for _, ped in pairs(spawnedPeds) do
        if DoesEntityExist(ped) then
            DeletePed(ped)
        end
    end
    spawnedPeds = {}

    if tabletProp and DoesEntityExist(tabletProp) then
        DeleteEntity(tabletProp)
        tabletProp = nil
    end
end

-- Cargar animación y sostener tablet
local function PlayTabletAnimation()
    local ped = PlayerPedId()
    local animDict = "amb@world_human_seat_wall_tablet@female@base"
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end
    TaskPlayAnim(ped, animDict, "base", 2.0, 2.0, -1, 51, 0, false, false, false)

    local model = `prop_cs_tablet`
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local coords = GetEntityCoords(ped)
    tabletProp = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(tabletProp, ped, GetPedBoneIndex(ped, 28422), -0.05, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
end

local function StopTabletAnimation()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    if tabletProp and DoesEntityExist(tabletProp) then
        DeleteEntity(tabletProp)
        tabletProp = nil
    end
end

-- Abrir la Tablet NUI
local function OpenDealershipTablet(dealerKey)
    if isTabletOpen then return end
    currentDealerId = dealerKey

    QBCore.Functions.TriggerCallback('spain_dealerships:server:getTabletData', function(data)
        if not data then return end

        isTabletOpen = true
        PlayTabletAnimation()
        SetNuiFocus(true, true)

        SendNUIMessage({
            action = 'openTablet',
            dealership = Config.Dealerships[dealerKey],
            user = data.user,
            societyBalance = data.societyBalance,
            catalog = Config.Vehicles,
            ownedVehicles = data.ownedVehicles,
            employees = data.employees,
            history = data.history
        })
    end, dealerKey)
end

-- Registrar Blips y Peds en el mapa
local function SetupDealerships()
    CleanupEntities()

    for key, dealer in pairs(Config.Dealerships) do
        -- 1. Blip en el mapa
        local blip = AddBlipForCoord(dealer.coords.x, dealer.coords.y, dealer.coords.z)
        SetBlipSprite(blip, dealer.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, dealer.blip.scale)
        SetBlipColour(blip, dealer.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(dealer.blip.label)
        EndTextCommandSetBlipName(blip)

        -- 2. NPC Comercial en el mostrador
        local modelHash = GetHashKey(dealer.pedModel)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(10)
        end

        local ped = CreatePed(4, modelHash, dealer.coords.x, dealer.coords.y, dealer.coords.z - 1.0, dealer.coords.w, false, true)
        SetEntityHeading(ped, dealer.coords.w)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)

        spawnedPeds[key] = ped
    end
end

CreateThread(function()
    SetupDealerships()
end)

-- Bucle de proximidad e interacción
CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)

        for key, dealer in pairs(Config.Dealerships) do
            local dist = #(pCoords - vector3(dealer.coords.x, dealer.coords.y, dealer.coords.z))

            if dist < 15.0 then
                wait = 0
                -- Marcador luminoso en el suelo
                DrawMarker(2, dealer.coords.x, dealer.coords.y, dealer.coords.z + 0.15, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.4, 0.4, 0.4, 59, 130, 246, 180, false, true, 2, false, nil, nil, false)

                if dist < 2.5 then
                    DrawText3D(dealer.coords.x, dealer.coords.y, dealer.coords.z + 1.05, "~b~[E]~w~ Abrir Tablet de " .. dealer.name)
                    if IsControlJustPressed(0, 38) then -- Tecla E
                        OpenDealershipTablet(key)
                    end
                end
            end
        end

        Wait(wait)
    end
end)

-- Comando de apoyo
RegisterCommand('compraventa', function()
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)

    for key, dealer in pairs(Config.Dealerships) do
        local dist = #(pCoords - vector3(dealer.coords.x, dealer.coords.y, dealer.coords.z))
        if dist < 20.0 then
            OpenDealershipTablet(key)
            return
        end
    end
    QBCore.Functions.Notify('Debes estar en las instalaciones de un Compra-Venta para acceder al terminal.', 'error')
end, false)

-- --------------------------------------------------------------------------
-- NUI CALLBACKS
-- --------------------------------------------------------------------------

RegisterNUICallback('closeTablet', function(data, cb)
    isTabletOpen = false
    SetNuiFocus(false, false)
    StopTabletAnimation()
    cb('ok')
end)

RegisterNUICallback('buyVehicle', function(data, cb)
    TriggerServerEvent('spain_dealerships:server:buyVehicle', data)
    cb('ok')
end)

RegisterNUICallback('sellVehicle', function(data, cb)
    TriggerServerEvent('spain_dealerships:server:sellVehicle', data)
    cb('ok')
end)

RegisterNUICallback('societyDeposit', function(data, cb)
    TriggerServerEvent('spain_dealerships:server:societyDeposit', data)
    cb('ok')
end)

RegisterNUICallback('societyWithdraw', function(data, cb)
    TriggerServerEvent('spain_dealerships:server:societyWithdraw', data)
    cb('ok')
end)

RegisterNUICallback('setEmployeeGrade', function(data, cb)
    TriggerServerEvent('spain_dealerships:server:setEmployeeGrade', data)
    cb('ok')
end)

RegisterNUICallback('fireEmployee', function(data, cb)
    TriggerServerEvent('spain_dealerships:server:fireEmployee', data)
    cb('ok')
end)

RegisterNUICallback('getNearbyPlayers', function(data, cb)
    QBCore.Functions.TriggerCallback('spain_dealerships:server:getNearbyPlayers', function(players)
        cb(players or {})
    end)
end)

RegisterNUICallback('hirePlayer', function(data, cb)
    TriggerServerEvent('spain_dealerships:server:hirePlayer', data)
    cb('ok')
end)

-- Actualizaciones en tiempo real recibidas del servidor
RegisterNetEvent('spain_dealerships:client:updateBalances', function(updateData)
    if isTabletOpen then
        SendNUIMessage({
            action = 'updateBalances',
            userBank = updateData.userBank,
            societyBalance = updateData.societyBalance,
            ownedVehicles = updateData.ownedVehicles,
            employees = updateData.employees
        })
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupEntities()
    end
end)
