// ==========================================================================
// SPAIN ROL - COMPRA-VENTA TABLET NUI CLIENT APP
// ==========================================================================

let appState = {
    isOpen: false,
    dealershipId: 'dealership_sur',
    dealershipName: 'Motors Sur Ocasión',
    dealershipCity: 'Los Santos Sur',
    user: {
        name: 'Ciudadano',
        bank: 0,
        job: 'unemployed',
        grade: 0,
        isBoss: false
    },
    societyBalance: 0,
    catalog: [],
    ownedVehicles: [],
    employees: [],
    history: [],
    activeCategory: 'all',
    searchQuery: '',
    selectedBuyVeh: null,
    selectedSellVeh: null,
    moneyPromptType: null // 'deposit' or 'withdraw'
};

// Formateador de moneda en Euros (€)
function formatCurrency(amount) {
    return new Intl.NumberFormat('es-ES', { style: 'currency', currency: 'EUR', maximumFractionDigits: 0 }).format(amount);
}

// Actualizar reloj de la barra de estado
function updateClock() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const clockEl = document.getElementById('status-clock');
    if (clockEl) clockEl.textContent = `${hours}:${minutes}`;
}
setInterval(updateClock, 1000);
updateClock();

// --------------------------------------------------------------------------
// RECEPCIÓN DE MENSAJES DESDE CLIENTE FIVEM
// --------------------------------------------------------------------------
window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'openTablet') {
        appState.isOpen = true;
        appState.dealershipId = data.dealership.id;
        appState.dealershipName = data.dealership.name;
        appState.dealershipCity = data.dealership.city;
        appState.user = data.user;
        appState.societyBalance = data.societyBalance || 0;
        appState.catalog = data.catalog || [];
        appState.ownedVehicles = data.ownedVehicles || [];
        appState.employees = data.employees || [];
        appState.history = data.history || [];

        renderHeader();
        renderCatalog();
        renderOwnedVehicles();
        renderBossManagement();
        renderHistory();

        // Mostrar u ocultar pestaña BOSS
        const bossNavBtn = document.getElementById('nav-btn-boss');
        if (appState.user.isBoss) {
            bossNavBtn.classList.remove('hidden');
        } else {
            bossNavBtn.classList.add('hidden');
        }

        // Poner la primera pestaña activa
        switchTab('tab-catalog');

        document.getElementById('tablet-wrapper').classList.remove('hidden');
    } else if (data.action === 'closeTablet') {
        closeTabletUI();
    } else if (data.action === 'updateBalances') {
        if (data.userBank !== undefined) appState.user.bank = data.userBank;
        if (data.societyBalance !== undefined) appState.societyBalance = data.societyBalance;
        if (data.ownedVehicles !== undefined) {
            appState.ownedVehicles = data.ownedVehicles;
            renderOwnedVehicles();
        }
        if (data.employees !== undefined) {
            appState.employees = data.employees;
            renderBossManagement();
        }
        renderHeader();
        renderBossManagement();
    }
});

