import 'package:flutter/material.dart';
import 'package:book_tracker/providers/user_auth_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Introduction'),
            _buildParagraph(
              'Welcome to Book Tracker. We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.'
            ),
            
            _buildSectionTitle('Information We Collect'),
            _buildParagraph(
              'We collect the following types of information:'
            ),
            _buildBulletPoint('Account information: email address and password when you register'),
            _buildBulletPoint('Reading data: books you add, reading progress, and reading goals'),
            _buildBulletPoint('User preferences: app settings and theme preferences'),
            _buildBulletPoint('Usage data: how you interact with the app and features you use'),
            
            _buildSectionTitle('How We Use Your Information'),
            _buildParagraph(
              'We use your information to:'
            ),
            _buildBulletPoint('Provide and maintain our service'),
            _buildBulletPoint('Personalize your experience'),
            _buildBulletPoint('Improve our application'),
            _buildBulletPoint('Generate reading analytics and statistics'),
            _buildBulletPoint('Communicate with you about updates and features'),
            
            _buildSectionTitle('Data Storage and Security'),
            _buildParagraph(
              'Your reading data is stored locally on your device. If you choose to create an account, your reading data can be backed up to our secure cloud servers. We implement appropriate security measures to protect against unauthorized access or alteration of your data.'
            ),
            
            _buildSectionTitle('Third-Party Services'),
            _buildParagraph(
              'Our application may use third-party services such as Firebase for authentication and data storage. These services have their own privacy policies, and we recommend reviewing them.'
            ),
            
            _buildSectionTitle('Your Rights'),
            _buildParagraph('You have the right to:'),
            _buildBulletPoint('Access the personal data we hold about you'),
            _buildBulletPoint('Request correction of your personal data'),
            _buildBulletPoint('Request deletion of your data'),
            _buildBulletPoint('Opt out of marketing communications'),
            _buildBulletPoint('Export your reading data'),
            
            _buildSectionTitle('Children\'s Privacy'),
            _buildParagraph(
              'Our application is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.'
            ),
            
            _buildSectionTitle('Changes to This Privacy Policy'),
            _buildParagraph(
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.'
            ),
            
            _buildSectionTitle('Contact Us'),
            _buildParagraph(
              'If you have any questions about this Privacy Policy, please contact us at support@booktracker.com'
            ),
            
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Last Updated: May 2023',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
} 