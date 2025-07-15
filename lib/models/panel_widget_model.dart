import 'package:flutter/material.dart';

enum PanelWidgetType {
  button,
  switch_,
  slider,
}

// Sabit icon haritası
const Map<int, IconData> iconMap = {
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

class PanelWidgetModel {
  final String id;
  final String title;
  final IconData icon;
  final PanelWidgetType type;
  final String topic;
  final String? onMessage;
  final String? offMessage;
  final double? minValue;
  final double? maxValue;
  bool isActive;
  double? currentValue;

  PanelWidgetModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.type,
    required this.topic,
    this.onMessage,
    this.offMessage,
    this.minValue,
    this.maxValue,
    this.isActive = false,
    this.currentValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'iconData': icon.codePoint,
      'type': type.toString(),
      'topic': topic,
      'onMessage': onMessage,
      'offMessage': offMessage,
      'minValue': minValue,
      'maxValue': maxValue,
      'isActive': isActive,
      'currentValue': currentValue,
    };
  }

  factory PanelWidgetModel.fromJson(Map<String, dynamic> json) {
    final iconCodePoint = json['iconData'] as int;
    final iconData = iconMap[iconCodePoint] ?? Icons.lightbulb_outline;

    return PanelWidgetModel(
      id: json['id'],
      title: json['title'],
      icon: iconData,
      type: PanelWidgetType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      topic: json['topic'],
      onMessage: json['onMessage'],
      offMessage: json['offMessage'],
      minValue: json['minValue']?.toDouble(),
      maxValue: json['maxValue']?.toDouble(),
      isActive: json['isActive'] ?? false,
      currentValue: json['currentValue']?.toDouble(),
    );
  }
} 