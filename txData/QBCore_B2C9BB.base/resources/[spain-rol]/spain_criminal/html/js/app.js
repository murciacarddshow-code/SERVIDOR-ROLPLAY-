let tabletData = null;
let isCrafting = false;

$(document).ready(function() {
    // Escuchar mensajes de NUI desde FiveM
    window.addEventListener('message', function(event) {
        const item = event.data;
        if (item.action === "openTablet") {
            tabletData = item.data;
            setupTabletUI(tabletData);
            $("#tablet-container").removeClass("hidden");
            updateTime();
        } else if (item.action === "closeTablet") {
            closeTablet();
        } else if (item.action === "updateOrg") {
            if (tabletData) {
                tabletData.organization = item.organization;
                tabletData.members = item.members;
                updateOrganizationTab();
            }
        }
    });

    // Tecla ESC para cerrar
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            closeTablet();
        }
    });

    // Botón de cerrar superior
    $("#btn-close-tablet").click(function() {
        closeTablet();
    });

    // Cambio de Pestañas
    $(".nav-item").click(function() {
        if (isCrafting) return; // Evitar cambiar si está en crafteo crítico
        const targetTab = $(this).data("tab");
        $(".nav-item").removeClass("active");
        $(this).addClass("active");

        $(".tab-pane").removeClass("active");
        $("#" + targetTab).addClass("active");
    });

    // Filtros de Armería
    $(".filter-pills .pill").click(function() {
        const filter = $(this).data("filter");
        $(".filter-pills .pill").removeClass("active");
        $(this).addClass("active");

        if (filter === "all") {
            $(".craft-card[data-type='weapon']").show();
        } else {
            $(".craft-card[data-type='weapon']").hide();
            $(`.craft-card[data-type='weapon'][data-category='${filter}']`).show();
        }
    });

    // Depositar Dinero Sucio en Caja
    $("#btn-deposit-money").click(function() {
        const amount = parseInt($("#safe-amount-input").val());
        if (!amount || amount <= 0) return;
        $.post(`https://spain_criminal/safeOperation`, JSON.stringify({
            action: 'deposit',
            type: 'black_money',
            amount: amount
        }));
        $("#safe-amount-input").val("");
    });

    // Retirar Dinero Sucio de Caja
    $("#btn-withdraw-money").click(function() {
        const amount = parseInt($("#safe-amount-input").val());
        if (!amount || amount <= 0) return;
        $.post(`https://spain_criminal/safeOperation`, JSON.stringify({
            action: 'withdraw',
            type: 'black_money',
            amount: amount
        }));
        $("#safe-amount-input").val("");
    });

    // Modal Reclutar
    $("#btn-invite-member").click(function() {
        $("#modal-invite").removeClass("hidden");
    });

    $("#btn-close-invite-modal, #btn-cancel-invite").click(function() {
        $("#modal-invite").addClass("hidden");
    });

    $("#btn-confirm-invite").click(function() {
        const targetId = parseInt($("#invite-player-id").val());
        if (!targetId || targetId <= 0) return;
        $.post(`https://spain_criminal/inviteMember`, JSON.stringify({
            targetId: targetId
        }));
        $("#invite-player-id").val("");
        $("#modal-invite").addClass("hidden");
    });
});

function closeTablet() {
    $("#tablet-container").addClass("hidden");
    $("#modal-invite").addClass("hidden");
    $.post(`https://spain_criminal/closeTablet`, JSON.stringify({}));
}

function updateTime() {
    const now = new Date();
    let hours = now.getHours().toString().padStart(2, '0');
    let minutes = now.getMinutes().toString().padStart(2, '0');
    $("#current-time").text(`${hours}:${minutes} CET`);
}

function setupTabletUI(data) {
    if (!data) return;

    // Perfil mini del sidebar
    $("#sidebar-org-name").text(data.organization ? data.organization.label : "Sin Organización");
    $("#sidebar-user-rank").text(data.userGrade ? data.userGrade.name : "Civil");
    $("#org-header-title").text(data.organization ? data.organization.label : "Organización Criminal");

    updateOrganizationTab();
    renderWeaponsTab(data.weapons);
    renderDrugsTab(data.drugs);
    renderGarageTab(data.garageVehicles);
    renderBlackMarketTab(data.blackmarketItems);
}

