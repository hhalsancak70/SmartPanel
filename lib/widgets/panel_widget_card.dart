import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/panel_widget_model.dart';

class PanelWidgetCard extends StatelessWidget {
  final PanelWidgetModel widget;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(bool) onToggle;
  final Function(double)? onSliderChanged;
  final Function(double)? onSliderChangeEnd;

  const PanelWidgetCard({
    super.key,
    required this.widget,
    required this.onTap,
    required this.onLongPress,
    required this.onToggle,
    this.onSliderChanged,
    this.onSliderChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'panel_widget_${widget.id}',
      child: Card(
        elevation: widget.isActive ? 4 : 2,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: _CardContent(
            widget: widget,
            onToggle: onToggle,
            onSliderChanged: onSliderChanged,
            onSliderChangeEnd: onSliderChangeEnd,
          ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final PanelWidgetModel widget;
  final Function(bool) onToggle;
  final Function(double)? onSliderChanged;
  final Function(double)? onSliderChangeEnd;

  const _CardContent({
    required this.widget,
    required this.onToggle,
    this.onSliderChanged,
    this.onSliderChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: widget.isActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _IconWidget(
            icon: widget.icon,
            isActive: widget.isActive,
          ),
          const SizedBox(height: 12),
          _TitleWidget(
            title: widget.title,
            isActive: widget.isActive,
          ),
          const SizedBox(height: 16),
          _ControlWidget(
            widget: widget,
            onToggle: onToggle,
            onSliderChanged: onSliderChanged,
            onSliderChangeEnd: onSliderChangeEnd,
          ),
        ],
      ),
    );
  }
}

class _IconWidget extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const _IconWidget({
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 40,
      color: isActive
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          duration: const Duration(seconds: 2),
          color: isActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Colors.transparent,
        );
  }
}

class _TitleWidget extends StatelessWidget {
  final String title;
  final bool isActive;

  const _TitleWidget({
    required this.title,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isActive ? Theme.of(context).colorScheme.primary : null,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ControlWidget extends StatelessWidget {
  final PanelWidgetModel widget;
  final Function(bool) onToggle;
  final Function(double)? onSliderChanged;
  final Function(double)? onSliderChangeEnd;

  const _ControlWidget({
    required this.widget,
    required this.onToggle,
    this.onSliderChanged,
    this.onSliderChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case PanelWidgetType.button:
        return _ButtonControl(
          widget: widget,
          onToggle: onToggle,
        );
      case PanelWidgetType.switch_:
        return _SwitchControl(
          isActive: widget.isActive,
          onToggle: onToggle,
        );
      case PanelWidgetType.slider:
        return _SliderControl(
          widget: widget,
          onSliderChanged: onSliderChanged,
          onSliderChangeEnd: onSliderChangeEnd,
        );
    }
  }
}

class _ButtonControl extends StatelessWidget {
  final PanelWidgetModel widget;
  final Function(bool) onToggle;

  const _ButtonControl({
    required this.widget,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onToggle(!widget.isActive),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceVariant,
        foregroundColor: widget.isActive
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        elevation: widget.isActive ? 4 : 0,
      ).copyWith(
        elevation: MaterialStateProperty.resolveWith<double>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return 8;
            }
            return widget.isActive ? 4 : 0;
          },
        ),
      ),
      child: Text(widget.isActive ? widget.onMessage! : widget.offMessage!),
    ).animate(target: widget.isActive ? 1 : 0).scale(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
        );
  }
}

class _SwitchControl extends StatelessWidget {
  final bool isActive;
  final Function(bool) onToggle;

  const _SwitchControl({
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isActive,
      onChanged: onToggle,
    ).animate(target: isActive ? 1 : 0).scale(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
  }
}

class _SliderControl extends StatelessWidget {
  final PanelWidgetModel widget;
  final Function(double)? onSliderChanged;
  final Function(double)? onSliderChangeEnd;

  const _SliderControl({
    required this.widget,
    required this.onSliderChanged,
    required this.onSliderChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
            thumbColor: Theme.of(context).colorScheme.primary,
            overlayColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
          child: Slider(
            value: widget.currentValue ?? widget.minValue!,
            min: widget.minValue!,
            max: widget.maxValue!,
            onChanged: onSliderChanged,
            onChangeEnd: onSliderChangeEnd,
          ),
        ),
        Text(
          '${widget.currentValue?.toStringAsFixed(1) ?? widget.minValue!.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 