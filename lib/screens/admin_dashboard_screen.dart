import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/story_model.dart';
import '../models/tense_model.dart';
import '../services/admin_api_service.dart';
import '../services/state_provider.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required this.adminKey});

  final String adminKey;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _api = AdminApiService();

  bool _loading = true;
  String? _error;

  List<Tense> _tenses = [];
  Tense? _selectedTense;
  List<Story> _stories = [];

  final _titleCtrl = TextEditingController();
  final _englishCtrl = TextEditingController();
  final _hindiCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  bool _isDemo = true;

  // PDF Stats
  Map<String, dynamic>? _pdfStats;
  bool _loadingPdfStats = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
    _loadPdfStats();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _englishCtrl.dispose();
    _hindiCtrl.dispose();
    _categoryCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _syncPublicContent() async {
    if (!mounted) return;
    await context.read<AppStateProvider>().reloadContent();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tensesJson = await _api.listAdminTenses(widget.adminKey);
      _tenses = tensesJson.map((e) => Tense.fromJson(e)).toList();
      _selectedTense = _tenses.isNotEmpty ? _tenses.first : null;
      if (_selectedTense != null) {
        await _refreshStories();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadPdfStats() async {
    setState(() => _loadingPdfStats = true);
    try {
      final stats = await _api.getPdfStats();
      if (mounted) {
        setState(() => _pdfStats = stats);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load PDF stats: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingPdfStats = false);
      }
    }
  }

  Future<void> _refreshStories() async {
    if (_selectedTense == null) return;

    final storiesJson = await _api.listAdminStories(
      widget.adminKey,
      tenseId: _selectedTense!.id,
    );

    if (!mounted) return;
    setState(() {
      _stories = storiesJson.map((e) => Story.fromJson(e)).toList();
    });
  }

  Future<void> _afterMutation(String message) async {
    await _refreshStories();
    await _syncPublicContent();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.secondary),
    );
  }

  Future<void> _createStory() async {
    if (_selectedTense == null) return;

    final title = _titleCtrl.text.trim();
    final english = _englishCtrl.text.trim();
    final hindi = _hindiCtrl.text.trim();

    if (title.isEmpty || english.isEmpty || hindi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title, English and Hindi are required')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _api.createStory(
        widget.adminKey,
        tenseId: _selectedTense!.id,
        title: title,
        englishText: english,
        hindiText: hindi,
        isDemo: _isDemo,
        category: _categoryCtrl.text.trim().isEmpty
            ? null
            : _categoryCtrl.text.trim(),
      );

      _titleCtrl.clear();
      _englishCtrl.clear();
      _hindiCtrl.clear();
      _categoryCtrl.clear();
      setState(() => _isDemo = true);

      await _afterMutation('Story created');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteStory(String storyId) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete story?'),
            content: const Text('This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    setState(() => _loading = true);
    try {
      await _api.deleteStory(widget.adminKey, storyId: storyId);
      await _afterMutation('Story deleted');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editStory(Story story) async {
    final titleCtrl = TextEditingController(text: story.title);
    final englishCtrl = TextEditingController(text: story.englishText);
    final hindiCtrl = TextEditingController(text: story.hindiText);
    final categoryCtrl = TextEditingController(text: story.category ?? '');

    bool isDemo = story.isDemo;

    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit story'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: englishCtrl,
                    decoration: const InputDecoration(
                      labelText: 'English text',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 6,
                    minLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: hindiCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Hindi text (हिंदी)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 6,
                    minLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: categoryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Category (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Demo story (free for all users)'),
                    value: isDemo,
                    onChanged: (v) =>
                        setDialogState(() => isDemo = v ?? true),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (save != true) {
      titleCtrl.dispose();
      englishCtrl.dispose();
      hindiCtrl.dispose();
      categoryCtrl.dispose();
      return;
    }

    final title = titleCtrl.text.trim();
    final english = englishCtrl.text.trim();
    final hindi = hindiCtrl.text.trim();
    final category = categoryCtrl.text.trim();

    titleCtrl.dispose();
    englishCtrl.dispose();
    hindiCtrl.dispose();
    categoryCtrl.dispose();

    if (title.isEmpty || english.isEmpty || hindi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title, English and Hindi are required')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _api.updateStory(
        widget.adminKey,
        storyId: story.id,
        title: title,
        englishText: english,
        hindiText: hindi,
        isDemo: isDemo,
        category: category.isEmpty ? null : category,
        tenseId: story.tenseId,
      );
      await _afterMutation('Story updated');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final storage = StorageService();
    await storage.init();
    await storage.clearAdminKey();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/adminLogin', (r) => false);
  }

  String _preview(String text, {int max = 80}) {
    if (text.length <= max) return text;
    return '${text.substring(0, max)}…';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Admin — Manage Stories & Analytics',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Stories'),
            Tab(text: 'PDF Downloads'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loading ? null : _load,
          ),
          IconButton(
            tooltip: 'Back to app',
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Stories Tab
          _buildStoriesTab(isMobile),
          // PDF Downloads Tab
          _buildPdfStatsTab(),
        ],
      ),
    );
  }

  Widget _buildStoriesTab(bool isMobile) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.all(
                  isMobile ? AppSpacing.md : AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add, edit, or delete English and Hindi story text. Changes sync to the public app immediately.',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Tense>(
                      initialValue: _selectedTense,
                      decoration: const InputDecoration(
                        labelText: 'Tense',
                        border: OutlineInputBorder(),
                      ),
                      items: _tenses
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text('${t.emoji} ${t.name}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) async {
                        setState(() {
                          _selectedTense = v;
                          _stories = [];
                        });
                        await _refreshStories();
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: isMobile
                          ? ListView(
                              children: [
                                _buildCreateCard(),
                                const SizedBox(height: 16),
                                _buildStoriesCard(),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildCreateCard()),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: _buildStoriesCard()),
                              ],
                            ),
                    ),
                  ],
                ),
              );
  }

  Widget _buildPdfStatsTab() {
    return _loadingPdfStats
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: _pdfStats == null
                ? const Center(
                    child: Text('Failed to load PDF statistics'),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PDF Download Statistics',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 24),
                        // Total Downloads Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total PDF Downloads',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  (_pdfStats!['totalDownloads'] ?? 0)
                                      .toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // By Language Stats
                        Text(
                          'Downloads by Language',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ..._buildLanguageStats(),
                        const SizedBox(height: 24),
                        // Recent Downloads
                        Text(
                          'Recent Downloads',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        _buildRecentDownloads(),
                      ],
                    ),
                  ),
          );
  }

  List<Widget> _buildLanguageStats() {
    final byLanguage =
        (_pdfStats!['byLanguage'] as List<dynamic>?) ?? [];

    if (byLanguage.isEmpty) {
      return [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No downloads yet')),
          ),
        ),
      ];
    }

    return byLanguage.map<Widget>((stat) {
      final lang =
          (stat['_id'] as String?)?.toUpperCase() ?? 'Unknown';
      final count = (stat['count'] as num?)?.toInt() ?? 0;
      final avgStoryCount =
          (stat['avgStoryCount'] as num?)?.toDouble() ?? 0;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: lang == 'ENGLISH'
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    lang == 'ENGLISH' ? '🇬🇧' : '🇮🇳',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Downloads: $count | Avg Stories: ${avgStoryCount.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildRecentDownloads() {
    final recentDownloads =
        (_pdfStats!['recentDownloads'] as List<dynamic>?) ?? [];

    if (recentDownloads.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No recent downloads')),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentDownloads.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) {
          final download = recentDownloads[index] as Map<dynamic, dynamic>;
          final language =
              (download['language'] as String?)?.toUpperCase() ?? 'Unknown';
          final storyCount =
              (download['storyCount'] as num?)?.toInt() ?? 0;
          final createdAt = (download['createdAt'] as String?) ?? 'Unknown';

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  language == 'ENGLISH' ? '🇬🇧' : '🇮🇳',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$language - $storyCount stories',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        createdAt,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add new story',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _englishCtrl,
              decoration: const InputDecoration(
                labelText: 'English text',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              minLines: 3,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _hindiCtrl,
              decoration: const InputDecoration(
                labelText: 'Hindi text (हिंदी)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              minLines: 3,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(
                labelText: 'Category (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Demo story'),
              value: _isDemo,
              onChanged: (v) => setState(() => _isDemo = v ?? true),
            ),
            ElevatedButton.icon(
              onPressed: _loading ? null : _createStory,
              icon: const Icon(Icons.add),
              label: const Text('Create story'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Stories (${_stories.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _stories.isEmpty
                  ? const Center(child: Text('No stories for this tense'))
                  : ListView.separated(
                      itemCount: _stories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final s = _stories[i];
                        return Card(
                          color: s.isDemo
                              ? Colors.amber.withValues(alpha: 0.08)
                              : Colors.green.withValues(alpha: 0.06),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        s.isDemo ? 'Demo' : 'Premium',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    IconButton(
                                      tooltip: 'Edit English & Hindi',
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editStory(s),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete',
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteStory(s.id),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'EN: ${_preview(s.englishText)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'HI: ${_preview(s.hindiText)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