// Cerrar tablet
function closeTabletUI() {
    appState.isOpen = false;
    document.getElementById('tablet-wrapper').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeTablet`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch(() => {});
}

// --------------------------------------------------------------------------
// RENDERIZADO DE VISTAS
// --------------------------------------------------------------------------

function renderHeader() {
    document.getElementById('dealer-tag').textContent = appState.dealershipName.toUpperCase();
    document.getElementById('dealer-location').textContent = appState.dealershipCity;
    document.getElementById('sidebar-dealer-name').textContent = appState.dealershipName;
    document.getElementById('user-display-name').textContent = appState.user.name;
    document.getElementById('user-bank-amount').textContent = formatCurrency(appState.user.bank);
}

// Renderizar Catálogo de Ocasión
function renderCatalog() {
    const grid = document.getElementById('catalog-grid');
    grid.innerHTML = '';

    const filtered = appState.catalog.filter(v => {
        const matchesCategory = (appState.activeCategory === 'all' || v.category === appState.activeCategory);
        const matchesSearch = v.label.toLowerCase().includes(appState.searchQuery.toLowerCase()) || 
                              v.brand.toLowerCase().includes(appState.searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
    });

    if (filtered.length === 0) {
        grid.innerHTML = `<div style="grid-column: 1/-1; text-align:center; padding: 40px; color: var(--text-muted);">
            <h3>No se encontraron vehículos en esta categoría o búsqueda.</h3>
        </div>`;
        return;
    }

    filtered.forEach(veh => {
        const card = document.createElement('div');
        card.className = 'vehicle-card';
        card.innerHTML = `
            <div class="vehicle-card-img-wrap">
                <span class="card-category-badge">${veh.category}</span>
                <span class="card-brand-tag">${veh.brand}</span>
                <img src="${veh.image}" alt="${veh.label}" onerror="this.src='https://docs.fivem.net/vehicles/zentorno.webp'">
            </div>
            <div class="vehicle-card-body">
                <div class="vehicle-title-price">
                    <div>
                        <h3>${veh.label}</h3>
                    </div>
                    <div class="vehicle-price-tag">${formatCurrency(veh.price)}</div>
                </div>

                <div class="vehicle-specs-list">
                    <div class="spec-row">
                        <span>Velocidad</span>
                        <div class="spec-bar-bg"><div class="spec-bar-fill" style="width: ${veh.speed}%"></div></div>
                    </div>
                    <div class="spec-row">
                        <span>Aceleración</span>
                        <div class="spec-bar-bg"><div class="spec-bar-fill" style="width: ${veh.accel}%"></div></div>
                    </div>
                    <div class="spec-row">
                        <span>Frenada</span>
                        <div class="spec-bar-bg"><div class="spec-bar-fill" style="width: ${veh.brakes}%"></div></div>
                    </div>
                    <div class="spec-row">
                        <span>Manejo</span>
                        <div class="spec-bar-bg"><div class="spec-bar-fill" style="width: ${veh.handling}%"></div></div>
                    </div>
                </div>

                <button class="btn-buy-card" onclick="openBuyModal('${veh.model}')">
                    <span>🛒 Comprar para mi Garaje</span>
                </button>
            </div>
        `;
        grid.appendChild(card);
    });
}

// Renderizar Vehículos Propios (Venta)
function renderOwnedVehicles() {
    const container = document.getElementById('owned-vehicles-list');
    container.innerHTML = '';

    if (!appState.ownedVehicles || appState.ownedVehicles.length === 0) {
        container.innerHTML = `
            <div style="grid-column: 1/-1; text-align:center; padding: 50px; background: rgba(255,255,255,0.02); border-radius: 16px;">
                <h3 style="color: var(--text-primary); margin-bottom: 8px;">No tienes vehículos en propiedad registrados</h3>
                <p style="color: var(--text-muted);">Los vehículos que compres aparecerán aquí para que puedas tasarlos y venderlos al concesionario en cualquier momento.</p>
            </div>
        `;
        return;
    }

    appState.ownedVehicles.forEach(veh => {
        const card = document.createElement('div');
        card.className = 'owned-card';
        card.innerHTML = `
            <div class="owned-card-header">
                <div>
                    <h3 style="font-size:1.2rem; font-weight:800; color:var(--text-primary);">${veh.label || veh.vehicle}</h3>
                    <p style="font-size:0.8rem; color:var(--text-muted); margin-top:2px;">Ubicación: <strong>${veh.garage || 'Garaje Central'}</strong></p>
                </div>
                <span class="owned-plate-badge">${veh.plate}</span>
            </div>

            <div class="owned-info-grid">
                <div class="owned-info-item">
                    <span>Estado Mecánico:</span>
                    <strong style="color: var(--accent-emerald);">100% Funcional</strong>
                </div>
                <div class="owned-info-item">
                    <span>Situación:</span>
                    <strong>${veh.state === 1 ? 'En Garaje ✅' : 'En Circulación ⚠️'}</strong>
                </div>
            </div>

            <div class="owned-valuation-box">
                <div>
                    <span style="font-size:0.75rem; color:var(--text-muted); text-transform:uppercase;">Oferta Inmediata (Banco)</span>
                    <div class="valuation-amount">${formatCurrency(veh.resellPrice || 15000)}</div>
                </div>
                <button class="btn-sell-card" onclick="openSellModal('${veh.plate}')">
                    <span>💵 Vender Ahora</span>
                </button>
            </div>
        `;
        container.appendChild(card);
    });
}

// Renderizar Panel de Gestión Empresarial
function renderBossManagement() {
    document.getElementById('society-bank-balance').textContent = formatCurrency(appState.societyBalance);
    document.getElementById('total-employees-count').textContent = appState.employees.length;
    document.getElementById('employees-badge').textContent = `${appState.employees.length} empleados`;
    document.getElementById('user-boss-grade').textContent = appState.user.gradeName || 'Gerencia';
    document.getElementById('dealership-society-name').textContent = appState.dealershipName;

    const tbody = document.getElementById('employees-tbody');
    tbody.innerHTML = '';

    if (appState.employees.length === 0) {
        tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding: 24px; color: var(--text-muted);">No hay otros empleados contratados actualmente en esta sede.</td></tr>`;
        return;
    }

    appState.employees.forEach(emp => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>
                <div style="display:flex; align-items:center; gap:8px;">
                    <span style="font-size:1.2rem;">👤</span>
                    <strong>${emp.name}</strong>
                </div>
            </td>
            <td><code>${emp.citizenid}</code></td>
            <td><span class="rank-pill">${emp.gradeName || 'Nivel ' + emp.grade}</span></td>
            <td style="color: var(--accent-emerald); font-weight:700;">${emp.payment || 80}€ / hora</td>
            <td>
                <span style="color: ${emp.isOnline ? 'var(--accent-emerald)' : 'var(--text-muted)'}; font-weight:700;">
                    ${emp.isOnline ? '🟢 En Servicio' : '⚪ Desconectado'}
                </span>
            </td>
            <td>
                <div class="action-btn-group">
                    <button class="btn-table-action" onclick="changeEmployeeGrade('${emp.citizenid}', ${emp.grade + 1})" title="Ascender">▲</button>
                    <button class="btn-table-action" onclick="changeEmployeeGrade('${emp.citizenid}', ${emp.grade - 1})" title="Degradar">▼</button>
                    <button class="btn-table-action fire-btn" onclick="fireEmployee('${emp.citizenid}')" title="Despedir">✕</button>
                </div>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

// Renderizar Historial
function renderHistory() {
    const container = document.getElementById('history-container');
    container.innerHTML = '';

    if (!appState.history || appState.history.length === 0) {
        container.innerHTML = `<div style="text-align:center; padding: 40px; color: var(--text-muted);">No hay transacciones registradas hoy en este terminal.</div>`;
        return;
    }

    appState.history.forEach(item => {
        const el = document.createElement('div');
        el.className = 'history-item';
        el.innerHTML = `
            <div class="history-info">
                <h4>${item.title}</h4>
                <p>${item.date} &bull; ${item.details}</p>
            </div>
            <div class="history-amount ${item.type === 'in' ? 'amount-positive' : 'amount-negative'}">
                ${item.type === 'in' ? '+' : '-'}${formatCurrency(item.amount)}
            </div>
        `;
        container.appendChild(el);
    });
}

// --------------------------------------------------------------------------
// MODALES Y ACCIONES
// --------------------------------------------------------------------------

// 1. Modal Comprar
window.openBuyModal = function(model) {
    const veh = appState.catalog.find(v => v.model === model);
    if (!veh) return;
    appState.selectedBuyVeh = veh;

    const modalBody = document.getElementById('modal-buy-body');
    modalBody.innerHTML = `
        <div style="display:flex; gap:16px; align-items:center;">
            <img src="${veh.image}" style="width:130px; height:80px; object-fit:contain; background:rgba(0,0,0,0.3); border-radius:8px;">
            <div>
                <h4 style="font-size:1.2rem; color:#fff;">${veh.label}</h4>
                <p style="color:var(--text-muted); font-size:0.85rem;">Marca: ${veh.brand} | Categoría: ${veh.category}</p>
                <div style="margin-top:6px; font-size:1.3rem; font-weight:800; color:var(--accent-emerald);">${formatCurrency(veh.price)}</div>
            </div>
        </div>
        <div style="background:rgba(59, 130, 246, 0.1); border:1px solid rgba(59, 130, 246, 0.25); padding:12px; border-radius:8px; font-size:0.84rem; margin-top:8px;">
            ℹ️ El importe de <strong>${formatCurrency(veh.price)}</strong> se cargará directamente en tu <strong>cuenta bancaria</strong>. 
            El vehículo será matriculado a tu nombre y quedará estacionado listo en tu <strong>Garaje Central (Pillbox)</strong>.
        </div>
    `;

    document.getElementById('modal-confirm-buy').classList.remove('hidden');
};

document.getElementById('modal-buy-close').onclick = () => document.getElementById('modal-confirm-buy').classList.add('hidden');
document.getElementById('modal-buy-cancel').onclick = () => document.getElementById('modal-confirm-buy').classList.add('hidden');
document.getElementById('modal-buy-confirm').onclick = () => {
    if (!appState.selectedBuyVeh) return;
    document.getElementById('modal-confirm-buy').classList.add('hidden');

    fetch(`https://${GetParentResourceName()}/buyVehicle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            model: appState.selectedBuyVeh.model,
            price: appState.selectedBuyVeh.price,
            label: appState.selectedBuyVeh.label,
            dealershipId: appState.dealershipId
        })
    }).catch(() => {});
};

// 2. Modal Vender
window.openSellModal = function(plate) {
    const veh = appState.ownedVehicles.find(v => v.plate === plate);
    if (!veh) return;
    appState.selectedSellVeh = veh;

    const modalBody = document.getElementById('modal-sell-body');
    modalBody.innerHTML = `
        <div>
            <h4 style="font-size:1.2rem; color:#fff;">${veh.label || veh.vehicle}</h4>
            <p style="color:var(--text-muted); font-size:0.85rem;">Matrícula: <strong>${veh.plate}</strong> | Garaje actual: <strong>${veh.garage}</strong></p>
        </div>
        <div style="background:rgba(16, 185, 129, 0.1); border:1px solid rgba(16, 185, 129, 0.25); padding:14px; border-radius:8px; margin-top:8px;">
            <span style="font-size:0.8rem; color:var(--text-muted);">TASACIÓN OFICIAL GARANTIZADA:</span>
            <div style="font-size:1.5rem; font-weight:800; color:var(--accent-emerald);">${formatCurrency(veh.resellPrice || 15000)}</div>
            <p style="font-size:0.82rem; color:var(--text-secondary); margin-top:6px;">
                Al confirmar la venta, el coche dejará de estar en tu garaje y el dinero de la tasación será ingresado <strong>inmediatamente en tu cuenta del banco</strong>.
            </p>
        </div>
    `;

    document.getElementById('modal-confirm-sell').classList.remove('hidden');
};

document.getElementById('modal-sell-close').onclick = () => document.getElementById('modal-confirm-sell').classList.add('hidden');
document.getElementById('modal-sell-cancel').onclick = () => document.getElementById('modal-confirm-sell').classList.add('hidden');
document.getElementById('modal-sell-confirm').onclick = () => {
    if (!appState.selectedSellVeh) return;
    document.getElementById('modal-confirm-sell').classList.add('hidden');

    fetch(`https://${GetParentResourceName()}/sellVehicle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            plate: appState.selectedSellVeh.plate,
            resellPrice: appState.selectedSellVeh.resellPrice,
            dealershipId: appState.dealershipId
        })
    }).catch(() => {});
};

