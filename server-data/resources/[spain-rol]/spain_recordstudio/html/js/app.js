/**
 * A-Records Vinewood • NUI Application Controller
 */

let studioData = {
    citizenid: "",
    playerName: "Artista",
    cash: 0,
    bank: 0,
    topSongs: [],
    drafts: [],
    defaultBeats: [],
    defaultCovers: []
};

let selectedCover = "";
let isRecording = false;
let recordSeconds = 0;
let recordTimerInterval = null;
let broadcastEnabled = true;

// Inicialización de Eventos DOM
document.addEventListener("DOMContentLoaded", () => {
    window.Visualizer.init();
    setupNavigation();
    setupTransportControls();
    setupMixerFaders();
    setupBoothRecording();
    setupSongwriter();
    setupVinylPress();
    setupVinylPlayerWidget();

    // Tecla ESC para cerrar
    document.addEventListener("keydown", (e) => {
        if (e.key === "Escape") {
            closeStudio();
            closeLyricsModal();
        }
    });

    document.getElementById("btn-close-studio").addEventListener("click", closeStudio);
    document.getElementById("btn-close-modal").addEventListener("click", closeLyricsModal);
});

// Listener de Mensajes NUI de FiveM
window.addEventListener("message", (event) => {
    const item = event.data;
    if (!item) return;

    if (item.action === "openStudio") {
        studioData = item.data;
        document.getElementById("user-artist-name").textContent = studioData.playerName || "Artista";
        document.getElementById("press-artist").value = studioData.playerName || "";

        // Rellenar Catálogo de Beats
        renderBeatsCatalog(studioData.defaultBeats);

        // Rellenar Carátulas
        renderCoversPalette(studioData.defaultCovers);

        // Rellenar Borradores
        renderDraftsList(studioData.drafts);

        // Rellenar Billboard
        renderBillboard(studioData.topSongs);

        // Abrir pestaña solicitada
        switchTab(item.tab || "mixer");

        document.getElementById("studio-app").classList.remove("hidden");
    } 
    else if (item.action === "updateLikes") {
        updateSongLikeDisplay(item.songId, item.likes, item.isLiked);
    }
    else if (item.action === "playStudioMonitor") {
        if (item.payload) {
            window.AudioEngine.init();
            if (item.payload.audioUrl) {
                window.AudioEngine.loadCustomAudioUrl(item.payload.audioUrl);
            } else if (item.payload.beatId) {
                window.AudioEngine.setBeat(item.payload.beatId, item.payload.bpm);
            }
            window.AudioEngine.setMasterVolume(Math.floor((item.volume || 0.8) * 100));
            window.AudioEngine.play();
        }
    }
    else if (item.action === "stopStudioMonitor" || item.action === "stopAllAudio") {
        window.AudioEngine.stop();
        document.getElementById("vinyl-portable-player").classList.add("hidden");
    }
    else if (item.action === "openVinylPlayer") {
        openVinylWidget(item.info);
    }
});

// Cerrar NUI
function closeStudio() {
    window.AudioEngine.stop();
    document.getElementById("studio-app").classList.add("hidden");
    fetch(`https://${GetParentResourceName()}/close`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({})
    });
}

// Navegación por pestañas
function setupNavigation() {
    const tabs = document.querySelectorAll(".nav-tab");
    tabs.forEach(tab => {
        tab.addEventListener("click", () => {
            const target = tab.getAttribute("data-tab");
            switchTab(target);
        });
    });
}

function switchTab(tabId) {
    document.querySelectorAll(".nav-tab").forEach(t => {
        t.classList.toggle("active", t.getAttribute("data-tab") === tabId);
    });
    document.querySelectorAll(".tab-content").forEach(c => {
        c.classList.remove("active");
    });
    const targetContent = document.getElementById(`tab-${tabId}`);
    if (targetContent) targetContent.classList.add("active");
}

