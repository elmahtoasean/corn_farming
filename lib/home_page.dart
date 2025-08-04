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
      return const Scaffold(
        backgroundColor: Color(0xFFFEF3E5),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const crossAxisCount = 3;

    final totalSpacing = 16.0 * (crossAxisCount - 1);
    final availableWidth = screenWidth - totalSpacing - 36;
    final cardWidth = (availableWidth / crossAxisCount).clamp(100.0, 300.0);

    double imageHeight;
    double fontSize;

    if (screenWidth < 350) {
      imageHeight = 80;
      fontSize = 16;
    } else if (screenWidth < 600) {
      // Medium screens (e.g. bigger phones, small tablets)
      imageHeight = 100;
      fontSize = 18;
    } else {
      // Large screens (tablets, desktop)
      imageHeight = 270;
      fontSize = 20;
    }

    final spacing = 16.0;
    final cardMargin = 8.0;

    final List<Map<String, dynamic>> cards = getCards(userRole);

    return Scaffold(
      backgroundColor: const Color(0xFFFEF3E5),
      body: Stack(
        children: [
          // Sidebar
          AnimatedPositioned(
            duration: duration,
            top: 0,
            bottom: 0,
            left: isSidebarOpen ? 0 : -250,
            child: CustomSidebar(
              onClose: () => setState(() => isSidebarOpen = false),
            ),
          ),

          // Main Content
          AnimatedPositioned(
            duration: duration,
            left: isSidebarOpen ? 250 : 0,
            right: isSidebarOpen ? -250 : 0,
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
                  backgroundColor: const Color(0xFFFEF3E5),
                  appBar: AppBar(
                    title: Text('home_page'.tr),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () {
                        setState(() => isSidebarOpen = !isSidebarOpen);
                      },
                    ),
                  ),
                  body: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(spacing),
                      child: GridView.count(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: 1 / 1.1,
                        children: cards.map((card) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Get.toNamed(card['route']);
                              Fluttertoast.showToast(msg: card['title'].tr);
                            },
                            child: Card(
                              elevation: 15,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              margin: EdgeInsets.all(cardMargin),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Image section
                                  SizedBox(
                                    height: imageHeight,
                                    child: Image.asset(
                                      card['icon'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                  // Text label with gradient
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
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
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          card['title'].toString().tr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            shadows: const [
                                              Shadow(
                                                blurRadius: 4,
                                                color: Color.fromARGB(128, 47, 132, 75),
                                                offset: Offset(1, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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
}
