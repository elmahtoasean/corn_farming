import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomSidebar extends StatelessWidget {
  final VoidCallback onClose;

  const CustomSidebar({super.key, required this.onClose});

  Future<void> _switchRole() async {
    final prefs = await SharedPreferences.getInstance();
    final currentRole = prefs.getString('user_role') ?? 'general_user';
    final newRole = currentRole == 'farmer' ? 'general_user' : 'farmer';
    await prefs.setString('user_role', newRole);
    Get.offAllNamed('/home?role=$newRole');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.brown.shade700,
                Colors.brown.shade400,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 50),

              // Top logo and app name only
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png', 
                      width: 55,
                      height: 55,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'app_name'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Main sidebar items
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.home, color: Colors.white),
                        title: Text("dashboard".tr,
                            style: const TextStyle(color: Colors.white)),
                        onTap: onClose,
                      ),
                      ListTile(
                        leading: const Icon(Icons.person, color: Colors.white),
                        title: Text("profile".tr,
                            style: const TextStyle(color: Colors.white)),
                        onTap: onClose,
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.white),
                        title: Text("logout".tr,
                            style: const TextStyle(color: Colors.white)),
                        onTap: onClose,
                      ),
                    ],
                  ),
                ),
              ),

              // Switch Role Button at Bottom
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: FutureBuilder<String?>(
                  future: SharedPreferences.getInstance()
                      .then((prefs) => prefs.getString('user_role')),
                  builder: (context, snapshot) {
                    final role = snapshot.data ?? 'general_user';
                    return ElevatedButton.icon(
                      onPressed: _switchRole,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade800,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.swap_horiz, color: Colors.white),
                      label: Text(
                        role == 'farmer'
                            ? 'switch_to_general'.tr
                            : 'switch_to_farmer'.tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
