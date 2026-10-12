import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:EazySupplies/core/constants/apiClients.dart';
import 'package:EazySupplies/core/constants/apiCall.dart';
import 'package:EazySupplies/core/constants/api_config.dart';
import 'package:EazySupplies/core/constants/cartStorage.dart';
import 'package:EazySupplies/core/constants/app_session.dart';
import 'package:EazySupplies/core/components/product_tile_square.dart';
import 'package:EazySupplies/core/components/quantity_stepper.dart';
import 'package:EazySupplies/core/models/userModel.dart';
import 'package:EazySupplies/core/routes/app_routes.dart';
import 'package:EazySupplies/core/themes/app_themes.dart';
import 'package:EazySupplies/core/utils/notification_content.dart';
import 'package:EazySupplies/core/utils/product_availability.dart';
import 'package:EazySupplies/views/cart/cart_page.dart';
import 'package:EazySupplies/views/cart/checkout_page.dart';
import 'package:EazySupplies/views/drawer/notification_page.dart';

Map<String, dynamic> productJson(int id,
        {int stock = 200, dynamic status = true}) =>
    {
      'id': id,
      'name': 'Premium basmati rice $id',
      'price': '125.50',
      'stock': '$stock',
      'status': status,
      'createdAt': '',
      'updatedAt': '',
      'pkgGwt': '1 kg',
      'mrp': '150'
    };
Product product(int id, {int stock = 200, dynamic status = true}) =>
    Product.fromJson(productJson(id, stock: stock, status: status));

