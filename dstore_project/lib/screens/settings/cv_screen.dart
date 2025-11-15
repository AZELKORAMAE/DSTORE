import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_theme.dart';

class CVScreen extends StatelessWidget {
  const CVScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV - DAKI ELKORAMAME'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareCV(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadCV(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context),
            
            // Contact Section
            _buildContactSection(context),
            
            // Profile Section
            _buildProfileSection(context),
            
            // Experience Section
            _buildExperienceSection(context),
            
            // Education Section
            _buildEducationSection(context),
            
            // Skills Section
            _buildSkillsSection(context),
            
            // Projects Section
            _buildProjectsSection(context),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryVariant,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Name
            Text(
              'DAKI ELKORAMAME',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Title
            Text(
              'Ingénieur Systèmes d\'Information & Data Science',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_phone, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Contact',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              context,
              Icons.phone,
              '+212 639700653',
              () => _launchUrl('tel:+212639700653'),
            ),
            _buildContactItem(
              context,
              Icons.email,
              'azelkoramame@gmail.com',
              () => _launchUrl('mailto:azelkoramame@gmail.com'),
            ),
            _buildContactItem(
              context,
              Icons.location_on,
              'Rabat, Maroc',
              null,
            ),
            _buildContactItem(
              context,
              Icons.work,
              'LinkedIn: DAKI AZ ELKORAMAME',
              () => _launchUrl('https://linkedin.com/in/daki-elkoramame'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String text, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (onTap != null)
              Icon(Icons.open_in_new, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Profil',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ingénieur en Systèmes d\'Information et Transformation Digitale, passionné par la data science, le machine learning et le développement de solutions numériques intelligentes. Doté d\'une solide formation en ingénierie logicielle, traitement de données et automatisation des processus. Autonome, rigoureux et curieux, je m\'investis dans des projets alliant analyse de données, modélisation prédictive et visualisation interactive pour soutenir la prise de décision.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work_outline, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Expérience Professionnelle',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // SAFRAN 2025
            _buildExperienceItem(
              context,
              'Gestion des compétences',
              'SAFRAN ENGINEERING SERVICES',
              'FÉV. 2025 - AOÛT 2025',
              [
                'Conception et réalisation d\'une application web capable de récupérer les données depuis des fichiers Excel',
                'Analyse en temps réel des niveaux de compétences selon des indicateurs personnalisés',
                'Mise en place de tableaux de bord interactifs pour la prise de décision',
                'Intégration de modèles de machine learning et système d\'accès par rôles'
              ],
              ['Python', 'Streamlit', 'SQLite', 'Excel Automation', 'Machine Learning', 'Cryptage'],
            ),
            
            const SizedBox(height: 16),
            
            // SAFRAN 2024
            _buildExperienceItem(
              context,
              'Gestion automatisée des workflows',
              'SAFRAN ENGINEERING SERVICES',
              'AOÛT 2024 - SEPT 2024',
              [
                'Développement d\'une application de tests d\'acceptation avec gestion des erreurs en temps réel',
                'Développement d\'une plateforme de gestion des connaissances',
                'Amélioration du partage d\'informations et de la prise de décision'
              ],
              ['Python', 'Django', 'React', 'PostgreSQL', 'Docker', 'REST APIs', 'CI/CD'],
            ),
            
            const SizedBox(height: 16),
            
            // Capgemini
            _buildExperienceItem(
              context,
              'Gestion des stagiaires',
              'Capgemini Engineering',
              'JUILLET 2023 - AOÛT 2023',
              [
                'Application web de gestion des stagiaires et plateforme de candidature en ligne',
                'Interface utilisateur intuitive pour la gestion des dossiers stagiaires',
                'Système de candidature en ligne avec suivi des demandes'
              ],
              ['ReactJS', 'VueJS', 'Django', 'NodeJS', 'PostgreSQL', 'MySQL', 'JWT', 'OAuth', 'AWS'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceItem(
    BuildContext context,
    String title,
    String company,
    String period,
    List<String> descriptions,
    List<String> technologies,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  period,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Descriptions
          ...descriptions.map((desc) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    desc,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          )),

          const SizedBox(height: 12),

          // Technologies
          Text(
            'Technologies:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: technologies.map((tech) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
              ),
              child: Text(
                tech,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school_outlined, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Formation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildEducationItem(
              context,
              '2022 - PRÉSENT',
              'Étudiant en ingénierie des systèmes d\'information et transformation digitale',
              'École des sciences d\'information',
            ),

            const SizedBox(height: 12),

            _buildEducationItem(
              context,
              '2020 - 2022',
              'Classes préparatoires filière MP',
              'Lycée Mohammed Khider',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationItem(BuildContext context, String period, String degree, String school) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            degree,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            school,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings_outlined, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Compétences',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSkillCategory(
              context,
              'Data Science & IA',
              Icons.analytics_outlined,
              ['Python', 'Pandas', 'NumPy', 'Scikit-learn', 'Matplotlib', 'Machine Learning', 'Analyse de données'],
            ),

            _buildSkillCategory(
              context,
              'Programmation',
              Icons.code_outlined,
              ['Python', 'Java', 'C', 'PHP', 'Dart', 'Solidity', 'JavaScript', 'SQL', 'MySQL'],
            ),

            _buildSkillCategory(
              context,
              'Développement Web',
              Icons.web_outlined,
              ['HTML', 'CSS', 'JavaScript', 'PHP', 'Streamlit', 'CMS'],
            ),

            _buildSkillCategory(
              context,
              'Mobile',
              Icons.phone_android_outlined,
              ['Flutter', 'React Native'],
            ),

            _buildSkillCategory(
              context,
              'Bases de données',
              Icons.storage_outlined,
              ['MySQL', 'SQL Server', 'Oracle', 'MongoDB Atlas', 'Firebase'],
            ),

            _buildSkillCategory(
              context,
              'Cloud & DevOps',
              Icons.cloud_outlined,
              ['Microsoft Azure', 'AWS S3', 'AWS Lambda', 'AWS Amplify', 'Google Cloud'],
            ),

            _buildSkillCategory(
              context,
              'Langues',
              Icons.language_outlined,
              ['Français (courant)', 'Anglais (professionnel)', 'Arabe (natif)'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillCategory(BuildContext context, String title, IconData icon, List<String> skills) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: skills.map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Text(
                skill,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_outlined, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Projets Académiques',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildProjectItem(
              context,
              'Application web de Gestion Automatisée de Fichiers avec AWS et GCP',
              'Système de gestion de fichiers basé sur le cloud pour l\'analyse automatisée des données et la classification. Intégration d\'AWS S3 et Google Cloud Vision API.',
              ['Python', 'Flask', 'AWS S3', 'Google Cloud Vision API', 'Machine Learning'],
            ),

            const SizedBox(height: 12),

            _buildProjectItem(
              context,
              'Chatbot d\'Assistance Médicale Multilingue avec IA',
              'Conception et développement d\'un chatbot spécialisé en assistance médicale d\'urgence utilisant l\'IA pour fournir des données de santé.',
              ['Python', 'NLP', 'Machine Learning', 'Flask'],
            ),

            const SizedBox(height: 12),

            _buildProjectItem(
              context,
              'Prédiction de la Santé Cardiaque',
              'Application de modèles de machine learning pour prédire les maladies cardiovasculaires.',
              ['Python', 'Scikit-learn', 'XGBoost', 'Pandas', 'Matplotlib'],
            ),

            const SizedBox(height: 12),

            _buildProjectItem(
              context,
              'Data Visualisation et PowerBI Machine Learning',
              'Analyse de la santé mentale des étudiants universitaires et prédiction des crises cardiaques.',
              ['Power BI', 'Python', 'Machine Learning', 'Data Analysis'],
            ),

            const SizedBox(height: 12),

            _buildProjectItem(
              context,
              'Application de Gestion de Livres en JavaFX',
              'Développement d\'une application de gestion de livres et utilisateurs avec fonctionnalités de bibliothèque.',
              ['Java', 'JavaFX', 'MySQL'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectItem(BuildContext context, String title, String description, List<String> technologies) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: technologies.map((tech) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.info.withOpacity(0.3)),
              ),
              child: Text(
                tech,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.info,
                  fontSize: 10,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  void _shareCV(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de partage en cours de développement'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _downloadCV(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de téléchargement en cours de développement'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Handle error silently
    }
  }
}
