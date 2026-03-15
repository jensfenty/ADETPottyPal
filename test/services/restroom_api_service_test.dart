import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pottypal/services/restroom_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('fetchRestrooms returns parsed restrooms from the API', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      return http.Response(
        jsonEncode({
          'elements': [
            {
              'id': 1,
              'lat': 15.1462,
              'lon': 120.5933,
              'tags': {'name': 'Library Restroom', 'addr:city': 'Angeles City'},
            },
          ],
        }),
        200,
      );
    });

    final restrooms = await RestroomApiService.fetchRestrooms(client: client);

    expect(restrooms, hasLength(1));
    expect(restrooms.first.name, 'Library Restroom');
    expect(restrooms.first.address, 'Angeles City');
  });

  test('fetchRestrooms falls back to cached data when the API fails', () async {
    SharedPreferences.setMockInitialValues({
      'cached_restrooms_response': jsonEncode({
        'elements': [
          {
            'id': 8,
            'lat': 15.144,
            'lon': 120.59,
            'tags': {'name': 'Cached Restroom'},
          },
        ],
      }),
    });

    final client = MockClient((request) async {
      throw Exception('No internet');
    });

    final restrooms = await RestroomApiService.fetchRestrooms(client: client);

    expect(restrooms, hasLength(1));
    expect(restrooms.first.name, 'Cached Restroom');
  });

  test(
    'fetchRestrooms throws when both API and cache are unavailable',
    () async {
      final client = MockClient((request) async {
        throw Exception('No internet');
      });

      expect(
        () => RestroomApiService.fetchRestrooms(client: client),
        throwsException,
      );
    },
  );
}
