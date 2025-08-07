import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/panel_widget_model.dart';

// Renk ve stil sabitleri
const kPrimaryColor = Color(0xFF2B7CD3);
const kBackgroundColor = Color(0xFFFAFAFA);
const kBorderColor = Color(0xFFCCCCCC);
const kTextDarkColor = Color(0xFF333333);
const kTextMediumColor = Color(0xFF666666);
const kTextLightColor = Color(0xFF999999);
const kErrorColor = Color(0xFFE53935);

// Stil sabitleri
const kInputDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: kBorderColor),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: kBorderColor),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: kPrimaryColor, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: kErrorColor),
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
);

class AddWidgetScreen extends StatefulWidget {
  const AddWidgetScreen({super.key});

  @override
  State<AddWidgetScreen> createState() => _AddWidgetScreenState();
}

class _AddWidgetScreenState extends State<AddWidgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _topicController = TextEditingController();
  final _subscribeTopicController = TextEditingController();
  final _minValueController = TextEditingController(text: '0');
  final _maxValueController = TextEditingController(text: '100');
  final _onMessageController = TextEditingController(text: 'AÇIK');
  final _offMessageController = TextEditingController(text: 'KAPALI');

  PanelWidgetType _selectedType = PanelWidgetType.button;
  IconData _selectedIcon = Icons.lightbulb_outline;

  final List<IconData> _availableIcons = [
    Icons.lightbulb_outline,
    Icons.light,
    Icons.door_sliding,
    Icons.garage,
    Icons.air,
    Icons.thermostat,
    Icons.water_drop,
    Icons.power,
    Icons.tv,
    Icons.speaker,
    Icons.camera,
    Icons.security,
    Icons.window,
    Icons.curtains,
    Icons.blinds,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    _subscribeTopicController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    _onMessageController.dispose();
    _offMessageController.dispose();
    super.dispose();
  }

  void _saveWidget() {
    if (!_formKey.currentState!.validate()) return;

    final widget = PanelWidgetModel(
      id: const Uuid().v4(),
      title: _titleController.text,
      topic: _topicController.text,
      subscribeTopic: _subscribeTopicController.text.isEmpty 
          ? null 
          : _subscribeTopicController.text,
      type: _selectedType,
      icon: _selectedIcon,
      isActive: false,
      minValue: _selectedType == PanelWidgetType.slider
          ? double.parse(_minValueController.text)
          : null,
      maxValue: _selectedType == PanelWidgetType.slider
          ? double.parse(_maxValueController.text)
          : null,
      currentValue: _selectedType == PanelWidgetType.slider
          ? double.parse(_minValueController.text)
          : null,
      onMessage: _selectedType == PanelWidgetType.button
          ? _onMessageController.text
          : null,
      offMessage: _selectedType == PanelWidgetType.button
          ? _offMessageController.text
          : null,
    );

    Navigator.pop(context, widget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Yeni Panel Bileşeni',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: kBackgroundColor,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<PanelWidgetType>(
              value: _selectedType,
              decoration: kInputDecoration.copyWith(
                labelText: 'Bileşen Türü',
                labelStyle: const TextStyle(color: kTextMediumColor),
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: kTextDarkColor),
              items: const [
                DropdownMenuItem(
                  value: PanelWidgetType.button,
                  child: Text('Buton'),
                ),
                DropdownMenuItem(
                  value: PanelWidgetType.switch_,
                  child: Text('Anahtar'),
                ),
                DropdownMenuItem(
                  value: PanelWidgetType.slider,
                  child: Text('Kaydırıcı'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: kInputDecoration.copyWith(
                labelText: 'Başlık',
                labelStyle: const TextStyle(color: kTextMediumColor),
                hintText: 'Bileşen başlığını girin',
              ),
              style: const TextStyle(color: kTextDarkColor),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir başlık girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _topicController,
              decoration: kInputDecoration.copyWith(
                labelText: 'Yayın Topic\'i (Publish)',
                labelStyle: const TextStyle(color: kTextMediumColor),
                hintText: 'örn: home/living_room/light/set',
                hintStyle: const TextStyle(color: kTextLightColor),
              ),
              style: const TextStyle(color: kTextDarkColor),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir topic girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subscribeTopicController,
              decoration: kInputDecoration.copyWith(
                labelText: 'Dinleme Topic\'i (Subscribe)',
                labelStyle: const TextStyle(color: kTextMediumColor),
                hintText: 'örn: home/living_room/light/state',
                hintStyle: const TextStyle(color: kTextLightColor),
                helperText: 'Boş bırakılabilir',
                helperStyle: const TextStyle(color: kTextLightColor),
              ),
              style: const TextStyle(color: kTextDarkColor),
            ),
            const SizedBox(height: 16),
            if (_selectedType == PanelWidgetType.button) ...[
              TextFormField(
                controller: _onMessageController,
                decoration: kInputDecoration.copyWith(
                  labelText: 'Açık Mesajı',
                  labelStyle: const TextStyle(color: kTextMediumColor),
                ),
                style: const TextStyle(color: kTextDarkColor),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen açık mesajını girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _offMessageController,
                decoration: kInputDecoration.copyWith(
                  labelText: 'Kapalı Mesajı',
                  labelStyle: const TextStyle(color: kTextMediumColor),
                ),
                style: const TextStyle(color: kTextDarkColor),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kapalı mesajını girin';
                  }
                  return null;
                },
              ),
            ],
            if (_selectedType == PanelWidgetType.slider) ...[
              TextFormField(
                controller: _minValueController,
                decoration: kInputDecoration.copyWith(
                  labelText: 'Minimum Değer',
                  labelStyle: const TextStyle(color: kTextMediumColor),
                ),
                style: const TextStyle(color: kTextDarkColor),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen minimum değer girin';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Lütfen geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxValueController,
                decoration: kInputDecoration.copyWith(
                  labelText: 'Maximum Değer',
                  labelStyle: const TextStyle(color: kTextMediumColor),
                ),
                style: const TextStyle(color: kTextDarkColor),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen maximum değer girin';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Lütfen geçerli bir sayı girin';
                  }
                  final min = double.parse(_minValueController.text);
                  final max = double.parse(value);
                  if (max <= min) {
                    return 'Maximum değer minimum değerden büyük olmalı';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'İkon Seçin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kTextDarkColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: _availableIcons.map((icon) {
                      final isSelected = _selectedIcon == icon;
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedIcon = icon);
                          HapticFeedback.lightImpact();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? kPrimaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? kPrimaryColor : kBorderColor,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: kPrimaryColor.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Icon(
                            icon,
                            color: isSelected ? Colors.white : kTextDarkColor,
                            size: 28,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: _saveWidget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                  shadowColor: kPrimaryColor.withOpacity(0.3),
                ),
                child: const Text(
                  'Kaydet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 