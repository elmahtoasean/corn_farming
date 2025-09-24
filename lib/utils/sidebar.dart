import 'package:corn_farming/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomSidebar extends StatelessWidget {
  final VoidCallback onClose;
  final ValueChanged<String> onNavigate;

  const CustomSidebar({
    super.key,
    required this.onClose,
    required this.onNavigate,
  });

  Future<void> _switchRole() async {
    final prefs = await SharedPreferences.getInstance();
    final currentRole = prefs.getString('user_role') ?? 'general_user';
    final newRole = currentRole == 'farmer' ? 'general_user' : 'farmer';
    await prefs.setString('user_role', newRole);
    Get.offAllNamed('/home?role=$newRole');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 260;
        final navItems = [
          _SidebarItem(
            icon: Icons.notifications_active,
            label: 'sidebar_alerts'.tr,
            route: RouteHelper.alerts,
          ),
          _SidebarItem(
            icon: Icons.map_outlined,
            label: 'sidebar_planner'.tr,
            route: RouteHelper.planner,
          ),
          _SidebarItem(
            icon: Icons.support_agent,
            label: 'sidebar_support'.tr,
            route: RouteHelper.help,
          ),
        ];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.85),
                theme.colorScheme.secondary,
                theme.colorScheme.secondary.withOpacity(0.75),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(6, 12),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 16 : 24,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'app_name'.tr,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'sidebar_tagline'.tr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...navItems.map((item) {
                            return _SidebarButton(
                              icon: item.icon,
                              label: item.label,
                              onTap: () {
                                onClose();
                                if (item.route != RouteHelper.home) {
                                  onNavigate(item.route);
                                }
                              },
                            );
                          }).toList(),
                          const SizedBox(height: 12),
                          
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<String?>(
                    future: SharedPreferences.getInstance()
                        .then((prefs) => prefs.getString('user_role')),
                    builder: (context, snapshot) {
                      final role = snapshot.data ?? 'general_user';
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _switchRole,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.22),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: const Icon(Icons.swap_horiz_rounded),
                          label: Text(
                            role == 'farmer'
                                ? 'switch_to_general'.tr
                                : 'switch_to_farmer'.tr,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarHighlight extends StatelessWidget {
  final ThemeData theme;

  const _SidebarHighlight({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_nature, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'sidebar_helper_text'.tr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.thermostat, color: Colors.white70),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'sidebar_weather_tip'.tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarMetrics extends StatelessWidget {
  final ThemeData theme;

  const _SidebarMetrics({required this.theme});

  @override
  Widget build(BuildContext context) {
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.white.withOpacity(0.9),
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'sidebar_progress_title'.tr,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _ProgressRow(
            label: 'sidebar_progress_field'.tr,
            value: '82%',
            theme: theme,
          ),
          const SizedBox(height: 8),
          _ProgressRow(
            label: 'sidebar_progress_irrigation'.tr,
            value: '3/5',
            theme: theme,
          ),
          const SizedBox(height: 8),
          Text(
            'sidebar_progress_hint'.tr,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _ProgressRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final String route;

  _SidebarItem({required this.icon, required this.label, required this.route});
}
