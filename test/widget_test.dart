// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aprender_a_leer/main.dart'; // Asegúrate de que esta ruta sea correcta

void main() {
  testWidgets('BienvenidaScreen displays correctly', (WidgetTester tester) async {
    // Construye la aplicación y activa un frame.
    await tester.pumpWidget(MyApp()); // Eliminamos 'const' aquí

    // Verifica que el texto "Rubi" está presente en la pantalla.
    expect(find.text('Rubi'), findsOneWidget);

    // Verifica que el texto "Aprende a leer" está presente en la pantalla.
    expect(find.text('Aprende a leer'), findsOneWidget);

    // Verifica que el botón "Comencemos" está presente.
    expect(find.widgetWithText(ElevatedButton, 'Comencemos'), findsOneWidget);

    // Simula un clic en el botón "Comencemos".
    await tester.tap(find.widgetWithText(ElevatedButton, 'Comencemos'));
    await tester.pumpAndSettle(); // Espera a que la navegación termine.

    // Verifica que se ha navegado a la pantalla del menú principal.
    expect(find.text('Menú Principal'), findsOneWidget);
  });
}