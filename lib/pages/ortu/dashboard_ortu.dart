import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_config.dart';
import '../../login_screen.dart';
import 'halaman_riwayat.dart';
import 'profil_ortu_page.dart';

class DashboardOrtuScreen extends StatefulWidget {
  final int parentId;
  final String parentName;

  const DashboardOrtuScreen({
    Key? key,
    required this.parentId,
    required this.parentName,
  }) : super(key: key);

  @override
  State<DashboardOrtuScreen> createState() => _DashboardOrtuScreenState();
}

class _DashboardOrtuScreenState extends State<DashboardOrtuScreen> {
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

  Future<void> _fetchDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/ortucontroller/dashboard/${widget.parentId}',
        ),
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

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Konfirmasi Keluar",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Apakah Anda yakin ingin keluar dari halaman pemantauan?",
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Batal",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
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
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Keluar",
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

  @override
  Widget build(BuildContext context) {
    // FILTER BUKU BERDASARKAN STATUS 'is_finished' (0 = Sedang Dibaca, 1 = Selesai)
    final inProgressLogs = _readingLogs.where((log) {
      return log['is_finished'] == 0 || log['is_finished'] == '0';
    }).toList();

    final finishedLogs = _readingLogs.where((log) {
      return log['is_finished'] == 1 || log['is_finished'] == '1';
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),
      appBar: AppBar(
        title: const Text(
          "Dashboard Orang Tua",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6C7EE1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchDashboardData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C7EE1)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 24),

                  // ================= BAGIAN SEDANG DIBACA =================
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF4A5568),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Sedang Dibaca $_childName",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  inProgressLogs.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Center(
                            child: Text(
                              "$_childName belum membaca buku baru saat ini.",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: inProgressLogs
                              .map((log) => _buildReadingCard(log, false))
                              .toList(),
                        ),

                  const SizedBox(height: 24),

                  // ================= BAGIAN SUDAH SELESAI =================
                  Row(
                    children: [
                      const Icon(
                        Icons.check_box,
                        color: Colors.green,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Sudah Selesai",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  finishedLogs.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Center(
                            child: Text(
                              "Belum ada bacaan yang sudah dibaca.",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: finishedLogs
                              .map((log) => _buildReadingCard(log, true))
                              .toList(),
                        ),

                  const SizedBox(height: 24),

                  // ================= TOMBOL LIHAT RIWAYAT =================
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HalamanRiwayat(parentId: widget.parentId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bar_chart, color: Colors.white),
                      label: const Text(
                        "Lihat Riwayat",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC471ED),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    int totalBuku =
        (int.tryParse(_stats['buku_selesai']?.toString() ?? '0') ?? 0) +
        (int.tryParse(_stats['sedang_dibaca']?.toString() ?? '0') ?? 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB15EFF), Color(0xFF5A8BFF)],
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
                    Text(
                      "Halo, ${widget.parentName}!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pantau aktivitas belajar $_childName",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilOrtuPage(
                        parentId: widget.parentId,
                        parentName: widget.parentName,
                        childName: _childName,
                        stats: _stats,
                      ),
                    ),
                  ).then((_) {
                    // Refresh data dashboard ketika kembali dari halaman profil
                    _fetchDashboardData();
                  });
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.25),
                  radius: 24,
                  child: Text(
                    widget.parentName.isNotEmpty
                        ? widget.parentName[0].toUpperCase()
                        : "W",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildGridItem(
                  "$totalBuku",
                  "Total Buku",
                  Icons.library_books,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridItem(
                  "${_stats['buku_selesai']}",
                  "Selesai Dibaca",
                  Icons.check_box,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGridItem(
                  "${_stats['total_durasi']}",
                  "Waktu Baca",
                  Icons.access_time_filled,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridItem(
                  "${_stats['poin_anak']}",
                  "Total Poin",
                  Icons.star,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadingCard(Map<String, dynamic> log, bool isFinished) {
    // [PERBAIKAN] Mengubah String menjadi Integer dengan aman tanpa crash
    int lastPage = int.tryParse(log['last_page']?.toString() ?? '0') ?? 0;
    int totalPages = int.tryParse(log['total_pages']?.toString() ?? '1') ?? 1;

    double progressPercent = lastPage / totalPages;
    int displayPercent = (progressPercent * 100).clamp(0, 100).toInt();

    Color iconBgColor = isFinished
        ? const Color(0xFF3B82F6)
        : const Color(0xFFFFC107);
    IconData iconData = isFinished ? Icons.set_meal : Icons.cruelty_free;
    Color progressColor = isFinished ? Colors.green : const Color(0xFF3B82F6);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(iconData, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log['title'] ?? 'Buku Bacaan',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isFinished
                          ? "Selesai: ${log['last_read_at'] ?? '-'}"
                          : "Terakhir baca: ${log['last_read_at'] ?? '-'}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercent.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          isFinished
              ? Row(
                  children: [
                    const Icon(Icons.check_box, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "Selesai • ${log['reading_duration'] ?? 0} menit baca",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Text(
                  "Hal. $lastPage dari $totalPages • $displayPercent% • ${log['reading_duration'] ?? 0} menit baca",
                  style: TextStyle(
                    fontSize: 12,
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ],
      ),
    );
  }
}
