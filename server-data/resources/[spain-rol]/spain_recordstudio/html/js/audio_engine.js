/**
 * A-Records Vinewood • Web Audio Engine & DAW Sound Processor
 * Generador de ritmos procedimentales de estudio (Reggaeton, Trap, Drill, HipHop, etc.)
 * y procesador multicanal con ecualizador, reverb, compresor y analizador de espectro.
 */

class StudioAudioEngine {
    constructor() {
        this.ctx = null;
        this.isPlaying = false;
        this.isLooping = true;
        this.currentBeatId = "reggaeton_flow";
        this.customAudio = null;
        this.customAudioSource = null;
        this.currentTime = 0;
        this.duration = 180; // 3 minutos estándar
        this.timerInterval = null;

        // Nodos del Master Bus
        this.masterGain = null;
        this.limiter = null;
        this.analyser = null;

        // Canales
        this.ch1Gain = null; // Beat
        this.eqLow = null;
        this.eqMid = null;
        this.eqHigh = null;

        this.ch2Gain = null; // Vocals
        this.reverbNode = null;
        this.delayNode = null;

        this.ch3Gain = null; // Adlibs
        this.pannerNode = null;

        // Secuenciador de Beats
        this.sequencerTimer = null;
        this.currentStep = 0;
        this.bpm = 94;

        this.onTimeUpdate = null;
        this.onMeterUpdate = null;
    }

    init() {
        if (this.ctx) return;
        const AudioCtx = window.AudioContext || window.webkitAudioContext;
        this.ctx = new AudioCtx();

        // Master Limiter & Analyser
        this.limiter = this.ctx.createDynamicsCompressor();
        this.limiter.threshold.setValueAtTime(-1.0, this.ctx.currentTime);
        this.limiter.knee.setValueAtTime(40, this.ctx.currentTime);
        this.limiter.ratio.setValueAtTime(12, this.ctx.currentTime);
        this.limiter.attack.setValueAtTime(0, this.ctx.currentTime);
        this.limiter.release.setValueAtTime(0.25, this.ctx.currentTime);

        this.masterGain = this.ctx.createGain();
        this.masterGain.gain.setValueAtTime(0.95, this.ctx.currentTime);

        this.analyser = this.ctx.createAnalyser();
        this.analyser.fftSize = 256;
        this.analyser.smoothingTimeConstant = 0.8;

        // Canal 1: Beat / EQ
        this.ch1Gain = this.ctx.createGain();
        this.ch1Gain.gain.setValueAtTime(0.85, this.ctx.currentTime);

        this.eqLow = this.ctx.createBiquadFilter();
        this.eqLow.type = "lowshelf";
        this.eqLow.frequency.setValueAtTime(100, this.ctx.currentTime);
        this.eqLow.gain.setValueAtTime(2, this.ctx.currentTime);

        this.eqMid = this.ctx.createBiquadFilter();
        this.eqMid.type = "peaking";
        this.eqMid.frequency.setValueAtTime(1000, this.ctx.currentTime);
        this.eqMid.gain.setValueAtTime(0, this.ctx.currentTime);

        this.eqHigh = this.ctx.createBiquadFilter();
        this.eqHigh.type = "highshelf";
        this.eqHigh.frequency.setValueAtTime(4000, this.ctx.currentTime);
        this.eqHigh.gain.setValueAtTime(0, this.ctx.currentTime);

        // Canal 2: Vocals / Reverb / Delay
        this.ch2Gain = this.ctx.createGain();
        this.ch2Gain.gain.setValueAtTime(0.90, this.ctx.currentTime);

        this.delayNode = this.ctx.createDelay();
        this.delayNode.delayTime.setValueAtTime(0.3, this.ctx.currentTime);
        this.delayFeedback = this.ctx.createGain();
        this.delayFeedback.gain.setValueAtTime(0.2, this.ctx.currentTime);
        this.delayNode.connect(this.delayFeedback);
        this.delayFeedback.connect(this.delayNode);

        // Canal 3: Ad-libs / Pan
        this.ch3Gain = this.ctx.createGain();
        this.ch3Gain.gain.setValueAtTime(0.75, this.ctx.currentTime);
        if (this.ctx.createStereoPanner) {
            this.pannerNode = this.ctx.createStereoPanner();
            this.pannerNode.pan.setValueAtTime(0, this.ctx.currentTime);
        }

        // Conectar Cadena de Audio:
        // Ch1 -> EQ Low -> EQ Mid -> EQ High -> Master Gain
        this.ch1Gain.connect(this.eqLow);
        this.eqLow.connect(this.eqMid);
        this.eqMid.connect(this.eqHigh);
        this.eqHigh.connect(this.limiter);

        // Ch2 -> Master Gain & Delay
        this.ch2Gain.connect(this.limiter);
        this.ch2Gain.connect(this.delayNode);
        this.delayNode.connect(this.limiter);

        // Ch3 -> Panner -> Master Gain
        if (this.pannerNode) {
            this.ch3Gain.connect(this.pannerNode);
            this.pannerNode.connect(this.limiter);
        } else {
            this.ch3Gain.connect(this.limiter);
        }

        // Master Limiter -> Master Gain -> Analyser -> Speakers
        this.limiter.connect(this.masterGain);
        this.masterGain.connect(this.analyser);
        this.analyser.connect(this.ctx.destination);
    }

