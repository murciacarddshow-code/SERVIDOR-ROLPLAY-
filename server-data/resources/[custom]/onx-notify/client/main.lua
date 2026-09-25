local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('onx-notify:client:SendAlert')
AddEventHandler('onx-notify:client:SendAlert', function(data)
    SendNUIMessage({
        action = 'notify',
        text = data.text,
        type = data.type or 'primary',
        length = data.length or 5000
    })
end)

RegisterCommand('testnotify', function()
    TriggerEvent('onx-notify:client:SendAlert', {
        text = "¡Esto es una notificación estilo ONX!",
        type = "primary",
        length = 5000
    })
    TriggerEvent('onx-notify:client:SendAlert', {
        text = "No tienes permiso para hacer esto.",
        type = "error",
        length = 5000
    })
    TriggerEvent('onx-notify:client:SendAlert', {
        text = "Acción realizada con éxito.",
        type = "success",
        length = 5000
    })
end, false)
