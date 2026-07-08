import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';

class DetailNilaiSiswaPage extends StatefulWidget {
  final int studentId;
  final String studentName;
  final double averageScore;
  final int totalTasks;

  const DetailNilaiSiswaPage({
    Key? key,
    required this.studentId,
    required this.studentName,
    required this.averageScore,
    required this.totalTasks,
  }) : super(key: key);

  @override
  State<DetailNilaiSiswaPage> createState() => _DetailNilaiSiswaPageState();
}

class _DetailNilaiSiswaPageState extends State<DetailNilaiSiswaPage> {
  List<dynamic> _submissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentSubmissions();
  }

  Future<void> _fetchStudentSubmissions() async {
    try {
      // 🌟 Pastikan studentId dikirim sebagai string di URL
      final String url =
          '${ApiConfig.baseUrl_siswa}/siswa/submited-tasks/${widget.studentId}';
      debugPrint("Fetching dari URL: $url"); // 🔥 Cek ini di Terminal VS Code

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          _submissions = decoded['data'] ?? [];
          _isLoading = false;
        });
      } else {
        debugPrint("Error Status: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error Fetching: $e");
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
        title: Text(
          "Rincian Nilai: ${widget.studentName}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF20B2AA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF20B2AA)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD RINGKASAN STATISTIK SISWA
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  const Text(
                    "Riwayat Pengumpulan Tugas",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _submissions.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              "Siswa belum mengumpulkan tugas apapun.",
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _submissions.length,
                          itemBuilder: (context, index) {
                            final task = _submissions[index];
                            final rawScore = task['score'];
                            final double currentScore = rawScore != null
                                ? double.parse(rawScore.toString())
                                : -1.0;
                            final String status = task['status'] ?? 'pending';

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
                                title: Text(
                                  task['title'] ?? 'Judul Tugas',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "Dikumpul: ${task['submitted_at'] ?? '-'}",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: currentScore >= 0
                                        ? _getScoreColor(
                                            currentScore,
                                          ).withOpacity(0.1)
                                        : Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    currentScore >= 0
                                        ? currentScore.toStringAsFixed(0)
                                        : "Belum\nDinilai",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: currentScore >= 0
                                          ? _getScoreColor(currentScore)
                                          : Colors.amber.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: currentScore >= 0 ? 16 : 10,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF48D1CC), Color(0xFF008080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                widget.averageScore > 0
                    ? widget.averageScore.toStringAsFixed(1)
                    : '-',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Rata-Rata Nilai",
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          Container(width: 1, height: 50, color: Colors.white24),
          Column(
            children: [
              Text(
                "${widget.totalTasks}",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Tugas Selesai",
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
