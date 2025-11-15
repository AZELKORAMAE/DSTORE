import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/admin_auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _adminService = AdminAuthService.instance;

  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  Map<String, dynamic>? _adminInfo;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    if (!_adminService.isAdminLoggedIn()) {
      if (mounted) {
        context.go('/admin-login');
      }
      return;
    }

    _adminInfo = _adminService.getAdminInfo();
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _adminService.getAllUsers();
      final stats = await _adminService.getAdminStats();

      setState(() {
        _users = users;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration - DStore'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Infos admin
          if (_adminInfo != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  _adminInfo!['full_name'] ?? 'Admin',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Bouton paramètres
          IconButton(
            onPressed: () => context.go('/admin-settings'),
            icon: const Icon(Icons.settings),
            tooltip: 'Paramètres',
          ),

          // Bouton déconnexion
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistiques
                    _buildStatsCards(),

                    const SizedBox(height: 24),

                    // Liste des utilisateurs
                    _buildUsersSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiques',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8, // Augmenté pour plus d'espace vertical
          children: [
            _buildStatCard(
              'Total Utilisateurs',
              _stats['total_users']?.toString() ?? '0',
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              'Actifs',
              _stats['active_users']?.toString() ?? '0',
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'En Attente',
              _stats['pending_users']?.toString() ?? '0',
              Icons.pending,
              Colors.orange,
            ),
            _buildStatCard(
              'Suspendus',
              _stats['suspended_users']?.toString() ?? '0',
              Icons.block,
              Colors.red,
            ),
            _buildActionCard(
              'Gestion Appareils',
              'Contrôler l\'accès',
              Icons.devices,
              Colors.purple,
              () => context.go('/admin/devices'),
            ),
            _buildActionCard(
              'Comptes/Appareils',
              'Gérer les accès',
              Icons.security,
              Colors.teal,
              () => context.go('/admin/simple-accounts'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12), // Réduit le padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Ajouté pour éviter l'overflow
          children: [
            Icon(
              icon,
              size: 28, // Réduit la taille de l'icône
              color: color,
            ),
            const SizedBox(height: 6), // Réduit l'espacement
            Flexible(
              // Ajouté pour gérer l'overflow
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20, // Réduit la taille de police
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2), // Réduit l'espacement
            Flexible(
              // Ajouté pour gérer l'overflow
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 11, // Réduit la taille de police
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2, // Permet 2 lignes maximum
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Utilisateurs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualiser',
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_users.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('Aucun utilisateur trouvé'),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return _buildUserCard(user);
            },
          ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final status = user['account_status'] ?? 'pending';
    final email = user['email'] ?? '';
    final fullName = user['full_name'] ?? 'Sans nom';
    final businessName = user['business_name'] ?? '';
    final subscriptionType = user['subscription_type'] ?? 'basic';
    final endDate = user['subscription_end_date'];
    final lastLogin = user['last_login_date'];

    final daysRemaining = _adminService.getDaysRemaining(endDate);
    final statusColor = Color(int.parse(
            _adminService.getStatusColor(status).substring(1),
            radix: 16) +
        0xFF000000);
    final statusIcon = _adminService.getStatusIcon(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête utilisateur
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor,
                  child: Text(
                    statusIcon,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (businessName.isNotEmpty)
                        Text(
                          businessName,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                // Statut
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Informations d'abonnement
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    'Type: ${subscriptionType.toUpperCase()}',
                    Icons.card_membership,
                  ),
                ),
                const SizedBox(width: 8),
                if (endDate != null)
                  Expanded(
                    child: _buildInfoChip(
                      daysRemaining > 0
                          ? '$daysRemaining jours restants'
                          : 'Expiré',
                      Icons.schedule,
                      color: daysRemaining > 7
                          ? Colors.green
                          : daysRemaining > 0
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
              ],
            ),

            if (lastLogin != null) ...[
              const SizedBox(height: 8),
              _buildInfoChip(
                'Dernière connexion: ${_adminService.formatDate(lastLogin)}',
                Icons.login,
              ),
            ],

            const SizedBox(height: 16),

            // Actions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildUserActions(user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color ?? Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserActions(Map<String, dynamic> user) {
    final userId = user['user_id'];
    final status = user['account_status'] ?? 'pending';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Actions principales
        if (status == 'pending')
          ElevatedButton.icon(
            onPressed: () => _showActivationDialog(userId),
            icon: const Icon(Icons.check_circle, size: 16),
            label: const Text('Activer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 32),
            ),
          ),

        if (status == 'active')
          ElevatedButton.icon(
            onPressed: () => _showSuspensionDialog(userId),
            icon: const Icon(Icons.block, size: 16),
            label: const Text('Suspendre'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 32),
            ),
          ),

        if (status == 'suspended')
          ElevatedButton.icon(
            onPressed: () => _reactivateUser(userId),
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Réactiver'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 32),
            ),
          ),

        // Actions secondaires
        if (status == 'active' || status == 'expired')
          OutlinedButton.icon(
            onPressed: () => _extendSubscription(userId),
            icon: const Icon(Icons.add_circle, size: 16),
            label: const Text('Prolonger'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 32),
            ),
          ),

        // Bouton de suppression (pour tous les statuts)
        OutlinedButton.icon(
          onPressed: () => _showDeleteDialog(userId, user['email']),
          icon: const Icon(Icons.delete, size: 16),
          label: const Text('Supprimer'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            minimumSize: const Size(0, 32),
          ),
        ),

        // Bouton d'édition
        OutlinedButton.icon(
          onPressed: () => _showEditDialog(userId, user),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Modifier'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 32),
          ),
        ),
      ],
    );
  }

  Future<void> _activateUser(String userId) async {
    final success = await _adminService.activateUser(userId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur activé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'activation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _suspendUser(String userId) async {
    final success = await _adminService.suspendUser(userId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur suspendu'),
          backgroundColor: Colors.orange,
        ),
      );
      await _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suspension'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _reactivateUser(String userId) async {
    final success = await _adminService.reactivateUser(userId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur réactivé'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la réactivation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _extendSubscription(String userId) async {
    // Dialogue pour choisir la durée
    final days = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prolonger l\'abonnement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('7 jours'),
              onTap: () => Navigator.of(context).pop(7),
            ),
            ListTile(
              title: const Text('30 jours'),
              onTap: () => Navigator.of(context).pop(30),
            ),
            ListTile(
              title: const Text('90 jours'),
              onTap: () => Navigator.of(context).pop(90),
            ),
            ListTile(
              title: const Text('365 jours'),
              onTap: () => Navigator.of(context).pop(365),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (days != null) {
      final success = await _adminService.extendSubscription(userId, days);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Abonnement prolongé de $days jours'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la prolongation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ==================== DIALOGUES D'ACTIONS ====================

  Future<void> _showActivationDialog(String userId) async {
    String selectedType = 'basic';
    int selectedDays = 30;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Activer le compte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choisissez le type d\'abonnement et la durée :'),
              const SizedBox(height: 16),

              // Type d'abonnement
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type d\'abonnement',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'basic', child: Text('Basique')),
                  DropdownMenuItem(value: 'premium', child: Text('Premium')),
                  DropdownMenuItem(
                      value: 'enterprise', child: Text('Entreprise')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Durée
              DropdownButtonFormField<int>(
                value: selectedDays,
                decoration: const InputDecoration(
                  labelText: 'Durée',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 7, child: Text('7 jours')),
                  DropdownMenuItem(value: 30, child: Text('30 jours')),
                  DropdownMenuItem(value: 90, child: Text('90 jours')),
                  DropdownMenuItem(value: 365, child: Text('365 jours')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedDays = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Activer'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final success = await _adminService.activateUser(
        userId,
        subscriptionType: selectedType,
        subscriptionDays: selectedDays,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte activé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'activation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showSuspensionDialog(String userId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspendre le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir suspendre ce compte ?\n\n'
          'L\'utilisateur ne pourra plus accéder à l\'application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Suspendre'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _adminService.suspendUser(userId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte suspendu'),
            backgroundColor: Colors.orange,
          ),
        );
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suspension'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(String userId, String email) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer définitivement le compte ?\n\n'
          'Email: $email\n\n'
          'Cette action est irréversible !',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _adminService.deleteUser(userId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur supprimé définitivement'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEditDialog(String userId, Map<String, dynamic> user) async {
    final emailController = TextEditingController(text: user['email']);
    final nameController = TextEditingController(text: user['full_name']);
    final businessController =
        TextEditingController(text: user['business_name']);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'utilisateur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: businessController,
                decoration: const InputDecoration(
                  labelText: 'Nom du commerce',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await _adminService.updateUser(
        userId,
        email: emailController.text.trim(),
        fullName: nameController.text.trim(),
        businessName: businessController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la modification'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    emailController.dispose();
    nameController.dispose();
    businessController.dispose();
  }

  Future<void> _signOut() async {
    await _adminService.signOutAdmin();
    if (mounted) {
      context.go('/login');
    }
  }

  Widget _buildActionCard(
      String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: color,
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
