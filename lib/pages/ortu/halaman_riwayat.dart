import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';

class HalamanRiwayat extends StatefulWidget {
  final int parentId;

  const HalamanRiwayat({Key? key, required this.parentId}) : super(key: key);

  @override
  State<HalamanRiwayat> createState() => _HalamanRiwayatState();
}

class _HalamanRiwayatState extends State<HalamanRiwayat> {
  bool _isLoading = true;
  String _childName = "Anak";
  String _totalDurasi = "0m";
  int _totalBuku = 0;
  List<dynamic> _riwayat = [];

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ortucontroller/riwayat-baca/${widget.parentId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _childName = data['child_name'] ?? 'Anak';
          _totalDurasi = data['total_durasi'] ?? '0m';
          _totalBuku = data['total_buku'] ?? 0;
          _riwayat = data['riwayat'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3), // Warna background nyambung dengan dashboard ortu
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B6B),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Riwayat Membaca", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buatHeaderMerah(),
                  const SizedBox(height: 16),
                  
                  _riwayat.isEmpty 
                    ? const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Text("Belum ada riwayat bacaan.", style: TextStyle(color: Colors.grey)),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: _riwayat.map((log) {
                            
                            // [KEAMANAN DATA]
                            int isFinished = int.tryParse(log['is_finished']?.toString() ?? '0') ?? 0;
                            int lastPage = int.tryParse(log['last_page']?.toString() ?? '0') ?? 0;
                            int totalPages = int.tryParse(log['total_pages']?.toString() ?? '1') ?? 1;
                            int duration = int.tryParse(log['reading_duration']?.toString() ?? '0') ?? 0;
                            
                            double progress = lastPage / totalPages;
                            int persentase = (progress * 100).clamp(0, 100).toInt();

                            bool selesai = (isFinished == 1 || lastPage >= totalPages);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buatKartuBuku(
                                ikon: selesai ? '🐠' : '🦁', // Ikan untuk selesai, Singa untuk belum
                                warnaIkon: selesai ? Colors.blue : Colors.orange,
                                judul: log['title'] ?? 'Buku Tanpa Judul',
                                status: selesai 
                                  ? 'Selesai: ${log['last_read_at'] ?? '-'}' 
                                  : 'Terakhir: ${log['last_read_at'] ?? '-'}',
                                persentase: progress.clamp(0.0, 1.0),
                                warnaProgress: selesai ? Colors.green : Colors.blue,
                                teksBawah: selesai 
                                  ? '✅ $lastPage/$totalPages hal • $duration menit'
                                  : 'Hal. $lastPage/$totalPages • $persentase% • $duration menit',
                                teksBawahWarna: selesai ? Colors.green : Colors.blue,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buatHeaderMerah() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B6B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bar_chart, color: Colors.white, size: 36),
              const SizedBox(width: 8),
              Text(
                'Riwayat $_childName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Total Waktu: $_totalDurasi • Berinteraksi dengan $_totalBuku buku',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buatKartuBuku({
    required String ikon,
    required Color warnaIkon,
    required String judul,
    required String status,
    required double persentase,
    required Color warnaProgress,
    required String teksBawah,
    Color? teksBawahWarna,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: warnaIkon,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(ikon, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: persentase,
                    child: Container(
                      decoration: BoxDecoration(
                        color: warnaProgress,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  teksBawah,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: teksBawahWarna ?? warnaProgress,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}