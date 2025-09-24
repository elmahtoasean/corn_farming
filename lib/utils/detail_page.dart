import 'dart:math' as math;

import 'package:corn_farming/controller/theme_controller.dart';
import 'package:corn_farming/utils/corn_header.dart';
import 'package:corn_farming/utils/tts_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'video_embed_stub.dart'
    if (dart.library.html) 'video_embed_web.dart';

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
  final FlutterTts _tts = FlutterTts();
  YoutubePlayerController? _youtubeController;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    final videoId = widget.videoId;
    if (!kIsWeb && videoId != null && videoId.isNotEmpty) {
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
    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });
    _tts.setCancelHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });
    _tts.setPauseHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });
    _tts.setErrorHandler((msg) {
      print('TTS Error: $msg');
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });
  }

  Future<void> _configureVoice() async {
    try {
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      
      print("Configuring TTS for locale: ${Get.locale}");
      
      // Debug Bengali TTS if needed
      if (Get.locale?.languageCode.toLowerCase() == 'bn') {
        await debugBengaliTTS(_tts);
      }
      
      final languageCode = await configureTtsLanguage(
        _tts,
        Get.locale,
        defaultLanguage: 'en-US',
      );
      
      await configureTtsVoice(_tts, languageCode, locale: Get.locale);
      
      // Language-specific speech rate
      final localeCode = Get.locale?.languageCode.toLowerCase();
      final speechRate = localeCode == 'bn' ? 0.9 : 0.75;
      
      await _tts.setSpeechRate(speechRate);
      await _tts.setPitch(1.0);
      
      print("TTS configured successfully for language: $languageCode");
      
    } catch (e) {
      print("TTS configuration error: $e");
      // Fallback configuration
      try {
        await _tts.setLanguage('en-US');
        await _tts.setSpeechRate(0.75);
        await _tts.setPitch(1.0);
      } catch (fallbackError) {
        print("TTS fallback configuration error: $fallbackError");
      }
    }
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
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    
    final narration = _buildNarration().trim();
    if (narration.isEmpty) {
      return;
    }
    
    try {
      setState(() => _isSpeaking = true);
      await _configureVoice();
      
      print("Starting narration: ${narration.substring(0, math.min(100, narration.length))}...");
      await _tts.speak(narration);
      
    } catch (e) {
      print("Narration error: $e");
      setState(() => _isSpeaking = false);
    }
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
            isNarrating: _isSpeaking,
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
                              ),
                              if (widget.videoId != null &&
                                  widget.videoId!.isNotEmpty) ...[
                                SizedBox(height: spacing + 8),
                                _VideoCard(
                                  controller: _youtubeController,
                                  videoId: widget.videoId!,
                                  title: 'detail_video_title'.tr,
                                  caption: 'detail_video_hint'.tr,
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
                                          child: _TimelineCard(item: entry),
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
    final isDarkTheme = theme.brightness == Brightness.dark;
    final baseOnPrimary = theme.colorScheme.onPrimary;
    final headerTextColor =
        isDarkTheme ? baseOnPrimary : Color.lerp(baseOnPrimary, Colors.black, 0.35)!;
    final headerSecondaryTextColor = isDarkTheme
        ? baseOnPrimary.withOpacity(0.85)
        : Color.lerp(headerTextColor, Colors.black, 0.2)!;
    final statusText =
        isNarrating ? 'detail_listening'.tr : 'detail_listen'.tr;

    final accentBadge = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: headerTextColor.withOpacity(isDarkTheme ? 0.18 : 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(accentIcon, color: headerTextColor, size: 26),
    );

    final listenButton = Container(
      decoration: BoxDecoration(
        color: headerTextColor.withOpacity(isDarkTheme ? 0.16 : 0.12),
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
            color: headerTextColor,
          ),
        ),
      ),
    );

    final themeToggle = Container(
      decoration: BoxDecoration(
        color: headerTextColor.withOpacity(isDarkTheme ? 0.16 : 0.12),
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
            color: headerTextColor,
          ),
        ),
      ),
    );

    final backButton = Container(
      decoration: BoxDecoration(
        color: headerTextColor.withOpacity(isDarkTheme ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_rounded),
        color: headerTextColor,
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
            color: headerTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          statusText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: headerSecondaryTextColor,
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
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: actions,
          );

          final rowChildren = <Widget>[
            backButton,
            const SizedBox(width: 14),
          ];

          if (!isCompact) {
            rowChildren.addAll([
              actionsWrap,
              const SizedBox(width: 16),
            ]);
          }

          rowChildren.add(Expanded(child: titleBlock));

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

  const _IntroCard({
    required this.intro,
    required this.quickTips,
    required this.accentIcon,
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact) ...[
                iconBadge,
                const SizedBox(height: 14),
                introText,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconBadge,
                    const SizedBox(width: 16),
                    Expanded(child: introText),
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

  const _DetailSectionCard({required this.section});

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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact) ...[
                iconBadge,
                const SizedBox(height: 12),
                titleWidget,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconBadge,
                    const SizedBox(width: 12),
                    Expanded(child: titleWidget),
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

  const _TimelineCard({required this.item});

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
  final YoutubePlayerController? controller;
  final String videoId;
  final String title;
  final String caption;

  const _VideoCard({
    required this.controller,
    required this.videoId,
    required this.title,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (kIsWeb) {
      return _VideoCardBody(
        theme: theme,
        title: title,
        caption: caption,
        child: buildYoutubeEmbed(videoId),
      );
    }

    final youtubeController = controller;
    if (youtubeController == null) {
      return const SizedBox.shrink();
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: youtubeController,
        showVideoProgressIndicator: true,
        progressIndicatorColor: theme.colorScheme.primary,
      ),
      builder: (context, player) {
        return _VideoCardBody(
          theme: theme,
          title: title,
          caption: caption,
          child: player,
        );
      },
    );
  }
}

class _VideoCardBody extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String caption;
  final Widget child;

  const _VideoCardBody({
    required this.theme,
    required this.title,
    required this.caption,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
                child:
                    Icon(Icons.play_circle_fill, color: theme.colorScheme.primary),
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
            ],
          ),
          const SizedBox(height: 14),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: child,
            ),
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
  }
}

class _ResourceList extends StatelessWidget {
  final List<String> resources;

  const _ResourceList({required this.resources});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Text(
            'detail_resources_title'.tr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
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