/* =========================================================================
   POKÉVAULT TCG (MURCIA CARD SHOW & SPAIN ROL) - APPLICATION LOGIC
   ========================================================================= */

// Catálogo de Productos Disponibles en la Tienda (Stock Ilimitado)
const SHOP_PRODUCTS = [
    {
        id: 'pokemon_booster_151',
        name: 'Sobre Pokémon 151 (Kanto)',
        expansion: 'Kanto 151',
        desc: 'Sobre precintado con 10 cartas de la región de Kanto. Probabilidad de Mew, Alakazam y cartas secretas.',
        price: 45,
        image: 'nui://qb-inventory/html/images/pokemon_booster_151.png'
    },
    {
        id: 'pokemon_booster_charizard',
        name: 'Sobre Destinos Brillantes',
        expansion: 'Shiny Vault',
        desc: 'Alta probabilidad de Pokémon Shiny y la codiciada carta Charizard VMAX Shiny Full Art.',
        price: 55,
        image: 'nui://qb-inventory/html/images/pokemon_booster_charizard.png'
    },
    {
        id: 'pokemon_booster_prismatic',
        name: 'Sobre Evoluciones Prismáticas',
        expansion: 'Prismatic',
        desc: 'Nueva expansión dedicada a Eevee y sus evoluciones. Posibilidad del legendario Umbreon Moonbreon.',
        price: 60,
        image: 'nui://qb-inventory/html/images/pokemon_booster_prismatic.png'
    },
    {
        id: 'pokemon_booster_vintage',
        name: 'Sobre Vintage Base Set 1999',
        expansion: 'Vintage 1999',
        desc: 'Joya histórica precintada de primera edición. Alta probabilidad de cartas graduadas PSA 10 Gem Mint.',
        price: 350,
        image: 'nui://qb-inventory/html/images/pokemon_booster_vintage.png'
    },
    {
        id: 'pokemon_etb_151',
        name: 'Caja Entrenador Élite ETB 151',
        expansion: 'Colección Élite',
        desc: 'Caja de lujo con múltiples sobres, fundas de coleccionista y cartas promocionales exclusivas.',
        price: 380,
        image: 'nui://qb-inventory/html/images/pokemon_etb_151.png'
    },
    {
        id: 'pokemon_mystery_box',
        name: 'Mystery Box Murcia Card Show',
        expansion: 'Murcia Show',
        desc: 'Caja sorpresa de coleccionismo con cartas secretas y posibilidad de cartas ya graduadas en PSA 10.',
        price: 500,
        image: 'nui://qb-inventory/html/images/pokemon_mystery_box.png'
    },
    {
        id: 'pokemon_binder',
        name: 'Álbum Coleccionista Oficial',
        expansion: 'Accesorios',
        desc: 'Carpeta acolchada oficial de 9 bolsillos para proteger tu colección en impecable estado.',
        price: 40,
        image: 'nui://qb-inventory/html/images/pokemon_binder.png'
    },
    {
        id: 'pokemon_protective_sleeve',
        name: 'Fundas Toploader Rígidas',
        expansion: 'Accesorios',
        desc: 'Pack de protectores rígidos ultra transparentes para conservar cartas en estado de conservación 10.',
        price: 15,
        image: 'nui://qb-inventory/html/images/pokemon_protective_sleeve.png'
    }
];

