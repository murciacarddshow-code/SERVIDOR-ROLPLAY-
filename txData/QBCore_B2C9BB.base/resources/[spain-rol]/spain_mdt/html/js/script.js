let currentOfficer = 'Agente';
let currentJob = 'CNP';
let currentCallsign = 'Z-10';

let penalCodeCatalog = [];
let selectedPenalCharges = [];

// Reloj digital en vivo
function updateLiveClock() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');
    const timeEl = document.getElementById('mdt-clock');
    if (timeEl) timeEl.textContent = `${hours}:${minutes}:${seconds}`;

    const days = ['DOMINGO', 'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO'];
    const months = ['ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO', 'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE'];
    const dateEl = document.getElementById('mdt-date');
    if (dateEl) {
        dateEl.textContent = `${days[now.getDay()]}, ${now.getDate()} DE ${months[now.getMonth()]}`;
    }
}
setInterval(updateLiveClock, 1000);
updateLiveClock();

// Fluctuación de Constantes Vitales ECG SAMUR
setInterval(() => {
    const bpmEl = document.getElementById('vital-bpm');
    if (bpmEl) {
        const randomBpm = 74 + Math.floor(Math.random() * 5);
        bpmEl.textContent = randomBpm;
    }
}, 2500);

// NUI Messages
window.addEventListener('message', function (event) {
    const data = event.data;
    if (data.action === 'open') {
        document.body.style.display = 'flex';
        currentOfficer = data.officer || 'Agente CNP';
        currentJob = data.job || 'CNP';
        currentCallsign = data.callsign || 'Z-10';

        document.getElementById('officer-name').innerText = currentOfficer;
        document.getElementById('officer-callsign').innerText = `INDICATIVO: ${currentCallsign}`;

        // Ajustar vistas si es SAMUR/EMS
        if (currentJob === 'ambulance' || currentJob === 'ems') {
            document.querySelector('.corp-pill.samur').style.background = '#e74c3c';
            document.querySelector('.corp-pill.samur').style.color = '#ffffff';
        }

        loadPenalCode();
        loadWarrants();
    } else if (data.action === 'close') {
        document.body.style.display = 'none';
    }
});

// Cerrar Tablet
document.getElementById('btn-close-tablet').addEventListener('click', closeTablet);
window.addEventListener('keyup', function (e) {
    if (e.key === 'Escape') closeTablet();
});

function closeTablet() {
    document.body.style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

// Botón de Pánico 112
document.getElementById('btn-panic-alert').addEventListener('click', function () {
    const btn = this;
    btn.style.background = '#ff0000';
    btn.innerHTML = `<i class="fa-solid fa-satellite-dish fa-spin"></i> TRANSMITIENDO 112...`;

    fetch(`https://${GetParentResourceName()}/panicAlert`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ officer: currentOfficer, callsign: currentCallsign })
    }).catch(() => {});

    setTimeout(() => {
        btn.style.background = '';
        btn.innerHTML = `<i class="fa-solid fa-triangle-exclamation fa-beat-fade"></i> <span>BOTÓN 112</span>`;
    }, 4000);
});

// Navegación por pestañas
const navBtns = document.querySelectorAll('.nav-btn');
navBtns.forEach(btn => {
    btn.addEventListener('click', function () {
        navBtns.forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.view-section').forEach(s => s.classList.remove('active'));

        this.classList.add('active');
        const targetId = this.getAttribute('data-target');
        const targetSection = document.getElementById(targetId);
        if (targetSection) targetSection.classList.add('active');

        if (targetId === 'sec-penal') loadPenalCode();
        if (targetId === 'sec-warrants') loadWarrants();
    });
});

// Búsqueda Ciudadana
document.getElementById('btn-search-citizen').addEventListener('click', searchCitizen);
document.getElementById('input-citizen').addEventListener('keyup', (e) => {
    if (e.key === 'Enter') searchCitizen();
});

