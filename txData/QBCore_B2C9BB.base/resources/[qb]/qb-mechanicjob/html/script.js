const navbarOptions = {
    power: [
        { id: "fMass", label: "Masa del Vehículo (kg)", description: "Peso total del chasis y carrocería en kilogramos. Afecta inercia y gravedad.", min: 0, max: 10000, step: 10 },
        { id: "fInitialDragCoeff", label: "Coeficiente de Resistencia Aerodinámica", description: "Fricción con el aire. Un valor menor incrementa la aceleración a altas velocidades.", min: 0, max: 100, step: 0.1 },
        { id: "fDownforceModifier", label: "Carga Aerodinámica (Downforce)", description: "Fuerza que empuja el coche hacia el suelo en curvas para no perder adherencia.", min: 0, max: 100, step: 0.1 },
        { id: "nInitialDriveGears", label: "Número de Velocidades / Marchas", description: "Cantidad de relaciones de transmisión en la caja de cambios.", min: 1, max: 10, step: 1 },
        { id: "fInitialDriveForce", label: "Fuerza de Tracción / Potencia Motor", description: "Entrega de par motor hacia las ruedas. Aumenta drásticamente la aceleración.", min: 0, max: 100, step: 0.01 },
        { id: "fDriveInertia", label: "Inercia de Revoluciones (RPM)", description: "Velocidad a la que el motor sube de revoluciones al pisar el acelerador.", min: 0, max: 2, step: 0.05 },
        { id: "fDriveBiasFront", label: "Reparto de Tracción (AWD/RWD/FWD)", description: "0.0 = Propulsión Trasera RWD puro | 0.5 = Total 4x4 AWD | 1.0 = Delantera FWD", min: 0, max: 1, step: 0.05 },
        { id: "fInitialDriveMaxFlatVel", label: "Velocidad Punta Teórica", description: "Velocidad máxima alcanzable al corte de inyección en última marcha.", min: 0, max: 1000, step: 5 },
        { id: "fClutchChangeRateScaleUpShift", label: "Rapidez Embrague (Subir Marcha)", description: "Velocidad a la que engrana la siguiente marcha. Ideal caja secuencial o DSG.", min: 0, max: 100, step: 0.5 },
        { id: "fClutchChangeRateScaleDownShift", label: "Rapidez Embrague (Reducciones)", description: "Agilidad del punta-tacón automático en reducciones bruscas antes de curva.", min: 0, max: 100, step: 0.5 },
    ],
    braking: [
        { id: "fSteeringLock", label: "Ángulo de Giro de Dirección", description: "Grado máximo de giro de las ruedas delanteras. Aumenta para drift amplio.", min: 0, max: 1, step: 0.01 },
        { id: "fBrakeForce", label: "Potencia de Frenada Principal", description: "Mordida de las pinzas de freno cerámicas sobre los cuatro discos.", min: 0, max: 100, step: 0.1 },
        { id: "fBrakeBiasFront", label: "Reparto de Frenada (Delantero / Trasero)", description: "0.0 = Frenada trasera | 0.5 = 50/50 equilibrada | 1.0 = Frenada delantera", min: 0, max: 1, step: 0.05 },
        { id: "fHandBrakeForce", label: "Freno de Mano Hidráulico", description: "Fuerza del freno de mano. Valores altos bloquean el eje trasero para cruzar el coche.", min: 0, max: 100, step: 0.5 },
    ],
    traction: [
        { id: "fTractionCurveMax", label: "Adherencia Máxima en Apoyo", description: "Límite de agarre lateral de los neumáticos en curva rápida.", min: 0, max: 100, step: 0.1 },
        { id: "fTractionCurveMin", label: "Adherencia Mínima en Tracción", description: "Grip al acelerar a fondo o frenar en línea recta sin patinar.", min: 0, max: 100, step: 0.1 },
        { id: "fTractionCurveLateral", label: "Progresividad Lateral de Curva", description: "Sensibilidad al límite de agarre antes de perder la trasera.", min: 0, max: 100, step: 0.5 },
        { id: "fTractionSpringDeltaMax", label: "Delta de Pérdida de Tracción", description: "Altura respecto al suelo a partir de la cual los neumáticos pierden contacto.", min: 0, max: 100, step: 0.5 },
        { id: "fLowSpeedTractionLossMult", label: "Pérdida de Grip a Baja Velocidad (Burnout)", description: "Valores altos permiten quemar rueda y derrapar desde parado.", min: 0, max: 100, step: 0.1 },
        { id: "fTractionBiasFront", label: "Reparto de Agarre Ejes", description: "Balance de tracción entre eje delantero y trasero en apoyos dinámicos.", min: 0, max: 1, step: 0.05 },
        { id: "fCamberStiffnesss", label: "Rigidez de Caída / Camber", description: "Agarre en deriva y derrape continuo (Stance / Drift tune).", min: 0, max: 100, step: 0.1 },
        { id: "fTractionLossMult", label: "Pérdida en Superficies Deslizantes", description: "Comportamiento del neumático sobre agua, tierra, gravilla o barro.", min: 0, max: 100, step: 0.1 },
    ],
    suspension: [
        { id: "fSuspensionForce", label: "Dureza de Muelles de Suspensión", description: "Rigidez de la amortiguación deportiva. Mayor valor reduce balanceo.", min: 0, max: 100, step: 0.1 },
        { id: "fSuspensionCompDamp", label: "Amortiguación en Compresión", description: "Resistencia del amortiguador al comprimirse en baches o frenadas.", min: 0, max: 100, step: 0.1 },
        { id: "fSuspensionReboundDamp", label: "Amortiguación en Extensión / Rebote", description: "Velocidad a la que el amortiguador regresa a su posición neutral.", min: 0, max: 100, step: 0.1 },
        { id: "fSuspensionRaise", label: "Altura del Chasis (Stance / Drop)", description: "Elevación o rebaje de la carrocería sobre las ruedas.", min: -0.15, max: 0.25, step: 0.005 },
        { id: "fSuspensionBiasFront", label: "Reparto de Dureza Delantera/Trasera", description: "Equilibrio de suspensión entre eje delantero y trasero.", min: 0, max: 1, step: 0.05 },
        { id: "fAntiRollBarForce", label: "Barras Estabilizadoras Antivuelco", description: "Rigidez contra el balanceo lateral del chasis en apoyos fuertes.", min: 0, max: 100, step: 0.1 },
        { id: "fAntiRollBarBiasFront", label: "Reparto Barras Estabilizadoras", description: "Distribución de rigidez entre barra delantera y trasera.", min: 0, max: 1, step: 0.05 },
    ],
    miscellaneous: [
        { id: "fEngineDamageMult", label: "Multiplicador Daño Motor", description: "Resistencia térmica y mecánica del bloque motor ante sobreesfuerzo.", min: 0, max: 10, step: 0.1 },
        { id: "fCollisionDamageMult", label: "Resistencia a Colisión Chasis", description: "Absorción de impacto en la deformación de la carrocería.", min: 0, max: 10, step: 0.1 },
        { id: "fPetrolTankVolume", label: "Capacidad Depósito Combustible", description: "Litros de carburante de alta densidad en el tanque de competición.", min: 0, max: 100, step: 1 },
        { id: "fOilVolume", label: "Capacidad Cárter de Aceite", description: "Volumen de lubricante sintético en el cárter seco.", min: 0, max: 100, step: 1 },
    ],
};

