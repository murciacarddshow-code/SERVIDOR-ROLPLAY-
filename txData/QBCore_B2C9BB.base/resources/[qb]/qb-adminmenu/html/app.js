let allPlayers = [];
let selectedPlayer = null;
let moneyActionType = 'give'; // 'give' | 'remove'
let punishActionType = 'kick'; // 'kick' | 'ban'
let staffToggles = {
    godmode: false,
    noclip: false,
    invisible: false
};

// ========================================================
// COMUNICACIÓN NUI CON LUA
// ========================================================
function postNUI(endpoint, data = {}) {
    return fetch(`https://qb-adminmenu/${endpoint}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    }).then(resp => resp.json()).catch(err => {
        // En caso de que no devuelva JSON
        return { status: 'ok' };
    });
}

function closeAdminMenu() {
    document.getElementById('admin-app').style.display = 'none';
    closeAllModals();
    postNUI('close');
}

function closeAllModals() {
    document.getElementById('modal-player-actions').style.display = 'none';
    document.getElementById('submodal-money').style.display = 'none';
    document.getElementById('submodal-job').style.display = 'none';
    document.getElementById('submodal-punish').style.display = 'none';
}

// ========================================================
// ESCUCHA DE MENSAJES DESDE FIVEM (LUA)
// ========================================================
window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'open') {
        document.getElementById('admin-app').style.display = 'flex';
        
        if (data.adminName) {
            document.getElementById('stat-admin-name').innerText = data.adminName;
        }

        if (data.toggles) {
            staffToggles = Object.assign(staffToggles, data.toggles);
            updateToggleButtons();
        }

        fetchAndRenderPlayers();
    } else if (data.action === 'close') {
        closeAdminMenu();
    } else if (data.action === 'updatePlayers') {
        if (data.players) {
            allPlayers = data.players;
            renderPlayers(allPlayers);
        }
    }
});

// Tecla ESCAPE para cerrar
window.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' || event.key === 'F10') {
        // Si hay un submodal abierto, cerrarlo primero
        const subMoney = document.getElementById('submodal-money');
        const subJob = document.getElementById('submodal-job');
        const subPunish = document.getElementById('submodal-punish');
        const modalPlayer = document.getElementById('modal-player-actions');

        if (subMoney.style.display === 'flex') {
            subMoney.style.display = 'none';
        } else if (subJob.style.display === 'flex') {
            subJob.style.display = 'none';
        } else if (subPunish.style.display === 'flex') {
            subPunish.style.display = 'none';
        } else if (modalPlayer.style.display === 'flex') {
            modalPlayer.style.display = 'none';
        } else {
            closeAdminMenu();
        }
    }
});

// ========================================================
// GESTIÓN DE PESTAÑAS (TABS)
// ========================================================
document.querySelectorAll('.nav-btn').forEach(button => {
    button.addEventListener('click', () => {
        document.querySelectorAll('.nav-btn').forEach(btn => btn.classList.remove('active'));
        document.querySelectorAll('.content-tab').forEach(tab => tab.classList.remove('active'));

        button.classList.add('active');
        const targetTabId = button.getAttribute('data-tab');
        const targetTab = document.getElementById(targetTabId);
        if (targetTab) {
            targetTab.classList.add('active');
        }

        if (targetTabId === 'tab-players') {
            fetchAndRenderPlayers();
        }
    });
});

// Botón Cerrar Superior
document.getElementById('btn-close-app').addEventListener('click', closeAdminMenu);

// ========================================================
// JUGADORES: OBTENCIÓN, BÚSQUEDA Y RENDER
// ========================================================
function fetchAndRenderPlayers() {
    postNUI('getPlayers').then(data => {
        if (data && data.players) {
            allPlayers = data.players;
            renderPlayers(allPlayers);
        }
    });
}

function renderPlayers(players) {
    const grid = document.getElementById('players-list-grid');
    const emptyAlert = document.getElementById('no-players-alert');
    const countSpan = document.getElementById('stat-online-count');
    
    countSpan.innerText = players.length;
    grid.innerHTML = '';

    if (players.length === 0) {
        emptyAlert.style.display = 'flex';
        return;
    } else {
        emptyAlert.style.display = 'none';
    }

    players.forEach(p => {
        const tile = document.createElement('div');
        tile.className = 'player-tile';
        
        const jobLabel = p.jobLabel || p.job || 'Desempleado';
        const jobGrade = p.jobGrade !== undefined ? `[${p.jobGrade}]` : '';
        const cashFmt = (p.cash || 0).toLocaleString('es-ES');
        const bankFmt = (p.bank || 0).toLocaleString('es-ES');

        tile.innerHTML = `
            <div class="tile-top">
                <div class="tile-id-badge">#${p.id}</div>
                <div class="tile-names">
                    <div class="tile-charname">${escapeHtml(p.charname || 'Sin Personaje')}</div>
                    <div class="tile-accountname"><i class="fa-brands fa-steam"></i> ${escapeHtml(p.name || 'Desconocido')}</div>
                </div>
            </div>
            <div class="tile-middle">
                <div class="tile-badge">
                    <i class="fa-solid fa-briefcase"></i>
                    <span>${escapeHtml(jobLabel)} ${jobGrade}</span>
                </div>
                <div class="tile-money-row">
                    <span>Efectivo: <strong>$${cashFmt}</strong></span>
                    <span>Banco: <strong>$${bankFmt}</strong></span>
                </div>
            </div>
            <div class="tile-footer">
                <div class="btn-tile-action">
                    <span>Gestionar</span>
                    <i class="fa-solid fa-arrow-right"></i>
                </div>
            </div>
        `;

        tile.addEventListener('click', () => {
            openPlayerModal(p);
        });

        grid.appendChild(tile);
    });
}

// Buscador en tiempo real
const searchInput = document.getElementById('input-player-search');
const clearSearchBtn = document.getElementById('btn-clear-search');

searchInput.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase().trim();
    if (query.length > 0) {
        clearSearchBtn.style.display = 'block';
    } else {
        clearSearchBtn.style.display = 'none';
    }

    const filtered = allPlayers.filter(p => {
        const idMatch = p.id.toString().includes(query);
        const nameMatch = (p.name || '').toLowerCase().includes(query);
        const charMatch = (p.charname || '').toLowerCase().includes(query);
        const jobMatch = (p.job || '').toLowerCase().includes(query);
        return idMatch || nameMatch || charMatch || jobMatch;
    });

    renderPlayers(filtered);
});

clearSearchBtn.addEventListener('click', () => {
    searchInput.value = '';
    clearSearchBtn.style.display = 'none';
    renderPlayers(allPlayers);
});

document.getElementById('btn-refresh-players').addEventListener('click', fetchAndRenderPlayers);

// ========================================================
// MODAL DE ACCIONES SOBRE EL JUGADOR SELECCIONADO
// ========================================================
function openPlayerModal(p) {
    selectedPlayer = p;
    
    document.getElementById('modal-p-charname').innerText = p.charname || 'Sin Personaje';
    document.getElementById('modal-p-id').innerText = `ID: #${p.id}`;
    document.getElementById('modal-p-account').innerText = p.name || 'Desconocido';
    document.getElementById('modal-p-citizenid').innerText = p.citizenid || 'N/A';

    const jobStr = `${p.jobLabel || p.job || 'Desempleado'} (Grado ${p.jobGrade ?? 0})`;
    document.getElementById('modal-p-job').innerText = jobStr;
    document.getElementById('modal-p-cash').innerText = '$' + (p.cash || 0).toLocaleString('es-ES');
    document.getElementById('modal-p-bank').innerText = '$' + (p.bank || 0).toLocaleString('es-ES');
    document.getElementById('modal-p-health').innerText = (p.health || 100) + '%';

    document.getElementById('label-act-freeze').innerText = p.isFrozen ? 'Descongelar' : 'Congelar';

    document.getElementById('modal-player-actions').style.display = 'flex';
}

document.getElementById('btn-close-player-modal').addEventListener('click', () => {
    document.getElementById('modal-player-actions').style.display = 'none';
    selectedPlayer = null;
});

// Acciones sobre el jugador:
// 1. Dar Dinero
document.getElementById('btn-act-givemoney').addEventListener('click', () => {
    if (!selectedPlayer) return;
    moneyActionType = 'give';
    document.getElementById('submodal-money-title').innerHTML = `<i class="fa-solid fa-hand-holding-dollar text-green"></i> Dar Dinero a #${selectedPlayer.id} (${escapeHtml(selectedPlayer.charname)})`;
    document.getElementById('input-money-amount').value = '';
    document.getElementById('submodal-money').style.display = 'flex';
});

// 2. Quitar Dinero
document.getElementById('btn-act-removemoney').addEventListener('click', () => {
    if (!selectedPlayer) return;
    moneyActionType = 'remove';
    document.getElementById('submodal-money-title').innerHTML = `<i class="fa-solid fa-money-bill-transfer text-red"></i> Quitar Dinero a #${selectedPlayer.id} (${escapeHtml(selectedPlayer.charname)})`;
    document.getElementById('input-money-amount').value = '';
    document.getElementById('submodal-money').style.display = 'flex';
});

document.getElementById('btn-cancel-money').addEventListener('click', () => {
    document.getElementById('submodal-money').style.display = 'none';
});

document.getElementById('btn-confirm-money').addEventListener('click', () => {
    if (!selectedPlayer) return;
    const amount = parseInt(document.getElementById('input-money-amount').value);
    const moneyType = document.querySelector('input[name="money-type"]:checked').value;

    if (!amount || amount <= 0) {
        alert('Introduce una cantidad válida.');
        return;
    }

    postNUI('modifyMoney', {
        targetId: selectedPlayer.id,
        actionType: moneyActionType,
        moneyType: moneyType,
        amount: amount
    }).then(() => {
        document.getElementById('submodal-money').style.display = 'none';
        // Refrescar datos
        fetchAndRenderPlayers();
        document.getElementById('modal-player-actions').style.display = 'none';
    });
});

// 3. Dar Trabajo (Job)
document.getElementById('btn-act-setjob').addEventListener('click', () => {
    if (!selectedPlayer) return;
    document.getElementById('submodal-job').style.display = 'flex';
});

document.getElementById('btn-cancel-job').addEventListener('click', () => {
    document.getElementById('submodal-job').style.display = 'none';
});

document.getElementById('btn-confirm-job').addEventListener('click', () => {
    if (!selectedPlayer) return;
    const job = document.getElementById('select-job-name').value;
    const grade = parseInt(document.getElementById('select-job-grade').value);

    postNUI('setJob', {
        targetId: selectedPlayer.id,
        job: job,
        grade: grade
    }).then(() => {
        document.getElementById('submodal-job').style.display = 'none';
        fetchAndRenderPlayers();
        document.getElementById('modal-player-actions').style.display = 'none';
    });
});

// 4. Revivir & Curar
document.getElementById('btn-act-revive').addEventListener('click', () => {
    if (!selectedPlayer) return;
    postNUI('revivePlayer', { targetId: selectedPlayer.id });
});

// 5. Matar (Kill)
document.getElementById('btn-act-kill').addEventListener('click', () => {
    if (!selectedPlayer) return;
    postNUI('killPlayer', { targetId: selectedPlayer.id });
});

// 6. Ir al Jugador (Goto)
document.getElementById('btn-act-goto').addEventListener('click', () => {
    if (!selectedPlayer) return;
    postNUI('teleportToPlayer', { targetId: selectedPlayer.id });
    closeAdminMenu();
});

// 7. Traer Jugador (Bring)
document.getElementById('btn-act-bring').addEventListener('click', () => {
    if (!selectedPlayer) return;
    postNUI('bringPlayer', { targetId: selectedPlayer.id });
});

// 8. Congelar (Freeze)
document.getElementById('btn-act-freeze').addEventListener('click', () => {
    if (!selectedPlayer) return;
    postNUI('toggleFreeze', { targetId: selectedPlayer.id }).then(res => {
        if (res && res.isFrozen !== undefined) {
            selectedPlayer.isFrozen = res.isFrozen;
            document.getElementById('label-act-freeze').innerText = res.isFrozen ? 'Descongelar' : 'Congelar';
        }
    });
});

// 9. Ver Inventario
document.getElementById('btn-act-inventory').addEventListener('click', () => {
    if (!selectedPlayer) return;
    postNUI('openInventory', { targetId: selectedPlayer.id });
    closeAdminMenu();
});

// 10. Dar Menú Ropa
document.getElementById('btn-act-skin').addEventListener('click', () => {
    if (!selectedPlayer) return;
    postNUI('giveSkin', { targetId: selectedPlayer.id });
});

// 11. Expulsar (Kick)
document.getElementById('btn-act-kick').addEventListener('click', () => {
    if (!selectedPlayer) return;
    punishActionType = 'kick';
    document.getElementById('submodal-punish-title').innerHTML = `<i class="fa-solid fa-door-open text-red"></i> Expulsar a #${selectedPlayer.id}`;
    document.getElementById('group-ban-time').style.display = 'none';
    document.getElementById('input-punish-reason').value = '';
    document.getElementById('submodal-punish').style.display = 'flex';
});

// 12. Banear (Ban)
document.getElementById('btn-act-ban').addEventListener('click', () => {
    if (!selectedPlayer) return;
    punishActionType = 'ban';
    document.getElementById('submodal-punish-title').innerHTML = `<i class="fa-solid fa-gavel text-red"></i> Banear a #${selectedPlayer.id}`;
    document.getElementById('group-ban-time').style.display = 'flex';
    document.getElementById('input-punish-reason').value = '';
    document.getElementById('submodal-punish').style.display = 'flex';
});

document.getElementById('btn-cancel-punish').addEventListener('click', () => {
    document.getElementById('submodal-punish').style.display = 'none';
});

document.getElementById('btn-confirm-punish').addEventListener('click', () => {
    if (!selectedPlayer) return;
    const reason = document.getElementById('input-punish-reason').value.trim() || 'Incumplimiento de normativas';
    
    if (punishActionType === 'kick') {
        postNUI('kickPlayer', {
            targetId: selectedPlayer.id,
            reason: reason
        }).then(() => {
            document.getElementById('submodal-punish').style.display = 'none';
            document.getElementById('modal-player-actions').style.display = 'none';
            fetchAndRenderPlayers();
        });
    } else {
        const duration = parseInt(document.getElementById('select-ban-duration').value);
        postNUI('banPlayer', {
            targetId: selectedPlayer.id,
            duration: duration,
            reason: reason
        }).then(() => {
            document.getElementById('submodal-punish').style.display = 'none';
            document.getElementById('modal-player-actions').style.display = 'none';
            fetchAndRenderPlayers();
        });
    }
});

// ========================================================
// PESTAÑA: OPCIONES STAFF
// ========================================================
function updateToggleButtons() {
    const godBtn = document.getElementById('btn-toggle-godmode');
    const noclipBtn = document.getElementById('btn-toggle-noclip');
    const invisBtn = document.getElementById('btn-toggle-invisible');

    if (staffToggles.godmode) godBtn.classList.add('active'); else godBtn.classList.remove('active');
    if (staffToggles.noclip) noclipBtn.classList.add('active'); else noclipBtn.classList.remove('active');
    if (staffToggles.invisible) invisBtn.classList.add('active'); else invisBtn.classList.remove('active');
}

document.getElementById('btn-toggle-godmode').addEventListener('click', () => {
    staffToggles.godmode = !staffToggles.godmode;
    updateToggleButtons();
    postNUI('toggleGodmode', { enabled: staffToggles.godmode });
});

document.getElementById('btn-toggle-noclip').addEventListener('click', () => {
    staffToggles.noclip = !staffToggles.noclip;
    updateToggleButtons();
    postNUI('toggleNoclip', { enabled: staffToggles.noclip });
    closeAdminMenu();
});

document.getElementById('btn-toggle-invisible').addEventListener('click', () => {
    staffToggles.invisible = !staffToggles.invisible;
    updateToggleButtons();
    postNUI('toggleInvisible', { enabled: staffToggles.invisible });
});

document.getElementById('btn-self-revive').addEventListener('click', () => {
    postNUI('selfRevive');
});

document.getElementById('btn-self-tpm').addEventListener('click', () => {
    postNUI('selfTPM');
    closeAdminMenu();
});

document.getElementById('btn-self-skin').addEventListener('click', () => {
    postNUI('selfSkin');
    closeAdminMenu();
});

document.getElementById('btn-self-suicide').addEventListener('click', () => {
    postNUI('selfSuicide');
});

// ========================================================
// PESTAÑA: VEHÍCULOS
// ========================================================
document.getElementById('btn-spawn-vehicle').addEventListener('click', () => {
    const model = document.getElementById('input-spawn-veh').value.trim();
    if (model) {
        postNUI('spawnVehicle', { model: model });
        closeAdminMenu();
    }
});

document.getElementById('input-spawn-veh').addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
        document.getElementById('btn-spawn-vehicle').click();
    }
});

