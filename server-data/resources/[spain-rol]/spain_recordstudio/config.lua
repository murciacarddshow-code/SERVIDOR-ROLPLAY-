Config = {}

-- Nombre del Estudio y Configuración General
Config.StudioName = "Vinewood A-Records"
Config.Currency = "€"
Config.VinylPressCost = 500 -- Coste en banco o efectivo por prensar un disco de vinilo físico
Config.StudioSoundRadius = 35.0 -- Distancia máxima a la que se escucha el sonido ambiental de la mesa de mezclas

-- Blip en el mapa general
Config.Blip = {
    enable = true,
    coords = vector3(-478.67, 36.0, 45.71),
    sprite = 614, -- Icono de disco musical / nota
    color = 47,   -- Naranja / Cyan
    scale = 0.85,
    label = "Estudio de Grabación Vinewood (A-Records)"
}

-- Puntos de interacción dentro del MLO de Vinewood
Config.Zones = {
    booth = {
        name = "Cabina Vocal",
        coords = vector3(-476.06, 54.91, 47.70),
        radius = 1.6,
        prompt = "[E] Entrar a Cabina Vocal (Cantar / Grabar)",
        tab = "booth"
    },
    mixer = {
        name = "Mesa de Mezclas & DAW",
        coords = vector3(-476.89, 54.47, 47.59),
        radius = 1.8,
        prompt = "[E] Mesa de Mezclas & Producción Musical",
        tab = "mixer"
    },
    writer = {
        name = "Composición de Letras",
        coords = vector3(-476.29, 53.71, 47.70),
        radius = 1.5,
        prompt = "[E] Cuaderno de Compositor & Letras",
        tab = "writer"
    },
    press = {
        name = "Prensa de Vinilos & Distribución",
        coords = vector3(-473.11, 52.46, 47.29),
        radius = 1.8,
        prompt = "[E] Prensa de Vinilos & Billboard Los Santos",
        tab = "press"
    }
}

-- Catálogo de Instrumentales / Beats Integrados (Generados por WebAudio y Stems sin copyright)
Config.DefaultBeats = {
    {
        id = "reggaeton_flow",
        title = "Dembow Puro 2026",
        producer = "Bizarrap Style",
        genre = "Reggaeton",
        bpm = 94,
        key = "F# Minor",
        desc = "Dembow latino clásico con percusión marcada, sintetizador tropical y bajo 808 profundo.",
        color = "#e11d48"
    },
    {
        id = "trap_808",
        title = "808 Mafia Madrid",
        producer = "Metro Boomin Style",
        genre = "Trap",
        bpm = 132,
        key = "C Minor",
        desc = "Trap oscuro de calle con hi-hats triples acelerados, melodía de piano siniestra y bajos saturados.",
        color = "#8b5cf6"
    },
    {
        id = "drill_spain",
        title = "Drill Lavapiés / Barna",
        producer = "Czar Beats",
        genre = "Drill",
        bpm = 142,
        key = "E Minor",
        desc = "Violines oscuros melancólicos, caja desplazada característica del drill UK/Español y slide 808 agresivo.",
        color = "#06b6d4"
    },
    {
        id = "hiphop_90s",
        title = "Golden Era Boom Bap",
        producer = "DJ Premier Style",
        genre = "Hip Hop",
        bpm = 90,
        key = "D Minor",
        desc = "Sonido clásico de vinilo con muestras de trompeta jazz, caja gorda analógica y bajo cálido de contrabajo.",
        color = "#f59e0b"
    },
    {
        id = "flamenco_flow",
        title = "Gitano Urbano",
        producer = "Rosalía / C. Tangana Vibe",
        genre = "Flamenco Urbano",
        bpm = 100,
        key = "A Phrygian",
        desc = "Palmas flamencas, cajón rítmico, guitarra española con arpegios y subgrave electrónico vanguardista.",
        color = "#ef4444"
    },
    {
        id = "rnb_chill",
        title = "Midnight Soul & Guitars",
        producer = "Drake / The Weeknd Vibe",
        genre = "R&B / Soul",
        bpm = 76,
        key = "G# Minor",
        desc = "Guitarras limpias con chorus, acordes de piano eléctrico Rhodes y atmósfera espacial envolvente.",
        color = "#ec4899"
    },
    {
        id = "pop_synthwave",
        title = "Blinding Sunset",
        producer = "Max Martin Style",
        genre = "Pop Melódico",
        bpm = 118,
        key = "A Minor",
        desc = "Sintetizadores retro años 80, arpegiador eufórico y línea de bajo rítmica muy pegadiza.",
        color = "#3b82f6"
    },
    {
        id = "corridos_tumbados",
        title = "Bélico & Doble P",
        producer = "Peso Pluma Vibe",
        genre = "Corridos Tumbados",
        bpm = 128,
        key = "D Major",
        desc = "Trombón de vara, requinto de guitarra electroacústica rápido y bajo de tololoche tradicional.",
        color = "#10b981"
    }
}

-- Carátulas de álbum oficiales predeterminadas para los discos
Config.DefaultCovers = {
    "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80",
    "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500&q=80",
    "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&q=80",
    "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=500&q=80",
    "https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?w=500&q=80",
    "https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=500&q=80"
}