// 3. Gestión Bancaria de Sociedad
document.getElementById('btn-deposit-society').onclick = () => {
    appState.moneyPromptType = 'deposit';
    document.getElementById('modal-money-title').textContent = 'Ingresar Dinero en la Cuenta Empresarial';
    document.getElementById('modal-money-desc').textContent = 'Introduce el importe en euros (€) que deseas transferir desde tu cuenta a la sociedad:';
    document.getElementById('input-money-amount').value = '';
    document.getElementById('modal-money-prompt').classList.remove('hidden');
};

document.getElementById('btn-withdraw-society').onclick = () => {
    appState.moneyPromptType = 'withdraw';
    document.getElementById('modal-money-title').textContent = 'Retirar Beneficios de la Sociedad';
    document.getElementById('modal-money-desc').textContent = 'Introduce el importe en euros (€) que deseas retirar a tu cuenta bancaria personal:';
    document.getElementById('input-money-amount').value = '';
    document.getElementById('modal-money-prompt').classList.remove('hidden');
};

document.getElementById('modal-money-close').onclick = () => document.getElementById('modal-money-prompt').classList.add('hidden');
document.getElementById('modal-money-cancel').onclick = () => document.getElementById('modal-money-prompt').classList.add('hidden');
document.getElementById('modal-money-confirm').onclick = () => {
    const val = parseInt(document.getElementById('input-money-amount').value);
    if (!val || val <= 0) return;
    document.getElementById('modal-money-prompt').classList.add('hidden');

    const endpoint = appState.moneyPromptType === 'deposit' ? 'societyDeposit' : 'societyWithdraw';
    fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            amount: val,
            dealershipId: appState.dealershipId
        })
    }).catch(() => {});
};

