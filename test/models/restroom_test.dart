import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pottypal/models/restroom.dart';

void main() {
  test('Restroom.fromJson maps Overpass data into app fields', () {
    final restroom = Restroom.fromJson({
      'id': 42,
      'lat': 15.1505,
      'lon': 120.6002,
      'tags': {
        'name': 'SM City Clark Restroom',
        'addr:street': 'Manuel A. Roxas Highway',
        'addr:city': 'Angeles City',
        'wheelchair': 'yes',
        'fee': 'no',
      },
    });

    expect(restroom.name, 'SM City Clark Restroom');
    expect(restroom.address, 'Manuel A. Roxas Highway, Angeles City');
    expect(restroom.amenities, containsAll(<String>['PWD', 'Accessible']));
    expect(restroom.amenities, contains('No Fee'));
    expect(restroom.distance, contains('away'));
    expect(restroom.cardColor, const Color(0xFFE3F2FD));
    expect(restroom.isOpen, isTrue);
  });

  test('Restroom.fromJson falls back when tags are incomplete', () {
    final restroom = Restroom.fromJson({
      'id': 7,
      'center': {'lat': 15.1455, 'lon': 120.5928},
      'tags': {'access': 'private'},
    });

    expect(restroom.name, 'Public Restroom 8');
    expect(restroom.address, 'Clark area, Angeles City');
    expect(restroom.isOpen, isFalse);
  });
}
