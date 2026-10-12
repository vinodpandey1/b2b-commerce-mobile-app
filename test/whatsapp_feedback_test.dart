import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:EazySupplies/views/auth/components/sign_up_form.dart';
import 'package:EazySupplies/core/utils/validators.dart';
import 'package:EazySupplies/core/components/product_price.dart';
import 'package:EazySupplies/core/models/userModel.dart';
import 'package:EazySupplies/views/cart/checkout_page.dart';

void main() {
  test('registration password explains the required symbol', () {
    expect(Validators.registrationPassword('abcdef'), contains('symbol'));
    expect(Validators.registrationPassword('abcde!'), isNull);
    expect(Validators.registrationPassword('abc!'), contains('6 characters'));
    expect(Validators.gst(' 27abcde1234f1z5 '), isNull);
  });
  testWidgets(
      'signup eyes toggle independently and GST error clears while editing',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: SignUpForm()))));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(2), 'bad');
    await tester.pump();
    expect(find.text('Enter a valid GST number'), findsOneWidget);
    await tester.enterText(fields.at(2), '27ABCDE1234F1Z5');
    await tester.pump();
    expect(find.text('Enter a valid GST number'), findsNothing);
    await tester.ensureVisible(find.byTooltip('Show password'));
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(tester.widget<TextFormField>(fields.at(4)).controller, isNotNull);
    final editable = find.byType(EditableText);
    expect(tester.widget<EditableText>(editable.at(4)).obscureText, false);
    expect(tester.widget<EditableText>(editable.at(5)).obscureText, true);
    await tester.ensureVisible(find.byTooltip('Show confirmation password'));
    await tester.tap(find.byTooltip('Show confirmation password'));
    await tester.pump();
    expect(tester.widget<EditableText>(editable.at(5)).obscureText, false);
    expect(tester.takeException(), isNull);
  });
  testWidgets('pricing shows MRP, percentage and savings only for discounts',
      (tester) async {
    final product = Product.fromJson(
        {'id': 1, 'price': 3520, 'mrp': 5575, 'skuType': 'Jerry Can'});
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ProductPrice(product: product))));
    expect(find.text('MRP ₹5575.00'), findsOneWidget);
    expect(find.text('36.86% off'), findsOneWidget);
    expect(find.text('Save ₹2055.00'), findsOneWidget);
    expect(find.text('per Jerry Can'), findsOneWidget);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ProductPrice(
                product:
                    Product.fromJson({'id': 2, 'price': 100, 'mrp': 100})))));
    expect(find.textContaining('Save'), findsNothing);
  });
  testWidgets('billing summary wraps long product names and keeps the amount visible', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const name = 'PREMIUM TOMATO KETCHUP SACHETS (10 PACKS X 100 SACHETS)';
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: BillingSummary(checkOutList: const [
      {'name': name, 'quantity': 2, 'price': 125.5}
    ]))));
    final text = tester.widget<Text>(find.text('$name   x  2'));
    expect(text.softWrap, true);
    expect(text.maxLines, isNull);
    expect(find.text('₹251.00'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

}
