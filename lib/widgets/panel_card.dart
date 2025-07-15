import 'package:flutter/material.dart';
import '../models/panel_item.dart';

class PanelCard extends StatelessWidget {
  final PanelItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const PanelCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Bileşeni Sil'),
              content: Text('${item.title} bileşenini silmek istediğinize emin misiniz?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                  child: const Text('Sil', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Switch(
                value: item.isActive,
                onChanged: onToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 