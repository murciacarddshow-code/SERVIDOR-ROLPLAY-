// ============================================================================
// THE DIAMOND CASINO & RESORT - CLIENT NUI LOGIC & AUDIO ENGINE
// ============================================================================

let AudioCtx = null;
function getAudioContext() {
    if (!AudioCtx) {
        AudioCtx = new (window.AudioContext || window.webkitAudioContext)();
    }
    if (AudioCtx.state === 'suspended') {
        AudioCtx.resume();
    }
    return AudioCtx;
}

// Generador de Sonidos Sintetizados por WebAudio
const SoundFX = {
    tick: () => {
        try {
            const ctx = getAudioContext();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.type = 'triangle';
            osc.frequency.setValueAtTime(800, ctx.currentTime);
            osc.frequency.exponentialRampToValueAtTime(200, ctx.currentTime + 0.04);
            gain.gain.setValueAtTime(0.12, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.04);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start();
            osc.stop(ctx.currentTime + 0.04);
        } catch (e) {}
    },
    coin: () => {
        try {
            const ctx = getAudioContext();
            const now = ctx.currentTime;
            [987, 1318].forEach((freq, i) => {
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.type = 'sine';
                osc.frequency.setValueAtTime(freq, now + (i * 0.08));
                gain.gain.setValueAtTime(0.15, now + (i * 0.08));
                gain.gain.exponentialRampToValueAtTime(0.001, now + (i * 0.08) + 0.25);
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start(now + (i * 0.08));
                osc.stop(now + (i * 0.08) + 0.25);
            });
        } catch (e) {}
    },
    win: () => {
        try {
            const ctx = getAudioContext();
            const now = ctx.currentTime;
            const notes = [523.25, 659.25, 783.99, 1046.50];
            notes.forEach((freq, i) => {
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.type = 'triangle';
                osc.frequency.setValueAtTime(freq, now + (i * 0.12));
                gain.gain.setValueAtTime(0.2, now + (i * 0.12));
                gain.gain.exponentialRampToValueAtTime(0.001, now + (i * 0.12) + 0.4);
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start(now + (i * 0.12));
                osc.stop(now + (i * 0.12) + 0.4);
            });
        } catch (e) {}
    },
    jackpot: () => {
        try {
            const ctx = getAudioContext();
            const now = ctx.currentTime;
            for (let i = 0; i < 8; i++) {
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.type = 'sawtooth';
                osc.frequency.setValueAtTime(400 + (i * 120), now + (i * 0.1));
                gain.gain.setValueAtTime(0.25, now + (i * 0.1));
                gain.gain.exponentialRampToValueAtTime(0.001, now + (i * 0.1) + 0.3);
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start(now + (i * 0.1));
                osc.stop(now + (i * 0.1) + 0.3);
            }
        } catch (e) {}
    }
};

// ============================================================================
// ESTADO GLOBAL DE LA APLICACIÓN
// ============================================================================
let CurrentPlayerData = {};
let ActiveModal = null;

// Escuchar mensajes desde el cliente LUA
window.addEventListener('message', (event) => {
    const d = event.data;
    if (!d || !d.action) return;

    if (d.action === 'openLuckyWheel') {
        openLuckyWheelModal(d.data, d.prizes, d.podiumVehicle);
    } else if (d.action === 'spinWheelToSlice') {
        executeWheelAnimation(d.sliceIndex, d.prize);
    } else if (d.action === 'openCashier') {
        openCashierModal(d.data, d.vipPrice, d.chipRate);
    } else if (d.action === 'openRoulette') {
        openRouletteModal(d.tableType, d.name, d.maxBet, d.chips, d.isVip, d.playerChips);
    } else if (d.action === 'rouletteSpinResult') {
        executeRouletteAnimation(d.result);
    } else if (d.action === 'openSlots') {
        openSlotsModal(d);
    } else if (d.action === 'slotsSpinResult') {
        executeSlotsAnimation(d.result);
    } else if (d.action === 'updateJackpot') {
        const el = document.getElementById('slots-jackpot-amount');
        if (el) el.innerText = Number(d.jackpot).toLocaleString() + ' FICHAS';
    } else if (d.action === 'updatePlayerData') {
        updateAllBalances(d.data);
    }
});

