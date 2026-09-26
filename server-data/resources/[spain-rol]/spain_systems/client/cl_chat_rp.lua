-- =========================================================================
-- SPAIN ROL - CLIENTE: SISTEMA DE CHAT ROLEPLAY Y PLANTILLAS VISUALES
-- =========================================================================

local QBCore = exports['qb-core']:GetCoreObject()

-- Registrar plantillas HTML con estilos modernos y elegantes de Spain Rol
CreateThread(function()
    Wait(800)

    -- 1. Twitter / Red Social
    TriggerEvent('chat:addTemplate', 'twt', [[
        <div class="msg-header">
            <div class="msg-meta">
                <span class="badge badge-twt"><i class="fa-brands fa-twitter"></i> TWITTER</span>
                <span class="msg-author" style="color: #38bdf8;">@{0}</span>
            </div>
        </div>
        <div class="msg-content" style="color: #e0f2fe;">{1}</div>
    ]])

    -- 2. Anónimo / Clandestino
    TriggerEvent('chat:addTemplate', 'anon', [[
        <div class="msg-header">
            <div class="msg-meta">
                <span class="badge badge-anon"><i class="fa-solid fa-user-secret"></i> ANÓNIMO</span>
            </div>
        </div>
        <div class="msg-content" style="color: #fecdd3; font-style: italic;">{0}</div>
    ]])

    -- 3. OOC (Out of Character)
    TriggerEvent('chat:addTemplate', 'ooc', [[
        <div class="msg-header">
            <div class="msg-meta">
                <span class="badge badge-ooc"><i class="fa-solid fa-comment-dots"></i> OOC</span>
                <span class="msg-author" style="color: #cbd5e1;">[{0}] {1}</span>
            </div>
        </div>
        <div class="msg-content" style="color: #f8fafc;">{2}</div>
    ]])

    -- 4. ME (Acciones)
    TriggerEvent('chat:addTemplate', 'me', [[
        <div class="msg-header">
            <div class="msg-meta">
                <span class="badge" style="background: rgba(168, 85, 247, 0.25); color: #d8b4fe; border: 1px solid rgba(168, 85, 247, 0.4);"><i class="fa-solid fa-hand-sparkles"></i> ACCIÓN</span>
                <span class="msg-author" style="color: #e9d5ff;">{0}</span>
            </div>
        </div>
        <div class="msg-content" style="color: #e9d5ff; font-style: italic;">* {1} *</div>
    ]])

    -- 5. DO (Entorno)
    TriggerEvent('chat:addTemplate', 'do', [[
        <div class="msg-header">
            <div class="msg-meta">
                <span class="badge" style="background: rgba(249, 115, 22, 0.25); color: #fdba74; border: 1px solid rgba(249, 115, 22, 0.4);"><i class="fa-solid fa-eye"></i> ENTORNO</span>
                <span class="msg-author" style="color: #fed7aa;">({0})</span>
            </div>
        </div>
        <div class="msg-content" style="color: #fed7aa; font-style: italic;">* {1} *</div>
    ]])

    -- 6. Policía Nacional (091)
    TriggerEvent('chat:addTemplate', 'policia', [[
        <div class="msg-header">
            <div class="msg-meta">
                <span class="badge badge-policia"><i class="fa-solid fa-shield-halved"></i> POLICÍA 091</span>
                <span class="msg-author" style="color: #93c5fd;">Aviso de {0}</span>
            </div>
        </div>
        <div class="msg-content" style="color: #ffffff;">{1}</div>
    ]])

    -- 7. Urgencias Sanitarias (112)
    TriggerEvent('chat:addTemplate', 'ems', [[
        <div class="msg-header">
            <div class="msg-meta">
                <span class="badge badge-ems"><i class="fa-solid fa-truck-medical"></i> URGENCIAS 112</span>
                <span class="msg-author" style="color: #fca5a5;">Aviso de {0}</span>
            </div>
        </div>
        <div class="msg-content" style="color: #ffffff;">{1}</div>
    ]])

    -- 8. Publicidad Comercial
    TriggerEvent('chat:addTemplate', 'ad', [[
        <div class="msg-header">
            <div class="msg-meta">
                <span class="badge badge-ad"><i class="fa-solid fa-bullhorn"></i> PUBLICIDAD</span>
                <span class="msg-author" style="color: #6ee7b7;">{0}</span>
            </div>
        </div>
        <div class="msg-content" style="color: #ffffff;">{1}</div>
    ]])

    -- 9. Reporte y Soporte Staff
    TriggerEvent('chat:addTemplate', 'staff', [[
        <div class="msg-header">
            <div class="msg-meta">
                <span class="badge badge-staff"><i class="fa-solid fa-shield-cat"></i> REPORTE STAFF</span>
                <span class="msg-author" style="color: #fde68a;">ID {0} ({1})</span>
            </div>
        </div>
        <div class="msg-content" style="color: #ffffff;">{2}</div>
    ]])

    -- =========================================================================
    -- SUGERENCIAS DE COMANDOS AMPLIADAS CON AUTOCOMPLETADO
    -- =========================================================================
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
    TriggerEvent('chat:addSuggestion', '/911', 'Llamar a la Policía Nacional para dar aviso urgente', {
        { name = 'motivo', help = 'Incidente y ubicación' }
    })
    TriggerEvent('chat:addSuggestion', '/ems', 'Llamar a Urgencias Sanitarias (112) para solicitar una ambulancia', {
        { name = 'motivo', help = 'Describa la emergencia médica' }
    })
    TriggerEvent('chat:addSuggestion', '/112', 'Llamar a Urgencias Sanitarias para auxilio médico', {
        { name = 'motivo', help = 'Describa la emergencia médica' }
    })
    TriggerEvent('chat:addSuggestion', '/ad', 'Publicar un anuncio clasificado en la prensa (€100)', {
        { name = 'anuncio', help = 'Texto de tu oferta o demanda comercial' }
    })
    TriggerEvent('chat:addSuggestion', '/ayuda', 'Solicitar asistencia técnica o soporte al equipo de administración', {
        { name = 'duda', help = 'Explica el problema o consulta' }
    })
    TriggerEvent('chat:addSuggestion', '/report', 'Enviar un reporte detallado al equipo de Staff', {
        { name = 'motivo', help = 'Explica el motivo del reporte' }
    })
    TriggerEvent('chat:addSuggestion', '/trabajos', 'Abrir la tablet moderna de empleos Spain Works Pro')
    TriggerEvent('chat:addSuggestion', '/darllaves', 'Entregar las llaves de tu vehículo a un jugador cercano', {
        { name = 'id', help = 'ID del jugador' }
    })
    TriggerEvent('chat:addSuggestion', '/dni', 'Consultar y mostrar tu Documento Nacional de Identidad')
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