let currentStats = {};
let activeTab = "power";

// Mostrar campos de la opción seleccionada
const displayFieldsForNavbarOption = (option) => {
    activeTab = option;
    const contentArea = document.getElementById("content-area");
    const diagPanel = document.getElementById("diagnostics-panel");
    const presetsPanel = document.getElementById("presets-panel");

    // Limpiar clases activas en tabs
    document.querySelectorAll(".nav-tab").forEach((tab) => {
        if (tab.getAttribute("data-tab") === option) {
            tab.classList.add("active");
        } else {
            tab.classList.remove("active");
        }
    });

    if (option === "diagnostics") {
        contentArea.style.display = "none";
        presetsPanel.style.display = "none";
        diagPanel.style.display = "flex";
        document.getElementById("table-description").textContent = "Monitoreo en directo de presión de aceite, bujías, temperatura de culata y embrague.";
        return;
    }

    if (option === "presets") {
        contentArea.style.display = "none";
        diagPanel.style.display = "none";
        presetsPanel.style.display = "flex";
        document.getElementById("table-description").textContent = "Selecciona un mapa Stage preconfigurado para flashear la centralita instantáneamente.";
        return;
    }

    diagPanel.style.display = "none";
    presetsPanel.style.display = "none";
    contentArea.style.display = "grid";
    contentArea.innerHTML = "";

    const selectedOptions = navbarOptions[option] || [];

    selectedOptions.forEach((param) => {
        const card = document.createElement("div");
        card.classList.add("param-card");

        const val = currentStats[param.id] !== undefined ? currentStats[param.id] : (param.min || 0);

        card.innerHTML = `
            <div class="param-top-row">
                <span class="param-title">
                    <i class="fa-solid fa-microchip"></i>
                    ${param.label}
                </span>
                <span class="param-id-tag">${param.id}</span>
            </div>
            <div class="param-inputs-row">
                <input type="range" class="param-slider" id="slider-${param.id}" 
                    min="${param.min}" max="${param.max}" step="${param.step || 0.1}" value="${val}">
                <input type="number" class="param-num-input number-input" id="${param.id}" 
                    min="${param.min}" max="${param.max}" step="${param.step || 0.1}" value="${val}">
            </div>
        `;

        // Tooltip descripción al hacer hover
        card.addEventListener("mouseenter", () => {
            document.getElementById("table-description").textContent = param.description || param.label;
        });

        // Sincronización Slider <-> Input numérico
        const slider = card.querySelector(`#slider-${param.id}`);
        const numInput = card.querySelector(`#${param.id}`);

        slider.addEventListener("input", (e) => {
            numInput.value = e.target.value;
            currentStats[param.id] = parseFloat(e.target.value);
        });

        numInput.addEventListener("input", (e) => {
            slider.value = e.target.value;
            currentStats[param.id] = parseFloat(e.target.value);
        });

        contentArea.appendChild(card);
    });
};

