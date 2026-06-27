import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_screen.dart';
import '../../api_config.dart'; // Import halaman register yang sudah dibuat

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Variabel untuk menyimpan data dari database
  int guruCount = 0;
  int parentCount = 0;
  int childCount = 0;
  int totalUser = 0;
  int totalEbooks = 0; 

  // Variabel untuk log aktivitas terbaru
  String recentEbookTitle = '';
  String recentEbookDesc = '';
  String recentEbookTime = '';
  bool hasRecentEbook = false;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserStats();
  }

  // Fungsi untuk mengambil data dari API CI4
  Future<void> _fetchUserStats() async {
    // Sesuaikan dengan URL yang berfungsi di environment Anda
    // Gunakan http://10.0.2.2:8080 jika menggunakan Android Emulator
    const String apiUrl = '${ApiConfig.baseUrl}/dashboard/user-stats';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> stats = responseData['data'];

        setState(() {
          guruCount = stats['guru'];
          parentCount = stats['parent'];
          childCount = stats['child'];
          totalUser = stats['total'];
          totalEbooks = stats['total_ebooks'];

          // --- Cek apakah ada data ebook terbaru ---
          if (stats['recent_ebook'] != null && stats['recent_ebook'] is Map) {
            final recent = stats['recent_ebook'];
            recentEbookTitle = recent['title'] ?? 'Tanpa Judul';
            
            // Format Role ke Bahasa Indonesia
            String rawRole = recent['uploader_role'] ?? '';
            String roleLabel = rawRole == 'parent' ? 'Orang Tua' : (rawRole == 'guru' ? 'Guru' : rawRole);
            
            String uploaderName = recent['uploader_name'] ?? 'Anonim';
            
            // Output misal: "Buku Uji Coba" oleh Bapak Andi (Orang Tua)
            recentEbookDesc = '"$recentEbookTitle" oleh $uploaderName ($roleLabel)';
            recentEbookTime = recent['uploaded_at'] ?? ''; 
            
            hasRecentEbook = true;
          } else {
            hasRecentEbook = false;
          }

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showError('Gagal mengambil data dari server');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Terjadi kesalahan koneksi: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD), // Warna background terang
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90E2), // Biru atas
        elevation: 0,
        title: const Text(
          'Dashboard Admin',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
            onPressed: () {
              setState(() => isLoading = true);
              _fetchUserStats(); // Panggil ulang API saat tombol refresh ditekan
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Proses Logout...')),
              );
            },
          ),
          const SizedBox(width: 8), 
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2))) 
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderGradient(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(Icons.people_alt_outlined, 'Manajemen Pengguna'),
                    const SizedBox(height: 12),
                    _buildUserManagementCards(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(Icons.notifications_active_outlined, 'Aktivitas & Log Sistem'),
                    const SizedBox(height: 12),
                    _buildRecentActivityCards(),
                    const SizedBox(height: 24),
                    _buildBottomActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  // 1. HEADER GRADIENT DENGAN STATISTIK
  Widget _buildHeaderGradient() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB485FF), Color(0xFF5B86E5)], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
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
                children: const [
                  Text(
                    'Halo, Admin! 👑',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pantau aktivitas sistem BelajarIn',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.3),
                radius: 24,
                child: const Text(
                  'A',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Grid Statistik Baris 1
          Row(
            children: [
              Expanded(child: _buildStatCard('$totalUser', 'Total User', Icons.group)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('$guruCount', 'Guru Aktif', Icons.school)),
            ],
          ),
          const SizedBox(height: 12),
          // Grid Statistik Baris 2
          Row(
            children: [
              Expanded(child: _buildStatCard('$totalEbooks', 'Total E-Book', Icons.menu_book)), 
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('30', 'Modul Belajar', Icons.assignment)), 
            ],
          ),
        ],
      ),
    );
  }

  // Komponen Kartu Statistik di dalam Header
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. JUDUL SEKSI
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

  // 3. MANAJEMEN PENGGUNA 
  Widget _buildUserManagementCards() {
    return Column(
      children: [
        _buildUserTypeCard(
          icon: Icons.person_4,
          iconColor: Colors.orange,
          title: 'Data Guru',
          subtitle: 'Kelola akses pembuat modul',
          total: '$guruCount Akun', 
        ),
        const SizedBox(height: 12),
        _buildUserTypeCard(
          icon: Icons.family_restroom,
          iconColor: Colors.green,
          title: 'Data Orang Tua',
          subtitle: 'Kelola akses pemantau & uploader PDF',
          total: '$parentCount Akun', 
        ),
        const SizedBox(height: 12),
        _buildUserTypeCard(
          icon: Icons.face,
          iconColor: Colors.blue,
          title: 'Data Anak (Siswa)',
          subtitle: 'Pantau poin & riwayat bacaan',
          total: '$childCount Akun', 
        ),
      ],
    );
  }

  // Komponen List Tile untuk User
  Widget _buildUserTypeCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String total,
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
            Text(total, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
        onTap: () {
          // TODO: Navigasi ke List Detail Pengguna
        },
      ),
    );
  }

  // 4. AKTIVITAS & LOG SISTEM
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
          // Menampilkan Log E-Book secara dinamis jika datanya ada
          if (hasRecentEbook)
            _buildActivityItem(
              title: 'E-Book Baru Diunggah',
              desc: recentEbookDesc,
              time: recentEbookTime,
              icon: Icons.upload_file,
              color: Colors.blue,
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'Belum ada e-book yang diunggah', 
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ),

          const Divider(height: 24),
          
          // Modul Baru (Statis untuk sementara)
          _buildActivityItem(
            title: 'Modul Baru Dibuat',
            desc: '"Matematika Dasar" oleh Pak Budi (Guru)',
            time: 'Kemarin, 16:00',
            icon: Icons.add_task,
            color: Colors.green,
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  // 5. TOMBOL AKSI BAWAH
  Widget _buildBottomActionButtons() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              // Navigasi push ke halaman RegisterScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2), 
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  Icon(Icons.person_add_alt_1, color: Colors.white),
                  SizedBox(height: 8),
                  Text('Tambah User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () {
              // TODO: Aksi Lihat Laporan
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFC084FC), 
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  Icon(Icons.bar_chart, color: Colors.white),
                  SizedBox(height: 8),
                  Text('Laporan Sistem', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}