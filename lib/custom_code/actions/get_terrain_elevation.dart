// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> getTerrainElevation(
  String pcIp,
  double latitude,
  double longitude,
) async {
  try {
    final cleanIp =
        pcIp.trim().replaceFirst(RegExp(r'^https?://'), '').replaceAll('/', '');

    if (cleanIp.isEmpty) {
      throw Exception('Computer IP address is empty');
    }

    final uri = Uri.http(
      '$cleanIp:9066',
      '/terrain',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Terrain API returned HTTP ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception('Invalid terrain API response');
    }

    final elevationFt = decoded['elevation_ft'];
    final elevationM = decoded['elevation_m'];

    if (elevationFt is! num || elevationM is! num) {
      throw Exception('Elevation values are missing or invalid');
    }

    return <String, dynamic>{
      'elevation_ft': elevationFt.toDouble(),
      'elevation_m': elevationM.toDouble(),
    };
  } catch (e) {
    throw Exception('Terrain elevation request failed: $e');
  }
}
