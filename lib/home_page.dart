import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }

  Future<void> loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedRole = prefs.getString('user_role');
    setState(() {
      userRole = savedRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> cardsToShow = [];

    if (userRole == 'general_user') {
      cardsToShow = [
        {'title': 'user_info', 'icon': '👤'}, 
        {'title': 'soil_type', 'icon': '🌱'},
      ];
    } else if (userRole == 'farmer') {
      cardsToShow = [
        {'title': 'seed_type', 'icon': '🌾'},
        {'title': 'soil_type', 'icon': '🌱'},
      ];
    } else {
      // fallback or empty
      cardsToShow = [];
    }

    return Scaffold(
      appBar: AppBar(title: Text('home'.tr)),
      body: userRole == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: cardsToShow.length,
                itemBuilder: (context, index) {
                  final card = cardsToShow[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    color: Colors.orange[100],
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            card['icon']!,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            card['title']!.tr,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
