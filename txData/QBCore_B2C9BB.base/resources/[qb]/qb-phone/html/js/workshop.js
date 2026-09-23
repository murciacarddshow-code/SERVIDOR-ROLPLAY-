var CurrentWorkshopData = null;

function SetupWorkshopApp() {
    $.post('https://qb-phone/GetWorkshopData', JSON.stringify({}), function(data) {
        if (!data) {
            QB.Phone.Notifications.Add("fas fa-exclamation-triangle", "Taller", "No tienes permisos de Jefe de Taller.");
            return;
        }

        CurrentWorkshopData = data;
        RenderWorkshopHeader(data);
        RenderWorkshopFinance(data);
        RenderWorkshopEmployees(data);
        RenderWorkshopSalaries(data);
    });
}

function RenderWorkshopHeader(data) {
    $("#workshop-header-name").text(data.jobLabel || "Taller Mecánico");
    $("#workshop-boss-name").text("Jefe: " + (data.bossName || "Administrador"));
}

function RenderWorkshopFinance(data) {
    var formattedBalance = new Intl.NumberFormat('es-ES').format(data.balance || 0);
    $("#workshop-balance-display").text(formattedBalance + " €");
}

function RenderWorkshopEmployees(data) {
    var container = $("#workshop-employees-list");
    container.html("");

    if (!data.employees || data.employees.length === 0) {
        container.html('<div style="text-align: center; color: #64748b; font-size: 1.1vh; padding: 2vh 0;">No hay mecánicos registrados en la plantilla.</div>');
        return;
    }

    $.each(data.employees, function(i, emp) {
        var statusClass = emp.isOnline ? "online" : "offline";
        var statusText = emp.isOnline ? "En Servicio" : "Desconectado";

        var card = `
            <div class="workshop-employee-card" data-cid="${emp.citizenid}">
                <div class="workshop-emp-top">
                    <span class="workshop-emp-name">${emp.name}</span>
                    <span class="workshop-status-dot ${statusClass}">${statusText}</span>
                </div>
                <div class="workshop-emp-mid">
                    <span class="workshop-emp-grade-badge">${emp.gradeName} (Nivel ${emp.grade})</span>
                    <span>${emp.salary} € / hora</span>
                </div>
                <div class="workshop-emp-actions">
                    <button class="workshop-small-btn change-grade-btn" data-cid="${emp.citizenid}" data-currentgrade="${emp.grade}">
                        <i class="fas fa-user-tag"></i> Cambiar Rol
                    </button>
                    <button class="workshop-small-btn fire fire-emp-btn" data-cid="${emp.citizenid}" title="Despedir">
                        <i class="fas fa-user-times"></i>
                    </button>
                </div>
            </div>
        `;
        container.append(card);
    });
}

function RenderWorkshopSalaries(data) {
    var container = $("#workshop-salaries-list");
    container.html("");

    if (!data.grades || data.grades.length === 0) {
        container.html('<div style="text-align: center; color: #64748b; font-size: 1.1vh;">No hay información de rangos disponible.</div>');
        return;
    }

    $.each(data.grades, function(i, gr) {
        var card = `
            <div class="workshop-salary-item">
                <div class="workshop-salary-left">
                    <span class="workshop-salary-grade">${gr.name}</span>
                    <span class="workshop-salary-desc">Grado ${gr.grade} ${gr.isboss ? '(Jefatura)' : ''}</span>
                </div>
                <div class="workshop-salary-right">
                    <span class="workshop-salary-amount">${gr.payment} €</span>
                    <button class="workshop-salary-edit-btn edit-salary-btn" data-grade="${gr.grade}" data-gradename="${gr.name}" data-current="${gr.payment}">
                        <i class="fas fa-edit"></i>
                    </button>
                </div>
            </div>
        `;
        container.append(card);
    });
}

// Tab Switching
$(document).on('click', '.workshop-tab-btn', function(e) {
    e.preventDefault();
    var targetTab = $(this).data('tab');

    $('.workshop-tab-btn').removeClass('active');
    $(this).addClass('active');

    $('.workshop-section').removeClass('active');
    $('#workshop-sec-' + targetTab).addClass('active');
});

// Depósito de Dinero
$(document).on('click', '#workshop-deposit-trigger', function(e) {
    e.preventDefault();
    ShowWorkshopInputModal("Ingresar Dinero en Taller", "Cantidad en euros (€)...", function(amount) {
        amount = parseInt(amount);
        if (amount && amount > 0) {
            $.post('https://qb-phone/WorkshopDepositMoney', JSON.stringify({ amount: amount }), function() {
                setTimeout(SetupWorkshopApp, 500);
            });
        }
    });
});

// Retirada de Dinero
$(document).on('click', '#workshop-withdraw-trigger', function(e) {
    e.preventDefault();
    ShowWorkshopInputModal("Retirar Dinero del Taller", "Cantidad en euros (€)...", function(amount) {
        amount = parseInt(amount);
        if (amount && amount > 0) {
            $.post('https://qb-phone/WorkshopWithdrawMoney', JSON.stringify({ amount: amount }), function() {
                setTimeout(SetupWorkshopApp, 500);
            });
        }
    });
});

