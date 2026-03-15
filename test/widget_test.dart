import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pottypal/main.dart';
import 'package:pottypal/models/restroom.dart';

void main() {
  testWidgets('PottyPal home screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      PottyPalApp(
        restroomLoader: () async => [
          Restroom(
            imageColor: const Color(0xFF1976D2),
            imagePath: 'assets/images/angeles-city-library.webp',
            name: 'Sample Restroom',
            address: 'Angeles City',
            distance: '120 m away',
            rating: 4.2,
            reviewCount: 10,
            amenities: const ['Soap', 'Tissue'],
            cardColor: const Color(0xFFE3F2FD),
            isOpen: true,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PottyPal'), findsOneWidget);
    expect(find.text('Sample Restroom'), findsOneWidget);
  });
}
