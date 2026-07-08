import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api_config.dart';
import 'pdf_viewer_page.dart';

class PerpustakaanPage extends StatefulWidget {
  final int studentId;

  const PerpustakaanPage({super.key, required this.studentId});

  @override
  State<PerpustakaanPage> createState() => _PerpustakaanPageState();
}

class _PerpustakaanPageState extends State<PerpustakaanPage> {
  List<dynamic> _books = [];
  bool _isLoading = true;

  final List<Color> _cardColors = [
    Colors.amber.shade400,
    Colors.green.shade500,
    Colors.blue.shade500,
    Colors.red.shade400,
    Colors.purple.shade400,
  ];

  @override
  void initState() {
    super.initState();
    _fetchLibraryBooks();
  }

  Future<void> _fetchLibraryBooks() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl_siswa}/siswa/library-books/${widget.studentId}',
        ),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _books = jsonDecode(response.body)['data'];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error ambil buku perpustakaan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFCE93D8), 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Perpustakaan E-Book (Tampilan Anak)",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFBA68C8), 
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Perpustakaanku",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isLoading
                              ? "Menghitung buku..."
                              : "${_books.length} buku menunggumu!",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFBA68C8)),
                  )
                : _books.isEmpty
                ? const Center(
                    child: Text(
                      "Wah, rak buku masih kosong.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _books.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 260, // 🌟 DIUBAH: Dari 245 ke 260 agar pas menampung kolom penulis
                        ),
                    itemBuilder: (context, index) {
                      final book = _books[index];
                      final int totalPages = int.parse(
                        book['total_pages'].toString(),
                      );
                      final int lastPage = book['last_page'] != null
                          ? int.parse(book['last_page'].toString())
                          : 0;
                      final bool isFinished =
                          book['is_finished'].toString() == '1';

                      final Color bookThemeColor =
                          _cardColors[index % _cardColors.length];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfViewerPage(
                                studentId: widget.studentId,
                                ebookId: int.parse(book['id'].toString()),
                                title: book['title'] ?? '',
                                initialPage: isFinished
                                    ? 1
                                    : (lastPage > 0 ? lastPage : 1),
                                totalPages: totalPages,
                                fileUrl: book['file_url'] ?? 'sample.pdf',
                              ),
                            ),
                          ).then((_) => _fetchLibraryBooks());
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: bookThemeColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.menu_book_rounded,
                                    size: 55,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildStatusTag(
                                      lastPage,
                                      totalPages,
                                      isFinished,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      book['title'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    
                                    // 🔥 BARU: MENAMPILKAN DETAIL PENGARANG / PENULIS E-BOOK
                                    Text(
                                      "Oleh: ${book['author'] ?? 'Anonim'}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 2),

                                    Text(
                                      lastPage > 0
                                          ? "$lastPage dari $totalPages hal."
                                          : "$totalPages halaman",
                                      style: const TextStyle(
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),

                                    if (lastPage > 0) ...[
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: lastPage / totalPages,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation(
                                            isFinished
                                                ? Colors.green
                                                : Colors.blue,
                                          ),
                                          minHeight: 5,
                                        ),
                                      ),
                                    ],
                                  ],
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

  Widget _buildStatusTag(int lastPage, int totalPages, bool isFinished) {
    String label = "✨ Baru";
    Color bg = Colors.amber.shade50;
    Color text = Colors.amber.shade800;

    if (isFinished) {
      label = "✅ Selesai";
      bg = Colors.green.shade50;
      text = Colors.green.shade700;
    } else if (lastPage > 0) {
      int percent = ((lastPage / totalPages) * 100).toInt();
      label = "📖 $percent%";
      bg = Colors.blue.shade50;
      text = Colors.blue.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}