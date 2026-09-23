QBCore.Shared.ForceJobDefaultDutyAtLogin = true -- true: Force duty state to jobdefaultDuty | false: set duty state from database last saved
QBCore.Shared.Jobs = {
	unemployed = { label = 'Civil / Desempleado', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Freelancer', payment = 15 } } },
	bus = {
		label = 'Conductor de Autobús',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Conductor en Prácticas', payment = 50 },
			['1'] = { name = 'Conductor Urbano', payment = 75 },
			['2'] = { name = 'Conductor Interurbano', payment = 100 },
			['3'] = { name = 'Jefe de Rutas', isboss = true, payment = 135 },
		}
	},
	judge = { label = 'Juez Magistrado', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Juez', payment = 150 } } },
	lawyer = { label = 'Bufete Jurídico', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Asociado', payment = 75 }, ['1'] = { name = 'Abogado Titular', payment = 110 } } },
	reporter = {
		label = 'Weazel News Reporter',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Periodista en Prácticas', payment = 50 },
			['1'] = { name = 'Reportero de Campo', payment = 75 },
			['2'] = { name = 'Presentador de Informativos', payment = 100 },
			['3'] = { name = 'Director de Emisión', isboss = true, payment = 140 },
		}
	},
	trucker = {
		label = 'Camionero de Transporte Pesado',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Chofer Novato', payment = 55 },
			['1'] = { name = 'Transportista de Corta Distancia', payment = 80 },
			['2'] = { name = 'Transportista de Larga Distancia', payment = 110 },
			['3'] = { name = 'Jefe de Flota', isboss = true, payment = 140 },
		}
	},
	tow = {
		label = 'Servicio de Grúa y Rescate',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Operador Auxiliar', payment = 50 },
			['1'] = { name = 'Gruista Oficial', payment = 75 },
			['2'] = { name = 'Especialista en Rescate Pesado', payment = 105 },
			['3'] = { name = 'Encargado de Depósito', isboss = true, payment = 135 },
		}
	},
	garbage = {
		label = 'Operario de Limpieza Urbana',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Peón de Limpieza', payment = 55 },
			['1'] = { name = 'Recolector Oficial', payment = 80 },
			['2'] = { name = 'Conductor de Camión Recolector', payment = 110 },
			['3'] = { name = 'Supervisor de Zona', isboss = true, payment = 140 },
		}
	},
	vineyard = {
		label = 'Viñedo de Marlowe',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recolector de Uva', payment = 50 },
			['1'] = { name = 'Bodeguero', payment = 75 },
			['2'] = { name = 'Maestro Vinícola', payment = 105 },
			['3'] = { name = 'Propietario de Finca', isboss = true, payment = 140 },
		}
	},
	hotdog = {
		label = 'Puesto de Perritos Calientes',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Ayudante de Puesto', payment = 50 },
			['1'] = { name = 'Vendedor Ambulante', payment = 75 },
			['2'] = { name = 'Maestro Salchichero', payment = 100 },
			['3'] = { name = 'Dueño de Franquicia', isboss = true, payment = 130 },
		}
	},

	-- TRABAJOS HABITUALES FIVE-M AÑADIDOS
	miner = {
		label = 'Minero de Cantera Davis Quartz',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Peón de Cantera', payment = 55 },
			['1'] = { name = 'Picador / Barrenista', payment = 80 },
			['2'] = { name = 'Operador de Fundición y Lavado', payment = 110 },
			['3'] = { name = 'Capataz de Mina', isboss = true, payment = 145 },
		}
	},
	lumberjack = {
		label = 'Leñador Forestal de Paleto',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Trazador / Novato de Hacha', payment = 55 },
			['1'] = { name = 'Motoserrista Forestal', payment = 80 },
			['2'] = { name = 'Operario de Aserradero', payment = 110 },
			['3'] = { name = 'Encargado Forestal', isboss = true, payment = 145 },
		}
	},
	fisherman = {
		label = 'Pescador Profesional de Alta Mar',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Marinero en Prácticas', payment = 50 },
			['1'] = { name = 'Pescador de Bajura', payment = 75 },
			['2'] = { name = 'Patrón de Arrastre', payment = 105 },
			['3'] = { name = 'Armador Pesquero', isboss = true, payment = 140 },
		}
	},
	farmer = {
		label = 'Agricultor de Campo Grapeseed',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Temporero', payment = 50 },
			['1'] = { name = 'Tractorista / Cosechador', payment = 75 },
			['2'] = { name = 'Agrónomo de Cooperativa', payment = 105 },
			['3'] = { name = 'Patrón de Finca', isboss = true, payment = 140 },
		}
	},
	delivery = {
		label = 'Repartidor de Paquetería Express',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Repartidor de Zona', payment = 55 },
			['1'] = { name = 'Mensajero Urgente', payment = 80 },
			['2'] = { name = 'Coordinador de Envíos', payment = 105 },
			['3'] = { name = 'Jefe de Logística', isboss = true, payment = 140 },
		}
	},
	electrician = {
		label = 'Técnico Electricista Municipal',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Ayudante de Mantenimiento', payment = 55 },
			['1'] = { name = 'Técnico de Red Eléctrica', payment = 80 },
			['2'] = { name = 'Especialista de Alta Tensión', payment = 115 },
			['3'] = { name = 'Ingeniero Jefe de Red', isboss = true, payment = 150 },
		}
	},
	gardener = {
		label = 'Jardinero y Paisajista Municipal',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Peón de Parques y Jardines', payment = 50 },
			['1'] = { name = 'Poda y Mantenimiento', payment = 75 },
			['2'] = { name = 'Diseñador Paisajista', payment = 105 },
			['3'] = { name = 'Supervisor de Espacios Verdes', isboss = true, payment = 135 },
		}
	},
	pizza = {
		label = 'Repartidor de Pizza This',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Repartidor en Scooter', payment = 50 },
			['1'] = { name = 'Pizzero Repartidor Exprés', payment = 75 },
			['2'] = { name = 'Maestro Pizzaiolo', payment = 100 },
			['3'] = { name = 'Gerente de Pizzería', isboss = true, payment = 135 },
		}
	},
	windowcleaner = {
		label = 'Limpiador de Cristales en Rascacielos',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Auxiliar de Limpieza Vertical', payment = 60 },
			['1'] = { name = 'Operario de Andamio Colgante', payment = 85 },
			['2'] = { name = 'Especialista en Altura Maze Bank', payment = 115 },
			['3'] = { name = 'Jefe de Seguridad en Altura', isboss = true, payment = 145 },
		}
	},
	diver = {
		label = 'Buzo Profesional y Rescate Acuático',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Buzo Open Water', payment = 55 },
			['1'] = { name = 'Buzo de Recuperación Marina', payment = 85 },
			['2'] = { name = 'Arqueólogo Submarino', payment = 115 },
			['3'] = { name = 'Director de Expedición Submarina', isboss = true, payment = 150 },
		}
	},
	security = {
		label = 'Vigilante de Seguridad Privada',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Vigilante de Centro Comercial', payment = 55 },
			['1'] = { name = 'Agente de Seguridad Armada', payment = 80 },
			['2'] = { name = 'Escolta Privado de VIPs', payment = 115 },
			['3'] = { name = 'Director de Operaciones de Seguridad', isboss = true, payment = 150 },
		}
	},
	waiter = {
		label = 'Camarero y Personal de Sala',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Camarero de Barra', payment = 50 },
			['1'] = { name = 'Camarero de Sala y Terraza', payment = 75 },
			['2'] = { name = 'Bartender / Coctelero Profesional', payment = 100 },
			['3'] = { name = 'Maitre / Encargado de Sala', isboss = true, payment = 135 },
		}
	},

	-- TRABAJOS NUEVOS E INVENTADOS (EXCLUSIVOS SPAIN ROL)
	cards_courier = {
		label = 'Repartidor Especialista TCG (Murcia Card Show)',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Repartidor de Sobres y Boosters', payment = 60 },
			['1'] = { name = 'Custodio de Cajas Selladas', payment = 85 },
			['2'] = { name = 'Especialista en Cartas Graduadas PSA 10', payment = 120 },
			['3'] = { name = 'Comisario Oficial de Murcia Card Show', isboss = true, payment = 160 },
		}
	},
	vintage_picker = {
		label = 'Chatarrero Vintage y Buscador de Reliquias',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Buscador de Desguace', payment = 55 },
			['1'] = { name = 'Chatarrero de Piezas Clásicas', payment = 85 },
			['2'] = { name = 'Restaurador de Reliquias de Los Santos', payment = 115 },
			['3'] = { name = 'Maestro Tasador de Antigüedades', isboss = true, payment = 155 },
		}
	},
	content_creator = {
		label = 'Creador de Contenido Urbano / Streamer',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Novato con Móvil en Trípode', payment = 50 },
			['1'] = { name = 'Vlogger Callejero de Tendencias', payment = 80 },
			['2'] = { name = 'Streamer Verificado en Directo', payment = 115 },
			['3'] = { name = 'Influencer Estrella de Vinewood', isboss = true, payment = 160 },
		}
	},
	wildlife_ranger = {
		label = 'Guardabosques y Fauna de Monte Chiliad',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Vigilante de Senderos y Rutas', payment = 55 },
			['1'] = { name = 'Ranger de Rescate de Fauna Silvestre', payment = 85 },
			['2'] = { name = 'Guía de Expedición y Supervivencia', payment = 115 },
			['3'] = { name = 'Ranger Mayor del Parque Natural', isboss = true, payment = 155 },
		}
	},
	wine_sommelier = {
		label = 'Enólogo y Maestro Bodeguero Marlowe',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Ayudante de Prensa y Barricas', payment = 55 },
			['1'] = { name = 'Catador de Añadas y Varietales', payment = 85 },
			['2'] = { name = 'Sommelier de Gran Reserva', payment = 120 },
			['3'] = { name = 'Director de Cava y Bodegas', isboss = true, payment = 160 },
		}
	},
	food_critic = {
		label = 'Inspector y Crítico Gastronómico',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Crítico de Comida Rápida', payment = 55 },
			['1'] = { name = 'Inspector de Higiene y Sabor', payment = 85 },
			['2'] = { name = 'Juez Gourmet de Los Santos', payment = 120 },
			['3'] = { name = 'Comisionado de Estrellas Michelin', isboss = true, payment = 160 },
		}
	},

	police = {
		label = 'Law Enforcement',
		type = 'leo',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Officer', payment = 75 },
			['2'] = { name = 'Sergeant', payment = 100 },
			['3'] = { name = 'Lieutenant', payment = 125 },
			['4'] = { name = 'Chief', isboss = true, payment = 150 },
		},
	},
	ambulance = {
		label = 'EMS',
		type = 'ems',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Paramedic', payment = 75 },
			['2'] = { name = 'Doctor', payment = 100 },
			['3'] = { name = 'Surgeon', payment = 125 },
			['4'] = { name = 'Chief', isboss = true, payment = 150 },
		},
	},
	realestate = {
		label = 'Real Estate',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'House Sales', payment = 75 },
			['2'] = { name = 'Business Sales', payment = 100 },
			['3'] = { name = 'Broker', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	taxi = {
		label = 'Taxi',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Driver', payment = 75 },
			['2'] = { name = 'Event Driver', payment = 100 },
			['3'] = { name = 'Sales', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	cardealer = {
		label = 'Vehicle Dealer',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Showroom Sales', payment = 75 },
			['2'] = { name = 'Business Sales', payment = 100 },
			['3'] = { name = 'Finance', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	mechanic = {
		label = 'LS Customs',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Novice', payment = 75 },
			['2'] = { name = 'Experienced', payment = 100 },
			['3'] = { name = 'Advanced', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	mechanic2 = {
		label = 'LS Customs',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Novice', payment = 75 },
			['2'] = { name = 'Experienced', payment = 100 },
			['3'] = { name = 'Advanced', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	mechanic3 = {
		label = 'LS Customs',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Novice', payment = 75 },
			['2'] = { name = 'Experienced', payment = 100 },
			['3'] = { name = 'Advanced', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	beeker = {
		label = 'Beeker\'s Garage',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Novice', payment = 75 },
			['2'] = { name = 'Experienced', payment = 100 },
			['3'] = { name = 'Advanced', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	bennys = {
		label = 'Benny\'s Original Motor Works',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Novice', payment = 75 },
			['2'] = { name = 'Experienced', payment = 100 },
			['3'] = { name = 'Advanced', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
}
