import 'package:corn_farming/controller/theme_controller.dart';
import 'package:corn_farming/utils/corn_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/user_cards.dart';
import 'utils/app_route.dart';
import 'utils/sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool isSidebarOpen = false;
  final Duration duration = const Duration(milliseconds: 300);

  String? userRole;
  bool isLoading = true;
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _initTts();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('user_role') ?? 'general_user';
      isLoading = false;
    });
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

  String _buildNarration(List<Map<String, dynamic>> cards) {
    final buffer = StringBuffer();
    buffer.writeln('home_page'.tr);
    buffer.writeln('home_appbar_subtitle'.tr);
    if (userRole != null) {
      final roleLabel = userRole == 'farmer'
          ? 'role_farmer_label'.tr
          : 'role_enthusiast_label'.tr;
      buffer.writeln('home_welcome'.trParams({'role': roleLabel}));
    }
    buffer.writeln('home_choose_guide'.tr);
    buffer.writeln('home_card_hint'.tr);
    for (final card in cards) {
      buffer.writeln(card['title'].toString().tr);
      final summaryKey = card['summary'] as String?;
      if (summaryKey != null) {
        buffer.writeln(summaryKey.tr);
      }
    }
    buffer.writeln('home_listen_narration'.tr);
    return buffer.toString();
  }

  Future<void> _toggleNarration(List<Map<String, dynamic>> cards) async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    final narration = _buildNarration(cards).trim();
    if (narration.isEmpty) {
      return;
    }
    await _configureVoice();
    setState(() => _isSpeaking = true);
    await _tts.speak(narration);
  }

  @override
  void dispose() {
    _tts.stop();
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return GetBuilder<ThemeController>(
      builder: (themeController) {
        final List<Map<String, dynamic>> cards = getCards(userRole);
        final media = MediaQuery.of(context);
        final theme = Theme.of(context);
        final sidebarWidth = _sidebarWidth(media.size.width);

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.12),
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: duration,
                top: 0,
                bottom: 0,
                left: isSidebarOpen ? 0 : -sidebarWidth,
                child: SizedBox(
                  width: sidebarWidth,
                  child: CustomSidebar(
                    onClose: () => setState(() => isSidebarOpen = false),
                    onNavigate: (route) {
                      setState(() => isSidebarOpen = false);
                      if (route.isEmpty) {
                        return;
                      }
                      if (route == RouteHelper.home) {
                        return;
                      }
                      Get.toNamed(route);
                    },
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: duration,
                curve: Curves.easeInOut,
                left: isSidebarOpen ? sidebarWidth : 0,
                right: isSidebarOpen ? -sidebarWidth : 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    if (isSidebarOpen) {
                      setState(() => isSidebarOpen = false);
                    }
                  },
                  child: AbsorbPointer(
                    absorbing: isSidebarOpen,
                    child: Scaffold(
                      backgroundColor: theme.colorScheme.surface,
                      appBar: _CornAppBar(
                        title: 'home_page'.tr,
                        onMenuTap: () => setState(() => isSidebarOpen = !isSidebarOpen),
                        onThemeTap: themeController.toggleThemeMode,
                        isDarkMode: themeController.isDarkMode,
                        onNarrationTap: () => _toggleNarration(cards),
                        isNarrating: _isSpeaking,
                      ),
                      body: SafeArea(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final crossAxisCount = _gridCountForWidth(width);
                            final spacing = width < 500 ? 12.0 : 20.0;
                            final horizontalPadding = spacing + 8;
                            final availableWidth = width -
                                (spacing * (crossAxisCount - 1)) -
                                (horizontalPadding * 2);
                            final cardWidth = availableWidth / crossAxisCount;
                            final cardHeight = width < 560
                                ? 190.0
                                : width < 1024
                                    ? cardWidth * 0.85
                                    : cardWidth * 0.75;
                            final aspectRatio = cardWidth / cardHeight;

                            return CustomScrollView(
                              physics: const BouncingScrollPhysics(),
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: horizontalPadding,
                                      vertical: spacing,
                                    ),
                                    child: _DashboardHeader(
                                      userRole: userRole,
                                      totalCards: cards.length,
                                    ),
                                  ),
                                ),
                                SliverPadding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                    vertical: spacing,
                                  ),
                                  sliver: SliverGrid(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: spacing,
                                      mainAxisSpacing: spacing,
                                      childAspectRatio: aspectRatio,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final card = cards[index];
                                        final iconName = card['icon'] as String;
                                        final icon = _iconForName(iconName);
                                        final colorValue = card['color'] as int?;
                                        final accent = colorValue != null
                                            ? Color(colorValue)
                                            : theme.colorScheme.primary;
                                        final summaryKey = card['summary'] as String?;
                                        final summary = summaryKey != null
                                            ? summaryKey.tr
                                            : 'home_card_hint'.tr;
                                        return _DashboardCard(
                                          title: card['title'].toString().tr,
                                          icon: icon,
                                          accent: accent,
                                          summary: summary,
                                          onTap: () {
                                            Get.toNamed(card['route'] as String);
                                            Fluttertoast.showToast(
                                                msg: card['title'].toString().tr);
                                          },
                                        );
                                      },
                                      childCount: cards.length,
                                    ),
                                  ),
                                ),
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 40),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _sidebarWidth(double screenWidth) {
    if (screenWidth < 420) {
      return screenWidth * 0.82;
    } else if (screenWidth < 768) {
      return screenWidth * 0.7;
    } else if (screenWidth < 1024) {
      return screenWidth * 0.45;
    }
    return 360;
  }

  int _gridCountForWidth(double width) {
    if (width < 480) {
      return 1;
    } else if (width < 840) {
      return 2;
    } else if (width < 1280) {
      return 3;
    } else if (width < 1600) {
      return 4;
    }
    return 5;
  }

  IconData _iconForName(String name) {
    switch (name) {
      case 'grass':
        return Icons.grass;
      case 'wb_sunny':
        return Icons.wb_sunny_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'bug_report':
        return Icons.bug_report_rounded;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'auto_graph':
        return Icons.auto_graph_rounded;
      case 'yard':
        return Icons.yard_rounded;
      case 'emoji_nature':
        return Icons.emoji_nature_rounded;
      case 'agriculture':
        return Icons.agriculture_rounded;
      case 'storefront':
        return Icons.storefront_rounded;
      case 'lightbulb':
        return Icons.lightbulb_outline;
      case 'construction':
        return Icons.construction_rounded;
      default:
        return Icons.eco_outlined;
    }
  }
}

