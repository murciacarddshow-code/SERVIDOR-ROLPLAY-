local QBCore = exports['qb-core']:GetCoreObject()

-- =========================================================================
-- REGISTRO DEL ÍTEM USABLE
-- =========================================================================
QBCore.Functions.CreateUseableItem(Config.ItemName, function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('spain_criminal:client:openTablet', source)
end)

-- =========================================================================
-- OBTENER DATOS DE LA TABLET (ORGANIZACIÓN, MIEMBROS, CRAFTEO, GARAJE)
-- =========================================================================
QBCore.Functions.CreateCallback('spain_criminal:server:getTabletData', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(nil) return end

    local gang = Player.PlayerData.gang
    if not gang or gang.name == 'none' then
        cb(nil)
        return
    end

    local gangName = gang.name
    local orgLabel = (Config.Organizations[gangName] and Config.Organizations[gangName].label) or gang.label or gangName

    -- Obtener o crear organización en BD
    MySQL.query('SELECT * FROM criminal_organizations WHERE gang = ? LIMIT 1', { gangName }, function(orgRes)
        local orgData = {
            gang = gangName,
            label = orgLabel,
            black_money = 100000,
            clean_money = 35000,
            level = 2,
            reputation = 500
        }

        if orgRes and orgRes[1] then
            orgData = orgRes[1]
        else
            MySQL.insert('INSERT INTO criminal_organizations (gang, label, black_money, clean_money, level, reputation) VALUES (?, ?, ?, ?, ?, ?)', {
                gangName, orgLabel, orgData.black_money, orgData.clean_money, orgData.level, orgData.reputation
            })
        end

        -- Obtener miembros de la organización
        MySQL.query("SELECT citizenid, charinfo, gang FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(gang, '$.name')) = ?", { gangName }, function(pRes)
            local members = {}
            if pRes then
                for _, row in ipairs(pRes) do
                    local charinfo = json.decode(row.charinfo) or {}
                    local gangObj = json.decode(row.gang) or {}
                    local pOnline = QBCore.Functions.GetPlayerByCitizenId(row.citizenid)

                    table.insert(members, {
                        citizenid = row.citizenid,
                        name = (charinfo.firstname or 'Desconocido') .. ' ' .. (charinfo.lastname or ''),
                        gradeName = (gangObj.grade and gangObj.grade.name) or 'Miembro',
                        gradeLevel = (gangObj.grade and gangObj.grade.level) or 0,
                        isboss = gangObj.isboss or false,
                        online = pOnline ~= nil
                    })
                end
            end

            -- Si no hay miembros en BD (por ejemplo el usuario aún no fue guardado en tabla con esa banda), añadir al jugador actual
            if #members == 0 then
                table.insert(members, {
                    citizenid = Player.PlayerData.citizenid,
                    name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                    gradeName = gang.grade.name or 'Líder',
                    gradeLevel = gang.grade.level or 3,
                    isboss = gang.isboss or false,
                    online = true
                })
            end

            cb({
                organization = orgData,
                members = members,
                userGrade = gang.grade,
                isBoss = gang.isboss or (gang.grade and gang.grade.level >= 2),
                myCitizenId = Player.PlayerData.citizenid,
                weapons = Config.WeaponsCrafting or {},
                drugs = Config.DrugsCrafting or {},
                garageVehicles = (Config.Organizations[gangName] and Config.Organizations[gangName].vehicles) or {},
                blackmarketItems = Config.NPC.shopItems or {}
            })
        end)
    end)
end)

-- =========================================================================
-- CAJA FUERTE (DEPÓSITO / RETIRO)
-- =========================================================================
RegisterNetEvent('spain_criminal:server:safeOperation', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data then return end

    local gang = Player.PlayerData.gang
    if not gang or gang.name == 'none' then return end

    local action = data.action
    local amount = tonumber(data.amount) or 0
    if amount <= 0 then return end

    if action == 'deposit' then
        -- Depósito de dinero sucio o efectivo
        if Player.Functions.RemoveMoney('cash', amount) then
            MySQL.query('UPDATE criminal_organizations SET black_money = black_money + ? WHERE gang = ?', { amount, gang.name }, function()
                TriggerClientEvent('QBCore:Notify', src, "Has depositado €" .. amount .. " en la caja fuerte de la organización.", "success")
                RefreshOrgForMembers(gang.name)
            end)
        else
            TriggerClientEvent('QBCore:Notify', src, "No tienes suficiente dinero en efectivo para depositar.", "error")
        end
    elseif action == 'withdraw' then
        if not gang.isboss and (not gang.grade or gang.grade.level < 2) then
            TriggerClientEvent('QBCore:Notify', src, "Solo los líderes o subjefes pueden retirar fondos de la caja.", "error")
            return
        end

        MySQL.query('SELECT black_money FROM criminal_organizations WHERE gang = ? LIMIT 1', { gang.name }, function(res)
            if res and res[1] and res[1].black_money >= amount then
                MySQL.query('UPDATE criminal_organizations SET black_money = black_money - ? WHERE gang = ?', { amount, gang.name }, function()
                    Player.Functions.AddMoney('cash', amount, 'gang-safe-withdraw')
                    TriggerClientEvent('QBCore:Notify', src, "Has retirado €" .. amount .. " de la caja fuerte.", "success")
                    RefreshOrgForMembers(gang.name)
                end)
            else
                TriggerClientEvent('QBCore:Notify', src, "No hay suficientes fondos en la caja fuerte de la banda.", "error")
            end
        end)
    end
end)

