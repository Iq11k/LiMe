import 'package:shared_preferences/shared_preferences.dart';

class LocationPrefs {
  static const _keyProvinsi = 'provinsi';
  static const _keyKabKota = 'kabkota';

  static const defaultProvinsi = 'D.I. Yogyakarta';
  static const defaultKabKota = 'Kota Yogyakarta';

  static Future<void> save({
    required String provinsi,
    required String kabKota,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProvinsi, provinsi);
    await prefs.setString(_keyKabKota, kabKota);
  }

  static Future<Map<String, String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'provinsi': prefs.getString(_keyProvinsi) ?? defaultProvinsi,
      'kabKota': prefs.getString(_keyKabKota) ?? defaultKabKota,
    };
  }
}
