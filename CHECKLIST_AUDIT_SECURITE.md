# CHECKLIST D'AUDIT DE SÉCURITÉ - JEU CRASH

Cette checklist doit être complétée lors de l'audit de sécurité du jeu Crash.

**Date de début**: _______________
**Auditeur**: _______________
**Version du jeu**: _______________

---

## 1. PRÉPARATION DE L'AUDIT

- [ ] Obtenir l'autorisation écrite pour les tests de pénétration
- [ ] Définir le périmètre de l'audit (URLs, environnements)
- [ ] Configurer l'environnement de test isolé
- [ ] Installer tous les outils nécessaires
- [ ] Créer un backup de l'environnement de test
- [ ] Documenter l'architecture de l'application
- [ ] Identifier tous les endpoints API

**Notes**:
```
_______________________________________________________________________________
_______________________________________________________________________________
```

---

## 2. TESTS DE SÉCURITÉ DU RNG (GÉNÉRATEUR ALÉATOIRE)

### 2.1 Validation du RNG

- [ ] Vérifier que le RNG est cryptographiquement sûr (CSPRNG)
- [ ] Confirmer l'utilisation de crypto.randomBytes (pas Math.random())
- [ ] Vérifier que le seed n'est pas prédictible
- [ ] Confirmer que le crash point est généré côté serveur uniquement
- [ ] Tester l'impossibilité de prédire le prochain crash

**Test effectué**: ☐ Oui  ☐ Non
**Résultat**: ☐ PASS  ☐ FAIL
**Vulnérabilités trouvées**: ___________________________________________________

### 2.2 Tests statistiques

- [ ] Collecter 1000+ échantillons de crash points
- [ ] Effectuer le test de Kolmogorov-Smirnov
- [ ] Effectuer le test d'autocorrélation
- [ ] Effectuer le Chi-square test
- [ ] Effectuer le Runs test
- [ ] Analyser la distribution des résultats

**Échantillons collectés**: _______________
**Résultat des tests**: ☐ Aléatoire  ☐ Patterns détectés
**Notes**: ___________________________________________________________________

### 2.3 Système Provably Fair

- [ ] Vérifier l'implémentation du système Provably Fair
- [ ] Tester la génération du server seed
- [ ] Tester la génération du client seed
- [ ] Vérifier la publication du seed hash avant le round
- [ ] Vérifier la révélation du seed après le round
- [ ] Valider que hash(server_seed) correspond au hash publié
- [ ] Tester la vérifiabilité des résultats

**Provably Fair implémenté**: ☐ Oui  ☐ Non
**Fonctionne correctement**: ☐ Oui  ☐ Non
**Vulnérabilités**: ___________________________________________________________

---

## 3. TESTS DE LOGIQUE MÉTIER

### 3.1 Validation des paris

- [ ] Tester pari avec montant négatif (-100)
- [ ] Tester pari avec montant 0
- [ ] Tester pari avec montant excessif (999999999)
- [ ] Tester pari avec nombre décimal invalide (0.00001)
- [ ] Tester pari dépassant le solde disponible
- [ ] Tester pari après le début du round
- [ ] Tester pari avec round_id invalide
- [ ] Tester pari sans authentication
- [ ] Tester double pari sur le même round

**Résumé des tests de pari**:
- Négatif: ☐ REJETÉ  ☐ ACCEPTÉ (VULNÉRABLE)
- Excessif: ☐ REJETÉ  ☐ ACCEPTÉ (VULNÉRABLE)
- Sans solde: ☐ REJETÉ  ☐ ACCEPTÉ (VULNÉRABLE)
- Après début: ☐ REJETÉ  ☐ ACCEPTÉ (VULNÉRABLE)

### 3.2 Validation des cashouts

- [ ] Tester cashout sans pari préalable
- [ ] Tester cashout après le crash (late cashout)
- [ ] Tester double cashout sur le même pari
- [ ] Tester cashout avec bet_id invalide
- [ ] Tester cashout avec multiplicateur modifié
- [ ] Tester cashout sans authentication
- [ ] Tester cashout d'un pari d'un autre utilisateur

