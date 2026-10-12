import 'package:flutter/material.dart';

import '../constants/constants.dart';

class TitleAndActionButton extends StatelessWidget {
  const TitleAndActionButton({
    super.key,
    required this.title,
    this.actionLabel,
    required this.onTap,
    this.isHeadline = false,
  });

  final String title;
  final String? actionLabel;
  final void Function() onTap;
  final bool isHeadline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: (isHeadline
                          ? Theme.of(context).textTheme.headlineSmall
                          : Theme.of(context).textTheme.titleMedium)
                      ?.copyWith(
                          color: const Color(0xFF20362A),
                          fontWeight: FontWeight.w700))),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onTap,
            child: Text(actionLabel ?? 'View All'),
          ),
        ],
      ),
    );
  }
}