// Renderizado de Beats
function renderBeatsCatalog(beats) {
    const container = document.getElementById("beats-container");
    const select = document.getElementById("select-active-beat");
    if (!container || !beats) return;

    container.innerHTML = "";
    select.innerHTML = "";

    beats.forEach((b, idx) => {
        // Option
        const opt = document.createElement("option");
        opt.value = b.id;
        opt.textContent = `${b.genre}: ${b.title} (${b.bpm} BPM)`;
        select.appendChild(opt);

        // Card
        const card = document.createElement("div");
        card.className = `beat-card ${idx === 0 ? 'active' : ''}`;
        card.setAttribute("data-id", b.id);
        card.setAttribute("data-bpm", b.bpm);
        card.innerHTML = `
            <div class="beat-card-header">
                <span class="beat-genre">${b.genre}</span>
                <span class="beat-bpm">${b.bpm} BPM</span>
            </div>
            <div class="beat-title">${b.title}</div>
            <div class="beat-producer">${b.producer}</div>
        `;

        card.addEventListener("click", () => {
            document.querySelectorAll(".beat-card").forEach(c => c.classList.remove("active"));
            card.classList.add("active");
            select.value = b.id;
            selectBeat(b.id, b.bpm);
        });

        container.appendChild(card);
    });

    select.addEventListener("change", (e) => {
        const beat = beats.find(b => b.id === e.target.value);
        if (beat) {
            document.querySelectorAll(".beat-card").forEach(c => {
                c.classList.toggle("active", c.getAttribute("data-id") === beat.id);
            });
            selectBeat(beat.id, beat.bpm);
        }
    });

    if (beats.length > 0) {
        selectBeat(beats[0].id, beats[0].bpm);
    }
}

function selectBeat(beatId, bpm) {
    window.AudioEngine.setBeat(beatId, bpm);
    document.getElementById("header-bpm").textContent = `${bpm} BPM`;
    document.getElementById("draft-bpm").value = bpm;
}

// Controles de Transporte (Play, Stop, Broadcast)
function setupTransportControls() {
    const btnPlay = document.getElementById("btn-transport-play");
    const btnStop = document.getElementById("btn-transport-stop");
    const btnLoop = document.getElementById("btn-transport-loop");
    const btnBroadcast = document.getElementById("btn-studio-broadcast");
    const timecode = document.getElementById("studio-timecode");

    btnPlay.addEventListener("click", () => {
        if (window.AudioEngine.isPlaying) {
            window.AudioEngine.pause();
            btnPlay.innerHTML = '<i class="fa-solid fa-play"></i>';
            btnPlay.classList.remove("playing");
        } else {
            window.AudioEngine.play();
            btnPlay.innerHTML = '<i class="fa-solid fa-pause"></i>';
            btnPlay.classList.add("playing");

            // Sincronizar en el estudio
            if (broadcastEnabled) {
                notifyStudioAudioSync();
            }
        }
    });

    btnStop.addEventListener("click", () => {
        window.AudioEngine.stop();
        btnPlay.innerHTML = '<i class="fa-solid fa-play"></i>';
        btnPlay.classList.remove("playing");
        timecode.textContent = "00:00:00";
    });

    btnLoop.addEventListener("click", () => {
        window.AudioEngine.isLooping = !window.AudioEngine.isLooping;
        btnLoop.classList.toggle("active", window.AudioEngine.isLooping);
    });

    btnBroadcast.addEventListener("click", () => {
        broadcastEnabled = !broadcastEnabled;
        btnBroadcast.querySelector(".state").textContent = broadcastEnabled ? "ACTIVO" : "SILENCIADO";
        btnBroadcast.classList.toggle("active", broadcastEnabled);
    });

    window.AudioEngine.onTimeUpdate = (cur, tot) => {
        const mins = String(Math.floor(cur / 60)).padStart(2, '0');
        const secs = String(cur % 60).padStart(2, '0');
        timecode.textContent = `00:${mins}:${secs}`;
    };

    // Cargar Audio Personalizado
    document.getElementById("btn-load-custom").addEventListener("click", () => {
        const url = document.getElementById("input-custom-audio").value.trim();
        if (url) {
            window.AudioEngine.loadCustomAudioUrl(url);
            window.AudioEngine.play();
            btnPlay.innerHTML = '<i class="fa-solid fa-pause"></i>';
            btnPlay.classList.add("playing");
            if (broadcastEnabled) notifyStudioAudioSync();
        }
    });
}

