import 'package:doku/data/model/sholat.dart';
import 'package:doku/data/provider/sholat_api.dart';
import 'package:doku/widgets/countdown.dart';
import 'package:doku/widgets/glass_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final date = DateTime.now();
  late final day = DateFormat('dd', 'id_ID').format(date);
  late final month = DateFormat('MMMM', 'id_ID').format(date);
  late final year = DateFormat('yyyy', 'id_ID').format(date);

  final hijriDate = HijriCalendar.now();
  late final hijriDay = hijriDate.hDay.toString();
  late final hijriMonth = hijriDate.longMonthName;
  late final hijriYear = hijriDate.hYear.toString();

  Future<Sholat?> _getImsakiyah() async {
    final api = SholatApi();
    return await api.getSholat(
      provinsi: 'D.I. Yogyakarta',
      kabkota: 'Kota Yogyakarta',
    );
  }

  Future<Jadwal?> _getJadwalBesok() async {
    try {
      final sholat = await _getImsakiyah();
      if (sholat == null) return null;

      final besok = DateTime.now().add(const Duration(days: 1));

      final jadwalBesok = sholat.data.jadwal.firstWhere(
        (jadwal) => jadwal.tanggal == besok.day,
        orElse: () => sholat.data.jadwal.first,
      );

      return jadwalBesok;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> _getNearestPrayer(Jadwal jadwal) async {
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    final prayers = {
      'Imsak': jadwal.imsak,
      'Subuh': jadwal.subuh,
      'Dzuhur': jadwal.dzuhur,
      'Ashar': jadwal.ashar,
      'Maghrib': jadwal.maghrib,
      'Isya': jadwal.isya,
    };

    final upcomingPrayers = prayers.entries.where((entry) {
      final time = entry.value.split(':');
      final hour = int.parse(time[0]);
      final minute = int.parse(time[1]);
      final prayerMinutes = hour * 60 + minute;
      return currentMinutes <= prayerMinutes;
    }).toList();

    if (upcomingPrayers.isNotEmpty) {
      return [upcomingPrayers.first.key, upcomingPrayers.first.value];
    }

    final jadwalBesok = await _getJadwalBesok();
    return ['Imsak', jadwalBesok?.imsak ?? jadwal.imsak];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: GlassBox(
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: FutureBuilder<Sholat?>(
                          future: _getImsakiyah(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: GoogleFonts.poppins(),
                                ),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data == null) {
                              return Center(
                                child: Text(
                                  'No data available',
                                  style: GoogleFonts.poppins(),
                                ),
                              );
                            }

                            final jadwalHariIni = snapshot.data!.data.jadwal
                                .firstWhere(
                                  (jadwal) =>
                                      jadwal.tanggal == DateTime.now().day,
                                );

                            return FutureBuilder<List<String>>(
                              future: _getNearestPrayer(jadwalHariIni),
                              builder: (context, asyncSnapshot) {
                                if (asyncSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (asyncSnapshot.hasError ||
                                    !asyncSnapshot.hasData) {
                                  return Center(
                                    child: Text(
                                      'Error loading prayer time',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }

                                final jadwalTerdekat = asyncSnapshot.data!;
                                final splitWaktu = jadwalTerdekat[1].split(':');

                                final now = TimeOfDay.now();
                                final currentMinutes =
                                    now.hour * 60 + now.minute;
                                final prayerMinutes =
                                    int.parse(splitWaktu[0]) * 60 +
                                    int.parse(splitWaktu[1]);

                                final isImsakBesok =
                                    jadwalTerdekat[0] == 'Imsak' &&
                                    currentMinutes > prayerMinutes;

                                final targetSholat = DateTime(
                                  date.year,
                                  date.month,
                                  isImsakBesok ? date.day + 1 : date.day,
                                  int.parse(splitWaktu[0]),
                                  int.parse(splitWaktu[1]),
                                );

                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/bulan bintang.svg',
                                      ),
                                      SimpleCountdown(
                                        targetTime: targetSholat,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        fontColor: const Color(0xFF4653FF),
                                      ),
                                      Text(
                                        "menuju",
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "${jadwalTerdekat[0]} pada ${jadwalTerdekat[1]}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const Gap(10),
                  Flexible(
                    flex: 1,
                    child: Column(
                      children: [
                        Flexible(
                          child: GlassBox(
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    day,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    month,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    year,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Gap(10),
                        Flexible(
                          child: GlassBox(
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    hijriDay,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    hijriMonth,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    hijriYear,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: GlassBox(),
            ),
          ),
        ],
      ),
    );
  }
}
