import 'package:flutter/material.dart';

// ✅ Fix: void main() dan class AplikasiNotifikasi dihapus,
//         karena entry point ada di main.dart

class HalamanNotifikasi extends StatelessWidget {
  const HalamanNotifikasi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buatHeaderHitam(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buatKartuNotifikasi(
                    warnaTitik: Colors.green.shade400,
                    teksUtama: '🎉 Andi menyelesaikan buku "Dunia Bawah Laut"! Badge Pembaca Pertama berhasil diraih.',
                    waktu: 'Kemarin, 16:02',
                    sudahDibaca: false,
                  ),
                  const SizedBox(height: 12),
                  _buatKartuNotifikasi(
                    warnaTitik: Colors.blue.shade400,
                    teksUtama: '📖 Andi mulai membaca "Si Kancil dan Buaya" (buku baru).',
                    waktu: 'Hari ini, 14:28',
                    sudahDibaca: false,
                  ),
                  const SizedBox(height: 12),
                  _buatKartuNotifikasi(
                    warnaTitik: Colors.amber.shade400,
                    teksUtama: '⏰ Pengingat: Andi belum membaca hari ini. Yuk semangati si kecil!',
                    waktu: 'Kemarin, 20:00',
                    sudahDibaca: false,
                  ),
                  const SizedBox(height: 12),
                  _buatKartuNotifikasi(
                    warnaTitik: Colors.grey.shade400,
                    teksUtama: '📚 Buku "Petualangan Antariksa" berhasil diunggah ke perpustakaan Andi.',
                    waktu: '3 hari lalu',
                    sudahDibaca: true,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buatHeaderHitam() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 32, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF333333),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🔔', style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Text(
                'Notifikasi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '3 notifikasi baru hari ini',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buatKartuNotifikasi({
    required Color warnaTitik,
    required String teksUtama,
    required String waktu,
    required bool sudahDibaca,
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
            margin: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.circle,
              size: 14,
              color: warnaTitik,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teksUtama,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: sudahDibaca ? Colors.grey.shade500 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  waktu,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
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