// Precios y configuración de recompra de cartas por el Tasador
const CARD_PRICES = {
    'pokemon_card_common': {
        name: 'Carta Común Kanto',
        tier: 'Común',
        rarityPill: 'common',
        unitPrice: 15,
        image: 'nui://qb-inventory/html/images/pokemon_card_common.png'
    },
    'pokemon_card_holo': {
        name: 'Carta Holográfica Rara Foil',
        tier: 'Holo Foil ✨',
        rarityPill: 'holo',
        unitPrice: 65,
        image: 'nui://qb-inventory/html/images/pokemon_card_holo.png'
    },
    'pokemon_card_mewtwo_gold': {
        name: 'Mewtwo VSTAR Secreta Oro',
        tier: 'Secreta Oro 👑',
        rarityPill: 'gold',
        unitPrice: 900,
        image: 'nui://qb-inventory/html/images/pokemon_card_mewtwo_gold.png'
    },
    'pokemon_card_charizard_vmax': {
        name: 'Charizard VMAX Shiny Full Art',
        tier: 'Ultra Rara 🔥⭐⭐⭐',
        rarityPill: 'secret',
        unitPrice: 1200,
        image: 'nui://qb-inventory/html/images/pokemon_card_charizard_vmax.png'
    },
    'pokemon_card_moonbreon': {
        name: 'Umbreon VMAX Moonbreon',
        tier: 'Ultra Rara 🌙⭐⭐⭐',
        rarityPill: 'secret',
        unitPrice: 1200,
        image: 'nui://qb-inventory/html/images/pokemon_card_moonbreon.png'
    },
    'pokemon_card_psa10': {
        name: 'Slab Graduada PSA 10 GEM MINT',
        tier: 'GEM MINT 10 💎',
        rarityPill: 'gem',
        unitPrice: 2500,
        image: 'nui://qb-inventory/html/images/pokemon_card_psa10.png'
    }
};

// Estado Global
let playerData = {
    cash: 0,
    bank: 0,
    inventory: {}
};
let selectedPaymentMethod = 'cash';
let productQuantities = {};

// Sintetizador de audio Web Audio API (efectos de sonido nativos sin archivos externos)
const audioCtx = new (window.AudioContext || window.webkitAudioContext)();

function playSound(type) {
    if (audioCtx.state === 'suspended') {
        audioCtx.resume();
    }
    const now = audioCtx.currentTime;
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();
    osc.connect(gain);
    gain.connect(audioCtx.destination);

    if (type === 'click') {
        osc.type = 'sine';
        osc.frequency.setValueAtTime(600, now);
        osc.frequency.exponentialRampToValueAtTime(800, now + 0.05);
        gain.gain.setValueAtTime(0.12, now);
        gain.gain.linearRampToValueAtTime(0.01, now + 0.05);
        osc.start(now);
        osc.stop(now + 0.05);
    } else if (type === 'buy') {
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(523.25, now); // C5
        osc.frequency.setValueAtTime(659.25, now + 0.08); // E5
        osc.frequency.setValueAtTime(783.99, now + 0.16); // G5
        gain.gain.setValueAtTime(0.15, now);
        gain.gain.linearRampToValueAtTime(0.01, now + 0.28);
        osc.start(now);
        osc.stop(now + 0.28);
    } else if (type === 'cash') {
        osc.type = 'sine';
        osc.frequency.setValueAtTime(987.77, now); // B5
        osc.frequency.setValueAtTime(1318.51, now + 0.09); // E6
        gain.gain.setValueAtTime(0.2, now);
        gain.gain.linearRampToValueAtTime(0.01, now + 0.35);
        osc.start(now);
        osc.stop(now + 0.35);
    } else if (type === 'fanfare') {
        // Fanfarria ascendente para cartas secretas y PSA 10
        const notes = [261.63, 329.63, 392.00, 523.25, 659.25, 783.99, 1046.50];
        notes.forEach((freq, idx) => {
            const noteOsc = audioCtx.createOscillator();
            const noteGain = audioCtx.createGain();
            noteOsc.connect(noteGain);
            noteGain.connect(audioCtx.destination);
            noteOsc.type = 'triangle';
            const noteTime = now + (idx * 0.07);
            noteOsc.frequency.setValueAtTime(freq, noteTime);
            noteGain.gain.setValueAtTime(0.18, noteTime);
            noteGain.gain.exponentialRampToValueAtTime(0.001, noteTime + 0.4);
            noteOsc.start(noteTime);
            noteOsc.stop(noteTime + 0.4);
        });
    } else if (type === 'engine') {
        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(80, now);
        osc.frequency.linearRampToValueAtTime(260, now + 0.3);
        gain.gain.setValueAtTime(0.12, now);
        gain.gain.linearRampToValueAtTime(0.01, now + 0.35);
        osc.start(now);
        osc.stop(now + 0.35);
    }
}