// Cerrar modales con tecla ESC
window.addEventListener('keyup', (e) => {
    if (e.key === 'Escape') {
        closeAllModals();
    }
});

function closeAllModals() {
    document.querySelectorAll('.casino-modal').forEach(m => m.classList.add('hidden'));
    document.getElementById('casino-app').classList.add('hidden');
    ActiveModal = null;
    fetch(`https://${GetParentResourceName()}/closeUI`, { method: 'POST', body: '{}' });
}

function updateAllBalances(data) {
    CurrentPlayerData = data;
    // Cajero
    const uCash = document.getElementById('user-cash');
    const uBank = document.getElementById('user-bank');
    const uChips = document.getElementById('user-chips');
    const uVip = document.getElementById('user-vip-text');
    if (uCash) uCash.innerText = Number(data.cash || 0).toLocaleString() + ' €';
    if (uBank) uBank.innerText = Number(data.bank || 0).toLocaleString() + ' €';
    if (uChips) uChips.innerText = Number(data.chips || 0).toLocaleString() + ' Fichas';
    if (uVip) uVip.innerText = data.isVip ? 'MIEMBRO VIP DIAMOND' : 'ESTÁNDAR';

    // Ruleta & Slots
    const rChips = document.getElementById('roulette-chips-val');
    if (rChips) rChips.innerText = Number(data.chips || 0).toLocaleString();
    const sChips = document.getElementById('slots-chips-val');
    if (sChips) sChips.innerText = Number(data.chips || 0).toLocaleString();
}

// ============================================================================
// 1. LÓGICA DE LA RULETA DIARIA DE LA SUERTE (24H)
// ============================================================================
let LuckyWheelPrizes = [];
let WheelCurrentAngle = 0;
let IsWheelSpinning = false;

function openLuckyWheelModal(playerData, prizes, podiumVehicle) {
    LuckyWheelPrizes = prizes || [];
    CurrentPlayerData = playerData;

    document.getElementById('casino-app').classList.remove('hidden');
    document.getElementById('wheel-modal').classList.remove('hidden');
    ActiveModal = 'wheel';

    // Info del vehículo del podio
    document.getElementById('podium-car-name').innerText = (podiumVehicle || 'VEHÍCULO EXCLUSIVO').toUpperCase();

    // Estado VIP
    const vipBadge = document.getElementById('wheel-vip-badge');
    if (playerData.isVip) vipBadge.classList.remove('hidden');
    else vipBadge.classList.add('hidden');

    // Comprobar Cooldown de 24 horas
    const spinBtn = document.getElementById('btn-spin-wheel');
    const timerText = document.getElementById('wheel-cooldown-text');

    if (playerData.canSpinWheel) {
        spinBtn.disabled = false;
        spinBtn.innerHTML = '<i class="fas fa-play"></i> ¡GIRAR RULETA GRATIS!';
        timerText.innerText = '¡DISPONIBLE AHORA!';
        timerText.style.color = '#00e676';
    } else {
        spinBtn.disabled = true;
        spinBtn.innerHTML = '<i class="fas fa-lock"></i> YA HAS RECLAMADO HOY';
        const rem = playerData.wheelRemaining || 0;
        const h = Math.floor(rem / 3600);
        const m = Math.floor((rem % 3600) / 60);
        timerText.innerText = `${h}h ${m}m RESTANTES`;
        timerText.style.color = '#ff3366';
    }

    drawLuckyWheel(0);
}

