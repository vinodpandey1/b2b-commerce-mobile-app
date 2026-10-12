import 'package:flutter/material.dart';
import '../models/userModel.dart';
import 'product_tile_square.dart';

class BundleTileSquare extends StatelessWidget {
  const BundleTileSquare({super.key, required this.data});
  final Product data;
  @override
  Widget build(BuildContext context) => ProductTileSquare(data: data);
}
