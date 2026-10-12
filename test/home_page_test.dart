import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:EazySupplies/core/constants/cartStorage.dart';
import 'package:EazySupplies/core/themes/app_themes.dart';
import 'package:EazySupplies/views/home/home_data.dart';
import 'package:EazySupplies/views/home/home_page.dart';
import 'package:EazySupplies/views/entrypoint/components/app_navigation_bar.dart';

Map<String, dynamic> item(int id, {bool active = true}) => {
      'id': id,
      'name': 'STRAWBERRY BAR SYRUP 12X750ML $id',
      'price': 1714.32,
      'stock': 200,
      'status': active,
      'skuType': 'case',
      'createdAt': '2026-10-${id.toString().padLeft(2, '0')}T00:00:00Z',
      'brand': {'name': 'Earthling'},
    };
HomeData fixture({bool error = false}) => HomeData.parse({
      'jsonData': {
        'data': {
          'content': {
            'home_banner': {
              'banners': [
                {
                  'status': true,
                  'image_url': '',
                  'redirect_link': {
                    'link':
                        'collections?category=21&title=Crushes%20and%20Bar%20Syrups'
                  }
                },
                {'status': false, 'image_url': '/api/file?file=hidden.jpg'},
              ]
            },
            'earthling_home': {
              'featured': {
                'product_ids': [2, 3]
              }
            },
          }
        }
      }
    }, {
      'data': [item(1), item(3), item(2), item(4, active: false)]
    }, {
      'data': [
        {'id': 21, 'name': 'Crushes and Bar Syrups', 'status': 1},
        {'id': 22, 'name': 'Hidden category', 'status': 0}
      ]
    }, hasError: error);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CartStorage.clearCart();
  });
  test('website template drives banners and product sections', () {
    final data = fixture();
    expect(data.banners.length, 1);
    expect(data.banners.single.categoryId, 21);
    expect(data.banners.single.title, 'Crushes and Bar Syrups');
    expect(data.latest.map((p) => p.id), [3, 2, 1]);
    expect(data.popular.map((p) => p.id), [3, 2]);
    expect(data.categories.map((c) => c.id), [21]);
    expect(homeImageUrl('/api/file?file=banner.jpg'),
        'https://api.eazysupplies.com/api/file?file=banner.jpg');
  });
  Future<void> pump(WidgetTester tester,
      {double scale = 1, Future<HomeData> Function()? loader}) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.defaultTheme,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!),
        home: HomePage(loader: loader ?? () async => fixture()),
        onGenerateRoute: (settings) => MaterialPageRoute(
            settings: settings,
            builder: (_) => Scaffold(
                body: Text('${settings.name} ${settings.arguments}')))));
    await tester.pumpAndSettle();
  }

  testWidgets('home tolerates Android initial zero-sized viewport',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox.shrink(
            child: HomePage(loader: () async => fixture()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('home fits small phones with enlarged text throughout the page',
      (tester) async {
    await pump(tester, scale: 1.3);
    expect(find.text('Latest Eats'), findsOneWidget);
    for (var i = 0; i < 16; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(find.text('Shop by category'), findsOneWidget);
  });
  testWidgets('banner opens its website category as a native app screen',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Crushes and Bar Syrups').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('/categoryDetails'), findsOneWidget);
    expect(find.textContaining('categoryId: 21'), findsOneWidget);
  });
  testWidgets('home product controls save quantity without leaving the screen',
      (tester) async {
    await pump(tester);
    final add = find.text('Add to cart').first;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
    await tester.pumpAndSettle();
    await tester.runAsync(() => tester.tap(add));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
    final quantity = await tester.runAsync(() => CartStorage.getItemQty('3'));
    expect(quantity, 1);
    expect(find.text('Latest Eats'), findsOneWidget);
    expect(find.text('Added to cart'), findsWidgets);
  });
  testWidgets('failed refresh retains products and offers retry',
      (tester) async {
    var calls = 0;
    await pump(tester,
        loader: () async => ++calls == 1
            ? fixture(error: true)
            : HomeData(
                content: {}, products: [], categories: [], hasError: true));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.textContaining('STRAWBERRY BAR SYRUP'), findsWidgets);
    expect(find.text('Retry'), findsOneWidget);
  });
  testWidgets('bottom navigation exposes all five destinations and cart count',
      (tester) async {
    await tester.runAsync(() => CartStorage.setQuantity('3', 2));
    var selected = -1;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
                currentIndex: 0, onNavTap: (index) => selected = index))));
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.text('Cart'));
    expect(selected, 2);
  });
}
