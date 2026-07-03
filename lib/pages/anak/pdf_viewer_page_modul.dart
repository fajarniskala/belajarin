import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerPage({Key? key, required this.url, required this.title})
    : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background senada dengan halaman lain
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF20B2AA), // Teal khas BelajarIn
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Tombol opsional untuk melihat daftar isi PDF (Bookmark) jika ada
          IconButton(
            icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
            tooltip: 'Daftar Isi Bookmark',
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // =======================================================
          // WIDGET UTAMA PEMBACA PDF DARI URL INTERNET/SERVER
          // =======================================================
          SfPdfViewer.network(
            widget.url,
            key: _pdfViewerKey,
            canShowScrollHead:
                false, // Menyembunyikan header scroll bawaan agar lebih bersih
            canShowScrollStatus: true,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _isLoading = false;
              });
            },
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              setState(() {
                _isLoading = false;
              });
              // Menampilkan peringatan jika file PDF rusak atau URL tidak ditemukan (404)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal memuat PDF: ${details.description}'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          // =======================================================
          // INDIKATOR LOADING SAAT PDF SEDANG DI-DOWNLOAD
          // =======================================================
          if (_isLoading)
            Container(
              color: Colors
                  .white, // Menutupi layar hitam bawaan SfPdfViewer saat loading
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF20B2AA)),
                    SizedBox(height: 16),
                    Text(
                      "Membuka Dokumen...",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
