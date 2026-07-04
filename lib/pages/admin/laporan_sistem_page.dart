import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';

class LaporanSistemPage extends StatefulWidget {
  const LaporanSistemPage({Key? key}) : super(key: key);

  @override
  State<LaporanSistemPage> createState() => _LaporanSistemPageState();
}

class _LaporanSistemPageState extends State<LaporanSistemPage> {
  bool _isLoading = true;
  int _totalPoinBeredar = 0;
  List<dynamic> _leaderboard = [];
  List<dynamic> _bukuPopuler = [];

  @override
  void initState() {
    super.initState();
    _fetchLaporanSistem();
  }

  Future<void> _fetchLaporanSistem() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard/getSystemReport'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'];

        setState(() {
          _totalPoinBeredar = data['total_poin_beredar'] ?? 0;
          _leaderboard = data['leaderboard'] ?? [];
          _bukuPopuler = data['buku_populer'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Gagal memuat laporan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Laporan & Analitik Sistem', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFC084FC), // ✅ Sudah diperbaiki murni hex warna ungu
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC084FC)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD TOTAL POIN BEREDAR
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC084FC), Color(0xFF6366F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Poin Terdistribusi', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Text('$_totalPoinBeredar Poin 🌟', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Akumulasi hadiah keaktifan membaca & tugas seluruh siswa', style: TextStyle(color: Colors.white60, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SEKSI LEADERBOARD GLOBAL
                  _buildSectionTitle(Icons.emoji_events_rounded, 'Peringkat Siswa Teraktif (Leaderboard)', Colors.amber.shade700),
                  const SizedBox(height: 12),
                  _buildCardContainer(
                    child: _leaderboard.isEmpty
                        ? const Center(child: Padding(padding: EdgeInsets.all(16), child: Text("Belum ada data kompetisi anak", style: TextStyle(color: Colors.grey))))
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _leaderboard.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final student = _leaderboard[index];
                              String medal = "";
                              if (index == 0) medal = "🥇";
                              else if (index == 1) medal = "🥈";
                              else if (index == 2) medal = "🥉";
                              else medal = "${index + 1}.";

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade50,
                                  child: Text(medal, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(student['name'] ?? 'Siswa', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(student['email'] ?? '', style: const TextStyle(fontSize: 12)),
                                trailing: Text('${student['total_points'] ?? 0} Poin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 24),

                  // SEKSI BUKU TERPOPULER
                  _buildSectionTitle(Icons.auto_stories_rounded, 'E-Book Cerita Paling Sering Dibaca', Colors.blue),
                  const SizedBox(height: 12),
                  _buildCardContainer(
                    child: _bukuPopuler.isEmpty
                        ? const Center(child: Padding(padding: EdgeInsets.all(16), child: Text("Belum ada log aktivitas bacaan", style: TextStyle(color: Colors.grey))))
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _bukuPopuler.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final book = _bukuPopuler[index];
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.book_rounded, color: Colors.blue),
                                ),
                                title: Text(book['title'] ?? 'Judul Buku', style: const TextStyle(fontWeight: FontWeight.bold)),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                                  child: Text('${book['total_dibaca']}x Dibuka', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}