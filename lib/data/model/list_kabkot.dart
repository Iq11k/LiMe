import 'dart:convert';

KabKot kabKotFromJson(String str) => KabKot.fromJson(json.decode(str));

String kabKotToJson(KabKot data) => json.encode(data.toJson());

class KabKot {
  int code;
  String message;
  List<String> data;

  KabKot({required this.code, required this.message, required this.data});

  factory KabKot.fromJson(Map<String, dynamic> json) => KabKot(
    code: json["code"],
    message: json["message"],
    data: List<String>.from(json["data"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x)),
  };
}