function notifyStudioAudioSync() {
    const engine = window.AudioEngine;
    fetch(`https://${GetParentResourceName()}/syncStudioAudio`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            beatId: engine.currentBeatId,
            audioUrl: engine.customAudio ? engine.customAudio.src : "",
            bpm: engine.bpm,
            volume: 85
        })
    });
}

// Configuración de Faders y EQ de la Mesa
function setupMixerFaders() {
    const faderBeat = document.getElementById("fader-beat");
    const faderVocal = document.getElementById("fader-vocal");
    const faderAdlib = document.getElementById("fader-adlib");
    const faderMaster = document.getElementById("fader-master");

    faderBeat.addEventListener("input", (e) => {
        window.AudioEngine.setChannelVolume(1, e.target.value);
        document.getElementById("reading-beat").textContent = `${((e.target.value - 85) / 5).toFixed(1)} dB`;
    });

    faderVocal.addEventListener("input", (e) => {
        window.AudioEngine.setChannelVolume(2, e.target.value);
        document.getElementById("reading-vocal").textContent = `${((e.target.value - 90) / 5).toFixed(1)} dB`;
    });

    faderAdlib.addEventListener("input", (e) => {
        window.AudioEngine.setChannelVolume(3, e.target.value);
        document.getElementById("reading-adlib").textContent = `${((e.target.value - 75) / 5).toFixed(1)} dB`;
    });

    faderMaster.addEventListener("input", (e) => {
        window.AudioEngine.setMasterVolume(e.target.value);
        document.getElementById("reading-master").textContent = `${((e.target.value - 90) / 4).toFixed(1)} dB`;
    });

    // EQ
    document.getElementById("beat-eq-low").addEventListener("input", (e) => {
        window.AudioEngine.setEq('low', e.target.value);
        e.target.nextElementSibling.textContent = `${e.target.value > 0 ? '+' : ''}${e.target.value}dB`;
    });
    document.getElementById("beat-eq-mid").addEventListener("input", (e) => {
        window.AudioEngine.setEq('mid', e.target.value);
        e.target.nextElementSibling.textContent = `${e.target.value > 0 ? '+' : ''}${e.target.value}dB`;
    });
    document.getElementById("beat-eq-high").addEventListener("input", (e) => {
        window.AudioEngine.setEq('high', e.target.value);
        e.target.nextElementSibling.textContent = `${e.target.value > 0 ? '+' : ''}${e.target.value}dB`;
    });
}

