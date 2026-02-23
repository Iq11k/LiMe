import 'dart:convert';
import 'package:doku/data/model/sholat.dart';
import 'package:http/http.dart' as http;

class SholatApi {
  final String baseUrl = "https://equran.id/api/v2/shalat";

  Future<Sholat?> getSholat({
    required String provinsi,
    required String kabkota,
    int? bulan,
    int? tahun,
  }) async {
    var client = http.Client();
    var uri = Uri.parse(baseUrl);

    final body = jsonEncode({
      "provinsi": provinsi,
      "kabkota": kabkota,
      "bulan": bulan,
      "tahun": tahun,
    });

    print('=== API Request ===');
    print('URL: $baseUrl');
    print('Body: $body');

    var response = await client.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print('Status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      return sholatFromJson(const Utf8Decoder().convert(response.bodyBytes));
    }
    return null;
  }
}
