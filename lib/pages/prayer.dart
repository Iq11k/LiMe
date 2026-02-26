import 'package:doku/widgets/provinsikota_popup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../data/model/sholat.dart';
import '../data/provider/sholat_api.dart';
import '../widgets/glass_box.dart';

class Prayer extends StatefulWidget {
  const Prayer({super.key});

  @override
  State<Prayer> createState() => _PrayerState();
}

class _PrayerState extends State<Prayer> {
  final ScrollController _scrollController = ScrollController();
  final List<Jadwal> _jadwalList = [];
  final Set<String> _fetchedMonths = {};
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;

  String provinsi = 'D.I. Yogyakarta';
  String kabKota = 'Kota Yogyakarta';

  final Map<String, IconData> prayerIcons = {
    'Imsak': Icons.nightlight_round,
    'Subuh': Icons.wb_twilight_rounded,
    'Dzuhur': Icons.wb_sunny_rounded,
    'Ashar': Icons.sunny_snowing,
    'Maghrib': Icons.wb_sunny_outlined,
    'Isya': Icons.nights_stay_rounded,
  };

  @override
  void initState() {
    super.initState();
    _loadMoreData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMoreData();
    }
  }

  void _resetAndReload() {
    setState(() {
      _jadwalList.clear();
      _fetchedMonths.clear();
      _hasMore = true;
      _currentMonth = DateTime.now().month;
      _currentYear = DateTime.now().year;
    });
    _loadMoreData();
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final int fetchMonth = _currentMonth;
    final int fetchYear = _currentYear;
    final String monthKey =
        '$fetchYear-${fetchMonth.toString().padLeft(2, '0')}';

    if (_fetchedMonths.contains(monthKey)) {
      _incrementMonth();
      setState(() => _isLoading = false);
      _loadMoreData();
      return;
    }

    _fetchedMonths.add(monthKey);
    _incrementMonth();

    if (fetchYear > DateTime.now().year + 5) {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
      return;
    }

    try {
      final api = SholatApi();

      final moreData = await api.getSholat(
        provinsi: provinsi,
        kabkota: kabKota,
        bulan: fetchMonth,
        tahun: fetchYear,
      );

      if (moreData != null && moreData.data.jadwal.isNotEmpty) {
        setState(() {
          _jadwalList.addAll(moreData.data.jadwal);

          if (_fetchedMonths.length == 1) {
            _trimToToday();
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _hasMore = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _trimToToday() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final index = _jadwalList.indexWhere((j) {
      final d = DateTime(
        j.tanggalLengkap.year,
        j.tanggalLengkap.month,
        j.tanggalLengkap.day,
      );
      return !d.isBefore(todayDate);
    });

    if (index > 0) {
      _jadwalList.removeRange(0, index);
    }
  }

  void _incrementMonth() {
    _currentMonth++;
    if (_currentMonth > 12) {
      _currentMonth = 1;
      _currentYear++;
    }
  }

  String convertToHijri(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    return '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}';
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        child: Column(
          children: [
            // Header lokasi
            GlassBox(
              variant: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFFC4F000),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kabKota,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              provinsi,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: const Color(0xFFC4F000),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        ProvinsiKotaPopup.show(
                          context: context,
                          onSelected: (prov, kab) {
                            setState(() {
                              provinsi = prov;
                              kabKota = kab;
                            });
                            _resetAndReload();
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.edit_location_alt_rounded,
                        color: Color(0xFFC4F000),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // List jadwal
            Expanded(
              child: _jadwalList.isEmpty && _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFC4F000),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _jadwalList.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _jadwalList.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                color: Color(0xFFC4F000),
                              ),
                            ),
                          );
                        }

                        final jadwal = _jadwalList[index];
                        final isToday =
                            formatDate(jadwal.tanggalLengkap) ==
                            formatDate(DateTime.now());

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GlassBox(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tanggal header
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              convertToHijri(
                                                jadwal.tanggalLengkap,
                                              ),
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              formatDate(jadwal.tanggalLengkap),
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isToday)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFC4F000),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            "Hari Ini",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),

                                  // Jadwal sholat dengan icon
                                  _buildPrayerTime('Imsak', jadwal.imsak),
                                  _buildPrayerTime('Subuh', jadwal.subuh),
                                  _buildPrayerTime('Dzuhur', jadwal.dzuhur),
                                  _buildPrayerTime('Ashar', jadwal.ashar),
                                  _buildPrayerTime('Maghrib', jadwal.maghrib),
                                  _buildPrayerTime('Isya', jadwal.isya),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTime(String name, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            prayerIcons[name] ?? Icons.access_time_rounded,
            color: const Color(0xFFC4F000),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFC4F000),
            ),
          ),
        ],
      ),
    );
  }
}