// Cabina de Grabación & Contador
function setupBoothRecording() {
    const btnRecord = document.getElementById("btn-start-record");
    const countdownEl = document.getElementById("record-countdown");
    const timerEl = document.getElementById("record-timer");
    const badgeAir = document.getElementById("on-air-badge");

    btnRecord.addEventListener("click", () => {
        if (!isRecording) {
            // Iniciar cuenta regresiva 3... 2... 1...
            countdownEl.classList.remove("hidden");
            let count = 3;
            countdownEl.textContent = count;

            const cInterval = setInterval(() => {
                count--;
                if (count > 0) {
                    countdownEl.textContent = count;
                } else if (count === 0) {
                    countdownEl.textContent = "¡GRABA!";
                } else {
                    clearInterval(cInterval);
                    countdownEl.classList.add("hidden");
                    startRecordingSession();
                }
            }, 800);
        } else {
            stopRecordingSession();
        }
    });

    function startRecordingSession() {
        isRecording = true;
        btnRecord.innerHTML = '<i class="fa-solid fa-stop"></i> <span>DETENER GRABACIÓN DE TOMA</span>';
        btnRecord.classList.add("recording");
        badgeAir.className = "badge-air on";
        badgeAir.textContent = "● ON AIR / REC";

        // Iniciar pista si no está sonando
        window.AudioEngine.play();

        // Notificar animación de rapero/cantar al cliente
        fetch(`https://${GetParentResourceName()}/triggerRecordingAnim`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({})
        });

        recordSeconds = 0;
        clearInterval(recordTimerInterval);
        recordTimerInterval = setInterval(() => {
            recordSeconds++;
            const mins = String(Math.floor(recordSeconds / 60)).padStart(2, '0');
            const secs = String(recordSeconds % 60).padStart(2, '0');
            timerEl.textContent = `${mins}:${secs}`;
        }, 1000);
    }

    function stopRecordingSession() {
        isRecording = false;
        clearInterval(recordTimerInterval);
        btnRecord.innerHTML = '<i class="fa-solid fa-circle"></i> <span>INICIAR GRABACIÓN DE TOMA</span>';
        btnRecord.classList.remove("recording");
        badgeAir.className = "badge-air off";
        badgeAir.textContent = "● REC OFF";

        fetch(`https://${GetParentResourceName()}/stopRecordingAnim`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({})
        });

        // Añadir toma al listado
        const takesList = document.getElementById("takes-list");
        const takeNum = takesList.children.length + 1;
        const mins = String(Math.floor(recordSeconds / 60)).padStart(2, '0');
        const secs = String(recordSeconds % 60).padStart(2, '0');

        const takeDiv = document.createElement("div");
        takeDiv.className = "take-item";
        takeDiv.innerHTML = `
            <span class="take-title">Toma ${takeNum} (Voz Grabada)</span>
            <span class="take-time">${mins}:${secs} min</span>
            <button class="btn-take-play"><i class="fa-solid fa-play"></i></button>
        `;
        takesList.prepend(takeDiv);
    }

    // Botón de teleprompter
    document.getElementById("btn-prompter-load-draft").addEventListener("click", () => {
        const lyrics = document.getElementById("draft-lyrics").value;
        if (lyrics) {
            loadLyricsToPrompter(lyrics);
        } else {
            alert("Escribe una letra primero en la pestaña 'Bloc de Compositor'");
        }
    });
}

function loadLyricsToPrompter(text) {
    const display = document.getElementById("prompter-display");
    display.innerHTML = "";
    const lines = text.split("\n").filter(l => l.trim().length > 0);
    lines.forEach((line, idx) => {
        const div = document.createElement("div");
        div.className = `prompter-line ${idx === 0 ? 'highlight' : ''}`;
        div.textContent = line;
        display.appendChild(div);
    });
}

// Bloc de Compositor
function setupSongwriter() {
    const lyricsArea = document.getElementById("draft-lyrics");
    const countEl = document.getElementById("lyrics-char-count");
    const btnSave = document.getElementById("btn-save-draft");

    lyricsArea.addEventListener("input", () => {
        const text = lyricsArea.value;
        const lines = text.split("\n").filter(l => l.trim().length > 0).length;
        const words = text.trim().split(/\s+/).filter(w => w.length > 0).length;
        countEl.textContent = `${lines} versos | ${words} palabras`;
    });

    btnSave.addEventListener("click", () => {
        const title = document.getElementById("draft-title").value.trim() || "Nueva Canción";
        const genre = document.getElementById("draft-genre").value;
        const bpm = document.getElementById("draft-bpm").value;
        const lyrics = lyricsArea.value;

        fetch(`https://${GetParentResourceName()}/saveDraft`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                title, genre, bpm, lyrics
            })
        });

        // Actualizar lista local
        const draftsList = document.getElementById("drafts-list");
        const item = document.createElement("div");
        item.className = "draft-item";
        item.innerHTML = `
            <div class="draft-item-title">${title}</div>
            <div class="draft-item-meta">
                <span>${genre}</span>
                <span>${bpm} BPM</span>
            </div>
        `;
        draftsList.prepend(item);
    });
}

function renderDraftsList(drafts) {
    const list = document.getElementById("drafts-list");
    if (!list || !drafts) return;
    list.innerHTML = "";

    drafts.forEach(d => {
        const div = document.createElement("div");
        div.className = "draft-item";
        div.innerHTML = `
            <div class="draft-item-title">${d.title}</div>
            <div class="draft-item-meta">
                <span>${d.genre}</span>
                <span>${d.bpm} BPM</span>
            </div>
        `;
        div.addEventListener("click", () => {
            document.getElementById("draft-title").value = d.title;
            document.getElementById("draft-genre").value = d.genre;
            document.getElementById("draft-bpm").value = d.bpm;
            document.getElementById("draft-lyrics").value = d.lyrics;
            loadLyricsToPrompter(d.lyrics);
            document.getElementById("preview-song-title").textContent = d.title;
            document.getElementById("press-title").value = d.title;
        });
        list.appendChild(div);
    });
}

