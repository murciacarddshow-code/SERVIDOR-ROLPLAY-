let currentJobName = 'unemployed';
let isOnDuty = true;

window.addEventListener('message', function (event) {
    const data = event.data;
    if (data.action === 'open') {
        const worker = data.worker || {};
        const corp = data.corp || {};
        currentJobName = worker.jobName || 'unemployed';
        isOnDuty = worker.onDuty;

        // Mostrar overlay
        document.querySelector('.jobtablet-overlay').style.display = 'flex';

        // Actualizar datos del trabajador
        document.getElementById('worker-name').textContent = worker.name || 'Empleado';
        document.getElementById('worker-grade').textContent = `${worker.jobLabel || 'Oficio'} &bull; ${worker.grade || 'Oficial'}`;
        document.getElementById('worker-salary').textContent = `€${worker.salary || 75}`;

        // Actualizar estado de servicio
        updateDutyButton(isOnDuty);

        // Actualizar datos corporativos de la empresa / trabajo
        document.getElementById('corp-title').textContent = corp.title || 'TERMINAL DE TRABAJO';
        document.getElementById('corp-subtitle').textContent = corp.subtitle || 'Spain Rol v2.0 Oficial';
        document.getElementById('corp-vehicle-name').textContent = corp.vehicle || 'Vehículo de Empresa';
        document.getElementById('hq-name').textContent = corp.hq || 'Sede Central de Los Santos';
        document.getElementById('corp-rate-val').textContent = corp.rate || 'Tarifa Oficial Regulada';

        // Icono y color corporativo
        const iconEl = document.getElementById('corp-icon');
        iconEl.className = `fa-solid ${corp.icon || 'fa-briefcase'}`;

        const badgeEl = document.getElementById('corp-logo-badge');
        if (corp.gradient) {
            badgeEl.style.background = corp.gradient;
        } else if (corp.color) {
            badgeEl.style.background = corp.color;
        }

        // Cargar compañeros
        loadColleagues(currentJobName);
    } else if (data.action === 'close') {
        document.querySelector('.jobtablet-overlay').style.display = 'none';
    }
});

// Toggle de servicio (On/Off Duty)
document.getElementById('duty-toggle-btn').addEventListener('click', function () {
    fetch(`https://${GetParentResourceName()}/toggleDuty`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(res => res.json())
    .then(data => {
        isOnDuty = data.onDuty;
        updateDutyButton(isOnDuty);
    });
});

function updateDutyButton(onDuty) {
    const btn = document.getElementById('duty-toggle-btn');
    const label = document.getElementById('duty-label');

    if (onDuty) {
        btn.classList.remove('off');
        label.textContent = 'EN SERVICIO';
    } else {
        btn.classList.add('off');
        label.textContent = 'FUERA DE TURNO';
    }
}

// Fijar GPS
document.getElementById('btn-set-gps').addEventListener('click', function () {
    fetch(`https://${GetParentResourceName()}/setGpsWaypoint`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ jobName: currentJobName })
    });
});

// Cargar compañeros de plantilla
function loadColleagues(jobName) {
    const tbody = document.getElementById('colleagues-tbody');
    tbody.innerHTML = `<tr><td colspan="4" style="text-align: center; color: #747d8c; padding: 25px;"><i class="fa-solid fa-spinner fa-spin"></i> Consultando cuadrante de personal en línea...</td></tr>`;

    fetch(`https://${GetParentResourceName()}/getColleagues`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ jobName: jobName })
    })
    .then(res => res.json())
    .then(colleagues => {
        tbody.innerHTML = '';
        const countBadge = document.getElementById('badge-colleagues-count');
        if (countBadge) countBadge.textContent = colleagues ? colleagues.length : 1;

        if (!colleagues || colleagues.length === 0) {
            tbody.innerHTML = `<tr><td colspan="4" style="text-align: center; color: #747d8c; padding: 25px;"><i class="fa-solid fa-user-clock"></i> Eres el único empleado de tu gremio activo en este momento.</td></tr>`;
            return;
        }

        colleagues.forEach(c => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <i class="fa-solid fa-circle-user" style="font-size: 1.2rem; color: #00cec9;"></i>
                        <strong>${c.name}</strong>
                    </div>
                </td>
                <td><span style="background: rgba(255,255,255,0.06); padding: 3px 8px; border-radius: 4px; font-size: 0.75rem;">${c.grade}</span></td>
                <td>
                    ${c.onDuty 
                        ? '<span style="color: #2ed573; font-weight: 800; font-size: 0.75rem;"><i class="fa-solid fa-circle" style="font-size: 0.5rem;"></i> En Servicio</span>' 
                        : '<span style="color: #ff7675; font-weight: 700; font-size: 0.75rem;"><i class="fa-solid fa-circle" style="font-size: 0.5rem;"></i> Descansando</span>'}
                </td>
                <td><i class="fa-solid fa-phone" style="color: #2ed573; font-size: 0.75rem;"></i> ${c.phone || 'N/A'}</td>
            `;
            tbody.appendChild(tr);
        });
    })
    .catch(() => {});
}

// Navegación de pestañas
document.querySelectorAll('.jt-nav-item').forEach(btn => {
    btn.addEventListener('click', function () {
        document.querySelectorAll('.jt-nav-item').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.jt-section').forEach(s => s.classList.remove('active'));

        this.classList.add('active');
        const targetId = this.getAttribute('data-tab');
        const section = document.getElementById(targetId);
        if (section) section.classList.add('active');
    });
});

// Cerrar tablet
document.getElementById('btn-close-tablet').addEventListener('click', closeTablet);
window.addEventListener('keyup', function (e) {
    if (e.key === 'Escape') closeTablet();
});

function closeTablet() {
    document.querySelector('.jobtablet-overlay').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}
