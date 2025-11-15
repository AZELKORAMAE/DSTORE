

import 'package:flutter/material.dart';
import 'services/subscription_service.dart';
import 'services/local_storage_service.dart';

class TestSubscriptionScreen extends StatefulWidget {
  @override
  _TestSubscriptionScreenState createState() => _TestSubscriptionScreenState();
}

class _TestSubscriptionScreenState extends State<TestSubscriptionScreen> {
  String _result = 'Appuyez sur le bouton pour tester';
  bool _isLoading = false;

  Future<void> _testSubscription() async {
    setState(() {
      _isLoading = true;
      _result = 'Test en cours...';
    });

    try {

      final email = await LocalStorageService.instance.getUserEmail();
      print('📧 Email récupéré: $email');

      final status = await SubscriptionService.instance.checkSubscriptionStatus();
      print('📊 Statut: $status');

      final canAccess = await SubscriptionService.instance.canAccessApp();
      print('🔑 Peut accéder: $canAccess');

      setState(() {
        _result = '''
Email: $email
Statut: $status
Peut accéder: $canAccess
        ''';
      });
    } catch (e) {
      print('❌ Erreur test: $e');
      setState(() {
        _result = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Subscription Service'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testSubscription,
              child: _isLoading 
                ? CircularProgressIndicator()
                : Text('Tester le Service d\'Abonnement'),
            ),
            SizedBox(height: 20),
            Text(
              _result,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
