import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';

// ---> TAMBAHAN IMPORTS UNTUK NAVIGASI BAWAH <---
import 'tambah_siswa_page.dart';
import 'tambah_modul_page.dart';
import 'upload_ebook_page.dart';

class RekapNilaiPage extends StatefulWidget {
  final int guruId;

  const RekapNilaiPage({Key? key, required this.guruId}) : super(key: key);

  @override
  State<RekapNilaiPage> createState() => _RekapNilaiPageState();
}

class _RekapNilaiPageState extends State<RekapNilaiPage> {
  List<dynamic> _recapData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGradesRecap();
  }

  Future<void> _fetchGradesRecap() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/gurucontroller/grades-recap/${widget.guruId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _recapData = jsonDecode(response.body)['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80.0) return Colors.green.shade600;
    if (score >= 60.0) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Rekap Nilai Siswa"),
        backgroundColor: const Color(0xFF20B2AA), 
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // ======================================================================
      // BOTTOM NAVIGATION BAR (ACTIVE INDEX: 3)
      // ======================================================================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 3, 
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
                MaterialPageRoute(builder: (context) => TambahSiswaPage(guruId: widget.guruId)),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TambahModulPage(guruId: widget.guruId)),
              );
            } else if (index == 4) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UploadEbookPage(guruId: widget.guruId)),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.person_add_alt_1), label: 'Siswa'),
            BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Modul'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Nilai'),
            BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: 'E-Book'),
          ],
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF20B2AA)))
          : _recapData.isEmpty
              ? Center(child: Text("Belum ada data nilai terkumpul.", style: TextStyle(color: Colors.grey[600])))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _recapData.length,
                  itemBuilder: (context, index) {
                    final item = _recapData[index];
                    final double avgScore = double.parse(item['average_score'].toString());

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: _getScoreColor(avgScore).withOpacity(0.1),
                          radius: 26,
                          child: Text(
                            avgScore > 0 ? avgScore.toStringAsFixed(0) : '-',
                            style: TextStyle(
                              color: _getScoreColor(avgScore),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        title: Text(
                          item['student_name'] ?? 'Siswa',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.assignment_turned_in_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                "${item['total_tasks']} Tugas Dinilai",
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Membuka detail nilai ${item['student_name']}...")),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}