**Résumé des tests de cashout**:
- Late cashout: ☐ REJETÉ  ☐ ACCEPTÉ (VULNÉRABLE)
- Double cashout: ☐ REJETÉ  ☐ ACCEPTÉ (VULNÉRABLE)
- Sans pari: ☐ REJETÉ  ☐ ACCEPTÉ (VULNÉRABLE)
- Autre utilisateur: ☐ REJETÉ  ☐ ACCEPTÉ (VULNÉRABLE)

### 3.3 Tests de race condition

- [ ] Envoyer 100 requêtes de cashout simultanées pour un même pari
- [ ] Placer 10 paris simultanés avec solde insuffisant
- [ ] Tester les locks de transaction sur la base de données
- [ ] Vérifier l'atomicité des transactions
- [ ] Tester avec haute latence réseau simulée

**Race conditions détectées**: ☐ Oui  ☐ Non
**Nombre de transactions réussies**: _______________
**Attendu**: 1
**Impact**: ___________________________________________________________________

---

## 4. TESTS D'INJECTION

### 4.1 Injection SQL

**Endpoints testés**:
- [ ] /api/bet
- [ ] /api/cashout
- [ ] /api/user/{id}
- [ ] /api/round/{id}
- [ ] /api/history

**Payloads testés**:
- [ ] `' OR '1'='1`
- [ ] `'; DROP TABLE bets; --`
- [ ] `' UNION SELECT * FROM users --`
- [ ] `1' AND SLEEP(5)--`
- [ ] `' OR 1=1--`

**Résultat**: ☐ Pas de vulnérabilité  ☐ Vulnérable
**Détails**: __________________________________________________________________
____________________________________________________________________________

### 4.2 Cross-Site Scripting (XSS)

**Champs testés**:
- [ ] Username
- [ ] Messages de chat
- [ ] Profil utilisateur
- [ ] Commentaires

**Payloads testés**:
- [ ] `<script>alert('XSS')</script>`
- [ ] `<img src=x onerror=alert('XSS')>`
- [ ] `<svg onload=alert('XSS')>`
- [ ] `javascript:alert('XSS')`

**Résultat**: ☐ Pas de vulnérabilité  ☐ Vulnérable
**Type de XSS**: ☐ Reflected  ☐ Stored  ☐ DOM-based
**Détails**: __________________________________________________________________

### 4.3 Command Injection

- [ ] Tester injection de commandes dans les paramètres
- [ ] Tester avec `; ls -la`
- [ ] Tester avec `| whoami`
- [ ] Tester avec `$(id)`

**Résultat**: ☐ Pas de vulnérabilité  ☐ Vulnérable

---

## 5. TESTS DE SÉCURITÉ RÉSEAU

### 5.1 Attaques par rejeu (Replay Attacks)

- [ ] Capturer une requête de pari légitime
- [ ] Rejouer la requête exacte
- [ ] Vérifier la présence de nonces
- [ ] Vérifier la présence de timestamps
- [ ] Vérifier la validation des signatures

**Replay possible**: ☐ Oui (VULNÉRABLE)  ☐ Non
**Protection en place**: ☐ Nonces  ☐ Timestamps  ☐ Signatures  ☐ Aucune

### 5.2 Man-in-the-Middle (MITM)

- [ ] Vérifier que HTTPS est obligatoire
- [ ] Vérifier que HTTP est redirigé vers HTTPS
- [ ] Tester le certificat SSL/TLS
- [ ] Vérifier la version TLS (minimum 1.2)
- [ ] Vérifier les ciphers utilisés
- [ ] Tester HSTS headers
- [ ] Vérifier WebSocket utilise WSS (pas WS)

**Certificat SSL valide**: ☐ Oui  ☐ Non
**Version TLS**: _______________
**HSTS activé**: ☐ Oui  ☐ Non
**WSS utilisé**: ☐ Oui  ☐ Non

### 5.3 Rate Limiting

- [ ] Envoyer 200 requêtes en 1 minute
- [ ] Vérifier si bloqué (429 Too Many Requests)
- [ ] Tester rate limiting par IP
- [ ] Tester rate limiting par utilisateur
- [ ] Tester rate limiting sur login
- [ ] Tester rate limiting sur API

