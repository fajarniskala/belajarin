import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../login_screen.dart';
import 'tambah_siswa_page.dart';
import 'tambah_modul_page.dart';
import 'rekap_tugas_page.dart';
import '../../api_config.dart';
import 'kelola_modul_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daftar_siswa_page.dart';
import 'rekap_nilai_page.dart';
import 'upload_ebook_page.dart';

class GuruDashboardScreen extends StatefulWidget {
  final int guruId;

  const GuruDashboardScreen({Key? key, required this.guruId}) : super(key: key);

  @override
  State<GuruDashboardScreen> createState() => _GuruDashboardScreenState();
}

class _GuruDashboardScreenState extends State<GuruDashboardScreen> {
  int myStudentCount = 0;
  int myModuleCount = 0;
  int pendingTaskCount = 0;
  int totalPointsGiven = 0;

  String recentActivityTitle = '';
  String recentActivityDesc = '';
  String recentActivityTime = '';
  bool hasRecentActivity = false;
  String _guruName = 'Guru';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGuruStats();
    _loadGuruName();
  }

  Future<void> _loadGuruName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _guruName = prefs.getString('name') ?? 'Guru';
    });
  }

  Future<void> _fetchGuruStats() async {
    final String apiUrl =
        '${ApiConfig.baseUrl}/gurucontroller/guru-stats?guru_id=${widget.guruId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> stats = responseData['data'];

        setState(() {
          myStudentCount = stats['my_students'] ?? 0;
          myModuleCount = stats['my_modules'] ?? 0;
          pendingTaskCount = stats['pending_tasks'] ?? 0;
          totalPointsGiven = stats['total_points'] ?? 0;

          if (stats['recent_activity'] != null &&
              stats['recent_activity'] is Map) {
            final recent = stats['recent_activity'];
            recentActivityTitle = recent['title'] ?? 'Aktivitas Baru';
            String studentName = recent['student_name'] ?? 'Siswa';
            String action = recent['action'] ?? 'menyelesaikan tugas';
            recentActivityDesc = '$studentName $action';
            recentActivityTime = recent['created_at'] ?? '';
            hasRecentActivity = true;
          } else {
            hasRecentActivity = false;
          }

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showError('Gagal mengambil data dari server');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _setDummyData();
    }
  }

  void _setDummyData() {
    setState(() {
      myStudentCount = 20;
      myModuleCount = 8;
      pendingTaskCount = 3;
      totalPointsGiven = 450;

      hasRecentActivity = true;
      recentActivityTitle = 'Tugas Dikumpulkan';
      recentActivityDesc = 'Andi mengumpulkan tugas Sains';
      recentActivityTime = 'Hari ini, 09:30';

      isLoading = false;
    });
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout, color: Color(0xFF20B2AA)),
              SizedBox(width: 10),
              Text(
                'Konfirmasi Logout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun ini?',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF20B2AA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'Ya, Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
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
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF20B2AA),
        elevation: 0,
        title: const Text(
          'Dashboard Guru',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
            onPressed: () {
              setState(() => isLoading = true);
              _fetchGuruStats();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _showLogoutDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      // ======================================================================
      // BOTTOM NAVIGATION BAR (PENGGANTI TOMBOL GRID BAWAH)
      // ======================================================================
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
          currentIndex: 0, // Indeks 0 (Home) akan selalu nyala
          type: BottomNavigationBarType.fixed, // Agar semua label menu muncul
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF20B2AA), // Warna teal aktif
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          onTap: (index) async {
            // Logika Routing (Navigasi) berdasarkan indeks tab yang diklik
            if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TambahSiswaPage(guruId: widget.guruId)));
            } else if (index == 2) {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => TambahModulPage(guruId: widget.guruId)));
              // Jika baru saja menambah modul dan kembali, segarkan statistik
              if (result == true) {
                setState(() => isLoading = true);
                _fetchGuruStats();
              }
            } else if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => RekapNilaiPage(guruId: widget.guruId)));
            } else if (index == 4) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UploadEbookPage(guruId: widget.guruId)));
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
            BottomNavigationBarItem(
              icon: Icon(Icons.post_add),
              label: 'Modul',
            ),
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
      // ======================================================================

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF20B2AA)),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderGradient(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(Icons.class_outlined, 'Manajemen Kelas'),
                    const SizedBox(height: 12),
                    _buildClassManagementCards(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      Icons.notifications_active_outlined,
                      'Aktivitas Siswa Terbaru',
                    ),
                    const SizedBox(height: 12),
                    _buildRecentActivityCards(),
                    const SizedBox(height: 10), // Jarak napas dengan Navbar Bawah
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderGradient() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF48D1CC), Color(0xFF008080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, $_guruName!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pantau perkembangan siswa Anda',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.3),
                radius: 24,
                child: const Icon(Icons.school, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '$myStudentCount',
                  'Siswa Saya',
                  Icons.people,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '$myModuleCount',
                  'Modul Saya',
                  Icons.menu_book,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '$pendingTaskCount',
                  'Tugas Masuk',
                  Icons.assignment_late,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '$totalPointsGiven',
                  'Poin Diberikan',
                  Icons.stars,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
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
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildClassManagementCards() {
    return Column(
      children: [
        _buildListCard(
          icon: Icons.face,
          iconColor: Colors.blue,
          title: 'Daftar Siswa',
          subtitle: 'Data Siswa',
          infoBadge: '$myStudentCount Anak',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DaftarSiswaPage(guruId: widget.guruId),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildListCard(
          icon: Icons.library_books,
          iconColor: Colors.orange,
          title: 'Modul & Materi',
          subtitle: 'Kelola modul pembelajaran Anda',
          infoBadge: '$myModuleCount Modul',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => KelolaModulPage(guruId: widget.guruId),
              ),
            ).then(
              (_) => _fetchGuruStats(),
            ); 
          },
        ),
        const SizedBox(height: 12),
        _buildListCard(
          icon: Icons.assignment_turned_in,
          iconColor: Colors.green,
          title: 'Evaluasi & Tugas',
          subtitle: 'Periksa tugas dan berikan poin',
          infoBadge: '$pendingTaskCount Pending',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RekapTugasPage(guruId: widget.guruId),
              ),
            ).then((_) => _fetchGuruStats()); 
          },
        ),
      ],
    );
  }

  Widget _buildListCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String infoBadge,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              infoBadge,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
        onTap: onTap ?? () {}, 
      ),
    );
  }

  Widget _buildRecentActivityCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          if (hasRecentActivity)
            _buildActivityItem(
              title: recentActivityTitle,
              desc: recentActivityDesc,
              time: recentActivityTime,
              icon: Icons.task_alt,
              color: Colors.blue,
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'Belum ada aktivitas siswa hari ini',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String desc,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}