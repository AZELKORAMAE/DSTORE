import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import 'dart:async';

class VerifyResetCodeScreen extends StatefulWidget {
  final String email;
  
  const VerifyResetCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _canResend = false;
  int _countdown = 60; // 1 minute
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _canResend = false;
    _countdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verifyCode() async {
    final code = _code;
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer le code complet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('🔄 Vérification du code: $code pour ${widget.email}');

    setState(() {
      _isLoading = true;
    });

    try {
      // Vérifier le code via AuthService
      final isValid = await AuthService.instance.verifyPasswordResetCode(widget.email, code);
      
      if (isValid) {
        print('✅ Code valide');
        if (mounted) {
          // Naviguer vers la page de nouveau mot de passe
          context.pushReplacement('/reset-password', extra: {
            'email': widget.email,
            'code': code,
          });
        }
      } else {
        print('❌ Code invalide');
        if (mounted) {
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
      }
    } catch (e) {
      print('❌ Erreur vérification: $e');
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
    print('🔄 Renvoi du code à: ${widget.email}');
    
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.instance.sendPasswordResetCode(widget.email);
      
      print('✅ Code renvoyé avec succès');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nouveau code envoyé'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Effacer les champs et redémarrer le countdown
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
        _startCountdown();
      }
    } catch (e) {
      print('❌ Erreur renvoi: $e');
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

  Widget _buildCodeInput(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          
          // Auto-vérifier quand tous les champs sont remplis
          if (_code.length == 6) {
            _verifyCode();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            
            // Icône
            const Icon(
              Icons.security,
              size: 80,
              color: Colors.blue,
            ),
            
            const SizedBox(height: 32),
            
            // Titre
            const Text(
              'Code de vérification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              'Entrez le code à 6 chiffres envoyé à\n${widget.email}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Champs de code
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _buildCodeInput(index)),
            ),
            
            const SizedBox(height: 32),
            
            // Bouton de vérification
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Vérifier le code',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Bouton de renvoi
            TextButton(
              onPressed: _canResend && !_isLoading ? _resendCode : null,
              child: Text(
                _canResend 
                    ? 'Renvoyer le code'
                    : 'Renvoyer dans ${_countdown}s',
                style: TextStyle(
                  color: _canResend ? Colors.blue : Colors.grey,
                ),
              ),
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
    );
  }
}
