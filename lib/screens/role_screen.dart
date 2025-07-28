import 'package:corn_farming/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});
  @override
  _RoleScreenState createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  String? selectedRoleKey;

  final roles = [
    {
      'key': 'farmer',
      'animation': 'assets/lottie/farmer.json',
    },
    {
      'key': 'general_user',
      'animation': 'assets/lottie/general_user.json',
    },
  ];

  void selectRole(String key) async {
    setState(() {
      selectedRoleKey = key;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF3E5),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'select_role'.tr,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = constraints.maxWidth;
                      double cardWidth = (screenWidth > 400)
                          ? (screenWidth / 2) - 12
                          : screenWidth;

                      return Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: roles.map((role) {
                          bool isSelected = selectedRoleKey == role['key'];
                          return SizedBox(
                            width: cardWidth.clamp(140, 280),
                            height: 260,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 6,
                              color: isSelected
                                  ? Colors.brown[300]
                                  : Colors.brown[100],
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () => selectRole(role['key']!),
                                child: Stack(
                                  children: [
                                    // Center the content inside the card
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Lottie.asset(
                                                role['animation']!,
                                                fit: BoxFit.contain,
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              role['key']!.tr,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.brown[900],
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Tick icon positioned top-right, does not affect layout
                                    if (isSelected)
                                      const Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  if (selectedRoleKey != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(RouteHelper.getHomeRoute());
                      },
                      icon: const Icon(Icons.navigate_next, color: Colors.white),
                      label: Text(
                        'next'.tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA9744E),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
