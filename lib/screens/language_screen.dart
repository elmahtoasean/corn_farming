import 'package:corn_farming/controller/localization_controller.dart';
import 'package:corn_farming/models/language_model.dart';
import 'package:corn_farming/utils/app_route.dart'; // Make sure RouteHelper is imported
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF3E5),
      body: SafeArea(
        child: GetBuilder<LocalizationController>(
          builder: (localizationController) {
            return Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 30),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'select_language'.tr,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
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
                                    children: List.generate(localizationController.languages.length, (index) {
                                      final languageModel = localizationController.languages[index];
                                      final isSelected = localizationController.selectedIndex == index;
                                      return SizedBox(
                                        width: cardWidth.clamp(140, 280),
                                        height: 160,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          elevation: 6,
                                          color: isSelected ? Colors.brown[300] : Colors.brown[100],
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(15),
                                            onTap: () {
                                              localizationController.setLanguage(Locale(
                                                languageModel.languageCode,
                                                languageModel.countryCode,
                                              ));
                                              localizationController.setSelectIndex(index);
                                            },
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(12),
                                                    child: Text(
                                                      languageModel.languageName,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,
                                                        color: isSelected ? Colors.white : Colors.brown[900],
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
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
                                    }),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'you_can_change_language'.tr,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 30),
                              if (localizationController.selectedIndex != -1)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Get.toNamed(RouteHelper.getRoleRoute());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFA9744E),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.navigate_next, color: Colors.white),
                                  label: Text(
                                    'next'.tr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
