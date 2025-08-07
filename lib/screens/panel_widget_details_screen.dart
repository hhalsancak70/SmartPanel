import 'package:flutter/material.dart';
import '../models/panel_widget_model.dart';
import '../services/storage_service.dart';
import 'edit_widget_screen.dart';

class PanelWidgetDetailsScreen extends StatelessWidget {
  final PanelWidgetModel widget;

  const PanelWidgetDetailsScreen({
    super.key,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF2B7CD3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Hero(
        tag: 'panel_widget_${widget.id}',
        child: Material(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(
                  icon: widget.icon,
                  title: widget.title,
                  isActive: widget.isActive,
                ),
                const SizedBox(height: 24),
                _buildDetailSection(
                  title: 'Genel Bilgiler',
                  children: [
                    _buildDetailRow('Tip', _getWidgetTypeName(widget.type)),
                    _buildDetailRow('Durum', widget.isActive ? 'Aktif' : 'Pasif'),
                    _buildDetailRow('Topic', widget.topic),
                    if (widget.subscribeTopic != null)
                      _buildDetailRow('Subscribe Topic', widget.subscribeTopic!),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.type != PanelWidgetType.slider) ...[
                  _buildDetailSection(
                    title: 'Mesajlar',
                    children: [
                      _buildDetailRow('Açık Mesajı', widget.onMessage ?? '-'),
                      _buildDetailRow('Kapalı Mesajı', widget.offMessage ?? '-'),
                    ],
                  ),
                ] else ...[
                  _buildDetailSection(
                    title: 'Değer Aralığı',
                    children: [
                      _buildDetailRow('Minimum Değer', '${widget.minValue}'),
                      _buildDetailRow('Maximum Değer', '${widget.maxValue}'),
                      _buildDetailRow('Mevcut Değer', '${widget.currentValue}'),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                _buildControlSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getWidgetTypeName(PanelWidgetType type) {
    switch (type) {
      case PanelWidgetType.button:
        return 'Buton';
      case PanelWidgetType.switch_:
        return 'Anahtar';
      case PanelWidgetType.slider:
        return 'Kaydırıcı';
    }
  }

  Widget _buildInfoCard(
      {required IconData icon, required String title, required bool isActive}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF2B7CD3).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: isActive ? const Color(0xFF2B7CD3) : Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getWidgetTypeName(widget.type),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B7CD3),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kontroller',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B7CD3),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push<PanelWidgetModel>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditWidgetScreen(widget: widget),
                    ),
                  );
                  if (result != null && context.mounted) {
                    Navigator.pop(context); // Detay sayfasını kapat
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B7CD3),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Düzenle'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // TODO: Silme işlemi için onay dialogu göster
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Bileşeni Sil'),
                      content: Text(
                        '${widget.title} bileşenini silmek istediğinize emin misiniz?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context); // Dialog'u kapat
                            Navigator.pop(context); // Detay sayfasını kapat
                            try {
                              await StorageService().deleteWidget(widget.id);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Widget silinirken bir hata oluştu!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Sil',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sil'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
