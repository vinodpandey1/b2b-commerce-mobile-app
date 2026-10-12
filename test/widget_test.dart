import 'package:EazySupplies/core/constants/api_config.dart';
import 'package:EazySupplies/core/models/userModel.dart';
import 'package:EazySupplies/core/utils/brand_image_url.dart';
import 'package:EazySupplies/core/utils/product_image_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('production configuration', () {
    test('uses the secure production API', () {
      expect(ApiConfig.baseUrl, 'https://api.eazysupplies.com/api');
    });

    test('uses the live customer password recovery endpoint', () {
      expect(
        ApiConfig.passwordReset,
        'https://api.eazysupplies.com/api/auth/login_auth',
      );
    });

    test('encodes product image filenames safely', () {
      final url = buildProductImageUrl('folder/Product image (1).jpg');
      final uri = Uri.parse(url);

      expect(uri.scheme, 'https');
      expect(uri.host, 'api.eazysupplies.com');
      expect(uri.queryParameters['file'], 'folder/Product image (1).jpg');
    });

    test('resolves brand assets against the production host', () {
      expect(
        buildBrandImageUrl('/assets/images/brands/royal-grove.png'),
        'https://api.eazysupplies.com/assets/images/brands/royal-grove.png',
      );
    });

    test('offers only payment methods supported by the API', () {
      expect(
        PaymentMethod.values.map((method) => method.id),
        orderedEquals(['NB', 'OFF']),
      );
    });
  });
}