function updateOrganizationTab() {
    if (!tabletData || !tabletData.organization) return;
    const org = tabletData.organization;
    const isBoss = tabletData.isBoss;

    // Estadísticas
    $("#stat-black-money").text("€" + (org.black_money || 0).toLocaleString());
    $("#mini-safe-balance").text("€" + (org.black_money || 0).toLocaleString());
    $("#stat-clean-money").text("€" + (org.clean_money || 0).toLocaleString());
    $("#stat-org-level").text("Nivel " + (org.level || 1));
    $("#stat-reputation").text((org.reputation || 0) + " PTS");

    // Miembros
    const members = tabletData.members || [];
    $("#members-count").text(`${members.length} Miembros`);
    const tbody = $("#members-list-body");
    tbody.empty();

    members.forEach(m => {
        const isOnline = m.online;
        const statusHtml = isOnline 
            ? `<span class="status-tag online"><span class="status-dot"></span> Online</span>`
            : `<span class="status-tag offline"><span class="status-dot"></span> Offline</span>`;

        let actionBtns = "";
        if (isBoss && m.citizenid !== tabletData.myCitizenId) {
            actionBtns = `
                <button class="action-btn-mini promote" title="Ascender Rango" onclick="manageMember('${m.citizenid}', 'promote')">
                    <i class="fas fa-chevron-up"></i>
                </button>
                <button class="action-btn-mini demote" title="Degradar Rango" onclick="manageMember('${m.citizenid}', 'demote')">
                    <i class="fas fa-chevron-down"></i>
                </button>
                <button class="action-btn-mini kick" title="Expulsar de la Organización" onclick="manageMember('${m.citizenid}', 'kick')">
                    <i class="fas fa-user-xmark"></i>
                </button>
            `;
        }

        const tr = `
            <tr>
                <td><strong>${m.name}</strong></td>
                <td><span style="font-family: var(--font-mono); color: var(--text-muted);">${m.citizenid}</span></td>
                <td><span class="member-badge-rank">${m.gradeName || 'Recluta'}</span></td>
                <td>${statusHtml}</td>
                <td class="actions-col">${actionBtns}</td>
            </tr>
        `;
        tbody.append(tr);
    });

    if (!isBoss) {
        $("#btn-invite-member").hide();
    } else {
        $("#btn-invite-member").show();
    }
}

function manageMember(citizenid, action) {
    $.post(`https://spain_criminal/manageMember`, JSON.stringify({
        citizenid: citizenid,
        action: action
    }));
}

// ==========================================
// RENDER ARMERÍA
// ==========================================
function renderWeaponsTab(weapons) {
    const grid = $("#weapons-grid");
    grid.empty();
    if (!weapons) return;

    weapons.forEach(w => {
        let matsHtml = "";
        w.materials.forEach(m => {
            matsHtml += `
                <div class="mat-item">
                    <span>${m.label}</span>
                    <span class="mat-qty">x${m.amount}</span>
                </div>
            `;
        });

        const card = `
            <div class="craft-card" data-type="weapon" data-category="${w.category}">
                <div>
                    <div class="craft-card-header">
                        <div class="craft-icon"><i class="${w.icon || 'fas fa-gun'}"></i></div>
                        <div>
                            <h3>${w.label}</h3>
                            <span class="craft-category">${w.category}</span>
                        </div>
                        <span class="craft-time"><i class="fas fa-clock"></i> ${(w.craftTime / 1000)}s</span>
                    </div>
                    <div class="materials-list">
                        <span class="materials-title">Componentes requeridos:</span>
                        ${matsHtml}
                    </div>
                </div>
                <button class="btn-action primary btn-craft" onclick="startCrafting('weapon', '${w.id}', ${w.craftTime}, '${w.label}')">
                    <i class="fas fa-hammer"></i> Fabricar Armamento
                </button>
            </div>
        `;
        grid.append(card);
    });
}

