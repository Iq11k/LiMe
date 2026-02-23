import 'package:doku/data/model/quran_list.dart';
import 'package:doku/data/provider/quran_api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_box.dart';

class SurahListPopup extends StatefulWidget {
  final int currentSurahId;
  final Function(int) onSurahSelected;

  const SurahListPopup({
    super.key,
    required this.currentSurahId,
    required this.onSurahSelected,
  });

  @override
  State<SurahListPopup> createState() => _SurahListPopupState();

  static Future<void> show({
    required BuildContext context,
    required int currentSurahId,
    required Function(int) onSurahSelected,
  }) {
    return showDialog(
      context: context,
      builder: (context) => SurahListPopup(
        currentSurahId: currentSurahId,
        onSurahSelected: onSurahSelected,
      ),
    );
  }
}

class _SurahListPopupState extends State<SurahListPopup> {
  final QuranApi _api = QuranApi();
  List<Datum> _surahList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSurahList();
  }

  Future<void> _loadSurahList() async {
    try {
      final result = await _api.getSurahList();
      if (mounted && result != null) {
        setState(() {
          _surahList = result.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSurah = _surahList.where((surah) {
      return surah.namaLatin.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          surah.nama.contains(_searchQuery) ||
          surah.nomor.toString().contains(_searchQuery);
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
        child: GlassBox(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Surah',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari surah...',
                    hintStyle: GoogleFonts.poppins(),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Divider(height: 1),

              // List Surah
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredSurah.isEmpty
                    ? Center(
                        child: Text(
                          'Surah tidak ditemukan',
                          style: GoogleFonts.poppins(),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredSurah.length,
                        itemBuilder: (context, index) {
                          final surah = filteredSurah[index];
                          final isSelected =
                              surah.nomor == widget.currentSurahId;

                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: Colors.black.withOpacity(0.1),
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade300,
                              child: Text(
                                '${surah.nomor}',
                                style: GoogleFonts.poppins(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            title: Text(
                              surah.namaLatin,
                              style: GoogleFonts.poppins(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              '${surah.nama} • ${surah.jumlahAyat} Ayat',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: surah.tempatTurun == TempatTurun.MEKAH
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                surah.tempatTurun == TempatTurun.MEKAH
                                    ? 'Makkah'
                                    : 'Madinah',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: surah.tempatTurun == TempatTurun.MEKAH
                                      ? Colors.orange.shade900
                                      : Colors.green.shade900,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              widget.onSurahSelected(surah.nomor);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
