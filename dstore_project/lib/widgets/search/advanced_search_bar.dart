import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../services/sound_service.dart';
import 'barcode_scanner_screen.dart';

class AdvancedSearchBar extends StatefulWidget {
  final String? hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function(String)? onBarcodeScanned;
  final TextEditingController? controller;
  final bool showCategoryFilter;
  final List<String>? categories;
  final Function(String?)? onCategoryChanged;
  final String? selectedCategory;

  const AdvancedSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onBarcodeScanned,
    this.controller,
    this.showCategoryFilter = false,
    this.categories,
    this.onCategoryChanged,
    this.selectedCategory,
  });

  @override
  State<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar> {
  late TextEditingController _controller;
  bool _isExpanded = false;
  String _searchType = 'name'; // 'name', 'barcode', 'category'

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de recherche principale
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Icône de type de recherche
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getSearchTypeIcon(),
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Champ de recherche
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: widget.hintText ?? _getHintText(l10n),
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                  ),
                ),

                // Bouton de scan
                if (_searchType == 'barcode')
                  IconButton(
                    onPressed: _scanBarcode,
                    icon: Icon(
                      Icons.qr_code_scanner,
                      color: Theme.of(context).primaryColor,
                    ),
                    tooltip: l10n?.scanBarcode ?? 'Scanner le code-barres',
                  ),

                // Bouton de recherche
                IconButton(
                  onPressed: () {
                    if (widget.onSubmitted != null) {
                      widget.onSubmitted!(_controller.text);
                    }
                  },
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Options de recherche avancée
          if (_isExpanded) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.advancedSearch ?? 'Recherche avancée',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Types de recherche
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSearchTypeChip(
                        'name',
                        l10n?.searchByName ?? 'Par nom',
                        Icons.text_fields,
                      ),
                      _buildSearchTypeChip(
                        'barcode',
                        l10n?.searchByBarcode ?? 'Par code-barres',
                        Icons.qr_code,
                      ),
                      if (widget.showCategoryFilter)
                        _buildSearchTypeChip(
                          'category',
                          l10n?.searchByCategory ?? 'Par catégorie',
                          Icons.category,
                        ),
                    ],
                  ),

                  // Filtre par catégorie
                  if (widget.showCategoryFilter &&
                      _searchType == 'category') ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: widget.selectedCategory,
                      decoration: InputDecoration(
                        labelText: l10n?.category ?? 'Catégorie',
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child:
                              Text(l10n?.categories ?? 'Toutes les catégories'),
                        ),
                        if (widget.categories != null)
                          ...widget.categories!.map(
                            (category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ),
                          ),
                      ],
                      onChanged: widget.onCategoryChanged,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchTypeChip(String type, String label, IconData icon) {
    final isSelected = _searchType == type;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _searchType = type;
            _controller.clear();
          });
          if (widget.onChanged != null) {
            widget.onChanged!('');
          }
        }
      },
    );
  }

  IconData _getSearchTypeIcon() {
    switch (_searchType) {
      case 'barcode':
        return Icons.qr_code;
      case 'category':
        return Icons.category;
      default:
        return Icons.text_fields;
    }
  }

  String _getHintText(AppLocalizations? l10n) {
    switch (_searchType) {
      case 'barcode':
        return l10n?.searchByBarcode ?? 'Rechercher par code-barres';
      case 'category':
        return l10n?.searchByCategory ?? 'Rechercher par catégorie';
      default:
        return l10n?.searchByName ?? 'Rechercher par nom';
    }
  }

  Future<void> _scanBarcode() async {
    try {
      // Jouer le son de scan
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      await SoundService.playSound(settingsProvider.scanSound);

      // Naviguer vers l'écran de scan
      if (mounted) {
        final result = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (context) => const BarcodeScannerScreen(),
          ),
        );

        if (result != null && result.isNotEmpty && mounted) {
          _controller.text = result;
          if (widget.onBarcodeScanned != null) {
            widget.onBarcodeScanned!(result);
          }
          if (widget.onChanged != null) {
            widget.onChanged!(result);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du scan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
