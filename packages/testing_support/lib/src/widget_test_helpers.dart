import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helper extensions for WidgetTester.
extension WidgetTesterHelpers on WidgetTester {
  /// Pumps a widget wrapped in standard MaterialApp with a Scaffold.
  Future<void> pumpTestWidget(
    Widget child, {
    ThemeData? theme,
    Size size = const Size(390, 844),
  }) async {
    await binding.setSurfaceSize(size);
    addTearDown(() => binding.setSurfaceSize(null));

    await pumpWidget(
      MaterialApp(
        theme: theme ?? ThemeData.light(useMaterial3: true),
        home: Scaffold(
          body: child,
        ),
      ),
    );
    await pumpAndSettle();
  }
}
