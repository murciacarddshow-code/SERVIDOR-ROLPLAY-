-- =========================================================================
-- SPAIN ROL - TABLET Y DIAGNÓSTICO DE MECÁNICOS
-- =========================================================================
-- Herramienta digital para mecánicos de Benny's y Los Santos Customs.
-- Permite diagnosticar desgaste, emitir presupuestos y reparar vehículos.

local QBCore = exports['qb-core']:GetCoreObject()

-- Comprobar si tiene trabajo de mecánico o admin
local function IsMechanic()
    local PlayerData = QBCore.Functions.GetPlayerData()
    return PlayerData.job and (PlayerData.job.name == 'mechanic' or PlayerData.job.name == 'bennys' or PlayerData.job.type == 'mechanic') or QBCore.Functions.HasPermission('admin')
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
-- Reparar motor y chapa
RegisterNetEvent('spain_mechanic:client:fixVehicle', function(data)
    local veh = data.veh or QBCore.Functions.GetClosestVehicle()
    if veh == 0 or #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(veh)) > 6.0 then
        QBCore.Functions.Notify('No hay ningún vehículo cerca para reparar.', 'error')
        return
    end

    SetVehicleDoorOpen(veh, 4, false, false)

    QBCore.Functions.Progressbar("mech_repair", "Reparando motor, chapa y radiador...", 7000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_ped",
        flags = 1,
    }, {
        model = "prop_tool_wrench",
        bone = 28422,
        coords = vector3(0.06, 0.01, -0.02),
        rotation = vector3(0.0, 0.0, 0.0),
    }, {}, function()
        SetVehicleDoorShut(veh, 4, false)
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehicleBodyHealth(veh, 1000.0)
        SetVehicleFixed(veh)
        SetVehicleDeformationFixed(veh)
        SetVehicleUndriveable(veh, false)
        QBCore.Functions.Notify('Reparación de motor y chapa completada al 100%.', 'success')
    end, function()
        SetVehicleDoorShut(veh, 4, false)
        QBCore.Functions.Notify('Reparación cancelada.', 'error')
    end)
end)

-- Reparar neumáticos
RegisterNetEvent('spain_mechanic:client:fixTyres', function(data)
    local veh = data.veh or QBCore.Functions.GetClosestVehicle()
    if veh == 0 or #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(veh)) > 6.0 then
        QBCore.Functions.Notify('No hay ningún vehículo cerca.', 'error')
        return
    end

    QBCore.Functions.Progressbar("mech_tyres", "Cambiando neumáticos y equilibrando ruedas...", 4500, false, true, {
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
        QBCore.Functions.Notify('Neumáticos sustituidos correctamente.', 'success')
    end)
end)

-- Lavar vehículo
RegisterNetEvent('spain_mechanic:client:cleanVehicle', function(data)
    local veh = data.veh or QBCore.Functions.GetClosestVehicle()
    if veh == 0 or #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(veh)) > 6.0 then
        QBCore.Functions.Notify('No hay ningún vehículo cerca.', 'error')
        return
    end

    QBCore.Functions.Progressbar("mech_clean", "Limpieza con pistola a presión y encerado...", 3500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        anim = "machinic_loop_mechandplayer",
        flags = 1,
    }, {}, {}, function()
        SetVehicleDirtLevel(veh, 0.0)
        QBCore.Functions.Notify('Vehículo limpio y reluciente.', 'success')
    end)
end)

-- Facturar a cliente
RegisterNetEvent('spain_mechanic:client:billCustomer', function()
    local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.5 then
        local targetServerId = GetPlayerServerId(closestPlayer)
        local dialog = exports['qb-input']:ShowInput({
            header = "Factura de Taller - Cobrar a Cliente",
            submitText = "Emitir Factura",
            inputs = {
                {
                    text = "Importe (€)",
                    name = "amount",
                    type = "number",
                    isRequired = true
                },
                {
                    text = "Concepto / Descripción del servicio",
                    name = "reason",
                    type = "text",
                    isRequired = false
                }
            }
        })

        if dialog and dialog.amount then
            local amount = tonumber(dialog.amount)
            if amount and amount > 0 then
                TriggerServerEvent('spain_mechanic:server:sendBill', targetServerId, amount, dialog.reason or "Servicios de Taller")
            else
                QBCore.Functions.Notify('Debes ingresar un importe válido.', 'error')
            end
        end
    else
        QBCore.Functions.Notify('No hay ningún cliente cerca para facturar.', 'error')
    end
end)

RegisterCommand('factura', function()
    if IsMechanic() then
        TriggerEvent('spain_mechanic:client:billCustomer')
    else
        QBCore.Functions.Notify('Solo personal de talleres mecánicos puede emitir facturas.', 'error')
    end
end, false)

