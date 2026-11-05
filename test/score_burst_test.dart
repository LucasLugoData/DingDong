import 'package:dingdong/game/solitaire.dart';
import 'package:dingdong/widgets/score_burst.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

ScoreEvent event({
  bool correct = true,
  double gain = 120,
  int streak = 4,
  double multMult = 1,
}) => ScoreEvent(
  correct: correct,
  chips: 20,
  mult: 6,
  multMult: multMult,
  gain: gain,
  streak: streak,
  triggered: const [],
);

Widget scene(ScoreEvent? value, {int id = 1,
  Duration duration = const Duration(milliseconds: 1100),
}) => MaterialApp(home: Scaffold(body: Stack(fit: StackFit.expand, children: [
  ScoreBurst(event: value, eventId: id, duration: duration),
])));

void main() {
  test('shake grows with gain and tier, is capped, and ignores failures', () {
    expect(shakeFor(event(correct: false, gain: 100000, streak: 20)), 0);
    expect(shakeFor(event(gain: 120)), greaterThan(shakeFor(event(gain: 10))));
    expect(shakeFor(event(streak: 10)), greaterThan(shakeFor(event())));
    for (final gain in [0.0, 1.0, 120.0, 1e20]) {
      expect(shakeFor(event(gain: gain, streak: 20)), inInclusiveRange(0, 12));
    }
  });

  testWidgets('gain is visible at 400 ms and the layer empties itself', (tester) async {
    await tester.pumpWidget(scene(event()));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('+120'), findsWidgets);
    expect(find.text('太棒了'), findsNothing);
    await tester.pumpAndSettle();
    final layer = find.byType(ScoreBurst);
    expect(find.descendant(of: layer, matching: find.byType(Text)), findsNothing);
    expect(find.descendant(of: layer, matching: find.byType(CustomPaint)), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('milestone shows hanzi and Spanish praise', (tester) async {
    await tester.pumpWidget(scene(event(streak: 10)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('太棒了'), findsWidgets);
    expect(find.text('¡Genial!'), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('太棒了'), findsNothing);
  });

  testWidgets('failure has only its breaking cross, even with a milestone', (tester) async {
    await tester.pumpWidget(scene(event(correct: false, streak: 20)));
    await tester.pump(const Duration(milliseconds: 400));
    final layer = find.byType(ScoreBurst);
    expect(find.descendant(of: layer, matching: find.byType(Text)), findsNothing);
    expect(find.descendant(of: layer, matching: find.byType(CustomPaint)), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.descendant(of: layer, matching: find.byType(CustomPaint)), findsNothing);
  });

  testWidgets('only a new eventId replays and captures the new event', (tester) async {
    await tester.pumpWidget(scene(event()));
    await tester.pumpAndSettle();
    await tester.pumpWidget(scene(event(gain: 300)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('+300'), findsNothing);
    await tester.pumpWidget(scene(event(gain: 300), id: 2));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('+300'), findsWidgets);
    await tester.pumpWidget(scene(event(gain: 15.5, multMult: 1.5), id: 3));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('+15.5'), findsWidgets);
    expect(find.text('X1.5'), findsOneWidget);
    expect(find.text('+300'), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('null clears an active event and custom duration ends on time', (tester) async {
    await tester.pumpWidget(scene(null));
    final layer = find.byType(ScoreBurst);
    expect(find.descendant(of: layer, matching: find.byType(CustomPaint)), findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
    // MaterialApp can schedule its own frame on mount, without a burst ticker.
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(scene(event(), id: 2,
        duration: const Duration(milliseconds: 220)));
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('+120'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 139));
    expect(find.descendant(of: layer, matching: find.byType(CustomPaint)), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 82));
    expect(find.text('+120'), findsNothing);
    expect(find.descendant(of: layer, matching: find.byType(CustomPaint)), findsNothing);
    await tester.pumpWidget(scene(event(), id: 3));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('+120'), findsWidgets);
    await tester.pumpWidget(scene(null, id: 4));
    expect(find.descendant(of: layer, matching: find.byType(CustomPaint)), findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpAndSettle();
    expect(find.text('+120'), findsNothing);
  });

  testWidgets('tier haptics fire once per event and failure uses a short impact', (tester) async {
    final calls = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') calls.add(call.arguments);
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(scene(event(streak: 10)));
    await tester.pumpAndSettle();
    await tester.pumpWidget(scene(event(streak: 10)));
    await tester.pumpWidget(scene(event(streak: 15), id: 2));
    await tester.pumpWidget(scene(event(streak: 20), id: 3));
    await tester.pumpWidget(scene(event(correct: false), id: 4));
    await tester.pumpAndSettle();
    expect(calls, [
      'HapticFeedbackType.mediumImpact',
      'HapticFeedbackType.mediumImpact',
      'HapticFeedbackType.heavyImpact',
      'HapticFeedbackType.lightImpact',
    ]);
  });

  testWidgets('fits 375 by 812 at all tiers and ignores touches', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final streak in [3, 5, 10, 15, 20]) {
      await tester.pumpWidget(scene(event(streak: streak, multMult: 1.5), id: streak));
      for (var frame = 0; frame < 12; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
      }
    }
    var taps = 0;
    await tester.pumpWidget(MaterialApp(home: Stack(fit: StackFit.expand, children: [
      GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => taps++,
        child: const SizedBox.expand()),
      ScoreBurst(event: event(), eventId: 100),
    ])));
    await tester.tapAt(const Offset(187, 400));
    expect(taps, 1);
    await tester.pumpAndSettle();
  });
}