class FakeApi implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  final products = <Map<String, dynamic>>[];
  bool guest = false;
  bool failOrders = false;
  Completer<void>? orderGate;
  final addresses = [
    {
      'id': 1,
      'userId': 1,
      'name': 'Office',
      'zipcode': '110001',
      'city': 'Delhi',
      'address': '12 Business Road',
      'createdAt': ''
    }
  ];
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    dynamic result = {'data': []};
    int status = 200;
    if (options.path.contains('/products')) {
      final ids = '${options.queryParameters['ids'] ?? ''}'.split(',');
      result = {
        'data': products
            .where((p) => ids.first.isEmpty || ids.contains('${p['id']}'))
            .toList()
      };
    } else if (options.path.contains('/auth/user')) {
      result = {
        'data': {'id': guest ? 0 : 1, 'name': 'Test Customer', 'orders': []}
      };
    } else if (options.path == ApiConfig.address) {
      result = {'data': addresses};
    } else if (options.method == 'POST' && options.path == ApiConfig.orders) {
      if (orderGate != null) await orderGate!.future;
      status = failOrders ? 503 : 201;
      result = failOrders
          ? {'error': 'Temporarily unavailable'}
          : {
              'data': {'id': 999}
            };
    } else if (options.path == '/notifications') {
      result = {
        'notifications': [
          {
            'id': 1,
            'name': 'Order Created with 208',
            'readStatus': false,
            'sentStatus': true,
            'remarks': '<div style="color:red">Order <b>208</b> created</div>',
            'createdAt': '2026-10-03T00:00:00Z'
          }
        ]
      };
    }
    return ResponseBody.fromString(jsonEncode(result), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType]
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final api = FakeApi();
  ApiClient.dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl))
    ..httpClientAdapter = api;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CartStorage.clearCart();
    await CartStorage.getCartItems();
    api.requests.clear();
    api.products.clear();
    api.guest = false;
    api.failOrders = false;
    api.orderGate = null;
  });
  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.runAsync(() => tester.tap(finder));
  }

  Future<void> settle(WidgetTester tester) async {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pumpAndSettle();
  }

  Future<void> pumpPage(WidgetTester tester, Widget page,
      {Size size = const Size(390, 844), double scale = 1}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.defaultTheme,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!),
        home: page,
        onGenerateRoute: (settings) => MaterialPageRoute(
            settings: settings,
            builder: (_) => Scaffold(body: Text('Route ${settings.name}')))));
    await settle(tester);
  }

  test('concurrent additions preserve every product and quantity after reload',
      () async {
    await Future.wait([
      for (var i = 1; i <= 20; i++) CartStorage.addToCart('$i', 1),
      for (var i = 0; i < 12; i++) CartStorage.addToCart('1', 1)
    ]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    expect((await CartStorage.getCartItems()).length, 20);
    expect(await CartStorage.getItemQty('1'), 13);
    expect(jsonDecode(prefs.getString('cart_items')!).length, 20);
  });
  test('legacy numeric IDs and string quantities remain editable', () async {
    SharedPreferences.setMockInitialValues(
        {'cart_items': '[{"id":1,"itemQty":"2"},{"id":"002","itemQty":3}]'});
    expect(await CartStorage.getItemQty('1'), 2);
    await CartStorage.setQuantity('2', 4);
    expect(await CartStorage.getItemQty('2'), 4);
    expect((await CartStorage.getCartItems()).length, 2);
  });
  test('stock limits reject additions without breaking subsequent saves',
      () async {
    await expectLater(
        CartStorage.addToCart('1', 5, maxQuantity: 4), throwsRangeError);
    await CartStorage.addToCart('2', 1);
    expect(await CartStorage.getItemQty('1'), 0);
    expect(await CartStorage.getItemQty('2'), 1);
    await expectLater(CartStorage.setQuantity('2', 101), throwsRangeError);
  });
  test('guest session and cart survive an application restart', () async {
    await AppSession.startGuestSession();
    await CartStorage.addToCart('7', 3);
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    expect(await AppSession.initialRoute(authenticated: false),
        AppRoutes.entryPoint);
    expect(await CartStorage.getItemQty('7'), 3);
  });
  test('onboarding is remembered when user has not started shopping', () async {
    expect(await AppSession.initialRoute(authenticated: false),
        AppRoutes.onboarding);
    await AppSession.completeOnboarding();
    expect(await AppSession.initialRoute(authenticated: false),
        AppRoutes.introLogin);
    await AppSession.initialRoute(authenticated: true);
    expect(await AppSession.initialRoute(authenticated: false),
        AppRoutes.entryPoint);
  });
  test('in-stock products parse with missing optional relations', () {
    final p = product(1, status: '1');
    expect(p.stock, 200);
    expect(p.price, 125.5);
    expect(p.status, true);
    expect(p.category.name, '');
    expect(p.brand.name, '');
    expect(purchaseLimit(p), 100);
    expect(cartAvailabilityError(product(2, status: false), 1), isNotNull);
    expect(cartAvailabilityError(product(2, stock: 0), 1), 'Out of stock');
    expect(cartAvailabilityError(product(2, stock: 2), 3), 'Only 2 available');
  });
  test('large saved carts fetch every product in bounded batches', () async {
    api.products.addAll([for (var i = 1; i <= 205; i++) productJson(i)]);
    expect(
        (await getProducts(
                ids: List.generate(205, (i) => i + 1), rethrowErrors: true))
            .length,
        205);
    expect(api.requests.length, 3);
  });
  test('notification previews remove markup CSS scripts and decode entities',
      () {
    expect(
        notificationText(
            '<style>.x{color:red}</style><script>alert(1)</script><div style="x">Rice &amp; tea<br>ready</div>'),
        'Rice & tea ready');
    final n = NotificationModel(
        id: 1,
        name: 'Order Created with 208',
        remarks: '',
        readStatus: false,
        sentStatus: true,
        createdAt: DateTime(2026));
    expect(notificationOrderId(n), 208);
  });
  testWidgets('minus is on the left and maximum plus remains disabled',
      (tester) async {
    int? changed;
    await pumpPage(
        tester,
        Scaffold(
            body: QuantityStepper(
                value: 100, maximum: 100, onChanged: (v) => changed = v)));
    expect(tester.getCenter(find.byTooltip('Decrease quantity')).dx,
        lessThan(tester.getCenter(find.byTooltip('Increase quantity')).dx));
    await tap(tester, find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(changed, isNull);
    await tap(tester, find.byTooltip('Decrease quantity'));
    expect(changed, 99);
  });
  testWidgets(
      'product cards select quantity add reliably and never navigate on disabled plus',
      (tester) async {
    await pumpPage(
        tester,
        Scaffold(
            body: SizedBox(
                width: 175,
                child: ProductTileSquare(data: product(1, stock: 2)))));
    await tap(tester, find.byTooltip('Increase quantity'));
    await tester.pump();
    await tap(tester, find.text('Add to cart'));
    await settle(tester);
    expect(CartStorage.quantities.value['1'], 2);
    expect(find.text('Added to cart'), findsOneWidget);
    await tap(tester, find.byTooltip('Increase quantity'));
    await settle(tester);
    expect(find.byType(ProductTileSquare), findsOneWidget);
    expect(find.text('Route ${AppRoutes.productDetails}'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('out-of-stock cards offer no purchase action', (tester) async {
    await pumpPage(
        tester,
        Scaffold(
            body: SizedBox(
                width: 175,
                child: ProductTileSquare(data: product(1, stock: 0)))));
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Add to cart'))
            .onPressed,
        isNull);
    expect(find.byType(QuantityStepper), findsNothing);
  });
  testWidgets('cart quantity updates preserve content without catalog reload',
      (tester) async {
    api.products.add(productJson(1));
    await tester.runAsync(() => CartStorage.addToCart('1', 1));
    await pumpPage(tester, const CartPage());
    final before = api.requests.length;
    await tap(tester, find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(find.text('Your cart'), findsOneWidget);
    expect(find.text('Premium basmati rice 1'), findsOneWidget);
    await settle(tester);
    expect(await tester.runAsync(() => CartStorage.getItemQty('1')), 2);
    expect(api.requests.length, before);
    expect(find.text('₹251.00'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'missing and unavailable cart items prevent checkout but can be removed',
      (tester) async {
    await tester.runAsync(() => CartStorage.addToCart('1', 1));
    await pumpPage(tester, const CartPage());
    final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Continue to checkout'));
    expect(button.onPressed, isNull);
    expect(find.text('This product is unavailable'), findsOneWidget);
    await tap(tester, find.byTooltip('Remove Unavailable product #1'));
    await settle(tester);
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
  });
  testWidgets('guest checkout redirects to sign in and keeps saved items',
      (tester) async {
    api.guest = true;
    api.products.add(productJson(1));
    await tester.runAsync(() => CartStorage.addToCart('1', 1));
    await pumpPage(tester, const CartPage());
    await tap(tester, find.text('Continue to checkout'));
    await settle(tester);
    expect(find.text('Route ${AppRoutes.introLogin}'), findsOneWidget);
    expect(await tester.runAsync(() => CartStorage.getItemQty('1')), 1);
    expect(api.requests.where((r) => r.method == 'POST'), isEmpty);
  });
  testWidgets(
      'checkout edits update totals in place without refetching address or stock',
      (tester) async {
    await tester.runAsync(() => CartStorage.addToCart('1', 1));
    await pumpPage(
        tester,
        CheckoutPage(checkOutList: [
          {
            'productId': 1,
            'name': product(1).name,
            'quantity': 1,
            'price': 125.5,
            'product': product(1)
          }
        ]));
    final before = api.requests.length;
    await tap(tester, find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(find.text('Checkout'), findsOneWidget);
    await settle(tester);
    expect(await tester.runAsync(() => CartStorage.getItemQty('1')), 2);
    expect(api.requests.length, before);
    expect(find.text('₹251.00'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  testWidgets('checkout rechecks stock immediately before submission',
      (tester) async {
    await tester.runAsync(() => CartStorage.addToCart('1', 2));
    api.products.add(productJson(1, stock: 1));
    await pumpPage(
        tester,
        CheckoutPage(checkOutList: [
          {
            'productId': 1,
            'name': product(1).name,
            'quantity': 2,
            'price': 125.5,
            'product': product(1)
          }
        ]));
    await tap(tester, find.text('Place Order'));
    await settle(tester);
    expect(api.requests.where((r) => r.method == 'POST'), isEmpty);
    expect(find.textContaining('Only 1 available'), findsOneWidget);
    expect(await tester.runAsync(() => CartStorage.getItemQty('1')), 2);
  });
  testWidgets('failed order retry retains the same idempotency key',
      (tester) async {
    await tester.runAsync(() => CartStorage.addToCart('1', 1));
    api.products.add(productJson(1));
    api.failOrders = true;
    await pumpPage(
        tester,
        CheckoutPage(checkOutList: [
          {
            'productId': 1,
            'name': product(1).name,
            'quantity': 1,
            'price': 125.5,
            'product': product(1)
          }
        ]));
    await tap(tester, find.text('Place Order'));
    await settle(tester);
    api.products.clear();
    await tap(tester, find.text('Place Order'));
    await settle(tester);
    final posts = api.requests.where((r) => r.method == 'POST').toList();
    expect(posts.length, 2);
    expect(posts[0].headers['Idempotency-Key'],
        posts[1].headers['Idempotency-Key']);
    expect(
        (posts[0].data['items'] as List).first.containsKey('product'), false);
    expect(await tester.runAsync(() => CartStorage.getItemQty('1')), 1);
  });
  testWidgets(
      'notification tap opens readable details and exposes an order action',
      (tester) async {
    await pumpPage(tester, const NotificationListPage());
    expect(find.textContaining('<div'), findsNothing);
    await tap(tester, find.text('Order Created with 208'));
    await settle(tester);
    expect(find.text('Notification'), findsOneWidget);
    expect(find.text('View order #208'), findsOneWidget);
    expect(api.requests.any((r) => r.method == 'PUT'), true);
  });
  testWidgets('shopping layouts fit small phones and enlarged text',
      (tester) async {
    api.products.add(productJson(1));
    await tester.runAsync(() => CartStorage.addToCart('1', 1));
    await pumpPage(tester, const CartPage(),
        size: const Size(320, 640), scale: 1.3);
    expect(tester.takeException(), isNull);
    await pumpPage(
        tester,
        Scaffold(
            body: SizedBox(
                width: 144,
                height: 460 * 1.3,
                child: ProductTileSquare(data: product(1)))),
        size: const Size(320, 640),
        scale: 1.3);
    expect(tester.takeException(), isNull);
  });
  testWidgets('export product and cart previews for visual review',
      (tester) async {
    final directory = Platform.environment['EAZY_UI_PREVIEW_DIR'];
    if (directory == null) return;
    await tester.runAsync(() async {
      final font = FontLoader('Gilroy')
        ..addFont(File('assets/fonts/Gilroy-Regular.ttf')
            .readAsBytes()
            .then((bytes) => ByteData.sublistView(bytes)));
      final icons = FontLoader('MaterialIcons')
        ..addFont(File(
                '/opt/homebrew/share/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf')
            .readAsBytes()
            .then((bytes) => ByteData.sublistView(bytes)));
      final roboto = FontLoader('Roboto')
        ..addFont(File(
                '/opt/homebrew/share/flutter/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf')
            .readAsBytes()
            .then((bytes) => ByteData.sublistView(bytes)));
      await font.load();
      await icons.load();
      await roboto.load();
    });
    api.products.add(productJson(1));
    await tester.runAsync(() => CartStorage.addToCart('1', 2));
    final key = GlobalKey();
    final items = [product(1), product(2, stock: 0)];
    await pumpPage(
        tester,
        RepaintBoundary(
            key: key,
            child: Scaffold(
                appBar: AppBar(title: const Text('Shop essentials')),
                body: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 460),
                    itemCount: 2,
                    itemBuilder: (_, index) =>
                        ProductTileSquare(data: items[index])))));
    Future<void> capture(String name) async {
      await tester.pump();
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('$directory/$name.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await capture('products');
    await pumpPage(tester, RepaintBoundary(key: key, child: const CartPage()));
    await capture('cart');
    expect(tester.takeException(), isNull);
  });
}
