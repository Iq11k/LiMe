import 'package:doku/data/provider/sholat_api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_box.dart';

class ProvinsiKotaPopup extends StatefulWidget {
  final Function(String provinsi, String kabkota) onSelected;

  const ProvinsiKotaPopup({super.key, required this.onSelected});

  @override
  State<ProvinsiKotaPopup> createState() => _ProvinsiKotaPopupState();

  static Future<void> show({
    required BuildContext context,
    required Function(String provinsi, String kabkota) onSelected,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ProvinsiKotaPopup(onSelected: onSelected),
    );
  }
}

class _ProvinsiKotaPopupState extends State<ProvinsiKotaPopup> {
  final SholatApi _api = SholatApi();
  final TextEditingController _searchController = TextEditingController();

  List<String> _provinsiList = [];
  List<String> _kabKotList = [];
  List<String> _filteredList = [];

  String? _selectedProvinsi;
  bool _isLoading = true;
  bool _isLoadingKabKot = false;
  bool _showingKabKot = false;

  @override
  void initState() {
    super.initState();
    _loadProvinsi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProvinsi() async {
    try {
      final result = await _api.getProvinsi();
      if (mounted && result != null) {
        setState(() {
          _provinsiList = result.data;
          _filteredList = result.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadKabKot() async {
    if (_selectedProvinsi == null) return;
    setState(() => _isLoadingKabKot = true);
    try {
      final result = await _api.getKabKot(
        provinsi: _selectedProvinsi!,
      ); // kirim provinsi
      if (mounted && result != null) {
        setState(() {
          _kabKotList = result.data;
          _filteredList = result.data;
          _isLoadingKabKot = false;
          _showingKabKot = true;
        });
        _searchController.clear();
      } else {
        if (mounted) setState(() => _isLoadingKabKot = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingKabKot = false);
    }
  }

  void _onSearch(String value) {
    setState(() {
      final source = _showingKabKot ? _kabKotList : _provinsiList;
      _filteredList = source
          .where((item) => item.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  void _onProvinsiSelected(String provinsi) {
    setState(() => _selectedProvinsi = provinsi);
    _loadKabKot();
  }

  void _onKabKotSelected(String kabkot) {
    Navigator.pop(context);
    widget.onSelected(_selectedProvinsi!, kabkot);
  }

  void _backToProvinsi() {
    setState(() {
      _showingKabKot = false;
      _filteredList = _provinsiList;
    });
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final title = _showingKabKot ? 'Pilih Kota/Kabupaten' : 'Pilih Provinsi';
    final hintText = _showingKabKot
        ? 'Cari kota/kabupaten...'
        : 'Cari provinsi...';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
        child: GlassBox(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    if (_showingKabKot)
                      IconButton(
                        onPressed: _backToProvinsi,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: const Color(0xFFC4F000),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_showingKabKot && _selectedProvinsi != null)
                            Text(
                              _selectedProvinsi!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFFC4F000),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
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
                  controller: _searchController,
                  onChanged: _onSearch,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: GoogleFonts.poppins(color: Colors.white38),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFC4F000),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFC4F000),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFC4F000),
                        width: 2.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Divider(height: 1),

              // List
              Expanded(
                child: _isLoading || _isLoadingKabKot
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFC4F000),
                        ),
                      )
                    : _filteredList.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ditemukan',
                          style: GoogleFonts.poppins(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _filteredList.length,
                        itemBuilder: (context, index) {
                          final item = _filteredList[index];
                          return ListTile(
                            leading: Icon(
                              _showingKabKot
                                  ? Icons.location_city_rounded
                                  : Icons.map_rounded,
                              color: const Color(0xFFC4F000),
                              size: 22,
                            ),
                            title: Text(
                              item,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            trailing: Icon(
                              _showingKabKot
                                  ? Icons.check_circle_outline
                                  : Icons.chevron_right_rounded,
                              color: Colors.white38,
                            ),
                            onTap: () => _showingKabKot
                                ? _onKabKotSelected(item)
                                : _onProvinsiSelected(item),
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
