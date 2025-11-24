# ANALYSE PASSIVE DU JEU CRASH 1XBET

**URL**: https://ma-1xbet.com/en/games/crash
**Date**: 24 Novembre 2025
**Type**: Analyse passive (légale, sans tests actifs)

---

## ⚠️ AVERTISSEMENT LÉGAL

Cette analyse est UNIQUEMENT passive - observation du comportement public du site.
AUCUN test actif, aucune tentative d'exploitation, aucun test de pénétration.

---

## 1. ANALYSE PASSIVE DU FRONTEND

### À observer (depuis DevTools du navigateur)

#### 1.1 Analyse du code JavaScript
```
1. Ouvrir le site dans le navigateur
2. Ouvrir DevTools (F12)
3. Onglet "Sources" → Observer les fichiers JS
4. Onglet "Network" → Observer les requêtes

Questions à se poser (SANS modifier) :
- Le code est-il obfusqué ?
- Quelles bibliothèques sont utilisées ?
- Y a-t-il des calculs sensibles côté client ?
- Les WebSockets sont-ils chiffrés (wss://) ?
```

#### 1.2 Headers de sécurité
```
Dans DevTools → Network → Sélectionner une requête → Headers

Vérifier la présence de :
☐ Strict-Transport-Security (HSTS)
☐ Content-Security-Policy (CSP)
☐ X-Frame-Options
☐ X-Content-Type-Options
☐ X-XSS-Protection
```

#### 1.3 Certificat SSL/TLS
```
Cliquer sur le cadenas dans la barre d'adresse
Vérifier :
☐ Certificat valide
☐ Émetteur du certificat
☐ Date d'expiration
☐ Version TLS utilisée
```

#### 1.4 Cookies et stockage
```
DevTools → Application → Storage
Observer (SANS modifier) :
- Cookies (HttpOnly, Secure flags ?)
- LocalStorage (données sensibles ?)
- SessionStorage
- IndexedDB
```

---

## 2. ANALYSE DU FLOW DU JEU

### 2.1 Séquence observable

```
1. CHARGEMENT
   - Quels assets sont chargés ?
   - D'où proviennent les scripts (CDN, domaine propre) ?
   - Subresource Integrity (SRI) présent ?

2. CONNEXION
   - Authentication via quel mécanisme ?
   - JWT ? Session cookies ?
   - HTTPS obligatoire ?

3. PLACEMENT DE PARI
   Network Tab → Observer :
   - Endpoint API utilisé
   - Méthode (POST ?)
   - Headers envoyés
   - Body de la requête (structure)
   - Réponse du serveur

4. PROGRESSION DU JEU
   - WebSocket pour temps réel ?
   - Messages échangés (observer dans WS tab)
   - Format des messages (JSON ?)

5. CASHOUT
   - Comment la requête est envoyée ?
   - Quels paramètres ?
   - Validation côté serveur apparente ?

6. CRASH
   - Comment le crash point est révélé ?
   - Vient du serveur ou calculé client ?
```

---

## 3. ANALYSE DES ENDPOINTS API (Observation uniquement)

### 3.1 Endpoints détectés

Depuis Network Tab, documenter :

```
Endpoint 1: _______________________
Méthode: GET / POST / WebSocket
Authentifié: ☐ Oui ☐ Non
Rate limiting observable: ☐ Oui ☐ Non

Endpoint 2: _______________________
Méthode: GET / POST / WebSocket
Authentifié: ☐ Oui ☐ Non
Rate limiting observable: ☐ Oui ☐ Non

...
```

---

## 4. ANALYSE DU WEBSOCKET (Observation)

### 4.1 Connexion WebSocket

```
Dans DevTools → Network → WS

URL WebSocket: _______________________
Protocole: ☐ ws:// ☐ wss:// (chiffré)

Messages observés (exemples) :
Client → Serveur:
{
  "action": "...",
  "data": {...}
}

Serveur → Client:
{
  "type": "...",
  "multiplier": ...,
  ...
}
```

### 4.2 Questions d'analyse

```
☐ Le multiplicateur vient-il du serveur ?
☐ Y a-t-il des signatures/checksums sur les messages ?
☐ Les timestamps sont-ils présents ?
☐ Le crash point est-il envoyé avant ou après le crash ?
```

---

## 5. ANALYSE DU SYSTÈME PROVABLY FAIR

### 5.1 Rechercher sur le site

```
☐ Y a-t-il une section "Provably Fair" ?
☐ Un seed hash est-il publié avant chaque round ?
☐ Le seed est-il révélé après le round ?
☐ Un outil de vérification est-il fourni ?
```

### 5.2 Si Provably Fair est présent

```
Server Seed Hash (avant round): _______________________
Server Seed révélé (après round): _______________________
Client Seed: _______________________

Vérification manuelle :
hash(server_seed) = seed_hash publié ? ☐ Oui ☐ Non
```

---

