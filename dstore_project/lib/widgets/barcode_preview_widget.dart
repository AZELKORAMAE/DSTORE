import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:barcode/barcode.dart' as bc;

import '../services/barcode_print_service.dart';

class BarcodePreviewWidget extends StatefulWidget {
  final String barcodeData;
  final String productName;
  final String? productDescription;
  final double? price;
  final String? unit;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;

  const BarcodePreviewWidget({
    super.key,
    required this.barcodeData,
    required this.productName,
    this.productDescription,
    this.price,
    this.unit,
    this.onPrint,
    this.onShare,
  });

  @override
  State<BarcodePreviewWidget> createState() => _BarcodePreviewWidgetState();
}

class _BarcodePreviewWidgetState extends State<BarcodePreviewWidget> {
  bc.BarcodeType _selectedBarcodeType = bc.BarcodeType.Code128;
  bool _multipleLabels = false;
  int _labelsPerPage = 12;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Icon(
                  Icons.qr_code_2,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Aperçu du code-barres',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Prévisualisation du code-barres
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // Nom du produit
                  Text(
                    widget.productName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  if (widget.productDescription?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.productDescription!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Code-barres
                  Container(
                    height: 80,
                    child: BarcodeWidget(
                      barcode: _getBarcodeFromType(_selectedBarcodeType),
                      data: widget.barcodeData,
                      width: 200,
                      height: 80,
                      drawText: true,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Prix
                  if (widget.price != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.price!.toStringAsFixed(2)} DH',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (widget.unit?.isNotEmpty == true) ...[
                          const SizedBox(width: 4),
                          Text(
                            '/ ${widget.unit}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Options d'impression
            _buildPrintOptions(),

            const SizedBox(height: 16),

            // Boutons d'action
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options d\'impression',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Type de code-barres
        DropdownButtonFormField<bc.BarcodeType>(
          value: _selectedBarcodeType,
          decoration: const InputDecoration(
            labelText: 'Type de code-barres',
            prefixIcon: Icon(Icons.qr_code),
          ),
          items: BarcodePrintService.getAvailableBarcodeTypes().map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(BarcodePrintService.getBarcodeTypeName(type)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedBarcodeType = value;
              });
            }
          },
        ),

        const SizedBox(height: 12),

        // Options multiples étiquettes
        SwitchListTile(
          title: const Text('Plusieurs étiquettes par page'),
          subtitle: Text(_multipleLabels 
            ? '$_labelsPerPage étiquettes par page'
            : 'Une seule étiquette grande'
          ),
          value: _multipleLabels,
          onChanged: (value) {
            setState(() {
              _multipleLabels = value;
            });
          },
        ),

        if (_multipleLabels) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Nombre d\'étiquettes: '),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _labelsPerPage,
                items: [6, 12, 18, 24].map((count) {
                  return DropdownMenuItem(
                    value: count,
                    child: Text('$count'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _labelsPerPage = value;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _printBarcode,
            icon: const Icon(Icons.print),
            label: const Text('Imprimer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _shareBarcode,
            icon: const Icon(Icons.share),
            label: const Text('Partager'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _printBarcode() async {
    await BarcodePrintService.printBarcode(
      context: context,
      barcodeData: widget.barcodeData,
      productName: widget.productName,
      productDescription: widget.productDescription,
      price: widget.price,
      unit: widget.unit,
      barcodeType: _selectedBarcodeType,
      multipleLabels: _multipleLabels,
      labelsPerPage: _labelsPerPage,
    );

    widget.onPrint?.call();
  }

  void _shareBarcode() async {
    await BarcodePrintService.shareBarcode(
      context: context,
      barcodeData: widget.barcodeData,
      productName: widget.productName,
      productDescription: widget.productDescription,
      price: widget.price,
      unit: widget.unit,
      barcodeType: _selectedBarcodeType,
      multipleLabels: _multipleLabels,
      labelsPerPage: _labelsPerPage,
    );

    widget.onShare?.call();
  }

  bc.Barcode _getBarcodeFromType(bc.BarcodeType type) {
    return bc.Barcode.fromType(type);
  }
}

class BarcodePreviewDialog extends StatelessWidget {
  final String barcodeData;
  final String productName;
  final String? productDescription;
  final double? price;
  final String? unit;

  const BarcodePreviewDialog({
    super.key,
    required this.barcodeData,
    required this.productName,
    this.productDescription,
    this.price,
    this.unit,
  });

  static Future<void> show({
    required BuildContext context,
    required String barcodeData,
    required String productName,
    String? productDescription,
    double? price,
    String? unit,
  }) {
    return showDialog(
      context: context,
      builder: (context) => BarcodePreviewDialog(
        barcodeData: barcodeData,
        productName: productName,
        productDescription: productDescription,
        price: price,
        unit: unit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.print, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Imprimer le code-barres',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Contenu
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: BarcodePreviewWidget(
                  barcodeData: barcodeData,
                  productName: productName,
                  productDescription: productDescription,
                  price: price,
                  unit: unit,
                  onPrint: () => Navigator.of(context).pop(),
                  onShare: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
