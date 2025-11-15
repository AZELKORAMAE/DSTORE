import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;

  // Timer pour l'expiration du code
  Timer? _timer;
  int _remainingSeconds = 120; // 2 minutes = 120 secondes
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _checkForCodeInUrl();
  }

  // Vérifier si un code est présent dans l'URL (depuis l'email)
  void _checkForCodeInUrl() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = Uri.base;
      final codeFromUrl = uri.queryParameters['code'];

      if (codeFromUrl != null && codeFromUrl.length == 6) {
        // Remplir automatiquement les champs avec le code de l'URL
        for (int i = 0; i < 6; i++) {
          _controllers[i].text = codeFromUrl[i];
        }
        setState(() {});

        // Vérifier automatiquement le code
        Future.delayed(const Duration(milliseconds: 500), () {
          _verifyCode();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isExpired = true;
          timer.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification du code'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icône et titre
                const Icon(
                  Icons.mark_email_read,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),

                const Text(
                  'Code de vérification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Nous avons envoyé un code de vérification à 6 chiffres à',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Si vous recevez un lien par email, cliquez dessus pour remplir automatiquement le code, ou copiez les 6 chiffres du code depuis l\'email.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Timer d'expiration
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isExpired ? Colors.red[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isExpired ? Colors.red : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isExpired ? Icons.timer_off : Icons.timer,
                        size: 16,
                        color: _isExpired ? Colors.red : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isExpired
                            ? 'Code expiré'
                            : 'Expire dans ${_formatTime(_remainingSeconds)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _isExpired ? Colors.red : Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Champs de saisie du code
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => _buildCodeField(index)),
                ),

                const SizedBox(height: 32),

                // Bouton de vérification
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Vérifier le code',
                          style: TextStyle(fontSize: 16),
                        ),
                ),

                const SizedBox(height: 16),

                // Bouton renvoyer le code
                TextButton(
                  onPressed: _isResending ? null : _resendCode,
                  child: _isResending
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Renvoyer le code'),
                ),

                const SizedBox(height: 8),

                // Bouton retour
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Retour à la connexion'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeField(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: _controllers[index].text.isNotEmpty
              ? Colors.blue
              : Colors.grey[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          setState(() {});

          if (value.isNotEmpty) {
            // Passer au champ suivant
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Dernier champ, vérifier automatiquement
              _verifyCode();
            }
          } else {
            // Revenir au champ précédent si on efface
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
        onTap: () {
          // Sélectionner tout le texte quand on clique
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          );
        },
      ),
    );
  }

  String _getCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  bool _isCodeComplete() {
    return _getCode().length == 6;
  }

  Future<void> _verifyCode() async {
    if (_isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le code a expiré. Veuillez demander un nouveau code.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isCodeComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir le code complet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final code = _getCode();

      final isValid = await authProvider.verifyResetCode(widget.email, code);

      if (isValid && mounted) {
        // Code valide, rediriger vers la page de réinitialisation
        context.go('/reset-password?email=${widget.email}&verified=true');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code invalide ou expiré'),
            backgroundColor: Colors.red,
          ),
        );

        // Effacer les champs
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resetPassword(widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code renvoyé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        // Effacer les champs
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();

        // Redémarrer le timer
        _timer?.cancel();
        setState(() {
          _remainingSeconds = 120;
          _isExpired = false;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }
}
