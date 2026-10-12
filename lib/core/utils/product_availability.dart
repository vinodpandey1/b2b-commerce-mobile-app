import '../constants/cartStorage.dart';
import '../models/userModel.dart';

int purchaseLimit(Product product) =>
    product.status ? product.stock.clamp(0, CartStorage.maxItemQuantity) : 0;
String? cartAvailabilityError(Product? product, int quantity) {
  if (product == null || !product.status) return 'This product is unavailable';
  if (product.stock <= 0) return 'Out of stock';
  if (quantity > product.stock) return 'Only ${product.stock} available';
  if (quantity > CartStorage.maxItemQuantity) {
    return 'Maximum ${CartStorage.maxItemQuantity} per product';
  }
  if (quantity < 1) return 'Select at least one item';
  return null;
}
