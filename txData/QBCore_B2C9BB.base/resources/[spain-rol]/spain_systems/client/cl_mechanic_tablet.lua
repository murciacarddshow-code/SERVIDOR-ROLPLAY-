-- =========================================================================
-- SPAIN ROL - TABLET Y DIAGNÓSTICO DE MECÁNICOS
-- =========================================================================
-- Herramienta digital para mecánicos de Benny's y Los Santos Customs.
-- Permite diagnosticar desgaste, emitir presupuestos y reparar vehículos.

local QBCore = exports['qb-core']:GetCoreObject()

-- Comprobar si tiene trabajo de mecánico o admin
local function IsMechanic()
    local PlayerData = QBCore.Functions.GetPlayerData()
    return PlayerData.job and PlayerData.job.name == 'mechanic' or QBCore.Functions.HasPermission('admin')
end

-- Abrir menú de diagnóstico y tablet de mecánico
local function OpenMechanicTablet()
    local ped = PlayerPedId()
    local veh = QBCore.Functions.GetClosestVehicle()

    if veh == 0 or #(GetEntityCoords(ped) - GetEntityCoords(veh)) > 5.0 then
        QBCore.Functions.Notify('No hay ningún vehículo cerca para diagnosticar.', 'error')
        return
    end

    local plate = GetVehicleNumberPlateText(veh)
    local engineHealth = math.floor(GetVehicleEngineHealth(veh) / 10)
    local bodyHealth = math.floor(GetVehicleBodyHealth(veh) / 10)
    local dirt = math.floor(GetVehicleDirtLevel(veh))

    local tyresBurst = 0
    for i = 0, 5 do
        if IsVehicleTyreBurst(veh, i, false) then
            tyresBurst = tyresBurst + 1
        end
    end

    local mechMenu = {
        {
            header = "📋 Tablet de Taller Mecánico - Matrícula: " .. plate,
            isMenuHeader = true,
        },
        {
            header = "⚙️ Estado del Motor: " .. engineHealth .. "%",
            txt = engineHealth < 50 and "⚠️ Motor con averías graves o sobrecalentamiento" or "✅ Rendimiento del bloque motor óptimo",
            isMenuHeader = true,
        },
        {
            header = "🚗 Estado de Carrocería: " .. bodyHealth .. "%",
            txt = "Chapa, defensas, ópticas y cristales",
            isMenuHeader = true,
        },
        {
            header = "🔘 Neumáticos Dañados: " .. tyresBurst .. " ruedas",
            txt = tyresBurst > 0 and "⚠️ Ruedas pinchadas o reventadas" or "✅ Presión y dibujo de neumáticos correcto",
            isMenuHeader = true,
        },
        {
            header = "🔧 Reparación Integral de Motor y Chapa",
            txt = "Restaura la salud del motor y chapa al 100% - 750€",
            params = {
                event = "spain_mechanic:client:fixVehicle",
                args = { veh = veh, cost = 750 }
            }
        },
        {
            header = "🛞 Sustituir y Alinear Neumáticos",
            txt = "Cambia todas las ruedas dañadas por neumáticos nuevos - 250€",
            params = {
                event = "spain_mechanic:client:fixTyres",
                args = { veh = veh, cost = 250 }
            }
        },
        {
            header = "🧼 Lavado y Detailing Profesional",
            txt = "Elimina suciedad, barro y polvo acumulado - 50€",
            params = {
                event = "spain_mechanic:client:cleanVehicle",
                args = { veh = veh, cost = 50 }
            }
        },
        {
            header = "💶 Emitir Factura a Cliente Cercano",
            txt = "Genera un cobro directo a la cuenta bancaria del cliente",
            params = {
                event = "spain_mechanic:client:billCustomer",
                args = {}
            }
        }
    }
    exports['qb-menu']:openMenu(mechMenu)
end

RegisterCommand('mecanico', function()
    if IsMechanic() then
        OpenMechanicTablet()
    else
        QBCore.Functions.Notify('Solo personal de talleres mecánicos autorizados puede usar esta tablet.', 'error')
    end
end, false)

RegisterNetEvent('spain_mechanic:client:openTablet', function()
    if IsMechanic() then
        OpenMechanicTablet()
    else
        QBCore.Functions.Notify('Habla con un mecánico de servicio para gestionar reparaciones.', 'primary')
    end
end)

-- Reparar motor y chapa
RegisterNetEvent('spain_mechanic:client:fixVehicle', function(data)
    local veh = data.veh
    local ped = PlayerPedId()

    QBCore.Functions.Progressbar("mech_repair", "Mecánicos realizando reparación de motor y chapa...", 6000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_ped",
        flags = 1,
    }, {}, {}, function()
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehicleBodyHealth(veh, 1000.0)
        SetVehicleFixed(veh)
        SetVehicleDeformationFixed(veh)
        SetVehicleUndriveable(veh, false)
        QBCore.Functions.Notify('Reparación de motor y chapa completada al 100%.', 'success')
    end)
end)

-- Reparar neumáticos
RegisterNetEvent('spain_mechanic:client:fixTyres', function(data)
    local veh = data.veh
    QBCore.Functions.Progressbar("mech_tyres", "Cambiando neumáticos y equilibrando ruedas...", 4000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_ped",
        flags = 1,
    }, {}, {}, function()
        for i = 0, 7 do
            SetVehicleTyreFixed(veh, i)
        end
        QBCore.Functions.Notify('Neumáticos sustituidos correctamente.', 'success')
    end)
end)

-- Lavar vehículo
RegisterNetEvent('spain_mechanic:client:cleanVehicle', function(data)
    local veh = data.veh
    QBCore.Functions.Progressbar("mech_clean", "Limpieza con pistola a presión y encerado...", 3000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        SetVehicleDirtLevel(veh, 0.0)
        QBCore.Functions.Notify('Vehículo limpio y reluciente.', 'success')
    end)
end)

-- Facturar a cliente
RegisterNetEvent('spain_mechanic:client:billCustomer', function()
    local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        local targetServerId = GetPlayerServerId(closestPlayer)
        local amount = prompt and prompt("Importe de la factura de taller (en Euros €):", "500") or 500
        TriggerServerEvent('spain_mechanic:server:sendBill', targetServerId, tonumber(amount) or 500)
    else
        QBCore.Functions.Notify('No hay ningún cliente cerca para facturar.', 'error')
    end
end)
