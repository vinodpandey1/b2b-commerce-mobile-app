import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper(
      {super.key,
      required this.value,
      required this.maximum,
      required this.onChanged,
      this.minimum = 0,
      this.enabled = true,
      this.accentColor});
  final int value;
  final int minimum;
  final int maximum;
  final bool enabled;
  final Color? accentColor;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDDE5E0)),
            borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              style: IconButton.styleFrom(
                  fixedSize: const Size(44, 44),
                  minimumSize: const Size(44, 44),
                  maximumSize: const Size(44, 44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              tooltip: 'Decrease quantity',
              onPressed: enabled && value > minimum
                  ? () => onChanged(value - 1)
                  : null,
              icon: const Icon(Icons.remove, size: 18),
              color: accentColor ?? AppColors.primary,
              disabledColor: Colors.grey.shade300,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 44),
              padding: EdgeInsets.zero),
          SizedBox(
              width: 26,
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('$value',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700)))),
          IconButton(
              style: IconButton.styleFrom(
                  fixedSize: const Size(44, 44),
                  minimumSize: const Size(44, 44),
                  maximumSize: const Size(44, 44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              tooltip: 'Increase quantity',
              onPressed: enabled && value < maximum
                  ? () => onChanged(value + 1)
                  : null,
              icon: const Icon(Icons.add, size: 18),
              color: accentColor ?? AppColors.primary,
              disabledColor: Colors.grey.shade300,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 44),
              padding: EdgeInsets.zero),
        ]),
      );
}