// Variables de Estado de la Tablet de Empleos y Revelación
let currentJobData = null;
let isJobTabletOpen = false;
let isCardRevealOpen = false;
let isShiftActionPending = false; // Debounce guard

// Inicialización de la Interfaz
document.addEventListener('DOMContentLoaded', () => {
    initTabs();
    initPaymentSelector();
    initCloseButton();
    renderProducts();
    initJobTabletEvents();
    initCardRevealEvents();
});

// Mensajes desde FiveM Client
window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data) return;

    if (data.action === 'open') {
        playerData = {
            cash: data.cash || 0,
            bank: data.bank || 0,
            inventory: data.inventory || {}
        };
        updateBalancesUI();
        renderProducts();
        renderSellTab();
        renderMyCardsTab();

        if (data.defaultTab) {
            switchTab(data.defaultTab);
        }

        document.getElementById('app').style.display = 'flex';
        playSound('click');
    } else if (data.action === 'update') {
        playerData.cash = data.cash !== undefined ? data.cash : playerData.cash;
        playerData.bank = data.bank !== undefined ? data.bank : playerData.bank;
        playerData.inventory = data.inventory || playerData.inventory;
        updateBalancesUI();
        renderSellTab();
        renderMyCardsTab();
    } else if (data.action === 'revealCard') {
        openCardReveal(data.card);
    } else if (data.action === 'openJobTablet') {
        openJobTablet(data);
    } else if (data.action === 'closeJobTablet') {
        closeJobTablet();
    } else if (data.action === 'close') {
        closeUI();
    }
});

// Cerrar con Tecla ESC (Manejador jerárquico inteligente)
window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' || e.keyCode === 27) {
        if (isCardRevealOpen) {
            closeCardReveal();
        } else if (isJobTabletOpen) {
            closeJobTablet();
        } else if (document.getElementById('app').style.display !== 'none') {
            closeUI();
        }
    }
});

function initCloseButton() {
    document.getElementById('btn-close').addEventListener('click', () => {
        closeUI();
    });
}

function closeUI() {
    document.getElementById('app').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

// Navegación de Pestañas
function initTabs() {
    const tabs = document.querySelectorAll('.nav-tab');
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            const target = tab.getAttribute('data-tab');
            switchTab(target);
            playSound('click');
        });
    });
}

function switchTab(tabId) {
    document.querySelectorAll('.nav-tab').forEach(t => {
        t.classList.toggle('active', t.getAttribute('data-tab') === tabId);
    });
    document.querySelectorAll('.tab-pane').forEach(p => {
        p.classList.toggle('active', p.id === tabId);
    });
}

// Selector de Método de Pago
function initPaymentSelector() {
    const cashOpt = document.getElementById('pm-cash');
    const bankOpt = document.getElementById('pm-bank');

    cashOpt.addEventListener('click', () => {
        selectedPaymentMethod = 'cash';
        cashOpt.classList.add('active');
        bankOpt.classList.remove('active');
        cashOpt.querySelector('input').checked = true;
        playSound('click');
    });

    bankOpt.addEventListener('click', () => {
        selectedPaymentMethod = 'bank';
        bankOpt.classList.add('active');
        cashOpt.classList.remove('active');
        bankOpt.querySelector('input').checked = true;
        playSound('click');
    });
}

// Actualizar saldos en cabecera
function updateBalancesUI() {
    document.getElementById('player-cash').textContent = '€' + (playerData.cash || 0).toLocaleString('es-ES');
    document.getElementById('player-bank').textContent = '€' + (playerData.bank || 0).toLocaleString('es-ES');
}

