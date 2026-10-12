import 'package:EazySupplies/core/utils/responsive.dart';
import 'package:flutter/material.dart';

import '../../../core/components/app_radio.dart';
import '../../../core/constants/constants.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.label,
    required this.phoneNumber,
    required this.address,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String phoneNumber;
  final String address;
  final bool isActive;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDefaults.padding,
        vertical: AppDefaults.padding / 2,
      ),
      child: Material(
        color: isActive
            ? AppColors.coloredBackground
            : AppColors.textInputBackground,
        borderRadius: AppDefaults.borderRadius,
        child: InkWell(
          borderRadius: AppDefaults.borderRadius,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppDefaults.padding),
            decoration: BoxDecoration(
              borderRadius: AppDefaults.borderRadius,
              border: Border.all(
                color: isActive ? AppColors.primary : Colors.grey,
                width: isActive ? 1 : 0.3,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppRadio(isActive: isActive),
                SizedBox(width: Responsive.wp(context, 16 / 4)),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                    ),
                    SizedBox(height: Responsive.hp(context, 8 / 8)),
                    Text(
                      phoneNumber,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                    SizedBox(height: Responsive.hp(context, 8 / 8)),
                    // Wrap the address in Expanded to prevent overflow
                    Text(address, softWrap: true),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
