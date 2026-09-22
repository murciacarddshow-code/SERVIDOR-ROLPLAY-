let count = 0;
let thisCount = 0;
let progress = 10;

const loadingText = document.getElementById('loading-status');
const loadingPct = document.getElementById('loading-pct');
const progressFill = document.getElementById('progress-fill');
const musicToggleBtn = document.getElementById('music-toggle');
const bgAudio = document.getElementById('bg-audio');

// FiveM Native Loading Events
const handlers = {
    startInitFunctionOrder(data) {
        count = data.count;
    },
    initFunctionInvoking(data) {
        document.getElementById('loading-status').innerText = `Iniciando sistemas: ${data.name || 'Componentes de Rol'}...`;
        progress = Math.min(95, Math.floor((data.idx / count) * 100));
        updateProgress(progress);
    },
    startDataFileEntries(data) {
        count = data.count;
    },
    performMapLoadFunction(data) {
        thisCount++;
        progress = Math.min(98, Math.floor((thisCount / count) * 100));
        document.getElementById('loading-status').innerText = 'Sincronizando mapa y texturas urbanas...';
        updateProgress(progress);
    },
    onLogLine(data) {
        if (data.message && data.message.includes('Initialized')) {
            document.getElementById('loading-status').innerText = 'Preparando personaje e inventario...';
        }
    }
};

window.addEventListener('message', function (e) {
    (handlers[e.data.eventName] || function () {})(e.data);
});

// Update UI
function updateProgress(val) {
    if (progressFill) progressFill.style.width = `${val}%`;
    if (loadingPct) loadingPct.innerText = `${val}%`;
}

// Simulated progressive feel for initial loading
let simPct = 15;
const simTimer = setInterval(() => {
    if (simPct < 90) {
        simPct += Math.floor(Math.random() * 4) + 1;
        if (simPct > progress) {
            updateProgress(simPct);
        }
    } else {
        clearInterval(simTimer);
    }
}, 800);

// Audio Controller
if (bgAudio) {
    bgAudio.volume = 0.25;
    
    // Auto-play attempt
    const playPromise = bgAudio.play();
    if (playPromise !== undefined) {
        playPromise.catch(() => {
            if (musicToggleBtn) musicToggleBtn.innerText = '▶️ Reproducir Música';
        });
    }

    if (musicToggleBtn) {
        musicToggleBtn.addEventListener('click', () => {
            if (bgAudio.paused) {
                bgAudio.play();
                musicToggleBtn.innerText = '⏸️ Pausar Música';
            } else {
                bgAudio.pause();
                musicToggleBtn.innerText = '▶️ Reproducir Música';
            }
        });
    }
}