// Renderizar Productos en la Tienda
function renderProducts() {
    const grid = document.getElementById('products-grid');
    grid.innerHTML = '';

    SHOP_PRODUCTS.forEach(prod => {
        if (!productQuantities[prod.id]) {
            productQuantities[prod.id] = 1;
        }

        const card = document.createElement('div');
        card.className = 'product-card';
        card.innerHTML = `
            <div class="product-badge-row">
                <span class="expansion-badge">${prod.expansion}</span>
                <span class="stock-badge-unlimited">
                    <span class="material-symbols-outlined" style="font-size: 14px;">all_inclusive</span>
                    Ilimitado
                </span>
            </div>
            <div class="product-image-container">
                <img class="product-image" src="${prod.image}" onerror="this.src='https://placehold.co/120x150/192231/ffd000?text=${encodeURIComponent(prod.name)}'" alt="${prod.name}">
            </div>
            <div class="product-details">
                <div class="product-name">${prod.name}</div>
                <div class="product-desc">${prod.desc}</div>
                <div class="product-price-row">
                    <span class="price-unit-label">PRECIO UNITARIO</span>
                    <span class="product-price">€${prod.price.toLocaleString('es-ES')}</span>
                </div>
                
                <div class="quantity-controller">
                    <button class="qty-btn" data-action="minus" data-id="${prod.id}">-</button>
                    <input type="text" class="qty-input" id="qty-${prod.id}" value="${productQuantities[prod.id]}" readonly>
                    <button class="qty-btn" data-action="plus" data-id="${prod.id}">+</button>
                </div>

                <div class="quick-qty-group">
                    <button class="btn-quick-qty" data-qty="1" data-id="${prod.id}">x1</button>
                    <button class="btn-quick-qty" data-qty="5" data-id="${prod.id}">x5</button>
                    <button class="btn-quick-qty" data-qty="10" data-id="${prod.id}">x10</button>
                </div>

                <button class="btn-buy-product" id="buy-btn-${prod.id}" data-id="${prod.id}">
                    <span class="material-symbols-outlined" style="font-size: 18px;">shopping_cart</span>
                    <span class="buy-btn-text">Comprar (Total: €${(prod.price * productQuantities[prod.id]).toLocaleString('es-ES')})</span>
                </button>
            </div>
        `;

        // Eventos de Cantidad
        card.querySelector(`[data-action="minus"][data-id="${prod.id}"]`).addEventListener('click', () => {
            if (productQuantities[prod.id] > 1) {
                productQuantities[prod.id]--;
                updateProductQtyUI(prod);
                playSound('click');
            }
        });

        card.querySelector(`[data-action="plus"][data-id="${prod.id}"]`).addEventListener('click', () => {
            if (productQuantities[prod.id] < 99) {
                productQuantities[prod.id]++;
                updateProductQtyUI(prod);
                playSound('click');
            }
        });

        card.querySelectorAll(`.btn-quick-qty[data-id="${prod.id}"]`).forEach(btn => {
            btn.addEventListener('click', () => {
                productQuantities[prod.id] = parseInt(btn.getAttribute('data-qty'));
                updateProductQtyUI(prod);
                playSound('click');
            });
        });

        // Evento de Compra
        card.querySelector(`#buy-btn-${prod.id}`).addEventListener('click', () => {
            executePurchase(prod.id, productQuantities[prod.id]);
        });

        grid.appendChild(card);
    });
}

function updateProductQtyUI(prod) {
    const qtyInput = document.getElementById(`qty-${prod.id}`);
    const buyBtn = document.getElementById(`buy-btn-${prod.id}`);
    if (qtyInput) qtyInput.value = productQuantities[prod.id];
    if (buyBtn) {
        const total = prod.price * productQuantities[prod.id];
        buyBtn.querySelector('.buy-btn-text').textContent = `Comprar (Total: €${total.toLocaleString('es-ES')})`;
    }
}

// Ejecutar Compra al Servidor
function executePurchase(itemId, amount) {
    const product = SHOP_PRODUCTS.find(p => p.id === itemId);
    if (!product) return;

    const totalPrice = product.price * amount;
    const currentFunds = selectedPaymentMethod === 'cash' ? playerData.cash : playerData.bank;

    if (currentFunds < totalPrice) {
        showToast('error', 'Fondos Insuficientes', `Necesitas €${totalPrice.toLocaleString('es-ES')} en ${selectedPaymentMethod === 'cash' ? 'efectivo' : 'tu cuenta bancaria'}.`);
        return;
    }

    fetch(`https://${GetParentResourceName()}/buyItem`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            item: itemId,
            amount: amount,
            payment: selectedPaymentMethod
        })
    }).then(resp => resp.json()).then(result => {
        if (result && result.success) {
            playSound('buy');
            showToast('success', '¡Compra Realizada con Éxito!', `Has adquirido ${amount}x ${product.name} por €${totalPrice.toLocaleString('es-ES')}.`);
        } else {
            showToast('error', 'Error en la Compra', result.message || 'No se pudo completar la transacción.');
        }
    }).catch(err => {
        console.error('Error enviando buyItem:', err);
    });
}

