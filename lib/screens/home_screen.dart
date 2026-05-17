import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/state_provider.dart';
import '../widgets/tense_card.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text(
          '📖 Language Stories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learn English Tenses',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Click on a tense to explore stories',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),

                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: provider.isUnlocked
                          ? AppColors.secondary
                          : AppColors.locked,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          provider.isUnlocked
                              ? Icons.check_circle
                              : Icons.lock,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            provider.isUnlocked
                                ? '✨ Premium unlocked! Full access enabled.'
                                : '🔒 Demo stories only. Enter coupon to unlock.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: isMobile ? 1.0 : 1.2,
                    ),
                    itemCount: provider.tenses.length,
                    itemBuilder: (context, index) {
                      return TenseCard(tense: provider.tenses[index]);
                    },
                  ),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