function drawLuckyWheel(rotationAngle) {
    const canvas = document.getElementById('lucky-wheel-canvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const numSlices = LuckyWheelPrizes.length || 16;
    const sliceAngle = (Math.PI * 2) / numSlices;
    const cx = canvas.width / 2;
    const cy = canvas.height / 2;
    const radius = cx - 12;

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    ctx.save();
    ctx.translate(cx, cy);
    ctx.rotate(rotationAngle);

    // Dibujar Slices
    for (let i = 0; i < numSlices; i++) {
        const start = i * sliceAngle;
        const end = start + sliceAngle;
        const prize = LuckyWheelPrizes[i] || {};

        ctx.beginPath();
        ctx.moveTo(0, 0);
        ctx.arc(0, 0, radius, start, end);
        ctx.closePath();

        // Colores alternados
        if (prize.type === 'vehicle') {
            ctx.fillStyle = '#d4af37'; // Oro brillante para el coche
        } else if (i % 2 === 0) {
            ctx.fillStyle = '#1c202a';
        } else {
            ctx.fillStyle = '#0f1117';
        }
        ctx.fill();

        // Borde del sector
        ctx.strokeStyle = 'rgba(212, 175, 55, 0.4)';
        ctx.lineWidth = 1.5;
        ctx.stroke();

        // Texto e Iconos en el Slice
        ctx.save();
        ctx.rotate(start + sliceAngle / 2);
        ctx.textAlign = 'right';
        ctx.fillStyle = (prize.type === 'vehicle') ? '#121005' : '#ffffff';
        ctx.font = 'bold 11px Montserrat';
        ctx.fillText(prize.label || '', radius - 20, 4);
        ctx.restore();
    }

    // Borde Exterior Dorado con Remaches
    ctx.beginPath();
    ctx.arc(0, 0, radius, 0, Math.PI * 2);
    ctx.strokeStyle = '#d4af37';
    ctx.lineWidth = 8;
    ctx.stroke();

    for (let i = 0; i < numSlices * 2; i++) {
        const pinAngle = (Math.PI * 2 / (numSlices * 2)) * i;
        const px = Math.cos(pinAngle) * (radius - 4);
        const py = Math.sin(pinAngle) * (radius - 4);
        ctx.beginPath();
        ctx.arc(px, py, 2.5, 0, Math.PI * 2);
        ctx.fillStyle = '#fff';
        ctx.fill();
    }

    ctx.restore();
}

function spinLuckyWheel() {
    if (IsWheelSpinning) return;
    const btn = document.getElementById('btn-spin-wheel');
    btn.disabled = true;
    btn.innerText = 'GIRANDO...';
    fetch(`https://${GetParentResourceName()}/requestWheelSpin`, { method: 'POST', body: '{}' });
}

function executeWheelAnimation(winningIndex, prize) {
    IsWheelSpinning = true;
    const numSlices = LuckyWheelPrizes.length || 16;
    const sliceAngle = (Math.PI * 2) / numSlices;
    
    // El puntero está arriba en -Math.PI / 2
    // Queremos que el centro del winningIndex (1-indexed) quede arriba
    const targetSliceAngle = (winningIndex - 1) * sliceAngle + (sliceAngle / 2);
    const targetAngle = (Math.PI * 2 * 6) + ((Math.PI * 1.5) - targetSliceAngle);

    const startTime = performance.now();
    const duration = 6000; // 6 segundos de giro suave
    const initialAngle = WheelCurrentAngle % (Math.PI * 2);

    let lastTickAngle = 0;

    function animate(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        
        // Easing cúbico suave de desaceleración (out-cubic / out-quart)
        const ease = 1 - Math.pow(1 - progress, 3.5);
        WheelCurrentAngle = initialAngle + (targetAngle - initialAngle) * ease;

        drawLuckyWheel(WheelCurrentAngle);

        // Sonido de tick cada vez que cruza un remache/sector
        if (Math.abs(WheelCurrentAngle - lastTickAngle) > (sliceAngle / 2)) {
            SoundFX.tick();
            lastTickAngle = WheelCurrentAngle;
        }

        if (progress < 1) {
            requestAnimationFrame(animate);
        } else {
            IsWheelSpinning = false;
            if (prize.type === 'vehicle') {
                SoundFX.jackpot();
            } else {
                SoundFX.win();
            }

            // Notificar al server para otorgar el premio al jugador
            fetch(`https://${GetParentResourceName()}/wheelSpinFinished`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ sliceIndex: winningIndex })
            });

            const timerText = document.getElementById('wheel-cooldown-text');
            timerText.innerText = '¡PREMIO OBTENIDO!';
            timerText.style.color = '#ffd700';
        }
    }

    requestAnimationFrame(animate);
}

