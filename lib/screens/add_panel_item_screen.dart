import 'package:flutter/material.dart';
import '../models/panel_item.dart';

class AddPanelItemScreen extends StatefulWidget {
  const AddPanelItemScreen({super.key});

  @override
  State<AddPanelItemScreen> createState() => _AddPanelItemScreenState();
}

class _AddPanelItemScreenState extends State<AddPanelItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _topicController = TextEditingController();
  IconData _selectedIcon = Icons.lightbulb_outline;

  final List<IconData> _availableIcons = [
    Icons.lightbulb_outline,
    Icons.thermostat,
    Icons.door_sliding,
    Icons.window,
    Icons.tv,
    Icons.speaker,
    Icons.camera_outdoor,
    Icons.power,
    Icons.air,
    Icons.water_drop,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Bileşen Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Başlık',
                hintText: 'Örn: Salon Lambası',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir başlık giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'MQTT Topic',
                hintText: 'Örn: home/livingroom/light',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir topic giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'İkon Seçin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _availableIcons.map((icon) {
                final isSelected = icon == _selectedIcon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 32),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newItem = PanelItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text,
                    icon: _selectedIcon,
                    topic: _topicController.text,
                  );
                  Navigator.pop(context, newItem);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Bileşen Ekle'),
            ),
          ],
        ),
      ),
    );
  }
} 