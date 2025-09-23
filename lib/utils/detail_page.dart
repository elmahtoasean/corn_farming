import 'dart:math' as math;

import 'package:corn_farming/controller/theme_controller.dart';
import 'package:corn_farming/utils/corn_header.dart';
import 'package:corn_farming/utils/tts_utils.dart';
import 'package:corn_farming/widgets/narration_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CornDetailSection {
  final IconData icon;
  final String titleKey;
  final String descriptionKey;
  final List<String> highlightKeys;

  const CornDetailSection({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    this.highlightKeys = const [],
  });
}

class CornTimelineItem {
  final String titleKey;
  final String detailKey;

  const CornTimelineItem({required this.titleKey, required this.detailKey});
}

typedef CornSupplementBuilder = Widget Function(
    BuildContext context, double maxWidth);

double _clampDimension(double value, double lower, double upper) {
  if (value.isNaN || value.isInfinite) {
    return upper;
  }
  var minValue = lower;
  var maxValue = upper;
  if (minValue > maxValue) {
    final swap = minValue;
    minValue = maxValue;
    maxValue = swap;
  }
  if (value < minValue) {
    return minValue;
  }
  if (value > maxValue) {
    return maxValue;
  }
  return value;
}

class CornDetailPage extends StatefulWidget {
  final String titleKey;
  final String introKey;
  final List<CornDetailSection> sections;
  final List<CornTimelineItem> timeline;
  final List<String> quickTipKeys;
  final IconData accentIcon;
  final List<String> resourceKeys;
  final String? videoId;
  final List<CornSupplementBuilder> supplementalBuilders;
  final List<String> additionalNarrationKeys;

  const CornDetailPage({
    super.key,
    required this.titleKey,
    required this.introKey,
    required this.sections,
    required this.timeline,
    required this.quickTipKeys,
    required this.accentIcon,
    this.resourceKeys = const [],
    this.videoId,
    this.supplementalBuilders = const [],
    this.additionalNarrationKeys = const [],
  });

  @override
  State<CornDetailPage> createState() => _CornDetailPageState();
}

class _CornDetailPageState extends State<CornDetailPage> {
  static const String _pageNarrationId = 'detail_page_overview';
  static const String _introNarrationId = 'detail_intro';
  static const String _resourcesNarrationId = 'detail_resources';

  final FlutterTts _tts = FlutterTts();
  YoutubePlayerController? _youtubeController;
  bool _isSpeaking = false;
  String? _activeNarrationId;