    setBeat(beatId, bpm) {
        this.currentBeatId = beatId;
        if (bpm) this.bpm = bpm;
        this.currentStep = 0;
    }

    loadCustomAudioUrl(url) {
        this.init();
        if (this.customAudio) {
            this.customAudio.pause();
            this.customAudio = null;
        }

        this.customAudio = new Audio();
        this.customAudio.crossOrigin = "anonymous";
        this.customAudio.src = url;
        this.customAudio.loop = this.isLooping;

        try {
            this.customAudioSource = this.ctx.createMediaElementSource(this.customAudio);
            this.customAudioSource.connect(this.ch1Gain);
        } catch (e) {
            console.log("Audio source already connected or cors fallback", e);
        }
    }

    play() {
        this.init();
        if (this.ctx.state === "suspended") {
            this.ctx.resume();
        }

        this.isPlaying = true;

        if (this.customAudio && this.customAudio.src) {
            this.customAudio.play().catch(e => console.log("Playback err:", e));
        } else {
            this.startProceduralSequencer();
        }

        // Intervalo de tiempo
        clearInterval(this.timerInterval);
        this.timerInterval = setInterval(() => {
            if (!this.isPlaying) return;
            this.currentTime++;
            if (this.currentTime >= this.duration) {
                if (this.isLooping) {
                    this.currentTime = 0;
                } else {
                    this.stop();
                }
            }
            if (this.onTimeUpdate) this.onTimeUpdate(this.currentTime, this.duration);
        }, 1000);
    }

    pause() {
        this.isPlaying = false;
        clearInterval(this.sequencerTimer);
        clearInterval(this.timerInterval);
        if (this.customAudio) {
            this.customAudio.pause();
        }
    }

    stop() {
        this.pause();
        this.currentTime = 0;
        this.currentStep = 0;
        if (this.customAudio) {
            this.customAudio.currentTime = 0;
        }
        if (this.onTimeUpdate) this.onTimeUpdate(0, this.duration);
    }

    // Generador Sintetizado de Baterías y Melodías Procedurales
    startProceduralSequencer() {
        clearInterval(this.sequencerTimer);
        const stepTimeMs = (60 / this.bpm / 4) * 1000; // 16th notes

        this.sequencerTimer = setInterval(() => {
            if (!this.isPlaying) return;
            this.triggerBeatStep(this.currentBeatId, this.currentStep);
            this.currentStep = (this.currentStep + 1) % 16;
        }, stepTimeMs);
    }

