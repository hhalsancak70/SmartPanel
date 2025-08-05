import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/panel_widget_model.dart';

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
        title: const Text('Yeni Panel Bileşeni'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<PanelWidgetType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Bileşen Türü',
                border: OutlineInputBorder(),
              ),
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
              decoration: const InputDecoration(
                labelText: 'Başlık',
                border: OutlineInputBorder(),
              ),
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
              decoration: const InputDecoration(
                labelText: 'Yayın Topic\'i (Publish)',
                border: OutlineInputBorder(),
                hintText: 'örn: home/living_room/light/set',
              ),
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
              decoration: const InputDecoration(
                labelText: 'Dinleme Topic\'i (Subscribe)',
                border: OutlineInputBorder(),
                hintText: 'örn: home/living_room/light/state',
                helperText: 'Boş bırakılabilir',
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedType == PanelWidgetType.button) ...[
              TextFormField(
                controller: _onMessageController,
                decoration: const InputDecoration(
                  labelText: 'Açık Mesajı',
                  border: OutlineInputBorder(),
                ),
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
                decoration: const InputDecoration(
                  labelText: 'Kapalı Mesajı',
                  border: OutlineInputBorder(),
                ),
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
                decoration: const InputDecoration(
                  labelText: 'Minimum Değer',
                  border: OutlineInputBorder(),
                ),
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
                decoration: const InputDecoration(
                  labelText: 'Maximum Değer',
                  border: OutlineInputBorder(),
                ),
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
            const Text(
              'İkon Seçin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableIcons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveWidget,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
} 