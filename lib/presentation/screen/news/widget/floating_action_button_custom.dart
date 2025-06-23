import 'package:admin_fitmom/core/utils/my_strings.dart';
import 'package:admin_fitmom/presentation/screen/category_news/category_news_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_images.dart';
import '../add_news/add_news_screen.dart';

class FloatingActionButtonCustom extends StatelessWidget {
  const FloatingActionButtonCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: MyColor.secondaryColor,
      foregroundColor: Colors.white,
      children: [
        SpeedDialChild(
          child: SvgPicture.asset(
            MyImages.addNews,
          ),
          label: MyStrings.buatBeritaDanTips,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddNewsScreen(),
              ),
            );
          },
        ),
        SpeedDialChild(
          child: SvgPicture.asset(
            MyImages.addCategory,
          ),
          label: MyStrings.buatCategory,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  CategoryNewsScreen(),
              ),
            );
          },
        ),
        
      ],
    );
  }
}
