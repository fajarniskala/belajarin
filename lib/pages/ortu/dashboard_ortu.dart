import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart'; // Pastikan path file configurasi URL API kamu benar

class DashboardOrtuScreen extends StatefulWidget {
  final int parentId; // Menerima ID Orang tua yang dikirim saat sukses login

  const DashboardOrtuScreen({Key? key, required this.parentId}) : super(key: key);

  @override
  State<DashboardOrtuScreen> createState() => _DashboardOrtuScreenState();
}

class _DashboardOrtuScreenState extends State<DashboardOrtuScreen> {
  // Objek penampung data dari database
  Map<String, dynamic> _stats = {
    'buku_selesai': 0,
    'sedang_dibaca': 0,
    'total_durasi': '0 jam',
    'poin_anak': 0,
  };
  List<dynamic> _readingLogs = [];
  String _childName = "Anak";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // JALUR PENGAMBILAN DATA DARI API BACKEND
  Future<void> _fetchDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ortucontroller/dashboard/${widget.parentId}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _stats = responseData['stats'];
          _readingLogs = responseData['reading_logs'];
          _childName = responseData['child_name'] ?? "Anak";
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error fetching dashboard data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Dashboard Orang Tua", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6C7EE1), // Warna senada ungu/periwinkle utama
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchDashboardData();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C7EE1)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ======================= COMPONENT 1: HEADER BANNER GRADIENT =======================
                  _buildHeaderCard(),
                  const SizedBox(height: 24),

                  // ======================= COMPONENT 2: DAFTAR BUKU SEDANG DIBACA =======================
                  Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: Colors.blue, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "Sedang Dibaca $_childName",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Kondisional pengecekan jika anak tidak/belum membaca buku apapun
                  _readingLogs.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: Center(
                            child: Text(
                              "$_childName belum membaca buku baru saat ini.",
                              style: TextStyle(color: Colors.grey[500], fontSize: 13),
                            ),
                          ),
                        )
                      : Column(
                          // Looping widget card mengikuti isi list database logs
                          children: _readingLogs.map((log) => _buildReadingCard(log)).toList(),
                        ),
                ],
              ),
            ),
    );
  }

  // WIDGET GENERATOR UNTUK BANNER GRADIENT ATAS
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7A8CE8), Color(0xFF5A6BC8)], // Kombinasi ungu-periwinkle mewah
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Halo, Wali Murid! 👋", // Bisa diganti session nama ortu jika disimpan
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pantau aktivitas belajar $_childName",
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.25),
                radius: 24,
                child: const Text("W", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              )
            ],
          ),
          const SizedBox(height: 20),
          
          // GRID STATISTIK 2 KOLOM x 2 BARIS
          Row(
            children: [
              Expanded(child: _buildGridItem("${_stats['buku_selesai']}", "Buku Selesai", Icons.assignment_turned_in)),
              const SizedBox(width: 12),
              Expanded(child: _buildGridItem("${_stats['sedang_dibaca']}", "Sedang Dibaca", Icons.chrome_reader_mode)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildGridItem("${_stats['total_durasi']}", "Total Durasi", Icons.access_time_filled)),
              const SizedBox(width: 12),
              Expanded(child: _buildGridItem("${_stats['poin_anak']}", "Poin Anak", Icons.stars)),
            ],
          )
        ],
      ),
    );
  }

  // ITEM CARD KECIL DI DALAM GRID UTAMA
  Widget _buildGridItem(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }

  // WIDGET GENERATOR UNTUK KARTU BUKU "SEDANG DIBACA" (ANTI-OVERFLOW)
  Widget _buildReadingCard(Map<String, dynamic> log) {
    // 1. Ambil data mentah numerik dari map
    int lastPage = log['last_page'] ?? 0;
    int totalPages = log['total_pages'] ?? 1; // Cegah pembagian angka dengan nol (division by zero)

    // 2. Kalkulasi persentase matematika untuk progress bar
    double progressPercent = lastPage / totalPages;
    int displayPercent = (progressPercent * 100).clamp(0, 100).toInt(); // Amankan di range 0-100%

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Wadah Ikon Buku Berwarna Kuning Singa Estetik
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107), // Warna oranye/kuning ikon singa
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.emoji_nature_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              
              // Informasi Utama Judul Buku
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log['title'] ?? 'Buku Bacaan',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Terakhir baca: ${log['last_read_at'] ?? '-'}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // PROGRESS BAR PROGRES MEMBACA ANAK
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercent.clamp(0.0, 1.0), // Amankan bar pengisi agar tidak overflow melebihi lebar kontainer
              backgroundColor: Colors.grey[100],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue), // Warna bar biru sesuai gambar
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 10),

          // DETAIL INDIKATOR TEXT BARIS BAWAH
          Text(
            "Hal. $lastPage dari $totalPages • $displayPercent% • ${log['reading_duration']} menit baca",
            style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}