// ============================================================================
// 2. LÓGICA DEL CAJERO DE FICHAS & PASE VIP 50K
// ============================================================================

function openCashierModal(data, vipPrice, chipRate) {
    updateAllBalances(data);
    document.getElementById('casino-app').classList.remove('hidden');
    document.getElementById('cashier-modal').classList.remove('hidden');
    ActiveModal = 'cashier';
    switchCashierTab('buy');

    // Si ya es VIP, ajustar botón del pase VIP
    const vipBtn = document.getElementById('btn-buy-vip');
    if (data.isVip) {
        vipBtn.disabled = true;
        vipBtn.innerHTML = '<i class="fas fa-check-circle"></i> YA ERES MIEMBRO VIP';
    } else {
        vipBtn.disabled = false;
        vipBtn.innerHTML = '<i class="fas fa-crown"></i> ADQUIRIR PASE VIP (50.000 €)';
    }
}

function switchCashierTab(tabName) {
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.cashier-tab-content').forEach(c => c.classList.add('hidden'));

    if (tabName === 'buy') {
        document.querySelector('.tab-btn:nth-child(1)').classList.add('active');
        document.getElementById('tab-buy').classList.remove('hidden');
    } else if (tabName === 'sell') {
        document.querySelector('.tab-btn:nth-child(2)').classList.add('active');
        document.getElementById('tab-sell').classList.remove('hidden');
    } else if (tabName === 'vip') {
        document.querySelector('.tab-btn.vip-tab').classList.add('active');
        document.getElementById('tab-vip').classList.remove('hidden');
    }
}

function setChipInput(type, val) {
    if (type === 'buy') {
        document.getElementById('input-buy-amount').value = val;
    } else if (type === 'sell') {
        if (val === 'all') {
            document.getElementById('input-sell-amount').value = CurrentPlayerData.chips || 0;
        } else {
            document.getElementById('input-sell-amount').value = val;
        }
    }
}

function executeBuyChips() {
    const amt = parseInt(document.getElementById('input-buy-amount').value);
    if (!amt || amt <= 0) return;
    const payMethod = document.querySelector('input[name="buy-method"]:checked').value;

    fetch(`https://${GetParentResourceName()}/buyChips`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount: amt, payMethod: payMethod })
    });
    SoundFX.coin();
    document.getElementById('input-buy-amount').value = '';
}

function executeSellChips() {
    const amt = parseInt(document.getElementById('input-sell-amount').value);
    if (!amt || amt <= 0) return;
    const payMethod = document.querySelector('input[name="sell-method"]:checked').value;

    fetch(`https://${GetParentResourceName()}/sellChips`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount: amt, payMethod: payMethod })
    });
    SoundFX.coin();
    document.getElementById('input-sell-amount').value = '';
}

function executeBuyVip() {
    const payMethod = document.querySelector('input[name="vip-method"]:checked').value;
    fetch(`https://${GetParentResourceName()}/buyVip`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ payMethod: payMethod })
    });
    SoundFX.win();
}

// ============================================================================
// 3. LÓGICA DE LA RULETA DE APUESTAS (NORMAL 10K / PREMIUM 100K)
// ============================================================================
let CurrentRouletteTableType = 'Normal';
let CurrentRouletteMaxBet = 10000;
let SelectedChipValue = 100;
let PlacedBets = [];
let IsRouletteSpinning = false;

const RED_NUMS = [1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36];

