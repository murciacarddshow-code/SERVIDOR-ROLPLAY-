-- =========================================================================
-- SPAIN ROL - GESTIÓN DEL KIT DE BIENVENIDA (SERVIDOR)
-- =========================================================================
-- Gestiona la entrega persistente única por personaje:
-- - 50.000€ en banco
-- - 5.000€ en efectivo
-- - 5x Agua y 5x Comida
-- - Vehículo propio registrado en la tabla player_vehicles

local QBCore = exports['qb-core']:GetCoreObject()

-- Crear tabla persistente para registrar los kits reclamados
MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `player_starterkits` (
            `citizenid` VARCHAR(50) NOT NULL,
            `plate` VARCHAR(20) DEFAULT NULL,
            `claimed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)

RegisterNetEvent('spain_welcome:server:claimKit', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    local charinfo = Player.PlayerData.charinfo or {}
    local fullName = (charinfo.firstname or 'Ciudadano') .. ' ' .. (charinfo.lastname or '')

    -- Comprobar si ya fue reclamado en metadatos
    if Player.PlayerData.metadata and Player.PlayerData.metadata['claimed_starter_kit'] then
        TriggerClientEvent('QBCore:Notify', src, "Ya has reclamado tu Kit de Bienvenida con este personaje.", "error", 6000)
        return
    end

    -- Comprobar en la base de datos para máxima persistencia
    MySQL.query('SELECT citizenid FROM player_starterkits WHERE citizenid = ? LIMIT 1', { citizenid }, function(results)
        if results and #results > 0 then
            Player.Functions.SetMetaData('claimed_starter_kit', true)
            TriggerClientEvent('QBCore:Notify', src, "Ya has reclamado tu Kit de Bienvenida con este personaje.", "error", 6000)
            return
        end

        -- 1. Marcar como reclamado
        Player.Functions.SetMetaData('claimed_starter_kit', true)

        -- 2. Entregar dinero (50k en banco y 5k en efectivo)
        Player.Functions.AddMoney('bank', 50000, 'starter-kit-bank')
        Player.Functions.AddMoney('cash', 5000, 'starter-kit-cash')

        -- 3. Entregar suministros (5x agua y 5x comida)
        Player.Functions.AddItem('water_bottle', 5)
        Player.Functions.AddItem('sandwich', 5)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['water_bottle'] or { name = 'water_bottle', label = 'Agua' }, 'add')
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['sandwich'] or { name = 'sandwich', label = 'Sandwich' }, 'add')

        -- 4. Generar y registrar vehículo propio en player_vehicles
        local plate = "ESP " .. tostring(math.random(100, 999))
        local model = 'blista'

        MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
            Player.PlayerData.license or 'license:unknown',
            citizenid,
            model,
            GetHashKey(model),
            '{}',
            plate,
            'Garaje Central',
            0
        }, function(id)
            -- Registrar en player_starterkits
            MySQL.insert('INSERT INTO player_starterkits (citizenid, plate) VALUES (?, ?)', { citizenid, plate })

            -- 5. Ordenar al cliente spawnear el coche en el parking designado
            TriggerClientEvent('spain_welcome:client:spawnStarterVehicle', src, {
                model = model,
                plate = plate,
                coords = data.spawnCoords
            })

            -- 6. Enviar tarjeta de bienvenida al chat
            TriggerClientEvent('chat:addMessage', src, {
                template = '<div style="padding: 14px 16px; margin: 8px 0; background: linear-gradient(135deg, #1e3c72 0%, #2a5298 50%, #f39c12 100%); color: #fff; border-radius: 12px; border-left: 6px solid #f1c40f; box-shadow: 0 4px 15px rgba(0,0,0,0.5); font-family: sans-serif;">' ..
                    '<div style="font-weight: 800; font-size: 14px; text-transform: uppercase; border-bottom: 1px solid rgba(255,255,255,0.2); padding-bottom: 6px; margin-bottom: 8px; color: #ffeaa7;">' ..
                    '🇪🇸 ¡BIENVENIDO A SPAIN ROL v2.0! &bull; KIT INICIAL RECLAMADO' ..
                    '</div>' ..
                    '<div style="font-size: 13px; line-height: 1.7;">' ..
                    '¡Hola <b>{0}</b>! Te damos la bienvenida oficial a la ciudad. Hemos preparado todo para tu comienzo:<br>' ..
                    '&bull; 💳 <b>50.000€</b> ingresados en tu cuenta bancaria.<br>' ..
                    '&bull; 💵 <b>5.000€</b> en efectivo en tu cartera.<br>' ..
                    '&bull; 🚗 <b>Vehículo en propiedad</b>: Dinka Blista [<b>{1}</b>] en la acera con llaves puestas.<br>' ..
                    '&bull; 🥪 <b>Suministros</b>: 5x Botellas de agua mineral y 5x Sandwiches.<br>' ..
                    '<i style="color:#ffeaa7;">¡Disfruta de la mejor experiencia de rol!</i>' ..
                    '</div>' ..
                    '</div>',
                args = { fullName, plate }
            })

            TriggerClientEvent('QBCore:Notify', src, "¡Kit de Bienvenida reclamado con éxito! Revisa tu cartera, tu cuenta y tu nuevo coche.", "success", 9000)
        end)
    end)
end)
