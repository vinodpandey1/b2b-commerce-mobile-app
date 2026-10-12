import 'package:EazySupplies/core/utils/responsive.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';

class CouponCodeField extends StatefulWidget {
  const CouponCodeField({
    super.key,
  });

  @override
  State<CouponCodeField> createState() => _CouponCodeFieldState();
}

class _CouponCodeFieldState extends State<CouponCodeField> {
  late TextEditingController controller;

  bool isFilled = false;

  void onChange(String? text) {
    if (text != null && text.isNotEmpty) {
      isFilled = true;
      setState(() {});
    } else {
      isFilled = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Add Coupon',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          SizedBox(height: Responsive.hp(context, 16 / 8)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Entry Voucher Code',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppDefaults.padding,
                    ),
                  ),
                  onChanged: onChange,
                  controller: controller,
                ),
              ),
              SizedBox(width: Responsive.wp(context, 16 / 4)),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: isFilled ? null : AppColors.placeholder,
                    backgroundColor:
                        isFilled ? null : Colors.grey.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
