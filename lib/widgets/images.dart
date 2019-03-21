

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const List<String> IconList = const<String>[
  'bicycle',
  'bunny',
  'car',
  'cat',
  'coins',
  'credit',
  'dance',
  'diploma',
  'doughnut',
  'first-aid-kit',
  'football',
  'groceries',
  'hand-money',
  'hanger',
  'laptop',
  'makeup',
  'mascara',
  'mobile-app',
  'mobile-phone',
  'money-bag',
  'mortarboard',
  'photo-camera',
  'pint',
  'shopping-bag',
  'stethoscope',
  'sunset',
  'tiger',
  'video-camera',
  'world',
];

List<Widget> getIcons(double iconSize) {
  return IconList.map((category) => Tab(
      icon: ImageIcon(
        AssetImage('assets/icons/' + category + '.png'),
          size: iconSize,
        ),
      ),
  ).toList();
}

const Map<String, String> CatMap = const<String, String>{
  'bicycle': 'Bike',
  'bunny': 'Misc',
  'car': 'Car',
  'cat': 'Offset',
  'coins': 'Cash',
  'credit': 'Board',
  'dance': 'Party',
  'diploma': 'Course',
  'doughnut': null,
  'first-aid-kit': null,
  'football': null,
  'groceries': null,
  'hand-money': 'Debt',
  'hanger': 'Clothes',
  'laptop': 'Computer',
  'makeup': 'TafeCourse',
  'mascara': 'Cosmetics',
  'mobile-app': null,
  'mobile-phone': 'Phone',
  'money-bag': 'Money',
  'mortarboard': 'Hecs',
  'photo-camera': 'Camera',
  'pint': 'Alcohol',
  'shopping-bag': 'Gift',
  'stethoscope': 'Medical',
  'sunset': 'RussiaTrip',
  'tiger': 'Tigrettes',
  'video-camera': null,
  'world': 'Travel',
};

Map<String, String> iconMap;

ImageIcon getIconForCategory(String category) {
  if (iconMap == null) {
    iconMap = <String, String>{};
    CatMap.keys.where((String key) => CatMap[key] != null).forEach((String key) => iconMap[CatMap[key]] = key);
    print('iconMap created: $iconMap');
  }
  print('iconMap[category]: ${iconMap[category]}');

  return ImageIcon(
    AssetImage('assets/icons/' + iconMap[category] + '.png'),
    size: 32.0,
  );
}