// Aplicar Presets Rápidos
window.applyPreset = (type) => {
    if (type === "street") {
        if (currentStats["fInitialDriveForce"]) currentStats["fInitialDriveForce"] = (parseFloat(currentStats["fInitialDriveForce"]) * 1.25).toFixed(3);
        if (currentStats["fDriveInertia"]) currentStats["fDriveInertia"] = 1.2;
        if (currentStats["fBrakeForce"]) currentStats["fBrakeForce"] = 1.4;
        displayNotification("Mapa Stage 1 (Calle / Sport) cargado en telemetría.");
    } else if (type === "race") {
        if (currentStats["fInitialDriveForce"]) currentStats["fInitialDriveForce"] = (parseFloat(currentStats["fInitialDriveForce"]) * 1.6).toFixed(3);
        if (currentStats["fDriveInertia"]) currentStats["fDriveInertia"] = 1.6;
        if (currentStats["fDownforceModifier"]) currentStats["fDownforceModifier"] = 2.5;
        if (currentStats["fBrakeForce"]) currentStats["fBrakeForce"] = 2.0;
        displayNotification("Mapa Stage 3 (Circuito / Competición) cargado en telemetría.");
    } else if (type === "drift") {
        currentStats["fDriveBiasFront"] = 0.0; // 100% RWD
        currentStats["fSteeringLock"] = 0.85; // Alto ángulo
        if (currentStats["fHandBrakeForce"]) currentStats["fHandBrakeForce"] = 3.5;
        displayNotification("Mapa Drift King (100% RWD + 65° giro) cargado en telemetría.");
    } else if (type === "eco") {
        if (currentStats["fInitialDriveForce"]) currentStats["fInitialDriveForce"] = (parseFloat(currentStats["fInitialDriveForce"]) * 0.9).toFixed(3);
        currentStats["fDriveBiasFront"] = 0.5; // Tracción equilibrada
        displayNotification("Mapa Eco Urbano eficiente cargado en telemetría.");
    }

    displayFieldsForNavbarOption("power");
};

function displayNotification(msg) {
    document.getElementById("table-description").textContent = "✓ " + msg;
}

const openTuner = (stats) => {
    currentStats = stats || {};
    document.querySelector(".tablet-chassis").parentElement.style.display = "flex";
    displayFieldsForNavbarOption("power");

    // Simulación de fluctuación de telemetría sutil
    const boostDisplay = document.getElementById("boost-display");
    if (boostDisplay) {
        setInterval(() => {
            const randomBoost = (1.7 + Math.random() * 0.25).toFixed(2);
            boostDisplay.textContent = `${randomBoost} BAR`;
        }, 1500);
    }
};

const saveSettings = () => {
    let data = {};
    let isInputValid = true;

    // Recoger todos los parámetros actualmente en stats o en inputs
    const inputs = document.querySelectorAll(".number-input");
    inputs.forEach((input) => {
        const val = parseFloat(input.value);
        const min = parseFloat(input.min);
        const max = parseFloat(input.max);

        if (isNaN(val) || val < min || val > max) {
            isInputValid = false;
        } else {
            data[input.id] = val;
            currentStats[input.id] = val;
        }
    });

    // Añadir todos los que ya estuvieran calculados
    Object.keys(currentStats).forEach((key) => {
        if (data[key] === undefined) {
            data[key] = currentStats[key];
        }
    });

    if (isInputValid) {
        document.getElementById("table-description").textContent = "⚡ Flasheando centralita ECU... Ajustes transmitidos al vehículo.";
        fetch("https://qb-mechanicjob/saveTune", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(data),
        });
        setTimeout(() => {
            closeTuner();
        }, 600);
    } else {
        document.getElementById("table-description").textContent = "⚠ Error: Algunos valores están fuera de rango permitido.";
    }
};

const resetSettings = () => {
    fetch("https://qb-mechanicjob/reset", { method: "POST" });
    closeTuner();
};

const closeTuner = () => {
    document.querySelector(".tablet-chassis").parentElement.style.display = "none";
    fetch("https://qb-mechanicjob/closeTuner", { method: "POST" });
};

// Eventos de clicks en navegación y botones
document.addEventListener("click", function (event) {
    const navTab = event.target.closest(".nav-tab");
    if (navTab) {
        const tabTarget = navTab.getAttribute("data-tab");
        if (tabTarget) {
            displayFieldsForNavbarOption(tabTarget);
        }
        return;
    }

    const targetId = event.target.id || event.target.closest("button")?.id;

    switch (targetId) {
        case "save-button":
            saveSettings();
            break;
        case "reset-button":
            resetSettings();
            break;
        case "cancel":
        case "close-x-btn":
            closeTuner();
            break;
    }
});

document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
        closeTuner();
    }
});

window.addEventListener("message", function (event) {
    var eventData = event.data;
    if (eventData.action == "openTuner") {
        openTuner(eventData.stats);
    }
});
