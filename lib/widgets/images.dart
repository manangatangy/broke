

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
      )).toList();
}

