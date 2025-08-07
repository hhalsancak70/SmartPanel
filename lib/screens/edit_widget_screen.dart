import 'package:flutter/material.dart';
import '../models/panel_widget_model.dart';
import '../services/storage_service.dart';

class EditWidgetScreen extends StatefulWidget {
  final PanelWidgetModel widget;

  const EditWidgetScreen({
    super.key,
    required this.widget,
  });

  @override
  State<EditWidgetScreen> createState() => _EditWidgetScreenState();
}

class _EditWidgetScreenState extends State<EditWidgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();

  late TextEditingController _titleController;
  late TextEditingController _topicController;
  late TextEditingController _subscribeTopicController;
  late TextEditingController _onMessageController;
  late TextEditingController _offMessageController;
  late TextEditingController _minValueController;
  late TextEditingController _maxValueController;
  late IconData _selectedIcon;
  late PanelWidgetType _selectedType;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.widget.title);
    _topicController = TextEditingController(text: widget.widget.topic);
    _subscribeTopicController = TextEditingController(text: widget.widget.subscribeTopic);
    _onMessageController = TextEditingController(text: widget.widget.onMessage);
    _offMessageController = TextEditingController(text: widget.widget.offMessage);
    _minValueController = TextEditingController(
      text: widget.widget.minValue?.toString() ?? '0',
    );
    _maxValueController = TextEditingController(
      text: widget.widget.maxValue?.toString() ?? '100',
    );
    _selectedIcon = widget.widget.icon;
    _selectedType = widget.widget.type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    _subscribeTopicController.dispose();
    _onMessageController.dispose();
    _offMessageController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedWidget = PanelWidgetModel(
      id: widget.widget.id,
      title: _titleController.text,
      icon: _selectedIcon,
      type: _selectedType,
      topic: _topicController.text,
      subscribeTopic: _subscribeTopicController.text.isEmpty
          ? null
          : _subscribeTopicController.text,
      onMessage: _selectedType != PanelWidgetType.slider
          ? _onMessageController.text
          : null,
      offMessage: _selectedType != PanelWidgetType.slider
          ? _offMessageController.text
          : null,
      minValue: _selectedType == PanelWidgetType.slider
          ? double.parse(_minValueController.text)
          : null,
      maxValue: _selectedType == PanelWidgetType.slider
          ? double.parse(_maxValueController.text)
          : null,
      currentValue: _selectedType == PanelWidgetType.slider
          ? widget.widget.currentValue
          : null,
      isActive: widget.widget.isActive,
    );

    try {
      await _storageService.updateWidget(updatedWidget);
      if (mounted) {
        Navigator.pop(context, updatedWidget);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Widget güncellenirken bir hata oluştu!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Düzenle'),
        backgroundColor: const Color(0xFF2B7CD3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: _titleController,
              label: 'Başlık',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Başlık boş olamaz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildIconSelector(),
            const SizedBox(height: 16),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _topicController,
              label: 'Topic',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Topic boş olamaz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _subscribeTopicController,
              label: 'Subscribe Topic (Opsiyonel)',
            ),
            const SizedBox(height: 16),
            if (_selectedType != PanelWidgetType.slider) ...[
              _buildTextField(
                controller: _onMessageController,
                label: 'Açık Mesajı',
                validator: (value) {
                  if (_selectedType != PanelWidgetType.slider &&
                      (value == null || value.isEmpty)) {
                    return 'Açık mesajı boş olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _offMessageController,
                label: 'Kapalı Mesajı',
                validator: (value) {
                  if (_selectedType != PanelWidgetType.slider &&
                      (value == null || value.isEmpty)) {
                    return 'Kapalı mesajı boş olamaz';
                  }
                  return null;
                },
              ),
            ] else ...[
              _buildTextField(
                controller: _minValueController,
                label: 'Minimum Değer',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_selectedType == PanelWidgetType.slider) {
                    if (value == null || value.isEmpty) {
                      return 'Minimum değer boş olamaz';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Geçerli bir sayı giriniz';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _maxValueController,
                label: 'Maximum Değer',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_selectedType == PanelWidgetType.slider) {
                    if (value == null || value.isEmpty) {
                      return 'Maximum değer boş olamaz';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Geçerli bir sayı giriniz';
                    }
                    if (double.parse(value) <=
                        double.parse(_minValueController.text)) {
                      return 'Maximum değer minimum değerden büyük olmalı';
                    }
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B7CD3),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  Widget _buildIconSelector() {
    final icons = [
      Icons.lightbulb_outline,
      Icons.power_settings_new,
      Icons.thermostat,
      Icons.water_drop,
      Icons.air,
      Icons.door_front_door,
      Icons.window,
      Icons.tv,
      Icons.speaker,
      Icons.kitchen,
      Icons.garage,
      Icons.curtains,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İkon',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: icons.length,
            itemBuilder: (context, index) {
              final icon = icons[index];
              final isSelected = icon == _selectedIcon;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2B7CD3).withOpacity(0.1)
                        : null,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2B7CD3)
                          : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? const Color(0xFF2B7CD3)
                        : const Color(0xFF666666),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tip',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildTypeOption(
                title: 'Buton',
                type: PanelWidgetType.button,
                icon: Icons.touch_app,
              ),
              const Divider(height: 1),
              _buildTypeOption(
                title: 'Anahtar',
                type: PanelWidgetType.switch_,
                icon: Icons.toggle_on,
              ),
              const Divider(height: 1),
              _buildTypeOption(
                title: 'Kaydırıcı',
                type: PanelWidgetType.slider,
                icon: Icons.tune,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption({
    required String title,
    required PanelWidgetType type,
    required IconData icon,
  }) {
    final isSelected = type == _selectedType;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2B7CD3).withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2B7CD3) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? const Color(0xFF2B7CD3) : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Color(0xFF2B7CD3),
              ),
          ],
        ),
      ),
    );
  }
}
