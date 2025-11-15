import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../services/password_reset_service.dart';

class VerifyResetCodePage extends StatefulWidget {
  final String email;
  
  const VerifyResetCodePage({super.key, required this.email});

  @override
  State<VerifyResetCodePage> createState() => _VerifyResetCodePageState();
}

class _VerifyResetCodePageState extends State<VerifyResetCodePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordResetService = PasswordResetService();
  
  bool _isLoading = false;
  int _remainingTime = 60; // 1 minute
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _passwordResetService.verifyCode(
        widget.email,
        _codeController.text.trim(),
      );

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code vérifié avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Naviguer vers la page de nouveau mot de passe
          context.pushReplacement('/reset-password', extra: {
            'email': widget.email,
            'userId': result['user_id'],
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Code invalide'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
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
      _isLoading = true;
      _remainingTime = 60;
    });

    try {
      final success = await _passwordResetService.sendVerificationCode(widget.email);
      
      if (success) {
        _startTimer();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nouveau code envoyé'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors du renvoi du code'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
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

  String get _formattedTime {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification du code'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // Icône
              const Icon(
                Icons.verified_user,
                size: 80,
                color: Colors.blue,
              ),
              
              const SizedBox(height: 24),
              
              // Titre
              const Text(
                'Vérification du code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Entrez le code de vérification envoyé à:\n${widget.email}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Champ code
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  labelText: 'Code de vérification',
                  hintText: '123456',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le code';
                  }
                  if (value.length != 6) {
                    return 'Le code doit contenir 6 chiffres';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Timer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _remainingTime > 0 ? Colors.green.shade50 : Colors.red.shade50,
                  border: Border.all(
                    color: _remainingTime > 0 ? Colors.green.shade200 : Colors.red.shade200,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _remainingTime > 0 ? Icons.timer : Icons.timer_off,
                      color: _remainingTime > 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _remainingTime > 0 
                          ? 'Temps restant: $_formattedTime'
                          : 'Code expiré',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _remainingTime > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Bouton vérifier
              ElevatedButton(
                onPressed: (_isLoading || _remainingTime <= 0) ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Vérifier le code',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Bouton renvoyer
              TextButton(
                onPressed: (_isLoading || _remainingTime > 0) ? null : _resendCode,
                child: const Text('Renvoyer le code'),
              ),
              
              const SizedBox(height: 16),
              
              // Bouton retour
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