    triggerBeatStep(beatId, step) {
        if (!this.ctx) return;
        const t = this.ctx.currentTime;

        // Patrón por género:
        if (beatId.includes("reggaeton")) {
            // Reggaeton Dembow: Kick en 0, 4, 8, 12. Snare en 3, 6, 11, 14
            if (step % 4 === 0) this.playKick(t, 65, 0.28);
            if (step === 3 || step === 6 || step === 11 || step === 14) this.playSnare(t, 240, 0.15, true);
            if (step % 2 === 0) this.playHiHat(t, 0.04);
            if (step === 0 || step === 8) this.playSubBass(t, 42, 0.5);
            if (step === 0 || step === 4 || step === 8 || step === 12) this.playPluckSynth(t, 370, 0.15);
        } else if (beatId.includes("trap") || beatId.includes("808")) {
            // Trap: Kick 0, 10. Snare 8. Hi-hats con roll
            if (step === 0 || step === 10) this.playKick(t, 55, 0.4);
            if (step === 8) this.playSnare(t, 180, 0.2, false);
            this.playHiHat(t, step % 3 === 0 ? 0.02 : 0.04); // Fast hats
            if (step === 0) this.playSubBass(t, 35, 0.7);
            if (step === 0 || step === 6 || step === 12) this.playPianoChord(t, [220, 261, 329]);
        } else if (beatId.includes("drill")) {
            // Drill: Kick 0, 7. Snare en 8. Slide 808
            if (step === 0 || step === 7) this.playKick(t, 50, 0.35);
            if (step === 8) this.playSnare(t, 210, 0.25, false);
            if (step % 2 !== 0) this.playHiHat(t, 0.03);
            if (step === 0 || step === 6) this.playSubBass(t, 38, 0.6);
            if (step === 0 || step === 8) this.playViolinNote(t, 440);
        } else if (beatId.includes("flamenco")) {
            // Flamenco: Palmas y compás
            if (step === 0 || step === 6 || step === 8 || step === 10) this.playClap(t, 0.08);
            if (step % 4 === 0) this.playKick(t, 70, 0.2);
            if (step % 2 === 0) this.playGuitarPluck(t, 293);
        } else {
            // Standard Hip Hop Boom Bap
            if (step === 0 || step === 10) this.playKick(t, 60, 0.3);
            if (step === 4 || step === 12) this.playSnare(t, 200, 0.2, false);
            if (step % 2 === 0) this.playHiHat(t, 0.05);
            if (step === 0 || step === 8) this.playSubBass(t, 45, 0.4);
        }
    }

    // Sintetizadores de Instrumentos WebAudio
    playKick(time, freq, decay) {
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.frequency.setValueAtTime(freq, time);
        osc.frequency.exponentialRampToValueAtTime(0.01, time + decay);
        gain.gain.setValueAtTime(1.0, time);
        gain.gain.exponentialRampToValueAtTime(0.01, time + decay);
        osc.connect(gain);
        gain.connect(this.ch1Gain);
        osc.start(time);
        osc.stop(time + decay);
    }

    playSnare(time, freq, decay, isRimshot) {
        const osc = this.ctx.createOscillator();
        const oscGain = this.ctx.createGain();
        osc.type = isRimshot ? "triangle" : "sine";
        osc.frequency.setValueAtTime(freq, time);
        oscGain.gain.setValueAtTime(0.7, time);
        oscGain.gain.exponentialRampToValueAtTime(0.01, time + decay);
        osc.connect(oscGain);
        oscGain.connect(this.ch1Gain);
        osc.start(time);
        osc.stop(time + decay);

        // White noise layer
        const node = this.ctx.createBufferSource();
        const buffer = this.ctx.createBuffer(1, this.ctx.sampleRate * decay, this.ctx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < buffer.length; i++) data[i] = Math.random() * 2 - 1;
        node.buffer = buffer;
        const noiseGain = this.ctx.createGain();
        noiseGain.gain.setValueAtTime(0.5, time);
        noiseGain.gain.exponentialRampToValueAtTime(0.01, time + decay);
        node.connect(noiseGain);
        noiseGain.connect(this.ch1Gain);
        node.start(time);
    }

