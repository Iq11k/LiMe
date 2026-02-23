import 'package:doku/data/model/sholat.dart';
import '../provider/sholat_api.dart';

class SholatService {
  final _api = SholatApi();
  Future<Sholat?> getImsakiyah({
    required String provinsi,
    required String kabkota,
    int? bulan,
    int? tahun,
  }) async {
    var res = await _api.getSholat(
      provinsi: provinsi,
      kabkota: kabkota,
      bulan: bulan,
      tahun: tahun,
    );
    return res;
  }
}
