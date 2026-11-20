import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as fm;
import 'package:game_app/views/splash/animated_splash.dart';

void main() {
  testWidgets('splash fits a phone and honors reduced motion', (tester) async {
    tester.view.physicalSize = const fm.Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      fm.MaterialApp(
        home: const fm.MediaQuery(
          data: fm.MediaQueryData(disableAnimations: true),
          child: AnimatedSplash(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AnimatedSplash), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('animated splash fits an iPad', (tester) async {
    tester.view.physicalSize = const fm.Size(1024, 1366);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const fm.MaterialApp(home: AnimatedSplash()));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(AnimatedSplash), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const fm.SizedBox.shrink());
  });
}