    playHiHat(time, decay) {
        const node = this.ctx.createBufferSource();
        const buffer = this.ctx.createBuffer(1, this.ctx.sampleRate * decay, this.ctx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < buffer.length; i++) data[i] = Math.random() * 2 - 1;
        node.buffer = buffer;

        const filter = this.ctx.createBiquadFilter();
        filter.type = "highpass";
        filter.frequency.setValueAtTime(7000, time);

        const gain = this.ctx.createGain();
        gain.gain.setValueAtTime(0.35, time);
        gain.gain.exponentialRampToValueAtTime(0.01, time + decay);

        node.connect(filter);
        filter.connect(gain);
        gain.connect(this.ch1Gain);
        node.start(time);
    }

    playSubBass(time, freq, decay) {
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.type = "sine";
        osc.frequency.setValueAtTime(freq, time);
        gain.gain.setValueAtTime(0.8, time);
        gain.gain.exponentialRampToValueAtTime(0.01, time + decay);
        osc.connect(gain);
        gain.connect(this.ch1Gain);
        osc.start(time);
        osc.stop(time + decay);
    }

    playPluckSynth(time, freq, decay) {
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.type = "sawtooth";
        osc.frequency.setValueAtTime(freq, time);
        gain.gain.setValueAtTime(0.2, time);
        gain.gain.exponentialRampToValueAtTime(0.01, time + decay);
        osc.connect(gain);
        gain.connect(this.ch1Gain);
        osc.start(time);
        osc.stop(time + decay);
    }

    playPianoChord(time, freqs) {
        freqs.forEach(f => {
            const osc = this.ctx.createOscillator();
            const gain = this.ctx.createGain();
            osc.type = "triangle";
            osc.frequency.setValueAtTime(f, time);
            gain.gain.setValueAtTime(0.12, time);
            gain.gain.exponentialRampToValueAtTime(0.01, time + 0.6);
            osc.connect(gain);
            gain.connect(this.ch1Gain);
            osc.start(time);
            osc.stop(time + 0.6);
        });
    }

    playViolinNote(time, freq) {
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.type = "sawtooth";
        osc.frequency.setValueAtTime(freq, time);
        gain.gain.setValueAtTime(0.15, time);
        gain.gain.exponentialRampToValueAtTime(0.01, time + 0.8);
        osc.connect(gain);
        gain.connect(this.ch1Gain);
        osc.start(time);
        osc.stop(time + 0.8);
    }

    playClap(time, decay) {
        this.playSnare(time, 350, decay, true);
    }

    playGuitarPluck(time, freq) {
        this.playPluckSynth(time, freq, 0.4);
    }

    // Parámetros de Mezcla & Faders
    setMasterVolume(val) {
        if (!this.masterGain) return;
        this.masterGain.gain.setValueAtTime(val / 100, this.ctx.currentTime);
    }

    setChannelVolume(channel, val) {
        const gain = val / 100;
        if (channel === 1 && this.ch1Gain) this.ch1Gain.gain.setValueAtTime(gain, this.ctx.currentTime);
        if (channel === 2 && this.ch2Gain) this.ch2Gain.gain.setValueAtTime(gain, this.ctx.currentTime);
        if (channel === 3 && this.ch3Gain) this.ch3Gain.gain.setValueAtTime(gain, this.ctx.currentTime);
    }

    setEq(band, val) {
        if (!this.eqLow) return;
        if (band === 'low') this.eqLow.gain.setValueAtTime(val, this.ctx.currentTime);
        if (band === 'mid') this.eqMid.gain.setValueAtTime(val, this.ctx.currentTime);
        if (band === 'high') this.eqHigh.gain.setValueAtTime(val, this.ctx.currentTime);
    }
}

window.AudioEngine = new StudioAudioEngine();
