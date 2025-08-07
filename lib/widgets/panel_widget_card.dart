import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/panel_widget_model.dart';

// Renk ve stil sabitleri
const kPrimaryColor = Color(0xFF2B7CD3);
const kCardBackgroundColor = Color(0xFFF9F9FC);
const kTextDarkColor = Color(0xFF333333);
const kTextMediumColor = Color(0xFF666666);
const kButtonLabelColor = Color(0xFFB0BEC5);

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: kCardBackgroundColor,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            onLongPress();
          },
          borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: widget.isActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kPrimaryColor.withOpacity(0.1),
                  kPrimaryColor.withOpacity(0.05),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(12),
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
            onToggle: (value) {
              HapticFeedback.selectionClick();
              onToggle(value);
            },
            onSliderChanged: onSliderChanged != null
                ? (value) {
                    HapticFeedback.selectionClick();
                    onSliderChanged!(value);
                  }
                : null,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? kPrimaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? kPrimaryColor : kButtonLabelColor.withOpacity(0.3),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
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
        size: 32,
        color: isActive ? kPrimaryColor : kTextMediumColor,
      ),
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
        fontWeight: FontWeight.w600,
        color: isActive ? kPrimaryColor : kTextDarkColor,
        letterSpacing: 0.2,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.diagonal3Values(
        widget.isActive ? 1.0 : 0.95,
        widget.isActive ? 1.0 : 0.95,
        1.0,
      ),
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            onToggle(!widget.isActive);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isActive ? kPrimaryColor : Colors.white,
            foregroundColor: widget.isActive ? Colors.white : kTextMediumColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: widget.isActive ? kPrimaryColor : kButtonLabelColor,
                width: widget.isActive ? 2 : 1,
              ),
            ),
          ),
          child: Text(
            widget.isActive ? widget.onMessage! : widget.offMessage!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.diagonal3Values(
        isActive ? 1.0 : 0.95,
        isActive ? 1.0 : 0.95,
        1.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? kPrimaryColor : kButtonLabelColor,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Switch.adaptive(
          value: isActive,
          onChanged: (value) {
            HapticFeedback.mediumImpact();
            onToggle(value);
          },
          activeColor: kPrimaryColor,
          activeTrackColor: kPrimaryColor.withOpacity(0.2),
        ),
      ),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.diagonal3Values(
        widget.isActive ? 1.0 : 0.95,
        widget.isActive ? 1.0 : 0.95,
        1.0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isActive ? kPrimaryColor : kButtonLabelColor,
            width: widget.isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: kPrimaryColor,
                inactiveTrackColor: kPrimaryColor.withOpacity(0.2),
                thumbColor: kPrimaryColor,
                overlayColor: kPrimaryColor.withOpacity(0.1),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8,
                  pressedElevation: 8,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 16,
                ),
              ),
              child: Slider(
                value: widget.currentValue ?? widget.minValue!,
                min: widget.minValue!,
                max: widget.maxValue!,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  onSliderChanged?.call(value);
                },
                onChangeEnd: onSliderChangeEnd,
              ),
            ),
            Text(
              '${widget.currentValue?.toStringAsFixed(1) ?? widget.minValue!.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 16,
                color: kPrimaryColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 