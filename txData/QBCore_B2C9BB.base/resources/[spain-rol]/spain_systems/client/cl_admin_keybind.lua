-- =========================================================================
-- SPAIN ROL - PANEL DE ADMINISTRADOR VINCULADO A F10
-- =========================================================================
-- Mapea la tecla F10 directamente al panel de administración del servidor.

local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('adminmenu_f10', function()
    TriggerEvent('qb-admin:client:openMenu')
end, false)

RegisterKeyMapping('adminmenu_f10', 'Abrir Panel de Administrador', 'keyboard', 'F10')