-- =========================================================================
-- GESTIÓN DE MIEMBROS (ASCENDER, DEGRADAR, EXPULSAR)
-- =========================================================================
RegisterNetEvent('spain_criminal:server:manageMember', function(data)
    local src = source
    local Boss = QBCore.Functions.GetPlayer(src)
    if not Boss or not data then return end

    local bossGang = Boss.PlayerData.gang
    if not bossGang.isboss and (not bossGang.grade or bossGang.grade.level < 2) then
        TriggerClientEvent('QBCore:Notify', src, "No tienes rango suficiente para gestionar miembros.", "error")
        return
    end

    local targetCitizenId = data.citizenid
    local action = data.action
    local gangDef = QBCore.Shared.Gangs[bossGang.name]
    if not gangDef then return end

    local Target = QBCore.Functions.GetPlayerByCitizenId(targetCitizenId)
    if Target then
        local currentGrade = Target.PlayerData.gang.grade.level
        if action == 'promote' then
            local nextGrade = math.min(currentGrade + 1, 3)
            Target.Functions.SetGang(bossGang.name, nextGrade)
            TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, "¡Has sido ascendido en " .. bossGang.label .. "!", "success")
        elseif action == 'demote' then
            local prevGrade = math.max(currentGrade - 1, 0)
            Target.Functions.SetGang(bossGang.name, prevGrade)
            TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, "Has sido degradado de rango.", "warning")
        elseif action == 'kick' then
            Target.Functions.SetGang('none', 0)
            TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, "Has sido expulsado de " .. bossGang.label .. ".", "error")
        end
    else
        -- Jugador Offline
        MySQL.query('SELECT gang FROM players WHERE citizenid = ? LIMIT 1', { targetCitizenId }, function(res)
            if res and res[1] then
                local gObj = json.decode(res[1].gang) or {}
                local currentGrade = (gObj.grade and gObj.grade.level) or 0

                if action == 'promote' then
                    local nextGrade = math.min(currentGrade + 1, 3)
                    local gradeName = (gangDef.grades[tostring(nextGrade)] and gangDef.grades[tostring(nextGrade)].name) or 'Miembro'
                    gObj.grade = { name = gradeName, level = nextGrade }
                    gObj.isboss = (nextGrade >= 3)
                    MySQL.query('UPDATE players SET gang = ? WHERE citizenid = ?', { json.encode(gObj), targetCitizenId })
                elseif action == 'demote' then
                    local prevGrade = math.max(currentGrade - 1, 0)
                    local gradeName = (gangDef.grades[tostring(prevGrade)] and gangDef.grades[tostring(prevGrade)].name) or 'Recluta'
                    gObj.grade = { name = gradeName, level = prevGrade }
                    gObj.isboss = false
                    MySQL.query('UPDATE players SET gang = ? WHERE citizenid = ?', { json.encode(gObj), targetCitizenId })
                elseif action == 'kick' then
                    local noneGang = { name = 'none', label = 'No Gang', grade = { name = 'Unaffiliated', level = 0 }, isboss = false }
                    MySQL.query('UPDATE players SET gang = ? WHERE citizenid = ?', { json.encode(noneGang), targetCitizenId })
                end
            end
        end)
    end

    TriggerClientEvent('QBCore:Notify', src, "Jerarquía de la organización actualizada.", "success")
    SetTimeout(500, function()
        RefreshOrgForMembers(bossGang.name)
    end)
end)

-- =========================================================================
-- RECLUTAR NUEVO MIEMBRO
-- =========================================================================
RegisterNetEvent('spain_criminal:server:inviteMember', function(targetId)
    local src = source
    local Boss = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetId))
    if not Boss or not Target then
        TriggerClientEvent('QBCore:Notify', src, "Jugador no encontrado o fuera de la ciudad.", "error")
        return
    end

    local bossGang = Boss.PlayerData.gang
    if not bossGang.isboss and (not bossGang.grade or bossGang.grade.level < 2) then
        TriggerClientEvent('QBCore:Notify', src, "No tienes permisos de reclutamiento.", "error")
        return
    end

    Target.Functions.SetGang(bossGang.name, 0) -- Rango Recluta inicial
    TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, "¡Has sido reclutado en " .. bossGang.label .. "! Abre tu tablet (F7).", "success", 10000)
    TriggerClientEvent('QBCore:Notify', src, "Has reclutado con éxito a " .. Target.PlayerData.charinfo.firstname, "success")

    SetTimeout(500, function()
        RefreshOrgForMembers(bossGang.name)
    end)
end)

