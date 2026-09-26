/**
 * SPAIN ROL - CHAT MODERNO Y AVANZADO
 * Motor NUI ultra-optimizado, auto-hide reactivo y renderizado visual moderno.
 */

(function () {
  'use strict';

  const RESOURCE_NAME = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'chat';

  // Configuración
  const CONFIG = {
    fadeDelay: 7500,        // Milisegundos antes de ocultarse si nadie habla
    graceDelayOnClose: 5000,// Milisegundos visible tras cerrar el input
    maxMessages: 100,       // Límite de mensajes en memoria
    maxHistory: 40          // Historial de comandos enviados
  };

  // Estados de Ocultación de FiveM
  const HIDE_STATES = {
    SHOW_WHEN_ACTIVE: 0,
    ALWAYS_SHOW: 1,
    ALWAYS_HIDE: 2
  };

  let currentHideState = HIDE_STATES.SHOW_WHEN_ACTIVE;
  let isInputActive = false;
  let fadeTimer = null;
  let templates = {};
  let suggestions = [];
  let modes = [{ name: '_global', displayName: 'GLOBAL', color: '#38bdf8' }];
  let currentModeIdx = 0;

  // Historial de Comandos
  let messageHistory = [];
  let historyIndex = -1;
  let currentDraft = '';

  // Sugerencias activas
  let activeSuggestionIndex = -1;
  let filteredSuggestions = [];

  // Elementos del DOM
  const dom = {
    container: document.getElementById('chat-container'),
    messages: document.getElementById('chat-messages'),
    inputWrapper: document.getElementById('chat-input-wrapper'),
    input: document.getElementById('chat-input'),
    modeBtn: document.getElementById('chat-mode'),
    modeLabel: document.getElementById('chat-mode-label'),
    sendBtn: document.getElementById('chat-send-btn'),
    suggestionsWrapper: document.getElementById('chat-suggestions'),
    suggestionsList: document.getElementById('suggestions-list')
  };

  // =========================================================================
  // SISTEMA DE AUTO-HIDE (OCULTARSE SI NADIE HABLA)
  // =========================================================================

  function showChat() {
    if (currentHideState === HIDE_STATES.ALWAYS_HIDE) return;
    dom.container.classList.remove('hidden');
  }

  function hideChat() {
    if (isInputActive) return; // Nunca ocultar mientras se esté escribiendo
    if (currentHideState === HIDE_STATES.ALWAYS_SHOW) return;
    dom.container.classList.add('hidden');
  }

  function resetFadeTimer(delay) {
    if (fadeTimer) {
      clearTimeout(fadeTimer);
      fadeTimer = null;
    }

    showChat();

    if (currentHideState === HIDE_STATES.SHOW_WHEN_ACTIVE && !isInputActive) {
      fadeTimer = setTimeout(() => {
        hideChat();
      }, delay || CONFIG.fadeDelay);
    }
  }

  // =========================================================================
  // UTILIDADES & PARSERS
  // =========================================================================

  function escapeHtml(text) {
    if (typeof text !== 'string') return text;
    return text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  function getCurrentTime() {
    const now = new Date();
    const h = String(now.getHours()).padStart(2, '0');
    const m = String(now.getMinutes()).padStart(2, '0');
    return `${h}:${m}`;
  }

  // Parsear códigos de color FiveM (^1 ... ^9, ^0, ~r~, etc.)
  function parseFiveMColors(text) {
    if (!text || typeof text !== 'string') return '';
    let parsed = escapeHtml(text);

    // Reemplazo de códigos FiveM ^1 a ^9
    parsed = parsed.replace(/\^([0-9])/g, (match, colorNum) => {
      return `</span><span class="col-${colorNum}">`;
    });

    // Reemplazo de códigos GTA ~r~, ~g~, ~b~, ~y~, ~w~
    const gtaColors = { r: 'col-1', g: 'col-2', y: 'col-3', b: 'col-4', w: 'col-0', p: 'col-6' };
    parsed = parsed.replace(/~([rgybwp])~/gi, (match, code) => {
      const cls = gtaColors[code.toLowerCase()] || 'col-0';
      return `</span><span class="${cls}">`;
    });

    return `<span>${parsed}</span>`;
  }

  // =========================================================================
  // RENDERIZADO DE MENSAJES MODERNOS
  // =========================================================================

  function addMessage(data) {
    if (!data) return;

    const time = getCurrentTime();
    let msgEl = document.createElement('div');
    msgEl.className = 'msg-item';

    // 1. Mensaje con plantilla registrada (templateId)
    if (data.templateId && templates[data.templateId]) {
      let html = templates[data.templateId];
      if (Array.isArray(data.args)) {
        data.args.forEach((arg, idx) => {
          const val = parseFiveMColors(String(arg));
          html = html.replace(new RegExp(`\\{${idx}\\}`, 'g'), val);
        });
      }
      msgEl.className += ` type-${data.templateId}`;
      msgEl.innerHTML = html;
    }
    // 2. Mensaje con plantilla personalizada directa
    else if (data.template) {
      let html = data.template;
      if (Array.isArray(data.args)) {
        data.args.forEach((arg, idx) => {
          const val = parseFiveMColors(String(arg));
          html = html.replace(new RegExp(`\\{${idx}\\}`, 'g'), val);
        });
      }
      msgEl.innerHTML = html;
    }
    // 3. Mensaje estándar con argumentos (author, text)
    else if (Array.isArray(data.args) && data.args.length > 0) {
      let author = '';
      let content = '';

      if (data.args.length === 1) {
        content = data.args[0];
      } else {
        author = data.args[0];
        content = data.args.slice(1).join(' ');
      }

      // Detección inteligente de tipo de canal por nombre de autor
      let typeClass = '';
      let badgeHtml = '';

      const lowerAuthor = (author || '').toLowerCase();
      if (lowerAuthor.includes('ooc') || lowerAuthor.includes('fuera de rol')) {
        typeClass = 'type-ooc';
        badgeHtml = '<span class="badge badge-ooc"><i class="fa-solid fa-comment"></i> OOC</span>';
      } else if (lowerAuthor.includes('twitter') || lowerAuthor.includes('twt')) {
        typeClass = 'type-twt';
        badgeHtml = '<span class="badge badge-twt"><i class="fa-brands fa-twitter"></i> TWITTER</span>';
      } else if (lowerAuthor.includes('anónimo') || lowerAuthor.includes('anonimo')) {
        typeClass = 'type-anon';
        badgeHtml = '<span class="badge badge-anon"><i class="fa-solid fa-user-secret"></i> ANÓNIMO</span>';
      } else if (lowerAuthor.includes('policía') || lowerAuthor.includes('091')) {
        typeClass = 'type-policia';
        badgeHtml = '<span class="badge badge-policia"><i class="fa-solid fa-shield-halved"></i> POLICÍA</span>';
      } else if (lowerAuthor.includes('urgencias') || lowerAuthor.includes('112') || lowerAuthor.includes('ems')) {
        typeClass = 'type-ems';
        badgeHtml = '<span class="badge badge-ems"><i class="fa-solid fa-truck-medical"></i> 112 EMS</span>';
      } else if (lowerAuthor.includes('publicidad') || lowerAuthor.includes('anuncio')) {
        typeClass = 'type-ad';
        badgeHtml = '<span class="badge badge-ad"><i class="fa-solid fa-bullhorn"></i> ANUNCIO</span>';
      } else if (lowerAuthor.includes('staff') || lowerAuthor.includes('admin') || lowerAuthor.includes('reporte')) {
        typeClass = 'type-staff';
        badgeHtml = '<span class="badge badge-staff"><i class="fa-solid fa-shield-cat"></i> STAFF</span>';
      } else if (lowerAuthor.includes('system') || lowerAuthor.includes('sistema') || lowerAuthor.includes('servidor')) {
        typeClass = 'type-system';
        badgeHtml = '<span class="badge badge-system"><i class="fa-solid fa-bolt"></i> SERVIDOR</span>';
      }

      if (typeClass) msgEl.className += ` ${typeClass}`;

      let colorStyle = '';
      if (Array.isArray(data.color) && data.color.length === 3) {
        colorStyle = `color: rgb(${data.color[0]}, ${data.color[1]}, ${data.color[2]});`;
      }

      let headerHtml = '';
      if (author || badgeHtml) {
        headerHtml = `
          <div class="msg-header">
            <div class="msg-meta">
              ${badgeHtml}
              ${author ? `<span class="msg-author" style="${colorStyle}">${parseFiveMColors(author)}</span>` : ''}
            </div>
            <span class="msg-time">${time}</span>
          </div>
        `;
      }

      msgEl.innerHTML = `
        ${headerHtml}
        <div class="msg-content">${parseFiveMColors(content)}</div>
      `;
    }

    // Insertar en el chat
    dom.messages.appendChild(msgEl);

    // Limitar cantidad máxima de mensajes para rendimiento óptimo
    while (dom.messages.children.length > CONFIG.maxMessages) {
      dom.messages.removeChild(dom.messages.firstChild);
    }

    // Auto-scroll hacia el final
    dom.messages.scrollTop = dom.messages.scrollHeight;

    // Reactivar visibilidad con auto-fade suave
    resetFadeTimer(CONFIG.fadeDelay);
  }

  // =========================================================================
  // GESTIÓN DE LA BARRA DE ENTRADA (INPUT)
  // =========================================================================

  function openChatInput(initialText) {
    isInputActive = true;
    showChat();
    dom.inputWrapper.classList.remove('hidden');

    // Cancelar cualquier temporizador de fade
    if (fadeTimer) {
      clearTimeout(fadeTimer);
      fadeTimer = null;
    }

    const initVal = (typeof initialText === 'string') ? initialText : '';
    dom.input.value = initVal;
    dom.input.style.height = '22px';
    historyIndex = -1;
    currentDraft = '';

    if (initVal.length > 0) {
      updateSuggestions(initVal);
    } else {
      hideSuggestions();
    }

    // Enfocar el input y colocar el cursor al final
    setTimeout(() => {
      dom.input.focus();
      if (initVal.length > 0) {
        dom.input.selectionStart = dom.input.selectionEnd = initVal.length;
      }
    }, 50);

    // Auto-scroll al fondo
    dom.messages.scrollTop = dom.messages.scrollHeight;
  }

  function closeChatInput(canceled) {
    if (!isInputActive) return;

    const message = dom.input.value.trim();
    isInputActive = false;
    dom.inputWrapper.classList.add('hidden');
    hideSuggestions();

    // Enviar resultado a FiveM
    if (!canceled && message.length > 0) {
      // Guardar en historial
      messageHistory.unshift(message);
      if (messageHistory.length > CONFIG.maxHistory) {
        messageHistory.pop();
      }

      const activeMode = modes[currentModeIdx] ? modes[currentModeIdx].name : '_global';
      fetch(`https://${RESOURCE_NAME}/chatResult`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: message, mode: activeMode })
      }).catch(() => {});
    } else {
      fetch(`https://${RESOURCE_NAME}/chatResult`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ canceled: true })
      }).catch(() => {});
    }

    // Gracia de 5 segundos visible tras cerrar el input antes de desvanecerse
    resetFadeTimer(CONFIG.graceDelayOnClose);
  }

  // =========================================================================
  // AUTOCOMPLETADO DE COMANDOS (SUGGESTIONS)
  // =========================================================================

  function updateSuggestions(text) {
    if (!text.startsWith('/')) {
      hideSuggestions();
      return;
    }

    const query = text.toLowerCase().trim();
    filteredSuggestions = suggestions.filter(s => {
      const name = s.name.toLowerCase();
      return name.startsWith(query) || (name.includes(query.replace('/', '')));
    }).slice(0, 7); // Mostrar máximo 7 sugerencias

    if (filteredSuggestions.length === 0) {
      hideSuggestions();
      return;
    }

    dom.suggestionsList.innerHTML = '';
    activeSuggestionIndex = 0;

    filteredSuggestions.forEach((s, idx) => {
      const item = document.createElement('div');
      item.className = `suggestion-item ${idx === 0 ? 'active' : ''}`;

      let paramsStr = '';
      if (Array.isArray(s.params)) {
        paramsStr = ' ' + s.params.map(p => `[${p.name || ''}]`).join(' ');
      }

      item.innerHTML = `
        <div>
          <span class="sugg-name">${escapeHtml(s.name)}</span>
          <span class="sugg-params">${escapeHtml(paramsStr)}</span>
        </div>
        ${s.help ? `<span class="sugg-help">${escapeHtml(s.help)}</span>` : ''}
      `;

      item.addEventListener('click', () => {
        applySuggestion(s);
      });

      dom.suggestionsList.appendChild(item);
    });

    dom.suggestionsWrapper.classList.remove('hidden');
  }

  function hideSuggestions() {
    dom.suggestionsWrapper.classList.add('hidden');
    dom.suggestionsList.innerHTML = '';
    activeSuggestionIndex = -1;
    filteredSuggestions = [];
  }

  function applySuggestion(suggestion) {
    if (!suggestion) return;
    dom.input.value = suggestion.name + ' ';
    dom.input.focus();
    hideSuggestions();
  }

  // =========================================================================
  // NAVEGACIÓN POR TECLADO
  // =========================================================================

  dom.input.addEventListener('keydown', (e) => {
    // 1. Enviar con ENTER
    if (e.key === 'Enter') {
      e.preventDefault();
      // Si hay una sugerencia seleccionada y el usuario solo escribió parte del comando
      if (!dom.suggestionsWrapper.classList.contains('hidden') && activeSuggestionIndex >= 0 && filteredSuggestions[activeSuggestionIndex]) {
        const fullCmd = filteredSuggestions[activeSuggestionIndex].name;
        if (dom.input.value.trim() === fullCmd || dom.input.value.trim().length <= 3) {
          applySuggestion(filteredSuggestions[activeSuggestionIndex]);
          return;
        }
      }
      closeChatInput(false);
    }
    // 2. Cancelar con ESC
    else if (e.key === 'Escape') {
      e.preventDefault();
      closeChatInput(true);
    }
    // 3. Autocompletar o cambiar de modo con TAB
    else if (e.key === 'Tab') {
      e.preventDefault();
      if (!dom.suggestionsWrapper.classList.contains('hidden') && activeSuggestionIndex >= 0 && filteredSuggestions[activeSuggestionIndex]) {
        applySuggestion(filteredSuggestions[activeSuggestionIndex]);
      } else {
        cycleMode();
      }
    }
    // 4. Navegación con Flecha ARRIBA
    else if (e.key === 'ArrowUp') {
      // Navegación en sugerencias
      if (!dom.suggestionsWrapper.classList.contains('hidden') && filteredSuggestions.length > 0) {
        e.preventDefault();
        activeSuggestionIndex = (activeSuggestionIndex - 1 + filteredSuggestions.length) % filteredSuggestions.length;
        updateActiveSuggestion();
      }
      // Navegación en historial
      else {
        e.preventDefault();
        if (historyIndex === -1) {
          currentDraft = dom.input.value;
        }
        if (historyIndex + 1 < messageHistory.length) {
          historyIndex++;
          dom.input.value = messageHistory[historyIndex];
          dom.input.selectionStart = dom.input.selectionEnd = dom.input.value.length;
        }
      }
    }
    // 5. Navegación con Flecha ABAJO
    else if (e.key === 'ArrowDown') {
      // Navegación en sugerencias
      if (!dom.suggestionsWrapper.classList.contains('hidden') && filteredSuggestions.length > 0) {
        e.preventDefault();
        activeSuggestionIndex = (activeSuggestionIndex + 1) % filteredSuggestions.length;
        updateActiveSuggestion();
      }
      // Navegación en historial
      else {
        e.preventDefault();
        if (historyIndex > 0) {
          historyIndex--;
          dom.input.value = messageHistory[historyIndex];
        } else if (historyIndex === 0) {
          historyIndex = -1;
          dom.input.value = currentDraft;
        }
        dom.input.selectionStart = dom.input.selectionEnd = dom.input.value.length;
      }
    }
  });

  dom.input.addEventListener('input', () => {
    // Auto-expandir altura de textarea
    dom.input.style.height = 'auto';
    dom.input.style.height = Math.min(dom.input.scrollHeight, 80) + 'px';

    // Actualizar autocompletado
    updateSuggestions(dom.input.value);
  });

  function updateActiveSuggestion() {
    const items = dom.suggestionsList.querySelectorAll('.suggestion-item');
    items.forEach((item, idx) => {
      if (idx === activeSuggestionIndex) {
        item.classList.add('active');
        item.scrollIntoView({ block: 'nearest' });
      } else {
        item.classList.remove('active');
      }
    });
  }

  // =========================================================================
  // GESTIÓN DE MODOS (GLOBAL, OOC, etc.)
  // =========================================================================

  function cycleMode() {
    if (modes.length <= 1) return;
    currentModeIdx = (currentModeIdx + 1) % modes.length;
    updateModeDisplay();
  }

  function updateModeDisplay() {
    const mode = modes[currentModeIdx] || { displayName: 'GLOBAL', color: '#38bdf8' };
    dom.modeLabel.textContent = mode.displayName;
    dom.modeBtn.style.color = mode.color || '#38bdf8';
    dom.modeBtn.style.borderColor = mode.color ? mode.color + '55' : 'rgba(56, 189, 248, 0.35)';
  }

  dom.modeBtn.addEventListener('click', cycleMode);
  dom.sendBtn.addEventListener('click', () => closeChatInput(false));

  // =========================================================================
  // RECEPCIÓN DE MENSAJES NUI DE FIVEM
  // =========================================================================

  window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.type) return;

    switch (data.type) {
      // 1. Abrir Input
      case 'ON_OPEN':
        openChatInput(data.initial || '');
        break;

      // 2. Nuevo Mensaje
      case 'ON_MESSAGE':
        addMessage(data.message);
        break;

      // 3. Limpiar Mensajes
      case 'ON_CLEAR':
        dom.messages.innerHTML = '';
        break;

      // 4. Agregar Plantilla HTML
      case 'ON_TEMPLATE_ADD':
        if (data.template && data.template.id) {
          templates[data.template.id] = data.template.html;
        }
        break;

      // 5. Agregar Sugerencia de Comando
      case 'ON_SUGGESTION_ADD':
        if (Array.isArray(data.suggestion)) {
          data.suggestion.forEach(s => {
            if (s && s.name) {
              const existingIdx = suggestions.findIndex(x => x.name === s.name);
              if (existingIdx !== -1) suggestions[existingIdx] = s;
              else suggestions.push(s);
            }
          });
        } else if (data.suggestion && data.suggestion.name) {
          const s = data.suggestion;
          const existingIdx = suggestions.findIndex(x => x.name === s.name);
          if (existingIdx !== -1) suggestions[existingIdx] = s;
          else suggestions.push(s);
        }
        break;

      // 6. Eliminar Sugerencia de Comando
      case 'ON_SUGGESTION_REMOVE':
        if (data.name) {
          suggestions = suggestions.filter(s => s.name !== data.name);
        }
        break;

      // 7. Modos de Chat
      case 'ON_MODE_ADD':
        if (data.mode && data.mode.name) {
          if (!modes.some(m => m.name === data.mode.name)) {
            modes.push(data.mode);
          }
        }
        break;

      case 'ON_MODE_REMOVE':
        if (data.name) {
          modes = modes.filter(m => m.name !== data.name);
          if (currentModeIdx >= modes.length) currentModeIdx = 0;
          updateModeDisplay();
        }
        break;

      // 8. Cambio de Estado de Pantalla (Pausa / Fadeout / toggleChat)
      case 'ON_SCREEN_STATE_CHANGE':
        currentHideState = data.hideState;
        if (currentHideState === HIDE_STATES.ALWAYS_HIDE) {
          dom.container.classList.add('hidden');
        } else if (currentHideState === HIDE_STATES.ALWAYS_SHOW) {
          dom.container.classList.remove('hidden');
        } else if (currentHideState === HIDE_STATES.SHOW_WHEN_ACTIVE) {
          resetFadeTimer(CONFIG.fadeDelay);
        }
        break;

      default:
        break;
    }
  });

  // =========================================================================
  // INICIALIZACIÓN
  // =========================================================================

  document.addEventListener('DOMContentLoaded', () => {
    // Notificar al cliente FiveM que el chat cargó
    fetch(`https://${RESOURCE_NAME}/loaded`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    }).catch(() => {});

    // Iniciar oculto por defecto
    hideChat();
    updateModeDisplay();
  });

})();