// 4. Jerarquía de Empleados
window.changeEmployeeGrade = function(cid, newGrade) {
    if (newGrade < 0 || newGrade > 4) return;
    fetch(`https://${GetParentResourceName()}/setEmployeeGrade`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            citizenid: cid,
            grade: newGrade,
            dealershipId: appState.dealershipId
        })
    }).catch(() => {});
};

window.fireEmployee = function(cid) {
    fetch(`https://${GetParentResourceName()}/fireEmployee`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            citizenid: cid,
            dealershipId: appState.dealershipId
        })
    }).catch(() => {});
};

// 5. Contratar Empleados Cercanos
document.getElementById('btn-open-hire-modal').onclick = () => {
    fetch(`https://${GetParentResourceName()}/getNearbyPlayers`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(res => res.json())
    .then(players => {
        const list = document.getElementById('nearby-players-list');
        list.innerHTML = '';

        if (!players || players.length === 0) {
            list.innerHTML = `<div style="text-align:center; padding: 20px; color: var(--text-muted);">No hay ciudadanos cerca del mostrador en este momento.</div>`;
        } else {
            players.forEach(p => {
                const row = document.createElement('div');
                row.className = 'nearby-player-row';
                row.innerHTML = `
                    <div>
                        <strong>${p.name}</strong>
                        <span style="color:var(--text-muted); font-size:0.8rem; margin-left:8px;">[ID: ${p.id}]</span>
                    </div>
                    <button class="btn-primary" style="padding:6px 14px; font-size:0.8rem;" onclick="hirePlayer(${p.id})">
                        Contratar
                    </button>
                `;
                list.appendChild(row);
            });
        }

        document.getElementById('modal-hire-player').classList.remove('hidden');
    })
    .catch(() => {});
};

window.hirePlayer = function(targetId) {
    document.getElementById('modal-hire-player').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/hirePlayer`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            targetId: targetId,
            dealershipId: appState.dealershipId
        })
    }).catch(() => {});
};

document.getElementById('modal-hire-close').onclick = () => document.getElementById('modal-hire-player').classList.add('hidden');
document.getElementById('modal-hire-cancel').onclick = () => document.getElementById('modal-hire-player').classList.add('hidden');

// --------------------------------------------------------------------------
// EVENT LISTENERS & NAVEGACIÓN
// --------------------------------------------------------------------------

// Pestañas
function switchTab(tabId) {
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.classList.toggle('active', btn.getAttribute('data-tab') === tabId);
    });
    document.querySelectorAll('.tab-view').forEach(view => {
        view.classList.toggle('active', view.id === tabId);
    });
}

document.querySelectorAll('.nav-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        const tab = btn.getAttribute('data-tab');
        switchTab(tab);
    });
});

// Category pills
document.querySelectorAll('.pill-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        document.querySelectorAll('.pill-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        appState.activeCategory = btn.getAttribute('data-category');
        renderCatalog();
    });
});

// Search input
document.getElementById('catalog-search').addEventListener('input', (e) => {
    appState.searchQuery = e.target.value;
    renderCatalog();
});

// Botones de cierre
document.getElementById('btn-close-tablet').addEventListener('click', closeTabletUI);
document.getElementById('btn-exit-bottom').addEventListener('click', closeTabletUI);

// Tecla ESC para cerrar
window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' || e.key === 'Backspace') {
        if (appState.isOpen) {
            closeTabletUI();
        }
    }
});
