import 'dart:convert';

Sholat sholatFromJson(String str) => Sholat.fromJson(json.decode(str));

String sholatToJson(Sholat data) => json.encode(data.toJson());

class Sholat {
  int code;
  String message;
  Data data;

  Sholat({required this.code, required this.message, required this.data});

  factory Sholat.fromJson(Map<String, dynamic> json) => Sholat(
    code: json["code"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  String provinsi;
  String kabkota;
  int bulan;
  int tahun;
  String bulanNama;
  List<Jadwal> jadwal;

  Data({
    required this.provinsi,
    required this.kabkota,
    required this.bulan,
    required this.tahun,
    required this.bulanNama,
    required this.jadwal,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    provinsi: json["provinsi"],
    kabkota: json["kabkota"],
    bulan: json["bulan"],
    tahun: json["tahun"],
    bulanNama: json["bulan_nama"],
    jadwal: List<Jadwal>.from(json["jadwal"].map((x) => Jadwal.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "provinsi": provinsi,
    "kabkota": kabkota,
    "bulan": bulan,
    "tahun": tahun,
    "bulan_nama": bulanNama,
    "jadwal": List<dynamic>.from(jadwal.map((x) => x.toJson())),
  };
}

class Jadwal {
  int tanggal;
  DateTime tanggalLengkap;
  String hari;
  String imsak;
  String subuh;
  String terbit;
  String dhuha;
  String dzuhur;
  String ashar;
  String maghrib;
  String isya;

  Jadwal({
    required this.tanggal,
    required this.tanggalLengkap,
    required this.hari,
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) => Jadwal(
    tanggal: json["tanggal"],
    tanggalLengkap: DateTime.parse(json["tanggal_lengkap"]),
    hari: json["hari"],
    imsak: json["imsak"],
    subuh: json["subuh"],
    terbit: json["terbit"],
    dhuha: json["dhuha"],
    dzuhur: json["dzuhur"],
    ashar: json["ashar"],
    maghrib: json["maghrib"],
    isya: json["isya"],
  );

  Map<String, dynamic> toJson() => {
    "tanggal": tanggal,
    "tanggal_lengkap":
        "${tanggalLengkap.day.toString().padLeft(2, '0')}-${tanggalLengkap.month.toString().padLeft(2, '0')}-${tanggalLengkap.year.toString().padLeft(4, '0')}",
    "hari": hari,
    "imsak": imsak,
    "subuh": subuh,
    "terbit": terbit,
    "dhuha": dhuha,
    "dzuhur": dzuhur,
    "ashar": ashar,
    "maghrib": maghrib,
    "isya": isya,
  };
}
