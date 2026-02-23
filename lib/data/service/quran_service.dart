import 'package:doku/data/model/quran.dart';
import 'package:doku/data/model/quran_list.dart';

import '../provider/quran_api.dart';

class ImsakiyahService {
  final _api = QuranApi();
  Future<Quran?> getSurah({required int id}) async {
    var res = await _api.getSurah(id: id);
    return res;
  }

  Future<SurahList?> getSurahList() async {
    var res = await _api.getSurahList();
    return res;
  }
}