function searchCitizen() {
    const query = document.getElementById('input-citizen').value.trim();
    if (!query) return;

    const tableBody = document.getElementById('citizen-results-body');
    tableBody.innerHTML = `<tr><td colspan="7" class="table-empty-msg"><i class="fa-solid fa-spinner fa-spin"></i><p>Consultando fichero de la Dirección General de Policía...</p></td></tr>`;

    fetch(`https://${GetParentResourceName()}/searchCitizen`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query: query })
    })
    .then(res => res.json())
    .then(citizens => {
        tableBody.innerHTML = '';
        if (!citizens || citizens.length === 0) {
            tableBody.innerHTML = `<tr><td colspan="7" class="table-empty-msg"><i class="fa-solid fa-user-xmark"></i><p>No se encontraron registros civiles con el término indicado.</p></td></tr>`;
            return;
        }

        citizens.forEach((c, idx) => {
            const row = document.createElement('tr');
            const fullName = `${c.firstname || ''} ${c.lastname || ''}`.trim() || 'Ciudadano';
            const dni = c.citizenid || `ES-${10000000 + idx}`;
            const gender = c.gender || 'Hombre';
            const phone = c.phone || '600-000-000';
            const birthdate = c.birthdate || '1995-05-12';

            row.innerHTML = `
                <td style="width: 60px;">
                    <div style="width: 40px; height: 40px; background: #1a2233; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #74b9ff; font-size: 1.2rem;">
                        <i class="fa-solid fa-user"></i>
                    </div>
                </td>
                <td><strong style="color: #00cec9; font-family: 'Share Tech Mono', monospace;">${dni}</strong></td>
                <td><strong>${fullName}</strong></td>
                <td>${birthdate}</td>
                <td><i class="fa-solid fa-phone" style="color: #2ed573; font-size: 0.75rem;"></i> ${phone}</td>
                <td><span class="badge-tag clean"><i class="fa-solid fa-check"></i> Sin Reclamaciones</span></td>
                <td>
                    <button class="action-btn-table" onclick="openFineModalDirect('${c.citizenid}', '${fullName}')">
                        <i class="fa-solid fa-gavel"></i> Sancionar
                    </button>
                </td>
            `;
            tableBody.appendChild(row);
        });
    })
    .catch(() => {
        tableBody.innerHTML = `<tr><td colspan="7" class="table-empty-msg"><i class="fa-solid fa-triangle-exclamation"></i><p>Error de conexión con el servidor de bases de datos.</p></td></tr>`;
    });
}

// Búsqueda de Vehículos (DGT)
document.getElementById('btn-search-veh').addEventListener('click', searchVehicle);
document.getElementById('input-veh').addEventListener('keyup', (e) => {
    if (e.key === 'Enter') searchVehicle();
});

