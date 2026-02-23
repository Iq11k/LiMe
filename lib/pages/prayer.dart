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
        provinsi: 'D.I. Yogyakarta',
        kabkota: 'Kota Yogyakarta',
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
      return !d.isBefore(todayDate); // sama dengan atau setelah hari ini
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: _jadwalList.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                itemCount: _jadwalList.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _jadwalList.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final jadwal = _jadwalList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassBox(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (jadwal.tanggal == DateTime.now().day)
                              Row(
                                children: [
                                  Text(
                                    convertToHijri(jadwal.tanggalLengkap),
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
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
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                convertToHijri(jadwal.tanggalLengkap),
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
                            const SizedBox(height: 12),
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
    );
  }

  Widget _buildPrayerTime(String name, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: GoogleFonts.poppins(fontSize: 14)),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
