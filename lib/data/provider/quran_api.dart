import 'dart:convert';
import 'package:doku/data/model/quran.dart';
import 'package:doku/data/model/quran_list.dart';
import 'package:http/http.dart' as http;

class QuranApi {
  final String baseUrl = "https://equran.id/api/v2/surat";

  Future<Quran?> getSurah({required int id}) async {
    var client = http.Client();
    var uri = Uri.parse('$baseUrl/$id');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      return quranFromJson(const Utf8Decoder().convert(response.bodyBytes));
    }
    return null;
  }

  Future<SurahList?> getSurahList() async {
    var client = http.Client();
    var uri = Uri.parse(baseUrl);
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      return surahListFromJson(const Utf8Decoder().convert(response.bodyBytes));
    }
    return null;
  }
}
