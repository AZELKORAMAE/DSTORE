import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../../models/invoice_customization_model.dart';
import '../../services/invoice_customization_service.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';

class InvoiceCustomizationScreen extends StatefulWidget {
  const InvoiceCustomizationScreen({super.key});

  @override
  State<InvoiceCustomizationScreen> createState() => _InvoiceCustomizationScreenState();
}

class _InvoiceCustomizationScreenState extends State<InvoiceCustomizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _headerTextController = TextEditingController();
  final _footerTextController = TextEditingController();
  
  final InvoiceCustomizationService _customizationService = InvoiceCustomizationService();
  InvoiceCustomizationModel? _customization;
  bool _isLoading = true;
  File? _logoFile;
  
  // Variables d'état pour les paramètres de personnalisation
  Color _primaryColor = const Color(0xFF2196F3);
  Color _secondaryColor = const Color(0xFFFFC107);
  double _fontSize = 12.0;
  bool _showLogo = true;
  bool _showHeader = true;
  bool _showFooter = true;
  bool _showCompanyInfo = true;
  
  @override
  void initState() {
    super.initState();
    _loadCustomization();
  }
  
  Future<void> _loadCustomization() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      
      if (userId != null) {
        _customization = await _customizationService.loadCustomization(userId);
        if (_customization != null) {
          _populateFields();
        }
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _populateFields() {
    if (_customization != null) {
      _companyNameController.text = _customization!.companyName ?? '';
      _companyAddressController.text = _customization!.companyAddress ?? '';
      _companyPhoneController.text = _customization!.companyPhone ?? '';
      _companyEmailController.text = _customization!.companyEmail ?? '';
      _headerTextController.text = _customization!.headerText ?? '';
      _footerTextController.text = _customization!.footerText ?? '';
      
      // Initialiser les variables d'état avec les valeurs de la personnalisation
      _primaryColor = Color(int.parse(_customization!.primaryColor.replaceFirst('#', '0xFF')));
      _secondaryColor = Color(int.parse(_customization!.secondaryColor.replaceFirst('#', '0xFF')));
      _fontSize = _customization!.fontSize;
      _showLogo = _customization!.showLogo;
      _showHeader = _customization!.showHeader;
      _showFooter = _customization!.showFooter;
      _showCompanyInfo = _customization!.showCompanyInfo;
    }
  }
  
  Future<void> _saveCustomization() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      
      if (userId == null) {
        _showErrorSnackBar('Utilisateur non connecté');
        return;
      }
      
      String? logoPath;
      if (_logoFile != null) {
        logoPath = _logoFile!.path;
      }
      
      final customization = InvoiceCustomizationModel(
        id: _customization?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        companyName: _companyNameController.text,
        companyAddress: _companyAddressController.text,
        companyPhone: _companyPhoneController.text,
        companyEmail: _companyEmailController.text,
        companyWebsite: _customization?.companyWebsite,
        headerText: _headerTextController.text,
        footerText: _footerTextController.text,
        logoPath: logoPath ?? _customization?.logoPath,
        primaryColor: '#${_primaryColor.value.toRadixString(16).substring(2).toUpperCase()}',
        secondaryColor: '#${_secondaryColor.value.toRadixString(16).substring(2).toUpperCase()}',
        fontSize: _fontSize,
        showLogo: _showLogo,
        showHeader: _showHeader,
        showFooter: _showFooter,
        showCompanyInfo: _showCompanyInfo,
        createdAt: _customization?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _customizationService.saveCustomization(customization);
      _customization = customization;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invoiceCustomizationSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la sauvegarde: $e');
    }
  }
  
  Future<void> _pickLogo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _logoFile = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la sélection du logo: $e');
    }
  }
  
  void _removeLogo() {
    setState(() {
      _logoFile = null;
      if (_customization != null) {
        _customization = _customization!.copyWith(logoPath: null);
      }
    });
  }
  
  Future<void> _resetToDefault() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      
      if (userId != null) {
        await _customizationService.resetToDefault(userId);
        _customization = InvoiceCustomizationModel.createDefault(userId);
        _populateFields();
        setState(() {
          _logoFile = null;
          // Réinitialiser les variables d'état aux valeurs par défaut
          _primaryColor = const Color(0xFF2196F3);
          _secondaryColor = const Color(0xFFFFC107);
          _fontSize = 12.0;
          _showLogo = true;
          _showHeader = true;
          _showFooter = true;
          _showCompanyInfo = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.invoiceCustomizationReset),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la réinitialisation: $e');
    }
  }
  
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showColorPicker(bool isPrimary) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isPrimary ? 'Choisir la couleur primaire' : 'Choisir la couleur secondaire'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: isPrimary ? _primaryColor : _secondaryColor,
              onColorChanged: (color) {
                setState(() {
                  if (isPrimary) {
                    _primaryColor = color;
                  } else {
                    _secondaryColor = color;
                  }
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        );
      },
    );
  }
  
  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    _companyEmailController.dispose();
    _headerTextController.dispose();
    _footerTextController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.invoiceCustomizationTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetToDefault,
            tooltip: 'Réinitialiser',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCustomization,
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Logo
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Logo de l\'entreprise',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_logoFile != null || (_customization?.logoPath != null && _customization!.logoPath!.isNotEmpty))
                              Container(
                                height: 100,
                                width: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _logoFile != null
                                    ? Image.file(_logoFile!, fit: BoxFit.contain)
                                    : _customization?.logoPath != null && _customization!.logoPath!.isNotEmpty
                                        ? Image.file(File(_customization!.logoPath!), fit: BoxFit.contain)
                                        : const Icon(Icons.image, size: 50),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _pickLogo,
                                  icon: const Icon(Icons.upload),
                                  label: Text(AppLocalizations.of(context)!.chooseLogo),
                                ),
                                const SizedBox(width: 16),
                                if (_logoFile != null || (_customization?.logoPath != null && _customization!.logoPath!.isNotEmpty))
                                  ElevatedButton.icon(
                                    onPressed: _removeLogo,
                                    icon: const Icon(Icons.delete),
                                    label: Text(AppLocalizations.of(context)!.delete),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Section Informations de l'entreprise
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations de l\'entreprise',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _companyNameController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.companyNameLabel,
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez saisir le nom de l\'entreprise';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _companyAddressController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.addressLabel,
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _companyPhoneController,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.phoneLabel,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _companyEmailController,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.emailLabel,
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value != null && value.isNotEmpty) {
                                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                          return 'Email invalide';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Section Couleurs et Style
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Couleurs et Style',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Couleur primaire
                            Row(
                              children: [
                                Text(AppLocalizations.of(context)!.primaryColorLabel + ': '),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () => _showColorPicker(true),
                                  child: Container(
                                    width: 50,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: _primaryColor,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Couleur secondaire
                            Row(
                              children: [
                                Text(AppLocalizations.of(context)!.secondaryColorLabel + ': '),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () => _showColorPicker(false),
                                  child: Container(
                                    width: 50,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: _secondaryColor,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Taille de police
                            Row(
                              children: [
                                Text(AppLocalizations.of(context)!.fontSizeLabel + ': '),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Slider(
                                    value: _fontSize,
                                    min: 8.0,
                                    max: 20.0,
                                    divisions: 12,
                                    label: _fontSize.round().toString(),
                                    onChanged: (value) {
                                      setState(() {
                                        _fontSize = value;
                                      });
                                    },
                                  ),
                                ),
                                Text('${_fontSize.round()}pt'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Section Options d'affichage
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.displayOptionsSectionTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            SwitchListTile(
                              title: Text(AppLocalizations.of(context)!.showLogo),
                              value: _showLogo,
                              onChanged: (value) {
                                setState(() {
                                  _showLogo = value;
                                });
                              },
                            ),
                            SwitchListTile(
                              title: Text(AppLocalizations.of(context)!.showCompanyInfo),
                              value: _showCompanyInfo,
                              onChanged: (value) {
                                setState(() {
                                  _showCompanyInfo = value;
                                });
                              },
                            ),
                            SwitchListTile(
                              title: Text(AppLocalizations.of(context)!.showHeader),
                              value: _showHeader,
                              onChanged: (value) {
                                setState(() {
                                  _showHeader = value;
                                });
                              },
                            ),
                            SwitchListTile(
                              title: Text(AppLocalizations.of(context)!.showFooter),
                              value: _showFooter,
                              onChanged: (value) {
                                setState(() {
                                  _showFooter = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Section En-tête et Pied de page
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'En-tête et Pied de page',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _headerTextController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.headerTextLabel,
                                border: OutlineInputBorder(),
                                hintText: AppLocalizations.of(context)!.headerTextHint,
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _footerTextController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.footerTextLabel,
                                border: OutlineInputBorder(),
                                hintText: AppLocalizations.of(context)!.footerTextHint,
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Boutons d'action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _resetToDefault,
                          icon: const Icon(Icons.refresh),
                          label: Text(AppLocalizations.of(context)!.reset),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _saveCustomization,
                          icon: const Icon(Icons.save),
                          label: Text(AppLocalizations.of(context)!.save),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}