// Renderizar Pestaña del Tasador
function renderSellTab() {
    const grid = document.getElementById('cards-sell-grid');
    const summary = document.getElementById('appraiser-summary');
    const liquidateBtn = document.getElementById('btn-liquidate-all');
    const liquidateTotal = document.getElementById('liquidate-total');
    const badgeSellCount = document.getElementById('badge-sell-count');

    grid.innerHTML = '';

    let totalCardsCount = 0;
    let totalValuation = 0;
    let cardsFound = 0;

    for (const [itemKey, cardConfig] of Object.entries(CARD_PRICES)) {
        const count = playerData.inventory[itemKey] || 0;
        if (count > 0) {
            cardsFound++;
            totalCardsCount += count;
            const itemTotal = count * cardConfig.unitPrice;
            totalValuation += itemTotal;

            const cardEl = document.createElement('div');
            cardEl.className = 'card-sell-item';
            cardEl.innerHTML = `
                <img class="card-sell-img" src="${cardConfig.image}" onerror="this.src='https://placehold.co/65x90/192231/ffd000?text=Card'" alt="${cardConfig.name}">
                <div class="card-sell-details">
                    <div class="card-sell-title">${cardConfig.name}</div>
                    <div class="card-sell-count">Tienes en posesión: <strong>${count} ud(s)</strong></div>
                    <div class="card-sell-rates">
                        <span class="card-sell-unit">€${cardConfig.unitPrice.toLocaleString('es-ES')} / ud</span>
                        <span class="card-sell-total">Total: €${itemTotal.toLocaleString('es-ES')}</span>
                    </div>
                    <div class="card-sell-actions">
                        <button class="btn-sell-single" data-item="${itemKey}">Vender 1 ud</button>
                        <button class="btn-sell-all" data-item="${itemKey}" data-count="${count}">Vender ${count} ud(s)</button>
                    </div>
                </div>
            `;

            cardEl.querySelector('.btn-sell-single').addEventListener('click', () => {
                executeSell(itemKey, 1);
            });

            cardEl.querySelector('.btn-sell-all').addEventListener('click', () => {
                executeSell(itemKey, count);
            });

            grid.appendChild(cardEl);
        }
    }

    badgeSellCount.textContent = totalCardsCount;

    if (cardsFound === 0) {
        grid.innerHTML = `
            <div class="empty-inventory-notice">
                <span class="material-symbols-outlined">style</span>
                <h4>No tienes cartas en tu inventario</h4>
                <p>Abre sobres comprados en la tienda PokéVault y vuelve aquí para tasar y liquidar tus cartas por dinero en efectivo.</p>
            </div>
        `;
        summary.textContent = "El tasador: 'Por el momento no tienes cartas coleccionables para tasar.'";
        liquidateBtn.disabled = true;
        liquidateTotal.textContent = "€0 EN EFECTIVO";
    } else {
        summary.innerHTML = `Tienes <strong>${totalCardsCount} carta(s)</strong> coleccionables en tu inventario valoradas en un total de <strong>€${totalValuation.toLocaleString('es-ES')}</strong>.`;
        liquidateBtn.disabled = false;
        liquidateTotal.textContent = `€${totalValuation.toLocaleString('es-ES')} EN EFECTIVO`;
    }

    liquidateBtn.onclick = () => {
        if (totalCardsCount > 0) {
            executeSell('all', totalCardsCount);
        }
    };
}

