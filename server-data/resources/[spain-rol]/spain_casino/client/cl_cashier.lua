local QBCore = exports['qb-core']:GetCoreObject()
local CashierPed = nil

-- ============================================================================
-- GENERACIÓN DEL NPC CAJERO DEL CASINO
-- ============================================================================

local function SpawnCashierPed()
    if CashierPed and DoesEntityExist(CashierPed) then return end

    local modelHash = joaat(Config.Cashier.model)
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    if HasModelLoaded(modelHash) then
        local c = Config.Cashier.coords
        CashierPed = CreatePed(4, modelHash, c.x, c.y, c.z - 1.0, c.w, false, true)
        SetModelAsNoLongerNeeded(modelHash)

        SetEntityInvincible(CashierPed, true)
        SetBlockingOfNonTemporaryEvents(CashierPed, true)
        FreezeEntityPosition(CashierPed, true)
        TaskStartScenarioInPlace(CashierPed, 'PROP_HUMAN_STAND_IMPATIENT', 0, true)
    end
end

-- ============================================================================
-- HILO DE INTERACCIÓN CON EL CAJERO
-- ============================================================================

CreateThread(function()
    while true do
        local sleep = 1500
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local c = Config.Cashier.coords
        local dist = #(pos - vector3(c.x, c.y, c.z))

        if dist < 25.0 then
            sleep = 0
            if not CashierPed or not DoesEntityExist(CashierPed) then
                SpawnCashierPed()
            end

            if dist < Config.Cashier.distance then
                DrawText3D(c.x, c.y, c.z + 0.3, Config.Cashier.prompt)

                if IsControlJustReleased(0, 38) then -- Tecla E
                    QBCore.Functions.TriggerCallback('spain_casino:server:getPlayerCasinoData', function(data)
                        if data then
                            SetNuiFocus(true, true)
                            SendNUIMessage({
                                action = 'openCashier',
                                data = data,
                                vipPrice = Config.VipPrice,
                                chipRate = Config.ChipRate
                            })
                        end
                    end)
                end
            end
        else
            if CashierPed and DoesEntityExist(CashierPed) then
                DeletePed(CashierPed)
                CashierPed = nil
            end
        end

        Wait(sleep)
    end
end)

-- ============================================================================
-- NUI CALLBACKS DEL CAJERO
-- ============================================================================

RegisterNUICallback('buyChips', function(data, cb)
    local amount = tonumber(data.amount)
    local payMethod = data.payMethod or 'cash'
    if amount and amount > 0 then
        TriggerServerEvent('spain_casino:server:buyChips', amount, payMethod)
    end
    cb('ok')
end)

RegisterNUICallback('sellChips', function(data, cb)
    local amount = tonumber(data.amount)
    local payMethod = data.payMethod or 'cash'
    if amount and amount > 0 then
        TriggerServerEvent('spain_casino:server:sellChips', amount, payMethod)
    end
    cb('ok')
end)

RegisterNUICallback('buyVip', function(data, cb)
    local payMethod = data.payMethod or 'cash'
    TriggerServerEvent('spain_casino:server:buyVipPass', payMethod)
    cb('ok')
end)

-- Limpieza al parar el recurso
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        if CashierPed and DoesEntityExist(CashierPed) then
            DeletePed(CashierPed)
        end
    end
end)
