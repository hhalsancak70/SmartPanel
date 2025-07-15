import 'package:flutter/material.dart';

// Sabit icon haritası
const Map<int, IconData> panelIconMap = {
  0xe3a8: Icons.lightbulb_outline,    // Varsayılan icon
  0xe318: Icons.home,                 // Ev
  0xe57f: Icons.settings,             // Ayarlar
  0xf050: Icons.thermostat_outlined,  // Termostat
  0xe31c: Icons.door_sliding,         // Kapı
  0xe335: Icons.air,                  // Fan/Havalandırma
  0xe50c: Icons.light,                // Işık
  0xe375: Icons.water,                // Su
  0xe1f6: Icons.power,                // Güç
  0xe2e7: Icons.light_mode,           // Aydınlatma modu
  0xe1e1: Icons.sensors,              // Sensörler
  0xe3da: Icons.motion_photos_auto,   // Hareket
  0xe3a6: Icons.sunny,                // Güneş/Aydınlık
  0xe3ab: Icons.lock,                 // Kilit
  0xe3ac: Icons.lock_open,            // Kilit açık
  0xe42a: Icons.security,             // Güvenlik
  0xe4b6: Icons.tv,                   // TV
  0xe4e1: Icons.water_drop,           // Su damlası
  0xe4f7: Icons.window,               // Pencere
};

class PanelItem {
  final String id;
  final String title;
  final IconData icon;
  bool isActive;
  final String topic;

  PanelItem({
    required this.id,
    required this.title,
    required this.icon,
    this.isActive = false,
    required this.topic,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'iconData': icon.codePoint,
      'isActive': isActive,
      'topic': topic,
    };
  }

  factory PanelItem.fromJson(Map<String, dynamic> json) {
    final iconCodePoint = json['iconData'] as int;
    final iconData = panelIconMap[iconCodePoint] ?? Icons.lightbulb_outline;

    return PanelItem(
      id: json['id'],
      title: json['title'],
      icon: iconData,
      isActive: json['isActive'],
      topic: json['topic'],
    );
  }
} 