import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kerjakan_tugas_page.dart';
import 'pdf_viewer_page.dart';
import 'daftar_modul_page.dart';
import 'perpustakaan_page.dart';
import '../../login_screen.dart';
import 'dart:convert';
import '../../api_config.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final int studentId;
  final String studentName;

  const HomePage({
    super.key,
    required this.studentId, // Wajib diisi saat memanggil HomePage
    required this.studentName, // Wajib diisi saat memanggil HomePage
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- Daftar State Wadah Penyimpanan Data dari DB ---
  List<dynamic> _listTugasTertunda = [];
  List<dynamic> _listKategori = [];
  List<dynamic> _listTugasSelesai = [];
  List<dynamic> _listAllEbooks =
      []; // Wadah untuk menyimpan semua koleksi buku cerita
  Map<String, dynamic>? _latestBookLog;

  // --- State Indikator Pemuatan Data (Loading) ---
  bool _isLoadingTugas = true;
  bool _isLoadingKategori = true;
  bool _isLoadingBook = true;
  bool _isLoadingTugasSelesai = true;
  bool _isLoadingAllEbooks = true;

  // --- State Statistik Gamifikasi Kepala Beranda ---
  int _totalPoin = 0;
  int _totalBadge = 0;
  int _hariStreak = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _fetchTugasTertunda();
    _fetchKategoriBelajar();
    _fetchLatestReading();
    _fetchGamificationStats();
    _fetchTugasSelesai();
    _fetchAllEbooks(); // Memuat koleksi rak buku cerita saat halaman dibuka
  }

  // ================= AMBIL DATA DARI API BACKEND =================

  // Ambil Koleksi Semua Buku Cerita untuk Rak Buku
  Future<void> _fetchAllEbooks() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl_siswa}/siswa/all-ebooks'),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _listAllEbooks = jsonDecode(response.body)['data'];
            _isLoadingAllEbooks = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingAllEbooks = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingAllEbooks = false);
      print("Error ambil semua ebook: $e");
    }
  }

  // Ambil Statistik Poin, Badge, dan Streak Anak
  Future<void> _fetchGamificationStats() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl_siswa}/siswa/gamification-stats/${widget.studentId}',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (mounted) {
          setState(() {
            _totalPoin = data['total_poin'];
            _totalBadge = data['total_badge'];
            _hariStreak = data['hari_streak'];
            _isLoadingStats = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingStats = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
      print("Error ambil statistik gamifikasi: $e");
    }
  }

  // Ambil Data Progres E-book yang Terakhir Dibaca
  Future<void> _fetchLatestReading() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl_siswa}/siswa/latest-reading/${widget.studentId}',
        ),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _latestBookLog = jsonDecode(response.body)['data'];
            _isLoadingBook = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingBook = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingBook = false);
      print("Error ambil log bacaan: $e");
    }
  }

  // Ambil Data Daftar Tugas yang Belum Dikerjakan Siswa
  Future<void> _fetchTugasTertunda() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl_siswa}/siswa/pending-tasks/${widget.studentId}',
        ),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _listTugasTertunda = jsonDecode(response.body)['data'];
            _isLoadingTugas = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingTugas = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTugas = false);
      print("Error ambil tugas: $e");
    }
  }

  // Ambil Data Kategori Pelajaran Beserta Jumlah Modulnya
  Future<void> _fetchKategoriBelajar() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl_siswa}/siswa/categories-with-count/${widget.studentId}',
        ),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _listKategori = jsonDecode(response.body)['data'];
            _isLoadingKategori = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingKategori = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingKategori = false);
      print("Error ambil kategori: $e");
    }
  }

  // Ambil Riwayat Pengumpulan Jawaban Tugas & Nilai dari Guru
  Future<void> _fetchTugasSelesai() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl_siswa}/siswa/submited-tasks/${widget.studentId}',
        ),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _listTugasSelesai = jsonDecode(response.body)['data'];
            _isLoadingTugasSelesai = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingTugasSelesai = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTugasSelesai = false);
      print("Error ambil riwayat tugas: $e");
    }
  }

  // --- DIALOG KONFIRMASI LOGOUT DENGAN CLEAR PREFERENCES ---
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Text("🥺 ", style: TextStyle(fontSize: 24)),
              Text(
                "Mau Keluar?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: const Text(
            "Apakah kamu yakin ingin selesai belajar dan keluar dari aplikasi BelajarIn?",
            style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Tidak, Tetap Belajar 🚀",
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // 🔐 MEMBERSIHKAN SELURUH DATA SESI DAN TOKEN DI HP ANAK
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Bersihkan halaman dan arahkan kembali ke halaman utama login_page.dart
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
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
                "Ya, Keluar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= FUNGSI BANTUAN GENERATOR UI =================

  Color _parseHexColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.blue;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

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
    String initial = widget.studentName.isNotEmpty
        ? widget.studentName[0].toUpperCase()
        : "S";

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER GAMIFIKASI KEPALA BERANDA ---
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                              "Hai, Selamat Belajar ✨",
                              style: TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.studentName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 32,
                              ),
                            ),
                          ],
                        ),
                        // GABUNGAN AVATAR & LOGO LOGOUT JELAS DI SEBELAH KANAN
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.yellow[600],
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(80),
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  style: BorderStyle.solid,
                                  width: 4,
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 32,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Tombol Logout dengan icon yang jelas dan intuitif untuk anak
                            IconButton(
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () => _showLogoutConfirmation(context),
                              tooltip: 'Keluar Aplikasi',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CardAchiev(
                          icons: Icons.star,
                          colors: Colors.amber,
                          values: _isLoadingStats
                              ? "..."
                              : _totalPoin.toString(),
                          desc: "Total Poin",
                        ),
                        CardAchiev(
                          icons: Icons.workspace_premium,
                          colors: Colors.brown.shade200,
                          values: _isLoadingStats
                              ? "..."
                              : _totalBadge.toString(),
                          desc: "Badge",
                        ),
                        CardAchiev(
                          icons: Icons.local_fire_department,
                          colors: Colors.amber.shade900,
                          values: _isLoadingStats
                              ? "..."
                              : _hariStreak.toString(),
                          desc: "Hari Streak",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: LANJUT MEMBACA ---
                  Row(
                    children: [
                      Icon(Icons.menu_book, color: Colors.blue[900], size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        "Lanjut Membaca",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isLoadingBook)
                    const Center(child: CircularProgressIndicator())
                  else if (_latestBookLog == null)
                    const Text(
                      "Belum ada buku bacaan untukmu.",
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.book,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _latestBookLog!['title'] ?? 'Buku Bacaan',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  int.parse(
                                            _latestBookLog!['last_page']
                                                .toString(),
                                          ) ==
                                          int.parse(
                                            _latestBookLog!['total_pages']
                                                .toString(),
                                          )
                                      ? "🎉 Hore! Sudah selesai kamu baca"
                                      : "Terakhir dibaca baru saja",
                                  style: TextStyle(
                                    color:
                                        int.parse(
                                              _latestBookLog!['last_page']
                                                  .toString(),
                                            ) ==
                                            int.parse(
                                              _latestBookLog!['total_pages']
                                                  .toString(),
                                            )
                                        ? Colors.green[700]
                                        : Colors.black45,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value:
                                        int.parse(
                                          _latestBookLog!['last_page']
                                              .toString(),
                                        ) /
                                        int.parse(
                                          _latestBookLog!['total_pages']
                                              .toString(),
                                        ),
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation(
                                      int.parse(
                                                _latestBookLog!['last_page']
                                                    .toString(),
                                              ) ==
                                              int.parse(
                                                _latestBookLog!['total_pages']
                                                    .toString(),
                                              )
                                          ? Colors.green
                                          : Colors.blue,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Halaman ${_latestBookLog!['last_page']} dari ${_latestBookLog!['total_pages']}",
                                  style: const TextStyle(
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfViewerPage(
                                          studentId: widget.studentId,
                                          ebookId: int.parse(
                                            _latestBookLog!['ebook_id']
                                                .toString(),
                                          ),
                                          title: _latestBookLog!['title'] ?? '',
                                          initialPage:
                                              int.parse(
                                                    _latestBookLog!['last_page']
                                                        .toString(),
                                                  ) ==
                                                  int.parse(
                                                    _latestBookLog!['total_pages']
                                                        .toString(),
                                                  )
                                              ? 1
                                              : int.parse(
                                                  _latestBookLog!['last_page']
                                                      .toString(),
                                                ),
                                          totalPages: int.parse(
                                            _latestBookLog!['total_pages']
                                                .toString(),
                                          ),
                                          fileUrl:
                                              _latestBookLog!['file_url'] ??
                                              'sample.pdf',
                                        ),
                                      ),
                                    ).then((_) {
                                      _fetchLatestReading();
                                      _fetchGamificationStats();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        int.parse(
                                              _latestBookLog!['last_page']
                                                  .toString(),
                                            ) ==
                                            int.parse(
                                              _latestBookLog!['total_pages']
                                                  .toString(),
                                            )
                                        ? Colors.green[600]
                                        : Colors.blue[900],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    int.parse(
                                              _latestBookLog!['last_page']
                                                  .toString(),
                                            ) ==
                                            int.parse(
                                              _latestBookLog!['total_pages']
                                                  .toString(),
                                            )
                                        ? "Baca Lagi 🔄"
                                        : "Lanjutkan",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),

                  // --- RAK BUKU CERITA (HORIZONTAL SCROLLING) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.library_books,
                            color: Colors.blue[900],
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Rak Buku Cerita",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PerpustakaanPage(studentId: widget.studentId),
                            ),
                          ).then((_) {
                            _fetchLatestReading();
                            _fetchAllEbooks();
                          });
                        },
                        child: Text(
                          "Lihat Semua",
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isLoadingAllEbooks)
                    const Center(child: CircularProgressIndicator())
                  else if (_listAllEbooks.isEmpty)
                    const Text(
                      "Belum ada koleksi buku cerita di rak.",
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    SizedBox(
                      height: 175,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _listAllEbooks.length,
                        itemBuilder: (context, index) {
                          final book = _listAllEbooks[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfViewerPage(
                                    studentId: widget.studentId,
                                    ebookId: int.parse(book['id'].toString()),
                                    title: book['title'] ?? '',
                                    initialPage: 1,
                                    totalPages: int.parse(
                                      book['total_pages'].toString(),
                                    ),
                                    fileUrl: book['file_url'] ?? 'sample.pdf',
                                  ),
                                ),
                              ).then((_) {
                                _fetchLatestReading();
                                _fetchGamificationStats();
                              });
                            },
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      color: Colors.amber[100],
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.book,
                                      size: 50,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    book['title'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 30),

                  // --- TUGAS TERTUNDA ---
                  Row(
                    children: [
                      Icon(
                        Icons.assignment_late,
                        color: Colors.red[400],
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Tugas Tertunda",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isLoadingTugas)
                    const Center(child: CircularProgressIndicator())
                  else if (_listTugasTertunda.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: const Column(
                        children: [
                          Text("🎉", style: TextStyle(fontSize: 40)),
                          SizedBox(height: 8),
                          Text(
                            "Hore! Semua tugas sudah selesai.",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: _listTugasTertunda.map((tugas) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.red.shade100,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.calculate,
                                  color: Colors.red[400],
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tugas['title'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tugas['due_date'] != null
                                          ? "Tenggat: ${tugas['due_date'].toString().substring(0, 10)}"
                                          : "Tidak ada batas waktu",
                                      style: TextStyle(
                                        color: Colors.red[400],
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => KerjakanTugasPage(
                                        studentId: widget.studentId,
                                        taskId: int.parse(
                                          tugas['id'].toString(),
                                        ),
                                        taskTitle: tugas['title'] ?? '',
                                      ),
                                    ),
                                  ).then((_) {
                                    _fetchTugasTertunda();
                                    _fetchTugasSelesai();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[400],
                                ),
                                child: const Text(
                                  "Kerjakan",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 30),

                  // --- KATEGORI BELAJAR ---
                  Row(
                    children: [
                      Icon(
                        Icons.grid_view_rounded,
                        color: Colors.blue[900],
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Kategori Belajar",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isLoadingKategori)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _listKategori.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 140,
                          ),
                      itemBuilder: (context, index) {
                        final kat = _listKategori[index];
                        final Color baseColor = _parseHexColor(
                          kat['color_hex'],
                        );
                        final int categoryId = int.parse(kat['id'].toString());

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DaftarModulPage(
                                  studentId: widget.studentId,
                                  categoryId: categoryId,
                                  categoryName: kat['name'] ?? 'Materi Belajar',
                                  colorHex: kat['color_hex'] ?? '#2196F3',
                                  iconName: kat['icon'],
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: CardModule(
                            icons: _getCategoryIcon(kat['icon']),
                            colorsIc: baseColor,
                            colors: baseColor.withOpacity(0.12),
                            colorsTitle: baseColor.withOpacity(0.9),
                            colorsCount: baseColor.withOpacity(0.6),
                            title: kat['name'] ?? '',
                            count: "${kat['total_modul']} modul",
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 35),

                  // --- RIWAYAT TUGAS & NILAI VALIDASI ---
                  Row(
                    children: [
                      Icon(
                        Icons.assignment_turned_in_rounded,
                        color: Colors.green[600],
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Riwayat Tugas Selesai",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isLoadingTugasSelesai)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    )
                  else if (_listTugasSelesai.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Belum ada tugas yang kamu kumpulkan.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _listTugasSelesai.map((itemTugas) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itemTugas['title'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Dikirim: ${itemTugas['submitted_at'] != null ? itemTugas['submitted_at'].toString().substring(0, 10) : '-'}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (itemTugas['status'] == 'pending')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[50],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Diproses ⏳",
                                    style: TextStyle(
                                      color: Colors.amber[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Nilai: ${itemTugas['score'] ?? '0'}",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ================= WIDGET KOMPONEN PENDUKUNG =================

class CardModule extends StatelessWidget {
  final IconData icons;
  final String title;
  final String count;
  final Color colors;
  final Color colorsIc;
  final Color colorsTitle;
  final Color colorsCount;

  const CardModule({
    super.key,
    required this.icons,
    required this.title,
    required this.count,
    required this.colors,
    required this.colorsIc,
    required this.colorsTitle,
    required this.colorsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icons, size: 32, color: colorsIc),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: colorsTitle,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                color: colorsCount,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardAchiev extends StatelessWidget {
  final String values;
  final String desc;
  final IconData icons;
  final Color colors;

  const CardAchiev({
    super.key,
    required this.values,
    required this.desc,
    required this.icons,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icons, color: colors, size: 24),
              const SizedBox(width: 4),
              Text(
                values,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
