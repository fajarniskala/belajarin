import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';
import 'tambah_tugas_page.dart';

class RekapTugasPage extends StatefulWidget {
  final int guruId;
  const RekapTugasPage({super.key, required this.guruId});

  @override
  State<RekapTugasPage> createState() => _RekapTugasPageState();
}

class _RekapTugasPageState extends State<RekapTugasPage> {
  List<dynamic> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTaskRecap();
  }

  Future<void> _fetchTaskRecap() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/gurucontroller/task-recap/${widget.guruId}',
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          _tasks = jsonDecode(response.body)['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Warna background senada dashboard
      appBar: AppBar(
        title: const Text("Rekap Tugas"),
        backgroundColor: const Color(0xFF20B2AA),
        foregroundColor: Colors.white, // Warna Teal utama
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF20B2AA)),
            )
          : _tasks.isEmpty
          ? Center(
              child: Text(
                "Belum ada tugas yang dibuat.",
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      16,
                    ), // Rounded sama dengan dashboard
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    title: Text(
                      task['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatusBadge(
                              "${task['pending_count']} Pending",
                              const Color(
                                0xFFF59E0B,
                              ), // Warna Orange (senada button dashboard)
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(
                              "${task['total_submissions']} Terkumpul",
                              const Color(0xFF20B2AA), // Warna Teal
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // Navigasi ke detail (bisa ditambahkan nanti)
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF20B2AA),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => TambahTugasPage(guruId: widget.guruId),
          ),
        ).then((_) => _fetchTaskRecap()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget Badge Kecil agar terlihat profesional
  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            color, // Hapus .withOpacity(0.1) agar background solid dan teks putih terbaca
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white, // <--- Font sudah menjadi putih di sini
        ),
      ),
    );
  }
}
