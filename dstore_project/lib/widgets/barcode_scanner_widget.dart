import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/settings_provider.dart';
import '../services/sound_service.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(String) onBarcodeDetected;
  final String title;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeDetected,
    this.title = 'Scanner le code-barres',
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Naviguer vers l'écran de scan avec mobile_scanner
      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => _MobileScannerScreen(),
        ),
      );

      if (result != null && result.isNotEmpty && mounted) {
        // Code-barres scanné avec succès
        widget.onBarcodeDetected(result);
        Navigator.of(context)
            .pop(result); // Fermer le widget scanner et retourner le résultat
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erreur lors du scan: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _processBarcode() {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      _showErrorDialog('Veuillez saisir un code-barres');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simuler un petit délai de traitement
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onBarcodeDetected(barcode);
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône principale
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.qr_code_scanner,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Scanner de code-barres',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bouton de scan caméra
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '📱 Scanner caméra disponible !',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Utilisez la caméra pour scanner automatiquement',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bouton de scan caméra
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _scanBarcode,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.camera_alt),
                      label: Text(_isProcessing
                          ? 'Ouverture...'
                          : 'Scanner avec la caméra'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Séparateur
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OU',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section saisie manuelle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Saisie manuelle du code-barres',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Saisissez le code-barres manuellement ci-dessous',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Champ de saisie
                  TextField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      labelText: 'Code-barres',
                      hintText: 'Saisissez le code-barres...',
                      prefixIcon: const Icon(Icons.qr_code),
                      border: const OutlineInputBorder(),
                      suffixIcon: _barcodeController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _barcodeController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onChanged: (value) => setState(() {}),
                    onSubmitted: (_) => _processBarcode(),
                    enabled: !_isProcessing,
                  ),

                  const SizedBox(height: 24),

                  // Bouton de validation
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _processBarcode,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(_isProcessing ? 'Traitement...' : 'Valider'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bouton d'annulation
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed:
                    _isProcessing ? null : () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informations sur les formats supportés
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Formats supportés: QR Code, EAN-13, EAN-8, Code 128, Code 39, etc.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Scanner caméra entièrement fonctionnel !',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Écran de scan avec mobile_scanner
class _MobileScannerScreen extends StatefulWidget {
  @override
  State<_MobileScannerScreen> createState() => _MobileScannerScreenState();
}

class _MobileScannerScreenState extends State<_MobileScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() {
          _isProcessing = true;
        });

        // Jouer le son de scan selon les paramètres utilisateur
        try {
          final settings =
              Provider.of<SettingsProvider>(context, listen: false);
          SoundService.playSound(settings.scanSound);
        } catch (e) {
          // Fallback si erreur avec les paramètres
          SoundService.playScanSound();
        }

        // Retourner le code scanné
        Navigator.of(context).pop(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner le code-barres'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner caméra
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // Overlay avec instructions
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pointez la caméra vers le code-barres',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Le scan se fera automatiquement',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Bouton d'annulation
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
