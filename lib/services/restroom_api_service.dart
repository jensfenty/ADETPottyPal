import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/restroom.dart';

class RestroomApiService {
  static const String _overpassQuery =
      '[out:json][timeout:25];'
      '('
      'node["amenity"="toilets"](15.10,120.50,15.20,120.65);'
      'way["amenity"="toilets"](15.10,120.50,15.20,120.65);'
      'relation["amenity"="toilets"](15.10,120.50,15.20,120.65);'
      ');'
      'out center tags;';

  static final Uri _endpoint = Uri.https(
    'overpass-api.de',
    '/api/interpreter',
    {'data': _overpassQuery},
  );

  static Future<List<Restroom>> fetchRestrooms({http.Client? client}) async {
    final activeClient = client ?? http.Client();
    final shouldCloseClient = client == null;

    try {
      final response = await activeClient.get(
        _endpoint,
        headers: const {
          'User-Agent': 'PottyPal Milestone 3',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'API request failed with status ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unexpected API response format.');
      }

      final elements = decoded['elements'];
      if (elements is! List) {
        throw const FormatException('Missing restroom data in API response.');
      }

      return elements
          .map((item) => Restroom.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } finally {
      if (shouldCloseClient) {
        activeClient.close();
      }
    }
  }
}
