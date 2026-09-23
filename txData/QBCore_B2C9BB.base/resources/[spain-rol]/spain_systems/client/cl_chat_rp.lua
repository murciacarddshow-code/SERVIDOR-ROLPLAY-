-- =========================================================================
-- SPAIN ROL - CLIENTE: SISTEMA DE CHAT ROLEPLAY Y PLANTILLAS VISUALES
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()

-- Registrar plantillas HTML con estilos exclusivos de Spain Rol
CreateThread(function()
    Wait(1000)

    -- Twitter
    TriggerEvent('chat:addTemplate', 'twt', [[
        <div style="background: rgba(29, 161, 242, 0.15); border-left: 4px solid #1DA1F2; padding: 6px 12px; margin: 4px 0; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.3); font-size: 13.5px;">
            <span style="color: #1DA1F2; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px;">🐦 Twitter</span> 
            <strong style="color: #FFFFFF;">@{0}</strong>: 
            <span style="color: #E8F5FD;">{1}</span>
        </div>
    ]])

    -- Anonimo
    TriggerEvent('chat:addTemplate', 'anon', [[
        <div style="background: rgba(33, 33, 33, 0.45); border-left: 4px solid #757575; padding: 6px 12px; margin: 4px 0; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.3); font-size: 13.5px;">
            <span style="color: #BDBDBD; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px;">🕵️ Anónimo</span>: 
            <span style="color: #ECEFF1; font-style: italic;">{0}</span>
        </div>
    ]])

    -- OOC (Out of Character)
    TriggerEvent('chat:addTemplate', 'ooc', [[
        <div style="background: rgba(45, 55, 72, 0.35); border-left: 4px solid #A0AEC0; padding: 6px 12px; margin: 4px 0; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.3); font-size: 13.5px;">
            <span style="color: #CBD5E0; font-weight: 800; letter-spacing: 0.5px;">💬 [OOC]</span> 
            <strong style="color: #EDF2F7;">[{0}] {1}</strong>: 
            <span style="color: #F7FAFC;">{2}</span>
        </div>
    ]])

    -- ME (Acciones)
    TriggerEvent('chat:addTemplate', 'me', [[
        <div style="background: rgba(142, 68, 173, 0.20); border-left: 4px solid #9B59B6; padding: 6px 12px; margin: 4px 0; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.3); font-size: 13.5px;">
            <span style="color: #D7BDE2; font-weight: bold; font-style: italic;">🟣 * {0} {1} *</span>
        </div>
    ]])

    -- DO (Entorno)
    TriggerEvent('chat:addTemplate', 'do', [[
        <div style="background: rgba(230, 126, 34, 0.20); border-left: 4px solid #E67E22; padding: 6px 12px; margin: 4px 0; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.3); font-size: 13.5px;">
            <span style="color: #FAD7A0; font-weight: bold; font-style: italic;">🟠 * {1} * ({0})</span>
        </div>
    ]])

    -- Policía
    TriggerEvent('chat:addTemplate', 'policia', [[
        <div style="background: rgba(21, 101, 192, 0.30); border-left: 4px solid #1E88E5; padding: 6px 12px; margin: 4px 0; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.3); font-size: 13.5px;">
            <span style="color: #64B5F6; font-weight: 800; letter-spacing: 0.5px;">🚨 [POLICÍA 091]</span> 
            <strong style="color: #BBDEFB;">Aviso de {0}</strong>: 
            <span style="color: #FFFFFF;">{1}</span>
        </div>
    ]])

    -- Emergencias 112 / EMS
    TriggerEvent('chat:addTemplate', 'ems', [[
        <div style="background: rgba(198, 40, 40, 0.30); border-left: 4px solid #E53935; padding: 6px 12px; margin: 4px 0; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.3); font-size: 13.5px;">
            <span style="color: #EF5350; font-weight: 800; letter-spacing: 0.5px;">🚑 [URGENCIAS 112]</span> 
            <strong style="color: #FFCDD2;">Aviso de {0}</strong>: 
            <span style="color: #FFFFFF;">{1}</span>
        </div>
    ]])

    -- Publicidad / Anuncio comercial
    TriggerEvent('chat:addTemplate', 'ad', [[
        <div style="background: rgba(46, 125, 50, 0.25); border-left: 4px solid #4CAF50; padding: 6px 12px; margin: 4px 0; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.3); font-size: 13.5px;">
            <span style="color: #81C784; font-weight: 800; letter-spacing: 0.5px;">📢 [PUBLICIDAD]</span> 
            <strong style="color: #C8E6C9;">{0}</strong>: 
            <span style="color: #FFFFFF;">{1}</span>
        </div>
    ]])

    -- Reporte / Soporte Staff
    TriggerEvent('chat:addTemplate', 'staff', [[
        <div style="background: rgba(243, 156, 18, 0.25); border-left: 4px solid #F39C12; padding: 6px 12px; margin: 4px 0; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.3); font-size: 13.5px;">
            <span style="color: #F9E79F; font-weight: 800; letter-spacing: 0.5px;">🛡️ [REPORTE STAFF]</span> 
            <strong style="color: #FCF3CF;">ID {0} ({1})</strong>: 
            <span style="color: #FFFFFF;">{2}</span>
        </div>
    ]])

    -- Sugerencias de comandos al escribir en el chat
    TriggerEvent('chat:addSuggestion', '/twt', 'Publicar un mensaje en la red social Twitter (visible para todos)', {
        { name = 'mensaje', help = 'Contenido de tu publicación en Twitter' }
    })
    TriggerEvent('chat:addSuggestion', '/twitter', 'Publicar un mensaje en la red social Twitter (visible para todos)', {
        { name = 'mensaje', help = 'Contenido de tu publicación en Twitter' }
    })
    TriggerEvent('chat:addSuggestion', '/anon', 'Enviar un mensaje anónimo sin revelar tu identidad', {
        { name = 'mensaje', help = 'Contenido del mensaje clandestino' }
    })
    TriggerEvent('chat:addSuggestion', '/ooc', 'Hablar fuera de personaje (Out Of Character) en el entorno cercano', {
        { name = 'mensaje', help = 'Mensaje OOC' }
    })
    TriggerEvent('chat:addSuggestion', '/me', 'Describir una acción realizada por tu personaje', {
        { name = 'acción', help = 'Ejemplo: saca la cartera de su bolsillo' }
    })
    TriggerEvent('chat:addSuggestion', '/do', 'Describir el entorno, ambiente o consecuencias de una situación', {
        { name = 'descripción', help = 'Ejemplo: el motor del coche estaría humeando' }
    })
    TriggerEvent('chat:addSuggestion', '/policia', 'Llamar a la Policía Nacional para solicitar patrullas o auxilio', {
        { name = 'motivo', help = 'Describa el motivo y ubicación del incidente' }
    })
    TriggerEvent('chat:addSuggestion', '/ems', 'Llamar a Urgencias Sanitarias (112) para solicitar una ambulancia', {
        { name = 'motivo', help = 'Describa la emergencia médica' }
    })
    TriggerEvent('chat:addSuggestion', '/ad', 'Publicar un anuncio clasificado en la prensa (€100)', {
        { name = 'anuncio', help = 'Texto de tu oferta o demanda comercial' }
    })
    TriggerEvent('chat:addSuggestion', '/ayuda', 'Solicitar asistencia técnica o soporte al equipo de administración', {
        { name = 'duda', help = 'Explica el problema o consulta' }
    })
    TriggerEvent('chat:addSuggestion', '/tx', 'Abrir el menú de gestión administrativa txAdmin en el juego')
end)

-- 3D Text flotante sobre la cabeza para /do
RegisterNetEvent('spain_chat:client:showDo3D', function(senderId, msg, senderName)
    local sender = GetPlayerFromServerId(senderId)
    CreateThread(function()
        local displayTime = 6000 + GetGameTimer()
        while displayTime > GetGameTimer() do
            local targetPed = GetPlayerPed(sender)
            if DoesEntityExist(targetPed) then
                local coords = GetEntityCoords(targetPed)
                local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z + 1.25)
                if onScreen then
                    SetTextScale(0.35, 0.35)
                    SetTextFont(4)
                    SetTextProportional(1)
                    SetTextColour(255, 178, 102, 215)
                    SetTextEntry("STRING")
                    SetTextCentre(1)
                    AddTextComponentString("* " .. msg .. " *")
                    DrawText(x, y)
                end
            end
            Wait(0)
        end
    end)
end)
