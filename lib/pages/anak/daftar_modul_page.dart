import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api_config.dart';
import 'pdf_viewer_page_modul.dart'; // <--- TAMBAHKAN IMPORT INI

class DaftarModulPage extends StatefulWidget {
  final int studentId;
  final int categoryId;
  final String categoryName;
  final String colorHex;
  final String? iconName;

  const DaftarModulPage({
    super.key,
    required this.studentId,
    required this.categoryId,
    required this.categoryName,
    required this.colorHex,
    this.iconName,
  });

  @override
  State<DaftarModulPage> createState() => _DaftarModulPageState();
}

class _DaftarModulPageState extends State<DaftarModulPage> {
  List<dynamic> _listModul = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchModulMateri();
  }

  // Mengambil daftar modul materi dari API Backend
  Future<void> _fetchModulMateri() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl_siswa}/siswa/modules-by-category/${widget.studentId}/${widget.categoryId}',
        ),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _listModul = jsonDecode(response.body)['data'];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error ambil daftar modul: $e");
    }
  }

  // Helper konversi HEX string database ke Objek Color Flutter
  Color _parseHexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Menentukan ikon atas beranda kategori berdasarkan nama file DB
  IconData _getCategoryIcon(String? dbIconName) {
    switch (dbIconName) {
      case 'icon_math.png':
        return Icons.calculate;
      case 'icon_ipa.png':
        return Icons.biotech;
      case 'icon_ips.png':
        return Icons.public;
      case 'icon_bahasa.png':
        return Icons.book_online_rounded;
      case 'icon_english.png':
        return Icons.translate;
      default:
        return Icons.import_contacts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = _parseHexColor(widget.colorHex);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Banner Atas bergaya melengkung khas BelajarIn
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getCategoryIcon(widget.iconName),
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Yuk, Pilih Modul Belajar!",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Selesaikan materi untuk menambah poin bintangmu.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Area Daftar List Materi Modul
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: themeColor))
                : _listModul.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("📭", style: TextStyle(fontSize: 50)),
                        const SizedBox(height: 12),
                        Text(
                          "Belum ada modul di kategori ini.",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _listModul.length,
                    itemBuilder: (context, index) {
                      final modul = _listModul[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: themeColor.withOpacity(0.15),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Badge Level Tingkatan Modul
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: themeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    "${modul['level'] ?? '1'}",
                                    style: TextStyle(
                                      color: themeColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Detail Informasi Modul
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      modul['title'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      modul['description'] ??
                                          'Tidak ada deskripsi materi.',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Baris Hadiah Hadiah Poin Gamifikasi
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.stars_rounded,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "+${modul['total_points'] ?? '0'} Poin Belajar",
                                          style: const TextStyle(
                                            color: Colors.amber,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // =======================================================
                              // ✅ TOMBOL BUKA MODUL (Diubah untuk membuka PdfViewerPage)
                              // =======================================================
                              ElevatedButton(
                                onPressed: () {
                                  final String? filePdf = modul['file_pdf'];

                                  if (filePdf != null &&
                                      filePdf.trim().isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfViewerPage(
                                          // Pastikan endpoint ini sesuai dengan cara backendmu nge-serve file modul
                                          url:
                                              '${ApiConfig.baseUrl}/siswa/stream-modul/$filePdf',
                                          title:
                                              modul['title'] ?? "Modul Materi",
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'File modul belum tersedia/diunggah.',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Buka",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
