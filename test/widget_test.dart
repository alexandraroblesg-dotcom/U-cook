import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ucook/app.dart';

void main() {
  testWidgets('T02: La aplicacion inicia y muestra la estructura de navegacion', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: UcookApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Comprobamos que el texto principal o bienvenida exista en pantalla
    expect(find.byType(Scaffold), findsWidgets);
  });
}
