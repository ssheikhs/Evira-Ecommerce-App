import 'package:ecommerce_app/features/cart/presentation/widgets/quantity_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('QuantitySelector shows the value and calls back', (
    tester,
  ) async {
    var quantity = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => QuantitySelector(
              quantity: quantity,
              onDecrement: quantity > 1
                  ? () => setState(() => quantity--)
                  : null,
              onIncrement: () => setState(() => quantity++),
            ),
          ),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byTooltip('Decrease quantity'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('decrease is disabled at the minimum', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantitySelector(
            quantity: 1,
            onDecrement: null,
            onIncrement: () {},
          ),
        ),
      ),
    );

    final decrease = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.remove),
        matching: find.byType(IconButton),
      ),
    );
    expect(decrease.onPressed, isNull);
  });
}
