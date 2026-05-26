import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tense_model.dart';
import '../models/story_model.dart';
import '../services/state_provider.dart';
import '../widgets/story_display.dart';
import '../widgets/paywall_modal.dart';
import '../utils/constants.dart';

class StoryViewScreen extends StatefulWidget {
  final Tense tense;

  const StoryViewScreen({
    Key? key,
    required this.tense,
  }) : super(key: key);

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  Story? _selectedStory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppStateProvider>();
      final stories = provider.getStoriesForTense(widget.tense.id);
      if (stories.isNotEmpty) {
        setState(() => _selectedStory = stories.first);
      }
    });
  }

  void _selectStory(Story story) {
    final provider = context.read<AppStateProvider>();
    if (!provider.canViewStory(story)) {
      _showPaywallModal(story);
      return;
    }
    setState(() => _selectedStory = story);
  }

  void _showPaywallModal(Story story) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaywallModal(story: story),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Consumer<AppStateProvider>(
      builder: (context, provider, _) {
        final stories = provider.getStoriesForTense(widget.tense.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '${widget.tense.emoji} ${widget.tense.name}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: isMobile
              ? _buildMobileLayout(stories, provider)
              : _buildDesktopLayout(stories, provider),
        );
      },
    );
  }

  Widget _buildMobileLayout(
    List<Story> stories,
    AppStateProvider provider,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Stories',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textDark,
                      ),
                ),
                SizedBox(height: AppSpacing.md),
                ...stories.map((story) => _buildStoryItem(story, provider)),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          if (_selectedStory != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: StoryDisplay(
                story: _selectedStory!,
                tense: widget.tense,
              ),
            ),
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    List<Story> stories,
    AppStateProvider provider,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: AppColors.surface,
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stories',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView.builder(
                    itemCount: stories.length,
                    itemBuilder: (_, i) => _buildStoryItem(stories[i], provider),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _selectedStory != null
              ? Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: StoryDisplay(
                    story: _selectedStory!,
                    tense: widget.tense,
                  ),
                )
              : const Center(
                  child: Text('Select a story to view'),
                ),
        ),
      ],
    );
  }

  Widget _buildStoryItem(
    Story story,
    AppStateProvider provider,
  ) {
    final canView = provider.canViewStory(story);
    final isSelected = _selectedStory?.id == story.id;

    return GestureDetector(
      onTap: () => _selectStory(story),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  if (story.isDemo)
                    Text(
                      '🎁 Demo',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white70 : AppColors.textLight,
                      ),
                    ),
                ],
              ),
            ),
            if (!canView)
              Icon(
                Icons.lock,
                color: isSelected ? Colors.white : AppColors.locked,
              ),
          ],
        ),
      ),
    );
  }
}

