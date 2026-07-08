import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';

class VerifikasiUserPage extends StatefulWidget {
  const VerifikasiUserPage({Key? key}) : super(key: key);

  @override
  State<VerifikasiUserPage> createState() => _VerifikasiUserPageState();
}

class _VerifikasiUserPageState extends State<VerifikasiUserPage> {
  List<dynamic> _pendingUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingUsers();
  }

  Future<void> _fetchPendingUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard/pending-users'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _pendingUsers = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data antrean verifikasi', Colors.red);
    }
  }

  // 🌟 PERBAIKAN 1: Mengubah parameter id menjadi String agar fleksibel menerima data dari database
  Future<void> _processVerification(String id, String action) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/dashboard/verify-user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'action': action}),
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        _showSnackBar(
          resData['message'] ?? 'Aksi berhasil diproses!',
          Colors.green,
        );
        _fetchPendingUsers(); // Auto refresh daftar setelah sukses eksekusi
      } else {
        _showSnackBar('Gagal memproses verifikasi', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Terjadi kendala koneksi internet', Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text(
          'Persetujuan Akun Baru',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
            )
          : _pendingUsers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    size: 70,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Semua bersih! Tidak ada antrean verifikasi.",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingUsers.length,
              itemBuilder: (context, index) {
                final user = _pendingUsers[index];
                String rawRole = user['role'] ?? 'child';

                Color roleColor = rawRole == 'guru'
                    ? Colors.teal
                    : (rawRole == 'parent' ? Colors.purple : Colors.blue);
                String roleLabel = rawRole == 'guru'
                    ? 'GURU'
                    : (rawRole == 'parent' ? 'ORANG TUA' : 'ANAK');

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: roleColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              roleLabel,
                              style: TextStyle(
                                color: roleColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            user['created_at'] ?? '',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email'] ?? '',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const Divider(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red[400],
                              side: BorderSide(color: Colors.red.shade200),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text(
                              'Tolak',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            // 🌟 PERBAIKAN 2: Menggunakan .toString() agar aman dikirim ke backend
                            onPressed: () => _processVerification(
                              user['id'].toString(),
                              'reject',
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[500],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: const Text(
                              'Setujui Akun',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            // 🌟 PERBAIKAN 3: Menggunakan .toString() agar aman dikirim ke backend
                            onPressed: () => _processVerification(
                              user['id'].toString(),
                              'approve',
                            ),
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