**Rate limiting en place**: ☐ Oui  ☐ Non
**Limite détectée**: _______________ requêtes/minute
**Endpoints protégés**: ___________________________________________________________

---

## 6. TESTS DE SÉCURITÉ WEBSOCKET

### 6.1 Validation WebSocket

- [ ] Vérifier que WebSocket utilise WSS (chiffré)
- [ ] Tester l'authentication sur connexion WebSocket
- [ ] Envoyer des messages malformés
- [ ] Tester l'injection dans les messages WebSocket
- [ ] Tester le flooding de messages
- [ ] Vérifier la validation des messages côté serveur

**WebSocket sécurisé**: ☐ Oui  ☐ Non
**Authentication requise**: ☐ Oui  ☐ Non
**Validation des messages**: ☐ Oui  ☐ Non

### 6.2 Manipulation des messages

- [ ] Tenter de modifier le multiplicateur via WebSocket
- [ ] Tenter d'envoyer des actions administrateur
- [ ] Tenter de modifier les données d'autres utilisateurs
- [ ] Tester les messages avec paramètres invalides

**Manipulation possible**: ☐ Oui (VULNÉRABLE)  ☐ Non

---

## 7. TESTS D'AUTHENTICATION ET AUTORISATION

### 7.1 Authentication

- [ ] Tester l'accès aux endpoints sans token
- [ ] Tester avec token expiré
- [ ] Tester avec token invalide
- [ ] Tester avec token d'un autre utilisateur
- [ ] Vérifier la durée d'expiration des tokens
- [ ] Tester le mécanisme de refresh token
- [ ] Vérifier le hashing des mots de passe

**Tous les endpoints protégés**: ☐ Oui  ☐ Non
**Expiration token**: _______________ minutes
**Refresh token implémenté**: ☐ Oui  ☐ Non

### 7.2 Autorisation

- [ ] Tester l'accès aux paris d'autres utilisateurs
- [ ] Tester le cashout de paris d'autres utilisateurs
- [ ] Tester l'accès aux informations d'autres utilisateurs
- [ ] Tester l'élévation de privilèges
- [ ] Tester les endpoints administrateur

**Contrôle d'accès correct**: ☐ Oui  ☐ Non
**Vulnérabilités IDOR**: ☐ Aucune  ☐ Trouvées

---

## 8. TESTS DE SÉCURITÉ CÔTÉ CLIENT

### 8.1 Validation du code JavaScript

- [ ] Vérifier que le code est obfusqué en production
- [ ] Vérifier Subresource Integrity (SRI) sur assets externes
- [ ] Vérifier Content Security Policy (CSP) headers
- [ ] Vérifier qu'aucune logique métier critique n'est côté client
- [ ] Vérifier que les calculs de crash sont côté serveur uniquement

**Code obfusqué**: ☐ Oui  ☐ Non
**SRI en place**: ☐ Oui  ☐ Non
**CSP configuré**: ☐ Oui  ☐ Non
**Logique métier côté client**: ☐ Aucune  ☐ Présente (RISQUE)

### 8.2 Manipulation du client

- [ ] Tenter de modifier le multiplicateur dans DevTools
- [ ] Tenter de modifier le solde dans DevTools
- [ ] Tenter de modifier les variables de jeu
- [ ] Vérifier que les modifications n'affectent pas le serveur

**Manipulation client possible**: ☐ Oui mais sans effet  ☐ Affecte le serveur (CRITIQUE)

---

## 9. TESTS DE TIMING

### 9.1 Timing Attacks

- [ ] Mesurer les temps de réponse de 100+ requêtes
- [ ] Analyser la corrélation entre timing et crash point
- [ ] Tester si le timing révèle des informations sensibles

**Timing attack possible**: ☐ Oui  ☐ Non
**Corrélation détectée**: _______________

---

## 10. TESTS DE BASE DE DONNÉES

### 10.1 Sécurité de la base de données

- [ ] Vérifier que les prepared statements sont utilisés
- [ ] Vérifier le chiffrement des données au repos
- [ ] Vérifier le chiffrement des connexions (TLS)
- [ ] Vérifier les permissions de l'utilisateur DB
- [ ] Vérifier les backups automatisés
- [ ] Vérifier l'audit logging