-- =========================================================================
-- FABRICACIÓN (CRAFTING DE ARMAS Y DROGAS)
-- =========================================================================
RegisterNetEvent('spain_criminal:server:craftItem', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data then return end

    local craftType = data.type
    local recipeId = data.recipeId
    local recipe = nil

    local list = (craftType == 'weapon') and Config.WeaponsCrafting or Config.DrugsCrafting
    for _, item in ipairs(list) do
        if item.id == recipeId then
            recipe = item
            break
        end
    end

    if not recipe then return end

    -- Verificar que el jugador tiene todos los materiales
    local hasAllMaterials = true
    for _, mat in ipairs(recipe.materials) do
        local userItem = Player.Functions.GetItemByName(mat.item)
        if not userItem or userItem.amount < mat.amount then
            hasAllMaterials = false
            break
        end
    end

    if not hasAllMaterials then
        TriggerClientEvent('QBCore:Notify', src, "Te faltan materiales o precursores para completar la fabricación.", "error")
        return
    end

    -- Retirar materiales
    for _, mat in ipairs(recipe.materials) do
        Player.Functions.RemoveItem(mat.item, mat.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[mat.item] or { label = mat.label }, "remove")
    end

    -- Entregar producto fabricado
    Player.Functions.AddItem(recipe.item, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[recipe.item] or { label = recipe.label }, "add")
    TriggerClientEvent('QBCore:Notify', src, "¡Fabricación completada: " .. recipe.label .. "!", "success")
end)

-- =========================================================================
-- TIENDA DE MATERIALES Y COMPRA DE TABLET
-- =========================================================================
RegisterNetEvent('spain_criminal:server:buyMaterial', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data then return end

    local price = tonumber(data.price) or 0
    local item = data.item
    local label = data.label or item

    if Player.Functions.RemoveMoney('cash', price) or Player.Functions.RemoveMoney('bank', price) then
        Player.Functions.AddItem(item, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item] or { label = label }, "add")
        TriggerClientEvent('QBCore:Notify', src, "Has comprado 1x " .. label .. " por €" .. price, "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "No tienes suficiente dinero para comprar este suministro.", "error")
    end
end)

RegisterNetEvent('spain_criminal:server:buyTabletNpc', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local price = Config.NPC.tabletPrice or 3500
    if Player.Functions.RemoveMoney('cash', price) or Player.Functions.RemoveMoney('bank', price) then
        Player.Functions.AddItem(Config.ItemName, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ItemName] or { label = "Tablet Criminal" }, "add")
        TriggerClientEvent('QBCore:Notify', src, "Has adquirido la Tablet Criminal Ilegal. Puedes abrirla con la tecla F7.", "success", 8000)
    else
        TriggerClientEvent('QBCore:Notify', src, "Necesitas €" .. price .. " para comprar el terminal cifrado.", "error")
    end
end)

-- =========================================================================
-- GARAJE PRIVADO (SOLICITAR VEHÍCULO)
-- =========================================================================
RegisterNetEvent('spain_criminal:server:requestSpawnOrgVehicle', function(model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local gang = Player.PlayerData.gang
    if not gang or not Config.Organizations[gang.name] then return end

    local org = Config.Organizations[gang.name]
    local allowed = false
    local playerGrade = (gang.grade and gang.grade.level) or 0

    for _, v in ipairs(org.vehicles) do
        if v.model == model and playerGrade >= v.minGrade then
            allowed = true
            break
        end
    end

    if allowed then
        TriggerClientEvent('spain_criminal:client:spawnVehicle', src, model)
    else
        TriggerClientEvent('QBCore:Notify', src, "No tienes el rango mínimo en la organización para solicitar este vehículo.", "error")
    end
end)

-- =========================================================================
-- FUNCIÓN AUXILIAR DE ACTUALIZACIÓN
-- =========================================================================
function RefreshOrgForMembers(gangName)
    MySQL.query('SELECT * FROM criminal_organizations WHERE gang = ? LIMIT 1', { gangName }, function(orgRes)
        if not orgRes or not orgRes[1] then return end
        local orgData = orgRes[1]

        MySQL.query("SELECT citizenid, charinfo, gang FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(gang, '$.name')) = ?", { gangName }, function(pRes)
            local members = {}
            if pRes then
                for _, row in ipairs(pRes) do
                    local charinfo = json.decode(row.charinfo) or {}
                    local gangObj = json.decode(row.gang) or {}
                    local pOnline = QBCore.Functions.GetPlayerByCitizenId(row.citizenid)

                    table.insert(members, {
                        citizenid = row.citizenid,
                        name = (charinfo.firstname or 'Desconocido') .. ' ' .. (charinfo.lastname or ''),
                        gradeName = (gangObj.grade and gangObj.grade.name) or 'Miembro',
                        gradeLevel = (gangObj.grade and gangObj.grade.level) or 0,
                        isboss = gangObj.isboss or false,
                        online = pOnline ~= nil
                    })
                end
            end

            -- Emitir a todos los jugadores online de esa banda
            local players = QBCore.Functions.GetQBPlayers()
            for _, p in pairs(players) do
                if p.PlayerData.gang and p.PlayerData.gang.name == gangName then
                    TriggerClientEvent('spain_criminal:client:refreshOrgData', p.PlayerData.source, orgData, members)
                end
            end
        end)
    end)
end
