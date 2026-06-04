import 'package:flutter/material.dart';

import '../utils/constants.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false),
        ),
        title: const Text('Policy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy (Placeholder)',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'This page is currently a placeholder. Replace this content with your official privacy policy and terms. '
                  'Typical sections include: what data is collected, how it is used, sharing/retention, user rights, and contact information.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textLight),
                ),
                SizedBox(height: AppSpacing.lg),

                _SectionTitle(title: '1. Information we collect'),
                _SectionBody(
                  'If you use the coupon/unlock flow, the app may store a locally generated user state in your browser. '
                  'Server-side analytics may also be tracked via backend endpoints.',
                ),

                _SectionTitle(title: '2. How we use information'),
                _SectionBody(
                  'We use collected data to provide access to stories, verify coupons, and improve content and performance.',
                ),

                _SectionTitle(title: '3. Cookies & local storage'),
                _SectionBody(
                  'The app may use local storage to remember unlocked state. You can clear site data in your browser to reset access.',
                ),

                _SectionTitle(title: '4. Third-party services'),
                _SectionBody(
                  'If applicable, we may use analytics or hosting providers. Replace this section with your real vendors.',
                ),

                _SectionTitle(title: '5. Contact'),
                _SectionBody(
                  'For policy questions, contact us at: <your-email@example.com>.',
                ),

                SizedBox(height: AppSpacing.xl),
                Center(
                  child: Text(
                    'Last updated: YYYY-MM-DD',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textLight),
                    textAlign: TextAlign.center,
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String text;

  const _SectionBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 0, right: 0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textLight),
      ),
    );
  }
}