function searchVehicle() {
    const plate = document.getElementById('input-veh').value.trim().toUpperCase();
    if (!plate) return;

    const container = document.getElementById('veh-result-box');
    container.innerHTML = `<div class="dgt-placeholder-card"><i class="fa-solid fa-spinner fa-spin"></i><h4>Consultando registro telemático de vehículos DGT...</h4></div>`;

    fetch(`https://${GetParentResourceName()}/searchVehicle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ plate: plate })
    })
    .then(res => res.json())
    .then(v => {
        if (!v) {
            container.innerHTML = `
                <div class="dgt-placeholder-card" style="color: #ff7675;">
                    <i class="fa-solid fa-circle-xmark" style="color: #e74c3c;"></i>
                    <h4>Vehículo no localizado</h4>
                    <p>La matrícula <strong>${plate}</strong> no consta dada de alta en el censo oficial de vehículos de la DGT.</p>
                </div>
            `;
            return;
        }

        container.innerHTML = `
            <div style="display: flex; gap: 20px; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.08); padding-bottom: 16px; margin-bottom: 16px;">
                <div class="spanish-plate-box">
                    <div class="plate-eu">
                        <span class="stars">★★★★</span>
                        <span>E</span>
                    </div>
                    <div class="plate-num">${v.plate}</div>
                </div>
                <div>
                    <h3 style="color: #ffffff; font-size: 1.25rem;">${v.model || v.vehicle || 'Vehículo Homologado'}</h3>
                    <p style="color: #a4b0be; font-size: 0.8rem;">DGT Censo Provincial &bull; Bastidor Vinculado</p>
                </div>
                <div style="margin-left: auto;">
                    <span class="badge-tag clean"><i class="fa-solid fa-shield-check"></i> ITV FAVORABLE</span>
                    <span class="badge-tag clean" style="margin-left: 6px;"><i class="fa-solid fa-file-contract"></i> SEGURO OBLIGATORIO VIGENTE</span>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px;">
                <div style="background: #0d121c; padding: 12px; border-radius: 8px;">
                    <span style="font-size: 0.68rem; color: #747d8c; font-weight: 800; display: block;">TITULAR REGISTRADO</span>
                    <strong style="color: #00cec9; font-size: 0.95rem;">${v.owner || 'Desconocido'}</strong>
                </div>
                <div style="background: #0d121c; padding: 12px; border-radius: 8px;">
                    <span style="font-size: 0.68rem; color: #747d8c; font-weight: 800; display: block;">ESTADO ADMINISTRATIVO</span>
                    <strong style="color: #2ed573; font-size: 0.95rem;"><i class="fa-solid fa-circle-check"></i> Sin Cargas / Sin Embargos</strong>
                </div>
                <div style="background: #0d121c; padding: 12px; border-radius: 8px;">
                    <span style="font-size: 0.68rem; color: #747d8c; font-weight: 800; display: block;">ENCARGO DE ROBO / BÚSQUEDA</span>
                    <strong style="color: #2ed573; font-size: 0.95rem;">Negativo (Limpio)</strong>
                </div>
            </div>
        `;
    })
    .catch(() => {
        container.innerHTML = `<div class="dgt-placeholder-card"><i class="fa-solid fa-triangle-exclamation"></i><h4>Error consultando datos de DGT</h4></div>`;
    });
}

// Catálogo del Código Penal & Calculadora
function loadPenalCode() {
    fetch(`https://${GetParentResourceName()}/getPenalCode`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(res => res.json())
    .then(items => {
        penalCodeCatalog = items || [];
        renderPenalTable(penalCodeCatalog);
    })
    .catch(() => {
        // Fallback si la llamada local no responde
        renderPenalTable(penalCodeCatalog);
    });
}

function renderPenalTable(items) {
    const body = document.getElementById('penal-table-body');
    body.innerHTML = '';

    if (!items || items.length === 0) {
        body.innerHTML = `<tr><td colspan="6" class="table-empty-msg">No se han cargado artículos del Código Penal.</td></tr>`;
        return;
    }

    items.forEach((p, idx) => {
        const tr = document.createElement('tr');
        const isChecked = selectedPenalCharges.some(c => c.id === p.id);

        tr.innerHTML = `
            <td>
                <input type="checkbox" class="penal-check" data-id="${p.id}" ${isChecked ? 'checked' : ''} style="cursor: pointer; transform: scale(1.2);">
            </td>
            <td><strong style="color: #00cec9; font-family: 'Share Tech Mono', monospace;">${p.id}</strong></td>
            <td><span class="corp-pill cnp">${p.category || 'General'}</span></td>
            <td><strong>${p.title}</strong></td>
            <td><strong style="color: #2ecc71;">${p.fine}€</strong></td>
            <td>${p.jail > 0 ? `<span class="badge-tag wanted">${p.jail} Meses</span>` : '<span style="color: #747d8c;">0 Meses</span>'}</td>
        `;

        const checkbox = tr.querySelector('.penal-check');
        checkbox.addEventListener('change', (e) => {
            if (e.target.checked) {
                if (!selectedPenalCharges.some(c => c.id === p.id)) {
                    selectedPenalCharges.push(p);
                }
            } else {
                selectedPenalCharges = selectedPenalCharges.filter(c => c.id !== p.id);
            }
            updatePenalCalculator();
        });

        body.appendChild(tr);
    });
}

// Filtros del Código Penal
document.querySelectorAll('.penal-filter').forEach(btn => {
    btn.addEventListener('click', function () {
        document.querySelectorAll('.penal-filter').forEach(b => b.classList.remove('active'));
        this.classList.add('active');

        const filter = this.getAttribute('data-filter');
        if (filter === 'all') {
            renderPenalTable(penalCodeCatalog);
        } else {
            const filtered = penalCodeCatalog.filter(p => p.category && p.category.toLowerCase().includes(filter.toLowerCase()));
            renderPenalTable(filtered);
        }
    });
});

// Actualizar Calculadora de Condenas
function updatePenalCalculator() {
    const listEl = document.getElementById('calc-selected-list');
    const totalFineEl = document.getElementById('calc-total-fine');
    const totalJailEl = document.getElementById('calc-total-jail');

    if (selectedPenalCharges.length === 0) {
        listEl.innerHTML = `<div class="calc-no-items">No has seleccionado ningún artículo penal de la tabla. Haz clic en las casillas para acumular penas.</div>`;
        totalFineEl.textContent = '€0';
        totalJailEl.textContent = '0 Meses';
        return;
    }

    listEl.innerHTML = '';
    let totalFine = 0;
    let totalJail = 0;

    selectedPenalCharges.forEach(p => {
        totalFine += Number(p.fine || 0);
        totalJail += Number(p.jail || 0);

        const pill = document.createElement('div');
        pill.classList.add('calc-charge-pill');
        pill.innerHTML = `
            <div>
                <strong style="color: #00cec9;">${p.id}</strong>: ${p.title}
            </div>
            <div style="white-space: nowrap; margin-left: 8px;">
                <span style="color: #2ecc71;">${p.fine}€</span> &bull; 
                <span style="color: #ff7675;">${p.jail}m</span>
            </div>
        `;
        listEl.appendChild(pill);
    });

    totalFineEl.textContent = `€${totalFine.toLocaleString()}`;
    totalJailEl.textContent = `${totalJail} Meses`;
}

// Limpiar Calculadora
document.getElementById('btn-clear-calc').addEventListener('click', () => {
    selectedPenalCharges = [];
    document.querySelectorAll('.penal-check').forEach(c => c.checked = false);
    updatePenalCalculator();
});

// Aplicar Cálculo a la Sanción
document.getElementById('btn-apply-calc').addEventListener('click', () => {
    if (selectedPenalCharges.length === 0) {
        alert('Por favor selecciona al menos un delito de la tabla para procesar.');
        return;
    }

    let totalFine = 0;
    let totalJail = 0;
    let reasons = [];

    selectedPenalCharges.forEach(p => {
        totalFine += Number(p.fine || 0);
        totalJail += Number(p.jail || 0);
        reasons.push(`${p.id} (${p.title})`);
    });

    document.getElementById('fine-amount').value = totalFine;
    document.getElementById('fine-jail').value = totalJail;
    document.getElementById('fine-reason').value = reasons.join(', ');

    openModal('modal-fine');
});

// Órdenes de Busca y Captura (Warrants)
function loadWarrants() {
    fetch(`https://${GetParentResourceName()}/getWarrants`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(res => res.json())
    .then(warrants => {
        const grid = document.getElementById('warrants-grid');
        grid.innerHTML = '';
        const countBadge = document.getElementById('warrants-count-badge');
        if (countBadge) countBadge.textContent = warrants ? warrants.length : 0;

        if (!warrants || warrants.length === 0) {
            grid.innerHTML = `<div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #747d8c;"><i class="fa-solid fa-shield-check" style="font-size: 2.5rem; color: #2ed573; margin-bottom: 10px; display: block;"></i>No hay órdenes de busca y captura pendientes en la demarcación.</div>`;
            return;
        }

        warrants.forEach(w => {
            const card = document.createElement('div');
            card.classList.add('warrant-card');
            card.innerHTML = `
                <div class="warrant-stamp">RECLAMADO</div>
                <div class="warrant-top">
                    <div class="warrant-mugshot"><i class="fa-solid fa-user-secret"></i></div>
                    <div>
                        <span class="warrant-id">ORDEN JUDICIAL #${w.id || '01'}</span>
                        <h4 class="warrant-name">${w.name || 'Sujeto Prófugo'}</h4>
                    </div>
                </div>
                <p class="warrant-desc"><strong>Cargos:</strong> ${w.reason || 'Reclamación judicial'}</p>
                <div class="warrant-meta">
                    <span><i class="fa-solid fa-triangle-exclamation" style="color: #e74c3c;"></i> Riesgo: ${w.danger || 'Alto'}</span> &bull; 
                    <span>Instructor: ${w.officer || 'Policía Nacional'}</span>
                </div>
            `;
            grid.appendChild(card);
        });
    })
    .catch(() => {});
}

// Modal Nueva Orden
document.getElementById('btn-new-warrant').addEventListener('click', () => {
    openModal('modal-warrant');
});

document.getElementById('btn-confirm-warrant').addEventListener('click', () => {
    const citizenid = document.getElementById('warrant-citizenid').value.trim();
    const name = document.getElementById('warrant-name').value.trim();
    const danger = document.getElementById('warrant-danger').value;
    const reason = document.getElementById('warrant-reason').value.trim();

    if (!name || !reason) {
        alert('Por favor introduce el nombre y los cargos del sospechoso.');
        return;
    }

    fetch(`https://${GetParentResourceName()}/createWarrant`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            citizenid: citizenid,
            name: name,
            danger: danger,
            reason: reason
        })
    }).then(() => {
        closeModal('modal-warrant');
        loadWarrants();
    });
});