class _CornAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMenuTap;
  final VoidCallback onThemeTap;
  final VoidCallback onNarrationTap;
  final bool isDarkMode;
  final bool isNarrating;

  const _CornAppBar({
    required this.title,
    required this.onMenuTap,
    required this.onThemeTap,
    required this.onNarrationTap,
    required this.isDarkMode,
    required this.isNarrating,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final modeChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco_rounded,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isDarkMode ? 'home_mode_dark'.tr : 'home_mode_light'.tr,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'home_card_hint'.tr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.75),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final listenButton = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        tooltip: isNarrating ? 'home_listen_stop'.tr : 'home_listen_start'.tr,
        onPressed: onNarrationTap,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: Icon(
            isNarrating ? Icons.stop_rounded : Icons.volume_up_rounded,
            key: ValueKey(isNarrating),
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );

    final themeToggle = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withOpacity(0.16),
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
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );

    return CornHeaderShell(
      height: preferredSize.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: onMenuTap,
              icon: const Icon(Icons.menu_rounded),
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'home_appbar_subtitle'.tr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'home_listen_hint'.tr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.7),
                    fontSize: 11,
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
                modeChip,
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

class _DashboardHeader extends StatelessWidget {
  final String? userRole;
  final int totalCards;

  const _DashboardHeader({required this.userRole, required this.totalCards});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFarmer = userRole == 'farmer';
    final roleLabel =
        isFarmer ? 'role_farmer_label'.tr : 'role_enthusiast_label'.tr;
    final welcomeText = 'home_welcome'.trParams({'role': roleLabel});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          welcomeText,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'home_choose_guide'.tr,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.75),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _HeaderChip(
              icon: Icons.grid_view_rounded,
              label: 'home_chip_paths'.trParams({'count': '$totalCards'}),
            ),
            _HeaderChip(
              icon: Icons.auto_fix_high,
              label:
                  isFarmer ? 'home_chip_expert'.tr : 'home_chip_beginner'.tr,
            ),
            _HeaderChip(
              icon: Icons.light_mode,
              label: 'home_chip_mode'.trParams({
                'mode': Theme.of(context).brightness == Brightness.dark
                    ? 'home_mode_dark'.tr
                    : 'home_mode_light'.tr,
              }),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final String summary;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.onTap,
    required this.summary,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withOpacity(isDark ? 0.3 : 0.18),
                blurRadius: _hovering ? 28 : 18,
                offset: const Offset(0, 12),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.accent.withOpacity(isDark ? 0.55 : 0.88),
                widget.accent.withOpacity(isDark ? 0.75 : 0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -24,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        size: 32,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.85),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_fill,
                              size: 18, color: theme.colorScheme.onPrimary),
                          const SizedBox(width: 6),
                          Text(
                            'home_card_open'.tr,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