// Prensa de Vinilos
function setupVinylPress() {
    const btnSubmit = document.getElementById("btn-submit-press");
    const pressTitle = document.getElementById("press-title");
    const pressArtist = document.getElementById("press-artist");
    const previewTitle = document.getElementById("preview-song-title");
    const previewArtist = document.getElementById("preview-artist-name");

    pressTitle.addEventListener("input", (e) => {
        previewTitle.textContent = e.target.value.trim() || "Título del Single";
    });

    pressArtist.addEventListener("input", (e) => {
        previewArtist.textContent = e.target.value.trim() || "Nombre del Artista";
    });

    document.getElementById("press-custom-cover").addEventListener("input", (e) => {
        const url = e.target.value.trim();
        if (url) {
            selectedCover = url;
            document.getElementById("preview-cover-img").src = url;
        }
    });

    btnSubmit.addEventListener("click", () => {
        const artist = pressArtist.value.trim();
        const title = pressTitle.value.trim();
        const genre = document.getElementById("press-genre").value;
        const audioUrl = document.getElementById("press-audio-url").value.trim() || (window.AudioEngine.customAudio ? window.AudioEngine.customAudio.src : "");
        const lyrics = document.getElementById("draft-lyrics").value;
        const beatId = window.AudioEngine.currentBeatId;
        const bpm = window.AudioEngine.bpm;

        if (!title) {
            alert("Por favor introduce un título para la canción.");
            return;
        }

        fetch(`https://${GetParentResourceName()}/pressVinyl`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                artist,
                title,
                genre,
                audioUrl,
                coverUrl: selectedCover,
                lyrics,
                beatId,
                bpm,
                duration: 180
            })
        });

        closeStudio();
    });
}

function renderCoversPalette(covers) {
    const palette = document.getElementById("covers-palette");
    if (!palette || !covers) return;
    palette.innerHTML = "";

    covers.forEach((url, idx) => {
        const div = document.createElement("div");
        div.className = `cover-thumb ${idx === 0 ? 'active' : ''}`;
        div.innerHTML = `<img src="${url}" alt="Cover">`;
        if (idx === 0) {
            selectedCover = url;
            document.getElementById("preview-cover-img").src = url;
        }

        div.addEventListener("click", () => {
            document.querySelectorAll(".cover-thumb").forEach(c => c.classList.remove("active"));
            div.classList.add("active");
            selectedCover = url;
            document.getElementById("preview-cover-img").src = url;
        });

        palette.appendChild(div);
    });
}

// Billboard Ranking
function renderBillboard(songs) {
    const tbody = document.getElementById("billboard-tbody");
    if (!tbody || !songs) return;
    tbody.innerHTML = "";

    songs.forEach((s, idx) => {
        const tr = document.createElement("tr");
        const rank = idx + 1;
        const rankClass = rank === 1 ? 'rank-1' : (rank === 2 ? 'rank-2' : (rank === 3 ? 'rank-3' : ''));

        tr.innerHTML = `
            <td><div class="rank-badge ${rankClass}">${rank}</div></td>
            <td><img src="${s.cover_url || 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80'}" class="table-cover-img"></td>
            <td><div class="table-song-title">${s.song_title}</div></td>
            <td><div class="table-artist-name">${s.artist_name}</div></td>
            <td><span class="ch-tag cyan-tag">${s.genre}</span></td>
            <td><b>${s.plays || 0}</b></td>
            <td><span id="likes-count-${s.id}">🔥 ${s.likes || 0}</span></td>
            <td>
                <button class="btn-chart-action play-btn" data-id="${s.id}"><i class="fa-solid fa-play"></i></button>
                <button class="btn-chart-action like ${s.user_liked ? 'active' : ''}" data-id="${s.id}"><i class="fa-solid fa-fire"></i></button>
                <button class="btn-chart-action lyrics-btn" data-id="${s.id}"><i class="fa-solid fa-align-left"></i></button>
            </td>
        `;

        // Listeners
        tr.querySelector(".play-btn").addEventListener("click", () => {
            if (s.audio_url) {
                window.AudioEngine.loadCustomAudioUrl(s.audio_url);
            } else if (s.beat_id) {
                window.AudioEngine.setBeat(s.beat_id, s.bpm);
            }
            window.AudioEngine.play();
            switchTab("mixer");

            fetch(`https://${GetParentResourceName()}/incrementPlays`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ songId: s.id })
            });
        });

        tr.querySelector(".like").addEventListener("click", (e) => {
            fetch(`https://${GetParentResourceName()}/likeSong`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ songId: s.id })
            });
        });

        tr.querySelector(".lyrics-btn").addEventListener("click", () => {
            openLyricsModal(s.song_title, s.lyrics);
        });

        tbody.appendChild(tr);
    });
}