// Modal Sanción Económica
window.openFineModalDirect = function(citizenid, name) {
    document.getElementById('fine-citizenid').value = citizenid;
    document.getElementById('fine-citizen-name').value = name;
    openModal('modal-fine');
};

document.getElementById('btn-confirm-fine').addEventListener('click', () => {
    const citizenid = document.getElementById('fine-citizenid').value;
    const name = document.getElementById('fine-citizen-name').value;
    const amount = parseInt(document.getElementById('fine-amount').value) || 0;
    const jail = parseInt(document.getElementById('fine-jail').value) || 0;
    const reason = document.getElementById('fine-reason').value || 'Infracción policial';

    fetch(`https://${GetParentResourceName()}/issueFine`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            citizenid: citizenid,
            target_name: name,
            amount: amount,
            jail: jail,
            reason: reason
        })
    }).then(() => {
        closeModal('modal-fine');
    });
});

// Ejecución de comandos SAMUR
window.executeEmsCmd = function(cmd) {
    closeTablet();
    fetch(`https://${GetParentResourceName()}/executeCommand`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ command: cmd })
    }).catch(() => {});
};

// Utilidades Modales
window.openModal = function(id) {
    const m = document.getElementById(id);
    if (m) m.style.display = 'flex';
};

window.closeModal = function(id) {
    const m = document.getElementById(id);
    if (m) m.style.display = 'none';
};