function openRouletteModal(tableType, name, maxBet, chips, isVip, playerChips) {
    CurrentRouletteTableType = tableType;
    CurrentRouletteMaxBet = maxBet;
    PlacedBets = [];
    IsRouletteSpinning = false;

    document.getElementById('casino-app').classList.remove('hidden');
    document.getElementById('roulette-modal').classList.remove('hidden');
    ActiveModal = 'roulette';

    document.getElementById('roulette-table-title').innerText = name.toUpperCase();
    document.getElementById('roulette-table-tag').innerText = (tableType === 'Premium') ? 'SALA VIP ALTAS APUESTAS' : 'MESA DE RULETA';
    document.getElementById('roulette-limit-desc').innerText = `Apuesta Máxima: ${Number(maxBet).toLocaleString()} € por tirada`;
    document.getElementById('roulette-chips-val').innerText = Number(playerChips || 0).toLocaleString();
    document.getElementById('roulette-current-bet').innerText = '0';
    document.getElementById('roulette-result-msg').innerText = '¡Coloca tus fichas en el tapete y gira!';
    document.getElementById('roulette-winning-num').innerText = '--';
    document.getElementById('roulette-winning-num').className = 'res-ball';

    // Generar tapete de números si está vacío
    buildRouletteNumbersGrid();

    // Generar selector de fichas
    buildChipSelector(chips);

    drawRouletteWheel(0);
}

function buildRouletteNumbersGrid() {
    const grid = document.getElementById('roulette-numbers-grid');
    grid.innerHTML = '';

    // En la ruleta americana/europea estándar las 3 filas son:
    // Fila 1: 3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36
    // Fila 2: 2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35
    // Fila 3: 1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34
    for (let row = 0; row < 3; row++) {
        for (let col = 0; col < 12; col++) {
            const num = (col * 3) + (3 - row);
            const isRed = RED_NUMS.includes(num);
            const cell = document.createElement('div');
            cell.className = `felt-cell num-cell ${isRed ? 'red' : 'black'}`;
            cell.dataset.type = 'straight';
            cell.dataset.value = num;
            cell.innerText = num;
            cell.onclick = () => placeBet('straight', num, cell);
            grid.appendChild(cell);
        }
    }

    // Eventos en celdas exteriores y docenas
    document.querySelectorAll('.felt-dozens-row .felt-cell, .felt-outside-row .felt-cell, .felt-columns-row .felt-cell, .felt-zero-col .felt-cell').forEach(cell => {
        cell.onclick = () => placeBet(cell.dataset.type, cell.dataset.value, cell);
    });
}

function buildChipSelector(chips) {
    const bar = document.getElementById('roulette-chip-selector');
    bar.innerHTML = '';
    SelectedChipValue = chips[0] || 100;

    chips.forEach((cVal, index) => {
        const btn = document.createElement('button');
        btn.className = `chip-btn chip-${cVal} ${index === 0 ? 'selected' : ''}`;
        btn.innerText = (cVal >= 1000) ? (cVal / 1000) + 'k' : cVal;
        btn.onclick = () => {
            document.querySelectorAll('.chip-btn').forEach(b => b.classList.remove('selected'));
            btn.classList.add('selected');
            SelectedChipValue = cVal;
            SoundFX.tick();
        };
        bar.appendChild(btn);
    });
}

function placeBet(type, value, cellElement) {
    if (IsRouletteSpinning) return;

    // Calcular total actual
    const currentTotal = PlacedBets.reduce((acc, b) => acc + b.amount, 0);
    if (currentTotal + SelectedChipValue > CurrentRouletteMaxBet) {
        alert(`¡La apuesta supera el límite máximo de ${CurrentRouletteMaxBet.toLocaleString()} fichas de esta mesa!`);
        return;
    }

    // Agregar o incrementar apuesta
    const existing = PlacedBets.find(b => b.type === type && b.value === value);
    if (existing) {
        existing.amount += SelectedChipValue;
    } else {
        PlacedBets.push({ type: type, value: value, amount: SelectedChipValue });
    }

    // Visualizar badge de fichas en la celda
    let badge = cellElement.querySelector('.chip-badge');
    if (!badge) {
        badge = document.createElement('div');
        badge.className = 'chip-badge';
        cellElement.appendChild(badge);
    }
    const betSum = PlacedBets.find(b => b.type === type && b.value === value).amount;
    badge.innerText = (betSum >= 1000) ? (betSum / 1000) + 'k' : betSum;

    document.getElementById('roulette-current-bet').innerText = (currentTotal + SelectedChipValue).toLocaleString();
    SoundFX.coin();
}