// Ejecutar Venta al Servidor
function executeSell(cardType, amount) {
    fetch(`https://${GetParentResourceName()}/sellCards`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            type: cardType,
            amount: amount
        })
    }).then(resp => resp.json()).then(result => {
        if (result && result.success) {
            playSound('cash');
            showToast('success', '¡Tasación y Venta Completada!', `Has vendido ${result.count || amount} carta(s) por €${(result.cash || 0).toLocaleString('es-ES')} en efectivo.`);
        } else {
            showToast('error', 'Error en la Venta', result.message || 'No se pudo liquidar la carta.');
        }
    }).catch(err => {
        console.error('Error enviando sellCards:', err);
    });
}

// Renderizar Pestaña "Mis Cartas & Sobres"
function renderMyCardsTab() {
    const packsGrid = document.getElementById('packs-open-grid');
    const cardsGrid = document.getElementById('cards-display-grid');
    const unopenedCount = document.getElementById('my-unopened-count');
    const cardsCount = document.getElementById('my-cards-count');
    const badgePacks = document.getElementById('badge-my-packs');

    packsGrid.innerHTML = '';
    cardsGrid.innerHTML = '';

    let totalPacks = 0;
    let totalCards = 0;

    // Sobres en posesión
    SHOP_PRODUCTS.forEach(p => {
        const count = playerData.inventory[p.id] || 0;
        if (count > 0) {
            totalPacks += count;
            const packCard = document.createElement('div');
            packCard.className = 'pack-open-card';
            packCard.innerHTML = `
                <img class="pack-open-img" src="${p.image}" onerror="this.src='https://placehold.co/90x120/192231/ffd000?text=${encodeURIComponent(p.name)}'" alt="${p.name}">
                <div class="pack-open-name">${p.name}</div>
                <div class="pack-open-count">${count} sobre(s)</div>
                <button class="btn-open-pack" data-id="${p.id}" data-label="${p.name}">
                    <span class="material-symbols-outlined" style="font-size: 16px;">bolt</span>
                    Abrir Sobre Ahora
                </button>
            `;

            packCard.querySelector('.btn-open-pack').addEventListener('click', () => {
                openPack(p.id, p.name);
            });

            packsGrid.appendChild(packCard);
        }
    });

    badgePacks.textContent = totalPacks;
    unopenedCount.textContent = `${totalPacks} sobre(s)`;

    if (totalPacks === 0) {
        packsGrid.innerHTML = `
            <div class="empty-inventory-notice" style="grid-column: 1 / -1; padding: 30px;">
                <span class="material-symbols-outlined" style="font-size: 32px;">inventory_2</span>
                <h4>No tienes sobres precintados</h4>
                <p>Ve a la pestaña de Tienda y adquiere sobres con stock ilimitado.</p>
            </div>
        `;
    }

    // Cartas en posesión
    for (const [k, c] of Object.entries(CARD_PRICES)) {
        const count = playerData.inventory[k] || 0;
        if (count > 0) {
            totalCards += count;
            const cardEl = document.createElement('div');
            cardEl.className = 'card-display-item';
            cardEl.innerHTML = `
                <span class="card-display-qty">x${count}</span>
                <img class="card-display-img" src="${c.image}" onerror="this.src='https://placehold.co/80x110/192231/ffd000?text=Card'" alt="${c.name}">
                <div class="card-display-name">${c.name}</div>
                <span class="rarity-pill ${c.rarityPill}">${c.tier}</span>
            `;
            cardsGrid.appendChild(cardEl);
        }
    }

    cardsCount.textContent = `${totalCards} carta(s)`;
    if (totalCards === 0) {
        cardsGrid.innerHTML = `
            <div class="empty-inventory-notice" style="grid-column: 1 / -1; padding: 30px;">
                <span class="material-symbols-outlined" style="font-size: 32px;">style</span>
                <h4>Aún no has coleccionado cartas</h4>
                <p>¡Abre sobres para encontrar tus cartas holográficas, VMAX y slabs PSA 10!</p>
            </div>
        `;
    }
}

