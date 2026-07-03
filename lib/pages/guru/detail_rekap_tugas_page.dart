import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';
import 'pdf_viewer_page.dart'; // Import halaman view pdf baru

class DetailRekapTugasPage extends StatefulWidget {
  final int taskId;
  final String taskTitle;

  const DetailRekapTugasPage({
    Key? key,
    required this.taskId,
    required this.taskTitle,
  }) : super(key: key);

  @override
  State<DetailRekapTugasPage> createState() => _DetailRekapTugasPageState();
}

class _DetailRekapTugasPageState extends State<DetailRekapTugasPage> {
  List<dynamic> _submissions = [];
  bool _isLoading = true;
  final TextEditingController _scoreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSubmissions();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _fetchSubmissions() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/gurucontroller/task-submissions/${widget.taskId}',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _submissions = jsonDecode(response.body)['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitGrade(int submissionId, String score) async {
    if (score.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/gurucontroller/grade-submission'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "submission_id": submissionId,
          "score": int.parse(score),
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nilai berhasil disimpan!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _fetchSubmissions(); // Auto refresh UI
      }
    } catch (e) {
      _showSnackBar('Terjadi gangguan jaringan', Colors.red);
    }
  }

  void _showGradeDialog(
    int submissionId,
    String studentName,
    String? currentScore,
  ) {
    _scoreController.text = currentScore ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Beri Nilai - $studentName',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _scoreController,
            keyboardType: TextInputType.number,
            maxLength: 3,
            decoration: const InputDecoration(
              hintText: 'Masukkan nilai (0 - 100)',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF20B2AA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _submitGrade(submissionId, _scoreController.text);
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String msg, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.taskTitle),
        backgroundColor: const Color(0xFF20B2AA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF20B2AA)),
            )
          : _submissions.isEmpty
              ? Center(
                  child: Text(
                    "Belum ada siswa yang mengumpulkan.",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _submissions.length,
                  itemBuilder: (context, index) {
                    final submission = _submissions[index];
                    final bool isPending = submission['status'] == 'pending';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. KEPALA CARD: Nama Siswa & Kumpulan Lencana Status (Terlambat & Status Nilai)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                submission['student_name'] ?? 'Siswa',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  // ✅ BADGE TERLAMBAT (Muncul jika terdeteksi lewat deadline)
                                  if (submission['is_late'] == 1 ||
                                      submission['is_late'] == true ||
                                      submission['status'] == 'late')
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red[600],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        "Terlambat",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  // BADGE UTAMA: Status Evaluasi Tugas
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPending
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFF20B2AA),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isPending ? "Belum Dinilai" : "Sudah Dinilai",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),

                          // 2. KONTEN JAWABAN TEKS SISWA
                          if (submission['text_submission'] != null &&
                              submission['text_submission']
                                  .toString()
                                  .trim()
                                  .isNotEmpty) ...[
                            const Text(
                              "Jawaban Teks Siswa:",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Text(
                                submission['text_submission'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // 3. KONTEN LAMPIRAN FILE PDF
                          if (submission['file_submission'] != null &&
                              submission['file_submission']
                                  .toString()
                                  .trim()
                                  .isNotEmpty) ...[
                            const Text(
                              "Lampiran File (Klik untuk melihat):",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PdfViewerPage(
                                      url:
                                          '${ApiConfig.baseUrl}/gurucontroller/stream-submission/${submission['file_submission']}',
                                      title:
                                          "File Tugas - ${submission['student_name']}",
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade100),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.picture_as_pdf,
                                        color: Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        submission['file_submission'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // 4. KAKI CARD: Tanggal Kumpul, Info Nilai & Tombol Aksi Evaluasi
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Dikumpul: ${submission['submitted_at'] ?? '-'}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    submission['score'] != null
                                        ? "Nilai: ${submission['score']}"
                                        : "Nilai: -",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF20B2AA),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isPending
                                          ? const Color(0xFFF59E0B)
                                          : Colors.grey.shade600,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      isPending ? "Beri Nilai" : "Ubah Nilai",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      final int safeSubmissionId =
                                          submission['id'] is int
                                              ? submission['id']
                                              : int.parse(submission['id']
                                                  .toString());
                                      _showGradeDialog(
                                        safeSubmissionId,
                                        submission['student_name'] ?? 'Siswa',
                                        submission['score']?.toString(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
  }
}