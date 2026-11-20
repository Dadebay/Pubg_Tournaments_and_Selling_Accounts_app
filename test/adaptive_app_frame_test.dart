// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_app/views/constants/adaptive_app_frame.dart';

void main() {
  Future<void> pumpAtSize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => AdaptiveAppFrame(child: child!),
        home: Scaffold(
          body: SizedBox.expand(
            key: const Key('page'),
            child: Builder(builder: (context) => Text(MediaQuery.sizeOf(context).width.toStringAsFixed(0))),
          ),
        ),
      ),
    );
  }

  testWidgets('phone routes keep the full width', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpAtSize(tester, const Size(390, 844));

    expect(tester.getSize(find.byKey(const Key('page'))).width, 390);
  });

  testWidgets('tablet routes are centered and capped in landscape', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpAtSize(tester, const Size(1366, 1024));

    final page = find.byKey(const Key('page'));
    expect(tester.getSize(page).width, AdaptiveAppFrame.maxContentWidth);
    expect(tester.getTopLeft(page).dx, (1366 - AdaptiveAppFrame.maxContentWidth) / 2);
    expect(find.text('960'), findsOneWidget);
  });

  testWidgets('tablet portrait keeps its available width', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpAtSize(tester, const Size(834, 1194));

    expect(tester.getSize(find.byKey(const Key('page'))).width, 834);
    expect(find.text('834'), findsOneWidget);
  });
}