// Abrir Sobre directamente desde la NUI
function openPack(packId, packLabel) {
    document.getElementById('app').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/openPackFromNui`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            item: packId,
            label: packLabel
        })
    });
}

// Toast Notificaciones
let toastTimeout = null;
function showToast(type, title, msg) {
    const toast = document.getElementById('pv-toast');
    const toastIcon = document.getElementById('toast-icon');
    const toastTitle = document.getElementById('toast-title');
    const toastMsg = document.getElementById('toast-msg');

    if (toastTimeout) clearTimeout(toastTimeout);

    toastTitle.textContent = title;
    toastMsg.textContent = msg;

    if (type === 'success') {
        toastIcon.textContent = 'check_circle';
        toastIcon.style.color = '#00e676';
        toast.style.borderLeftColor = '#00e676';
    } else {
        toastIcon.textContent = 'error';
        toastIcon.style.color = '#ff334b';
        toast.style.borderLeftColor = '#ff334b';
    }

    toast.classList.add('show');
    toastTimeout = setTimeout(() => {
        toast.classList.remove('show');
    }, 4500);
}

/* =========================================================================
   POKÉVAULT - SISTEMA DE REVELACIÓN DE CARTA (3D PULL REVEAL)
   ========================================================================= */
function initCardRevealEvents() {
    const btnStash = document.getElementById('btn-stash-card');
    if (btnStash) {
        btnStash.addEventListener('click', () => {
            closeCardReveal();
        });
    }
}

function openCardReveal(card) {
    if (!card) return;
    isCardRevealOpen = true;

    const modal = document.getElementById('card-reveal-modal');
    const tagline = document.getElementById('reveal-pack-origin');
    const title = document.getElementById('reveal-title');
    const rarity = document.getElementById('reveal-rarity');
    const img = document.getElementById('reveal-card-img');
    const cardName = document.getElementById('reveal-card-name');
    const marketVal = document.getElementById('reveal-market-val');

    tagline.textContent = card.packOrigin || 'SOBRE PRECINTADO';
    title.textContent = card.isHit ? '🔥 ¡¡HITAZO DE COLECCIÓN!! 🔥' : '¡NUEVA CARTA OBTENIDA!';
    rarity.textContent = card.rarity || 'COMÚN';
    img.src = card.image || 'nui://qb-inventory/html/images/pokemon_card_common.png';
    cardName.textContent = card.name || 'Carta Pokémon';
    marketVal.textContent = '€' + (card.marketValue || 0).toLocaleString('es-ES');

    modal.style.display = 'flex';

    if (card.isHit) {
        playSound('fanfare');
    } else {
        playSound('buy');
    }
}

function closeCardReveal() {
    const modal = document.getElementById('card-reveal-modal');
    if (modal) modal.style.display = 'none';
    isCardRevealOpen = false;

    fetch(`https://${GetParentResourceName()}/closeCardReveal`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

/* =========================================================================
   TABLET CORPORATIVA DE EMPLEOS (SPAIN WORKS PRO)
   ========================================================================= */
function initJobTabletEvents() {
    const btnClose = document.getElementById('job-btn-close');
    const btnStart = document.getElementById('btn-start-shift');
    const btnStop = document.getElementById('btn-stop-shift');
    const btnRespawn = document.getElementById('btn-respawn-veh');
    const btnGps = document.getElementById('btn-gps-task');

    if (btnClose) {
        btnClose.addEventListener('click', () => {
            closeJobTablet();
        });
    }

    if (btnStart) {
        btnStart.addEventListener('click', () => {
            if (isShiftActionPending || !currentJobData) return;
            isShiftActionPending = true;
            playSound('engine');
            closeJobTablet();

            fetch(`https://${GetParentResourceName()}/startShiftFromNui`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ stationKey: currentJobData.stationKey })
            });

            setTimeout(() => { isShiftActionPending = false; }, 1500);
        });
    }

    if (btnStop) {
        btnStop.addEventListener('click', () => {
            if (isShiftActionPending || !currentJobData) return;
            isShiftActionPending = true;
            playSound('click');
            closeJobTablet();

            fetch(`https://${GetParentResourceName()}/stopShiftFromNui`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ stationKey: currentJobData.stationKey })
            });

            setTimeout(() => { isShiftActionPending = false; }, 1500);
        });
    }

    if (btnRespawn) {
        btnRespawn.addEventListener('click', () => {
            if (!currentJobData) return;
            playSound('click');
            closeJobTablet();

            fetch(`https://${GetParentResourceName()}/respawnVehicleFromNui`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ stationKey: currentJobData.stationKey })
            });
        });
    }

    if (btnGps) {
        btnGps.addEventListener('click', () => {
            playSound('click');
            closeJobTablet();

            fetch(`https://${GetParentResourceName()}/setGpsToTask`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
        });
    }
}

