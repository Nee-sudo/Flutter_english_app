import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LanguageSelectionDialog extends StatefulWidget {
  const LanguageSelectionDialog({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionDialog> createState() =>
      _LanguageSelectionDialogState();
}

class _LanguageSelectionDialogState extends State<LanguageSelectionDialog> {
  String? selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Select Language',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choose the language for your PDF download',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: AppSpacing.lg),
          _buildLanguageOption('english', '🇬🇧 English'),
          SizedBox(height: AppSpacing.md),
          _buildLanguageOption('hindi', '🇮🇳 हिंदी (Hindi)'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedLanguage == null
              ? null
              : () => Navigator.pop(context, selectedLanguage),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: const Text(
            'Download PDF',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: selectedLanguage == value ? AppColors.secondary : Colors.grey,
          width: selectedLanguage == value ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: selectedLanguage == value
            ? AppColors.secondary.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: RadioListTile<String>(
        title: Text(label),
        value: value,
        groupValue: selectedLanguage,
        onChanged: (newValue) {
          setState(() => selectedLanguage = newValue);
        },
        activeColor: AppColors.secondary,
      ),
    );
  }
}
