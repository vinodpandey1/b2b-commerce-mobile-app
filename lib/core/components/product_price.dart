import 'package:flutter/material.dart';
import '../models/userModel.dart';

class ProductPrice extends StatelessWidget {
  const ProductPrice({super.key, required this.product, this.fontSize = 17});
  final Product product;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final mrp = product.mrp;
    final discounted = mrp != null && mrp > product.price && product.price >= 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('₹${product.price.toStringAsFixed(2)}',
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700)),
      Text(
          'per ${product.skuType?.trim().isNotEmpty == true ? product.skuType!.trim() : 'pack'}',
          style: const TextStyle(fontSize: 11, color: Color(0xFF69746D))),
      if (discounted) ...[
        Text('MRP ₹${mrp.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                decoration: TextDecoration.lineThrough)),
        Text('${((mrp - product.price) / mrp * 100).toStringAsFixed(2)}% off',
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF99602C),
                fontWeight: FontWeight.w600)),
        Text('Save ₹${(mrp - product.price).toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF168345),
                fontWeight: FontWeight.w600)),
      ],
    ]);
  }
}