  @override
  void initState() {
    super.initState();
    _initTts();
    final videoId = widget.videoId;
    if (videoId != null && videoId.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          useHybridComposition: true,
        ),
      );
    }
  }

  void _initTts() {
    _tts.setStartHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = true);
      }
    });
    _tts.setCompletionHandler(_handleSpeechStopped);
    _tts.setCancelHandler(_handleSpeechStopped);
    _tts.setPauseHandler(_handleSpeechStopped);
  }

  void _handleSpeechStopped() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isSpeaking = false;
      _activeNarrationId = null;
    });
  }

  Future<void> _stopNarration() async {
    await _tts.stop();
    _handleSpeechStopped();
  }

  bool _isNarrating(String id) => _isSpeaking && _activeNarrationId == id;

  Future<void> _configureVoice() async {
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    final languageCode = await configureTtsLanguage(
      _tts,
      Get.locale,
      defaultLanguage: 'en-US',
    );
    await configureTtsVoice(_tts, languageCode, locale: Get.locale);
    try {
      await _tts.setLanguage(languageCode);
    } catch (_) {}
    final localeCode = Get.locale?.languageCode.toLowerCase();
    final speechRate = localeCode == 'bn' ? 0.9 : 0.75;
    await _tts.setSpeechRate(speechRate);
    await _tts.setPitch(1.0);
  }

  Future<void> _speakNarration(String id, String narration) async {
    final text = narration.trim();
    if (text.isEmpty) {
      return;
    }

    if (_isNarrating(id)) {
      await _stopNarration();
      return;
    }

    await _stopNarration();
    await _configureVoice();
    if (!mounted) {
      return;
    }

    setState(() {
      _activeNarrationId = id;
      _isSpeaking = true;
    });

    await _tts.speak(text);
  }

  String _sectionNarrationId(CornDetailSection section) =>
      'detail_section_${section.titleKey}';

  String _timelineNarrationId(CornTimelineItem item) =>
      'detail_timeline_${item.titleKey}';

  String _videoNarrationId(String? videoId) =>
      'detail_video_${videoId ?? 'primary'}';

  String _buildIntroNarration() {
    final buffer = StringBuffer();
    buffer.writeln(widget.titleKey.tr);
    buffer.writeln(widget.introKey.tr);
    if (widget.quickTipKeys.isNotEmpty) {
      buffer.writeln('detail_quick_tip_heading'.tr);
      for (final tip in widget.quickTipKeys) {
        buffer.writeln('- ${tip.tr}');
      }
    }
    return buffer.toString();
  }

  String _buildSectionNarration(CornDetailSection section) {
    final buffer = StringBuffer();
    buffer.writeln(section.titleKey.tr);
    buffer.writeln(section.descriptionKey.tr);
    for (final highlight in section.highlightKeys) {
      buffer.writeln(highlight.tr);
    }
    return buffer.toString();
  }

  String _buildTimelineNarration(CornTimelineItem item) {
    return '${item.titleKey.tr}. ${item.detailKey.tr}';
  }

  String _buildResourceNarration() {
    if (widget.resourceKeys.isEmpty) {
      return '';
    }
    final buffer = StringBuffer();
    buffer.writeln('detail_resources_title'.tr);
    for (final resource in widget.resourceKeys) {
      buffer.writeln(resource.tr);
    }
    return buffer.toString();
  }

  String _buildVideoNarration(String title, String caption) {
    final buffer = StringBuffer();
    buffer.writeln(title);
    buffer.writeln(caption);
    return buffer.toString();
  }

  Future<void> _toggleIntroNarration() async {
    final narration = _buildIntroNarration();
    await _speakNarration(_introNarrationId, narration);
  }

  Future<void> _toggleSectionNarration(CornDetailSection section) async {
    final narration = _buildSectionNarration(section);
    await _speakNarration(_sectionNarrationId(section), narration);
  }

  Future<void> _toggleTimelineNarration(CornTimelineItem item) async {
    final narration = _buildTimelineNarration(item);
    await _speakNarration(_timelineNarrationId(item), narration);
  }

  Future<void> _toggleResourceNarration() async {
    final narration = _buildResourceNarration();
    if (narration.isEmpty) {
      return;
    }
    await _speakNarration(_resourcesNarrationId, narration);
  }

  Future<void> _toggleVideoNarration(String title, String caption) async {
    final narration = _buildVideoNarration(title, caption);
    await _speakNarration(_videoNarrationId(widget.videoId), narration);
  }

  String _buildNarration() {
    final buffer = StringBuffer();
    buffer.writeln(widget.titleKey.tr);
    buffer.writeln(widget.introKey.tr);
    if (widget.quickTipKeys.isNotEmpty) {
      buffer.writeln('detail_quick_tip_heading'.tr);
      for (final tip in widget.quickTipKeys) {
        buffer.writeln('- ${tip.tr}');
      }
    }
    for (final section in widget.sections) {
      buffer.writeln(section.titleKey.tr);
      buffer.writeln(section.descriptionKey.tr);
      for (final highlight in section.highlightKeys) {
        buffer.writeln(highlight.tr);
      }
    }
    if (widget.timeline.isNotEmpty) {
      buffer.writeln('seasonal_timeline'.tr);
      for (final item in widget.timeline) {
        buffer.writeln('${item.titleKey.tr}: ${item.detailKey.tr}');
      }
    }
    for (final resource in widget.resourceKeys) {
      buffer.writeln(resource.tr);
    }
    for (final extra in widget.additionalNarrationKeys) {
      buffer.writeln(extra.tr);
    }
    return buffer.toString();
  }

  Future<void> _toggleNarration() async {
    final narration = _buildNarration();
    await _speakNarration(_pageNarrationId, narration);
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: _CornDetailAppBar(
            title: widget.titleKey.tr,
            accentIcon: widget.accentIcon,
            isNarrating: _isNarrating(_pageNarrationId),
            onBack: () => Navigator.of(context).maybePop(),
            onNarrationTap: _toggleNarration,
            onThemeTap: themeController.toggleThemeMode,
            isDarkMode: themeController.isDarkMode,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final targetWidth =
                      availableWidth > 1180 ? 1180.0 : availableWidth;
                  final horizontalPadding = targetWidth < 420
                      ? 16.0
                      : targetWidth < 720
                          ? 20.0
                          : 28.0;
                  final verticalPadding = targetWidth < 520 ? 20.0 : 24.0;
                  final spacing = targetWidth < 600 ? 16.0 : 20.0;
                  final safeWidth =
                      math.max(targetWidth - (horizontalPadding * 2), 0.0);
                  final sectionColumns = targetWidth >= 1180
                      ? 3
                      : targetWidth >= 820
                          ? 2
                          : 1;
                  final baseSectionWidth = sectionColumns == 1 || safeWidth == 0
                      ? safeWidth
                      : (safeWidth - (sectionColumns - 1) * spacing) /
                          sectionColumns;
                  final minSectionWidth =
                      safeWidth <= 320 ? safeWidth : 260.0;
                  final maxSectionWidth = sectionColumns == 1 || safeWidth == 0
                      ? safeWidth
                      : safeWidth / sectionColumns;
                  final sectionWidth = _clampDimension(
                    baseSectionWidth,
                    minSectionWidth,
                    maxSectionWidth,
                  );

                  final timelineTwoColumn = safeWidth >= 760;
                  final baseTimelineWidth =
                      timelineTwoColumn && safeWidth > 0
                          ? (safeWidth - spacing) / 2
                          : safeWidth;
                  final timelineMinWidth =
                      safeWidth <= 360 ? safeWidth : 300.0;
                  final timelineMaxWidth = timelineTwoColumn && safeWidth > 0
                      ? safeWidth / 2
                      : safeWidth;
                  final timelineWidth = _clampDimension(
                    baseTimelineWidth,
                    timelineMinWidth,
                    timelineMaxWidth,
                  );

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: targetWidth),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        child: SizedBox(
                          width: targetWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _IntroCard(
                                intro: widget.introKey.tr,
                                quickTips: widget.quickTipKeys
                                    .map((tip) => tip.tr)
                                    .toList(),
                                accentIcon: widget.accentIcon,
                                onNarrationTap: _toggleIntroNarration,
                                isNarrating: _isNarrating(_introNarrationId),
                              ),
                              if (_youtubeController != null) ...[
                                SizedBox(height: spacing + 8),
                                Builder(
                                  builder: (context) {
                                    final videoTitle =
                                        'detail_video_title'.tr;
                                    final videoCaption =
                                        'detail_video_hint'.tr;
                                    return _VideoCard(
                                      controller: _youtubeController!,
                                      title: videoTitle,
                                      caption: videoCaption,
                                      isNarrating: _isNarrating(
                                          _videoNarrationId(widget.videoId)),
                                      onNarrationTap: () =>
                                          _toggleVideoNarration(
                                        videoTitle,
                                        videoCaption,
                                      ),
                                    );
                                  },
                                ),
                              ],
                              SizedBox(height: spacing + 4),
                              Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: widget.sections
                                    .map(
                                      (section) => SizedBox(
                                        width: sectionColumns == 1
                                            ? safeWidth
                                            : sectionWidth,
                                        child: _DetailSectionCard(
                                          section: section,
                                          isNarrating: _isNarrating(
                                              _sectionNarrationId(section)),
                                          onNarrationTap: () =>
                                              _toggleSectionNarration(
                                                  section),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              if (widget.supplementalBuilders.isNotEmpty) ...[
                                SizedBox(height: spacing + 4),
                                ...widget.supplementalBuilders.map(
                                  (builder) => Padding(
                                    padding: EdgeInsets.only(bottom: spacing),
                                    child: builder(context, targetWidth),
                                  ),
                                ),
                              ],
                              if (widget.timeline.isNotEmpty) ...[
                                SizedBox(height: spacing + 12),
                                Text(
                                  'seasonal_timeline'.tr,
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: spacing,
                                  runSpacing: spacing,
                                  children: widget.timeline
                                      .map(
                                        (entry) => SizedBox(
                                          width: timelineTwoColumn
                                              ? timelineWidth
                                              : safeWidth,
                                          child: _TimelineCard(
                                            item: entry,
                                            isNarrating: _isNarrating(
                                                _timelineNarrationId(entry)),
                                            onNarrationTap: () =>
                                                _toggleTimelineNarration(
                                                    entry),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                              if (widget.resourceKeys.isNotEmpty) ...[
                                SizedBox(height: spacing + 12),
                                _ResourceList(
                                  resources: widget.resourceKeys
                                      .map((key) => key.tr)
                                      .toList(),
                                  isNarrating:
                                      _isNarrating(_resourcesNarrationId),
                                  onNarrationTap: _toggleResourceNarration,
                                ),
                              ],
                              SizedBox(height: spacing * 2.4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CornDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData accentIcon;
  final bool isNarrating;
  final VoidCallback onBack;
  final VoidCallback onNarrationTap;
  final VoidCallback onThemeTap;
  final bool isDarkMode;

  const _CornDetailAppBar({
    required this.title,
    required this.accentIcon,
    required this.isNarrating,
    required this.onBack,
    required this.onNarrationTap,
    required this.onThemeTap,
    required this.isDarkMode,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusText =
        isNarrating ? 'detail_listening'.tr : 'detail_listen'.tr;

    final accentBadge = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        shape: BoxShape.circle,
      ),
      child: Icon(accentIcon, color: Colors.white, size: 26),
    );

    final listenButton = Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        onPressed: onNarrationTap,
        tooltip:
            isNarrating ? 'detail_stop_listening'.tr : 'detail_listen'.tr,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: Icon(
            isNarrating ? Icons.stop_rounded : Icons.volume_up_rounded,
            key: ValueKey(isNarrating),
            color: Colors.white,
          ),
        ),
      ),
    );

    final themeToggle = Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        tooltip:
            isDarkMode ? 'switch_to_light_mode'.tr : 'switch_to_dark_mode'.tr,
        onPressed: onThemeTap,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => RotationTransition(
            turns: Tween(begin: 0.75, end: 1.0).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Icon(
            isDarkMode ? Icons.light_mode_rounded : Icons.nights_stay_rounded,
            key: ValueKey(isDarkMode),
            color: Colors.white,
          ),
        ),
      ),
    );

    final backButton = Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_rounded),
        color: Colors.white,
      ),
    );

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          statusText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.85),
          ),
        ),
      ],
    );

    final actions = [accentBadge, listenButton, themeToggle];

    return CornHeaderShell(
      height: preferredSize.height,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 460;
          final actionsWrap = Wrap(
            spacing: isCompact ? 10 : 12,
            runSpacing: isCompact ? 8 : 10,
            alignment: isCompact ? WrapAlignment.start : WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: actions,
          );

          final rowChildren = <Widget>[
            backButton,
            const SizedBox(width: 14),
            Expanded(child: titleBlock),
          ];

          if (!isCompact) {
            rowChildren.addAll([
              const SizedBox(width: 12),
              Flexible(child: actionsWrap),
            ]);
          }

          final headerRow = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: rowChildren,
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerRow,
                const SizedBox(height: 12),
                actionsWrap,
              ],
            );
          }

          return headerRow;
        },
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final String intro;
  final List<String> quickTips;
  final IconData accentIcon;
  final VoidCallback onNarrationTap;
  final bool isNarrating;

  const _IntroCard({
    required this.intro,
    required this.quickTips,
    required this.accentIcon,
    required this.onNarrationTap,
    required this.isNarrating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.secondaryContainer.withOpacity(0.85),
            theme.colorScheme.primary.withOpacity(0.75),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 380;
          final iconBadge = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(accentIcon, color: Colors.white),
          );

          final introText = Text(
            intro,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          );

          final buttonSize = isCompact ? 40.0 : 44.0;
          final buttonPadding = isCompact ? 8.0 : 10.0;
          final buttonIconSize = isCompact ? 20.0 : 22.0;
          final listenButton = NarrationToggleButton(
            isActive: isNarrating,
            onPressed: onNarrationTap,
            backgroundColor: Colors.white.withOpacity(0.22),
            iconColor: Colors.white,
            size: buttonSize,
            padding: EdgeInsets.all(buttonPadding),
            iconSize: buttonIconSize,
            startTooltip: 'detail_listen'.tr,
            stopTooltip: 'detail_stop_listening'.tr,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact) ...[
                Row(
                  children: [
                    iconBadge,
                    const Spacer(),
                    listenButton,
                  ],
                ),
                const SizedBox(height: 14),
                introText,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconBadge,
                    const SizedBox(width: 16),
                    Expanded(child: introText),
                    const SizedBox(width: 12),
                    listenButton,
                  ],
                ),
              if (quickTips.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  'detail_quick_tip_heading'.tr,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: quickTips
                      .map((tip) => _TipChip(
                            label: tip,
                            color: Colors.white,
                            textColor: theme.colorScheme.primary,
                          ))
                      .toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DetailSectionCard extends StatelessWidget {
  final CornDetailSection section;
  final VoidCallback onNarrationTap;
  final bool isNarrating;

  const _DetailSectionCard({
    required this.section,
    required this.onNarrationTap,
    required this.isNarrating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;
          final iconBadge = Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(section.icon, color: theme.colorScheme.primary),
          );

          final titleWidget = Text(
            section.titleKey.tr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          );

          final buttonSize = isCompact ? 38.0 : 42.0;
          final buttonPadding = isCompact ? 7.0 : 8.0;
          final buttonIconSize = isCompact ? 18.0 : 20.0;
          final listenButton = NarrationToggleButton(
            isActive: isNarrating,
            onPressed: onNarrationTap,
            backgroundColor:
                theme.colorScheme.primary.withOpacity(0.12),
            iconColor: theme.colorScheme.primary,
            size: buttonSize,
            padding: EdgeInsets.all(buttonPadding),
            iconSize: buttonIconSize,
            startTooltip: 'detail_listen'.tr,
            stopTooltip: 'detail_stop_listening'.tr,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconBadge,
                    const Spacer(),
                    listenButton,
                  ],
                ),
                const SizedBox(height: 12),
                titleWidget,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconBadge,
                    const SizedBox(width: 12),
                    Expanded(child: titleWidget),
                    const SizedBox(width: 12),
                    listenButton,
                  ],
                ),
              const SizedBox(height: 12),
              Text(
                section.descriptionKey.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.85),
                  height: 1.55,
                ),
              ),
              if (section.highlightKeys.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: section.highlightKeys
                      .map((item) => _TipChip(
                            label: item.tr,
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            textColor: theme.colorScheme.primary,
                          ))
                      .toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final CornTimelineItem item;
  final VoidCallback onNarrationTap;
  final bool isNarrating;

  const _TimelineCard({
    required this.item,
    required this.onNarrationTap,
    required this.isNarrating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark
        ? Colors.white
        : theme.colorScheme.onSecondaryContainer.withOpacity(0.95);
    final detailColor = isDark
        ? Colors.white.withOpacity(0.9)
        : theme.colorScheme.onSecondaryContainer.withOpacity(0.85);
    final iconColor = isDark
        ? Colors.white
        : theme.colorScheme.primary.withOpacity(0.9);
    final buttonBackground = isDark
        ? Colors.white.withOpacity(0.18)
        : theme.colorScheme.primary.withOpacity(0.14);
    final listenButton = NarrationToggleButton(
      isActive: isNarrating,
      onPressed: onNarrationTap,
      backgroundColor: buttonBackground,
      iconColor: iconColor,
      size: 40,
      padding: const EdgeInsets.all(8),
      iconSize: 20,
      startTooltip: 'detail_listen'.tr,
      stopTooltip: 'detail_stop_listening'.tr,
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.titleKey.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              listenButton,
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.detailKey.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: detailColor,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _TipChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 16, color: textColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final YoutubePlayerController controller;
  final String title;
  final String caption;
  final VoidCallback onNarrationTap;
  final bool isNarrating;

  const _VideoCard({
    required this.controller,
    required this.title,
    required this.caption,
    required this.onNarrationTap,
    required this.isNarrating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: theme.colorScheme.primary,
      ),
      builder: (context, player) {
        final listenButton = NarrationToggleButton(
          isActive: isNarrating,
          onPressed: onNarrationTap,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
          iconColor: theme.colorScheme.primary,
          size: 42,
          padding: const EdgeInsets.all(8),
          iconSize: 20,
          startTooltip: 'detail_listen'.tr,
          stopTooltip: 'detail_stop_listening'.tr,
        );
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.play_circle_fill,
                        color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  listenButton,
                ],
              ),
              const SizedBox(height: 14),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: player,
              ),
              const SizedBox(height: 12),
              Text(
                caption,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.75),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResourceList extends StatelessWidget {
  final List<String> resources;
  final VoidCallback onNarrationTap;
  final bool isNarrating;

  const _ResourceList({
    required this.resources,
    required this.onNarrationTap,
    required this.isNarrating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listenButton = NarrationToggleButton(
      isActive: isNarrating,
      onPressed: onNarrationTap,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
      iconColor: theme.colorScheme.primary,
      size: 42,
      padding: const EdgeInsets.all(8),
      iconSize: 20,
      startTooltip: 'detail_listen'.tr,
      stopTooltip: 'detail_stop_listening'.tr,
    );
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'detail_resources_title'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              listenButton,
            ],
          ),
          const SizedBox(height: 14),
          ...resources.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.85),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
