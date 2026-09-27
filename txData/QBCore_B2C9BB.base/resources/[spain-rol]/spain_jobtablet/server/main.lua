local QBCore = exports['qb-core']:GetCoreObject()

-- Obtener compañeros de trabajo conectados
QBCore.Functions.CreateCallback('spain_jobtablet:server:getColleagues', function(source, cb, jobName)
    local colleagues = {}
    local players = QBCore.Functions.GetQBPlayers()

    for _, player in pairs(players) do
        if player.PlayerData.job and player.PlayerData.job.name == jobName then
            local charinfo = player.PlayerData.charinfo or {}
            local name = (charinfo.firstname or 'Empleado') .. ' ' .. (charinfo.lastname or '')
            table.insert(colleagues, {
                name = name,
                grade = player.PlayerData.job.grade and player.PlayerData.job.grade.name or 'Oficial',
                onDuty = player.PlayerData.job.onduty or false,
                phone = charinfo.phone or 'N/A'
            })
        end
    end

    cb(colleagues)
end)
