/**
 * A-Records Vinewood • Audio Visualizer & Hardware VU Meters
 * Renderiza el osciloscopio en tiempo real en el Canvas y los medidores analógicos LED.
 */

class StudioVisualizer {
    constructor() {
        this.canvas = null;
        this.ctx = null;
        this.animationId = null;
        this.dataArray = null;
        this.bufferLength = 0;
    }

    init() {
        this.canvas = document.getElementById("waveform-canvas");
        if (!this.canvas) return;
        this.ctx = this.canvas.getContext("2d");

        // Adaptar resolución de renderizado
        this.canvas.width = this.canvas.offsetWidth * window.devicePixelRatio || 680;
        this.canvas.height = this.canvas.offsetHeight * window.devicePixelRatio || 125;

        this.startLoop();
    }

    startLoop() {
        const draw = () => {
            this.animationId = requestAnimationFrame(draw);
            this.render();
            this.updateHardwareMeters();
        };
        draw();
    }

    render() {
        if (!this.ctx || !this.canvas) return;
        const w = this.canvas.width;
        const h = this.canvas.height;

        this.ctx.fillStyle = "#070a10";
        this.ctx.fillRect(0, 0, w, h);

        // Dibujar rejilla de fondo del osciloscopio (Grid analógico de estudio)
        this.ctx.strokeStyle = "rgba(255, 255, 255, 0.03)";
        this.ctx.lineWidth = 1;
        for (let x = 0; x < w; x += 40) {
            this.ctx.beginPath();
            this.ctx.moveTo(x, 0);
            this.ctx.lineTo(x, h);
            this.ctx.stroke();
        }
        for (let y = 0; y < h; y += 25) {
            this.ctx.beginPath();
            this.ctx.moveTo(0, y);
            this.ctx.lineTo(w, y);
            this.ctx.stroke();
        }

        const engine = window.AudioEngine;
        if (!engine || !engine.analyser) {
            this.drawIdleLine(w, h);
            return;
        }

        if (!engine.isPlaying) {
            this.drawIdleLine(w, h);
            return;
        }

        // Obtener datos de frecuencia y onda
        if (!this.dataArray) {
            this.bufferLength = engine.analyser.frequencyBinCount;
            this.dataArray = new Uint8Array(this.bufferLength);
        }

        engine.analyser.getByteTimeDomainData(this.dataArray);

        // Dibujar Espectro de Frecuencias (Barras Neón de Fondo)
        const freqData = new Uint8Array(this.bufferLength);
        engine.analyser.getByteFrequencyData(freqData);

        const barWidth = (w / this.bufferLength) * 2.2;
        let barX = 0;
        for (let i = 0; i < this.bufferLength; i++) {
            const barHeight = (freqData[i] / 255) * (h * 0.85);

            const grad = this.ctx.createLinearGradient(0, h, 0, h - barHeight);
            grad.addColorStop(0, "rgba(6, 182, 212, 0.15)");
            grad.addColorStop(0.7, "rgba(139, 92, 246, 0.35)");
            grad.addColorStop(1, "rgba(225, 29, 72, 0.7)");

            this.ctx.fillStyle = grad;
            this.ctx.fillRect(barX, h - barHeight, barWidth - 1, barHeight);
            barX += barWidth;
        }

        // Dibujar Onda del Osciloscopio (Línea Neón Cyan / Ruby)
        this.ctx.lineWidth = 2.5;
        this.ctx.strokeStyle = "#06b6d4";
        this.ctx.shadowBlur = 12;
        this.ctx.shadowColor = "rgba(6, 182, 212, 0.8)";

        this.ctx.beginPath();
        const sliceWidth = w / this.bufferLength;
        let x = 0;

        for (let i = 0; i < this.bufferLength; i++) {
            const v = this.dataArray[i] / 128.0;
            const y = (v * h) / 2;

            if (i === 0) {
                this.ctx.moveTo(x, y);
            } else {
                this.ctx.lineTo(x, y);
            }
            x += sliceWidth;
        }

        this.ctx.lineTo(w, h / 2);
        this.ctx.stroke();
        this.ctx.shadowBlur = 0;
    }

    drawIdleLine(w, h) {
        this.ctx.lineWidth = 1.5;
        this.ctx.strokeStyle = "rgba(6, 182, 212, 0.3)";
        this.ctx.beginPath();
        this.ctx.moveTo(0, h / 2);
        this.ctx.lineTo(w, h / 2);
        this.ctx.stroke();
    }

    updateHardwareMeters() {
        const engine = window.AudioEngine;
        const isPlaying = engine && engine.isPlaying;

        // Vúmetros de Canal
        const meterBeat = document.querySelector("#meter-beat .meter-bar");
        const meterVocal = document.querySelector("#meter-vocal .meter-bar");
        const meterAdlib = document.querySelector("#meter-adlib .meter-bar");
        const meterMasterL = document.getElementById("meter-master-l");
        const meterMasterR = document.getElementById("meter-master-r");

        if (isPlaying) {
            const beatLevel = Math.min(95, Math.floor(Math.random() * 45 + 50));
            const vocalLevel = Math.min(90, Math.floor(Math.random() * 55 + 35));
            const adlibLevel = Math.min(80, Math.floor(Math.random() * 40 + 20));
            const masterLevel = Math.min(96, Math.floor((beatLevel + vocalLevel) / 1.7));

            if (meterBeat) meterBeat.style.height = `${beatLevel}%`;
            if (meterVocal) meterVocal.style.height = `${vocalLevel}%`;
            if (meterAdlib) meterAdlib.style.height = `${adlibLevel}%`;
            if (meterMasterL) meterMasterL.style.height = `${masterLevel}%`;
            if (meterMasterR) meterMasterR.style.height = `${Math.max(10, masterLevel - Math.floor(Math.random() * 8))}%`;
        } else {
            if (meterBeat) meterBeat.style.height = "0%";
            if (meterVocal) meterVocal.style.height = "0%";
            if (meterAdlib) meterAdlib.style.height = "0%";
            if (meterMasterL) meterMasterL.style.height = "0%";
            if (meterMasterR) meterMasterR.style.height = "0%";
        }
    }
}

window.Visualizer = new StudioVisualizer();
