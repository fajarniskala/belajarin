import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';
import 'upload_ebook_page.dart';
import 'tambah_siswa_page.dart';
import 'tambah_modul_page.dart';
import 'rekap_nilai_page.dart';
import 'pdf_viewer_page.dart';

class ListEbookPage extends StatefulWidget {
  final int guruId;
  const ListEbookPage({Key? key, required this.guruId}) : super(key: key);

  @override
  State<ListEbookPage> createState() => _ListEbookPageState();
}

class _ListEbookPageState extends State<ListEbookPage> {
  List<dynamic> _ebooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGuruEbooks();
  }

  Future<void> _fetchGuruEbooks() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/gurucontroller/my-ebooks/${widget.guruId}',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _ebooks = jsonDecode(response.body)['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Koleksi E-Book Saya",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: const Color(
          0xFF9B59B6,
        ), // Ungu serasi dengan tema E-book kamu
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // Floating Action Button untuk navigasi ke form tambah
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF9B59B6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Upload Buku",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadEbookPage(guruId: widget.guruId),
            ),
          );
          if (result == true) {
            setState(() => _isLoading = true);
            _fetchGuruEbooks(); // Refresh list jika sukses upload
          }
        },
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 4, // Aktif di tab E-Book
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF20B2AA),
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          onTap: (index) {
            if (index == 0) {
              Navigator.pop(context);
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TambahSiswaPage(guruId: widget.guruId),
                ),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TambahModulPage(guruId: widget.guruId),
                ),
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RekapNilaiPage(guruId: widget.guruId),
                ),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_add_alt_1),
              label: 'Siswa',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Modul'),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              label: 'Nilai',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.upload_file),
              label: 'E-Book',
            ),
          ],
        ),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF9B59B6)),
            )
          : _ebooks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 60,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Kamu belum mengunggah E-Book.",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _ebooks.length,
              itemBuilder: (context, index) {
                final book = _ebooks[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B59B6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF9B59B6),
                      ),
                    ),
                    title: Text(
                      book['title'] ?? 'Judul Buku',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Penulis: ${book['author'] ?? '-'} • ${book['total_pages']} Hal",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        book['category_name'] ?? 'Umum',
                        style: const TextStyle(
                          color: Colors.teal,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    //LOGIKA KLIK UTAMA UNTUK MEMBUKA BACAAN PDF
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewerPage(
                            // Mengarahkan ke rute stream-ebook backend menggunakan ID buku dinamis
                            url:
                                '${ApiConfig.baseUrl_siswa}/siswa/stream-ebook/${book['id']}',
                            title: book['title'] ?? 'Membaca E-Book',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
