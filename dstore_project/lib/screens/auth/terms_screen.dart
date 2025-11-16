import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Écran affichant les conditions d'utilisation et la politique de confidentialité.
/// Accessible sans authentification depuis l'inscription.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // On garde l'import l10n si vous ajoutez plus tard des traductions.
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Conditions d'utilisation et politique de confidentialité",
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // ===== CONDITIONS D'UTILISATION =====
              Text(
                "Conditions d'utilisation",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "1) Acceptation des conditions\n"
                "En utilisant cette application, vous acceptez sans réserve les présentes conditions. "
                "Si vous n’êtes pas d’accord avec l’une des clauses, veuillez cesser d’utiliser l’application.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                "2) Usage autorisé\n"
                "L’application est destinée à un usage professionnel : gestion des produits, ventes, factures, "
                "stocks et crédits clients. Toute utilisation illégale ou contraire aux lois en vigueur est interdite.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                "3) Compte et sécurité\n"
                "Vous êtes responsable de la confidentialité de vos identifiants et de l’exactitude des informations fournies. "
                "Informez-nous en cas d’utilisation non autorisée de votre compte.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                "4) Données et disponibilité du service\n"
                "Nous mettons en place des mesures techniques pour protéger vos données et assurer la disponibilité du service. "
                "Cependant, aucune solution n’offre une sécurité absolue ni une disponibilité sans interruption.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                "5) Responsabilité\n"
                "L’éditeur ne pourra être tenu responsable des pertes de données, pertes financières ou tout dommage indirect "
                "résultant de l’utilisation de l’application.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                "6) Modifications\n"
                "Nous pouvons modifier ces conditions à tout moment. Les modifications prennent effet dès leur publication "
                "dans l’application.",
                style: TextStyle(fontSize: 14),
              ),

              SizedBox(height: 24),

              // ===== POLITIQUE DE CONFIDENTIALITÉ =====
              Text(
                "Politique de confidentialité",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "1) Données collectées\n"
                "Nous collectons uniquement les données nécessaires au fonctionnement de l’application : "
                "informations de compte (nom, email, téléphone), produits, ventes, factures, mouvements de stock, "
                "et crédits clients.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                "2) Finalités du traitement\n"
                "• Gérer vos produits, stocks, ventes et factures\n"
                "• Établir rapports et états de suivi\n"
                "• Améliorer l’expérience utilisateur (support, fiabilité)",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                "3) Partage des données\n"
                "Vos données ne sont ni vendues ni partagées avec des tiers, sauf obligation légale ou consentement explicite.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                "4) Sécurité\n"
                "Nous utilisons des mesures techniques et organisationnelles raisonnables pour protéger vos informations "
                "contre l’accès non autorisé, la divulgation ou la destruction.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                "5) Vos droits\n"
                "Vous disposez d’un droit d’accès, de rectification, de suppression, de limitation et d’opposition au traitement "
                "de vos données, conformément à la réglementation applicable.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                "6) Contact\n"
                "Pour toute question relative à la protection des données : dstoreteam@gmail.com",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 24),
              Text(
                "Dernière mise à jour : 09/08/2025",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