**Prepared statements**: ☐ Oui  ☐ Non
**Chiffrement au repos**: ☐ Oui  ☐ Non
**Chiffrement en transit**: ☐ Oui  ☐ Non
**Privilèges minimaux**: ☐ Oui  ☐ Non

---

## 11. TESTS D'INFRASTRUCTURE

### 11.1 Sécurité serveur

- [ ] Vérifier que les ports inutiles sont fermés (nmap)
- [ ] Vérifier les headers de sécurité HTTP
- [ ] Vérifier la configuration du firewall
- [ ] Tester la protection DDoS
- [ ] Vérifier les mises à jour de sécurité
- [ ] Vérifier les logs d'accès et d'erreur

**Headers de sécurité**:
- [ ] Strict-Transport-Security (HSTS)
- [ ] X-Frame-Options
- [ ] X-Content-Type-Options
- [ ] X-XSS-Protection
- [ ] Content-Security-Policy
- [ ] Referrer-Policy

**Tous headers présents**: ☐ Oui  ☐ Non
**Protection DDoS**: ☐ Active  ☐ Inactive

### 11.2 Configuration serveur

- [ ] Vérifier que les informations de version sont cachées
- [ ] Vérifier que les pages d'erreur ne révèlent pas d'informations sensibles
- [ ] Vérifier la configuration nginx/apache
- [ ] Vérifier les permissions des fichiers

**Configuration sécurisée**: ☐ Oui  ☐ Non

---

## 12. TESTS DE MONITORING ET LOGGING

### 12.1 Audit logging

- [ ] Vérifier que toutes les transactions sont loggées
- [ ] Vérifier que les tentatives d'accès non autorisé sont loggées
- [ ] Vérifier que les erreurs sont loggées
- [ ] Vérifier que les logs sont protégés (pas accessibles publiquement)
- [ ] Vérifier la rétention des logs

**Logging complet**: ☐ Oui  ☐ Non
**Logs protégés**: ☐ Oui  ☐ Non

### 12.2 Détection d'anomalies

- [ ] Vérifier la détection de paris anormaux
- [ ] Vérifier la détection de taux de gain anormal
- [ ] Vérifier la détection de comportement suspect
- [ ] Vérifier les alertes automatiques

**Détection active**: ☐ Oui  ☐ Non

---

## 13. RÉSUMÉ DES VULNÉRABILITÉS

### Vulnérabilités CRITIQUES
```
1. ___________________________________________________________________________
2. ___________________________________________________________________________
3. ___________________________________________________________________________
```

### Vulnérabilités ÉLEVÉES
```
1. ___________________________________________________________________________
2. ___________________________________________________________________________
3. ___________________________________________________________________________
```

### Vulnérabilités MOYENNES
```
1. ___________________________________________________________________________
2. ___________________________________________________________________________
```

### Vulnérabilités FAIBLES
```
1. ___________________________________________________________________________
2. ___________________________________________________________________________
```

---

## 14. RECOMMANDATIONS PRIORITAIRES

### Priorité 1 (À corriger immédiatement)
```
1. ___________________________________________________________________________
2. ___________________________________________________________________________
3. ___________________________________________________________________________
```

### Priorité 2 (À corriger avant production)
```
1. ___________________________________________________________________________
2. ___________________________________________________________________________
3. ___________________________________________________________________________
```

### Priorité 3 (Améliorations)
```
1. ___________________________________________________________________________
2. ___________________________________________________________________________
```

---

## 15. VALIDATION FINALE

- [ ] Toutes les vulnérabilités critiques sont corrigées
- [ ] Retest effectué sur les corrections
- [ ] Documentation mise à jour
- [ ] Équipe de développement formée
- [ ] Plan de surveillance post-production établi
- [ ] Procédure de réponse aux incidents établie

**Prêt pour la production**: ☐ Oui  ☐ Non

**Signature de l'auditeur**: ___________________
**Date**: _______________

---

## NOTES ADDITIONNELLES

```
_______________________________________________________________________________
_______________________________________________________________________________
_______________________________________________________________________________
_______________________________________________________________________________
_______________________________________________________________________________
_______________________________________________________________________________
_______________________________________________________________________________
_______________________________________________________________________________
```

---

**FIN DE LA CHECKLIST**
