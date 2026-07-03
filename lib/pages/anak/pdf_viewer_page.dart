import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../api_config.dart';

class PdfViewerPage extends StatefulWidget {
  final int studentId;
  final int ebookId;
  final String title;
  final int initialPage;
  final int totalPages;
  final String fileUrl;

  const PdfViewerPage({
    super.key,
    required this.studentId,
    required this.ebookId,
    required this.title,
    required this.initialPage,
    required this.totalPages,
    required this.fileUrl,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfViewerController _pdfViewerController;
  int _currentPage = 1;
  bool _isSaving = false;
  bool _isDocumentLoaded = false;
  
  // ---> 1. DEKLARASI STOPWATCH UNTUK MENGHITUNG WAKTU BACA <---
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _currentPage = widget.initialPage;
    
    // ---> 2. MULAI MENGHITUNG WAKTU SAAT HALAMAN DIBUKA <---
    _stopwatch.start();
  }

  @override
  void dispose() {
    // ---> 3. HENTIKAN STOPWATCH SAAT KELUAR HALAMAN <---
    _stopwatch.stop();
    _pdfViewerController.dispose();
    super.dispose();
  }

  // Fungsi menyimpan progress halaman terakhir ke database sebelum keluar
  Future<void> _simpanProgressKeDatabase() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    // ---> 4. KONVERSI WAKTU KE MENIT <---
    int durationInMinutes = _stopwatch.elapsed.inMinutes;
    // Jika anak membaca kurang dari 1 menit tapi lebih dari 10 detik, kita bulatkan jadi 1 menit agar tetap tercatat.
    if (durationInMinutes == 0 && _stopwatch.elapsed.inSeconds > 10) {
      durationInMinutes = 1;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl_siswa}/siswa/save-reading'),
        body: {
          'user_id': widget.studentId.toString(),
          'ebook_id': widget.ebookId.toString(),
          'last_page': _currentPage.toString(),
          'total_pages': widget.totalPages.toString(),
          
          // ---> 5. KIRIM DATA DURASI KE BACKEND <---
          'reading_duration': durationInMinutes.toString(),
        },
      );
      if (response.statusCode == 200) {
        debugPrint("Progress halaman $_currentPage selama $durationInMinutes menit berhasil disimpan!");
      }
    } catch (e) {
      debugPrint("Gagal menyimpan progress baca: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Membentuk URL file PDF yang mengarah ke folder public backend CI4
    final String pdfUrl = '${ApiConfig.baseUrl_siswa}/siswa/stream-ebook/${widget.ebookId}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Simpan progress halaman saat ini ke DB sebelum menutup layar
        await _simpanProgressKeDatabase();
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF333333),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFCC33),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.maybePop(context), // Menggunakan maybePop agar terdeteksi oleh PopScope
          ),
          title: const Text(
            "PDF Viewer",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Bar Judul E-book
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF222222),
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Area Konten Dokumen PDF Asli
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SfPdfViewer.network(
                    pdfUrl,
                    controller: _pdfViewerController,
                    canShowScrollHead: false, 
                    canShowScrollStatus: false,
                    onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                      setState(() => _isDocumentLoaded = true);
                      // Lompat otomatis ke halaman terakhir yang tersimpan di DB
                      _pdfViewerController.jumpToPage(widget.initialPage);
                    },
                    onPageChanged: (PdfPageChangedDetails details) {
                      setState(() {
                        _currentPage = details.newPageNumber;
                      });
                    },
                  ),
                ),
              ),
            ),

            // Slider Navigasi Halaman
            if (_isDocumentLoaded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Slider(
                  value: _currentPage.toDouble(),
                  min: 1,
                  max: widget.totalPages.toDouble(),
                  activeColor: const Color(0xFFFFCC33),
                  inactiveColor: Colors.grey,
                  divisions: widget.totalPages > 1 ? widget.totalPages - 1 : 1,
                  onChanged: (value) {
                    setState(() {
                      _currentPage = value.toInt();
                      _pdfViewerController.jumpToPage(_currentPage);
                    });
                  },
                ),
              ),

            // Tombol Navigasi Bawah
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF222222),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _currentPage > 1
                        ? () {
                            _pdfViewerController.previousPage();
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    label: const Text(
                      "Sebelumnya",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF444444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "$_currentPage / ${widget.totalPages}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _currentPage < widget.totalPages
                        ? () {
                            _pdfViewerController.nextPage();
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    label: const Text(
                      "Berikutnya",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}