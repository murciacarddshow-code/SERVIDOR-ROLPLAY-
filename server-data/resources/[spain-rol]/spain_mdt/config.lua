Config = Config or {}

Config.AuthorizedJobs = {
    ['police'] = { label = 'Cuerpo Nacional de Policía / Guardia Civil', badge = 'CNP-GC' },
    ['ambulance'] = { label = 'Servicio de Asistencia Médica de Urgencia (SAMUR)', badge = 'SAMUR' }
}

-- Catálogo oficial del Código Penal (Tipificado en Euros y meses de prisión)
Config.PenalCode = {
    -- Infracciones de Tráfico
    { id = 'TRAF-01', title = 'Exceso de velocidad leve (< 30 km/h)', fine = 150, jail = 0, category = 'Tráfico' },
    { id = 'TRAF-02', title = 'Exceso de velocidad grave (> 50 km/h)', fine = 450, jail = 0, category = 'Tráfico' },
    { id = 'TRAF-03', title = 'Conducción temeraria / Peligro para terceros', fine = 750, jail = 5, category = 'Tráfico' },
    { id = 'TRAF-04', title = 'Conducción bajo los efectos de drogas o alcohol', fine = 1000, jail = 10, category = 'Tráfico' },
    { id = 'TRAF-05', title = 'Fuga de control policial en vehículo', fine = 2000, jail = 15, category = 'Tráfico' },

    -- Delitos contra el Orden Público
    { id = 'ORD-01', title = 'Desacato / Falta de respeto a la autoridad', fine = 500, jail = 0, category = 'Orden Público' },
    { id = 'ORD-02', title = 'Desobediencia grave a órdenes de los agentes', fine = 1200, jail = 10, category = 'Orden Público' },
    { id = 'ORD-03', title = 'Alteración grave del orden en vía pública', fine = 800, jail = 5, category = 'Orden Público' },
    { id = 'ORD-04', title = 'Agresión a funcionario público en ejercicio', fine = 3500, jail = 25, category = 'Orden Público' },

    -- Tenencia Ilícita de Armas
    { id = 'ARM-01', title = 'Porte visible de armas en zona urbana sin licencia', fine = 1500, jail = 10, category = 'Armas' },
    { id = 'ARM-02', title = 'Tenencia ilícita de arma de fuego corta', fine = 3000, jail = 20, category = 'Armas' },
    { id = 'ARM-03', title = 'Tenencia ilícita de arma de guerra o fusil automático', fine = 7000, jail = 40, category = 'Armas' },
    { id = 'ARM-04', title = 'Disparos en vía pública', fine = 2500, jail = 15, category = 'Armas' },

    -- Delitos contra la Salud Pública (Narcotráfico)
    { id = 'DROG-01', title = 'Posesión de sustancias para consumo (< 5 bolsitas)', fine = 800, jail = 0, category = 'Drogas' },
    { id = 'DROG-02', title = 'Tráfico y menudeo de drogas en vía pública', fine = 2500, jail = 20, category = 'Drogas' },
    { id = 'DROG-03', title = 'Distribución a gran escala o laboratorio clandestino', fine = 10000, jail = 45, category = 'Drogas' },

    -- Delitos contra el Patrimonio y la Vida
    { id = 'ROB-01', title = 'Robo con fuerza en establecimiento comercial (Badulake)', fine = 3000, jail = 25, category = 'Robos' },
    { id = 'ROB-02', title = 'Atraco a mano armada en Joyería o Banco Fleeca', fine = 7500, jail = 50, category = 'Robos' },
    { id = 'ROB-03', title = 'Asalto a gran escala (Banco Central / Yate)', fine = 15000, jail = 75, category = 'Robos' },
    { id = 'HOM-01', title = 'Tentativa de homicidio', fine = 8000, jail = 60, category = 'Delitos Graves' },
    { id = 'HOM-02', title = 'Homicidio en primer grado / Asesinato', fine = 25000, jail = 100, category = 'Delitos Graves' },
}