// Contratar Ciudadano Cercano
$(document).on('click', '#workshop-hire-trigger', function(e) {
    e.preventDefault();
    $.post('https://qb-phone/WorkshopGetClosePlayers', JSON.stringify({}), function(players) {
        if (!players || players.length === 0) {
            QB.Phone.Notifications.Add("fas fa-info-circle", "Personal", "No hay ciudadanos cercanos (radio de 5m) para contratar.");
            return;
        }

        var optionsHtml = '<select id="workshop-hire-select" class="workshop-modal-input" style="background:#22272e;">';
        $.each(players, function(i, p) {
            optionsHtml += `<option value="${p.id}">${p.name} (ID: ${p.id})</option>`;
        });
        optionsHtml += '</select>';

        ShowWorkshopCustomModal("Contratar Ciudadano como Aprendiz", optionsHtml, function() {
            var selectedId = $("#workshop-hire-select").val();
            if (selectedId) {
                $.post('https://qb-phone/WorkshopHirePlayer', JSON.stringify({ playerId: selectedId }), function() {
                    setTimeout(SetupWorkshopApp, 500);
                });
            }
        });
    });
});

// Cambiar Rango / Rol
$(document).on('click', '.change-grade-btn', function(e) {
    e.preventDefault();
    var cid = $(this).data('cid');
    var currentGrade = $(this).data('currentgrade');

    if (!CurrentWorkshopData || !CurrentWorkshopData.grades) return;

    var optionsHtml = '<select id="workshop-grade-select" class="workshop-modal-input" style="background:#22272e;">';
    $.each(CurrentWorkshopData.grades, function(i, gr) {
        var selected = (gr.grade == currentGrade) ? 'selected' : '';
        optionsHtml += `<option value="${gr.grade}" ${selected}>${gr.name} (Nivel ${gr.grade} - ${gr.payment}€)</option>`;
    });
    optionsHtml += '</select>';

    ShowWorkshopCustomModal("Asignar Nuevo Rango / Rol", optionsHtml, function() {
        var newGrade = $("#workshop-grade-select").val();
        if (newGrade !== undefined) {
            $.post('https://qb-phone/WorkshopSetGrade', JSON.stringify({ citizenid: cid, grade: newGrade }), function() {
                setTimeout(SetupWorkshopApp, 500);
            });
        }
    });
});

// Despedir Mecánico
$(document).on('click', '.fire-emp-btn', function(e) {
    e.preventDefault();
    var cid = $(this).data('cid');

    ShowWorkshopCustomModal("Confirmar Despido", '<p style="font-size:1.15vh; color:#cbd5e1; text-align:center;">¿Estás seguro de que deseas rescindir el contrato de este empleado?</p>', function() {
        $.post('https://qb-phone/WorkshopFireEmployee', JSON.stringify({ citizenid: cid }), function() {
            setTimeout(SetupWorkshopApp, 500);
        });
    });
});

// Modificar Sueldo de Rango
$(document).on('click', '.edit-salary-btn', function(e) {
    e.preventDefault();
    var grade = $(this).data('grade');
    var gradeName = $(this).data('gradename');
    var current = $(this).data('current');

    ShowWorkshopInputModal(`Sueldo para ${gradeName}`, `Sueldo actual: ${current} €`, function(val) {
        var newSalary = parseInt(val);
        if (newSalary !== null && !isNaN(newSalary) && newSalary >= 0) {
            $.post('https://qb-phone/WorkshopUpdateSalary', JSON.stringify({ grade: grade, salary: newSalary }), function() {
                setTimeout(SetupWorkshopApp, 500);
            });
        }
    });
});

// Funciones Auxiliares de Modal
var activeModalCallback = null;

function ShowWorkshopInputModal(title, placeholder, callback) {
    $("#workshop-modal-title").text(title);
    $("#workshop-modal-body").html(`<input type="number" id="workshop-modal-input-field" class="workshop-modal-input" placeholder="${placeholder}">`);
    $("#workshop-modal").css('display', 'flex');
    activeModalCallback = function() {
        var val = $("#workshop-modal-input-field").val();
        callback(val);
    };
}

function ShowWorkshopCustomModal(title, htmlContent, callback) {
    $("#workshop-modal-title").text(title);
    $("#workshop-modal-body").html(htmlContent);
    $("#workshop-modal").css('display', 'flex');
    activeModalCallback = callback;
}

$(document).on('click', '#workshop-modal-confirm', function(e) {
    e.preventDefault();
    if (activeModalCallback) activeModalCallback();
    $("#workshop-modal").hide();
    activeModalCallback = null;
});

$(document).on('click', '#workshop-modal-cancel', function(e) {
    e.preventDefault();
    $("#workshop-modal").hide();
    activeModalCallback = null;
});
