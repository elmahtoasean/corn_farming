import 'package:corn_farming/controller/theme_controller.dart';
import 'package:corn_farming/utils/corn_header.dart';
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
    if (videoId != null && videoId.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
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
  }

  Future<void> _configureVoice() async {
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    final locale = Get.locale;
    if (locale != null && locale.languageCode.toLowerCase() == 'bn') {
      await _tts.setLanguage('bn-BD');
    } else {
      await _tts.setLanguage('en-US');
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
    await _configureVoice();
    setState(() => _isSpeaking = true);
    await _tts.speak(narration);
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
                  final width = constraints.maxWidth;
                  final columnCount = width > 1100
                      ? 3
                      : width > 720
                          ? 2
                          : 1;
                  final itemWidth = columnCount == 1
                      ? width
                      : (width - (columnCount - 1) * 20) / columnCount;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: width < 420 ? 16 : 24,
                      vertical: 24,
                    ),
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
                        if (_youtubeController != null) ...[
                          const SizedBox(height: 24),
                          _VideoCard(
                            controller: _youtubeController!,
                            title: 'detail_video_title'.tr,
                            caption: 'detail_video_hint'.tr,
                          ),
                        ],
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: widget.sections
                              .map((section) => SizedBox(
                                    width: itemWidth.clamp(260, width),
                                    child: _DetailSectionCard(section: section),
                                  ))
                              .toList(),
                        ),
                        if (widget.supplementalBuilders.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          ...widget.supplementalBuilders.map(
                            (builder) => Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: builder(context, width),
                            ),
                          ),
                        ],
                        if (widget.timeline.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Text(
                            'seasonal_timeline'.tr,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: widget.timeline
                                .map((entry) => SizedBox(
                                      width: width > 840
                                          ? (width / 2) - 32
                                          : double.infinity,
                                      child: _TimelineCard(item: entry),
                                    ))
                                .toList(),
                          ),
                        ],
                        if (widget.resourceKeys.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          _ResourceList(
                            resources: widget.resourceKeys
                                .map((key) => key.tr)
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 48),
                      ],
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

    return CornHeaderShell(
      height: preferredSize.height,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
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
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                accentBadge,
                listenButton,
                themeToggle,
              ],
            ),
          ),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(accentIcon, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  intro,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(section.icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.titleKey.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
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
              const Icon(Icons.timeline_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.titleKey.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
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
              color: Colors.white.withOpacity(0.9),
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
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
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

  const _VideoCard({
    required this.controller,
    required this.title,
    required this.caption,
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