function updateSongLikeDisplay(songId, likes, isLiked) {
    const el = document.getElementById(`likes-count-${songId}`);
    if (el) el.textContent = `🔥 ${likes}`;
    const btn = document.querySelector(`.btn-chart-action.like[data-id="${songId}"]`);
    if (btn) btn.classList.toggle("active", isLiked);
}

// Modal de Letras
function openLyricsModal(title, lyrics) {
    document.getElementById("modal-song-title").textContent = title || "Letra";
    document.getElementById("modal-lyrics-content").textContent = lyrics || "No se ha registrado letra para esta canción.";
    document.getElementById("lyrics-modal").classList.remove("hidden");
}

function closeLyricsModal() {
    document.getElementById("lyrics-modal").classList.add("hidden");
}

// Reproductor Portátil de Vinilo Flotante
function setupVinylPlayerWidget() {
    const widget = document.getElementById("vinyl-portable-player");
    const btnClose = document.getElementById("widget-btn-close");
    const btnPlay = document.getElementById("widget-btn-play");
    const volSlider = document.getElementById("widget-vol-slider");

    btnClose.addEventListener("click", () => {
        window.AudioEngine.stop();
        widget.classList.add("hidden");
    });

    btnPlay.addEventListener("click", () => {
        if (window.AudioEngine.isPlaying) {
            window.AudioEngine.pause();
            btnPlay.innerHTML = '<i class="fa-solid fa-play"></i>';
            document.getElementById("widget-spinner").style.animationPlayState = "paused";
        } else {
            window.AudioEngine.play();
            btnPlay.innerHTML = '<i class="fa-solid fa-pause"></i>';
            document.getElementById("widget-spinner").style.animationPlayState = "running";
        }
    });

    volSlider.addEventListener("input", (e) => {
        window.AudioEngine.setMasterVolume(e.target.value);
    });
}

function openVinylWidget(info) {
    const widget = document.getElementById("vinyl-portable-player");
    document.getElementById("widget-title").textContent = info.song_title || "Canción";
    document.getElementById("widget-artist").textContent = info.artist_name || "Artista";
    document.getElementById("widget-cover").src = info.cover_url || "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80";

    widget.classList.remove("hidden");

    window.AudioEngine.init();
    if (info.audio_url && info.audio_url !== "") {
        window.AudioEngine.loadCustomAudioUrl(info.audio_url);
    } else {
        window.AudioEngine.setBeat("reggaeton_flow", info.bpm || 94);
    }
    window.AudioEngine.play();

    document.getElementById("widget-btn-play").innerHTML = '<i class="fa-solid fa-pause"></i>';
    document.getElementById("widget-spinner").style.animationPlayState = "running";

    window.AudioEngine.onTimeUpdate = (cur, tot) => {
        const curMins = String(Math.floor(cur / 60)).padStart(2, '0');
        const curSecs = String(cur % 60).padStart(2, '0');
        document.getElementById("widget-cur-time").textContent = `${curMins}:${curSecs}`;
        const pct = Math.min(100, (cur / tot) * 100);
        document.getElementById("widget-progress-fill").style.width = `${pct}%`;
    };
}
