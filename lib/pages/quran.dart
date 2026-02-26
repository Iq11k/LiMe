import 'package:doku/data/model/quran.dart' as data;
import 'package:doku/data/provider/quran_api.dart';
import 'package:doku/widgets/glass_box.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../widgets/popup_menu.dart';

class Quran extends StatefulWidget {
  const Quran({super.key});

  @override
  State<Quran> createState() => _QuranState();
}

class _QuranState extends State<Quran> {
  int _currentSurahId = 1;
  final QuranApi _api = QuranApi();
  final _audioPlayer = AudioPlayer();
  data.Quran? _currentData; // Cache data saat ini
  bool _isLoading = false;
  int? _playingAyatIndex;

  @override
  void initState() {
    super.initState();
    _loadSurah(_currentSurahId);

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _playingAyatIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSurah(int id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _api.getSurah(id: id);
      if (mounted) {
        setState(() {
          _currentData = result;
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

  Future<void> _playAyat(String audioUrl, int ayatIndex) async {
    try {
      if (_playingAyatIndex == ayatIndex) {
        if (_audioPlayer.playing) {
          await _audioPlayer.pause();
          setState(() => _playingAyatIndex = null);
        } else {
          await _audioPlayer.play();
          setState(() => _playingAyatIndex = ayatIndex);
        }
      } else {
        setState(() => _playingAyatIndex = ayatIndex);
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.play();
      }
    } catch (e) {
      setState(() => _playingAyatIndex = null);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal memutar audio')));
      }
    }
  }

  void _navigateToSurah(int surahId) {
    _currentSurahId = surahId;
    _loadSurah(surahId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            Row(
              children: [
                // Button prev
                GlassBox(
                  child: IconButton(
                    onPressed:
                        _currentData?.data.suratSebelumnya != null &&
                            !_isLoading
                        ? () {
                            _navigateToSurah(
                              _currentData!.data.suratSebelumnya!.nomor,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_left),
                    iconSize: 40,
                    color: Colors.black,
                    disabledColor: Colors.grey,
                  ),
                ),
                const Gap(16),

                Expanded(
                  child: GlassBox(
                    onTap: () {
                      SurahListPopup.show(
                        context: context,
                        currentSurahId: _currentSurahId,
                        onSurahSelected: _navigateToSurah,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            _currentData?.data.namaLatin ?? 'Loading...',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _currentData?.data.nama ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text("${_currentData?.data.jumlahAyat} Ayat"),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(16),

                // Button Next
                GlassBox(
                  child: IconButton(
                    onPressed:
                        _currentData?.data.suratSelanjutnya != null &&
                            !_isLoading
                        ? () {
                            _navigateToSurah(
                              _currentData!.data.suratSelanjutnya!.nomor,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_right),
                    iconSize: 40,
                    color: Colors.black,
                    disabledColor: Colors.grey,
                  ),
                ),
              ],
            ),

            const Gap(16),
            Expanded(
              child: GlassBox(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _currentData == null
                    ? Center(
                        child: Text(
                          'No data available',
                          style: GoogleFonts.poppins(),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _currentData!.data.ayat.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Column(
                              children: [
                                const Gap(10),
                                Text(
                                  "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيْمِ",
                                  style: GoogleFonts.notoNaskhArabic(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Gap(16),
                              ],
                            );
                          }

                          final ayat = _currentData!.data.ayat[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _playingAyatIndex == ayat.nomorAyat
                                            ? Icons.pause_circle
                                            : Icons.play_circle,
                                        size: 30,
                                      ),
                                      color: Color(0xFFC4F000),
                                      onPressed: () {
                                        _playAyat(
                                          ayat.audio["06"] ??
                                              ayat.audio.values.first,
                                          ayat.nomorAyat,
                                        );
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        "${ayat.teksArab}\t(${ayat.nomorAyat})",
                                        style: GoogleFonts.notoNaskhArabic(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFC4F000),
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),

                                Text(
                                  ayat.teksLatin,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const Gap(5),
                                Text(
                                  ayat.teksIndonesia,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFC4F000),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const Gap(10),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
