import 'package:corn_farming/controller/localization_controller.dart';
import 'package:corn_farming/models/language_model.dart';
import 'package:corn_farming/utils/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LanguageWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;

  LanguageWidget({
    required this.languageModel,
    required this.localizationController,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = localizationController.selectedIndex == index;

    const Color unselectedCardColor = Color(0xFFC4A484); // Light mocha
    const Color selectedCardColor = Color(0xFFA9744E); // Rich caramel

    return InkWell(
      onTap: () {
        localizationController.setSelectIndex(index);
        localizationController.setLanguage(Locale(
          AppConstants.languages[index].languageCode,
          AppConstants.languages[index].countryCode,
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isSelected ? selectedCardColor : unselectedCardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 5,
              spreadRadius: 1,
            )
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    languageModel.languageName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 30,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