document.getElementById('btn-veh-repair').addEventListener('click', () => {
    postNUI('repairVehicle');
});

document.getElementById('btn-veh-clean').addEventListener('click', () => {
    postNUI('cleanVehicle');
});

document.getElementById('btn-veh-maxtune').addEventListener('click', () => {
    postNUI('maxTuneVehicle');
});

document.getElementById('btn-veh-delete').addEventListener('click', () => {
    postNUI('deleteVehicle');
});

// ========================================================
// PESTAÑA: CLIMA & MUNDO
// ========================================================
document.querySelectorAll('.btn-weather').forEach(btn => {
    btn.addEventListener('click', () => {
        const weather = btn.getAttribute('data-weather');
        postNUI('setWeather', { weather: weather });
    });
});

document.querySelectorAll('.btn-time').forEach(btn => {
    btn.addEventListener('click', () => {
        const hour = parseInt(btn.getAttribute('data-hour'));
        const minute = parseInt(btn.getAttribute('data-minute'));
        postNUI('setTime', { hour: hour, minute: minute });
    });
});

document.getElementById('btn-send-announcement').addEventListener('click', () => {
    const msg = document.getElementById('input-global-announcement').value.trim();
    if (msg) {
        postNUI('sendAnnouncement', { message: msg });
        document.getElementById('input-global-announcement').value = '';
    }
});

// Helper HTML escape
function escapeHtml(text) {
    if (!text) return '';
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.toString().replace(/[&<>"']/g, m => map[m]);
}
