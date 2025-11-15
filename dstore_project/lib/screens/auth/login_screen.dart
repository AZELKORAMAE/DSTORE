// imports
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../config/app_router.dart';
import '../../main.dart';
import '../../services/local_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoadingCredentials = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final credentials = await LocalStorageService.instance
          .getSavedLoginCredentials()
          .timeout(const Duration(seconds: 5));

      if (mounted) {
        setState(() {
          if (credentials['email'] != null) {
            _emailController.text = credentials['email']!;
          }
          _rememberMe = credentials['remember_me'] == 'true';
          _isLoadingCredentials = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCredentials = false;
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await authProvider.signIn(email, password);

    if (success && mounted) {
      await LocalStorageService.instance.saveLoginCredentials(
        email: email,
        password: password,
        rememberMe: _rememberMe,
      );

      final hasAccess = await authProvider.checkSubscriptionAccess();
      if (mounted) {
        if (hasAccess) {
          context.goToDashboard();
        } else {
          context.go('/subscription-check');
        }
      }
    } else if (mounted) {
      final errorMessage = authProvider.errorMessage ?? 'Erreur de connexion';
      print('🔍 DEBUG LOGIN: Message d\'erreur reçu: "$errorMessage"');

      if (errorMessage.contains('PENDING_ACCOUNT')) {
        print('🔄 DEBUG LOGIN: Redirection vers /pending-account');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.goToPendingAccount();
          }
        });
        return;
      }

      if (errorMessage.contains('SUSPENDED_ACCOUNT')) {
        print('🔄 DEBUG LOGIN: Redirection vers /suspended-account');
        Future.delayed(Duration.zero, () {
          if (mounted) {
            try {
              context.go('/suspended-account');
              print('✅ DEBUG LOGIN: Redirection réussie vers /suspended-account');
            } catch (e) {
              print('❌ DEBUG LOGIN: Erreur redirection: $e');
            }
          }
        });
        return;
      }

      // Gestion spécifique des erreurs liées aux appareils
      if (errorMessage.contains("en attente")) {
        // L'appareil est en attente d'autorisation -> rediriger vers l'écran d'autorisation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              context.go('/device-authorization');
            } catch (e) {
              // En cas d'erreur de navigation, afficher un message
              AppUtils.showSnackBar(context, errorMessage, isError: true);
            }
          }
        });
      } else if (errorMessage.contains('suspendu')) {
        // L'appareil a été suspendu -> rediriger vers l'écran dédié aux appareils suspendus
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              context.go('/suspended-device');
            } catch (e) {
              AppUtils.showSnackBar(context, errorMessage, isError: true);
            }
          }
        });
      } else if (errorMessage.contains("Pas d'accès avec cet appareil")) {
        // Cas générique de refus d'accès avec cet appareil
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              context.go('/device-authorization');
            } catch (e) {
              AppUtils.showSnackBar(context, errorMessage, isError: true);
            }
          }
        });
      } else {
        // Pour les autres erreurs de connexion, afficher un message générique
        AppUtils.showSnackBar(
          context,
          errorMessage,
          isError: true,
        );
      }
    }
  }

  void _showDeviceAccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.block, color: Colors.red, size: 48),
          title: const Text(
            'Accès refusé',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Compris'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearSavedCredentials() async {
    try {
      await LocalStorageService.instance.clearLoginCredentials();
      if (mounted) {
        setState(() {
          _emailController.clear();
          _passwordController.clear();
          _rememberMe = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Informations sauvegardées effacées'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erreur lors de l\'effacement'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    try {
      context.push('/forgot-password');
    } catch (e) {
      print('❌ Erreur navigation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCredentials) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement des informations...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(
                0,
                MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    32,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gestion de Stock',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Connectez-vous à votre compte',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'votre@email.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir votre email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onFieldSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          hintText: 'Votre mot de passe',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir votre mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                              if (!_rememberMe) {
                                LocalStorageService.instance
                                    .clearLoginCredentials();
                              }
                            },
                          ),
                          const Flexible(child: Text('Se souvenir de moi')),
                          const Spacer(),
                          Flexible(
                            child: TextButton(
                              onPressed: _handleForgotPassword,
                              child: const Text('Mot de passe oublié ?'),
                            ),
                          ),
                        ],
                      ),
                      if (_rememberMe || _emailController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Center(
                            child: TextButton.icon(
                              onPressed: _clearSavedCredentials,
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text(
                                'Effacer les informations sauvegardées',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  authProvider.isLoading ? null : _handleLogin,
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text('Se connecter'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Pas encore de compte ?'),
                    TextButton(
                      onPressed: () => context.goToRegister(),
                      child: const Text("S'inscrire"),
                    ),
                  ],
                ),
                // Ajout d'un bouton pour l'accès à l'administration
               // const SizedBox(height: 8),
               // TextButton(
                //  onPressed: () => context.go('/admin-login'),
                 // child: Text(
                  //  'Accès Administration',
                   // style: TextStyle(
                    //  color: Colors.grey[600],
                     // fontSize: 12,
                   // ),
                 // ),
               // ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Version ${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
