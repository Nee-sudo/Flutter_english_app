import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../models/tense_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class StoryDisplay extends StatefulWidget {
  final Story story;
  final Tense? tense;

  const StoryDisplay({
    Key? key,
    required this.story,
    this.tense,
  }) : super(key: key);

  @override
  State<StoryDisplay> createState() => _StoryDisplayState();
}

class _StoryDisplayState extends State<StoryDisplay> {
  bool _showEnglish = true;
  bool _isDownloading = false;

  Future<void> _downloadPdf() async {
    setState(() => _isDownloading = true);
    
    final language = _showEnglish ? 'english' : 'hindi';
    final result = await ApiService().generatePdf(
      language,
      tenseId: widget.tense?.id,
    );

    if (mounted) {
      setState(() => _isDownloading = false);
      
      final snackBar = SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.story.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _showEnglish = true),
                  icon: const Icon(Icons.language),
                  label: const Text('English'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showEnglish
                        ? AppColors.primary
                        : AppColors.border,
                    foregroundColor: _showEnglish
                        ? Colors.white
                        : AppColors.textDark,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _showEnglish = false),
                  icon: const Icon(Icons.translate),
                  label: const Text('हिंदी'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_showEnglish
                        ? AppColors.secondary
                        : AppColors.border,
                    foregroundColor: !_showEnglish
                        ? Colors.white
                        : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          ElevatedButton.icon(
            onPressed: _isDownloading ? null : _downloadPdf,
            icon: _isDownloading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _showEnglish ? Colors.white : Colors.white,
                      ),
                    ),
                  )
                : const Icon(Icons.download),
            label: Text(_isDownloading ? 'Downloading...' : 'Download PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _showEnglish
                  ? AppColors.primary
                  : AppColors.secondary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.lg,
              ),
              disabledBackgroundColor: AppColors.border,
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _showEnglish ? widget.story.englishText : widget.story.hindiText,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                height: 1.8,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}

