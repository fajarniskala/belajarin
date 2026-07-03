import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';
import 'tambah_modul_page.dart';
import 'pdf_viewer_page.dart';

class KelolaModulPage extends StatefulWidget {
  final int guruId;

  const KelolaModulPage({Key? key, required this.guruId}) : super(key: key);

  @override
  State<KelolaModulPage> createState() => _KelolaModulPageState();
}

class _KelolaModulPageState extends State<KelolaModulPage> {
  List<dynamic> _modules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchModules();
  }

  Future<void> _fetchModules() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/gurucontroller/modules-detailed/${widget.guruId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _modules = jsonDecode(response.body)['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ==================== FUNGSI AKSI HAPUS KE BACKEND ====================
  Future<void> _deleteModule(int moduleId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/gurucontroller/delete-module/$moduleId'),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Modul berhasil dihapus', Colors.green);
        _fetchModules(); // Refresh daftar modul setelah berhasil dihapus
      } else {
        _showSnackBar('Gagal menghapus modul dari server', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Terjadi gangguan jaringan', Colors.red);
    }
  }

  // ==================== DIALOG KONFIRMASI HAPUS MODUL ====================
  void _showDeleteDialog(int moduleId, String moduleTitle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Hapus Modul', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Text('Apakah Anda yakin ingin menghapus modul "$moduleTitle"? File materi PDF terkait juga akan dihapus permanen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog dulu
                _deleteModule(moduleId); // Jalankan fungsi hapus
              },
              child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String msg, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Modul & Materi"),
        backgroundColor: const Color(0xFF20B2AA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF20B2AA)))
          : _modules.isEmpty
              ? Center(child: Text("Belum ada modul yang dibuat.", style: TextStyle(color: Colors.grey[600])))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _modules.length,
                  itemBuilder: (context, index) {
                    final module = _modules[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFF20B2AA).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Text(module['category_name'] ?? 'Kategori', style: const TextStyle(color: Color(0xFF008080), fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                Text("Urutan: ${module['order_seq']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(module['title'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 6),
                            Text(module['description'] ?? '-', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                            const SizedBox(height: 14),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            
                            // BARIS BAWAH: INDIKATOR DAN TOMBOL HAPUS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.layers_outlined, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text("Level ${module['level']}", style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                    const SizedBox(width: 14),
                                    const Icon(Icons.stars_rounded, size: 14, color: Color(0xFFF59E0B)),
                                    const SizedBox(width: 4),
                                    Text("${module['total_points']} Poin", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                                  ],
                                ),
                                
                                Row(
                                  children: [
                                    if (module['file_pdf'] != null && module['file_pdf'].toString().trim().isNotEmpty)
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PdfViewerPage(
                                                url: '${ApiConfig.baseUrl}/gurucontroller/stream-module/${module['file_pdf']}',
                                                title: module['title'] ?? "Lihat Modul",
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(4),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          child: Row(
                                            children: [
                                              Icon(Icons.picture_as_pdf_rounded, size: 14, color: Colors.red),
                                              SizedBox(width: 4),
                                              Text("PDF", style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 16),
                                    
                                    // ================= TOMBOL TRASH UNTUK HAPUS =================
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () {
                                        _showDeleteDialog(module['id'], module['title'] ?? 'Modul');
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF20B2AA),
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => TambahModulPage(guruId: widget.guruId)));
          if (result == true) {
            setState(() => _isLoading = true);
            _fetchModules();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}