function openJobTablet(data) {
    if (!data) return;
    currentJobData = data;
    isJobTabletOpen = true;

    const station = data.station || {};
    const worker = data.worker || {};

    // Encabezado
    document.getElementById('job-station-name').textContent = station.name || "Sede Laboral";
    document.getElementById('job-company-tag').textContent = (station.name || "EMPLEO OFICIAL").toUpperCase() + " • SPAIN ROL";

    // Credencial
    document.getElementById('job-worker-name').textContent = worker.name || "Ciudadano";
    document.getElementById('job-worker-role').textContent = (worker.grade || "Operario") + " (" + (worker.jobLabel || station.name || "Empresa") + ")";
    document.getElementById('job-worker-cid').textContent = "EXPEDIENTE: " + (worker.citizenid || "DESCONOCIDO");

    // Estado de Turno
    const dutyPill = document.getElementById('job-duty-status');
    const dutyText = document.getElementById('job-duty-text');
    const btnStart = document.getElementById('btn-start-shift');
    const btnStop = document.getElementById('btn-stop-shift');
    const btnRespawn = document.getElementById('btn-respawn-veh');
    const btnGps = document.getElementById('btn-gps-task');

    if (worker.onDuty) {
        dutyPill.classList.add('on-duty');
        dutyText.textContent = "EN SERVICIO ACTIVO";
        btnStart.style.display = 'none';
        btnStop.style.display = 'flex';
        btnRespawn.style.display = station.vehicle ? 'flex' : 'none';
        btnGps.style.display = 'flex';
    } else {
        dutyPill.classList.remove('on-duty');
        dutyText.textContent = "FUERA DE SERVICIO";
        btnStart.style.display = 'flex';
        btnStop.style.display = 'none';
        btnRespawn.style.display = 'none';
        btnGps.style.display = 'none';
    }

    // Métricas en vivo
    const payRange = (station.pay && station.pay.min && station.pay.max) 
        ? `€${station.pay.min} - €${station.pay.max}` 
        : "€120 - €240";
    document.getElementById('job-metric-pay').textContent = payRange;
    document.getElementById('job-metric-overtime').textContent = '€' + (worker.overtimeCash || 0).toLocaleString('es-ES');
    document.getElementById('job-metric-tasks').textContent = worker.tasksCount || 0;
    document.getElementById('job-metric-time').textContent = (worker.minutesWorked || 0) + ' min';

    // Itinerario y Cuadrante de Paradas
    const routesList = document.getElementById('job-routes-list');
    const routeBadge = document.getElementById('job-route-count');
    routesList.innerHTML = '';

    const tasks = station.tasks || [];
    routeBadge.textContent = `${tasks.length} Paradas Programadas`;

    tasks.forEach((t, idx) => {
        const item = document.createElement('div');
        item.className = 'route-card';

        const isCurrent = (worker.currentTaskIndex === idx + 1);
        item.innerHTML = `
            <div class="route-card-left">
                <div class="route-num">${idx + 1}</div>
                <div>
                    <div class="route-label">${t.label}</div>
                    <div class="route-tag">Duración estimada: ~${Math.round((t.duration || 5000) / 1000)}s &bull; GPS Verificado</div>
                </div>
            </div>
            ${isCurrent ? '<span class="route-badge-active">📍 ACTIVA EN GPS</span>' : '<span class="route-tag">En espera</span>'}
        `;
        routesList.appendChild(item);
    });

    document.getElementById('job-dashboard').style.display = 'flex';
    playSound('click');
}

function closeJobTablet() {
    const dashboard = document.getElementById('job-dashboard');
    if (dashboard) dashboard.style.display = 'none';
    isJobTabletOpen = false;

    fetch(`https://${GetParentResourceName()}/closeJobDashboard`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}
