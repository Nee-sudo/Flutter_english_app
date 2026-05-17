import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story_model.dart';
import '../services/state_provider.dart';
import '../utils/constants.dart';

class PaywallModal extends StatefulWidget {
  final Story story;

  const PaywallModal({
    Key? key,
    required this.story,
  }) : super(key: key);

  @override
  State<PaywallModal> createState() => _PaywallModalState();
}

class _PaywallModalState extends State<PaywallModal> {
  late TextEditingController _couponController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _couponController = TextEditingController();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon(BuildContext context) async {
    if (_couponController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a coupon code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<AppStateProvider>();
    final success = await provider.verifyCoupon(_couponController.text);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ All stories unlocked!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${provider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            Center(
              child: Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.locked.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: AppColors.locked,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            Center(
              child: Text(
                'Premium Content',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),

            Center(
              child: Text(
                'Enter your coupon code to unlock all stories',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            TextField(
              controller: _couponController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Enter coupon code',
                prefixIcon: const Icon(Icons.confirmation_number),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '💡 Tip: Try "NEER50" for access',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _applyCoupon(context),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.lock_open),
              label: Text(_isLoading ? 'Verifying...' : 'Unlock All Stories'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                disabledBackgroundColor: AppColors.border,
              ),
            ),

            SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

