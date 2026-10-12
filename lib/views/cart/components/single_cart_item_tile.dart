import 'package:flutter/material.dart';
import '../../../core/components/network_image.dart';
import '../../../core/components/quantity_stepper.dart';
import '../../../core/utils/product_image_url.dart';

class SingleCartItemTile extends StatelessWidget {
  const SingleCartItemTile(
      {super.key,
      required this.productId,
      required this.name,
      required this.quantity,
      required this.price,
      required this.imageUrl,
      required this.onQuantityChanged,
      required this.onRemove,
      this.maximum = 100,
      this.error,
      this.saving = false,
      this.onOpen});
  final String productId, name, imageUrl;
  final int quantity, maximum;
  final double price;
  final String? error;
  final bool saving;
  final void Function(String, int) onQuantityChanged;
  final void Function(String) onRemove;
  final VoidCallback? onOpen;
  @override
  Widget build(BuildContext context) {
    final urls = buildProductImageUrls(imageUrl);
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE3EAE5)),
            borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InkWell(
                onTap: onOpen,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                    width: 64,
                    height: 64,
                    child: urls.isEmpty
                        ? const Icon(Icons.inventory_2_outlined,
                            color: Colors.grey)
                        : NetworkImageWithLoader(urls.first,
                            fit: BoxFit.contain))),
            const SizedBox(width: 12),
            Expanded(
                child: InkWell(
                    onTap: onOpen,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text('₹${price.toStringAsFixed(2)} each',
                              style: const TextStyle(
                                  color: Color(0xFF66756B), fontSize: 12))
                        ]))),
            IconButton(
                tooltip: 'Remove $name',
                onPressed: saving ? null : () => onRemove(productId),
                icon: const Icon(Icons.delete_outline, size: 20)),
          ]),
          if (error != null)
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 13))),
          const SizedBox(height: 12),
          Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                QuantityStepper(
                    value: quantity,
                    maximum: maximum,
                    enabled: !saving,
                    onChanged: (qty) => qty == 0
                        ? onRemove(productId)
                        : onQuantityChanged(productId, qty)),
                Text('₹${(price * quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16))
              ]),
        ]));
  }
}