// ==========================================
// RENDER LABORATORIO DE DROGAS
// ==========================================
function renderDrugsTab(drugs) {
    const grid = $("#drugs-grid");
    grid.empty();
    if (!drugs) return;

    drugs.forEach(d => {
        let matsHtml = "";
        d.materials.forEach(m => {
            matsHtml += `
                <div class="mat-item">
                    <span>${m.label}</span>
                    <span class="mat-qty">x${m.amount}</span>
                </div>
            `;
        });

        const card = `
            <div class="craft-card">
                <div>
                    <div class="craft-card-header">
                        <div class="craft-icon drug"><i class="${d.icon || 'fas fa-flask'}"></i></div>
                        <div>
                            <h3>${d.label}</h3>
                            <span class="craft-category">${d.category}</span>
                        </div>
                        <span class="craft-time"><i class="fas fa-clock"></i> ${(d.craftTime / 1000)}s</span>
                    </div>
                    <div class="materials-list">
                        <span class="materials-title">Reactivos químicos requeridos:</span>
                        ${matsHtml}
                    </div>
                </div>
                <button class="btn-action primary btn-craft" style="background: var(--secondary); box-shadow: 0 4px 15px rgba(0, 210, 255, 0.35);" onclick="startCrafting('drug', '${d.id}', ${d.craftTime}, '${d.label}')">
                    <i class="fas fa-vial-circle-check"></i> Sintetizar en Laboratorio
                </button>
            </div>
        `;
        grid.append(card);
    });
}

// ==========================================
// CRAFTING CON ANIMACIÓN
// ==========================================
function startCrafting(type, recipeId, duration, label) {
    if (isCrafting) return;
    isCrafting = true;

    $("#crafting-progress-box").removeClass("hidden");
    $("#crafting-status-label").html(`<i class="fas fa-cog fa-spin"></i> Procesando: ${label}...`);
    
    let elapsed = 0;
    const interval = 100;
    const progressFill = $("#crafting-bar-fill");
    const progressPercent = $("#crafting-percent");

    const timer = setInterval(() => {
        elapsed += interval;
        const pct = Math.min(100, Math.floor((elapsed / duration) * 100));
        progressFill.css("width", pct + "%");
        progressPercent.text(pct + "%");

        if (elapsed >= duration) {
            clearInterval(timer);
            setTimeout(() => {
                $("#crafting-progress-box").addClass("hidden");
                progressFill.css("width", "0%");
                isCrafting = false;
                
                // Enviar al servidor para entregar el item y restar materiales
                $.post(`https://spain_criminal/craftItem`, JSON.stringify({
                    type: type,
                    recipeId: recipeId
                }));
            }, 500);
        }
    }, interval);
}

// ==========================================
// RENDER GARAJE PRIVADO
// ==========================================
function renderGarageTab(vehicles) {
    const grid = $("#garage-vehicles-grid");
    grid.empty();
    if (!vehicles || vehicles.length === 0) {
        grid.html('<p style="color: var(--text-muted); grid-column: span 2;">Tu organización aún no tiene vehículos exclusivos configurados o asignados.</p>');
        return;
    }

    vehicles.forEach(v => {
        const card = `
            <div class="veh-card">
                <div class="veh-info-group">
                    <div class="veh-icon"><i class="${v.icon || 'fas fa-car'}"></i></div>
                    <div class="veh-details">
                        <h3>${v.label}</h3>
                        <span class="veh-rank-req">Rango mínimo: Grado ${v.minGrade}</span>
                    </div>
                </div>
                <button class="btn-action primary" onclick="spawnGarageVehicle('${v.model}')">
                    <i class="fas fa-key"></i> Sacar de Garaje
                </button>
            </div>
        `;
        grid.append(card);
    });
}

function spawnGarageVehicle(model) {
    $.post(`https://spain_criminal/spawnOrgVehicle`, JSON.stringify({
        model: model
    }));
    closeTablet();
}

// ==========================================
// RENDER MERCADO NEGRO
// ==========================================
function renderBlackMarketTab(items) {
    const grid = $("#blackmarket-grid");
    grid.empty();
    if (!items) return;

    items.forEach(item => {
        const card = `
            <div class="shop-card">
                <div>
                    <div class="shop-card-top">
                        <div class="shop-icon"><i class="${item.icon || 'fas fa-box'}"></i></div>
                        <h4>${item.label}</h4>
                    </div>
                </div>
                <div>
                    <div class="shop-price">€${item.price.toLocaleString()}</div>
                    <button class="btn-action warning" style="width: 100%; justify-content: center;" onclick="buyMaterial('${item.name}', ${item.price})">
                        <i class="fas fa-shopping-cart"></i> Comprar
                    </button>
                </div>
            </div>
        `;
        grid.append(card);
    });
}

function buyMaterial(itemName, price) {
    $.post(`https://spain_criminal/buyMaterial`, JSON.stringify({
        item: itemName,
        price: price
    }));
}
