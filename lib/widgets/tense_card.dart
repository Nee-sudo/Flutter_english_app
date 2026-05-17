import 'package:flutter/material.dart';
import '../models/tense_model.dart';
import '../screens/story_view_screen.dart';
import '../utils/constants.dart';

class TenseCard extends StatelessWidget {
  final Tense tense;

  const TenseCard({
    Key? key,
    required this.tense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryViewScreen(tense: tense),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.accent.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tense.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                tense.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                tense.description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