-- =========================================================================
-- INTEGRACIÓN CON QB-TARGET (INTERACCIÓN FÍSICA ESTILO ONX)
-- =========================================================================
CreateThread(function()
    -- Interacción directa con el capó y motor
    exports['qb-target']:AddTargetBone({'bonnet', 'engine'}, {
        options = {
            {
                type = "client",
                event = "spain_mechanic:client:openTablet",
                icon = "fas fa-clipboard-check",
                label = "Diagnosticar Motor y Averías",
                canInteract = function() return IsMechanic() end,
            },
            {
                type = "client",
                action = function(entity)
                    TriggerEvent("spain_mechanic:client:fixVehicle", { veh = entity })
                end,
                icon = "fas fa-wrench",
                label = "Reparar Motor y Chapa",
                canInteract = function() return IsMechanic() end,
            },
            {
                type = "client",
                action = function(entity)
                    TriggerEvent("qb-tunerchip:client:openChip")
                end,
                icon = "fas fa-microchip",
                label = "Conectar Tablet ECU (Tuning)",
                canInteract = function() return IsMechanic() end,
            }
        },
        distance = 2.2
    })

    -- Interacción directa con las ruedas
    exports['qb-target']:AddTargetBone({'wheel_lf', 'wheel_rf', 'wheel_lr', 'wheel_rr'}, {
        options = {
            {
                type = "client",
                action = function(entity)
                    TriggerEvent("spain_mechanic:client:fixTyres", { veh = entity })
                end,
                icon = "fas fa-circle-dot",
                label = "Cambiar Rueda y Frenos",
                canInteract = function() return IsMechanic() end,
            }
        },
        distance = 1.8
    })

    -- Opciones generales al mirar el vehículo
    exports['qb-target']:AddGlobalVehicle({
        options = {
            {
                type = "client",
                action = function(entity)
                    TriggerEvent("spain_mechanic:client:cleanVehicle", { veh = entity })
                end,
                icon = "fas fa-shower",
                label = "Limpieza y Detailing",
                canInteract = function() return IsMechanic() end,
            },
            {
                type = "client",
                event = "spain_mechanic:client:billCustomer",
                icon = "fas fa-file-invoice-dollar",
                label = "Cobrar / Facturar a Cliente",
                canInteract = function() return IsMechanic() end,
            }
        },
        distance = 2.5
    })
end)

-- =========================================================================
-- INSTALACIÓN DE PIEZAS DE CARROCERÍA FÍSICAS (PUERTAS, CAPÓ, MALETERO, RUEDAS)
-- =========================================================================

RegisterNetEvent('spain_mechanic:client:installDoor', function()
    local veh = QBCore.Functions.GetClosestVehicle()
    if veh == 0 or #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(veh)) > 4.0 then
        QBCore.Functions.Notify('Debes estar cerca de un vehículo para colocar la puerta.', 'error')
        return
    end

    QBCore.Functions.Progressbar("mech_door", "Encajando y atornillando puerta de repuesto...", 6000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_ped",
        flags = 1,
    }, {
        model = "prop_tool_wrench",
        bone = 28422,
        coords = vector3(0.06, 0.01, -0.02),
        rotation = vector3(0.0, 0.0, 0.0),
    }, {}, function()
        for i = 0, 5 do
            SetVehicleDoorShut(veh, i, false)
        end
        SetVehicleBodyHealth(veh, math.min(1000.0, GetVehicleBodyHealth(veh) + 150.0))
        SetVehicleDeformationFixed(veh)
        QBCore.Functions.Notify('Puerta colocada y bisagras calibradas.', 'success')
        TriggerServerEvent('spain_mechanic:server:removeRepairItem', 'veh_door')
    end)
end)

RegisterNetEvent('spain_mechanic:client:installHood', function()
    local veh = QBCore.Functions.GetClosestVehicle()
    if veh == 0 or #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(veh)) > 4.0 then
        QBCore.Functions.Notify('Debes estar frente al vehículo para colocar el capó.', 'error')
        return
    end

    QBCore.Functions.Progressbar("mech_hood", "Montando capó de recambio...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_ped",
        flags = 1,
    }, {}, {}, function()
        SetVehicleDoorShut(veh, 4, false)
        SetVehicleBodyHealth(veh, math.min(1000.0, GetVehicleBodyHealth(veh) + 150.0))
        QBCore.Functions.Notify('Capó instalado con éxito.', 'success')
        TriggerServerEvent('spain_mechanic:server:removeRepairItem', 'veh_hood')
    end)
end)

RegisterNetEvent('spain_mechanic:client:installTrunk', function()
    local veh = QBCore.Functions.GetClosestVehicle()
    if veh == 0 or #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(veh)) > 4.0 then
        QBCore.Functions.Notify('Debes estar detrás del vehículo para colocar el maletero.', 'error')
        return
    end

    QBCore.Functions.Progressbar("mech_trunk", "Instalando portón del maletero...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_ped",
        flags = 1,
    }, {}, {}, function()
        SetVehicleDoorShut(veh, 5, false)
        SetVehicleBodyHealth(veh, math.min(1000.0, GetVehicleBodyHealth(veh) + 150.0))
        QBCore.Functions.Notify('Portón de maletero instalado con éxito.', 'success')
        TriggerServerEvent('spain_mechanic:server:removeRepairItem', 'veh_trunk')
    end)
end)

RegisterNetEvent('spain_mechanic:client:installWheel', function()
    local veh = QBCore.Functions.GetClosestVehicle()
    if veh == 0 or #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(veh)) > 4.0 then
        QBCore.Functions.Notify('Debes estar cerca del neumático dañado.', 'error')
        return
    end

    TriggerEvent('spain_mechanic:client:fixTyres', { veh = veh })
    TriggerServerEvent('spain_mechanic:server:removeRepairItem', 'veh_wheel')
end)
