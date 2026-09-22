local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('spain_identity:client:showDocument', function(data, docType)
    local ped = PlayerPedId()
    RequestAnimDict("mp_common")
    while not HasAnimDict("mp_common") do Wait(10) end
    TaskPlayAnim(ped, "mp_common", "givetake2_a", 2.0, 2.0, 1500, 49, 0, false, false, false)

    local title = "DOCUMENTO NACIONAL DE IDENTIDAD (DNI)"
    if docType == 'driver' then
        title = "DIRECCION GENERAL DE TRAFICO (DGT) - PERMISO DE CONDUCIR"
    elseif docType == 'weapon' then
        title = "MINISTERIO DEL INTERIOR - LICENCIA DE ARMAS TIPO B"
    end

    TriggerEvent('chat:addMessage', {
        template = '<div style="padding: 12px; margin: 8px 0; background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%); color: #fff; border-radius: 8px; border-left: 5px solid #e74c3c; box-shadow: 0 4px 6px rgba(0,0,0,0.3); font-family: sans-serif;"><div style="font-weight: bold; font-size: 14px; text-transform: uppercase; border-bottom: 1px solid rgba(255,255,255,0.2); padding-bottom: 5px; margin-bottom: 6px;">🇪🇸 {0}</div><div style="font-size: 13px; line-height: 1.5;"><b>Nombre y Apellidos:</b> {1} {2}<br><b>DNI / NIE:</b> {3}<br><b>Nacionalidad:</b> Espanola<br><b>Fecha de Nacimiento:</b> {4}<br><b>Sexo:</b> {5}</div></div>',
        args = { title, data.firstname, data.lastname, data.citizenid, data.birthdate, (data.gender == 0 and "Hombre" or "Mujer") }
    })
end)