function clearRouletteBets() {
    if (IsRouletteSpinning) return;
    PlacedBets = [];
    document.querySelectorAll('.chip-badge').forEach(b => b.remove());
    document.getElementById('roulette-current-bet').innerText = '0';
    SoundFX.tick();
}

function spinRoulette() {
    if (IsRouletteSpinning) return;
    if (PlacedBets.length === 0) {
        alert('Debes colocar al menos una ficha en el tapete para girar.');
        return;
    }

    IsRouletteSpinning = true;
    document.getElementById('btn-spin-roulette').disabled = true;
    document.getElementById('roulette-result-msg').innerText = 'Girando la ruleta y lanzando la bola...';

    fetch(`https://${GetParentResourceName()}/spinRoulette`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            tableType: CurrentRouletteTableType,
            bets: PlacedBets
        })
    });
}

function drawRouletteWheel(angle) {
    const canvas = document.getElementById('roulette-wheel-canvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const cx = canvas.width / 2;
    const cy = canvas.height / 2;
    const radius = cx - 8;
    const totalPockets = 37;
    const pocketAngle = (Math.PI * 2) / totalPockets;

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    ctx.save();
    ctx.translate(cx, cy);
    ctx.rotate(angle);

    for (let i = 0; i < totalPockets; i++) {
        const start = i * pocketAngle;
        const end = start + pocketAngle;

        ctx.beginPath();
        ctx.moveTo(0, 0);
        ctx.arc(0, 0, radius, start, end);
        ctx.closePath();

        if (i === 0) ctx.fillStyle = '#1b5e20';
        else if (i % 2 === 0) ctx.fillStyle = '#b71c1c';
        else ctx.fillStyle = '#1a1a1a';
        ctx.fill();

        ctx.strokeStyle = 'rgba(212, 175, 55, 0.5)';
        ctx.lineWidth = 1;
        ctx.stroke();
    }

    // Centro metálico
    ctx.beginPath();
    ctx.arc(0, 0, radius * 0.45, 0, Math.PI * 2);
    ctx.fillStyle = '#111';
    ctx.fill();
    ctx.strokeStyle = '#ffd700';
    ctx.lineWidth = 4;
    ctx.stroke();

    ctx.restore();
}

function executeRouletteAnimation(result) {
    const duration = 4500;
    const startTime = performance.now();
    let currentWheelAngle = 0;
    let lastTick = 0;

    function animate(now) {
        const elapsed = now - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const ease = 1 - Math.pow(1 - progress, 3);
        currentWheelAngle = ease * (Math.PI * 2 * 8);

        drawRouletteWheel(currentWheelAngle);

        if (currentWheelAngle - lastTick > 0.4) {
            SoundFX.tick();
            lastTick = currentWheelAngle;
        }

        if (progress < 1) {
            requestAnimationFrame(animate);
        } else {
            IsRouletteSpinning = false;
            document.getElementById('btn-spin-roulette').disabled = false;

            // Mostrar resultado en pantalla
            const numEl = document.getElementById('roulette-winning-num');
            numEl.innerText = result.winningNumber;
            numEl.className = `res-ball ${result.color}`;

            const msgEl = document.getElementById('roulette-result-msg');
            if (result.totalWinnings > 0) {
                msgEl.innerText = `¡GANASTE ${result.totalWinnings.toLocaleString()} FICHAS! (Beneficio: +${result.netProfit.toLocaleString()})`;
                msgEl.style.color = '#00e676';
                SoundFX.win();
            } else {
                msgEl.innerText = `Ha salido el ${result.winningNumber} (${result.color.toUpperCase()}). ¡Suerte en la próxima!`;
                msgEl.style.color = '#ff5252';
            }

            document.getElementById('roulette-chips-val').innerText = result.newChipBalance.toLocaleString();
            clearRouletteBets();
        }
    }

    requestAnimationFrame(animate);
}

// ============================================================================
// 4. LÓGICA DE LAS TRAGAPERRAS / JACKPOT DIAMOND
// ============================================================================
let CurrentSlotBet = 100;
let AvailableSlotBets = [];
let IsSlotSpinning = false;

function openSlotsModal(data) {
    document.getElementById('casino-app').classList.remove('hidden');
    document.getElementById('slots-modal').classList.remove('hidden');
    ActiveModal = 'slots';

    document.getElementById('slots-chips-val').innerText = Number(data.playerChips || 0).toLocaleString();
    document.getElementById('slots-jackpot-amount').innerText = Number(data.currentJackpot || 150000).toLocaleString() + ' FICHAS';

    AvailableSlotBets = data.bets || [100, 250, 500, 1000, 2500];
    CurrentSlotBet = AvailableSlotBets[0];

    // Generar botones de apuesta según si es VIP
    const btnGroup = document.getElementById('slots-bet-buttons');
    btnGroup.innerHTML = '';
    AvailableSlotBets.forEach((bVal, i) => {
        // Filtrar apuestas altas para no VIPs
        if (bVal > data.normalMaxBet && !data.isVip) return;

        const btn = document.createElement('button');
        btn.className = `bet-btn ${i === 0 ? 'active' : ''}`;
        btn.innerText = bVal.toLocaleString();
        btn.onclick = () => {
            document.querySelectorAll('.bet-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            CurrentSlotBet = bVal;
            SoundFX.tick();
        };
        btnGroup.appendChild(btn);
    });
}

function spinSlots() {
    if (IsSlotSpinning) return;
    IsSlotSpinning = true;
    document.getElementById('btn-spin-slots').disabled = true;

    // Animación de rodillos girando
    startReelsSpinningVisual();

    fetch(`https://${GetParentResourceName()}/spinSlots`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ bet: CurrentSlotBet })
    });
}

