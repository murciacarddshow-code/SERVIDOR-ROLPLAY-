let currentOfficer = 'Agente';
let currentJob = 'CNP';

window.addEventListener('message', function (event) {
    const data = event.data;
    if (data.action === 'open') {
        document.body.style.display = 'flex';
        document.getElementById('officer-name').innerText = data.officer || 'Agente CNP';
        document.getElementById('officer-callsign').innerText = `ID: ${data.callsign || '01'}`;
        loadDashboard();
    } else if (data.action === 'close') {
        document.body.style.display = 'none';
    }
});

// Close button and Escape key
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

// Navigation Tabs
const navItems = document.querySelectorAll('.nav-item');
navItems.forEach(item => {
    item.addEventListener('click', function () {
        navItems.forEach(n => n.classList.remove('active'));
        document.querySelectorAll('.view-section').forEach(s => s.classList.remove('active'));

        this.classList.add('active');
        const targetId = this.getAttribute('data-target');
        const targetSection = document.getElementById(targetId);
        if (targetSection) targetSection.classList.add('active');

        if (targetId === 'sec-penal') loadPenalCode();
        if (targetId === 'sec-warrants') loadWarrants();
    });
});

// Citizen Search
document.getElementById('btn-search-citizen').addEventListener('click', function () {
    const query = document.getElementById('input-citizen').value.trim();
    if (!query) return;

    fetch(`https://${GetParentResourceName()}/searchCitizen`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query: query })
    })
    .then(res => res.json())
    .then(citizens => {
        const tableBody = document.getElementById('citizen-results-body');
        tableBody.innerHTML = '';
        if (!citizens || citizens.length === 0) {
            tableBody.innerHTML = `<tr><td colspan="6" style="text-align:center; color:#b2bec3;">No se encontraron registros civiles con ese DNI o nombre.</td></tr>`;
            return;
        }

        citizens.forEach(c => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td><strong>${c.dni}</strong></td>
                <td>${c.name}</td>
                <td>${c.birthdate}</td>
                <td>${c.phone}</td>
                <td><span class="badge-tag ${c.licenses.driver ? 'success' : 'danger'}">Conducir: ${c.licenses.driver ? 'Sí' : 'No'}</span></td>
                <td>
                    <button class="action-btn" style="padding:0.4rem 0.8rem; font-size:0.75rem;" onclick="openFineModal('${c.citizenid}', '${c.name}')">Sancionar</button>
                </td>
            `;
            tableBody.appendChild(row);
        });
    });
});

// Vehicle Search
document.getElementById('btn-search-veh').addEventListener('click', function () {
    const plate = document.getElementById('input-veh').value.trim();
    if (!plate) return;

    fetch(`https://${GetParentResourceName()}/searchVehicle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ plate: plate })
    })
    .then(res => res.json())
    .then(v => {
        const container = document.getElementById('veh-result-box');
        if (!v) {
            container.innerHTML = `<p style="color:#e74c3c; font-weight:700;">No existe ningún vehículo registrado con la matrícula indicada.</p>`;
            return;
        }

        container.innerHTML = `
            <div style="background:#131a24; padding:1.2rem; border-radius:12px; border:1px solid rgba(255,255,255,0.06);">
                <h3 style="color:#00cec9; margin-bottom:0.8rem;">Matrícula: ${v.plate}</h3>
                <p style="margin-bottom:0.4rem;"><strong>Modelo:</strong> ${v.vehicle}</p>
                <p style="margin-bottom:0.4rem;"><strong>Titular Registrado:</strong> ${v.owner}</p>
                <p style="margin-bottom:0.4rem;"><strong>Ubicación Habitual:</strong> ${v.garage}</p>
                <p style="margin-bottom:0.8rem;"><strong>Estado:</strong> <span class="badge-tag primary">${v.state}</span></p>
            </div>
        `;
    });
});

// Penal Code Loader
function loadPenalCode() {
    fetch(`https://${GetParentResourceName()}/getPenalCode`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(res => res.json())
    .then(items => {
        const body = document.getElementById('penal-table-body');
        body.innerHTML = '';
        items.forEach(p => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td><strong>${p.id}</strong></td>
                <td><span class="badge-tag primary">${p.category}</span></td>
                <td>${p.title}</td>
                <td><strong style="color:#2ecc71;">${p.fine}€</strong></td>
                <td>${p.jail > 0 ? `<span class="badge-tag danger">${p.jail} Meses</span>` : '<span style="color:#b2bec3;">Sin Prisión</span>'}</td>
            `;
            body.appendChild(tr);
        });
    });
}

// Warrants Loader
function loadWarrants() {
    fetch(`https://${GetParentResourceName()}/getWarrants`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(res => res.json())
    .then(warrants => {
        const body = document.getElementById('warrants-table-body');
        body.innerHTML = '';
        if (!warrants || warrants.length === 0) {
            body.innerHTML = `<tr><td colspan="5" style="text-align:center; color:#b2bec3;">No hay órdenes de busca y captura activas en este momento.</td></tr>`;
            return;
        }

        warrants.forEach(w => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td><strong>#${w.id}</strong></td>
                <td>${w.name}</td>
                <td>${w.reason}</td>
                <td><span class="badge-tag danger">${w.danger}</span></td>
                <td>${w.officer}</td>
            `;
            body.appendChild(tr);
        });
    });
}

// Fine Modal
window.openFineModal = function(citizenid, name) {
    const amount = prompt(`Introduce la cuantía de la sanción económica para ${name} (en Euros €):`, "500");
    if (!amount) return;
    const jail = prompt(`Meses de prisión en Bolingbroke (0 si no aplica prisión):`, "0");
    const reason = prompt(`Motivo de la sanción:`, "Infracción del Código Penal");

    fetch(`https://${GetParentResourceName()}/issueFine`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            citizenid: citizenid,
            target_name: name,
            amount: parseInt(amount) || 0,
            jail: parseInt(jail) || 0,
            reason: reason || 'Sanción oficial'
        })
    });
};

window.testAction = function(actionCommand) {
    fetch(`https://${GetParentResourceName()}/triggerAction`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: actionCommand })
    });
};

function loadDashboard() {
    // Basic dashboard initializer
}