## 6. OBSERVATIONS GÉNÉRALES

### 6.1 Points positifs observés

```
✅ _________________________________________________________________
✅ _________________________________________________________________
✅ _________________________________________________________________
```

### 6.2 Points d'attention (sans test actif)

```
⚠️ _________________________________________________________________
⚠️ _________________________________________________________________
⚠️ _________________________________________________________________
```

### 6.3 Questions nécessitant autorisation pour tester

```
❓ Le RNG est-il vraiment imprévisible ? (nécessite tests statistiques)
❓ Les race conditions sont-elles gérées ? (nécessite tests actifs)
❓ L'injection SQL est-elle possible ? (nécessite tests actifs)
❓ ...
```

---

## 7. RECOMMANDATIONS POUR AUDIT OFFICIEL

Si vous obtenez l'autorisation d'un audit complet :

### 7.1 Tests à effectuer

Utiliser la documentation créée :
- `AUDIT_SECURITE_CRASH_GAME.md` pour la méthodologie complète
- `CHECKLIST_AUDIT_SECURITE.md` pour suivre les tests
- `security_test_suite.py` pour les tests automatisés

### 7.2 Environnement requis

```
☐ Environnement de staging (PAS production)
☐ Credentials de test fournis
☐ Autorisation écrite signée
☐ Période de test définie
☐ Contact technique chez 1xbet
```

---

## 8. COMMENT OBTENIR UNE AUTORISATION OFFICIELLE

### 8.1 Programme Bug Bounty

Rechercher si 1xbet a un programme :
- Sur leur site web (footer, section sécurité)
- Sur des plateformes comme HackerOne, Bugcrowd, YesWeHack

### 8.2 Contact direct

```
Option 1: Email sécurité
Rechercher une adresse type:
- security@1xbet.com
- bugbounty@1xbet.com
- responsible-disclosure@1xbet.com

Option 2: Contact support
Via le site web, demander à être mis en relation avec l'équipe sécurité

Option 3: LinkedIn
Contacter des employés de l'équipe sécurité/technique
```

### 8.3 Contenu de la demande

```
Objet : Proposition d'audit de sécurité - Jeu Crash

Bonjour,

Je suis [votre nom], auditeur de sécurité spécialisé dans les jeux d'argent en ligne.

Je souhaite proposer un audit de sécurité de votre jeu Crash pour identifier
et corriger d'éventuelles vulnérabilités avant qu'elles ne soient exploitées.

J'ai préparé une méthodologie complète couvrant :
- Sécurité du générateur de nombres aléatoires (RNG)
- Protection contre les manipulations
- Tests de pénétration API
- Validation du système Provably Fair
- Et 10+ autres catégories de vulnérabilités

Seriez-vous intéressés par :
1. Un audit complet sous contrat
2. Une participation à votre programme bug bounty (si existant)
3. Une collaboration de responsible disclosure

Je reste à votre disposition pour discuter des modalités.

Cordialement,
[Votre nom]
[Vos qualifications]
```

---

## 9. RESSOURCES POUR APPRENDRE (Légalement)

### 9.1 Environnements de pratique légaux

```
- OWASP WebGoat (application vulnérable pour apprendre)
- Damn Vulnerable Web Application (DVWA)
- HackTheBox (challenges légaux)
- TryHackMe (plateforme d'apprentissage)
- PentesterLab (labs de sécurité)
```

### 9.2 Créer votre propre jeu Crash

```
Pour pratiquer l'audit :
1. Créer votre propre version du jeu Crash
2. Implémenter volontairement des vulnérabilités
3. Utiliser vos outils d'audit dessus
4. Corriger les vulnérabilités trouvées
5. Répéter le processus

Cela vous donnera l'expérience nécessaire sans risques légaux.
```

---

## 10. RÉSUMÉ - CE QUI EST PERMIS

### ✅ LÉGAL (Sans autorisation)

- Observer le comportement public du site
- Analyser le code JavaScript côté client visible
- Lire la documentation publique
- Vérifier les headers HTTP
- Observer les requêtes dans DevTools
- Analyser le certificat SSL
- Tester sur vos propres instances
- Apprendre sur des environnements de test publics

### ❌ ILLÉGAL (Sans autorisation)

- Envoyer des requêtes modifiées
- Tester des injections SQL/XSS
- Tenter de manipuler le jeu
- Faire du fuzzing d'API
- Exploiter des vulnérabilités
- Scanner les ports du serveur
- Tenter un accès non autorisé
- Tests de charge (DoS)

---

## CONCLUSION

Cette analyse passive vous donne un aperçu du fonctionnement du jeu.
Pour aller plus loin, **vous DEVEZ obtenir une autorisation officielle**.

La documentation d'audit que j'ai créée est prête à être utilisée dès que
vous obtenez cette autorisation.

---

**Rappel légal** : Ne jamais tester un système sans autorisation explicite écrite.