let ReelSpinInterval = null;
function startReelsSpinningVisual() {
    const symbols = ['🍒', '🍋', '🔔', '🍇', '💎', '7️⃣', '⭐'];
    ReelSpinInterval = setInterval(() => {
        for (let r = 1; r <= 3; r++) {
            const sym = symbols[Math.floor(Math.random() * symbols.length)];
            const strip = document.getElementById(`reel-strip-${r}`);
            if (strip) strip.innerHTML = `<div class="slot-symbol">${sym}</div>`;
        }
        SoundFX.tick();
    }, 90);
}

function executeSlotsAnimation(result) {
    // Detener rodillo 1 a los 1.2s, rodillo 2 a los 2.0s y rodillo 3 a los 2.8s
    setTimeout(() => {
        document.getElementById('reel-strip-1').innerHTML = `<div class="slot-symbol">${result.symbols[0]}</div>`;
        SoundFX.tick();
    }, 1200);

    setTimeout(() => {
        document.getElementById('reel-strip-2').innerHTML = `<div class="slot-symbol">${result.symbols[1]}</div>`;
        SoundFX.tick();
    }, 2000);

    setTimeout(() => {
        clearInterval(ReelSpinInterval);
        document.getElementById('reel-strip-3').innerHTML = `<div class="slot-symbol">${result.symbols[2]}</div>`;
        IsSlotSpinning = false;
        document.getElementById('btn-spin-slots').disabled = false;

        document.getElementById('slots-chips-val').innerText = result.newChipBalance.toLocaleString();
        document.getElementById('slots-jackpot-amount').innerText = Number(result.currentJackpot).toLocaleString() + ' FICHAS';

        if (result.isJackpot) {
            SoundFX.jackpot();
            alert(`🎉 ¡¡¡GRAN BOTE JACKPOT GANADO!!! Te llevas ${result.winAmount.toLocaleString()} Fichas.`);
        } else if (result.winAmount > 0) {
            SoundFX.win();
        }
    }, 2800);
}
