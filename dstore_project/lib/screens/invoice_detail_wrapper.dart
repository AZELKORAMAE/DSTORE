import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../version.dart';
import '../l10n/app_localizations.dart';
import '../models/invoice_model.dart';
import '../providers/invoice_provider.dart';
import '../screens/invoice_detail_screen.dart';

class InvoiceDetailScreenWrapper extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreenWrapper({
    Key? key,
    required this.invoiceId,
  }) : super(key: key);

  @override
  State<InvoiceDetailScreenWrapper> createState() =>
      _InvoiceDetailScreenWrapperState();
}

class _InvoiceDetailScreenWrapperState
    extends State<InvoiceDetailScreenWrapper> {
  InvoiceModel? invoice;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final invoiceProvider =
          Provider.of<InvoiceProvider>(context, listen: false);

      // Chercher d'abord dans les factures déjà chargées
      final existingInvoice = invoiceProvider.invoices.firstWhere(
        (inv) => inv.id == widget.invoiceId,
        orElse: () => throw Exception('Facture non trouvée'),
      );

      setState(() {
        invoice = existingInvoice;
        isLoading = false;
      });
    } catch (e) {
      // Si la facture n'est pas trouvée dans la liste, essayer de la charger
      try {
        final invoiceProvider =
            Provider.of<InvoiceProvider>(context, listen: false);
        await invoiceProvider.loadInvoices(); // Recharger toutes les factures

        final loadedInvoice = invoiceProvider.invoices.firstWhere(
          (inv) => inv.id == widget.invoiceId,
          orElse: () => throw Exception('Facture non trouvée'),
        );

        setState(() {
          invoice = loadedInvoice;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          error = 'Erreur lors du chargement de la facture: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // PATCH MARKER
    // ignore: avoid_print
    print('[InvoiceWrapper] build '+kBuildPatch);
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chargement...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erreur'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(error ?? AppLocalizations.of(context)!.genericErrorPrefix, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadInvoice,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Facture introuvable'),
        ),
        body: const Center(
          child: Text('Cette facture n\'existe pas ou a été supprimée.'),
        ),
      );
    }

    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.invoice)),
        body: Center(child: Text(AppLocalizations.of(context)!.genericErrorPrefix + ' (invoice == null)')),
      );
    }
    final inv = invoice;
    if (inv == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.invoice)),
        body: Center(child: Text(AppLocalizations.of(context)!.genericErrorPrefix + ' (invoice == null)')),
      );
    }
    return InvoiceDetailScreen(invoice: inv);
  }
}
