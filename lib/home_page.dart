import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('user_role') ?? 'general_user';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final List<Map<String, dynamic>> cards = getCards(userRole);

    final media = MediaQuery.of(context);
    final theme = Theme.of(context);
    final sidebarWidth = _sidebarWidth(media.size.width);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.12),
                  theme.colorScheme.background,
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
                  backgroundColor: Colors.transparent,
                  appBar: _CornAppBar(
                    title: 'home_page'.tr,
                    onMenuTap: () => setState(() => isSidebarOpen = !isSidebarOpen),
                  ),
                  body: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final crossAxisCount = _gridCountForWidth(width);
                        final spacing = width < 500 ? 12.0 : 20.0;
                        final horizontalPadding = spacing + 8;
                        final availableWidth =
                            width - (spacing * (crossAxisCount - 1)) - (horizontalPadding * 2);
                        final cardWidth = availableWidth / crossAxisCount;
                        final cardHeight = width < 600
                            ? 170.0
                            : width < 1024
                                ? cardWidth * 0.9
                                : cardWidth * 0.8;
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
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                    return _DashboardCard(
                                      title: card['title'].toString().tr,
                                      icon: icon,
                                      accent: accent,
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
    } else if (width < 1200) {
      return 3;
    }
    return 4;
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

  const _CornAppBar({required this.title, required this.onMenuTap});

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(isDark ? 0.65 : 0.45),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary.withOpacity(0.18),
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.secondaryContainer.withOpacity(isDark ? 0.3 : 0.7),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.eco_rounded,
                      color: theme.colorScheme.onSecondaryContainer,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.onTap,
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
                widget.accent.withOpacity(isDark ? 0.55 : 0.85),
                widget.accent.withOpacity(isDark ? 0.75 : 0.65),
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
                      'home_card_hint'.tr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.85),
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
